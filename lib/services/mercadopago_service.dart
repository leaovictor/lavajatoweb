import 'package:cloud_functions/cloud_functions.dart';

class MercadoPagoService {
  final FirebaseFunctions _functions = FirebaseFunctions.instanceFor(region: 'us-central1'); // Especifique a região da sua função

  /// Cria uma preferência de pagamento de forma segura através de uma Cloud Function.
  ///
  /// [planName] é o nome do plano (ex: "basic" ou "premium") que deve corresponder
  /// ao ID do documento na coleção 'plans' no Firestore.
  Future<Map<String, dynamic>> createPreference(String planName) async {
    try {
      // Obtém a referência para a função 'createPreference'
      final HttpsCallable callable = _functions.httpsCallable('createPreference');

      // Chama a função com os parâmetros necessários
      final response = await callable.call<Map<String, dynamic>>({
        'planName': planName,
      });

      // A função retorna um mapa, e esperamos que contenha 'checkoutUrl' (ou 'init_point')
      final checkoutUrl = response.data['init_point'];

      if (checkoutUrl == null) {
        throw Exception('init_point not found in Cloud Function response');
      }

      return {'checkoutUrl': checkoutUrl};
    } on FirebaseFunctionsException catch (e) {
      // Erros específicos do Firebase Functions
      print('Erro ao chamar a Cloud Function: ${e.code} - ${e.message}');
      throw Exception('Failed to create Mercado Pago preference via Cloud Function.');
    } catch (e) {
      // Outros erros
      print('Erro inesperado: $e');
      throw Exception('An unexpected error occurred.');
    }
  }
}
