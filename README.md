# Painel CAGED Portuário

Painel para visualização de dados do CAGED (Cadastro Geral de Empregados e Desempregados) relacionados ao setor portuário.

## Automação com GitHub Actions

Este projeto utiliza GitHub Actions para automatizar a atualização de dados e o deploy para o shinyapps.io. O workflow está configurado para executar automaticamente no dia 29 de cada mês, quando novos dados do CAGED geralmente estão disponíveis.

### Configuração de Segredos

Para que o workflow funcione corretamente, é necessário configurar os seguintes segredos no repositório GitHub:

1. **SHINYAPPS_TOKEN** e **SHINYAPPS_SECRET**:
   - Acesse https://www.shinyapps.io/
   - Faça login com sua conta
   - Vá para Account → Tokens → Show
   - Copie o token e o secret

2. **GOOGLE_APPLICATION_CREDENTIALS**:
   - No console do Google Cloud:
     - Vá para IAM & Admin → Service Accounts
     - Crie ou selecione uma conta de serviço
     - Crie uma nova chave (formato JSON)
     - Copie todo o conteúdo do arquivo JSON

### Como configurar os segredos:

1. No GitHub, vá para o repositório
2. Clique em "Settings" (Configurações)
3. No menu lateral, clique em "Secrets and variables" → "Actions"
4. Clique em "New repository secret"
5. Adicione cada um dos segredos mencionados acima

### Teste de Credenciais

Antes de executar o workflow principal, você pode verificar se as credenciais estão configuradas corretamente:

1. No GitHub, vá para o repositório
2. Clique na aba "Actions"
3. Selecione o workflow "Test Credentials"
4. Clique em "Run workflow"

Este workflow executará apenas os testes de credenciais, sem atualizar dados ou fazer deploy.

### Execução Manual do Workflow Principal

Além da execução automática, você pode iniciar o workflow principal manualmente:

1. No GitHub, vá para o repositório
2. Clique na aba "Actions"
3. Selecione o workflow "Update Data and Deploy"
4. Clique em "Run workflow"

### Teste Local de Credenciais

Você também pode testar as credenciais localmente usando o script `test-credentials.R`:

```r
# Defina as variáveis de ambiente com suas credenciais
Sys.setenv(SHINYAPPS_TOKEN = "seu_token")
Sys.setenv(SHINYAPPS_SECRET = "seu_secret")

# Execute o script de teste
source("test-credentials.R")
```

## Estrutura do Projeto

- `app.R`: Aplicativo Shiny principal
- `caged-baixar-dados.R`: Script para baixar e processar os dados do CAGED
- `data/`: Diretório contendo os dados processados
- `www/`: Diretório contendo recursos estáticos (imagens, etc.)
- `rsconnect/`: Configurações de deploy para o shinyapps.io
- `dockerfile`: Configuração para containerização com Docker

## Desenvolvimento Local

Para executar o aplicativo localmente:

```r
shiny::runApp()
```
