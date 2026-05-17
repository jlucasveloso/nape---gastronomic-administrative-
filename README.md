# Napê — Gestão Gastronômica

App Flutter para gestão financeira de restaurantes. Controle de vendas, despesas, funcionários e análise de resultados em tempo real.

---

## Grupo

| Nome |
|------|
| João Lucas Veloso |
| Luiz Felipe |

---

## Tecnologias utilizadas

- Flutter / Dart
- Supabase (banco de dados e autenticação)
- Provider (gerenciamento de estado)
- fl_chart (gráficos)

---

## Pré-requisitos

Antes de rodar o projeto, certifique-se de ter instalado:

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (versão 3.10 ou superior)
- Android Studio ou VS Code com extensão Flutter
- Emulador Android ou dispositivo físico

---

## Passo a passo para rodar o projeto

### 1. Clonar o repositório

```bash
git clone -b dev https://github.com/jlucasveloso/nape---gastronomic-administrative-.git
```

### 2. Entrar na pasta do projeto

```bash
cd nape---gastronomic-administrative-
```

### 3. Abrir no VS Code

```bash
code .
```

### 4. Configurar o arquivo `.env`

Renomeie o arquivo `.env.example` para `.env`:

```bash
cp .env.example .env
```

Abra o arquivo `.env` e preencha com as credenciais do Supabase:

```env
SUPABASE_URL=Samuel insira aqui
SUPABASE_ANON_KEY=Samuel insira aqui
```

> Para obter as credenciais, entre em contato com algum dos membros do grupo.

### 5. Instalar as dependências

```bash
flutter pub get
```

### 6. Rodar o projeto

```bash
flutter run
```

---

## Funcionalidades

- Cadastro e login de usuários
- Dashboard com resumo financeiro
- Registro de vendas e despesas
- Despesas recorrentes com controle mensal
- Gestão de funcionários e pagamentos
- Tela de análise com DRE, CMV, CMO e comparação de períodos
- Painel administrativo com tabelas editáveis

---

## Arquitetura do projeto
lib/
├── features/
│   ├── auth/         — telas de login e cadastro
│   ├── dashboard/    — telas principais do usuário
│   │   ├── model/    — modelos de dados
│   │   ├── controller/
│   │   └── ui/       — telas
│   ├── admin/        — painel administrativo
│   └── perfil/       — perfil do restaurante
├── repositories/     — acesso ao banco de dados
├── shared/
│   └── widgets/      — componentes reutilizáveis
├── app_state.dart    — gerenciamento de estado global
└── main.dart

---

## Observações

- O banco de dados é hospedado no Supabase com Row Level Security (RLS) ativado
- Cada usuário acessa apenas os próprios dados
- O painel administrativo requer permissão especial configurada diretamente no banco
