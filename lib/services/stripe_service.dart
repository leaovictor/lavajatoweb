import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:url_launcher/url_launcher.dart'; // Importação essencial
import 'dart:developer'; // Para logging

class StripeService {
  // Configuração para a instância do Firebase Functions
  final FirebaseFunctions _functions = FirebaseFunctions.instanceFor(region: 'us-central1');

  // TODO: Substitua pela sua chave publicável real do Stripe
  // ⚠️ Esta chave só precisa ser definida UMA VEZ na inicialização do seu aplicativo (ex: no main())
  static const String publishableKey = "pk_test_51SP3fjGfFFjcSNCzZk4A7oUOZOw8X7VICjykQMDV3ZmGxOFhOWGCs59PR1imv68JqbJFt8uOM1nWGELN6eM85Cwo00sKYqrrnl";

  // ⚠️ NOTA: Assumimos que Stripe.publishableKey e Stripe.instance.applySettings()
  // foram chamados uma vez no main() do seu aplicativo.

  Future<void> createCheckoutSessionAndRedirect({
    required String planId,
    required String successUrl,
    required String cancelUrl,
  }) async {
    // Validação básica
    if (planId.isEmpty) {
      throw ArgumentError('O planId não pode estar vazio.');
    }
    
    try {
      final HttpsCallable callable = _functions.httpsCallable('createCheckoutSession');
      
      log('Chamando createCheckoutSession para o plano: $planId');

      // 1. Chama a Cloud Function para criar a sessão
      final response = await callable.call<Map<String, dynamic>>({
        'planId': planId,
        'success_url': successUrl,
        'cancel_url': cancelUrl,
      });

      final sessionUrl = response.data?['url'] as String?;

      if (sessionUrl == null || sessionUrl.isEmpty) {
        throw Exception('A função em nuvem não retornou um URL de sessão válido. Verifique o log do Firebase.');
      }
      
      // 2. Redireciona o usuário para o URL do Stripe usando url_launcher
      final uri = Uri.parse(sessionUrl);
      
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication, // Abre no navegador padrão do dispositivo
        );
        log('Redirecionando para: $sessionUrl');
      } else {
        throw Exception('Não foi possível abrir o URL do Stripe: $sessionUrl');
      }

    } on FirebaseFunctionsException catch (e) {
      log('Erro do Servidor Firebase (${e.code}): ${e.message}');
      throw Exception('Erro do Servidor Stripe: ${e.message}');
    } on Exception catch (e) {
      log('Erro inesperado: $e');
      throw Exception('Erro inesperado ao processar o pagamento.');
    } catch (e) {
      log('Erro de tipo desconhecido: $e');
      throw Exception('Ocorreu um erro desconhecido.');
    }
  }
}

// Exemplo de como inicializar no seu main()
/*
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicialização do Stripe - CHAVE OBRIGATÓRIA
  Stripe.publishableKey = StripeService.publishableKey; 
  await Stripe.instance.applySettings();

  runApp(MyApp());
}
*/