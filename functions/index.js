const functions = require("firebase-functions");
const admin = require("firebase-admin");
const stripe = require("stripe")(functions.config().stripe.secret_key);
const cors = require("cors")({ origin: true });

admin.initializeApp();

/**
 * Creates a Stripe Checkout session for a service purchase.
 */
exports.createCheckoutSession = functions.https.onRequest((req, res) => {
  cors(req, res, async () => {
    if (req.method !== "POST") {
      res.status(405).send("Method Not Allowed");
      return;
    }

    try {
      const { serviceName, price, userId, appointmentData } = req.body;

      if (!serviceName || !price || !userId || !appointmentData) {
        res.status(400).send("Missing required parameters.");
        return;
      }

      const session = await stripe.checkout.sessions.create({
        payment_method_types: ["card"],
        line_items: [
          {
            price_data: {
              currency: "brl",
              product_data: {
                name: serviceName,
              },
              unit_amount: price, // Price in cents
            },
            quantity: 1,
          },
        ],
        mode: "payment",
        // IMPORTANT: These URLs need to be replaced with your actual frontend URLs
        success_url: "https://your-website.com/success?session_id={CHECKOUT_SESSION_ID}",
        cancel_url: "https://your-website.com/cancel",
        client_reference_id: userId,
        metadata: {
          appointment: JSON.stringify(appointmentData),
        },
      });

      res.status(200).send({ id: session.id });
    } catch (error) {
      console.error("Error creating Stripe session:", error);
      res.status(500).send({ error: error.message });
    }
  });
});

/**
 * Stripe webhook to handle payment events.
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

  // Handle the checkout.session.completed event
  if (event.type === 'checkout.session.completed') {
    const session = event.data.object;

    // Retrieve appointment data from metadata
    const appointmentData = JSON.parse(session.metadata.appointment);

    // Convert string dates back to DateTime objects for Firestore
    appointmentData.startTime = new Date(appointmentData.startTime);
    appointmentData.endTime = new Date(appointmentData.endTime);


    try {
      // Save the appointment to Firestore
      await admin.firestore().collection('appointments').add(appointmentData);
      console.log('Appointment created successfully for user:', session.client_reference_id);
    } catch (error) {
      console.error('Error saving appointment to Firestore:', error);
      return res.status(500).send('Error saving appointment.');
    }
  }

  res.status(200).send();
});
