# SunSystem - Plataforma de Gestão de Engenharia

![SunSystem UI]

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

