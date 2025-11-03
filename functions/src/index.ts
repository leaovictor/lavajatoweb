import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import * as mercadopago from "mercadopago";
import * as cors from "cors";

admin.initializeApp();
const db = admin.firestore();

const corsHandler = cors({ origin: true });

// 1. Corrigido: Usar 'token' ao invés de 'accesstoken' para corresponder ao .runtimeconfig.json
const mpToken = functions.config().mercadopago?.token;

if (!mpToken) {
  console.error("Mercado Pago access token not found. Set it with `firebase functions:config:set mercadopago.token=YOUR_TOKEN`");
  throw new Error("MERCADOPAGO_TOKEN_NOT_SET");
}

mercadopago.configure({
  access_token: mpToken,
});

// 2. Função Refatorada: Criar preferência de pagamento com CORS
export const createPreference = functions.https.onRequest((request, response) => {
  corsHandler(request, response, async () => {
    // Autenticação Manual
    const idToken = request.headers.authorization?.split("Bearer ")[1];
    if (!idToken) {
      response.status(401).send({ error: "Unauthorized" });
      return;
    }

    let decodedToken;
    try {
      decodedToken = await admin.auth().verifyIdToken(idToken);
    } catch (error) {
      console.error("Error verifying Firebase ID token:", error);
      response.status(401).send({ error: "Unauthorized" });
      return;
    }

    const userId = decodedToken.uid;
    const userEmail = decodedToken.email;
    const { planName } = request.body.data; // Callable functions wrap data in a 'data' object

    if (!planName || !userEmail) {
      response.status(400).send({ error: "O nome do plano e o email são obrigatórios." });
      return;
    }

    try {
      const planDoc = await db.collection("plans").doc(planName).get();
      if (!planDoc.exists) {
        response.status(404).send({ error: `Plano '${planName}' não encontrado.` });
        return;
      }
      const plan = planDoc.data();
      if (!plan || !plan.price) {
        response.status(500).send({ error: "Dados do plano são inválidos." });
        return;
      }

      const region = "us-central1";
      const projectId = process.env.GCLOUD_PROJECT;
      const notification_url = `https://${region}-${projectId}.cloudfunctions.net/mercadoPagoWebhook`;

      const preference = {
        items: [
          {
            title: `Assinatura ${plan.name}`,
            quantity: 1,
            currency_id: "BRL",
            unit_price: plan.price,
          },
        ],
        payer: {
          email: userEmail,
        },
        back_urls: {
          success: `https://${projectId}.firebaseapp.com/success`,
          failure: `https://${projectId}.firebaseapp.com/failure`,
          pending: `https://${projectId}.firebaseapp.com/pending`,
        },
        auto_return: "approved",
        external_reference: userId,
        notification_url: notification_url,
      };

      const mpResponse = await mercadopago.preferences.create(preference);
      response.status(200).send({ data: { init_point: mpResponse.body.init_point } });

    } catch (error) {
      console.error("Erro ao criar preferência do Mercado Pago:", error);
      response.status(500).send({ error: "Não foi possível criar a preferência de pagamento." });
    }
  });
});


// Função Webhook existente (com pequenas melhorias)
export const mercadoPagoWebhook = functions.https.onRequest(async (request, response) => {
  functions.logger.info("Webhook do Mercado Pago recebido!", { query: request.query });

  const { query } = request;
  const topic = query.topic || query.type;

  // O ID do pagamento pode vir em diferentes campos dependendo da versão da notificação
  const paymentId = query.id || (query["data.id"] as string | undefined);

  if (topic === "payment" && paymentId) {
    try {
      functions.logger.info(`Processando pagamento com ID: ${paymentId}`);

      const payment = await mercadopago.payment.findById(Number(paymentId));

      if (payment && payment.body) {
        const { status, external_reference, items } = payment.body;

        if (!external_reference) {
          functions.logger.warn(`external_reference não encontrado para o pagamento ${paymentId}. Ignorando.`);
          response.status(200).send("OK (ignored, no external_reference)");
          return;
        }

        const planName = items[0]?.title.includes("Básica") ? "basic" : "premium";

        if (status === "approved") {
          const userRef = db.collection("clientes").doc(external_reference);
          await userRef.update({
            subscriptionStatus: "active",
            subscriptionPlan: planName,
            subscriptionDate: admin.firestore.FieldValue.serverTimestamp(),
          });
          functions.logger.info(`Assinatura do usuário ${external_reference} atualizada para o plano ${planName}.`);
        }

        functions.logger.info(`Pagamento ${paymentId} processado com status: ${status}`);
      } else {
        functions.logger.error(`Pagamento com ID ${paymentId} não encontrado.`);
      }

      response.status(200).send("OK");
    } catch (error) {
      functions.logger.error("Erro ao processar o webhook do Mercado Pago:", error);
      response.status(500).send("Erro interno do servidor");
    }
  } else {
    // Responde OK para outros tipos de notificações para evitar reenvios.
    response.status(200).send("OK (not a payment notification)");
  }
});
