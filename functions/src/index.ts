import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import * as mercadopago from "mercadopago";

admin.initializeApp();
const db = admin.firestore();

// 1. Corrigido: Usar 'token' ao invés de 'accesstoken' para corresponder ao .runtimeconfig.json
const mpToken = functions.config().mercadopago?.token;

if (!mpToken) {
  console.error("Mercado Pago access token not found. Set it with `firebase functions:config:set mercadopago.token=YOUR_TOKEN`");
  throw new Error("MERCADOPAGO_TOKEN_NOT_SET");
}

mercadopago.configure({
  access_token: mpToken,
});

// 2. Nova Função: Criar preferência de pagamento
export const createPreference = functions.https.onCall(async (data, context) => {
  // Autenticação: Garante que o usuário está logado.
  if (!context.auth) {
    throw new functions.https.HttpsError("unauthenticated", "Você precisa estar logado para criar uma preferência de pagamento.");
  }

  const userId = context.auth.uid;
  const userEmail = context.auth.token.email;
  const { planName } = data; // Recebe o nome do plano do app cliente

  if (!planName || !userEmail) {
    throw new functions.https.HttpsError("invalid-argument", "O nome do plano e o email são obrigatórios.");
  }

  try {
    // Busca os detalhes do plano no Firestore
    const planDoc = await db.collection("plans").doc(planName).get();
    if (!planDoc.exists) {
      throw new functions.https.HttpsError("not-found", `Plano '${planName}' não encontrado.`);
    }
    const plan = planDoc.data();
    if (!plan || !plan.price) {
        throw new functions.https.HttpsError("internal", "Dados do plano são inválidos.");
    }

    // Constrói a URL do webhook dinamicamente
    const region = "us-central1"; // Ou a região onde sua função está hospedada
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
        // TODO: Substitua pelas URLs do seu app web
        success: `https://${projectId}.firebaseapp.com/success`,
        failure: `https://${projectId}.firebaseapp.com/failure`,
        pending: `https://${projectId}.firebaseapp.com/pending`,
      },
      auto_return: "approved",
      external_reference: userId, // Referência para identificar o usuário no webhook
      notification_url: notification_url, // URL para receber notificações de pagamento
    };

    const response = await mercadopago.preferences.create(preference);

    // Retorna o URL de checkout para o cliente
    return { init_point: response.body.init_point };

  } catch (error) {
    console.error("Erro ao criar preferência do Mercado Pago:", error);
    throw new functions.https.HttpsError("internal", "Não foi possível criar a preferência de pagamento.");
  }
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
