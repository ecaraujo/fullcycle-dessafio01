# Etapa de construção
FROM golang:1.18-alpine AS builder

# Instale o upx para comprimir o binário
RUN apk add --no-cache upx

# Defina o diretório de trabalho
WORKDIR /app

# Copie o código fonte para o contêiner
COPY main.go .

# Inicialize o módulo Go (se necessário)
RUN go mod init fullcycle-rocks && go mod tidy

# Compile a aplicação com otimizações adicionais
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-w -s" -o app .

# Comprimir o binário usando upx
RUN upx --best --lzma -o app_compressed app

# Etapa final
FROM gcr.io/distroless/static:nonroot

# Copie o binário comprimido da etapa anterior
COPY --from=builder /app/app_compressed /app

# Defina o comando de entrada
USER nonroot:nonroot
ENTRYPOINT ["/app"]
