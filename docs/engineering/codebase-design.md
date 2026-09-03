## O que faz

`codebase-design` corrige as palavras que você usa para desenhar um módulo: **module**, **interface**, **depth**, **seam**, **adapter**, **leverage**, **locality**. Define cada uma com precisão, proíbe os substitutos soltos ("component", "service", "API", "boundary") e estabelece os poucos princípios que decorrem deles.

É uma referência, não um processo. Não há um loop para rodar, nenhum artefato que produz, nenhum checkpoint onde faz uma pergunta. Cada outra skill que toca em design empresta seu vocabulário; por si só, dá a linguagem e para. Isso é o que vale saber antes de invocá-la, porque uma skill sem processo e sem regra de parada vai improvisar uma se você apontar uma [session](https://www.aihero.dev/ai-coding-dictionary/session) nela e disser "vá." Veja as perguntas abaixo para ver como isso é na prática.

## Quando usá-la

Digite `/codebase-design`, ou o agente a usa automaticamente quando uma tarefa de design se encaixa.

Use-a quando você já sabe qual código está redesenhando e precisa pensar em sua forma: onde vai a seam, o quão pequena a interface pode ficar, se uma extração vale o esforço. É também o que se usa para resolver uma discussão sobre o significado de uma palavra.

Várias skills ficam próximas dela. Qual delas você quer depende do que é o problema real:

| O problema | A skill |
|---|---|
| A forma de um módulo: sua interface, sua seam, sua profundidade | `codebase-design` |
| As *palavras do domínio*: "account" significa três coisas, duas pessoas entendem coisas diferentes por "cancellation" | [domain-modeling](https://aihero.dev/skills-domain-modeling) |
| Você ainda não sabe *qual* módulo redesenhar | [improve-codebase-architecture](https://aihero.dev/skills-improve-codebase-architecture) (o levantamento que encontra candidatos) |
| Você quer que o design seja questionado, não apenas nomeado | [grilling](https://aihero.dev/skills-grilling) |
| Há um comportamento concreto a construir e você quer testes que sobrevivam a um refactor | [tdd](https://aihero.dev/skills-tdd) |

## O vocabulário

O glossário é a skill. Cada termo é definido em relação aos demais, e cada um vem com a palavra que ele substitui.

| Termo | O que significa | Não diga |
|---|---|---|
| **Module** | Qualquer coisa com uma interface e uma implementação. Deliberadamente agnóstico de escala: uma função, uma classe, um pacote, um slice que atravessa camadas. | unit, component, service |
| **Interface** | Tudo que um chamador precisa saber para usá-la corretamente: a assinatura de tipo, mais invariantes, restrições de ordenação, modos de erro, configuração necessária, características de desempenho. | API, signature |
| **Depth** | Leverage na interface: quanto comportamento um chamador ou um teste pode exercer por unidade de interface que ele precisa aprender. **Deep**: muito comportamento atrás de uma interface pequena. **Shallow**: a interface é quase tão complexa quanto a implementação. | none |
| **Seam** | Termo de Michael Feathers: um lugar onde você pode alterar comportamento sem editar naquele local. É a *localização* de uma interface, e onde colocá-la é uma decisão por si só, separada do que vai por trás. | boundary |
| **Adapter** | Uma coisa concreta que satisfaz uma interface em uma seam. Nomeia um papel, não uma substância: um fake em memória e um repositório Postgres são ambos adapters. | none |
| **Leverage** | O que os chamadores ganham com depth: mais capacidade por unidade de interface aprendida. | none |
| **Locality** | O que os mantenedores ganham com depth: mudança, bugs e verificação se concentram em um lugar. Conserta uma vez, corrigido em todo lugar. | none |

Depth é deliberadamente *não* definida como a proporção de linhas de implementação sobre linhas de interface, que é a própria definição de Ousterhout. Essa métrica favorece inflar a implementação. Depth-as-leverage é usada em vez disso.

## Os quatro princípios

- **Depth é uma propriedade da interface, não da implementação.** Um módulo deep pode ser construído internamente a partir de pequenas partes intercambiáveis. Elas simplesmente não aparecem para os chamadores. Um módulo pode ter seams internas que seus próprios testes usam, e uma seam externa em sua interface.
- **O teste de exclusão.** Imagine excluir o módulo. Se a complexidade desaparece, ele era um pass-through. Se ela reaparece em N chamadores, ele estava valendo o esforço.
- **A interface é a superfície de teste.** Chamadores e testes cruzam a mesma seam. Se você quer testar *além* da interface, o módulo tem a forma errada.
- **Um adapter significa uma seam hipotética. Dois adapters significam uma seam real.** Não corte uma seam até algo realmente variar nela. Uma seam com um único adapter é apenas indireção.

Dois arquivos de suporte vão além, e a skill os lê sob demanda em vez de antecipadamente. [DEEPENING.md](https://github.com/mattpocock/skills/blob/main/skills/engineering/codebase-design/DEEPENING.md) classifica as dependências de um candidato em quatro categorias (in-process, local-substitutable, remote-but-owned, true-external), porque a categoria decide como o módulo aprofundado é testado ao longo de sua seam. [DESIGN-IT-TWICE.md](https://github.com/mattpocock/skills/blob/main/skills/engineering/codebase-design/DESIGN-IT-TWICE.md) lança [sub-agentes](https://www.aihero.dev/ai-coding-dictionary/subagent) paralelos para produzir três ou mais interfaces radicalmente diferentes para o mesmo módulo, depois os compara em depth, locality e colocação da seam.

## Perguntas comuns

**Como eu realmente construo um módulo deep em TypeScript?**

Essa é a pergunta mais feita sobre a skill e a skill não a responde. Ela define o que um módulo deep *é*; não diz nada sobre como impedir que um import solto ultrapasse a interface. A [Issue #458](https://github.com/mattpocock/skills/issues/458) colocou isso claramente: "digamos que estamos satisfeitos com a interface, ela esconde os detalhes, etc. Mas como a fazemos cumprir? Acho que sem linting ou guardrails claros, humanos e LLMs vão começar a bagunçá-la ao longo do tempo." A resposta de Matt, naquele thread, foram três opções: encapsulá-la em uma classe ou IIFE e aceitar que a classe fique enorme; fazer dela um pacote em um monorepo e aceitar a infraestrutura de monorepo; ou usar um linter como [dependency-cruiser](https://github.com/sverweij/dependency-cruiser) para proibir imports que ignoram a interface. Ele chamou separadamente Effect de melhor mecanismo e dependency-cruiser de segundo melhor.

**Eu apontei uma session nela e ela gastou 100 mil [tokens](https://www.aihero.dev/ai-coding-dictionary/token) redesenhando coisas que eu nunca pedi.**

Conhecido, e registrado como [issue #449](https://github.com/mattpocock/skills/issues/449). A skill é model-invoked e se descreve como vocabulário, mas nada nela impede um agente de tratá-la como um processo executável. Dito para "resumir em /codebase-design e conduzir as decisões abertas", um agente usou o conteúdo que mais parecia uma ação que encontrou: os sub-agentes paralelos em `DESIGN-IT-TWICE.md`. Ele reexplorou código que uma session anterior já mapeou e seguiu longe antes de perguntar qualquer coisa. Nenhum dos guardrails que uma skill de direção tem (checkpoints, uma pergunta por vez, sem avanço automático) está presente aqui, porque uma referência não tem nenhum. A alternativa é nomear uma skill de direção e deixar esta por baixo: `/grill-with-docs`, `/improve-codebase-architecture` ou `/tdd` com `codebase-design` como vocabulário. A issue está aberta.

**O que aconteceu com `design-an-interface`? E há uma skill `/interface-design`?**

`design-an-interface` foi removida e absorvida nesta skill. Nada se perdeu: sua técnica "design it twice" (sub-agentes paralelos gerando designs radicalmente diferentes, de Ousterhout) é entregue aqui como `DESIGN-IT-TWICE.md`. Separadamente, várias pessoas pediram uma skill dedicada `/interface-design` para a filosofia de módulo-deep/interface-fina; essa filosofia já vive aqui, e nenhuma skill separada está planejada. Se você veio procurando qualquer um desses nomes, esta é a página.

**Não é isso uma convenção de estrutura de arquivos, como pastas, barrel files, feature slices?**

Não, e a skill manteve essa posição sob críticas repetidas. A [Issue #95](https://github.com/mattpocock/skills/issues/95) propôs uma estrutura de arquivos fractal-tree formalizada como implementação concreta de módulos deep; a resposta foi que os dois são ortogonais: "módulos deep são sobre o design da interface e acessar através de uma interface estrita, não importa como o sistema de arquivos parece. Parece perfeitamente possível ter módulos shallow com essa abordagem." O mesmo surgiu na #458: "acho que você pode estar vinculando o conceito de módulos muito de perto ao sistema de arquivos. O sistema de arquivos pode certamente ser uma dica útil para a forma dos módulos, mas não há necessidade de usar o sistema de arquivos na construção de módulos deep." O glossário define **module** como agnóstico de escala de propósito.

**A `tdd` realmente usa esse vocabulário?**

Agora sim. Por um longo tempo não usava. As notas inline sobre módulos deep que viviam dentro de `tdd` foram removidas na v1.0 em favor desta skill compartilhada, mas o ponteiro que as substituiu nunca foi adicionado, então `tdd` definiu "seam" por si mesma e não referenciou nada. A lacuna foi fechada: o ponteiro agora está na skill, acessado quando a forma da interface é a questão aberta em vez dos testes. `tdd` ainda é dona de "seam" como a boundary onde você *testa*; esta skill é dona da forma do módulo por trás.

**O padrão design-it-twice funciona fora do Claude Code?**

Não de forma limpa. `DESIGN-IT-TWICE.md` diz "gere 3+ sub-agentes em paralelo usando a Agent tool", que é a [tool](https://www.aihero.dev/ai-coding-dictionary/tool) do Claude Code com o nome do Claude Code. O repositório entrega metadados para outros [harnesses](https://www.aihero.dev/ai-coding-dictionary/harness), incluindo Codex, e esses podem não expor nada com esse nome, então a fase de design paralelo é menos portável do que os metadados da skill sugerem. Rastreado na [issue #564](https://github.com/mattpocock/skills/issues/564), aberta.

**Posso adicionar meus próprios conceitos ao glossário, como connascence, segredos de módulo, [progressive disclosure](https://www.aihero.dev/ai-coding-dictionary/progressive-disclosure)?**

Pessoas propuseram exatamente esses. A [Issue #180](https://github.com/mattpocock/skills/issues/180) adiciona os segredos de módulo de Parnas e a connascence de Page-Jones como uma camada de nomenclatura para *o que* está vazando em uma seam, com um diff funcional anexado; a [issue #303](https://github.com/mattpocock/skills/issues/303) propõe progressive disclosure dentro da implementação, para que um módulo que é deep em sua interface pública não seja uma massa indiferenciada por baixo. Ambas estão abertas e não mescladas. O glossário como entregue é deliberadamente pequeno, e a razão de permanecer pequeno está declarada na própria skill: linguagem consistente é o objetivo, e um termo que ninguém usa consistentemente é pior do que nenhum termo.

## Está funcionando se

- A conversa de design para de produzir as palavras "component", "service" e "boundary", e começa a produzir "module", "interface" e "seam".
- Alguém pode apontar para uma extração proposta e dizer se ela passa no teste de exclusão, sem hesitação.
- Uma seam proposta vem com um segundo adapter nomeado, não apenas o primeiro.
- A discussão de uma interface cobre invariantes, ordenação e modos de erro, não apenas a assinatura de tipo.
- Invocá-la não inicia uma session. Se o agente começa a ler arquivos e propor refactors baseado apenas em `/codebase-design`, ele confundiu a referência com uma driver.

## Onde se encaixa

`codebase-design` é um **standalone para usar a qualquer momento**, e a camada de vocabulário por baixo das skills de engenharia em vez de um passo em qualquer cadeia. Seu vizinho mais próximo é [domain-modeling](https://aihero.dev/skills-domain-modeling), a referência paralela para as palavras do *problema do domínio* em vez da forma do módulo. As duas geralmente são desejadas juntas, porque nomear bem um módulo deep precisa de ambas. [improve-codebase-architecture](https://aihero.dev/skills-improve-codebase-architecture) é a outra: ela levanta um codebase em busca de candidatos para aprofundar e escreve cada um deles neste glossário, então ela encontra o módulo e esta skill é a bancada onde você o desenha. Quando não tem certeza de qual skill ou fluxo se encaixa, [how-works](https://aihero.dev/skills-how-works) te direciona.
