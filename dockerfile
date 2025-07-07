# =========================================================================
# Imagem base: Debian Slim é leve e estável.
# =========================================================================
FROM debian:bullseye-slim

# =========================================================================
# Argumentos e Variáveis de Ambiente
# Use ARG para facilitar a atualização de versões no futuro.
# =========================================================================
ARG RUSTDESK_VERSION=1.1.14
ENV DEBIAN_FRONTEND=noninteractive

# =========================================================================
# Instalação de Dependências, Tailscale e RustDesk Server
# Boas Práticas:
# - Agrupar comandos RUN para reduzir o número de camadas na imagem.
# - Limpar o cache do apt no final para manter a imagem pequena.
# =========================================================================
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    gnupg \
    supervisor \
    wget && \
    # Instalar Tailscale
    curl -fsSL https://pkgs.tailscale.com/stable/debian/bullseye.noarmor.gpg | tee /usr/share/keyrings/tailscale-archive-keyring.gpg >/dev/null && \
    curl -fsSL https://pkgs.tailscale.com/stable/debian/bullseye.tailscale-keyring.list | tee /etc/apt/sources.list.d/tailscale.list && \
    apt-get update && \
    apt-get install -y tailscale && \
    # Instalar RustDesk Server
    wget "https://github.com/rustdesk/rustdesk-server/releases/download/${RUSTDESK_VERSION}/rustdesk-server-hbbr_${RUSTDESK_VERSION}_amd64.deb" -O /tmp/rustdesk-server-hbbr.deb && \
    wget "https://github.com/rustdesk/rustdesk-server/releases/download/${RUSTDESK_VERSION}/rustdesk-server-hbbs_${RUSTDESK_VERSION}_amd64.deb" -O /tmp/rustdesk-server-hbbs.deb && \
    dpkg -i /tmp/rustdesk-server-hbbr.deb /tmp/rustdesk-server-hbbs.deb && \
    # Limpeza
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# =========================================================================
# Configuração
# Boas Práticas:
# - Copiar arquivos de configuração em vez de criá-los no RUN.
# - Declarar um volume para dados persistentes.
# =========================================================================
# Copia o script de inicialização e o arquivo de configuração do supervisor
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY supervisord.conf /etc/supervisor/supervisord.conf

# Torna o script de inicialização executável
RUN chmod +x /usr/local/bin/entrypoint.sh

# Declara um volume para os dados persistentes do RustDesk (a chave privada!)
VOLUME /data

# Expõe as portas padrão do RustDesk. Elas não precisam ser publicadas no host
# se você usar apenas o Tailscale, mas é uma boa prática documentá-las.
EXPOSE 21115/tcp 21116/tcp 21116/udp 21117/tcp 21118/tcp 21119/tcp

# =========================================================================
# Comando de Execução
# O entrypoint.sh cuidará da inicialização dos serviços.
# =========================================================================
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]