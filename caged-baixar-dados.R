# Limpar o ambiente (comentado para evitar problemas quando o script é sourced)
# rm(list = ls())



# Definir repositório CRAN antes de instalar pacotes
options(repos = c(CRAN = "https://cloud.r-project.org"))

# Configurar codificação UTF-8 globalmente
options(encoding = "UTF-8")



# Instalar e carregar pacotes individuais
library("dplyr")
library("tidyr")
library("ggplot2")
library("readr")
library("purrr")
library("tibble")
library("stringr")
library("forcats")
library("lubridate")
library("basedosdados")

# Detach plyr if it's loaded to avoid conflicts
if ("package:plyr" %in% search()) {
  detach("package:plyr", unload=TRUE)
}


# Defina o seu projeto no Google Cloud
#set_billing_id("observatorio-portuario")


# Criação da query utilizando SQL diretamente
#query <- "
#SELECT 
#  ano,
#  mes,
#  sigla_uf,
#  saldo_movimentacao,
#  id_municipio,
#  cnae_2_secao,
#  categoria,
#  cnae_2_subclasse,
#  cbo_2002,
#  grau_instrucao,
#  sexo,
#  salario_mensal,
#  indicador_trabalho_intermitente,
#  indicador_trabalho_parcial
#FROM `basedosdados.br_me_caged.microdados_movimentacao`
#WHERE cnae_2_subclasse IN (
#      --essas duas subclasses são da divisão 50 TRANSPORTE AQUAVIÁRIO
#      '5231101', --Administração da infraestrutura portuária
#      '5231102', --Atividades do operador portuário
#      --essas outras são novas
#      '5011401', --Transporte marítimo de cabotagem - carga
#      '5011402', --Transporte marítimo de cabotagem - passageiros
#      '5021101', --Transporte por navegação interior de carga, municipal, exceto travessia
#      '5021102', --Transporte por navegação interior de carga, intermunicipal, interestadual e internacional, exceto travessia
#      '5022001', --Transporte por navegação interior de passageiros em linhas regulares, municipal, exceto travessia
#      '5022002', --Transporte por navegação interior de passageiros em linhas regulares, intermunicipal, interestadual e internacional, exceto travessia
#      '5030101', --Navegação de apoio marítimo
#      '5030102', --Navegação de apoio portuário
#      '5030103', --Serviço de rebocadores e empurradores
#      '5091201', --Transporte por navegação de travessia, municipal
#      '5091202', --Transporte por navegação de travessia intermunicipal, interestadual e internacional
#      '5099801', --Transporte aquaviário para passeios turísticos
#      '5099899', --Outros transportes aquaviários não especificados anteriormente
#      --novas subclasses incluídas
#      '5012201', --Transporte marítimo de longo curso - carga
#      '5012202', --Transporte marítimo de longo curso - passageiros
#      '5231103', --Gestão de terminais aquaviários
#      '5232000', --Atividades de agenciamento marítimo
#      '5239701', --Serviços de praticagem
#      '5239799' --Atividades auxiliares dos transportes aquaviários não especificadas anteriormente
#)"

# Coleta dos dados
#df <- read_sql(query)
# Salvar os dados em csv
#df <- df[df$ano >= 2023, ]
#saveRDS(df, file = "data/df.rds")



###################


#### Leitura do arquivo salvo 

df <- readRDS("data/df.rds")



# Crie uma nova coluna de data

# Verifica se há NA e lida com eles antes de criar a coluna data
df <- df %>%
  # Remover ou substituir NAs nos anos e meses (depende do que você quer fazer com os NAs)
  filter(!is.na(ano) & !is.na(mes)) %>%
  # Certificar que ano e mês estão no formato numérico e são inteiros
  mutate(
    ano = as.integer(ano),
    mes = as.integer(mes),
    # Cria a coluna data garantindo que o mês seja sempre de dois dígitos
    data = ymd(paste(ano, sprintf("%02d", mes), "01"))
  )


##### Fazer label encoding das colunas do tipo factor

df_dois <- df %>%
  mutate(cnae_2_subclasse = recode(cnae_2_subclasse,
                                   '5231101' = 'Administração da infraestrutura portuária',
                                   '5231102' = 'Atividades do operador portuário',
                                   '5011401' = 'Transporte marítimo de cabotagem - carga',
                                   '5011402' = 'Transporte marítimo de cabotagem - passageiros',
                                   '5021101' = 'Transporte por navegação interior de carga, municipal, exceto travessia',
                                   '5021102' = 'Transporte por navegação interior de carga, intermunicipal, interestadual e internacional, exceto travessia',
                                   '5022001' = 'Transporte por navegação interior de passageiros em linhas regulares, municipal, exceto travessia',
                                   '5022002' = 'Transporte por navegação interior de passageiros em linhas regulares, intermunicipal, interestadual e internacional, exceto travessia',
                                   '5030101' = 'Navegação de apoio marítimo',
                                   '5030102' = 'Navegação de apoio portuário',
                                   '5030103' = 'Serviço de rebocadores e empurradores',
                                   '5091201' = 'Transporte por navegação de travessia, municipal',
                                   '5091202' = 'Transporte por navegação de travessia intermunicipal, interestadual e internacional',
                                   '5099801' = 'Transporte aquaviário para passeios turísticos',
                                   '5099899' = 'Outros transportes aquaviários não especificados anteriormente'))


df_dois$indicador_trabalho_parcial <- factor(df_dois$indicador_trabalho_parcial)

df_dois$indicador_trabalho_parcial <- fct_recode(df_dois$indicador_trabalho_parcial, 
                                                 'Sim' = '1', 'Nao' = '0', 'NA' = '9')

df_dois$indicador_trabalho_intermitente <- factor(df_dois$indicador_trabalho_intermitente)

df_dois$indicador_trabalho_intermitente <- fct_recode(df_dois$indicador_trabalho_intermitente, 
                                                      "Sim" = "1", "Nao" = "0", 'NA' = '9')

df_dois$grau_instrucao <- factor(df_dois$grau_instrucao)

df_dois$grau_instrucao <- fct_recode(df_dois$grau_instrucao,    
                                     'Analfabeto' = '1', 
                                     'Até 5ª Incompleto' = '2', 
                                     '5ª Completo Fundamental' = '3', 
                                     '6ª a 9ª Fundamental' = '4', 
                                     'Fundamental Completo' = '5',
                                     'Médio Incompleto' = '6', 
                                     'Médio Completo' = '7', 
                                     'Superior Incompleto' = '8', 
                                     'Superior Completo' = '9', 
                                     'Mestrado' = '10', 
                                     'Doutorado' = '11', 
                                     'Especialização' = '80')


df_dois$indicador_trabalho_intermitente <- factor(df_dois$indicador_trabalho_intermitente)


df_dois$indicador_trabalho_intermitente <- fct_recode(df_dois$indicador_trabalho_intermitente, 
                                                      'Sim' = '1', 'Nao' = '0', 'NA' = '9')

df_dois$saldo_movimentacao <- factor(df_dois$saldo_movimentacao)

df_dois$saldo_movimentacao <- fct_recode(df_dois$saldo_movimentacao, 
                                         "Admitidos" = "1", "Desligados" = "-1")




df_dois$sexo <- factor(df_dois$sexo)

df_dois$sexo <- fct_recode(df_dois$sexo, 
                           "Homem" = "1", "Mulher" = "3")



##### Mudar o tipo de dado para fazer o join abaixo
df_dois$cbo_2002<- factor(df_dois$cbo_2002)


#lendo arquivo da cbo 2002
cbo <- read_delim(file = 'data/cbo2002.csv', delim = ";",
                  col_type = list(.default = "f"),
                  locale = locale(encoding = "latin1"))



# substituindo o valor 517235 por 517335 da coluna CODIGO da tabela cbo
cbo <- 
  cbo %>% mutate(
    CODIGO = as.character(CODIGO),
    CODIGO = if_else(CODIGO == "517235", "517335", CODIGO),
    CODIGO = as.factor(CODIGO))




#da variáveil cbo_2002
df_tres <- 
  left_join(df_dois, #primeira tabela
            cbo, #segunda tabela
            by = c("cbo_2002" = "CODIGO")) %>% 
  mutate(cbo_2002 = TITULO) %>% #substituindo 
  select(!TITULO)


# Define um vetor com as regiões para criar uma nova coluna

regioes <- list(
  "Norte" = c("RO", "AC", "AM", "RR", "PA", "AP", "TO"),
  "Nordeste" = c("MA", "PI", "CE", "RN", "PB", "PE", "AL", "SE", "BA"),
  "Centro-Oeste" = c("MS", "MT", "GO", "DF"),
  "Sudeste" = c("MG", "ES", "RJ", "SP"),
  "Sul" = c("PR", "SC", "RS")
)

# Função para retornar a região a partir da sigla
get_regiao <- function(sigla) {
  regiao <- NA
  for (r in names(regioes)) {
    if (sigla %in% regioes[[r]]) {
      regiao <- r
      break
    }
  }
  return(regiao)
}

# Aplica a função para criar a nova coluna regiao
df_tres$regiao <- sapply(df_tres$sigla_uf, get_regiao)



# Selecionando as colunas desejadas para criar o valuebox
df_selecionado <- df %>%
  select(sigla_uf, saldo_movimentacao, data)


df_resumo <- df %>%
  group_by(sigla_uf, year = lubridate::year(data), month = lubridate::month(data)) %>%
  summarize(saldo_somado = sum(saldo_movimentacao, na.rm = TRUE)) %>%
  ungroup()

cat("Verificando df_resumo...\n")
print(head(df_resumo))
print(summary(df_resumo$year))
print(summary(df_resumo$month))


df_resumo <- df_resumo %>%
  mutate(data_mes = as.Date(paste(year, month, "01", sep = "-"), format = "%Y-%m-%d")) %>%
  select(sigla_uf, data_mes, saldo_somado)

cat("Verificando data_mes...\n")
print(head(df_resumo))
print(summary(df_resumo$data_mes))



df_variacao <- df_resumo %>%
  mutate(saldo_somado = as.numeric(saldo_somado)) %>%
  arrange(sigla_uf, data_mes) %>%
  group_by(sigla_uf) %>%
  mutate(
    saldo_anterior = lag(saldo_somado, n = 12),
    # Evita divisão por zero usando ifelse
    percentual_variacao = ifelse(
      is.na(saldo_anterior) | saldo_anterior == 0,
      NA_real_,  # Retorna NA quando saldo_anterior é zero ou NA
      round(((saldo_somado - saldo_anterior) / saldo_anterior) * 100, 2)
    ),
    saldo_trimestral_anterior = lag(saldo_somado, n = 3),
    # Evita divisão por zero usando ifelse
    variacao_trimestral = ifelse(
      is.na(saldo_trimestral_anterior) | saldo_trimestral_anterior == 0,
      NA_real_,  # Retorna NA quando saldo_trimestral_anterior é zero ou NA
      round(((saldo_somado - saldo_trimestral_anterior) / saldo_trimestral_anterior) * 100, 2)
    )
  ) %>%
  slice_max(order_by = data_mes, n = 1) %>%  # Seleciona a última data para cada sigla_uf
  ungroup()


# Seleciona o ultimo dado de mes disponivel para analise do mes vigente

ultimo_dado <- df_tres[df_tres$data == max(df_tres$data), ]

# --- Controle de processamento: só processa se arquivos não existem ou se force == TRUE ---
force <- TRUE # Altere para TRUE se quiser forçar o processamento e sobrescrita

arquivos <- c(
  "data/df.rds",
  "data/df_dois.rds",
  "data/df_tres.rds",
  "data/df_resumo.rds",
  "data/df_variacao.rds",
  "data/ultimo_dado.rds"
)

if (!all(file.exists(arquivos)) || force) {
  cat("Processando e salvando datasets intermediários...\n")
  # Salvar datasets intermediários para acelerar carregamento futuro
  saveRDS(df, file = "data/df.rds")
  saveRDS(df_dois, file = "data/df_dois.rds")
  saveRDS(df_tres, file = "data/df_tres.rds")
  saveRDS(df_resumo, file = "data/df_resumo.rds")
  saveRDS(df_variacao, file = "data/df_variacao.rds")
  saveRDS(ultimo_dado, file = "data/ultimo_dado.rds")
} else {
  cat("Arquivos intermediários já existem. Pulando processamento pesado.\n")
}
