## O que faz

`resolving-merge-conflicts` trabalha em um merge ou rebase do git em progresso, bloco por bloco, depois roda os checks próprios do projeto e termina a operação com um commit.

Ele se recusa a tratar um conflito como um problema de texto. Antes de tocar em um bloco, ele rastreia cada lado até sua **[fonte primária](https://www.aihero.dev/ai-coding-dictionary/primary-source)** (a mensagem de commit, o PR, a issue original), então ele está escolhendo entre duas intenções em vez de entre dois blocos de texto, e preserva ambos onde forem compatíveis. Onde genuinamente não são, ele escolhe o lado que corresponde ao objetivo declarado do merge e nomeia o trade-off. Ele não inventa um novo comportamento para disfarçar um conflito, e `--abort` não é uma opção que ele tem: o merge sempre é levado a um commit terminado.

## Quando usar

Digite `/resolving-merge-conflicts`, ou o [agent](https://www.aihero.dev/ai-coding-dictionary/agent) o usa automaticamente quando uma tarefa se encaixa.

Use quando o git já parou em conflitos que não conseguiu resolver sozinho. Ele está escopado ao conflito diante de você, não a nada ao redor:

| Sua situação | Skill |
| --- | --- |
| No meio de um merge ou rebase, marcadores de conflito na árvore | Este |
| Merge terminado, algo agora se comporta mal por razões que você não consegue ver | [diagnosing-bugs](https://aihero.dev/skills-diagnosing-bugs) |
| Planejando como dividir o trabalho para que branches colidam menos | Nenhum: veja a pergunta de trabalho paralelo abaixo |

## Fontes primárias sobre `ours` e `theirs`

A falha que isso existe para eliminar é resolver por flag: `--ours`, `--theirs`, ou deletar manualmente o bloco que parece menos importante, para que os marcadores desapareçam e o build compile. Essa resolução pode ser sintaticamente perfeita e ainda silenciosamente dropar uma mudança que alguém fez de propósito.

Você não pode preservar uma intenção que não leu. Então o trabalho começa no histórico (commits, PRs, [tickets](https://www.aihero.dev/ai-coding-dictionary/ticket)) e só então vai para o diff. Outro passo no loop existe pela mesma razão: o skill encontra os [automated checks](https://www.aihero.dev/ai-coding-dictionary/automated-check) do próprio repo e os roda antes de fazer commit, porque um merge é o lugar mais fácil no git para produzir código que satisfaz ambos os branches e não passa nos testes de nenhum dos dois.

## Perguntas frequentes

**Claude Code já resolve conflitos razoavelmente bem sozinho. Por que precisa de um skill?**

O valor adicionado são os passos "encontre as fontes primárias" e "rote loops de feedback", que caso contrário precisam ser pedidos manualmente a cada vez. Um agent sem prompt geralmente produz uma resolução plausível a partir do diff apenas e para ali. O valor do skill são os dois passos que ele não deixa o agent pular: ler por que cada lado existe, e rodar os checks depois. Isso é uma margem estreita sobre um bom [model](https://www.aihero.dev/ai-coding-dictionary/model), e é intencional: pelo menos um leitor previu que isso é uma skill inteira que se torna um no-op à medida que os models melhoram.

**Devo manter agents paralelos fora dos mesmos arquivos para evitar conflitos?**

Na maioria das vezes não. Zonar arquivos entre tarefas paralelas custa mais do que economiza, porque agents são bons o suficiente em conflitos de merge para que o trade-off não seja tão duro quanto parece. A única disciplina que vale a pena manter é fazer grandes refatoramentos primeiro. Um grande rename caindo depois de dez branches terem fechado dele é o caso que continua caro.

Uma ressalva de um relato de um usuário sobre worktrees paralelos: quando [sessions](https://www.aihero.dev/ai-coding-dictionary/session) irmãs constroem cada um um ticket em sua própria árvore, o merge de volta é melhor feito pela session que escreveu a mudança, porque é a que já conhece a intenção. Agrupar os conflitos de todos em um agent no final descarta exatamente o passo de [context](https://www.aihero.dev/ai-coding-dictionary/context) que o passo 2 deste skill tem que ir e reconstruir.

**Por que nunca `--abort`?**

Abortar descarta o trabalho de resolução e te retorna ao mesmo conflito, inalterado, na próxima vez que tentar. O skill é escrito para o caso em que o merge vai acontecer. Se você decidiu que não deveria acontecer, essa é uma decisão a tomar antes de invocar, não um branch dentro do loop.

## Está funcionando se

- O agent cita mensagens de commit, PRs ou issues para você enquanto resolve, não apenas blocos de diff.
- Cada bloco termina com o comportamento de ambos os lados, ou com uma nota explícita nomeando o que foi descartado e por quê.
- Nada aparece no resultado que não estava em nenhum dos dois branches.
- Typecheck, testes e formatação foram localizados e rodaram verdes *antes* do commit, não depois que você notou algo quebrado.
- Você termina com uma árvore limpa com a operação concluída, incluindo cada commit restante em um rebase multi-commit.

## Onde se encaixa

Um standalone que você usa a qualquer momento sem dependências de nenhuma outra skill: começa quando o git trava e termina quando a árvore está limpa e commitada. Seu único vizinho real é [diagnosing-bugs](https://aihero.dev/skills-diagnosing-bugs), que toma o ponto onde um merge foi resolvido limpo mas o código mergeado se comporta mal: um problema de diagnóstico, não de conflito. Ele fica completamente fora do fluxo principal de ideia-à-entrega, então [how-works](https://aihero.dev/skills-how-works) é o mapa do que roda antes e depois dele.
