#!/bin/bash
set -e

# Define o caminho para o arquivo de estado do Tailscale
TAILSCALE_STATE_FILE="/data/tailscaled.state"

# --- LÓGICA DE CONFIGURAÇÃO ÚNICA DO TAILSCALE ---
# Apenas executa a configuração 'up' na primeira vez, se necessário.
# O daemon em si será gerenciado pelo Supervisor.

if [ ! -f "$TAILSCALE_STATE_FILE" ]; then
    echo "Estado do Tailscale não encontrado. Realizando a autenticação inicial..."
    if [ -z "${TS_AUTH_KEY}" ]; then
      echo "ERRO FATAL: O estado do Tailscale não existe e a TS_AUTH_KEY não foi definida."
      exit 1
    fi

    # Inicia o daemon TEMPORARIAMENTE para fazer a autenticação
    /usr/sbin/tailscaled --state="$TAILSCALE_STATE_FILE" --socket=/var/run/tailscale/tailscaled.sock &
    sleep 3

    # Autentica e efetivamente cria o arquivo de estado
    /usr/bin/tailscale up --authkey="${TS_AUTH_KEY}" --hostname="${TS_HOSTNAME:-rustdesk-server}" --accept-routes

    # Para o daemon temporário para que o Supervisor possa assumir o controle
    pkill tailscaled
    sleep 1
    echo "Autenticação inicial concluída. O estado do Tailscale foi criado."
else
    echo "Estado do Tailscale encontrado. O Supervisor irá gerenciar a conexão."
fi

echo "===================================================================="

# --- LÓGICA DA CHAVE DO RUSTDESK (sem alterações) ---
KEY_FILE="/data/id_ed25519"
if [ ! -f "$KEY_FILE" ]; then
    echo "Chave privada do RustDesk não encontrada. Gerando uma nova chave..."
    (cd /data && /usr/bin/hbbs)
    echo "Nova chave privada gerada."
else
    echo "Chave privada do RustDesk encontrada."
fi

echo ""
echo "--- SUA CHAVE PÚBLICA DO RUSTDESK ---"
PUBLIC_KEY=$(cat /data/id_ed25519.pub)
echo "Key: ${PUBLIC_KEY}"
echo "-------------------------------------"
echo ""

# Agora, passa o controle TOTAL para o Supervisor. Ele será o único
# responsável por iniciar e manter tailscaled, hbbs e hbbr.
echo "Iniciando o Supervisor para gerenciar todos os serviços..."
exec /usr/bin/supervisord -c /etc/supervisor/supervisord.conf
