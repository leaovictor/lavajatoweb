# LavaJato App - Agendamento Inteligente (Versão Web)

Este é um aplicativo web completo para agendamento de serviços de lava-jato, desenvolvido em Flutter com integração Firebase. O projeto abrange desde a autenticação de usuários até um painel administrativo, oferecendo um fluxo de ponta a ponta para clientes e administradores.

---

## ✨ Funcionalidades

- **Autenticação Completa:**
  - Cadastro com nome, e-mail, telefone e senha.
  - Login com e-mail e senha.
  - Recuperação de senha por e-mail.
  - Acesso restrito para o e-mail `admin@lavajato.com`.

- **Agendamento de Serviços:**
  - Visualização de serviços disponíveis.
  - Calendário para seleção de data.
  - Lógica de disponibilidade que mostra apenas os horários livres, evitando colisões.
  - Confirmação e salvamento do agendamento no Firestore.

- **Sistema de Assinaturas (Simulado):**
  - Tela com planos de assinatura (Básico e Premium).
  - Fluxo de pagamento simulado com Stripe (`PaymentSheet`).
  - Atualização do status de assinatura do cliente no Firestore após o "pagamento".

- **Área do Cliente:**
  - Visualização do status da assinatura.
  - Histórico de agendamentos, separado em "Próximas Reservas" e "Histórico".

- **Painel Administrativo:**
  - Acesso restrito ao administrador.
  - Dashboard com abas para "Agendamentos do Dia" e "Assinantes Ativos".
  - Visualização de todos os agendamentos do dia.
  - Funcionalidade para cancelar agendamentos.
  - Lista de todos os clientes com assinaturas ativas.

- **Notificações (Simuladas):**
  - Estrutura para envio de e-mails de confirmação de cadastro e agendamento.
  - Atualmente, as notificações são simuladas com `print` no console.

---

## 🛠️ Estrutura do Projeto

- **`lib/`**: Diretório principal do código-fonte.
  - **`main.dart`**: Ponto de entrada da aplicação, inicialização do Firebase e Stripe.
  - **`models/`**: Contém os modelos de dados (`Appointment`, `Client`, `Service`).
  - **`screens/`**: Contém todas as telas da aplicação, organizadas por funcionalidade (auth, home, admin, etc.).
  - **`services/`**: Camada de lógica de negócio.
    - **`auth_service.dart`**: Lida com a autenticação (Firebase Auth).
    - **`firestore_service.dart`**: Centraliza todas as operações com o Firestore.
    - **`notification_service.dart`**: Serviço simulado para notificações.
  - **`stripe_keys.dart`**: Armazena as chaves do Stripe (este arquivo está no `.gitignore`).

---

## 🚀 Como Executar o Projeto

1.  **Configure o Firebase:**
    -   Siga as instruções da documentação oficial do Firebase para criar um projeto e configurar o Flutter.
    -   Gere o arquivo `firebase_options.dart` com o FlutterFire CLI.

2.  **Configure as Chaves do Stripe:**
    -   Crie o arquivo `lib/stripe_keys.dart`.
    -   Adicione suas chaves de teste do Stripe a este arquivo:
        ```dart
        const String stripePublishableKey = 'sua_chave_publicavel';
        const String stripeClientSecret = 'seu_client_secret_simulado';
        ```

3.  **Instale as Dependências:**
    ```bash
    flutter pub get
    ```

4.  **Execute a Aplicação:**
    ```bash
    flutter run -d chrome
    ```

---

## 📝 Testes

O projeto inclui um teste de widget básico para a tela de login, localizado em `test/login_screen_test.dart`. Para executar todos os testes:

```bash
flutter test
```
