"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.stripeWebhook = exports.createCheckoutSession = void 0;
const functions = require("firebase-functions");
const admin = require("firebase-admin");
const stripe_1 = require("stripe");
admin.initializeApp();
const db = admin.firestore();
// Stripe configuration
const stripeSecret = process.env.STRIPE_SECRET;
if (!stripeSecret) {
    console.error("STRIPE SECRET KEY NOT SET. Make sure to set the 'STRIPE_SECRET' environment variable.");
}
// Forcing the type since we check for existence above
const stripe = new stripe_1.default(stripeSecret, { apiVersion: '2024-06-20' });
exports.createCheckoutSession = functions.https.onCall(async (data, context) => {
    if (!stripeSecret) {
        throw new functions.https.HttpsError("unavailable", "Stripe secret key not set on the server.");
    }
    if (!context.auth) {
        throw new functions.https.HttpsError("unauthenticated", "Você deve estar logado para criar uma sessão de checkout.");
    }
    const userId = context.auth.uid;
    // O userEmail é importante para pré-preencher o checkout do Stripe
    const userEmail = context.auth.token.email;
    const { planId, success_url, cancel_url } = data;
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
    }
    catch (error) {
        console.error("Error creating Stripe checkout session:", error);
        if (error instanceof functions.https.HttpsError) {
            throw error;
        }
        throw new functions.https.HttpsError("internal", "Não foi possível criar a sessão de pagamento.");
    }
});
exports.stripeWebhook = functions.https.onRequest(async (request, response) => {
    var _a;
    const sig = request.headers['stripe-signature'];
    const webhookSecret = process.env.STRIPE_WEBHOOK_SECRET;
    if (!webhookSecret) {
        console.error("STRIPE WEBHOOK SECRET NOT SET.");
        response.status(400).send("Webhook secret not configured.");
        return;
    }
    let event;
    try {
        event = stripe.webhooks.constructEvent(request.rawBody, sig, webhookSecret);
    }
    catch (err) {
        console.error("Webhook signature verification failed.", err.message);
        response.status(400).send(`Webhook Error: ${err.message}`);
        return;
    }
    // Handle the checkout.session.completed event
    if (event.type === 'checkout.session.completed') {
        const session = event.data.object;
        const userId = session.client_reference_id;
        const planId = (_a = session.metadata) === null || _a === void 0 ? void 0 : _a.planId;
        if (!userId || !planId) {
            console.error("Webhook recebeu uma sessão sem client_reference_id (userId) ou planId.");
            response.status(200).send("OK (dados faltando)");
            return;
        }
        const customerId = session.customer;
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
        }
        catch (dbError) {
            console.error("Falha ao atualizar o status de assinatura do usuário no Firestore:", dbError);
            response.status(500).send("Database error.");
            return;
        }
    }
    response.status(200).send("OK");
});
//# sourceMappingURL=index.js.map