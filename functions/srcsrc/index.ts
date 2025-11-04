import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import * as Stripe from "stripe";
import * as cors from "cors";

const stripe = new Stripe(functions.config().stripe.secret, {
  apiVersion: "2024-06-20",
});
const corsHandler = cors({ origin: true });

admin.initializeApp();

interface RequestBody {
  planId: string;
  userId: string;
  userEmail: string;
  success_url: string;
  cancel_url: string;
}

export const createCheckoutSession = functions.https.onRequest(
  (req: functions.https.Request, res: functions.Response) => {
    corsHandler(req, res, async () => {
      if (req.method !== "POST") {
        res.status(405).send({ error: "Método não permitido" });
        return;
      }

      const {
        planId,
        userId,
        userEmail,
        success_url,
        cancel_url,
      }: RequestBody = req.body;

      if (!planId || !userId || !userEmail || !success_url || !cancel_url) {
        res.status(400).send({ error: "Parâmetros ausentes" });
        return;
      }

      try {
        const prices: { [key: string]: string } = {
          basic: "price_1P6gjwLdHpz35336fL8eT2U5",
          premium: "price_1P6glFLdHpz35336gP6qLcrU",
        };

        const priceId = prices[planId];

        if (!priceId) {
          res.status(400).send({ error: "Plano inválido" });
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
          success_url: success_url,
          cancel_url: cancel_url,
          client_reference_id: userId,
          customer_email: userEmail,
        });

        res.status(200).send({
          url: session.url,
        });
      } catch (error) {
        console.error("Erro ao criar sessão de checkout:", error);
        res.status(500).send({ error: "Erro interno do servidor" });
      }
    });
  }
);
