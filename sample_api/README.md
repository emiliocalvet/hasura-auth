# Exemplo de api GraphQL com Hasura e Dart

### Hasura:
##### Engine GraphQL que gera schemas do baco de dados alvo. Importante frizar que as tabelas precisam ser criadas, pois não foram utilizadas migrations neste exemplo.

### Dart server:
##### Utilizado para criar o token JWT colocando todas as informações necessárias para validação de tabelas no payload do token (Esse processo deve ser realizado pelo keycloak).

### Como executar:
#### Para rodar o projeto basta ter o docker instalado e rodar o seguinte comando na raiz do projeto: ```docker compose up -d```