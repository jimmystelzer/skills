## O que faz

`how-works` é o roteador sobre as skills neste repositório. Você descreve a situação em que está (uma ideia que não consegue começar, uma pilha de relatórios de bugs recebidos, uma [session](https://www.aihero.dev/ai-coding-dictionary/session) que rodou por muito tempo), e ele nomeia a skill ou a sequência de skills que se encaixa, mais onde as decisões humanas nessa sequência ficam.

Ele recomenda e para. Ele não grilla, escreve uma [spec](https://www.aihero.dev/ai-coding-dictionary/spec), abre um arquivo ou dispara a skill que acabou de nomear; o que você recebe de volta é a próxima coisa a digitar, e você digita. Ele também é um mapa escrito à mão das skills neste repositório em vez de uma varredura do que você tem instalado, então ele não te roteará sobre suas próprias skills ou as de outro autor.

## Quando usá-la

Você invoca esta digitando `/how-works`; o agente não a usa por conta própria.

| Sua situação | O que o roteador retorna |
| --- | --- |
| Uma ideia, e nenhuma ideia por onde começar | A cabeça do fluxo principal, e se a construção é pequena o suficiente para pular a spec |
| Bugs e pedidos recebidos de outras pessoas | A rampa de acesso do [triage](https://aihero.dev/skills-triage), e por que [tickets](https://www.aihero.dev/ai-coding-dictionary/ticket) que você gerou não pertencem a ela |
| Duas skills que parecem intercambiáveis | A linha entre elas, e geralmente é um teste concreto em vez de uma questão de gosto. [grill-me](https://aihero.dev/skills-grill-me) ou [grill-with-docs](https://aihero.dev/skills-grill-with-docs) depende de você estar em um diretório de trabalho; [grill-with-docs](https://aihero.dev/skills-grill-with-docs) ou [wayfinder](https://www.aihero.dev/skills-wayfinder) depende de o esforço caber em uma session |
| Uma session longa e uma decisão sobre o [context](https://www.aihero.dev/ai-coding-dictionary/context) | A árvore ordenada sobre as cinco opções em um boundary de fase |
| Uma skill que você já escolheu | Nada útil. Invoque aquela skill diretamente. |

## Pré-requisitos

O roteador nomeia skills; ele não instala. Tudo que ele aponta precisa estar instalado para que a recomendação seja acionável, e ele só conhece as skills promovidas neste repositório.

As rotas dependentes de tracker (triage, `to-spec`, `to-tickets`, `implement`) presumem que [setup-skills](https://aihero.dev/skills-setup-skills) já configurou um issue tracker no repositório. O roteador vai felizmente recomendar antes disso ter acontecido.

## Fluxos, não skills

A palavra que a skill lhe dá para pensar é **fluxo**: um caminho *através* das skills, não uma só. Nomear sua situação te coloca em um fluxo em um passo, que é uma resposta diferente de "aqui está a skill que combina com suas palavras-chave". Existem quatro tipos de rota, e a skill os carrega completos:

- **O fluxo principal**, da ideia ao envio. Grill, spec, tickets, implement, review, com duas ramificações dentro dele: um desvio para protótipo quando uma pergunta precisa de código executável para se resolver, e a divisão spec-e-tickets, que só se paga quando a construção abrange mais de uma session.
- **Rampas de acesso**, para uma situação que gera trabalho e depois se funde ao fluxo principal: relatórios de bugs recebidos, algo quebrado, ou um esforço turvo e grande demais para caber em uma session.
- **Standalones**, fora de todo fluxo, usados por seus próprios méritos: o protótipo, o questionário, o conflito de merge em que você já está sentado.
- **Uma camada de vocabulário por baixo**, as duas referências que as outras skills puxam quando as palavras em vez do processo são o problema.

## O boundary de fase

A outra ideia que ele lhe entrega é o **boundary de fase**. Uma fase é um bloco de trabalho dentro de uma session (o [grilling](https://www.aihero.dev/ai-coding-dictionary/grilling), a implementação, o QA), e o boundary entre duas delas é o único lugar onde a pergunta "o que eu faço com este contexto?" pertence. No meio de uma fase não há nada a decidir: continuar, ou dividir o que resta em [subagents](https://www.aihero.dev/ai-coding-dictionary/subagent).

| Opção | Use quando |
| --- | --- |
| **Continuar** | A próxima fase quer esta exatamente como está, ou você tem [smart zone](https://www.aihero.dev/ai-coding-dictionary/smart-zone) restante. É o único movimento que mantém a session como uma [primary source](https://www.aihero.dev/ai-coding-dictionary/primary-source), então descarte-o primeiro |
| **`/clear`** | Tudo atrás de você é descartável. O movimento mais barato no tabuleiro, e sem volta se você errou |
| **[handoff](https://www.aihero.dev/skills-handoff)** | Algo precisa viajar: um novo [harness](https://www.aihero.dev/ai-coding-dictionary/harness), um novo diretório, um colega, uma tarefa secundária bifurcada no meio da fase |
| **Subagent** | A tarefa é delimitada o suficiente para rodar com você [ausente do teclado](https://www.aihero.dev/ai-coding-dictionary/afk) |
| **`/compact`** | Nenhuma das anteriores. O padrão, e cai aqui com frequência |

Duas delas são rotineiramente feitas erradas, é por isso que o roteador traz a ordem em vez da lista. `/handoff` parece a ponte geral entre janelas e não é: portabilidade é tudo que ela compra. `/compact` é o fundo da árvore em vez do primeiro recurso, porque as quatro perguntas acima dela são cada uma mais barata ou mais precisa.

## Perguntas comuns

**Não há apenas uma lista das skills na ordem certa?**

Pessoas continuam pedindo uma no README. Esta skill é essa lista: é para isso que ela existe. Uma tabela estática diria `wayfinder → to-spec → to-tickets → implement → code-review` e estaria errada para a maioria das situações, porque as partes interessantes são as ramificações: há um codebase, a construção abrange sessões, essa pergunta pode ser resolvida conversando. O custo honesto é que o roteador é mantido à mão e fica atrás do repositório. `/grilling` e `/resolving-merge-conflicts` foram entregues muito antes do roteador as nomear.

**Ela me disse que metade das skills não está instalada.**

Um bug conhecido, não corrigido. A maioria das skills que o roteador te roteia definem `disable-model-invocation: true`, o que significa que o harness as deixa fora da lista de skills que injeta no contexto do agente. O agente lê essa lista como exaustiva e as reporta como ausentes. Uma session reportada teve ele declarar todo o fluxo spec-e-tickets ausente e rerotear para `/grilling` e `/tdd` puros. Treze das skills carregam essa flag, então este é o caso comum em vez de uma exceção. Elas estão instaladas. Digite o slash command mesmo assim.

**Ela descreveu o comportamento de uma skill, e a skill não faz isso.**

Também real, também não corrigido. O roteador responde de seu próprio resumo de uma linha de cada skill em vez da skill. Um relatório detalhado rastreou três instâncias em uma única session, incluindo uma recomendação para pular [to-spec](https://aihero.dev/skills-to-spec) com base na glossa "transformar o thread em uma spec": `to-spec/SKILL.md` nunca foi aberta. Em todos os casos ele verificou apenas depois que o usuário contestou, e nunca por iniciativa própria. Pular `to-spec` ali custou uma verificação real de seam, e os tickets que saíram subcontaram o trabalho. Quando o roteador afirma algo load-bearing sobre outra skill, peça para ele abrir aquele `SKILL.md` primeiro. O mesmo se aplica a perguntas que o mapa não cobre de jeito nenhum, como se usar [plan mode](https://www.aihero.dev/ai-coding-dictionary/agent-mode): essa resposta é a inferência do [model](https://www.aihero.dev/ai-coding-dictionary/model), não algo escrito aqui.

**Por que é texto corrido em vez de uma checklist numerada?**

Uma reclamação justa, registrada como uma issue aberta argumentando que a maioria do roteamento é determinístico e a narrativa torna difícil de escanear. Nada impede você de pedir a forma comprimida: "apenas me dê a sequência" lhe dá a sequência. O que o texto carrega é a metade condicional: as ramificações, onde uma decisão humana é esperada, e onde limpar ou compactar entre passos. Uma checklist plana descarta exatamente isso.

**Ela pode rotear sobre minhas próprias skills, ou as de outro autor?**

Não. Três propostas separadas pediram um roteador que lê seu diretório local `skills/` e recomenda de qualquer coisa instalada. `how-works` não é isso. É um mapa de um conjunto, mantido à mão, e não sabe nada sobre skills que você escreveu ou instalou de outro lugar.

**Ela me disse para editar um SKILL.md.**

Esse conselho é frequentemente correto e raramente durável. Alguém perguntou como fazer [implement](https://aihero.dev/skills-implement) fechar tickets, foi dito para adicionar uma linha à skill, e imediatamente viu o problema: `npx skills update` sobrescreve o arquivo. Coloque comportamento persistente no seu próprio `CLAUDE.md` ou `AGENTS.md`, ou diga na invocação. Adaptações a nível de prompt sobrevivem atualizações: perguntar quais tickets abertos poderiam rodar em paralelo, ou apontar o fluxo para um tracker diferente, são coisas que pessoas fazem dessa forma.

**Ela nomeou uma skill que eu não tenho, ou omitiu uma que tenho.**

Verifique o changelog por uma renomeação antes de presumir que ela foi embora. `writing-great-skills` se tornou [writing-for-agents](https://www.aihero.dev/skills-writing-for-agents) sem alias, `to-prd` se tornou [to-spec](https://www.aihero.dev/skills-to-spec), e `pathfinder` se tornou [wayfinder](https://www.aihero.dev/skills-wayfinder). Quatro skills foram aposentadas diretamente nas skills que as absorveram: `ubiquitous-language`, `design-an-interface`, `qa` e `request-refactor-plan`. O caso inverso é o próprio atraso do roteador, acima.

## Está funcionando se

- Ela termina nomeando o que digitar e para ali, em vez de começar o trabalho em si.
- A rota que retorna menciona onde limpar ou compactar o contexto e onde você é esperado para revisar, não apenas uma lista de nomes de skills.
- Onde duas skills são próximas, diz qual e por que a outra é errada para você.
- Qualquer afirmação que faz sobre o comportamento de outra skill aparece no trace como ela lendo aquele `SKILL.md`.
- Você reconhece sua própria situação no que entrega, em vez do cenário genérico mais próximo.

## Onde se encaixa

`how-works` é um **roteador standalone** que fica sobre o conjunto todo. Ele nunca é um passo em uma cadeia; ele aponta para dentro de cada cadeia, e é o nó ao qual as outras páginas de documentação vinculam de volta para que nenhuma delas tenha que redesenhar o grafo. Daqui você mais frequentemente chega a [grill-with-docs](https://aihero.dev/skills-grill-with-docs), a cabeça do fluxo principal, ou [triage](https://aihero.dev/skills-triage), a rampa de acesso para trabalho que chegou em vez de trabalho que você começou.

Ele é uma [secondary source](https://www.aihero.dev/ai-coding-dictionary/secondary-source) sobre as skills que descreve. Onde o roteador e uma `SKILL.md` discordam, a `SKILL.md` está certa.
