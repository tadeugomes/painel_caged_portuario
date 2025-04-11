# Configuração de Segredos para GitHub Actions

Este documento fornece instruções detalhadas sobre como obter e configurar os segredos necessários para o funcionamento do workflow de GitHub Actions neste projeto.

## 1. Configuração de Tokens do shinyapps.io

### Obtenção dos Tokens

1. Acesse https://www.shinyapps.io/
2. Faça login com a conta `observatoriopmaranhao@gmail.com`
3. No canto superior direito, clique no nome da conta e selecione "Tokens"
4. Clique em "Show" ou "Show Secret" para visualizar os tokens
5. Você verá dois valores: o Token e o Secret

### Configuração no GitHub

1. No GitHub, vá para o repositório
2. Clique em "Settings" (Configurações)
3. No menu lateral, clique em "Secrets and variables" → "Actions"
4. Clique em "New repository secret"
5. Adicione os seguintes segredos:
   - Nome: `SHINYAPPS_TOKEN` - Valor: [Token obtido do shinyapps.io]
   - Nome: `SHINYAPPS_SECRET` - Valor: [Secret obtido do shinyapps.io]

## 2. Configuração de Credenciais do Google Cloud

### Criação de Chave de Serviço

1. Acesse https://console.cloud.google.com/
2. Faça login com a conta `observatoriopmaranhao@gmail.com`
3. Selecione o projeto "observatorio-portuario"
4. No menu lateral, vá para "IAM & Admin" → "Service Accounts"
5. Crie uma nova conta de serviço ou selecione uma existente
   - Se criar nova: Dê um nome como "github-actions"
   - Conceda os papéis necessários (pelo menos "BigQuery User" e "BigQuery Job User")
6. Na lista de contas de serviço, clique na conta desejada
7. Vá para a aba "Keys" (Chaves)
8. Clique em "Add Key" → "Create new key"
9. Selecione o formato JSON e clique em "Create"
10. Um arquivo JSON será baixado automaticamente

### Configuração no GitHub

1. Abra o arquivo JSON baixado em um editor de texto
2. Copie todo o conteúdo do arquivo (é um objeto JSON completo)
3. No GitHub, vá para o repositório
4. Clique em "Settings" (Configurações)
5. No menu lateral, clique em "Secrets and variables" → "Actions"
6. Clique em "New repository secret"
7. Adicione o seguinte segredo:
   - Nome: `GOOGLE_APPLICATION_CREDENTIALS` - Valor: [Todo o conteúdo do arquivo JSON]

## Verificação da Configuração

Após configurar todos os segredos, você pode verificar se estão corretos usando o workflow de teste de credenciais:

1. No GitHub, vá para o repositório
2. Clique na aba "Actions"
3. Selecione o workflow "Test Credentials"
4. Clique em "Run workflow" → "Run workflow"
5. Acompanhe a execução do workflow para verificar se as credenciais estão configuradas corretamente

Este workflow executará apenas os testes de credenciais, sem atualizar dados ou fazer deploy, o que é mais seguro para verificação inicial.

Alternativamente, você pode executar o workflow principal:

1. No GitHub, vá para o repositório
2. Clique na aba "Actions"
3. Selecione o workflow "Update Data and Deploy"
4. Clique em "Run workflow" → "Run workflow"
5. Acompanhe a execução do workflow para verificar se está funcionando corretamente

## Solução de Problemas

Se o workflow falhar, verifique os logs de execução para identificar o problema:

- **Erro de autenticação no shinyapps.io**: Verifique se os tokens estão corretos e não expiraram
- **Erro de autenticação no Google Cloud**: Verifique se a chave de serviço está correta e se a conta tem as permissões necessárias
- **Erro no script R**: Verifique os logs para identificar problemas no script de atualização de dados

Para qualquer outro problema, consulte a documentação do GitHub Actions ou entre em contato com o administrador do repositório.
