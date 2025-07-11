# =========================================================================
# Imagem base: Debian Slim é leve e estável.
# =========================================================================
FROM debian:bullseye-slim

# =========================================================================
# Define o SHELL para garantir que pipelines falhem corretamente.
# =========================================================================
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# =========================================================================
# Argumentos e Variáveis de Ambiente
# =========================================================================
ARG RUSTDESK_VERSION=1.1.14
ENV DEBIAN_FRONTEND=noninteractive

# =========================================================================
# Instalação de Dependências, Tailscale e RustDesk Server
# =========================================================================
# hadolint ignore=DL3008
RUN apt-get update && \
    # Deixamos o apt resolver as dependências base, o que é mais robusto.
    apt-get install -y --no-install-recommends \
    ca-certificates \
    gnupg \
    supervisor \
    wget && \
    # Adiciona a chave e o repositório do Tailscale
    wget -qO- https://pkgs.tailscale.com/stable/debian/bullseye.noarmor.gpg | tee /usr/share/keyrings/tailscale-archive-keyring.gpg >/dev/null && \
    wget -qO- https://pkgs.tailscale.com/stable/debian/bullseye.tailscale-keyring.list | tee /etc/apt/sources.list.d/tailscale.list && \
    # Atualiza a lista de pacotes novamente após adicionar o repo do Tailscale
    apt-get update && \
    # Aqui sim podemos pinar a versão do Tailscale se quisermos, pois vem do repo.
    # Mas deixar sem a versão instala a mais recente, o que é bom para projetos pessoais.
    apt-get install -y --no-install-recommends tailscale && \
    #
    # --- Bloco de instalação do RustDesk ---
    #
    wget -q "https://github.com/rustdesk/rustdesk-server/releases/download/${RUSTDESK_VERSION}/rustdesk-server-hbbs_${RUSTDESK_VERSION}_amd64.deb" -O /tmp/rustdesk-hbbs.deb && \
    wget -q "https://github.com/rustdesk/rustdesk-server/releases/download/${RUSTDESK_VERSION}/rustdesk-server-hbbr_${RUSTDESK_VERSION}_amd64.deb" -O /tmp/rustdesk-hbbr.deb && \
    #
    # --- SOLUÇÃO: Removido o "=versão" ao instalar arquivos .deb locais ---
    #
    apt-get install -y --no-install-recommends /tmp/rustdesk-hbbs.deb /tmp/rustdesk-hbbr.deb && \
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
