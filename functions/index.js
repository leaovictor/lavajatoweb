const functions = require("firebase-functions");
const admin = require("firebase-admin");
const stripe = require("stripe")(functions.config().stripe.secret_key);
const cors = require("cors")({ origin: true });

admin.initializeApp();

/**
 * Creates a Stripe Checkout session for a subscription.
 *
 * @param {object} data The data passed to the function.
 * @param {string} data.priceId The ID of the Stripe price.
 * @param {string} data.userId The ID of the user.
 * @returns {object} The Stripe Checkout session object.
 */
exports.createSubscriptionCheckoutSession = functions.https.onRequest((req, res) => {
  cors(req, res, async () => {
    if (req.method !== "POST") {
      res.status(405).send("Method Not Allowed");
      return;
    }

    try {
      const { priceId, userId } = req.body;

      if (!priceId || !userId) {
        res.status(400).send("Missing required parameters.");
        return;
      }

      const session = await stripe.checkout.sessions.create({
        payment_method_types: ["card"],
        line_items: [
          {
            price: priceId,
            quantity: 1,
          },
        ],
        mode: "subscription",
        // IMPORTANT: These URLs need to be replaced with your actual frontend URLs
        success_url: "https://your-website.com/success?session_id={CHECKOUT_SESSION_ID}",
        cancel_url: "https://your-website.com/cancel",
        client_reference_id: userId,
      });

      res.status(200).send({ id: session.id });
    } catch (error) {
      console.error("Error creating Stripe session:", error);
      res.status(500).send({ error: error.message });
    }
  });
});

/**
 * Stripe webhook to handle subscription events.
 */
exports.stripeWebhook = functions.https.onRequest(async (req, res) => {
    const stripeSignature = req.headers["stripe-signature"];

    // IMPORTANT: Set the webhook secret in your Firebase environment configuration
    // firebase functions:config:set stripe.webhook_secret="whsec_..."
    const endpointSecret = functions.config().stripe.webhook_secret;

    let event;
    try {
        event = stripe.webhooks.constructEvent(req.rawBody, stripeSignature, endpointSecret);
    } catch (err) {
        console.error("Webhook signature verification failed.", err.message);
        return res.status(400).send(`Webhook Error: ${err.message}`);
    }

    // Handle the event
    switch (event.type) {
        case 'customer.subscription.created':
        case 'customer.subscription.updated':
        case 'customer.subscription.deleted':
            const subscription = event.data.object;
            const userId = subscription.client_reference_id;

            if (!userId) {
                console.error('No client_reference_id found on subscription');
                break;
            }

            const subscriptionData = {
                subscriptionId: subscription.id,
                planId: subscription.items.data[0].price.id,
                status: subscription.status,
                currentPeriodEnd: admin.firestore.Timestamp.fromMillis(subscription.current_period_end * 1000),
            };

            try {
                await admin.firestore().collection('users').doc(userId).set({ subscription: subscriptionData }, { merge: true });
                console.log(`Subscription status for user ${userId} updated to ${subscription.status}.`);
            } catch (error) {
                console.error('Error updating user subscription status:', error);
            }
            break;
        default:
            console.log(`Unhandled event type ${event.type}`);
    }

    res.status(200).send();
});
