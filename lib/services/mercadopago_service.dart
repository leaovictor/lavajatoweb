import 'package:cloud_functions/cloud_functions.dart';

class MercadoPagoService {
  // Use a região configurada na sua Cloud Function.
  final FirebaseFunctions _functions = FirebaseFunctions.instanceFor(region: 'us-central1'); 

  /// Cria uma preferência de pagamento de forma segura através de uma Cloud Function 
  /// e retorna o URL de checkout (init_point).
  ///
  /// [planName] é o nome do plano (ex: "basic" ou "premium").
  /// @returns A URL de checkout (init_point) do Mercado Pago.
  /// @throws Exceção com a mensagem de erro da Cloud Function ou do SDK.
  Future<String> createPreferenceAndGetInitPoint({required String planName}) async {
    try {
      // LOG DE CONFIRMAÇÃO: Se você vir esta mensagem, o serviço foi chamado corretamente.
      print('Chamando Cloud Function "createPreference" com plano: $planName');

      final HttpsCallable callable = _functions.httpsCallable('createPreference');

      final response = await callable.call<Map<String, dynamic>>({
        'planName': planName,
      });

      final checkoutUrl = response.data?['init_point'] as String?;

      if (checkoutUrl == null) {
        // Se a função não lançar um erro, mas o init_point estiver faltando:
        throw Exception('A Cloud Function não retornou o init_point. Verifique os logs do servidor.');
      }

      return checkoutUrl;

    } on FirebaseFunctionsException catch (e) {
      // Erros específicos do Firebase Functions (ex: unauthenticated, not-found)
      print('Erro ao chamar a Cloud Function: ${e.code} - ${e.message}');
      // Lança uma exceção mais amigável usando a mensagem do servidor
      throw Exception('Erro do Servidor (${e.code}): ${e.message}'); 
    } catch (e) {
      // Outros erros (ex: falha de rede)
      print('Erro inesperado ao criar preferência: $e');
      throw Exception('Erro inesperado: $e');
    }
  }
}
