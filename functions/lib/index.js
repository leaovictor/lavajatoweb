"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.mercadoPagoWebhook = void 0;
const functions = require("firebase-functions");
const admin = require("firebase-admin");
const mercadopago = require("mercadopago");
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
exports.mercadoPagoWebhook = functions.https.onRequest(async (request, response) => {
    functions.logger.info("Webhook do Mercado Pago recebido!");
    const { query } = request;
    const topic = query.topic || query.type;
    const paymentId = query.id || query["data.id"];
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
                if (!externalReference) {
                    functions.logger.warn(`external_reference não encontrado para o pagamento ${paymentId}`);
                    response.status(200).send("OK"); // Retorna 200 para evitar re-tentativas do Mercado Pago
                    return;
                }
                // TODO: Atualize esta lógica para corresponder à sua estrutura do Firestore
                // Assumindo que external_reference é o ID do seu documento de agendamento
                const appointmentRef = admin.firestore().collection("appointments").doc(externalReference);
                await appointmentRef.update({
                    paymentStatus: paymentStatus,
                    paymentId: paymentId,
                });
                functions.logger.info(`Agendamento ${externalReference} atualizado com status: ${paymentStatus}`);
            }
            else {
                functions.logger.error(`Pagamento com ID ${paymentId} não encontrado.`);
            }
            response.status(200).send("OK");
        }
        catch (error) {
            functions.logger.error("Erro ao processar o webhook do Mercado Pago:", error);
            response.status(500).send("Erro interno do servidor");
        }
    }
    else {
        response.status(200).send("OK");
    }
});
//# sourceMappingURL=index.js.map