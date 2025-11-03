"use strict";
var _a;
Object.defineProperty(exports, "__esModule", { value: true });
exports.mercadoPagoWebhook = exports.createPreference = void 0;
const functions = require("firebase-functions");
const admin = require("firebase-admin");
const mercadopago = require("mercadopago");
const cors = require("cors");
admin.initializeApp();
const db = admin.firestore();
// Inicializa o middleware CORS (necessário apenas para a função onRequest/webhook)
const corsHandler = cors({ origin: true });
// Configuração do Mercado Pago
const mpToken = (_a = functions.config().mercadopago) === null || _a === void 0 ? void 0 : _a.token;
if (!mpToken) {
    console.error("MERCADO PAGO TOKEN NOT SET. Certifique-se de configurar a chave 'mercadopago.token'.");
}
else {
    mercadopago.configure({
        access_token: mpToken,
    });
}
// --- FUNÇÃO 1: CRIAR PREFERÊNCIA (Chamada pelo App Flutter via SDK) ---
exports.createPreference = functions.https.onCall(async (data, context) => {
    // 1. Verificações Iniciais
    if (!mpToken) {
        throw new functions.https.HttpsError("unavailable", "O token de acesso ao Mercado Pago não foi configurado no servidor.");
    }
    if (!context.auth) {
        throw new functions.https.HttpsError("unauthenticated", "Você precisa estar logado para criar uma preferência de pagamento.");
    }
    const userId = context.auth.uid;
    // CORREÇÃO: Define um email de fallback se o email não estiver no token (soluciona o INVALID_ARGUMENT)
    const payerEmail = context.auth.token.email || `${userId}@anon.lavajato.com`;
    const { planName } = data;
    if (!planName) {
        throw new functions.https.HttpsError("invalid-argument", "O nome do plano é obrigatório.");
    }
    try {
        // 2. BUSCA CORRETA PELO ID DO DOCUMENTO (Assumindo que planName é o Document ID: "Basic")
        const planDoc = await db.collection("plans").doc(planName).get();
        if (!planDoc.exists) {
            // Se esta linha ainda for alcançada, a chave "Basic" no Firestore está errada.
            throw new functions.https.HttpsError("not-found", `Plano '${planName}' não encontrado.`);
        }
        const plan = planDoc.data();
        // 3. Verificação de Dados (Usando plan.name, o campo correto)
        if (!plan || !plan.price || !plan.name) {
            throw new functions.https.HttpsError("internal", "Dados do plano são inválidos (falta price ou name).");
        }
        // 4. Constrói a URL do webhook
        const region = process.env.FUNCTION_REGION || "us-central1";
        const projectId = process.env.GCLOUD_PROJECT;
        const notification_url = `https://${region}-${projectId}.cloudfunctions.net/mercadoPagoWebhook`;
        // 5. Constrói a preferência do Mercado Pago
        const preference = {
            items: [
                {
                    id: planName,
                    title: plan.name, // Usa plan.name
                    quantity: 1,
                    currency_id: "BRL",
                    unit_price: plan.price,
                },
            ],
            payer: {
                email: payerEmail, // Usa email de fallback se necessário
            },
            back_urls: {
                success: `https://${projectId}.firebaseapp.com/payment/success`,
                failure: `https://${projectId}.firebaseapp.com/payment/failure`,
                pending: `https://${projectId}.firebaseapp.com/payment/pending`,
            },
            auto_return: "approved",
            external_reference: userId,
            notification_url: notification_url,
        };
        const response = await mercadopago.preferences.create(preference);
        // 6. Retorna o URL de checkout
        return { init_point: response.body.init_point };
    }
    catch (error) {
        console.error("Erro ao criar preferência do Mercado Pago:", error);
        if (error instanceof functions.https.HttpsError) {
            throw error;
        }
        throw new functions.https.HttpsError("internal", "Não foi possível criar a preferência de pagamento.");
    }
});
// --- FUNÇÃO 2: WEBHOOK DO MERCADO PAGO (Sem alterações significativas) ---
exports.mercadoPagoWebhook = functions.https.onRequest(async (request, response) => {
    corsHandler(request, response, async () => {
        var _a;
        functions.logger.info("Webhook do Mercado Pago recebido!", { query: request.query });
        const { query } = request;
        const topic = query.topic || query.type;
        const paymentId = query.id || query["data.id"];
        if (topic === "payment" && paymentId) {
            try {
                if (!mpToken) {
                    functions.logger.error("Token MP ausente, não foi possível consultar o pagamento.");
                    response.status(503).send("Service Unavailable");
                    return;
                }
                const payment = await mercadopago.payment.findById(Number(paymentId));
                if (payment && payment.body) {
                    const { status, external_reference, items } = payment.body;
                    if (!external_reference) {
                        functions.logger.warn(`external_reference não encontrado para o pagamento ${paymentId}. Ignorando.`);
                        response.status(200).send("OK");
                        return;
                    }
                    const planName = (_a = items[0]) === null || _a === void 0 ? void 0 : _a.id;
                    if (status === "approved" && planName) {
                        const userRef = db.collection("clientes").doc(external_reference);
                        await userRef.set({
                            subscriptionStatus: "active",
                            subscriptionPlan: planName,
                            subscriptionDate: admin.firestore.FieldValue.serverTimestamp(),
                        }, { merge: true });
                        functions.logger.info(`Assinatura do usuário ${external_reference} atualizada para o plano ${planName}.`);
                    }
                    functions.logger.info(`Pagamento ${paymentId} processado com status: ${status}`);
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
            response.status(200).send("OK (non-payment topic)");
        }
    });
});
//# sourceMappingURL=index.js.map