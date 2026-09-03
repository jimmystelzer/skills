## O que faz

`grilling` é o loop de entrevista que estressa um plano, uma decisão ou uma ideia antes que alguém age sobre ela. Mapeia o assunto como uma **árvore de design**: cada decisão se ramifica nas decisões que dependem dela, e entrevista você ramo por ramo até que nada fique silenciosamente pressuposto.

Não faz uma pergunta por vez, nem faz tudo de uma vez. Cada **rodada** faz a **fronteira** inteira: cada decisão cujos pré-requisitos já foram resolvidos, e nada mais. Duas perguntas nunca compartilham uma rodada se uma depende da outra; uma pergunta que depende de uma resposta ainda em aberto pertence a uma rodada posterior. Suas respostas resolvem decisões, a fronteira avança, e a próxima rodada pergunta o que isso destravou. Treze perguntas tipicamente caem em cerca de três rodadas em vez de treze.

## Quando usar

Digite `/grilling`, ou o [agent](https://www.aihero.dev/ai-coding-dictionary/agent) busca por conta própria quando uma tarefa se encaixa. É a única [skill](https://www.aihero.dev/ai-coding-dictionary/skill) na família grilling que é invocada pelo model, o que é raro de digitar: geralmente uma skill que *você* digitou está executando para você.

Digitando `/grilling` diretamente, você obtém a entrevista pura e nada mais. Para algo mais do que isso:

| O que você tem | Busque por |
| --- | --- |
| Você não está trabalhando em um working directory | [grill-me](https://aihero.dev/skills-grill-me): a mesma [session](https://www.aihero.dev/ai-coding-dictionary/session), sob um nome que o agent nunca aciona sozinho |
| Você está em um working directory | [grill-with-docs](https://aihero.dev/skills-grill-with-docs): a mesma session, e escreve `CONTEXT.md` e ADRs conforme avança |
| Um esforço grande demais para caber em uma session | [wayfinder](https://aihero.dev/skills-wayfinder): traça um mapa e executa grilling dentro dos tickets de decisão |
| Uma pergunta que a conversa não resolve: como algo deveria parecer ou ser sentido | [prototype](https://aihero.dev/skills-prototype): construa a versão descartável, depois volte |
| Uma skill sua que precisa de uma entrevista | invoque `/grilling` a partir dela, em vez de escrever outra entrevista |

## A rodada, a fronteira e quem decide

Três ideias carregam a skill inteira.

A **árvore de design** é o modelo do assunto: decisões com decisões que dependem delas. A **fronteira** é o conjunto de decisões cujos pré-requisitos estão todos resolvidos: as únicas perguntas que podem honestamente ser feitas ainda. Uma **rodada** é uma fronteira, feita por inteiro e respondida por inteiro.

Dentro de uma rodada, cada pergunta chega em uma forma fixa: numerada e titulada atrás de um `❓`, depois o corpo, depois a resposta recomendada do agent sozinha em uma linha `➡️`. É isso que torna uma rodada respondível por número ("1 sim, 2 a segunda opção, 3 não, eis por quê") em vez de citar perguntas de volta. O formato tem uma aspereza conhecida: a recomendação às vezes argumenta *contra* a pergunta como foi redigida, então concordar com a recomendação significa responder "não" à pergunta. Quando isso acontece, responda à recomendação e diga isso.

A outra metade do design é a separação entre fatos e decisões. Fatos são o trabalho da própria skill: quando uma pergunta na fronteira precisa de algo que o [environment](https://www.aihero.dev/ai-coding-dictionary/environment) pode resolver, ela despacha um [sub-agent](https://www.aihero.dev/ai-coding-dictionary/subagent) para ir descobrir em vez de perguntar a você. Isso não bloqueia; apenas as perguntas posteriores a uma exploração em andamento esperam. Decisões são suas, e ela deve esperar por elas. Um agent executando `grilling` que responde suas próprias decisões quebrou a skill, não a interpretou liberalmente. A session termina quando a fronteira está vazia, e ela não agirá sobre o que você concordou até que você confirme que alcançou um entendimento compartilhado.

O limite honesto: a fronteira é o julgamento do agent, não um grafo computado. Ele pode colocar duas perguntas em uma rodada e só depois descobrir que uma resposta deveria ter mudado a outra. Não há proteção contra isso além de dizer, o que reabre o ramo afetado na próxima rodada.

## O que fica aqui e o que fica nos wrappers

Esta página cobre o mecanismo. As coisas que as pessoas mais querem estão documentadas um nível acima.

| Pergunta | Onde é respondida |
| --- | --- |
| A árvore, a fronteira, rodadas, o formato das perguntas, fatos vs decisões | Aqui |
| Quanto tempo uma session deve rodar, o que fazer com uma pergunta que não pode ser resolvida conversando, como evitar assentir automaticamente | [grill-me](https://aihero.dev/skills-grill-me) |
| O que é escrito no `CONTEXT.md`, o que vira um ADR | [grill-with-docs](https://aihero.dev/skills-grill-with-docs) |

## Perguntas frequentes

**Posso voltar para uma pergunta por vez?**
Sim, e grande parte do público faz isso. Adicione isso ao seu `CLAUDE.md` global:

```
When grilling, ask one question at a time.
```

O padrão baseado em rodadas é genuinamente contestado. Profissionais que leem devagar, que trabalham em um segundo idioma, ou que usam o formato sequencial como andaime de foco todos relatam que o ritmo de uma por vez é melhor para eles, e a opção de saída é suportada em vez de tolerada.

**Onde foi o `/batch-grill-me`?**
Entrou nesta skill. A perguntada baseada em rodadas foi lançada brevemente como uma skill separada, depois se moveu para o próprio `grilling`, de modo que tudo construído sobre a primitiva (`grill-me`, `grill-with-docs`, `triage`, `wayfinder`) a recebeu de uma vez. Não há `batch-grill-me` para instalar, nem uma skill sequencial separada; a linha `CLAUDE.md` acima é o caminho de volta para uma por vez.

**Perguntar uma rodada inteira de uma vez deve perder as perguntas que minhas respostas anteriores teriam levantado. Não é?**
Essa é a objeção mais comum ao design de rodadas, e a fronteira é a resposta: uma rodada só contém perguntas que não dependem uma da outra, então nenhuma resposta em uma rodada pode invalidar outra pergunta naquela rodada. As respostas ainda remodelam tudo posteriormente: a próxima rodada é recalculada, não pré-escrita. O que você perde é menor do que "todas as perguntas de uma vez" implica, e maior do que nada: veja o limite da fronteira acima.

**Esgotou as perguntas e começou a construir.**
Existe um gate de confirmação precisamente para isso: a skill não termina quando a fronteira esvazia, termina quando você diz que o entendimento é compartilhado. [Models](https://www.aihero.dev/ai-coding-dictionary/model) mais fracos e rápidos ainda quebram isso; isso é relatado mais frequentemente em models de menor esforço ou não-fronteira, que colapsam "entrevistar até entendimento compartilhado" em umas poucas perguntas e um outline. Se o seu faz isso, a correção confiável é uma linha no seu próprio `AGENTS.md` ou `CLAUDE.md` dizendo ao agent para não implementar sem permissão.

**Ele respondeu suas próprias perguntas em vez de me perguntar.**
Isso é um bug na execução, não o comportamento pretendido, e foi por isso que fatos e decisões foram separados no texto da skill. Aparece mais quando outra skill executa `grilling` dentro de um frame resolve-this-ticket, onde a tarefa circundante se lê como licença para continuar. A mesma restrição é por que não há modo assíncrono: pessoas pediram uma variante que lê um GitHub issue e publica um memorando consolidado de decisão, e isso é uma skill diferente, porque uma sessão de grilling que ninguém respondeu produziu a opinião do agent em vez da sua.

**Posso limitar o número de perguntas?**
Não, e um limite é deliberadamente fora do escopo. Alguns planos precisam de três perguntas e outros de cinquenta; um teto fixo ou truncada o caso difícil ou parece arbitrário no fácil. Condução em linguagem simples é o controle pretendido: diga para ele concluir, ou pare e aceite o plan onde está. Se uma session está rodando muito tempo, a causa geralmente é que o escopo era grande demais; divida o trabalho e grille as partes.

**Instalei `grill-me` sozinho e nada acontece.**
`grill-me` é uma skill de uma linha cujo corpo inteiro é "executar uma session `/grilling`", então precisa desta skill instalada também. O mesmo é verdade para `grill-with-docs`, que adicionalmente precisa de [domain-modeling](https://aihero.dev/skills-domain-modeling). Instalar o conjunto inteiro evita o problema; instalar seletivamente significa instalar as primitivas também.

**`grill-with-docs` rodou, mas nunca carregou `grilling`.**
Uma aspereza real e não corrigida, relatada entre [harnesses](https://www.aihero.dev/ai-coding-dictionary/harness) e models: uma skill que nomeia outra skill não causa de forma confiável o carregamento daquela skill, e `grill-with-docs` nomeia duas. O sinal é uma session que pergunta tudo de uma vez sem recomendações anexadas: isso é o model improvisando uma entrevista em vez de executar esta. Perguntar ao agent diretamente se ele carregou `grilling` e `domain-modeling` geralmente recupera.

## Está funcionando se

- Uma rodada chega como uma lista numerada, cada pergunta com sua recomendação em uma linha separada `➡️`, e você pode responder a rodada inteira por número.
- Nada em uma rodada precisa que outra pergunta na mesma rodada seja respondida primeiro.
- Rodadas posteriores perguntam coisas que a primeira rodada não poderia ter perguntado.
- Ele vai e busca fatos (lendo arquivos, despachando um sub-agent) em vez de perguntar algo que poderia ter descoberto.
- Pesquisa rodando em segundo plano não trava a rodada; apenas as perguntas que dependem dela esperam.
- Ele para no final e pede que você confirme que o entendimento é compartilhado, em vez de começar o trabalho.
- A contagem de perguntas fica alta enquanto a contagem de rodadas fica baixa.

## Onde se encaixa

`grilling` é uma **primitiva**, não um passo que você agenda: a única fonte de verdade para a técnica de entrevista, mantida em um lugar para que toda skill que precise de uma entrevista busque em vez de inventar uma. [grill-me](https://aihero.dev/skills-grill-me) e [grill-with-docs](https://aihero.dev/skills-grill-with-docs) são suas duas portas de entrada invocadas pelo usuário, e `grill-with-docs` é onde a cadeia principal de construção começa, antes de [to-spec](https://aihero.dev/skills-to-spec). [wayfinder](https://aihero.dev/skills-wayfinder) o executa para resolver tickets de decisão, [triage](https://aihero.dev/skills-triage) para grill um relatório vago em um utilizável, e [improve-codebase-architecture](https://aihero.dev/skills-improve-codebase-architecture) para percorrer a árvore depois que você escolheu um candidato para aprofundar. Quando não tem certeza qual ponto de entrada se encaixa, [how-works](https://aihero.dev/skills-how-works) o direciona.
