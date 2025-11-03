import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import * as mercadopago from "mercadopago";

admin.initializeApp();

// Configure o Mercado Pago com suas credenciais
// TODO: Adicione seu Access Token do Mercado Pago em um ambiente seguro (ex: Firebase environment variables)
const mpConfig = functions.config().mercadopago;
if (!mpConfig || !mpConfig.accesstoken) {
  throw new Error("A configuração do Access Token do Mercado Pago não foi encontrada. Execute 'firebase functions:config:set mercadopago.accesstoken=SUA_CHAVE' para configurar.");
}
mercadopago.configure({
  access_token: mpConfig.accesstoken,
});

export const mercadoPagoWebhook = functions.https.onRequest(async (request, response) => {
  functions.logger.info("Webhook do Mercado Pago recebido!");

  const { query } = request;
  const topic = query.topic || query.type;
  const paymentId = query.id || (query["data.id"] as string | undefined);

  if (!topic || !paymentId) {
    functions.logger.warn("Parâmetros 'topic' ou 'id' ausentes.", { query });
    response.status(400).send("Parâmetros 'topic' ou 'id' ausentes.");
    return;
  }

  if (topic === "payment") {
    try {
      functions.logger.info(`Processando pagamento com ID: ${paymentId}`);

      const payment = await mercadopago.payment.findById(Number(paymentId));

      if (payment && payment.body) {
        const paymentStatus = payment.body.status;
        const externalReference = payment.body.external_reference;
        const plan = payment.body.items[0].title.includes("Básica") ? "basic" : "premium";

        if (!externalReference) {
          functions.logger.warn(`external_reference não encontrado para o pagamento ${paymentId}`);
          response.status(200).send("OK");
          return;
        }

        if (paymentStatus === "approved") {
          const userRef = admin.firestore().collection("clientes").doc(externalReference);
          await userRef.update({
            subscriptionStatus: "active",
            subscriptionPlan: plan,
            subscriptionDate: admin.firestore.FieldValue.serverTimestamp(),
          });
          functions.logger.info(`Assinatura do usuário ${externalReference} atualizada para o plano ${plan}`);
        }

        // Opcional: se você ainda quiser rastrear o status do pagamento em um agendamento
        // const appointmentRef = admin.firestore().collection("appointments").doc(externalReference);
        // await appointmentRef.update({
        //   paymentStatus: paymentStatus,
        //   paymentId: paymentId,
        // });

        functions.logger.info(`Pagamento ${paymentId} processado com status: ${paymentStatus}`);
      } else {
        functions.logger.error(`Pagamento com ID ${paymentId} não encontrado.`);
      }

      response.status(200).send("OK");
    } catch (error) {
      functions.logger.error("Erro ao processar o webhook do Mercado Pago:", error);
      response.status(500).send("Erro interno do servidor");
    }
  } else {
    response.status(200).send("OK");
  }
});
