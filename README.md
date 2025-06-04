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

### Workflows Disponíveis

#### 1. Test Credentials

Este workflow testa as credenciais do Google Cloud e do shinyapps.io para garantir que estão configuradas corretamente.

**Como executar:**
1. No GitHub, vá para o repositório
2. Clique na aba "Actions"
3. Selecione o workflow "Test Credentials"
4. Clique em "Run workflow" → "Run workflow"

#### 2. Update Data and Deploy

Este workflow atualiza os dados do CAGED e faz o deploy do aplicativo para o shinyapps.io.

**Execução automática:** O workflow é executado automaticamente no dia 29 de cada mês às 12:00 UTC.

**Como executar manualmente:**
1. No GitHub, vá para o repositório
2. Clique na aba "Actions"
3. Selecione o workflow "Update Data and Deploy"
4. Clique em "Run workflow" → "Run workflow"

### Scripts de Suporte

#### test-credentials.R

Script para testar as credenciais do Google Cloud e do shinyapps.io.

**Como executar localmente:**
```r
# Defina as variáveis de ambiente com suas credenciais
Sys.setenv(SHINYAPPS_TOKEN = "seu_token")
Sys.setenv(SHINYAPPS_SECRET = "seu_secret")

# Execute o script de teste
source("test-credentials.R")
```

#### deploy.R

Script para fazer o deploy do aplicativo para o shinyapps.io.

**Como executar localmente:**
```r
# Defina as variáveis de ambiente com suas credenciais
Sys.setenv(SHINYAPPS_TOKEN = "seu_token")
Sys.setenv(SHINYAPPS_SECRET = "seu_secret")

# Execute o script de deploy
source("deploy.R")
```

#### debug-deploy.R

Script para depurar problemas de deploy para o shinyapps.io. Fornece informações detalhadas sobre o ambiente e o processo de deploy.

**Como executar localmente:**
```r
# Defina as variáveis de ambiente com suas credenciais
Sys.setenv(SHINYAPPS_TOKEN = "seu_token")
Sys.setenv(SHINYAPPS_SECRET = "seu_secret")

# Execute o script de depuração
source("debug-deploy.R")
```

#### test-deploy-local.R

Script para testar o deploy localmente, sem fazer o deploy real. Verifica se o aplicativo está pronto para ser implantado.

**Como executar localmente:**
```r
# Defina as variáveis de ambiente com suas credenciais
Sys.setenv(SHINYAPPS_TOKEN = "seu_token")
Sys.setenv(SHINYAPPS_SECRET = "seu_secret")

# Execute o script de teste de deploy
source("test-deploy-local.R")
```

### Solução de Problemas

Se o workflow falhar, verifique os logs de execução para identificar o problema:

- **Erro de autenticação no shinyapps.io**: Verifique se os tokens estão corretos e não expiraram
- **Erro de autenticação no Google Cloud**: Verifique se a chave de serviço está correta e se a conta tem as permissões necessárias
- **Erro no script R**: Verifique os logs para identificar problemas no script de atualização de dados

Para depurar problemas de deploy, execute o script `debug-deploy.R` localmente para obter informações detalhadas sobre o ambiente e o processo de deploy.

## Estrutura do Projeto

- `app.R`: Aplicativo Shiny principal
- `caged-baixar-dados.R`: Script para baixar e processar os dados do CAGED
- `data/`: Diretório contendo os dados processados
- `www/`: Diretório contendo recursos estáticos (imagens, etc.)
- `rsconnect/`: Configurações de deploy para o shinyapps.io

## Desenvolvimento Local

Para executar o aplicativo localmente:

```r
shiny::runApp()
```

## Executando com Docker

Para construir e iniciar o contêiner localmente:

```bash
docker build -t painel_caged_portuario .
docker run -p 3838:3838 painel_caged_portuario
```

A aplicação estará disponível em <http://localhost:3838>.
