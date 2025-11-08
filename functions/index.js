const functions = require("firebase-functions");
const admin = require("firebase-admin");
const stripe = require("stripe")(functions.config().stripe.secret_key);
const cors = require("cors")({ origin: true });

admin.initializeApp();

/**
 * Creates a Stripe Checkout session for a subscription.
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
 * Creates a Stripe Checkout session for a one-time payment.
 */
exports.sendPaymentLink = functions.https.onRequest((req, res) => {
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
        mode: "payment",
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
 * Reactivates a Stripe subscription.
 */
exports.reactivateSubscription = functions.https.onRequest((req, res) => {
  cors(req, res, async () => {
    if (req.method !== "POST") {
      res.status(405).send("Method Not Allowed");
      return;
    }

    try {
      const { subscriptionId } = req.body;

      if (!subscriptionId) {
        res.status(400).send("Missing subscriptionId.");
        return;
      }

      const subscription = await stripe.subscriptions.update(subscriptionId, {
        pause_collection: null,
      });

      res.status(200).send({ status: subscription.status });
    } catch (error) {
      console.error("Error reactivating subscription:", error);
      res.status(500).send({ error: error.message });
    }
  });
});

/**
 * Suspends a Stripe subscription.
 */
exports.suspendSubscription = functions.https.onRequest((req, res) => {
  cors(req, res, async () => {
    if (req.method !== "POST") {
      res.status(405).send("Method Not Allowed");
      return;
    }

    try {
      const { subscriptionId } = req.body;

      if (!subscriptionId) {
        res.status(400).send("Missing subscriptionId.");
        return;
      }

      const subscription = await stripe.subscriptions.update(subscriptionId, {
        pause_collection: {
          behavior: 'void',
        },
      });

      res.status(200).send({ status: subscription.status });
    } catch (error) {
      console.error("Error suspending subscription:", error);
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
        case 'checkout.session.completed':
            const session = event.data.object;
            const userId = session.client_reference_id;

            if (session.mode === 'subscription') {
                const subscriptionId = session.subscription;
                const subscription = await stripe.subscriptions.retrieve(subscriptionId);

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
            }
            break;
        case 'customer.subscription.updated':
        case 'customer.subscription.deleted':
            const subscription = event.data.object;
            const customer = await stripe.customers.retrieve(subscription.customer);
            const userEmail = customer.email;

            // Find user by email
            const userQuery = await admin.firestore().collection('users').where('email', '==', userEmail).get();
            if (!userQuery.empty) {
                const userId = userQuery.docs[0].id;
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
            }
            break;
        default:
            console.log(`Unhandled event type ${event.type}`);
    }

    res.status(200).send();
});

/**
 * Fetches Stripe dashboard metrics.
 */
exports.getStripeDashboardMetrics = functions.https.onRequest((req, res) => {
  cors(req, res, async () => {
    if (req.method !== "GET") {
      res.status(405).send("Method Not Allowed");
      return;
    }

    try {
      // MRR: Iterate through all active subscriptions and sum up the monthly price.
      let totalMRR = 0;
      let startingAfter = null;
      let hasMore = true;

      while (hasMore) {
        const subscriptions = await stripe.subscriptions.list({
          status: 'active',
          limit: 100,
          starting_after: startingAfter,
        });

        subscriptions.data.forEach(subscription => {
          subscription.items.data.forEach(item => {
            totalMRR += item.price.unit_amount / 100; // Amount is in cents
          });
        });

        if (subscriptions.has_more) {
          startingAfter = subscriptions.data[subscriptions.data.length - 1].id;
        } else {
          hasMore = false;
        }
      }

      // New Subscriptions: Count subscriptions created in the last 30 days.
      const thirtyDaysAgo = Math.floor((Date.now() - 30 * 24 * 60 * 60 * 1000) / 1000);
      const newSubscriptions = await stripe.subscriptions.list({
        created: { gte: thirtyDaysAgo },
        status: 'all',
      });

      const churnedSubscriptions = await stripe.subscriptions.list({
        status: 'canceled',
        cancel_at_period_end: false,
        canceled_at: { gte: thirtyDaysAgo },
      });

      const oneTimePayments = await stripe.charges.list({
        created: { gte: thirtyDaysAgo },
      });

      let additionalRevenue = 0;
      oneTimePayments.data.forEach(charge => {
        if (charge.customer && !charge.invoice) { // Filter out subscription payments
          additionalRevenue += charge.amount / 100;
        }
      });

      res.status(200).send({
        mrr: totalMRR,
        newSubscriptions: newSubscriptions.data.length,
        churn: churnedSubscriptions.data.length,
        additionalRevenue: additionalRevenue,
      });
    } catch (error) {
      console.error("Error fetching Stripe metrics:", error);
      res.status(500).send({ error: error.message });
    }
  });
});
