# VORA CLOUD - Calculadora de Taxas

Aplicação web para cálculo de taxas de cartão de crédito, débito e PIX.

## 🚀 Funcionalidades

- **Calculadora de Taxas**: Calcule taxas para VISA, MasterCard, ELO, Hiper e bandeiras customizadas
- **Múltiplos Pagamentos**: Divida uma venda em múltiplas formas de pagamento
- **Painel do Gestor**: Gerencie usuários, visualize taxas e monitore conexões
- **Sincronização em Nuvem**: Dados salvos no Supabase com sincronização automática
- **Modo Troca**: Suporte para operações de troca com crédito

## 🛠️ Tecnologias

- **Frontend**: React 18 (via CDN + Babel)
- **Estilização**: Tailwind CSS
- **Backend/Database**: Supabase (PostgreSQL)
- **Hosting**: Vercel
- **CI/CD**: GitHub Actions (keep-alive semanal)

## 📦 Deploy

O deploy é automático via Vercel. Cada push na branch `main` gera um novo deploy.

### Keep-Alive

Um GitHub Action roda semanalmente para evitar que o Supabase e Vercel pausem por inatividade.

## 📋 Setup do Banco de Dados

Execute o arquivo `setup_supabase.sql` no SQL Editor do Supabase para criar as tabelas necessárias.
