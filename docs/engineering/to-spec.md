## O que faz

`to-spec` transforma a conversa que você acabou de ter em uma **[spec](https://www.aihero.dev/ai-coding-dictionary/spec)**, e a publica no seu issue tracker como uma única issue.

Ele não entrevista você. Quando você o acessa a decisão já foi tomada, então ele sintetiza o que é conhecido (da thread, do codebase, do seu `CONTEXT.md` e ADRs) em vez de abrir uma nova rodada de perguntas. A spec é um registro de decisões já tomadas, não um lugar onde novas decisões são feitas.

## Quando acessá-lo

Você invoca isso digitando `/to-spec`; o [agent](https://www.aihero.dev/ai-coding-dictionary/agent) não o acessará sozinho.

Acesse-o quando a construção é grande demais para uma [session](https://www.aihero.dev/ai-coding-dictionary/session) de agent e precisa sobreviver a ser dividida entre várias. Esse é todo o gatilho:

| Onde você está | O que executar |
| --- | --- |
| Você ainda não decidiu nada | [grill-with-docs](https://aihero.dev/skills-grill-with-docs) primeiro |
| Decidiu, e o trabalho cabe em uma [context window](https://www.aihero.dev/ai-coding-dictionary/context-window) | [implement](https://aihero.dev/skills-implement): pule a spec |
| Decidiu, e o trabalho abrange várias sessões | `/to-spec`, depois [to-tickets](https://aihero.dev/skills-to-tickets) |
| Um mapa [wayfinder](https://aihero.dev/skills-wayfinder) foi liberado | `/to-spec #<map_issue>` |

## Pré-requisitos

`to-spec` publica a spec como uma issue, então [setup-skills](https://aihero.dev/skills-setup-skills) deve ter configurado um tracker e o vocabulário de rótulos de triagem para este repo primeiro. Qualquer tipo funciona: um tracker real como GitHub, ou arquivos markdown locais sob `.scratch/`, que é suportado nativamente.

## A spec é um registro de decisões

A spec existe porque context windows terminam. Tudo o que você resolveu enquanto [grillava](https://www.aihero.dev/ai-coding-dictionary/grilling) (a forma da solução, as escolhas que você discutiu, o que você deliberadamente recusou) está em uma conversa que está prestes a ser limpa. A spec é o que sobrevive a isso.

Então ela não valida nada, e não decide nada. Ela captura o que foi decidido, no vocabulário do seu projeto, para que uma sessão nova possa retomar o trabalho sem você re-explicar. Qualquer coisa que a spec afirme que você nunca realmente disse é um defeito.

## Seams antes de texto

Antes de escrever uma palavra, `to-spec` esboça os **seams** nos quais a funcionalidade será testada, e os verifica com você. Ele prefere seams que já existem a novos, e pega o seam mais alto que pode: o número ideal em uma mudança é um.

Esses seams acordados então viajam. [tdd](https://aihero.dev/skills-tdd) trabalha apenas em seams pré-acordados, e [code-review](https://aihero.dev/skills-code-review) revisa o diff contra a spec, então um seam que ninguém acordou aparece como achado de revisão. A vinculação é indireta: ela corre através deste documento, que é exatamente por que a conversa sobre seams vale a pena ser levada a sério aqui em vez de ser adiada para a implementação.

## Perguntas comuns

**Para onde foi `/to-prd`?**
Esta é a skill, renomeada na v1.1. "Spec" é agora o único termo longitudinal, e o antigo slug `to-prd` está morto; reinstale sob o novo nome. O par que substituiu o antigo vocabulário é *spec* e *tickets*: a spec é o destino e as decisões que o fixam, os [tickets](https://www.aihero.dev/ai-coding-dictionary/ticket) são os passos de execução para chegar lá. Se você mudar de ideia, delete os tickets não finalizados e mantenha a spec.

**Por que a spec recebe o rótulo `ready-for-agent`? Eu não quero um agent implementando a partir dela.**
O rótulo significa "nenhuma triagem adicional necessária": o documento está completo o suficiente para um agent trabalhar. É uma designação de entrada, não uma ordem de trabalho. Mas se você executar [AFK](https://www.aihero.dev/ai-coding-dictionary/afk) agents que buscam por `ready-for-agent`, essa distinção não é visível para eles, e eles tentarão felizmente construir toda a spec em uma execução em vez de selecionar os slices de tickets. Esta é a aresta áspera mais reportada da skill. Até que mude, exclua a spec pai explicitamente no prompt do seu agent AFK, ou remova o rótulo depois que `/to-tickets` for executado.

**Por que não ir direto do grilling para `/to-tickets` e pular a spec?**
Geralmente você deveria; a spec ganha sua etapa apenas em trabalho multi-sessão. Onde ela se paga é que os tickets são descartáveis e a spec não: cada ticket é dimensionado para uma nova context window e é deletado ou fechado, enquanto a spec permanece como o único lugar onde o raciocínio por trás deles vive. Em uma mudança de única sessão isso não compra nada, e você pagou uma etapa extra de síntese onde o [model](https://www.aihero.dev/ai-coding-dictionary/model) pode derivar. Vá grilling → `/implement`.

**Acabei de finalizar um mapa wayfinder. O que eu alimento com ele?**
A issue do mapa principal: `/to-spec #<map_issue>`, não os tickets individuais de decisão. [wayfinder](https://aihero.dev/skills-wayfinder) produz decisões em vez de entregas, espalhadas por um mapa; `to-spec` é a etapa que colapsa essas decisões em um único documento construível. Alimentar o mapa direto em `/implement` descarta esse colapso.

**A spec é para eu revisar, ou é apenas para o agent?**
Principalmente para o agent, e ela lê dessa forma: completa, densa, pesada em referências. As partes que valem seu olhar são os seams e a seção fora do escopo, porque esses são os dois lugares onde uma decisão errada é mais barata de detectar e mais cara de descobrir depois. Ler a coisa toda de ponta a ponta é uma queixa real que as pessoas têm, e não há modo de resumo: a resposta honesta é que se a spec te surpreende, o grilling foi raso demais, não a spec longa demais.

**Mantenho a spec congelada quando os tickets começam, ou deixo o agent reescrevê-la?**
Nada mantém ela sincronizada, então na prática é um snapshot do que você sabia naquele momento, e ela fica obsoleta na primeira vez que a implementação te ensina algo. Trate-a como descartável depois que o trabalho é entregue. Os artefatos destinados a sobreviver a ela são seu `CONTEXT.md` e seus ADRs; se algo aprendido durante a implementação merece durar, pertence lá, não em uma spec editada.

**Meu trabalho é um refactor ou um limite de módulo, não uma funcionalidade. O template se encaixa?**
Menos bem, e isso é uma limitação conhecida. O template se apoia fortemente em user stories, que é a forma errada para trabalho arquitetônico: você acaba escrevendo stories que ninguém pediu ao redor de decisões que são realmente sobre interfaces e invariantes. Apoie-se nas seções de decisões de implementação e decisões de teste, e deixe as decisões arquitetônicas duradouras serem ADRs via [grill-with-docs](https://aihero.dev/skills-grill-with-docs) em vez de tentar fazer a spec carregá-las.

**Ele verá o tracker por trabalho relacionado, ou citará os ADRs que está respeitando?**
Não para ambos. Ele lê e respeita os ADRs cobrindo a área que toca, mas não os vincula, e não pesquisa o tracker por issues sobrepondo antes de redigir, então uma spec pode silenciosamente duplicar trabalho que alguém já registrou. Pesquise o tracker você mesmo primeiro se a área estiver ocupada.

**`/to-tickets` não conseguiu ler minha spec: ficava truncando.**
Specs muito grandes podem crescer além do que uma issue de tracker serve de volta limpa, e não há cópia local para recorrer. A correção é higiene de contexto: não faça [clear](https://www.aihero.dev/ai-coding-dictionary/clearing) ou [compact](https://www.aihero.dev/ai-coding-dictionary/compaction) entre `/to-spec` e `/to-tickets`. Execute-os na mesma janela e a spec nunca precisa ser buscada novamente.

## Está funcionando se

- Ele começa a escrever em vez de fazer uma nova rodada de perguntas.
- Ele coloca os seams diante de você antes de escrever, e propõe o menos que puder.
- Ele volta nos substantivos do seu projeto, não em template genérico de gestão de produto.
- Cada decisão nela é uma que você se lembra de ter tomado. Nada foi inventado para preencher uma seção.
- A seção fora do escopo tem coisas reais nelas: as coisas que você recusou são geralmente as linhas mais úteis na página.

## Onde se encaixa

`to-spec` é uma etapa na cadeia principal de construção, e apenas no ramo multi-sessão dela:

```txt
grill-with-docs → to-spec → to-tickets → implement → code-review
```

Seus vizinhos a montante são [grill-with-docs](https://aihero.dev/skills-grill-with-docs), que faz a decisão que esta skill apenas registra, e [wayfinder](https://aihero.dev/skills-wayfinder), cujo mapa finalizado se funde na cadeia bem aqui. A jusante, [to-tickets](https://aihero.dev/skills-to-tickets) corta a spec em tickets de tracer bullet para [implement](https://aihero.dev/skills-implement) construir. Quando você não tem certeza de qual skill ou fluxo se encaixa, [how-works](https://aihero.dev/skills-how-works) o direciona.
