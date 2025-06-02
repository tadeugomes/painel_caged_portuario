# Imagem base com R, Shiny Server e RStudio
FROM rocker/shiny:latest

# Atualização e instalação das dependências do sistema operacional
RUN apt-get update && apt-get install -y \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    libharfbuzz-dev \
    libfribidi-dev \
    libfreetype6-dev \
    libpng-dev \
    libtiff5-dev \
    libjpeg-dev \
    libgit2-dev \
    libglpk-dev \
    libv8-dev \
    libcairo2-dev \
    libxt-dev \
    libgdal-dev \
    libgeos-dev \
    libproj-dev \
    libgl1-mesa-dev \
    libglu1-mesa-dev \
    && rm -rf /var/lib/apt/lists/*

# Instalar todos os pacotes R usados no app
RUN R -e "install.packages(c( \
  'shiny', 'shinydashboard', 'dplyr', 'tidyr', 'ggplot2', 'readr', 'purrr', \
  'tibble', 'stringr', 'forcats', 'highcharter', 'jsonlite', \
  'RColorBrewer', 'DT', 'lubridate', 'igraph' \
), repos = 'https://cloud.r-project.org')"

# Criar diretório da aplicação Shiny
RUN mkdir -p /srv/shiny-server/

# Copiar os arquivos do app para dentro da imagem
COPY . /srv/shiny-server/

# Permissão para o usuário 'shiny'
RUN chown -R shiny:shiny /srv/shiny-server

# Porta padrão do Shiny
EXPOSE 3838

# Comando de inicialização do servidor
CMD ["/usr/bin/shiny-server"]
