<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [Desafio ninja](#desafio-ninja)
  - [Escopo inicial](#escopo-inicial)
  - [Notas do escopo inicial](#notas-do-escopo-inicial)
  - [Pré-requisitos](#pr%C3%A9-requisitos)
    - [Docker e Docker-compose](#docker-e-docker-compose)
  - [Iniciando a aplicação](#iniciando-a-aplica%C3%A7%C3%A3o)
  - [Setup incial - populando o banco de dados](#setup-incial---populando-o-banco-de-dados)
  - [Como rodar os testes](#como-rodar-os-testes)
  - [Referências](#refer%C3%AAncias)
  - [Toubleshootings](#toubleshootings)
    - [Permissão negada para determinadas ações dentro do diretório da aplicação](#permiss%C3%A3o-negada-para-determinadas-a%C3%A7%C3%B5es-dentro-do-diret%C3%B3rio-da-aplica%C3%A7%C3%A3o)
    - [Arquivos rastreados pelo git após alterar permissões de acesso para o usuário atual](#arquivos-rastreados-pelo-git-ap%C3%B3s-alterar-permiss%C3%B5es-de-acesso-para-o-usu%C3%A1rio-atual)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# Desafio ninja

## Escopo inicial
Temos um problema grande com reuniões, elas são muitas e temos poucas salas disponíveis.
Precisamos de uma agenda para nos mantermos sincronizados e esse será seu desafio!
Temos 4 salas e podemos usá-las somente em horário comercial, de segunda a sexta das 09:00 até as 18:00.
Sua tarefa será de criar uma API REST que crie, edite, mostre e delete o agendamento dos horários para que os usuários não se percam ao agendar as salas.

## Notas do escopo inicial
- O teste deve ser escrito utilizando Ruby e Ruby on Rails
- Utilize as gems que achar necessário
- Não faça squash dos seus commits, gostamos de acompanhar a evolução gradual da aplicação via commits.
- Estamos avaliando coisas como design, higiene do código, confiabilidade e boas práticas
- Esperamos testes automatizados.
- A aplicação deverá subir com docker-compose
- Crie um README.md descrevendo a sua solução e as issues caso houver
- O desafio pode ser entregue abrindo um pull request ou fazendo um fork do repositório

## Pré-requisitos

Como na descrição do problema é pedido para que a aplicação "suba" usando o `docker-compose`, o único pré-requisito para inciar o projeto será o [Docker](https://www.docker.com/) e o [Docker-compose](https://docs.docker.com/compose/). Dito isso, não cabe a esse README falar sobre a instalação do Ruby, Ruby on Rails, Bundler, e afins...

### Docker e Docker-compose

É possível buildar e rodar o projeto dentro de um container do [Docker](https://www.docker.com/). Com ele é possível que o projeto execute na máquina destino sem a necessidade de nenhuma configuração de ambiente, como por exemplo e mencionado anteriormente, instalar Ruby, Rails e Bundler. Para isso basta ter o próprio [Docker](https://www.docker.com/) e [Docker-compose](https://docs.docker.com/compose/)(ferramenta do Docker para definir e rodar multiplas aplicações) instalados na máquina.

As diretrizes para instalação do Docker são essas: [Get Docker](https://www.docker.com/get-docker).

Obs: o Docker-compose está disponível ao instalar o Docker para os sistemas Windows e MacOS. Para usuários do sistema Linux, o `docker-compose` precisa ser instalado separadamente. Basta seguir o link ([Install Compose on Linux](https://docs.docker.com/compose/install/#install-compose)) clicando no item "Install Compose" no menu apresentado a esquerda e depois na aba "Linux" para seguir as instruções de instalação.

## Iniciando a aplicação

Novamente não cabe a esse README falar sobre a inicialização manualmente do servidor Rails, pois estamos usando o `docker-compose` como forma de "rodar" a aplicação

Para isso abra o terminal, clone a aplicação utilizando o [Git](https://git-scm.com/book/pt-br/v1/Primeiros-passos-Instalando-Git) e navegue até pasta:

`$ git clone git@github.com:lsfernandes92/desafio-ninja.git`

`$ cd desafio-ninja/`

Após isso faça o build do container do docker, que contém a aplicação e seu ambiente de desenvolvimento com o comando:

`$ docker-compose --build`

Inicie o container com:

`$ docker-compose up` (para mostrar o log e processos do servidor no terminal)

ou

`$ docker-compose up -d` (para dar um "detach" no terminal, assim o mesmo não ficará preso com a execução do container do servidor rails).

Em outro terminal ou no mesmo(caso usou a opção `-d`) faça o seguinte para criar o banco usado pela aplicação:

`$ docker-compose run web rake db:create`

## Setup incial - populando o banco de dados

Uma primeira opção seria rodar os comandos de praxe:

`$ docker-compose run web rails db:migrate` para rodar as migrações

e

`$ docker-compose run web rails db:seed` para popular o banco de dados.

Uma outra opção e com intuito de facilitar a navegação pela aplicação pela primeira vez, foi criado uma _task_ para servir de seed data. Para fazer uso da mesma, após estar com a aplicação "rodando" pelo endereço http://localhost:3000 digite o seguinte comando:

`$ docker-compose run web rails dev:setup`

Após isso terá uma saída como a seguinte:

```
=== Reseting data base with seed than run migrate
=== Data base reset finished!

```

O que esse comando faz é "dropar" e criar novamente o banco de dados, rodar as migrações e por fim popular o banco com os seeds localizado em `db/seeds.rb`.

O motivo por eu criar essa task e não optar por rodar o `rails db:reset` (que supostamente faria a mesma coisa) expliquei [nesse commit](https://github.com/lsfernandes92/desafio-ninja/commit/7d34bb33cdf70645280c5f28eb100190ddfcff5e).

## Como rodar os testes

Para os testes foi utilizado RSpec e para executar os mesmos execute o comando:

`$ docker-compose run web bin/rspec`

Exemplo de saida:

```
Randomized with seed 17226

Users requests
  when request with invalid headers
    returns status code 406 if no accept header sent
  when resquest with valid headers
    POST /users
      should create user
      with validations
        email should be present
        email should not be too long
        email should be saved in lower case
        email address should be unique
        name should be present
        rejects invalid email addresses
        name should not be too long
    GET /users
      returns users info
    PATCH/PUT /users/:id
      with invalid params
        should not update the user
      with valid params
        updates the user
    DELETE /users/:user_id
      should not delete an invalid user
      deletes the user
    GET /users/:id
      returns only first user
      returns 404 when user do not exist

Finished in 0.4118 seconds (files took 0.66875 seconds to load)
16 examples, 0 failures

Randomized with seed 17226
```

## Referências

  - [Quickstart: Compose and Rails](https://docs.docker.com/compose/rails/)
  - [Como o git gerencia mudanças de permissões em arquivos](https://medium.com/@tahteche/how-git-treats-changes-in-file-permissions-f71874ca239d)
  - [Ruby gems - onde procuro pelas Gem's pra adicionar no projeto](https://rubygems.org/)
  - [Curso de API da Udemy usado de referência](https://www.udemy.com/share/101C4OAkcScFlbQ3o=/)
  - [HTTP Statuses - uso como referência pra olhar os status codes](https://httpstatuses.com/)
  - [Apipie - Api documentation](https://github.com/Apipie/apipie-rails)

## Toubleshootings

### Permissão negada para determinadas ações dentro do diretório da aplicação

Utilizando o Ubuntu com o Docker, em algumas ocasiões após tentar rodar alguns comandos, ou até mesmo para editar arquivos, a mensagem de erro "Permission denied" é retornada.

Isso acontece porque quando o Docker executa o comando `rails new` ele roda esse comando como usuário root e consequente ele atribui como dono o mesmo usuário root para as pastas e arquivos criados sob esse comando.

Para que essa mensagem não volte a ocorrer rode o seguinte comando dentro da pasta aplicação no terminal.

`$ sudo chown -R $USER:$USER .`

O comando acima irá designar o usuário atual como dono da pasta, dos subdiretórios e dos arquivos que contém a pasta da aplicação.

Após isso, precisamos dar as devidas permissões de acesso para o usuário. E fazemos isso com:

`$ sudo chmod -R u+rwx .`

Isso fará com que o usuário atual tenha as permissões de leitura, escrita e execução para todas as pastas, subdiretórios e arquivos contidos na pasta da aplicaçap. Logo, a mensagem de permissão negada não deverá acontecer novamente :).

### Arquivos rastreados pelo git após alterar permissões de acesso para o usuário atual

Isso acontece porque o git detecta que as permissões dos arquivos foram alteradas. O git tem seu próprio jeito de manter esse rastreamento desses arquivos que é mudando o "file mode" para `100644` ou `100755`. Vide a imagem:

[![Screenshot-from-2022-01-20-18-37-23.png](https://i.postimg.cc/9f2BY4hV/Screenshot-from-2022-01-20-18-37-23.png)](https://postimg.cc/QF65XdCn)

Se após realizar as operações do problema acima você se deparar com o diretório inteiro da aplicação em seu "staged area" e não desejar que o git mantenha esse tipo de gerenciamento, basta rodar o comando:

`$ git config --local core.fileMode false`
