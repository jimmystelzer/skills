## O que faz

`grill-me` pega uma **ideia vaga** e entrevista você até que você possa se comprometer com ela. Você não precisa de um plano elaborado para começar: produzir um é para o que a [session](https://www.aihero.dev/ai-coding-dictionary/session) serve. Pergunta em **rodadas**: cada rodada é a **fronteira** inteira (cada pergunta cujos pré-requisitos você já resolveu), então você nunca é perguntado algo que depende de uma resposta que ele ainda não ouviu.

É **[stateless](https://www.aihero.dev/ai-coding-dictionary/stateless)**. Não escreve arquivos e não deixa um workspace para trás. A única coisa que deixa é uma versão mais nítida da ideia, na sua própria cabeça.

## Quando usar

Você invoca isso digitando `/grill-me`; o [agent](https://www.aihero.dev/ai-coding-dictionary/agent) não busca por conta própria. Comece em uma **conversa fresca**, não por cima de um plano que você já fez um agent escrever.

Busque assim que tiver uma ideia vale a pena levar a sério (uma feature, uma direção de produto, uma decisão de negócio, um texto), e muito antes de ter descoberto o que envolve. Vagueza não é motivo para esperar; é o que a session consome. Se você já pode especificar a coisa com precisão, não precisa grillar.

Qual das três skills de grilling você quer depende do que está diante de você:

- **Qualquer coisa, em qualquer lugar**: `grill-me`. Não precisa de repo e não escreve arquivos, e o assunto não precisa ser código.
- **Um codebase para alinhar**: [grill-with-docs](https://aihero.dev/skills-grill-with-docs). A mesma entrevista, mas [stateful](https://www.aihero.dev/ai-coding-dictionary/stateful): lê seu código e guarda o que aprende em `CONTEXT.md` e ADRs.
- **Grande demais para uma session**: [wayfinder](https://aihero.dev/skills-wayfinder). Traça o esforço como um mapa e executa sessões de grilling dentro dele.

Mantenha o [plan mode](https://www.aihero.dev/ai-coding-dictionary/agent-mode) desligado. Plan mode faz o agent pressa para produzir um plano, que é o oposto de ficar em investigação.

## É uma conversa, não uma entrevista

A skill faz as perguntas, mas **você** controla o escopo. É a parte que as pessoas perdem, e separa uma session que transforma uma ideia em decisões de uma que produz nonsense confiante.

O modo de falha é **passividade**: responder "concordo, concordo, concordo" por quarenta perguntas e sair com um plano que o agent escreveu e você assentiu. Parece produtivo porque foi longo. Nada foi realmente decidido, e o resultado carrega uma certeza que não conquistou.

Ser ativo significa conduzir. Rebata uma pergunta com um nível abaixo da fidelidade que você precisa. Diga quando o escopo está derivando. Responda "não sei" e leve a sério. Esta skill foi construída para auxiliar um engenheiro, não para substituir um: o que sai acompanha a qualidade das suas respostas, não o número de perguntas feitas.

O erro oposto é real, mas mais raro: ficar na entrevista tanto tempo que você nunca chega ao código.

## Grillável e não-grillável

Algumas perguntas podem ser respondidas conversando. Outras não, e nenhuma quantidade de grilling vai te levar lá.

"Um formulário longo ou três páginas?" e "como deveria ser a sensação dessa interação?" são **não-grilláveis**: precisam de algo para reagir. Quando encontrar uma, pare de grillar. Construa a versão descartável com [prototype](https://aihero.dev/skills-prototype), olhe para ela, depois volte e responda em uma linha.

Conversar para resolver uma pergunta não-grillável é onde as sessions crescem. O agent continua reformulando, você continua adivinhando, e o escopo cresce para preencher a incerteza.

## Está funcionando se

- Você discorda de algo. Uma session sem reprovação sua é uma session que você não precisava.
- As perguntas chegam em poucas rodadas em vez de uma longa gota, e as rodadas posteriores claramente se baseiam no que você disse antes.
- Você termina em algum lugar que não esperava, porque uma pergunta revelou uma decisão que você estava tomando implicitamente.
- No final você poderia defender cada escolha para alguém que não estava lá.

## Perguntas frequentes

**Quantas perguntas devo esperar, e como sei quando termina?**
Conte rodadas, não perguntas. Quarenta e seis perguntas em quatro rodadas é uma session comum. Termina quando a fronteira está vazia: cada ramo visitado, nada restante silenciosamente pressuposto.

**Ele me fez duzentas perguntas. O que deu errado?**
Geralmente o escopo era grande demais. Peça ao agent para dividir o trabalho em pedaços menores primeiro, depois grille cada um. Sessions muito longas também derivam para a **[dumb zone](https://www.aihero.dev/ai-coding-dictionary/smart-zone)**, onde o [context window](https://www.aihero.dev/ai-coding-dictionary/context-window) está cheio o suficiente para que as perguntas piorem.

**Posso voltar para uma pergunta por vez?**
Sim. Adicione isso ao seu `CLAUDE.md` global:

```
When grilling, ask one question at a time.
```

**E se eu genuinamente não souber a resposta?**
Diga isso. "Não sei" é uma resposta real, e uma pergunta que você não pode responder geralmente é um sinal de prototipar em vez de adivinhar.

**Começo uma session nova antes de escrever a spec?**
Não. O valor da session é o [context](https://www.aihero.dev/ai-coding-dictionary/context) que você acabou de construir. Passe a mesma conversa direto para [to-spec](https://aihero.dev/skills-to-spec).

**O model importa?**
Mais do que para a maioria das skills. Grilling depende do senso próprio do [model](https://www.aihero.dev/ai-coding-dictionary/model) de como sistemas quebram, então dê o seu melhor. Implementação segue majoritariamente o context e tolera um model mais barato.

## Onde se encaixa

`grill-me` é uma **standalone que você pode executar em qualquer lugar, em qualquer coisa**. Ser stateless é o que o torna portável: sem repo, sem workspace, sem configuração, e sem a suposição de que a ideia é sequer sobre software. As pessoas apontam para decisões de negócio, para escrita, para o que fazer a seguir: qualquer coisa que não fique parada na cabeça.

Essa portabilidade é toda a diferença de [grill-with-docs](https://aihero.dev/skills-grill-with-docs), que executa a mesma entrevista mas lê um codebase para alinhar e grava o que aprende como `CONTEXT.md` e ADRs. Ambos se apoiam na primitiva [grilling](https://aihero.dev/skills-grilling); `grill-me` é a porta de entrada invocada pelo usuário que não carrega nada.

Se o que você grillou realmente se revelar software, você pode passar a mesma conversa para [to-spec](https://aihero.dev/skills-to-spec) e continuar no fluxo de construção (uma opção, não o objetivo da skill). Quando não tem certeza qual fluxo se encaixa, [how-works](https://aihero.dev/skills-how-works) o direciona.
