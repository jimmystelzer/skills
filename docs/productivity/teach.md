## O que faz

`teach` transforma o diretório onde você o executa em um workspace de ensino permanente e ensina você um tópico ao longo de muitas [sessions](https://www.aihero.dev/ai-coding-dictionary/session), em short lessons HTML autocontidas.

Ele não ensina com o que o [model](https://www.aihero.dev/ai-coding-dictionary/model) já sabe. [Parametric knowledge](https://www.aihero.dev/ai-coding-dictionary/parametric-knowledge) é tratado como não confiável: antes de ensinar, ele vai e encontra recursos de alta confiança, os grava em `RESOURCES.md`, e os cita dentro de cada lesson. O outro fato estrutural é que é [stateful](https://www.aihero.dev/ai-coding-dictionary/stateful): a missão, os recursos, as lessons e o registro do que você aprendeu vivem todos no diretório como arquivos, então a próxima session recupera desses arquivos em vez do que restou da última conversa.

## Quando usar

Você invoca isso digitando `/teach`; o [agent](https://www.aihero.dev/ai-coding-dictionary/agent) não busca por conta própria.

Busque quando o aprendizado é o projeto: uma linguagem, um framework, um codebase que você acabou de entrar, yoga, shaders, uma certificação. Não é a ferramenta para uma explicação passageira.

| O que você quer | O que buscar |
| --- | --- |
| Aprender um tópico ao longo de semanas, com sessions que acumulam | `teach` |
| Uma ideia explicada dentro da session em que você já está | Apenas pergunte, naquela session |
| A última mensagem do agent reformulada porque não ficou clara | [wait-what](https://aihero.dev/skills-wait-what) |
| Refinar o pensamento que você já tem, em vez de adquirir novo material | [grill-me](https://aihero.dev/skills-grill-me) |
| Um agent em segundo plano para ler [primary sources](https://www.aihero.dev/ai-coding-dictionary/primary-source) e deixar um documento citado | [research](https://aihero.dev/skills-research) |
| Aprender algo que surgiu no meio de um grilling, sem desviar o [grilling](https://www.aihero.dev/ai-coding-dictionary/grilling) | [handoff](https://aihero.dev/skills-handoff) para um workspace de ensino, depois `teach` lá |

## Pré-requisitos

`teach` constrói um diretório em vez de produzir um arquivo, e a skill assume uma missão por workspace, então execute em algum lugar que você esteja feliz em dedicar a um único tópico. Mantenha fora do projeto em que você está trabalhando: um repo separado é o lar recomendado, em vez de uma pasta `~/.learnings/` global ou o projeto de trabalho em si. Um repo dedicado também torna as lessons commitáveis, que é como equipes as compartilham.

O que se acumula nesse diretório:

| Caminho | O que contém |
| --- | --- |
| `MISSION.md` | Por que você está aprendendo isso. Todo o resto depende disso; se estiver faltando, a primeira coisa que `teach` faz é entrevistar você até que não esteja |
| `RESOURCES.md` | As fontes verificadas que ensina, divididas em Conhecimento e Sabedoria (comunidades) |
| `lessons/*.html` | As lessons numeradas: a unidade primária de ensino |
| `reference/*.html` | Cheatsheets comprimidas, algoritmos, glossários: os documentos que você realmente consulta |
| `learning-records/*.md` | Notas no estilo ADR sobre o que você demonstrou ter aprendido, usadas para decidir o que ensinar a seguir |
| `assets/*` | Componentes reutilizáveis, começando com uma stylesheet compartilhada, para que as lessons pareçam um único curso |
| `NOTES.md` | Suas preferências de ensino declaradas |

Duas notas honestas sobre essa lista. Um glossário se adapta à maioria dos tópicos, mas a skill lança um `GLOSSARY-FORMAT.md` que o `SKILL.md` não vincula mais, então você só terá um se pedir ([issue #559](https://github.com/mattpocock/skills/issues/559)). E o workspace nem sempre é criado onde você espera, então veja a primeira pergunta abaixo antes de construir um longo curso sobre ele.

## Força de armazenamento, não fluência

A palavra para pensar é **força de armazenamento**: retenção de longo prazo, em oposição a **fluência**, a recall no momento que se sente como domínio enquanto você está lendo e some uma semana depois. `teach` constrói a primeira através de dificuldade desejável: prática de recuperação, espaçamento, intercalação. Conhecimento vem primeiro, onde dificuldade é a inimiga porque consome a memória de trabalho que você precisa para entender; depois a skill é treinada através de um feedback loop apertado, onde dificuldade é a ferramenta.

Duas coisas conduzem o que você é ensinado. A **missão** (a razão concreta do mundo real por que você quer isso) ancora cada lesson; sem ela, as lessons derivam para o abstrato e nada decide o que vem a seguir. Da missão e dos learning records, `teach` escolhe a próxima lesson dentro da sua **zona de desenvolvimento proximal**: desafiadora o suficiente para exigir esforço, não tão à frente que para de ser aprendível.

Também é por isso que a skill resiste em vez de se submeter. Uma pergunta que precisa de **sabedoria** (julgamento do mundo real) recebe uma tentativa de resposta e depois um ponteiro para uma comunidade onde você pode testá-la. Um quiz é um gate, não uma formalidade: um usuário relatou dizer "muito obrigado" e ser informado que o treino ainda estava ativo.

## Lessons, referências e componentes

Uma **lesson** é um arquivo HTML autocontido, curto o suficiente para terminar em uma sessão, vinculado à missão, dando uma vitória tangível. Cita suas fontes, recomenda uma primary source para ler por conta própria, e vincula a lessons e documentos de referência irmãos.

A separação que vale conhecer: lessons raramente são revisitadas, documentos de referência são. Então a essência comprimida de uma lesson (a tabela de sintaxe, o algoritmo, a sequência de poses, o glossário) pertence ao `reference/`, não enterrada na lesson que a introduziu.

Lessons são construídas a partir de **componentes** em `assets/`: stylesheets, widgets de quiz, simuladores, auxiliares de diagrama. Reuso é o padrão. O agent lê `assets/` antes de escrever uma lesson e constrói a partir do que está lá, e qualquer coisa nova que uma segunda lesson possa usar é escrita como componente em vez de inline. A stylesheet compartilhada é o primeiro componente que cada workspace conquista; é o que impede que a saída seja uma pilha de coisas únicas.

## Perguntas frequentes

**Onde ele coloca os arquivos? Os meus terminaram em `~/.claude/skills`.**
Um bug real e aberto ([#377](https://github.com/mattpocock/skills/issues/377)). `SKILL.md` usa `./` para duas raízes diferentes ao mesmo tempo: `./MISSION-FORMAT.md` e seus irmãos realmente ficam ao lado do `SKILL.md` na skill instalada, enquanto `./lessons/`, `./reference/`, `./learning-records/` e `./assets/` pretendem estar no seu diretório. Um agent que resolve o primeiro tipo contra o diretório de instalação da skill continua a resolver o segundo tipo lá também, e escreve seu curso na pasta da skill. Verifique onde a primeira lesson ficou antes de construir sobre ela, e nomeie o diretório explicitamente quando começar em vez de confiar que "o diretório atual" será entendido.

**Fico em uma session, ou começo uma nova por lesson?**
Os três métodos funcionam: ficar na mesma session, re-invocar `/teach` em uma nova session, ou abrir uma nova session na mesma pasta. Cada lesson é sua própria invocação. A pasta é a continuidade, não a conversa. A prática comum é abrir uma session fresca no workspace e dizer `/teach next lesson for <tópico>`.

**Como sei que ele não está me ensinando algo que inventou?**
Você não sabe, apenas pela palavra da skill. Você lê as primary sources. `teach` não é confiável o suficiente para confiar sem verificação, e nenhuma skill construída em um LLM é. A maquinaria de fundamentação (`RESOURCES.md`, citações em cada lesson, uma primary source recomendada por lesson) existe para tornar a verificação barata, não para eliminar a necessidade. A falha não é hipotética: um usuário aprendendo um cubo Rubik 2x2 recebeu sequências de movimentos fabricadas que não o resolvem. A checklist diagnóstica para um caso como esse é model, harness, esforço, e o que a fonte era. O risco é maior em domínios procedurais com notação precisa, e menor onde a saída é imediatamente verificável, como código que você pode rodar.

**A resposta correta do quiz é sempre a primeira opção.**
Confirmado por várias pessoas, no Sonnet, no Opus e no GLM, e ainda não corrigido. `SKILL.md` agora requer que todas as respostas tenham o mesmo número de palavras, o que elimina outro sinal (a resposta correta costumava ser a única completamente fundamentada), mas não diz nada sobre posição. Um contributor testou uma correção a nível de instrução para posição e relatou que a resposta correta ainda caía no slot A 33 vezes de 33 em nove lessons ([#335](https://github.com/mattpocock/skills/issues/335)), o que aponta para um componente de quiz embaralhado em `assets/` como a correção real em vez de melhor redação. Até isso ser lançado, trate a posição da resposta como irrelevante. Seu diretório `assets/` é seu para mudar, então pedir um componente que embaralhe no momento da renderização é uma correção local legítima.

**Ele presumiu que eu já sabia coisas e usou termos que nunca definiu.**
A reclamação substantiva mais comum. Não há etapa de avaliação: `teach` infere seu nível da missão e dos learning records, e na session um não há learning records. Um usuário executando dentro de um pipeline wayfinder disse diretamente: "Ele nunca fez grilling para estabelecer meu ponto de partida, então fez muitas presunções sobre o que eu já sabia." Outro relatou lessons apoiando jargão indefinido, e uma lesson adaptada ao hardware que cobriu o que o hardware podia fazer enquanto nunca dizia o que não podia. Duas coisas ajudam: declare seu conhecimento prévio e suas lacunas na primeira mensagem, e corrija o nível em voz alta quando uma lesson erra, porque a correção se torna um learning record e conduz a próxima. Uma etapa explícita de avaliação de conhecimento é um pedido de funcionalidade permanente ([#725](https://github.com/mattpocock/skills/issues/725)), não comportamento lançado.

**Ele faz repetição espaçada e sabe quando parar de ensinar?**
Não para o primeiro, e não de forma confiável para o segundo. Espaçamento e intercalação são princípios pelos quais as lessons são projetadas, mas nada agenda uma revisão, e não há integração com Anki ou calendário; ambos são pedidos recorrentes. A lacuna relacionada é critérios de saída: como um usuário colocou, `teach` "é bom em fazer a próxima lesson, mas não tão bom em saber quando parar e mudar para revisão ou prática real." Se você quer revisão ou treino em vez de novo material, peça; a skill não vai propor a mudança por conta própria.

**Só é útil para código?**
Não, e o uso não-codificado é a maior parte do registro: coreano, registro formal de japonês, piano, guitarra, design de jogos de tabuleiro, OpenSCAD, enredos de filmes, certificações Azure e CCNA, exames universitários, e crianças de oito e dez anos obtendo livros impressos sobre salas de fuga e salamandras-de-fogo. Nada na skill é específico de programação: missão, recursos, zona de desenvolvimento proximal e treino funcionam da mesma forma em qualquer domínio. Dentro de código, o uso mais forte relatado não é aprender uma linguagem do zero, mas se orientar em um codebase unfamiliar ou na stack de uma nova equipe.

**Qual model devo usar?**
Não há resposta canônica, e as diferenças relatadas são grandes. Maior [reasoning effort](https://www.aihero.dev/ai-coding-dictionary/effort) foi relatado como produzindo lessons notavelmente melhores do que a configuração média. Um usuário executou a mesma skill pelo Copilot CLI com Codex e obteve um único card HTML de 30 linhas onde Claude Code produziu uma lesson completa. Roda sem modificação no Claude Cowork, sujeito a se sua organização permite skills serem adicionadas lá. Se as lessons saírem finas, mude model, [harness](https://www.aihero.dev/ai-coding-dictionary/harness) ou esforço antes de reescrever seu prompt.

## Está funcionando se

- A primeira coisa que faz em um diretório vazio é entrevistar você sobre por que você quer isso, em vez de produzir uma lesson.
- `RESOURCES.md` enche antes das lessons, e cada lesson nomeia uma primary source que vale a pena ler por conta própria.
- Afirmações em uma lesson trazem links para fora. Uma lesson sem citações é a skill ensinando de memória.
- Uma lesson leva uma sessão e deixa você capaz de fazer uma coisa que não conseguia antes.
- Abrir uma session fresca na pasta e dizer "next lesson" continua o curso em vez de reiniciá-lo.
- `learning-records/` cresce, e as lessons param de re-ensinar o que você já demonstrou.
- As lessons parecem um único curso: vinculam a stylesheet em `assets/` em vez de cada uma carregar a sua.
- Uma pergunta que precisa de julgamento te aponta para um fórum, subreddit ou turma, não apenas uma resposta.

## Onde se encaixa

`teach` é uma **standalone para buscar a qualquer momento**. Não é um passo em uma cadeia de construção e não compartilha artefatos com o fluxo de engenharia; possui seu diretório e vive lá enquanto o tópico durar.

Seu único vizinho real é [handoff](https://aihero.dev/skills-handoff), através da composição que Matt nomeou como a resposta para "o que eu faço se estou sendo grilhado sobre algo que não entendo?": não pare o grilling para aprender: `/handoff` para um workspace de ensino, aprenda lá com `/teach`, depois volte e continue de onde parou. A alternativa próxima é [research](https://aihero.dev/skills-research), para quando você quer um documento citado em vez de lessons e retenção. Quando não tem certeza qual skill ou fluxo se encaixa, [how-works](https://aihero.dev/skills-how-works) o direciona pelo conjunto inteiro.
