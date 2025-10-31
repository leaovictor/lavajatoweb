# LavaJato App - Agendamento Inteligente

Este é um aplicativo de agendamento para serviços de lava-jato, desenvolvido em Flutter com integração Firebase. O projeto serve como um protótipo funcional completo (MVP), demonstrando um fluxo de usuário coeso, desde a autenticação até a consulta de agendamentos.

---

## ✨ Funcionalidades Atuais

O protótipo atual inclui as seguintes funcionalidades:

#### 1. **Autenticação de Usuários**
-   Login social integrado com **Google Sign-In** para um acesso rápido e seguro.
-   Fluxo de autenticação reativo que separa usuários logados e deslogados.

#### 2. **Listagem de Serviços**
-   A tela principal exibe uma lista de serviços buscando dados em tempo real do **Cloud Firestore**.
-   Interface em formato de cards, mostrando nome, descrição, duração e preço de cada serviço.

#### 3. **Agendamento Dinâmico**
-   Ao selecionar um serviço, o usuário é direcionado para uma tela de agendamento com calendário.
-   **Lógica anti-colisão:** o sistema verifica os horários já agendados para um determinado dia e exibe apenas os slots de tempo realmente disponíveis, evitando agendamentos duplicados.
-   O agendamento é salvo na coleção `appointments` do Firestore, associado ao ID do usuário.

#### 4. **Consulta de Agendamentos**
-   Uma aba dedicada ("Meus Agendamentos") permite que o usuário visualize seu histórico de agendamentos.
-   Os agendamentos são listados em ordem cronológica.
-   Ícones visuais diferenciam agendamentos futuros dos já concluídos.

---

## 🛠️ Tecnologias Utilizadas

-   **Framework:** Flutter 3.x
-   **Linguagem:** Dart
-   **Backend & Banco de Dados:** Firebase
    -   **Firebase Authentication:** para autenticação de usuários.
    -   **Cloud Firestore:** como banco de dados NoSQL em tempo real para serviços e agendamentos.
-   **Gerenciamento de Estado:** `StatefulWidget` com `setState` para estados locais de UI.
-   **Pacotes Principais:**
    -   `firebase_core`, `firebase_auth`, `cloud_firestore`
    -   `google_sign_in`
    -   `table_calendar`
    -   `font_awesome_flutter`
    -   `intl`

---

## 🚀 Próximos Passos e Melhorias

A base do projeto é sólida, mas as seguintes funcionalidades podem ser adicionadas para torná-lo ainda mais completo:

-   **[ ] Autenticação com E-mail/Senha:**
    -   Implementar uma tela de cadastro e lógica para login tradicional.

-   **[ ] Cancelamento de Agendamentos:**
    -   Adicionar um botão para que o usuário possa cancelar um agendamento futuro.

-   **[ ] Notificações Push:**
    -   Integrar o Firebase Cloud Messaging (FCM) para enviar lembretes de agendamento.

-   **[ ] Painel Administrativo:**
    -   Desenvolver uma interface (web ou no app) para que o administrador do lava-jato possa gerenciar os serviços (adicionar, editar, remover) e visualizar todos os agendamentos.

-   **[ ] Perfil de Usuário:**
    -   Uma tela onde o usuário possa editar suas informações e gerenciar seus veículos cadastrados.

-   **[ ] Cadastro de Veículos:**
    -   Permitir que o usuário salve seus veículos no perfil para uma seleção mais rápida durante o agendamento.
# lavajatoweb
# lavajatoweb
