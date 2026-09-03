## O que faz

`writing-for-agents` é a referência contra a qual você escreve documentos voltados para agents: uma skill, um `AGENTS.md` / `CLAUDE.md`, uma [spec](https://www.aihero.dev/ai-coding-dictionary/spec), um prompt de runtime, um README, qualquer documento que um [agent](https://www.aihero.dev/ai-coding-dictionary/agent) lê. A embalagem difere; a escrita não: as mesmas alavancas tornam cada um previsível, para que o agent tome o mesmo *processo* a cada execução em vez de produzir a mesma saída.

Seu movimento padrão é exclusão, não explicação. Peça a um agent para escrever instruções para outro agent e ele gasta a maior parte de suas palavras explicando o que o [model](https://www.aihero.dev/ai-coding-dictionary/model) já sabe. Cada uma dessas linhas é um **no-op**, pagando [context](https://www.aihero.dev/ai-coding-dictionary/context) e não mudando comportamento. Esta referência é a lente que os encontra, por isso se paga pelo menos tão frequentemente em um documento que você já tem quanto em um arquivo em branco.

Ela se chamava `writing-great-skills` até a v1.1. A renomeação rastreia o que sempre foi por baixo: quase nada é específico de skill. A mecânica exclusiva de skills (frontmatter, a escolha entre invocação por model ou por usuário, router skills) é divulgada em um `SKILL-MECHANICS.md` vinculado que você lê apenas quando o documento diante de você é uma skill.

## Quando usar

Digite `/writing-for-agents`, ou o agent busca por conta própria quando você está criando ou editando uma skill, ou modificando `AGENTS.md` ou `CLAUDE.md`.

Busque manualmente para todo o resto que um agent lê: seus documentos, specs e [tickets](https://www.aihero.dev/ai-coding-dictionary/ticket), prompts de sistema e [AFK](https://www.aihero.dev/ai-coding-dictionary/afk). O teste é uma pergunta: um agent lê isso? E não importa como o documento chega diante dele, se um ponteiro o nomeia, um humano o cola, ou ele simplesmente fica no repo. Para descobrir o que um codebase realmente contém inicialmente, use [grill-with-docs](https://aihero.dev/skills-grill-with-docs); esta referência governa como um documento se lê, não o que sabe.

## As duas cargas

A ideia na qual toda a referência gira é um par de orçamentos que cada documento e ponteiro gasta:

- **Context load**: o custo do material sempre carregado na janela do agent: uma linha de `AGENTS.md`, uma descrição de skill, qualquer coisa que fica no context a cada [turn](https://www.aihero.dev/ai-coding-dictionary/turn) quer dispare ou não.
- **Cognitive load**: o custo para você, especificamente quais documentos existem e quando buscar cada um. Você é o índice. Não um custo a minimizar: é o preço da agência humana.

Uma vez que você pensa nessas duas cargas, a maioria das decisões de escrita (dividir ou não, inline ou divulgar, apontar ou empurrar) se torna a mesma troca feita em lugares diferentes.

## As alavancas

- **[Context pointers](https://www.aihero.dev/ai-coding-dictionary/context-pointer)**: a referência mantida no context que nomeia material fora do context e codifica quando alcançá-lo. Uma descrição de skill e uma linha de `AGENTS.md` que nomeia um documento são o mesmo objeto; a *redação* do ponteiro, não seu alvo, decide quão confiavelmente o agent alcança através dele.
- **Hierarquia de informação**: a escada de passo dentro do arquivo, para referência dentro do arquivo, para referência divulgada atrás de um ponteiro. **[Progressive disclosure](https://www.aihero.dev/ai-coding-dictionary/progressive-disclosure)** é o movimento descendo essa escada para que o topo permaneça legível.
- **Critérios de conclusão**: a clareza e demanda da condição de conclusão de cada passo, e o **trabalho preparatório** que essa demanda impulsiona; a defesa contra **conclusão prematura**.
- **Leading words**: um conceito compacto já no pré-treinamento do model (*tight*, *red*, *tracer bullet*) com o qual o agent pensa ao executar o documento. Ela ancora em dois pontos: execução no corpo, invocação no ponteiro.
- **Poda**: fonte de verdade única, relevância, e o teste no-op aplicado frase por frase, contra **duplicação**, **sedimentação** e **expansão descontrolada**.

## Perguntas frequentes

**Onde foi `/writing-great-skills`?**
É esta skill, renomeada na v1.1. Profissionais já a apontavam para `AGENTS.md`, docs, specs, tickets e prompts de runtime muito antes do nome acompanhar; estrutura, leading words e poda se revelam o ofício de qualquer texto que um agent lê. Não há alias. Reinstale com o novo nome.

**"Writing for agents": então o agent faz a escrita?**
O inverso. Você é o autor; o agent é o leitor. Essa é toda a dificuldade do gênero: você está escrevendo para um leitor que já leu tudo, então explicação é desperdício e precisão é todo o trabalho.

**Não posso simplesmente pedir ao agent para escrever para mim?**
Pode, e ele produzirá algo verboso. Deixado sozinho, o model explica o que já sabe, e não vai aplicar o teste no-op ou buscar uma leading word por conta própria. Use a referência no rascunho: uma passagem de revisão é onde a maior parte de seu valor chega.

**Pedi a um agent para encurtar um documento e ele cortou a funcionalidade.**
Agents instruídos a "simplificar" otimizam por comprimento, porque comprimento é o que conseguem ver. O teste no-op é comportamental, não estético: delete a linha e pergunte se o comportamento do agent mudou. Quando uma frase falha, delete a frase inteira em vez de aparar palavras dela, e resolva uma divergência executando o documento, não argumentando.

**Como sei quando está pronto?**
Quando funciona, e você não consegue mais encontrar duplicação, sedimentação ou no-ops. Não há avaliação automatizada aqui; a verificação é uma execução manual mais o vocabulário de modos de falha como diagnóstico. Quando um documento se comporta mal, esse vocabulário também é o kit de reparo: nomeie o modo de falha primeiro, depois corrija isso.

**Devo colocar isso no `CLAUDE.md` ou em outro lugar?**
Pergunte qual carga você quer pagar. `CLAUDE.md` carrega em toda [session](https://www.aihero.dev/ai-coding-dictionary/session) incondicionalmente; material atrás de um ponteiro custa apenas a linha do ponteiro até que dispare. Qualquer coisa que se aplica em um contexto de dez está pagando context load nas outras nove vezes.

**Preciso reescrever meus documentos para cada model novo?**
Na maior parte não, e super-adaptar a um model é uma armadilha própria. Atualizar para um model novo geralmente é outra passagem no-op em vez de uma reescrita.

**Minha skill só funciona na tarefa exata que criei.**
A rota comum (fazer o trabalho uma vez, depois pedir ao agent para escrevê-lo como skill) super-indexa naquela execução, e os exemplares saem específicos demais. Mantenha a execução como evidência, depois abstraia deliberadamente: remova o que pertencia àquele repo e àqueles arquivos, e escreva para a classe de tarefa.

**Inglês não é minha primeira língua. Perco a vantagem das leading words?**
Não. Encontrar a palavra que empacota mais comportamento em menos [tokens](https://www.aihero.dev/ai-coding-dictionary/token) é trabalho que a referência faz por você. É uma das coisas para as quais ela existe.

## Está funcionando se

- O documento encurta à medida que melhora, e você fica surpreso com o pouco que sobra.
- Você pode apontar uma leading word e vê-la trabalhando em mais de um lugar.
- Nada é declarado duas vezes, em qualquer forma. Duplicação é o sinal mais confiável de que um documento nunca foi testado.
- Referência que só um ramo precisa fica atrás de um ponteiro em vez do arquivo principal.

## Onde se encaixa

Esta é uma referência standalone para buscar a qualquer momento. Não tem vizinho na cadeia porque fica abaixo do conjunto inteiro em vez de ao lado de qualquer skill: toda skill aqui foi escrita contra ela, e os documentos que as outras skills deixam (um `CONTEXT.md` e seus ADRs, uma spec, um ticket) são exatamente o texto que ela governa uma vez que um agent precisa lê-los. Quando não tem certeza qual skill ou fluxo se encaixa em uma tarefa, [how-works](https://aihero.dev/skills-how-works) o direciona pelo conjunto inteiro.
