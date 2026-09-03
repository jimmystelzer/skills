## O que faz

`implement` constrói trabalho que já foi decidido. Você aponta para um [ticket](https://www.aihero.dev/ai-coding-dictionary/ticket), uma [spec](https://www.aihero.dev/ai-coding-dictionary/spec), ou o plano que você acabou de concordar na conversa, e ele escreve o código, direciona [tdd](https://aihero.dev/skills-tdd) nos seams, faz typecheck durante o processo, roda [code-review](https://aihero.dev/skills-code-review) ao final, e faz commit no branch atual.

Ele nunca reabre o plano. Não há entrevista, nem rodada de esclarecimentos, nem proposta de uma abordagem diferente. O que foi definido upstream é a entrada, e o trabalho inteiro do skill é transformar isso em um commit. É isso que o separa de digitar "construa isso" em um [agent](https://www.aihero.dev/ai-coding-dictionary/agent) novo, que vai redesenhar o trabalho enquanto o constrói com prazer.

## Quando usar

Você invoca isso digitando `/implement` você mesmo: o agent não vai usar por conta própria. Ele vem com `disable-model-invocation: true`, então nenhum outro skill pode chamá-lo também. Sempre que [how-works](https://aihero.dev/skills-how-works) ou [to-tickets](https://aihero.dev/skills-to-tickets) diz "então `/implement` por ticket", isso é uma instrução para você, não algo que o agent fará sem ser pedido.

Onde o trabalho está atualmente determina se este é o skill certo:

| O trabalho é… | Use |
| --- | --- |
| Um ticket no tracker | `/implement #42`, um ticket por [session](https://www.aihero.dev/ai-coding-dictionary/session), [clearing](https://www.aihero.dev/ai-coding-dictionary/clearing) o contexto entre tickets |
| Uma spec, ainda não dividida, e a construção abrange múltiplas sessions | [to-tickets](https://aihero.dev/skills-to-tickets) primeiro, depois `/implement` por ticket |
| Uma spec, e a construção é pequena | `/implement` diretamente contra a spec |
| Ainda só existe na conversa que você acabou de ter, e é pequena | `/implement` ali mesmo, na mesma janela |
| Ainda não escrito em nenhum lugar | [grill-with-docs](https://www.aihero.dev/skills-grill-with-docs), ou [grill-me](https://www.aihero.dev/skills-grill-me) se não há codebase |
| Um comportamento concreto que você quer test-first, sem spec | [tdd](https://aihero.dev/skills-tdd) diretamente |
| Já construído, e você quer que seja revisado | [code-review](https://aihero.dev/skills-code-review) diretamente |

O caso da mesma session merece destaque porque a primeira linha do próprio skill não o cobre. `SKILL.md` diz "a spec ou os tickets", o que leva o [model](https://www.aihero.dev/ai-coding-dictionary/model) a procurar por um arquivo que não existe. Se o plano vive apenas no thread, diga isso ao invocá-lo.

## Pré-requisitos

`implement` faz commit no branch que você está. Ele não cria um, nem pergunta. Verifique se está no branch onde quer que o trabalho seja feito antes de começar.

Se os tickets vieram de [to-tickets](https://www.aihero.dev/skills-to-tickets), o tracker onde estão foi configurado por [setup-skills](https://aihero.dev/skills-setup-skills). `code-review` lê a mesma configuração para encontrar a spec de origem no fechamento.

## O que uma execução faz

Uma execução tem cinco tempos, em ordem:

1. Lê o ticket ou spec e identifica os seams.
2. Direciona [tdd](https://aihero.dev/skills-tdd) nos seams pré-acordados, um fatia red-green por vez.
3. Faz typecheck frequentemente, roda arquivos de teste individuais durante o processo.
4. Roda a suíte de testes completa uma vez, ao final.
5. Roda [code-review](https://aihero.dev/skills-code-review), depois faz commit no branch atual.

Uma execução cobre um ticket. Os tickets que [to-tickets](https://aihero.dev/skills-to-tickets) produz são fatias verticais tracer-bullet dimensionadas para caber em uma única [context window](https://www.aihero.dev/ai-coding-dictionary/context-window) nova, então o ritmo pretendido é: limpar contexto, implementar um ticket, commit, limpar novamente. Cada ticket é autocontido, o que torna o contexto do ticket anterior descartável.

## Seams pré-acordados

A ideia na qual o skill opera é o **seam**: o limite público onde você observa comportamento, sem acessar o que está dentro. Testes vivem nos seams. Trabalhar em um seam acordado antes de qualquer código ser escrito é o que mantém os testes duráveis, porque a implementação por baixo pode ser reescrita sem que os testes se movam.

A palavra "pré-acordado" tem um papel real, e é também a articulação mais fraca do skill. Nada dentro de `implement` acorda os seams. `tdd` é o skill que pergunta, e ele se recusa a escrever um teste em um seam não confirmado. Então, na prática, o acordo acontece ou upstream na spec, ou na primeira troca da execução. Se não acontecer em nenhum lugar, a pré-condição nunca dispara e a execução silenciosamente se torna "apenas escreva o código". Nomear os seams na spec é o que impede isso.

## Perguntas frequentes

**Terminou, mas meu ticket continua aberto e os critérios de aceitação continuam desmarcados.**

Correto, e esperado. `implement` não tem etapa de conclusão. Ele termina no commit e nunca toca no item de trabalho, confirmado no GitHub Issues e no tracker markdown local, então não é um problema de integração com o tracker. Também não age sobre os resultados que `code-review` produziu, e não marca as caixas `- [ ]` na issue de origem. Feche o ticket e reconcilie os critérios você mesmo. Isso dói mais em uma cadeia de dependências, porque [to-tickets](https://www.aihero.dev/skills-to-tickets) define a fronteira como tickets cujos bloqueadores estão todos fechados. Se nada for fechado, nada se torna visivelmente desbloqueado.

**Posso apontar para todos os meus tickets de uma vez, ou rodar vários em paralelo?**

Não. Uma invocação, um ticket. Dispatch em lote em uma fila de tickets e fan-out de [subagent](https://www.aihero.dev/ai-coding-dictionary/subagent) são solicitados repetidamente, e nenhum existe. Rodar várias sessões `/implement` lado a lado em um checkout é pior do que não ter suporte: um relato descreve um `git commit --amend` em uma sessão caindo no commit de outra sessão, um stash desaparecendo de `refs/stash`, e commits caindo no branch errado, tudo em uma única tarde em três issues. As sessões compartilham um diretório de trabalho, um índice e um HEAD. Git worktrees são a solução da comunidade, e note que `refs/stash` é compartilhado entre worktrees também, então worktrees por si só não resolvem o caso do stash. Se você quer paralelismo hoje, está montando sozinho.

**Pode abrir um pull request em vez de fazer commit?**

Não é nativo. Ele faz commit direto no branch atual, o que várias pessoas acham ousado demais: o código é mergeado antes que elas tenham chance de verificar se funciona. Não há flag de configuração nem modo PR. As pessoas contornam na invocação ("faça commit em um branch e abra um PR") ou editando sua cópia local do skill.

**`code-review` diz que não consegue ver minhas mudanças.**

`code-review` revisa `git diff <fixed-point>...HEAD`, que exclui mudanças staged e do working tree. `implement` o roda antes de fazer commit, então, a menos que um commit intermediário já exista, não há nada nesse diff para revisar. Várias pessoas relataram isso e está corrigido em nenhum dos dois lados. Faça commit primeiro, depois revise contra o ponto de onde você fez branch.

Separadamente, algumas pessoas deliberadamente não querem a revisão dentro da execução, porque um agent revisando o código que acabou de escrever é enviesado em favor de sua própria solução. Rodar [code-review](https://www.aihero.dev/skills-code-review) em uma sessão nova contra um fixed point é uma alternativa legítima, e é a mesma razão pela qual esse skill roda seus dois eixos em sub-agentes separados.

**Um ticket consumiu 150k tokens. Estou usando errado?**

Provavelmente o ticket é grande demais, não que o skill esteja sendo mal usado. Uma execução faz exploração da codebase, um loop red-green por seam, uma suíte completa, e uma revisão, então um ticket não trivial que excede 100k [tokens](https://www.aihero.dev/ai-coding-dictionary/token) é normal, não um sinal de que algo quebrou. A alavanca está upstream: dimensione corretamente os tickets em [to-tickets](https://aihero.dev/skills-to-tickets) para que cada um caiba em uma janela nova. Se um único ticket continua estourando, divida-o em vez de aumentar o nível de [effort](https://www.aihero.dev/ai-coding-dictionary/effort).

**`/implement #2` em uma sessão nova trabalhou em algo completamente não relacionado.**

`#2` é resolvido contra qualquer lista numerada que o agent consiga ver, que em uma sessão nova pode ser um arquivo de tarefas, um checklist, ou outra lista de trabalho em vez do tracker configurado. A resolução é confiante em vez de fail-closed, então o erro não é óbvio até que tenha começado. Passe a referência completa, a URL da issue ou `owner/repo#2`, e peça que confirme o título antes de começar.

## Está funcionando se

- A sessão começa lendo o ticket ou spec e reafirmando o que vai construir, em vez de perguntar o que construir.
- Você consegue ver uma invocação real de `/tdd` no trace, não apenas testes aparecendo no diff.
- Typechecks e arquivos de teste individuais rodam repetidamente durante a execução, e a suíte completa roda uma vez perto do final.
- A execução chega a um commit no seu branch atual sem que você peça para continuar.
- O diff é a mudança de um ticket: uma fatia vertical por cada camada, não vários tickets agrupados.

## Onde se encaixa

`implement` é a etapa de construção da cadeia principal, segunda do final:

```txt
grill-with-docs → to-spec → to-tickets → implement → code-review
```

Seus vizinhos são [to-tickets](https://aihero.dev/skills-to-tickets), que produz os tickets que ele consome e declara as arestas de bloqueio que determinam sua ordem; [tdd](https://aihero.dev/skills-tdd), que ele direciona internamente em cada seam; e [code-review](https://aihero.dev/skills-code-review), que ele roda antes de fazer commit. Ele fica downstream das skills de planejamento e confia nelas. Ele não re-valida a forma do que lhe foi entregue, então um mapa mal estruturado ou um ticket horizontalmente layerado é construído conforme escrito.

Essa confiança é pela qual [wayfinder](https://aihero.dev/skills-wayfinder) se funde na cadeia em [to-spec](https://www.aihero.dev/skills-to-spec) em vez de conectar seu mapa diretamente em `implement`. Ir direto para `implement` a partir de um mapa só quando o esforço se revelou genuinamente pequeno.

[how-works](https://aihero.dev/skills-how-works) é o roteador sobre o conjunto inteiro quando você não tem certeza em qual fluxo está.
