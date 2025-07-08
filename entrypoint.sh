#!/bin/bash
set -e

# Verifica se a chave de autenticação do Tailscale foi passada
if [ -z "${TS_AUTH_KEY}" ]; then
  echo "ERRO: A variável de ambiente TS_AUTH_KEY não foi definida."
  echo "Por favor, forneça sua chave de autenticação do Tailscale."
  exit 1
fi

# Define o nome do host para o Tailscale, ou usa um padrão
TS_HOSTNAME=${TS_HOSTNAME:-rustdesk-server}

# Inicia o daemon do Tailscale em segundo plano
/usr/sbin/tailscaled --state=/var/lib/tailscale/tailscaled.state --socket=/var/run/tailscale/tailscaled.sock &
PID_TAILSCALED=$!

# Espera um pouco para o daemon iniciar
sleep 3

# Conecta à sua tailnet
/usr/bin/tailscale up --authkey="${TS_AUTH_KEY}" --hostname="${TS_HOSTNAME}" --accept-routes

echo "===================================================================="
echo "Tailscale iniciado com sucesso como '${TS_HOSTNAME}'."
echo "===================================================================="

# --- LÓGICA DA CHAVE PERSISTENTE DO RUSTDESK (ATUALIZADA) ---
KEY_FILE="/data/id_ed25519"

if [ ! -f "$KEY_FILE" ]; then
    echo "Chave privada do RustDesk não encontrada em ${KEY_FILE}."
    echo "Gerando uma nova chave..."
    # MUDANÇA: Executa o comando hbbs dentro do diretório /data para que ele crie as chaves lá.
    (cd /data && /usr/bin/hbbs)
    echo "Nova chave privada gerada e armazenada em ${KEY_FILE}."
    echo "Esta chave será reutilizada em futuras execuções se o volume for mantido."
else
    echo "Chave privada do RustDesk encontrada em ${KEY_FILE}."
    echo "Usando a chave existente para garantir que os clientes não precisem de reconfiguração."
fi

echo ""
echo "--- SUA CHAVE PÚBLICA DO RUSTDESK ---"
# MUDANÇA: Extrai a chave pública executando o comando a partir do diretório /data.
PUBLIC_KEY=$(cd /data && /usr/bin/hbbs --get-key)
echo "Key: ${PUBLIC_KEY}"
echo "-------------------------------------"
echo "Use o IP do Tailscale deste servidor e a chave pública acima nos seus clientes RustDesk."
echo ""

# Inicia o Supervisor em primeiro plano para manter o contêiner em execução
echo "Iniciando os serviços RustDesk via Supervisor..."
exec /usr/bin/supervisord -c /etc/supervisor/supervisord.conf