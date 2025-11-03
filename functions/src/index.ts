import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import Stripe from 'stripe';

admin.initializeApp();
const db = admin.firestore();

// Define a interface para os dados de entrada da função callable
interface CheckoutData {
  planId: string;
  success_url?: string;
  cancel_url?: string;
}

// Stripe configuration
const stripeSecret = process.env.STRIPE_SECRET;
if (!stripeSecret) {
  console.error("STRIPE SECRET KEY NOT SET. Make sure to set the 'STRIPE_SECRET' environment variable.");
}
// Forcing the type since we check for existence above
const stripe = new Stripe(stripeSecret as string, { apiVersion: '2024-06-20' });


export const createCheckoutSession = functions.https.onCall(async (data: unknown, context: any) => {
  if (!stripeSecret) {
    throw new functions.https.HttpsError("unavailable", "Stripe secret key not set on the server.");
  }
  
  if (!context.auth) {
    throw new functions.https.HttpsError("unauthenticated", "Você deve estar logado para criar uma sessão de checkout.");
  }

  const userId = context.auth.uid;
  // O userEmail é importante para pré-preencher o checkout do Stripe
  const userEmail = context.auth.token.email; 
  
  const { planId, success_url, cancel_url } = data as CheckoutData;

  // As URLs de sucesso/cancelamento são passadas pelo Flutter, 
  // mas fornecemos valores padrão como fallback
  const finalSuccessUrl = success_url || `https://lavajato-5944c.firebaseapp.com/payment/success`;
  const finalCancelUrl = cancel_url || `https://lavajato-5944c.firebaseapp.com/payment/failure`;

  if (!planId) {
    throw new functions.https.HttpsError("invalid-argument", "O 'planId' é obrigatório."); 
  }

  try {
    const planDoc = await db.collection("plans").doc(planId).get();
    if (!planDoc.exists) {
      throw new functions.https.HttpsError("not-found", `O plano '${planId}' não foi encontrado.`);
    }

    const plan = planDoc.data();
    if (!plan || !plan.price || !plan.name) {
      throw new functions.https.HttpsError("internal", "Os dados do plano são inválidos (falta preço ou nome).");
    }

    const session = await stripe.checkout.sessions.create({
      payment_method_types: ['card'],
      mode: 'subscription',
      line_items: [
        {
          price_data: {
            currency: 'brl',
            product_data: {
              name: plan.name,
            },
            unit_amount: Math.round(plan.price * 100),
            recurring: {
              interval: 'month',
            },
          },
          quantity: 1,
        },
      ],
      metadata: {
        planId: planId,
      },
      customer_email: userEmail,
      client_reference_id: userId,
      success_url: finalSuccessUrl,
      cancel_url: finalCancelUrl,
    });

    // Retornamos o URL para o Flutter abrir com url_launcher
    return { 
      sessionId: session.id,
      url: session.url 
    };

  } catch (error) {
    console.error("Error creating Stripe checkout session:", error);
    if (error instanceof functions.https.HttpsError) {
      throw error;
    }
    throw new functions.https.HttpsError("internal", "Não foi possível criar a sessão de pagamento.");
  }
});

export const stripeWebhook = functions.https.onRequest(async (request, response) => {
    const sig = request.headers['stripe-signature'] as string;
    const webhookSecret = process.env.STRIPE_WEBHOOK_SECRET;

    if (!webhookSecret) {
      console.error("STRIPE WEBHOOK SECRET NOT SET.");
      response.status(400).send("Webhook secret not configured.");
      return;
    }

    let event: Stripe.Event;

    try {
      event = stripe.webhooks.constructEvent(request.rawBody, sig, webhookSecret as string); 
    } catch (err: any) {
      console.error("Webhook signature verification failed.", err.message);
      response.status(400).send(`Webhook Error: ${err.message}`);
      return;
    }

    // Handle the checkout.session.completed event
    if (event.type === 'checkout.session.completed') {
      const session = event.data.object as Stripe.Checkout.Session;
      const userId = session.client_reference_id;
      const planId = session.metadata?.planId;

      if (!userId || !planId) {
        console.error("Webhook recebeu uma sessão sem client_reference_id (userId) ou planId.");
        response.status(200).send("OK (dados faltando)");
        return;
      }
      
      const customerId = session.customer as string;

      const userRef = db.collection("clientes").doc(userId);

      try {
        await userRef.set({
          subscriptionStatus: "active",
          subscriptionId: session.subscription, 
          customerId: customerId, 
          subscriptionPlan: planId,
          subscriptionDate: admin.firestore.FieldValue.serverTimestamp(),
        }, { merge: true });

        console.log(`Assinatura do usuário atualizada para userId: ${userId}`);
      } catch (dbError) {
        console.error("Falha ao atualizar o status de assinatura do usuário no Firestore:", dbError);
        response.status(500).send("Database error.");
        return;
      }
    }

    response.status(200).send("OK");
  });
