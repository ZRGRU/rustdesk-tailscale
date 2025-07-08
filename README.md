# RustDesk Tailscale

Este repositório contém um Dockerfile e scripts para criar uma imagem Docker que integra o RustDesk com o Tailscale, permitindo acesso remoto seguro a dispositivos.

## Estrutura do Repositório

rustdesk-tailscale/
├── Dockerfile
├── supervisord.conf
├── entrypoint.sh
├── docker-compose.yml
├── .env.example
└── .gitignore

- `Dockerfile`: Define a imagem Docker, instalando o RustDesk e o Tailscale.
- `entrypoint.sh`: Script de entrada que configura o Tailscale e inicia o RustDesk.
- `supervisord.conf`: Configuração do Supervisor para gerenciar os processos do Tailscale e do RustDesk.
- `docker-compose.yml`: Arquivo de configuração do Docker Compose para facilitar a execução do contêiner.
- `.env.example`: Exemplo de arquivo de variáveis de ambiente, que deve ser renomeado para `.env` e preenchido com os dados necessários.
- `.gitignore`: Lista de arquivos e diretórios a serem ignorados pelo Git.

## Instruções de Uso

1. **Construir a Imagem Docker**:

   ```bash
   docker build -t rustdesk-tailscale .
   ```

2. **Executar o Contêiner**:

   ```bash
   docker run -d \
   --name rustdesk-tailscale \
   --restart unless-stopped \
   -v rustdesk-data:/data \
   -e TS_AUTH_KEY="tskey-auth-key" \
   -e TS_HOSTNAME="$HOSTNAME" \
   --device=/dev/net/tun:/dev/net/tun \
   --cap-add=NET_ADMIN \
   rustdesk-tailscale:latest
   ```

3. **Configurar o RustDesk**:

Assim que o contêiner terminar de iniciar, você verá uma mensagem com a tag `Key: ${PUBLIC_KEY}`, essa é a chave que deve ser usada para conectar ao RustDesk, juntamente com o endereço IP do contêiner fornecido pelo Tailscale. Caso queira verificar os logs do contêiner, você pode usar o seguinte comando:

```bash
docker logs rustdesk-tailscale
```
