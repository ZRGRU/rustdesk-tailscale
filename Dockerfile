# =========================================================================
# Imagem base: Debian Slim é leve e estável.
# =========================================================================
FROM debian:bullseye-slim

# =========================================================================
# Argumentos e Variáveis de Ambiente
# =========================================================================
ARG RUSTDESK_VERSION=1.1.14
ENV DEBIAN_FRONTEND=noninteractive

# =========================================================================
# SOLUÇÃO PARA DL4006: Garante que os pipelines falhem se qualquer comando falhar
# =========================================================================
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# =========================================================================
# Instalação de Dependências, Tailscale e RustDesk Server
# =========================================================================
RUN apt-get update && \
    # SOLUÇÃO PARA DL4001: Remove 'curl' e usa apenas 'wget'
    apt-get install -y --no-install-recommends \
    ca-certificates=20250419 \
    gnupg=2.4.7-21 \
    supervisor=4.2.5-3 \
    wget=1.25.0-2 && \
    # SOLUÇÃO PARA DL4001: Trocamos 'curl' por 'wget -qO-'
    wget -qO- https://pkgs.tailscale.com/stable/debian/bullseye.noarmor.gpg | tee /usr/share/keyrings/tailscale-archive-keyring.gpg >/dev/null && \
    wget -qO- https://pkgs.tailscale.com/stable/debian/bullseye.tailscale-keyring.list | tee /etc/apt/sources.list.d/tailscale.list && \
    apt-get update && \
    # SOLUÇÃO PARA DL3015: Adicionamos --no-install-recommends
    # SOLUÇÃO PARA DL3008 (Opcional): Você pode pinar a versão, ex: tailscale=1.52.1-1
    apt-get install -y --no-install-recommends tailscale=1.84.0 && \
    #
    # --- Bloco de instalação do RustDesk (já usando wget) ---
    #
    wget -q "https://github.com/rustdesk/rustdesk-server/releases/download/${RUSTDESK_VERSION}/rustdesk-server-hbbs_${RUSTDESK_VERSION}_amd64.deb" -O /tmp/rustdesk-hbbs.deb && \
    wget -q "https://github.com/rustdesk/rustdesk-server/releases/download/${RUSTDESK_VERSION}/rustdesk-server-hbbr_${RUSTDESK_VERSION}_amd64.deb" -O /tmp/rustdesk-hbbr.deb && \
    apt-get install -y --no-install-recommends /tmp/rustdesk-hbbs.deb=1.1.14 /tmp/rustdesk-hbbr.deb=1.1.14 && \
    #
    # --- Limpeza ---
    #
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# =========================================================================
# Configuração (sem alterações aqui)
# =========================================================================
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY supervisord.conf /etc/supervisor/supervisord.conf

RUN chmod +x /usr/local/bin/entrypoint.sh

VOLUME /data
EXPOSE 21115/tcp 21116/tcp 21116/udp 21117/tcp 21118/tcp 21119/tcp

# =========================================================================
# Comando de Execução
# =========================================================================
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
