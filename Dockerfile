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

# Criar diretório e copiar arquivos
RUN mkdir -p /srv/shiny-server
WORKDIR /srv/shiny-server
COPY . /srv/shiny-server/

# Criar script de inicialização com debug
RUN echo '#!/bin/bash\n\
echo "=== Listing contents of /srv/shiny-server ==="\n\
ls -la /srv/shiny-server\n\
echo "=== Listing contents of /srv/shiny-server/data ==="\n\
ls -la /srv/shiny-server/data\n\
echo "=== Checking R installation ==="\n\
R --version\n\
echo "=== Starting Shiny Server ==="\n\
exec shiny-server >> /var/log/shiny-server.log 2>&1' > /start.sh \
&& chmod +x /start.sh

# Configurar permissões
RUN chown -R shiny:shiny /srv/shiny-server \
    && chmod -R 755 /srv/shiny-server

# Porta e comando de inicialização
EXPOSE 3838
CMD ["/start.sh"]
