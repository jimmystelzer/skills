## O que faz

`to-tickets` pega um plano, uma [spec](https://www.aihero.dev/ai-coding-dictionary/spec), ou a conversa em que você está, e o divide em um conjunto de **[tickets](https://www.aihero.dev/ai-coding-dictionary/ticket)** no seu issue tracker. Cada ticket declara suas **arestas de bloqueio**: os outros tickets que precisam terminar antes que ele possa começar.

Todo ticket é uma **tracer bullet**: um caminho estreito mas completo através de cada camada da mudança (schema, API, UI, testes) que pode ser demonstrado por si só no momento em que é lançado. Essa é a restrição que o faz se comportar de forma diferente da maneira óbvia de dividir trabalho, que é cortar uma camada por vez e integrar no final. Ele também dimensiona cada ticket para caber em uma única nova [context window](https://www.aihero.dev/ai-coding-dictionary/context-window), porque a coisa que vai pegar o ticket é uma [session](https://www.aihero.dev/ai-coding-dictionary/session) que nunca viu sua spec.

## Quando acessá-lo

Você invoca isso digitando `/to-tickets`. O [agent](https://www.aihero.dev/ai-coding-dictionary/agent) não o acessará sozinho.

| Onde você está | O que executar |
| --- | --- |
| Você tem uma issue de spec e a construção abrange várias sessões | `/to-tickets`, ou `/to-tickets #<spec_issue>` |
| O plano está apenas na conversa, nunca foi escrito | `/to-tickets` lê a thread diretamente, nenhuma spec necessária |
| A mudança inteira cabe em uma context window | [implement](https://aihero.dev/skills-implement), pule os tickets |
| Nada foi decidido ainda | [grill-with-docs](https://aihero.dev/skills-grill-with-docs), depois [to-spec](https://aihero.dev/skills-to-spec) |
| Um mapa [wayfinder](https://aihero.dev/skills-wayfinder) foi liberado | [to-spec](https://aihero.dev/skills-to-spec) primeiro, para colapsar o mapa, depois `/to-tickets` |

Tickets que `to-tickets` produziu são agent-ready por construção. Não execute [triage](https://aihero.dev/skills-triage) sobre eles. Triage é para trabalho que chegou de outra pessoa.

## Pré-requisitos

`to-tickets` publica em um tracker, então [setup-skills](https://aihero.dev/skills-setup-skills) deve ter configurado um para este repo, junto com o vocabulário de rótulos de triagem. Qualquer tipo funciona: um tracker real como GitHub, ou arquivos markdown locais sob `.scratch/`, que é suportado nativamente.

## Tracer bullets, não camadas

Um corte **horizontal** entrega uma camada da mudança. Nada funciona até que todas as camadas tenham sido lançadas, e os critérios de aceitação de cada ticket precisam reaching into trabalho que outro ticket possui. Um corte **vertical** (a tracer bullet) entrega um caminho fino através de todas as camadas de uma vez, então é verificável sozinho e possui tudo o que avalia.

Esta é a regra que as pessoas mais quebram, e as consequências são bem documentadas. Uma equipe executou uma pilha de 26 tickets cortada por camada (corpus, producer, aggregator, selector) e obteve aproximadamente vinte execuções de agent por ticket fechado, cerca de três quartos delas retrabalho. Seu próprio post-mortem rastreou cada classe de falha até o corte horizontal em vez das implementações.

Duas coisas acontecem antes que qualquer coisa seja publicada. `to-tickets` procura por prefactoring (o princípio "torne a mudança fácil, depois faça a mudança fácil") e ordena esse trabalho primeiro. Então ele apresenta a divisão como uma lista numerada e te questiona sobre ela: a granularidade está certa, as arestas de bloqueio são reais, algo deveria ser mesclado ou dividido. Nada alcança o tracker até você aprovar, e esse questionamento é o lugar para recusar.

## Arestas de bloqueio

As arestas são o ponto do artefato. Elas são lidas de duas formas dependendo do tracker:

| Tracker | Onde as arestas ficam | Como você trabalha com elas |
| --- | --- | --- |
| Markdown local | Texto em um arquivo por ticket sob `.scratch/<feature>/issues/<NN>-<slug>.md`, numeradas com bloqueadores primeiro | De cima para baixo, à mão |
| Um tracker real (GitHub) | Links de bloqueio nativos, ou sub-issues onde o tracker as tem | Qualquer ticket cujos bloqueadores estão fechados está na **fronteira** e pode ser selecionado |

As arestas ficam no ticket de qualquer forma. O meio apenas decide se algo pode agir sobre elas em paralelo. `to-tickets` produz o artefato; executá-lo (uma sessão por vez, ou uma frota) é seu trabalho, não da skill.

## A exceção de refactoring amplo

Uma forma quebra a regra da tracer bullet. Um **refactoring amplo** é uma mudança mecânica única (renomear uma coluna, re-typar um símbolo compartilhado) cujo **blast radius** se espalha por todo o codebase, então uma edição quebra milhares de call sites e nenhum corte vertical pode chegar verde.

`to-tickets` sequencia isso como **expand-contract** em vez disso:

- **Expand**: adicione a nova forma ao lado da antiga, para que nada quebre.
- **Migrate**: mova os call sites em lotes dimensionados por blast radius (por pacote, por diretório), um ticket por lote, cada um bloqueado pelo expand. CI fica verde porque a forma antiga ainda existe.
- **Contract**: delete a forma antiga quando nenhum caller permanecer, em um ticket bloqueado por cada lote de migrate.

Onde até os lotes não podem ficar verdes sozinhos, eles compartilham uma branch de integração e todos bloqueiam um ticket final de integrar-e-verificar. Verde é prometido apenas lá.

## Perguntas comuns

**Ele produziu doze tickets para uma mudança de três linhas.**
A decomposição excessiva é a fricção mais reportada nesta skill, e é consistente entre praticantes: o [model](https://www.aihero.dev/ai-coding-dictionary/model) é padrão em unidades atômicas e perde o agrupamento que as tornaria significativas. A etapa de questionamento existe exatamente para isso: peça para mesclar, e ele o fará. A resposta mais profunda é que os tickets têm um piso: se a mudança inteira cabe em uma context window, você não precisa desta skill. Vá direto para [implement](https://aihero.dev/skills-implement).

**Os tickets saíram um por camada: todo o schema em um, toda a API em outro.**
Esta é a falha para a qual a regra de corte vertical foi escrita, e a skill ainda às vezes a produza. Pegue-a na etapa de questionamento fazendo uma pergunta por ticket: o que posso demonstrar quando isso estiver pronto? Um ticket sem resposta é um corte horizontal. Algumas pessoas adicionam uma linha "demo path" a cada ticket por essa razão, e reportam que isso empurra o model em direção à decomposição vertical.

**No GitHub os tickets não foram criados como sub-issues da issue de spec.**
Conhecido e não corrigido. Foi reportado em mais de uma dúzia de execuções e vários models, [mais completamente no issue #554](https://github.com/mattpocock/skills/issues/554), e é pior no Codex do que no Claude. `gh` suporta isso nativamente desde v2.94: `gh issue create --parent <n>`, e `gh issue edit <parent> --add-sub-issue <n>` depois. Até que o template do tracker prefira esses, conectar os links de pai manualmente depois de uma execução é a jogada confiável.

**"Blocked by" foi escrito no corpo da issue em vez de um link de bloqueio real.**
Mesma classe de problema, [reportado no issue #513](https://github.com/mattpocock/skills/issues/513), onde o agent foi ao ponto de afirmar que o GitHub não tem nenhuma relação de bloqueio nativa. Tem: `gh issue create --blocked-by 12,15`. Como os bloqueadores são publicados primeiro, seus números estão sempre disponíveis no momento da criação. O texto do corpo é destinado a ser o fallback para trackers sem aresta nativa, não o padrão.

**Para onde vão os tickets locais? As notas da v1.1 diziam um `tickets.md` no nível raiz.**
Era, e isso era um bug: um único arquivo compartilhado também competia quando agents paralelos escreviam nele. O modo local agora escreve um arquivo por ticket sob `.scratch/<feature-slug>/issues/<NN>-<slug>.md`, em ordem de dependência, correspondendo ao layout que o template do tracker local já descrevia. O prefixo `NN` é um ID de ticket real, então `/implement 03` funciona em vez de digitar um título longo.

**Ele ficava truncando quando tentava ler minha spec.**
Uma spec muito grande pode crescer além do que uma issue de tracker serve de volta limpa, e não há cópia local para recorrer, então o agent então gasta [tool calls](https://www.aihero.dev/ai-coding-dictionary/tool-call) re-buscando pedaços e nunca alcança o fim. Não faça [clear](https://www.aihero.dev/ai-coding-dictionary/clearing) ou [compact](https://www.aihero.dev/ai-coding-dictionary/compaction) entre `/to-spec` e `/to-tickets`. Execute-os na mesma context window e a spec nunca precisa ser buscada de volta.

**Os critérios de aceitação não avaliaram nada: alguns passaram antes que qualquer trabalho fosse feito.**
O template pede critérios e não diz nada sobre se eles podem falhar, então isso acontece. Três formas se repetem: um critério que já é verdade no commit base, um critério que só pode ser satisfeito por trabalho que outro ticket possui, e um que reenuncia a requisição em vez de derivar do artefato. O corte vertical previne a maioria disso (um slice que entrega comportamento que não existia antes é vermelho no commit base por construção), mas a verificação vale a pena ser feita à mão. Para cada critério, nomeie a observação que mostraria ele falso, e confirme que ele falha no commit de onde o implementador começa.

**Os tickets foram publicados. Como eu realmente os executo?**
A skill para no artefato, e não há modo de despacho automático. Despacho é manual: olhe para o quadro, conte os tickets sem bloqueadores abertos, e abra tantas sessões de agent. Um ticket por context nova, limpa entre eles. Esteja ciente de que [implement](https://aihero.dev/skills-implement) não fecha ou marca o ticket de forma confiável quando termina, no GitHub ou em markdown local, então o estado do ticket é seu para atualizar.

## Está funcionando se

- Cada ticket tem uma resposta para "o que posso demonstrar quando isso estiver pronto?", e a resposta é comportamento, não uma camada.
- A lista volta para você numerada, com uma linha "Blocked by" em cada uma, antes que qualquer coisa seja publicada.
- O ticket no topo não tem bloqueadores e pode ser iniciado imediatamente.
- Nada no corpo de um ticket é um caminho de arquivo ou um número de linha, exceto um trecho que um protótipo produziu.
- Cada ticket lê como algo que uma sessão nova poderia terminar sem você na sala.
- Prefactoring, onde encontrou qualquer, está na frente da ordem em vez de misturado com tickets de funcionalidade.

## Onde se encaixa

`to-tickets` é uma etapa na cadeia principal de construção:

```txt
grill-with-docs → to-spec → to-tickets → implement → code-review
```

A montante está [to-spec](https://aihero.dev/skills-to-spec), que entrega uma spec definida para cortar contra; mantenha ambos em uma context window ininterrupta. A jusante está [implement](https://aihero.dev/skills-implement), que constrói um ticket por sessão nova, conduzindo [tdd](https://aihero.dev/skills-tdd) para os testes e fechando com [code-review](https://aihero.dev/skills-code-review). Quando você não tem certeza de qual skill ou fluxo se encaixa, [how-works](https://aihero.dev/skills-how-works) o direciona.
