# RustDesk Tailscale

Este repositório contém arquivos necessários para criar uma imagem Docker que integra o RustDesk com o Tailscale, permitindo acesso remoto seguro a dispositivos.

Visa criar uma solução para atender meus clientes de forma mais segura e não depender de ferramentas de terceiros, garantindo melhor segurança e controle, pois a conexão não transita pela internet aberta e sim pela rede wireguard com criptografia de ponta a ponta.

De forma geral, é criado um contêiner sobre a imagem `debian:bullseye-slim` e inicializada com a instalação de programas necessários e os principais para o projeto: ***tailscale***, ***rustdesk server*** (`rustdesk-hbbs.deb` e `rustdesk-hbbr.deb`) e ***supervisor*** que fará o gerenciamento dos serviços do contêiner. Quando o contêniner é criado ele busca o volume na pasta padrão do docker `/var/lib/docker/volumes/${nome_do_container}_${nome_do_volume}`, caso não encontre ele irá criar, o mesmo ocorre com as chaves e estados de serviço, caso não seja encontrado ele cria nova chave e inicializa os serviços.

## Estrutura do Repositório

```tree
rustdesk-tailscale/
├── docker-compose.yaml
├── dockerfile
├── docker_run.sh
├── entrypoint.sh
├── .env.example
├── .github
│   └── workflows
├── .gitignore
├── .pre-commit-config.yaml
├── README.md
├── supervisord.conf
└── volumes
    ├── restaurar_volumes.sh
    ├── rustdesk-tailscale_rustdesk_data # Exemplo
    └── salvar_volumes.sh
```

- `docker-compose.yaml`
Arquivo principal de configuração do Docker Compose. Define como os containers Docker devem ser construídos, configurados e interagir entre si.

- `dockerfile`
Contém as instruções para construir a imagem Docker personalizada, especificando o sistema base, dependências e comandos de inicialização.

- `docker_run.sh`
Script shell para facilitar a execução de comandos Docker, geralmente usado para iniciar, parar ou gerenciar containers de forma automatizada.

- `entrypoint.sh`
Script executado como ponto de entrada do container. Prepara o ambiente antes de rodar o processo principal do container.

- `.env.example`
Exemplo de arquivo de variáveis de ambiente. Serve como modelo para criar um arquivo `.env` real, contendo configurações sensíveis ou específicas do ambiente.

- `.github/workflows`
Pasta que armazena arquivos de workflow do GitHub Actions, usados para automação de CI/CD (integração e entrega contínua).

- `.gitignore`
Lista de arquivos e pastas que o Git deve ignorar, evitando que arquivos desnecessários ou sensíveis sejam versionados.

- `.pre-commit-config.yaml`
Configuração do Pre-commit, uma ferramenta que executa verificações de qualidade de código antes de cada commit. Define quais verificações devem ser executadas, como formatação de código, linting, etc.

- `README.md`
Arquivo de documentação principal do projeto. Explica como instalar, configurar e usar o projeto.

- `supervisord.conf`
Arquivo de configuração do Supervisor, um gerenciador de processos que pode ser usado para manter múltiplos serviços rodando dentro do container.

- `volumes/`
Pasta para armazenar dados persistentes dos containers Docker.

- `restaurar_volumes.sh`
Script para restaurar dados dos volumes Docker a partir de backups.

- `salvar_volumes.sh`
Script para salvar (fazer backup) dos dados dos volumes Docker.

- `rustdesk-tailscale_rustdesk_data`
Exemplo de backup de volume Docker que armazena dados persistentes do RustDesk, neste caso, dados de chaves, configurações e estado de serviços. O nome do volume segue o padrão `${nome_do_container}_${nome_do_volume}`.

## Pré-requisitos

- Docker instalado na máquina.
- Docker Compose (opcional, mas recomendado para facilitar a gestão de containers).

## Instruções de Uso

1. **Clonar repositório do GitHub**:
   Navegue até a pasta em que deseja deixar o projeto e realize o clone.

   ```bash
   mkdir ~/pasta-de-projetos
   cd ~/pasta-de-projetos
   git clone https://github.com/ZRGRU/rustdesk-tailscale.git
   ```

   > `~/` é uma variável de sistema para o diretório padrão do usuário, onde fica as pastas `Documentos`, `Downloads` etc.

2. **Executar o Contêiner**:
   O contêiner docker pode ser executado usando o `docker run` ou `docker compose`.

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

   > Exemplo de como executar com `docker run`.

   ```bash
   docker compose up -d
   ```

   > Exemplo de como executar com `docker compose`.

   ```bash
   docker compose up -d --build
   ```

   > Caso seja feito qualquer alteração nos arquivos de configuração é necessário gerar uma nova imagem.
   > Para parar o contêiner é só executar o comando `docker compose down` dentro da pasta principal do projeto.

3. **Configurar o RustDesk**:
   Assim que o contêiner terminar de iniciar, você verá uma mensagem com a tag `Key: ${PUBLIC_KEY}`, essa é a chave que deve ser usada para conectar ao RustDesk, juntamente com o endereço IP do contêiner fornecido pelo Tailscale. Caso queira verificar os logs do contêiner, você pode usar o seguinte comando:

   ```bash
   docker logs rustdesk-tailscale
   ```

4. **Backup/restauração de volumes**:
   Assim que o contêiner já estiver em execução ele já terá seus dados salvos com persistência no sistema host, mas caso precise ser movido para outro
   host e não queira que seja gerada uma nova chave é necessário fazer o backup e restauração desses dados.

   ```bash
   bash salvar_volumes.sh
   ```

   > Exemplo de como executar o script de backup de volumes `salvar_volumes.sh`.

   ```bash
   bash restaurar_volumes.sh
   ```

   > Exemplo de como executar o script de restauração de volumes `restaurar_volumes.sh`.
