import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import * as cors from 'cors';
import Stripe from 'stripe';

admin.initializeApp();
const db = admin.firestore();
const corsHandler = cors({ origin: true });

// Stripe configuration
const stripeSecret = functions.config().stripe?.secret;
if (!stripeSecret) {
  console.error("STRIPE SECRET KEY NOT SET. Make sure to set the 'stripe.secret' config key.");
}
const stripe = new Stripe(stripeSecret, { apiVersion: '2024-06-20' });


export const createCheckoutSession = functions.https.onCall(async (data, context) => {
  if (!stripeSecret) {
    throw new functions.https.HttpsError("unavailable", "Stripe secret key not set on the server.");
  }
  
  if (!context.auth) {
    throw new functions.https.HttpsError("unauthenticated", "You must be logged in to create a checkout session.");
  }

  const userId = context.auth.uid;
  const userEmail = context.auth.token.email;
  const { planId } = data;

  if (!planId) {
    throw new functions.https.HttpsError("invalid-argument", "The 'planId' is required.");
  }

  try {
    const planDoc = await db.collection("plans").doc(planId).get();
    if (!planDoc.exists) {
      throw new functions.https.HttpsError("not-found", `Plan '${planId}' not found.`);
    }

    const plan = planDoc.data();
    if (!plan || !plan.price || !plan.name) {
      throw new functions.https.HttpsError("internal", "Plan data is invalid (missing price or name).");
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
            unit_amount: Math.round(plan.price * 100), // Stripe expects the amount in cents
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
      success_url: data.success_url || `https://lavajato-5944c.firebaseapp.com/payment/success`,
      cancel_url: data.cancel_url || `https://lavajato-5944c.firebaseapp.com/payment/failure`,
    });

    return { sessionId: session.id };

  } catch (error) {
    console.error("Error creating Stripe checkout session:", error);
    if (error instanceof functions.https.HttpsError) {
      throw error;
    }
    throw new functions.https.HttpsError("internal", "Could not create payment session.");
  }
});

export const stripeWebhook = functions.https.onRequest(async (request, response) => {
  corsHandler(request, response, async () => {
    const sig = request.headers['stripe-signature'] as string;
    const webhookSecret = functions.config().stripe?.webhook_secret;

    if (!webhookSecret) {
      console.error("STRIPE WEBHOOK SECRET NOT SET.");
      response.status(400).send("Webhook secret not configured.");
      return;
    }

    let event: Stripe.Event;

    try {
      event = stripe.webhooks.constructEvent(request.rawBody, sig, webhookSecret);
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
        console.error("Webhook received a session without a client_reference_id (userId) or planId.");
        response.status(200).send("OK (missing data)");
        return;
      }

      const userRef = db.collection("clientes").doc(userId);

      try {
        await userRef.set({
          subscriptionStatus: "active",
          subscriptionId: session.subscription, // Store the subscription ID for future management
          subscriptionPlan: planId,
          subscriptionDate: admin.firestore.FieldValue.serverTimestamp(),
        }, { merge: true });

        console.log(`User subscription updated for userId: ${userId}`);
      } catch (dbError) {
        console.error("Failed to update user subscription status in Firestore:", dbError);
        response.status(500).send("Database error.");
        return;
      }
    }

    response.status(200).send("OK");
  });
});
