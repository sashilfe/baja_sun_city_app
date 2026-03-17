# SunSystem - Plataforma de Gestão de Engenharia

![SunSystem UI](/ui.png)

O **SunSystem** é uma plataforma de gestão de engenharia de alta performance desenvolvida especificamente para o ecossistema do **Baja SunCity (IFBA-Jequié)**. A plataforma integra um motor de Ordens de Serviço (OS) com rastreabilidade pericial e cronômetro em tempo real a uma Wiki Técnica inspirada no padrão GitBook para a perenização de manuais em Markdown.

Construído com Flutter e Firebase, o sistema resolve o desafio da comunicação e gestão de conhecimento em equipes de competição ao implementar notificações críticas via FCM API V1, controle rigoroso de dependências entre tarefas e análise de produtividade por subsistema. Ele transforma a rotina da oficina em um fluxo de dados estruturado que valida a dedicação dos membros e garante a continuidade técnica do grupo **MENTES**.

---

## ✨ Core Features

-   **Gestão de OS:** Sequenciamento inteligente (ex: `FASD-001`) e travas de segurança para tarefas dependentes, garantindo que os processos de manufatura sigam a ordem correta.
-   **Knowledge Base:** Repositório Markdown integrado para documentação de projeto e manufatura, criando uma base de conhecimento centralizada e perene no estilo GitBook/Notion.
-   **Real-time Sync:** Atualização instantânea de status de tarefas, comentários e badges de notificação para manter toda a equipe sincronizada.
-   **Segurança V1:** Implementação da nova API de mensagens do Google (FCM API V1) com autenticação segura via OAuth2 para notificações push.

---

## 🛠️ Tecnologias Utilizadas

-   **Frontend:** Flutter
-   **Backend & Database:** Firebase (Firestore, Authentication, Storage)
-   **Notificações:** Firebase Cloud Messaging (FCM API V1)
-   **Gerenciamento de Estado:** Provider
-   **Gráficos e Dashboards:** fl_chart
-   **Componentes:** flutter_svg, google_fonts, data_table_2

---

## 🚀 Como Começar

Siga as instruções abaixo para configurar o ambiente e rodar o projeto localmente.

### **Pré-requisitos**

-   [Flutter SDK](https://flutter.dev/docs/get-started/install) (versão 2.17.0 ou superior)
-   [Firebase CLI](https://firebase.google.com/docs/cli)
-   Um editor de código (VS Code, Android Studio, etc.)

### **Instalação**

1.  **Clone o repositório:**
    ```sh
    git clone https://github.com/seu-usuario/seu-repositorio.git
    cd seu-repositorio
    ```

2.  **Instale as dependências:**
    ```sh
    flutter pub get
    ```

3.  **Configure o Firebase:**
    -   Faça login no Firebase CLI: `firebase login`.
    -   Crie um projeto no [console do Firebase](https://console.firebase.google.com/).
    -   Adicione um aplicativo Android e/ou Web ao seu projeto Firebase.
    -   **Para Android:** Baixe o arquivo `google-services.json` e coloque-o em `android/app/`.
    -   **Para Web (e outras plataformas):** Configure as opções do Firebase no seu projeto Flutter usando o FlutterFire:
        ```sh
        flutterfire configure
        ```
    -   Isso irá gerar o arquivo `lib/firebase_options.dart` automaticamente.

4.  **Rode o aplicativo:**
    ```sh
    flutter run
    ```
    Selecione o dispositivo desejado (Web, Desktop ou Mobile) para iniciar a aplicação.

---

## License

Este projeto é distribuído sob a licença MIT. Veja o arquivo `LICENSE` para mais detalhes.

---

## 👥 Contributors ✨

Thanks goes to these wonderful people ([emoji key](https://allcontributors.org/docs/en/emoji-key)):

<!-- ALL-CONTRIBUTORS-LIST:START - Do not remove or modify this section -->
<!-- prettier-ignore-start -->
<!-- markdownlint-disable -->
<table>
  <tr>
    <td align="center"><a href="https://github.com/simon1tan"><img src="https://avatars.githubusercontent.com/u/1250858?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Simon Tan</b></sub></a><br /><a href="https://github.com/abuanwar072/Flutter-Responsive-Admin-Panel-or-Dashboard/issues?q=author%3Asimon1tan" title="Bug reports">🐛</a></td>
    <td align="center"><a href="https://github.com/gillescoolen"><img src="https://avatars.githubusercontent.com/u/31668393?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Gilles</b></sub></a><br /><a href="https://github.com/abuanwar072/Flutter-Responsive-Admin-Panel-or-Dashboard/issues?q=author%3Agillescoolen" title="Bug reports">🐛</a></td>
    <td align="center"><a href="https://github.com/RounakTadvi"><img src="https://avatars.githubusercontent.com/u/38634459?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Rounak Tadvi</b></sub></a><br /><a href="#maintenance-RounakTadvi" title="Maintenance">🚧</a> <a href="https://github.com/abuanwar072/Flutter-Responsive-Admin-Panel-or-Dashboard/commits?author=RounakTadvi" title="Code">💻</a></td>    
  </tr>
</table>

<!-- markdownlint-restore -->
<!-- prettier-ignore-end -->

<!-- ALL-CONTRIBUTORS-LIST:END -->

This project follows the [all-contributors](https://github.com/all-contributors/all-contributors) specification. Contributions of any kind welcome!
