## O que faz

`code-review` revisa o diff entre `HEAD` e um ponto fixo que você nomeia (um commit, uma branch, uma tag, `main`, `HEAD~5`) ao longo de dois eixos. **Standards** pergunta se o código segue como este repositório escreve código. **Spec** pergunta se o código faz o que a issue original ou a [spec](https://www.aihero.dev/ai-coding-dictionary/spec) pedia. Cada eixo roda em sua própria [sub-agent](https://www.aihero.dev/ai-coding-dictionary/subagent), para que nenhum veja o raciocínio do outro.

Os dois eixos nunca são mesclados e nunca são reordenados. O relatório termina com o pior problema *por eixo* e recusa-se a nomear um único vencedor entre eles, porque uma alteração pode passar em um eixo e falhar no outro: código que segue todas as convenções enquanto implementa a coisa errada passa em Standards e falha em Spec; código que faz exatamente o que o [ticket](https://www.aihero.dev/ai-coding-dictionary/ticket) pedia enquanto quebra as convenções do repositório faz o inverso. Um veredito misturado permite que o eixo que passou esconda o que falhou.

## Quando usá-la

Digite `/code-review`, ou o agente a usa automaticamente quando você pede para revisar uma branch, um PR, trabalho em progresso, ou qualquer coisa "desde X".

| Sua situação | Use |
| --- | --- |
| Um diff existe e você quer saber se foi construído certo *e* se é a coisa certa | `code-review` |
| Você quer caçar bugs no diff: caminhos nulos, race conditions, off-by-one | A revisão embutida do próprio Claude Code, não esta (veja o conflito de nomes abaixo) |
| Nada foi escrito ainda e você quer que seja escrito test-first | [tdd](https://aihero.dev/skills-tdd) |
| Uma spec inteira precisa ser construída, com revisão incluída | [implement](https://aihero.dev/skills-implement), que invoca esta skill |
| O codebase inteiro deslocou, não apenas um diff | [improve-codebase-architecture](https://aihero.dev/skills-improve-codebase-architecture) |
| Algo está quebrado e você não sabe por quê | [diagnosing-bugs](https://aihero.dev/skills-diagnosing-bugs) |

Você precisa fornecer o ponto fixo. Se não fornecer, a skill pede um em vez de adivinhar; depois verifica se o ref resolve e se o diff não está vazio antes de gerar qualquer coisa, para que um nome de branch errado falhe na sua frente em vez de dentro de dois sub-agentes.

## Pré-requisitos

O eixo Standards não precisa de nada. Ele lê o que o repositório documenta (`CODING_STANDARDS.md`, `CONTRIBUTING.md`, e similares) e recorre a uma linha de base embutida quando o repositório não documenta nada.

O eixo Spec precisa que uma spec exista e seja encontrável. Ele procura nesta ordem:

1. Referências a issues nas mensagens dos commits (`#123`, `Closes #45`, um GitLab `!67`), buscadas através de `docs/agents/issue-tracker.md`.
2. Um caminho que você passa como argumento.
3. Um arquivo de spec em `docs/`, `specs/`, ou `.scratch/` que corresponda ao nome da branch ou feature.
4. Perguntar a você.

O passo 1 depende de `docs/agents/issue-tracker.md`, que [setup-skills](https://aihero.dev/skills-setup-skills) escreve. Sem ele o eixo ainda funciona se você fornecer um caminho. Sem nenhuma spec, o sub-agente Spec é ignorado e o relatório diz "nenhuma spec disponível" em vez de inventar requisitos.

## Os dois eixos

| | Standards | Spec |
| --- | --- | --- |
| Pergunta | Foi construído certo? | É a coisa certa? |
| Lê | Os padrões documentados do repositório, mais a linha de base de smells | A issue ou spec original |
| Relata | Violações documentadas (podem ser difíceis) e smells (sempre julgamentos) | Requisitos ausentes ou parciais, scope creep, requisitos implementados incorretamente |
| Cada achado cita | O arquivo de padrões e a regra, ou o smell nomeado plus o hunk | A linha da spec |

Uma skill de revisão genérica que não conhece seus padrões é exatamente o que este design tenta evitar: ela sinaliza o que é deliberado no seu codebase e perde os invariantes que o seu codebase realmente depende. Portanto, a documentação própria do repositório é a [primary source](https://www.aihero.dev/ai-coding-dictionary/primary-source) no eixo Standards, e **o repositório sempre prevalece**.

A **linha de base de smells** é o chão por baixo, doze code smells de Fowler do _Refactoring_ cap.3: Mysterious Name, Duplicated Code, Feature Envy, Data Clumps, Primitive Obsession, Repeated Switches, Shotgun Surgery, Divergent Change, Speculative Generality, Message Chains, Middle Man, Refused Bequest. Cada um é uma heurística rotulada ("possível Feature Envy"), nunca uma violação estrita, e cada um é declarado como *o que é* → *como corrigir*, para que um achado chegue com um movimento anexado em vez de uma reclamação. Tudo que seu linter já aplica é ignorado por ambos os eixos.

## Perguntas comuns

**Ela conflita com o `/code-review` próprio do Claude Code. O que eu faço?**

Esse é o problema mais reportado sobre a skill, e não foi corrigido. O Claude Code entrega seu próprio `/code-review`, que faz algo diferente: ele caça bugs no diff, enquanto este verifica conformidade com a spec e padrões do repositório. Instalar esta biblioteca significa que um deles vence, e qual vence depende de como você instalou. Via uma instalação plain skills, o arquivo local vence e esta skill sobrepõe a embutida. Uma resposta limpa é remover as skills embutidas do Claude Code completamente: uma grande economia de [context](https://www.aihero.dev/ai-coding-dictionary/context), e o conflito deixa de importar. A sobreposição em si é provavelmente um bug do [harness](https://www.aihero.dev/ai-coding-dictionary/harness) do Claude Code (um autor de skill deveria poder nomear uma skill como quiser), então a outra resposta é renomear a cópia local. Editar o frontmatter ou renomear o diretório é desfeito por `npx skills update`; a alternativa durável reportada por usuários é fazer fork da skill para um novo nome e remover `code-review` do conjunto gerenciado, mantendo uma nota do commit de onde você fez fork para poder ressincronizar manualmente.

**Seus sub-agentes continuam invocando `/code-review` novamente e geram mais agentes.**

Bug aberto conhecido, reproduzido por várias pessoas e em mais de um harness. Os prompts de Standards e Spec não proíbem delegação, então um sub-agente pode redescobrir a skill e ramificar novamente: um relatório chegou a mais de 50 agentes. A correção que pessoas aplicaram em forks é uma linha adicionada aos dois briefs dos sub-agentes: "Não invoque `/code-review` ou gere agentes adicionais: execute esta revisão diretamente." Algumas preferem tratar no nível do harness para que toda skill herde a proteção. Nenhuma está na skill entregue ainda. Se você rodar isso sem supervisão, observe a contagem de agentes.

**Devo rodá-la na mesma [session](https://www.aihero.dev/ai-coding-dictionary/session) que escreveu o código?**

Prefira uma nova. Como um leitor colocou: "A mesma session revisando a si mesma não é revisão, é confirmação de viés com um slash command." O agente revisor na session de autoria detém todas as premissas que moldaram o código, que é exatamente o contexto que um revisor independente não teria. É também por isso que pessoas pedem [implement](https://aihero.dev/skills-implement) sem seu passo de revisão embutido: ela roda a revisão dentro da session que acabou de escrever o diff. Invocar `/code-review` você mesmo de uma session limpa é a versão honesta.

**Após cada ticket, ou uma vez no final?**

Ambos funcionam, e a skill não decide por você. Por ticket mantém cada diff pequeno o suficiente para que o eixo Spec tenha uma spec clara para verificar, que é o modo que `implement` usa. Agrupar até o final de uma branch captura interações entre tickets que o modo por ticket passaria despercebido. Se não tem certeza, revise por ticket e execute uma passada final contra o ponto da branch.

**Posso confiar nos achados?**

Não sem verificar. A saída de um sub-agente é uma hipótese, não evidência: um time reportou uma dúzia de breaking changes que revisões baseadas em texto deixaram passar. A skill agrega os dois relatos textualmente ou levemente limpos em vez de reverificar cada afirmação contra os arquivos, então um achado pode citar o local errado ou exagerar um impacto. Leia a citação em cada achado antes de agir sobre ele. O fato de cada achado ser obrigatório a carregar uma (uma regra de padrão, um smell mais seu hunk, ou uma linha de spec) é o que torna isso verificável.

**Por que ela encontra novos problemas toda vez que eu a rodo?**

Porque correções criam nova superfície, e porque a metade de julgamento do eixo Standards não é determinística entre execuções. Um leitor descreveu o loop claramente: "/code-review e /improve-code-architecture sempre encontram coisas novas toda vez. Eu implemento correções, reexecuto essas skills, e de novo e de novo." Não há garantia de convergência. Trate uma passada como uma lista de pistos, aja sobre as que têm uma regra citada atrás, e pare: não a rode em loop até voltar limpa, porque não vai.

**Ela revisa meu trabalho não commitado?**

Não. Ela faz diff de `<fixed-point>...HEAD`, três pontos, que é medido a partir do merge-base e exclui alterações staged e da working-tree. Se `implement` não fez um commit interim, o trabalho prestes a ser commitado é invisível para a revisão. Commit primeiro, depois revise, depois amend ou adicione um fixup.

## Está funcionando se

- Ela se recusa a iniciar com um ref ruim ou um diff vazio, antes que qualquer sub-agente seja gerado.
- O relatório chega como dois blocos separados sob `## Standards` e `## Spec`, não uma lista mesclada.
- Cada achado de Standards nomeia ou uma regra em um dos arquivos do seu repositório ou um dos doze smells, com o hunk citado; cada achado de Spec cita uma linha da spec.
- O resumo final dá o pior problema por eixo e se recusa a escolher um vencedor geral.
- Sem spec disponível, o bloco de Spec diz isso em vez de listar requisitos inferidos do código.

## Onde se encaixa

`code-review` é o passo de revisão na ponta da cadeia de construção: `grill-with-docs → to-spec → to-tickets → implement → code-review`. Ela também funciona sozinha em qualquer branch ou PR que você apontar nela.

- [implement](https://aihero.dev/skills-implement) é a vizinha mais próxima: ela conduz a construção e invoca esta skill como sua própria revisão final antes de commitar.
- [to-spec](https://aihero.dev/skills-to-spec) e [to-tickets](https://aihero.dev/skills-to-tickets) produzem o documento que o eixo Spec verifica; uma spec vaga torna aquele eixo vago.
- [improve-codebase-architecture](https://aihero.dev/skills-improve-codebase-architecture) é a contraparte de codebase inteiro: esta skill só olha para um diff.

[how-works](https://aihero.dev/skills-how-works) te direciona pelo conjunto todo quando você não tem certeza de qual skill a situação precisa.
