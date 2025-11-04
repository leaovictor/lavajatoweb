"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.createCheckoutSession = void 0;
const functions = __importStar(require("firebase-functions"));
const admin = __importStar(require("firebase-admin"));
const stripe_1 = __importDefault(require("stripe"));
const cors_1 = __importDefault(require("cors"));
const stripe = new stripe_1.default(functions.config().stripe.secret);
const corsHandler = (0, cors_1.default)({ origin: true });
admin.initializeApp();
exports.createCheckoutSession = functions.https.onRequest((req, res) => {
    corsHandler(req, res, async () => {
        if (req.method !== "POST") {
            res.status(405).send({ error: "Método não permitido" });
            return;
        }
        const { planId, userId, userEmail, success_url, cancel_url, } = req.body;
        if (!planId || !userId || !userEmail || !success_url || !cancel_url) {
            res.status(400).send({ error: "Parâmetros ausentes" });
            return;
        }
        try {
            const prices = {
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
        }
        catch (error) {
            console.error("Erro ao criar sessão de checkout:", error);
            res.status(500).send({ error: "Erro interno do servidor" });
        }
    });
});
//# sourceMappingURL=index.js.map