FROM analythium/r2u-quarto:20.04

RUN addgroup --system app && adduser --system --ingroup app app
WORKDIR /home/app
COPY . .

# Pré-renderizar o documento (opcional)
# RUN quarto render dashboard.qmd

RUN chown app:app -R /home/app
USER app
EXPOSE 8080

# Servir o documento sem renderizar novamente
CMD ["quarto", "serve", "dashboard.qmd", "--port", "8080", "--host", "0.0.0.0", "--no-render"]
