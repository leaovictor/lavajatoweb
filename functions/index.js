const functions = require("firebase-functions");
const admin = require("firebase-admin");
const stripe = require("stripe")(functions.config().stripe.secret);
const cors = require("cors")({ origin: true });

admin.initializeApp();

exports.createCheckoutSession = functions.https.onRequest((req, res) => {
  cors(req, res, async () => {
    if (req.method !== "POST") {
      return res.status(405).send({ error: "Método não permitido" });
    }

    const { planId, userId, userEmail, success_url, cancel_url } = req.body;

    if (!planId || !userId || !userEmail || !success_url || !cancel_url) {
      return res.status(400).send({ error: "Parâmetros ausentes" });
    }

    try {
      const prices = {
        basic: "price_1P6gjwLdHpz35336fL8eT2U5",
        premium: "price_1P6glFLdHpz35336gP6qLcrU",
      };

      const priceId = prices[planId];

      if (!priceId) {
        return res.status(400).send({ error: "Plano inválido" });
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
        success_url: success_url,
        cancel_url: cancel_url,
        client_reference_id: userId,
        customer_email: userEmail,
      });

      return res.status(200).send({
        url: session.url,
      });
    } catch (error) {
      console.error("Erro ao criar sessão de checkout:", error);
      return res.status(500).send({ error: "Erro interno do servidor" });
    }
  });
});
