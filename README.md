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
  - [Melhorias](#melhorias)
  - [Toubleshootings](#toubleshootings)
    - [Permissão negada para determinadas ações dentro do diretório da aplicação](#permiss%C3%A3o-negada-para-determinadas-a%C3%A7%C3%B5es-dentro-do-diret%C3%B3rio-da-aplica%C3%A7%C3%A3o)
    - [Arquivos rastreados pelo git após alterar permissões de acesso para o usuário atual](#arquivos-rastreados-pelo-git-ap%C3%B3s-alterar-permiss%C3%B5es-de-acesso-para-o-usu%C3%A1rio-atual)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# Desafio ninja

O propósito desse repositório é de elaborar um sistema de agendamento usando o framework Ruby on Rails. O projeto foi sugerido pela GetNinjas para uma vaga de desenvolvedor Rails. O escopo da aplicação é o seguinte: [escopo inicial](#escopo-inicial).

_Importante ressaltar que para que esse documento não fique tão repetitivo usando a palavra "agendamento", foi usado sinônimos dessa mesma palavra, mas que todas elas se subentende por ser um agendamento._

As principais classes do modelo de negócio que identifiquei foram: `User`, `Appointment` e `Room`. Como forma de me guiar, progredi com o projeto navegando em outros aplicativos de agendamento semelhantes como o Google Agenda e o próprio Calendar do Linux.

No que se diz respeito a modelagem da aplicação tentei ser o mais simples possível tentando cumprir com os requisitos do escopo e não reinventar a roda. Portanto, a versão aqui presente seria minha primeira implementação, e claro, abrindo mão para melhorias futuras conforme necessidades forem surgindo.

Para esse projeto imaginei um fluxo da seguinte forma: um usuário irá entrar no aplicação e se deparar com um calendário, navegando pelo calendário ele irá escolher um dia, ao clicar no dia uma nova janela seria aberta para criação do novo evento, a janela que iria abrir teria os campos relacionados a criação do evento. Seriam eles: o título, notas adicionais, data e horário inicial, data e horário final, e a sala que determina onde irá ocorrer o evento. Bastaria preencher os campos necessários e criar efetivamento o agendamento.

Para um agendamento ser concluído, pelo menos um usuário e uma sala deverá existir necessariamente. Isso porque imaginei que um agendamento só poderá ser criado através de um usuário, no qual também, deverá sinalizar obrigatóriamente uma determinada localização(sala) para a convocação. A API dispõe do endpoint `POST /v1/users/:user_id/relationships/appointment` para tal ação de criação de um agendamento.

Os agendamentos existentes só poderão serem consultados através de um usuário e ou uma sala. Ou seja, um usuário terá relacionado nenhum ou vários agendamentos que ele criou ou não posteriormente. A mesma coisa acontecerá para a sala, ou seja, no momento em que um usuário criar um agendamento e atrelar uma sala, essa sala ficará relacionada com esse agendamento. Então uma sala poderá ter também nenhum ou vários agendamentos. Para isso, a API dispõe os endpoints `GET v1/users/:user_id/relationships/appointments` ou `GET v1/rooms/:room_id/relationships/appointments` para tal ação de consulta de agendamentos.

No que diz respeito a criação, alteração, e exclusão dos compromissos deve-se ter em mente que somente os usuários tem esse poder e somente o dono de um agendamento poderá realizar essas ações. Para isso, a API dispõe os endpoints `POST v1/users/:user_id/relationships/appointment`, `PATCH/PUT v1/users/:user_id/relationships/appointment` e `DELETE v1/users/:user_id/relationships/appointment` para as respectivas ações.

Ao tentar criar um agendamento existe algumas validações que irei citar aqui de antemão. Algumas delas(se não esqueci de nenhuma :sweat_smile:) são:

* Um agendamento só poderá ser alterado responsável por sua criação
* Um agendamento deverá ter como data inicial e final a mesma, porém horários e salas diferentes
* A criação de um agendamento só será permitida se a data for igual ou maior que a atual
* Como pedido, um agendamento só poderá ser criado em dias da semana
* Como pedido também, um agendamento só poderá ser criado das 9h às 18h
* Dois agendamentos poderão ter a mesma data e horário se forem criados em salas diferentes

Falando sobre a API... A opção por usar o Active Model Serializer na API foi pela maior flexibilidade para trabalhar com retornos JSON. Essa maior flexibilidade acontece usando os componentes serializers. Não só isso, mas talvez o mais importante é de que usando o AMS conseguimos alterar o adapter da aplicação. E com isso a possibilidade de conseguir seguir uma especificação, a famigerada [{json:api}](https://jsonapi.org/). Com ela é possível seguir boas práticas caso haja alguma dúvida no momento da implementação da API. Algumas das boas práticas, sugeridas por essa especificação e seguidas aqui nesse projeto, foram:

* **Visualização de Campos Associados em Models**: Quando um model guarda o id de um outro model no qual faz associação, o response dessa associação não vira descrito o que ela representa e sim somente o id e um link de referência para consulta. Por exemplo, nesse projeto é possível ver os agendamentos de um usuário através do nó "relationships" e então "appointments".

```
{
  {
      "data": {
          "id": "2",
          "type": "users",
          "attributes": {
              "name": "Daisy Chain",
              "email": "argelia.hauck@dibbert.biz"
          },
          "relationships": {
              "appointments": {
                  "data": [
                      {
                          "id": "4",
                          "type": "appointments"
                      },
                      ...
                  ],
                  "links": {
                      "related": "http://localhost:3000/v1/users/2/relationships/appointments"
                  }
              }
          },
          "links": {
              "self": "http://localhost:3000/v1/users/2"
          }
      }
  }
```

* **Links(HATEOAS)**: Faz parte de uma das constraints do RESTful, a Interface Uniforme com hypermedia. É justamente o que faz o item acima "Visualização de Campos Associados em Models" no momento de trazer suas associações e disponibilizando através dos nós "links". Isso é facilmente implementado fazendo algo da seguinte forma nos serializers:

```
has_many :appointments do
  link(:related) { v1_user_appointments_url(object.id) }
end

link(:self) { v1_user_url(object) }
```

* **Content negociation com media types**: É a definição de "Uma string que define qual o formato do dado e como ele vai ser lido pela máquina. Isso permite um computador diferenciar entre JSON e XML, por exemplo". Eles fazem parte dos headers de uma requisição/resposta. Alguns exemplos são:
  * application/json
  * application/xml
  * multipart/form-data
  * text/html

  A especificação diz que as responsabilidades do cliente são:
    * Ignorar qualquer "response" que não venha com o "header" `Content-Type: application/vnd.api+json`
    * Quando uma requisição for enviar qualquer tipo de informação no corpo da mesma, ela enviada com o "header" `Content-Type: application/vnd.api+json`
    * Para qualquer requisição o cliente deve informar o "header" `Accept: application/vnd.api+json`

  A especificação fala também que aa responsabilidades do servidor são:
    * Deverá sempre responder com o "header" `Content-Type: application/vnd.api+json`
    * Deverá responder com o status code **415 Unsupported Media Type** quando uma requisição com "body" não enviar o "header" `Content-Type: application/vnd.api+json`
    * Deverá responder com o status code **406 Not Acceptable** quando uma requisição não enviar o "header" `Accept: application/vnd.api+json`

* **Paginação**: O servidor quando escolher responder com paginação ele deverá conter os seguintes links de paginação em sua resposta:
  * **first**: the first page of data
  * **last**: the last page of data
  * **prev**: the previous page of data
  * **next**: the next page of data


* **Erros amigáveis**: Quando o servidor encontra um erro ele pode optar por devolver o erro(s) de forma mais inteligível para o usuário. Se ele optar por enviar esse objeto de erro como resposta, esse objeto deverá ter o nó "errors" como mais externo e dentro dele uma array de objetos que poderá ter alguns nós como membros, por exemplo, `id`, `links`, `status`, `code`, `title`, `detail`, `source` e  `meta`.

  Isso pode ser visto ao tentar fazer um `POST /v1/users/1/relationships/appointment` não enviando os dados do agendamento
```
{
    "errors": [
        {
            "id": "room",
            "title": "must exist"
        },
        {
            "id": "title",
            "title": "can't be blank"
        },
        {
            "id": "notes",
            "title": "can't be blank"
        },
        {
            "id": "start_time",
            "title": "can't be blank"
        },
        {
            "id": "end_time",
            "title": "can't be blank"
        }
    ]
}
```

Ainda falando sobre as boas práticas vale mencionar que também existe um item que diz respeito ao retorno de campos do tipo data. Ele diz que diz que todo retorno desse tipo deve vir com o padrão 1994-11-05T08:15:30-05:00 seguindo a ISO 8601. Porém, esse projeto não utilizou desse item simplesmente porque achei mais intuitivo o usuário mandar a data no formado "dia/mês/ano hora:minutos".

A documentação completa da API está disponível [aqui](https://afternoon-hamlet-39898.herokuapp.com/v1/apipie/1.0.html).

Disponibilizo também a minha coleção do Postman que usei durante o desenvolvimento bastando [clicar aqui](https://www.getpostman.com/collections/cfe38ad585c051c87372). Com ela em mãos abra o Postman, dentro dele no canto superior esquerdo vá em "File > Import...", na janela que irá abrir escolha "Link", cole o link no campo "Enter a URL", clique em "Continue" e confirme clicando no botão "Import".

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
  - [Rails Guides - Como formartar Date/Time](https://guides.rubyonrails.org/i18n.html#adding-date-time-formats)
  - [Rubocop comandos básicos](https://docs.rubocop.org/rubocop/1.25/usage/basic_usage.html)
  - [Como definar um helper method no RSpec](https://relishapp.com/rspec/rspec-core/v/3-8/docs/helper-methods/define-helper-methods-in-a-module)
  - [Adicionar json-expectations no RSpec](https://relishapp.com/waterlink/rspec-json-expectations/docs/json-expectations/include-json-matcher-with-hash)
  - [Como o Git lida com as mudanças de permissões de arquivos](https://medium.com/@tahteche/how-git-treats-changes-in-file-permissions-f71874ca239d)
  - [Como dar ao usuário permissão de acesso à arquivos](https://fedingo.com/how-to-give-user-access-to-folder-in-linux/?utm_source=pocket_mylist)
  - [Usando símbolo :if Active Record](https://guides.rubyonrails.org/active_record_validations.html#using-a-symbol-with-if-and-unless)
  - [Helper de validação :comparison Rails 7](https://guides.rubyonrails.org/active_record_validations.html#comparison)
  - [Como usar as classes Date & Time](https://www.rubyguides.com/2015/12/ruby-time/)
  - [Validation helper que usei de referência para meu custom appointment validator](https://guides.rubyonrails.org/active_record_validations.html#validates-with)

## Melhorias

- Usar Swagger como documentação da API
- Usar match responde schema nos testes
- Possibilitar fazer um agendamento somente com data/horário inicial e automaticamente setar data/horário final
- Refatorar método de validação `already_took`
- Refatorar classe `AppointmentValidator`
- Refatorar o seed dos `Appointment`. Os seeds atualmente estão com datas e horário setados para uma data no futuro, porém pensando em uma aplicação real, isso seria uma problema porque um dia essa data ficaria obsoleta e o seed pararia de funcionar
- Talvez uma refatoração que falicitaria as validações de data sem precisar checar os atributos "start_time" e para o "end_time" de `Appointment` a todo momento
- Dar uma atenção aos pontos que poderiam ser cacheados na aplicação
- Ao meu ver, seria bacana que a data e horário enviados na requisição fosse forçada ao padrão "21/03/2022 17:59"
- Adicionar no agendamento, a menção a outros usuário para que os mesmo sejam notificados sobre sua convocação
- Usar uma Gem para validações de data xD. As validações de data poderiam ser feito de maneira simplificada por alguma Gem, porém achei melhor fazer minhas próprias validações com o intuito de demonstrar como eu penso

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
