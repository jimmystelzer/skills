## O que faz

`research` responde uma pergunta lendo as fontes que possuem a resposta, depois deixa um arquivo Markdown citado no repo. Ele trabalha apenas com **[fontes primárias](https://www.aihero.dev/ai-coding-dictionary/primary-source)**: documentação oficial, código-fonte, specs, APIs de primeira parte. Ele segue cada afirmação até a fonte que a possui, então não vai repetir o relato de um blog post sobre uma API quando a própria documentação da API está acessível.

Ele não responde na conversa. A saída é um arquivo, escrito onde o repo já mantém essas notas, com um link em cada afirmação. Esse é o ponto: um documento ao qual você pode reagir, entregar a outro agent, ou descartar, em vez de uma resposta que desaparece quando a [session](https://www.aihero.dev/ai-coding-dictionary/session) termina.

## Quando usar

Digite `/research`, ou o [agent](https://www.aihero.dev/ai-coding-dictionary/agent) o usa automaticamente quando uma tarefa se transforma em trabalho de leitura.

Use quando o próximo passo é *descobrir algo* de fora do working directory (como uma API de terceiros se comporta, o que uma spec realmente diz, se uma afirmação de versão se sustenta), e você preferiria não travar seu próprio thread fazendo a leitura. O que você precisa determina qual skill:

| O que você precisa | Use |
| --- | --- |
| Um fato externo do qual uma decisão depende | `research` |
| Uma decisão feita *com* você, por entrevista | [grilling](https://aihero.dev/skills-grilling) |
| Uma decisão de arquitetura duradoura, escrita em `CONTEXT.md` e ADRs | [grill-with-docs](https://aihero.dev/skills-grill-with-docs) |
| Descobrir se uma abordagem funciona na sua codebase | [prototype](https://aihero.dev/skills-prototype) |
| Um plano grande demais para caber em uma session | [wayfinder](https://aihero.dev/skills-wayfinder) |

A linha entre `research` e `grill-with-docs` é a **vida útil do que volta**. Research produz ativos de curta duração: o que o mecanismo de autenticação desta biblioteca faz esta semana. Um ADR registra uma decisão que você mantém. Se o que você está produzindo é uma decisão e não um fato, você está [questionando](https://www.aihero.dev/ai-coding-dictionary/grilling), não pesquisando.

## Trabalho delegado

O movimento definidor é que a leitura roda como um **agent de fundo**. Você continua trabalhando; ele vai embora, segue cada afirmação até sua fonte primária, escreve um arquivo Markdown, e relata de volta. Research é trabalho que você delega, não pensamento que você terceiriza: você recebe um documento para questionar, planejar, ou projetar, e ainda toma a decisão.

A delegação é sem guarda, e o agent de fundo pode gerar outro agent de fundo. Esta é a aresta áspera mais documentada do skill.

Onde o arquivo cai é decidido pelo repo, não pelo skill: ele se adapta à convenção que já existe para notas, e se não houver nenhuma, escolhe um lugar sensato e te diz onde. Ele escreve um arquivo por execução.

## Perguntas frequentes

**Ele gerou um segundo agent de pesquisa. Isso deveria acontecer?**

Não. Este é um bug em aberto, [issue #530](https://github.com/mattpocock/skills/issues/530). O skill diz ao seu chamador para iniciar um agent de fundo, mas não restringe o tipo de agent, então o agent que ele gera é um `general-purpose` que detém a ferramenta `Agent` e as mesmas instruções, e as dispara novamente. Um relato mediu uma única tarefa de pesquisa custando cerca de 450k [tokens](https://www.aihero.dev/ai-coding-dictionary/token) em três execuções sobrepostas, com o duplicado terminando meia hora depois completamente fora de vista. Isso se reproduz fora do Claude Code também; o mesmo aninhamento foi confirmado no Codex com GPT-5.6-sol. Não há correção publicada. Usuários corrigiram sua própria cópia instalada com uma linha dizendo a um agent que já é um [subagent](https://www.aihero.dev/ai-coding-dictionary/subagent) para fazer o trabalho ele mesmo, o que ajuda mas é no nível de instrução, não estrutural. Monitore sua lista de tarefas de fundo após invocar, e pare o duplicado.

A falha oposta também existe: se suas instruções globais proíbem um agent de re-delegar trabalho, o agent de fundo vai educadamente recusar a tarefa e o skill silenciosamente não faz nada.

**Onde o arquivo deveria viver, e devo fazer commit?**

O skill coloca o arquivo onde o repo já mantém notas e não tem opinião além disso. A da comunidade é razoavelmente estabelecida: ADRs são mantidos, arquivos de pesquisa não. A versão mais direta, de uma thread do Discord sobre exatamente esta pergunta: "ADRs sim. Todo o resto archive ou delete depois de pronto. Caso contrário vira lixo de trabalho e pode envenenar leituras futuras do repo se você se afastou da spec/pesquisa." Um arquivo de pesquisa registra o que era verdade no dia em que foi escrito, então um desatualizado é pior que nenhum. No geral, esses artefatos realmente não pertencem ao git, e não há um local canônico para eles: pessoas usam Obsidian, um repo de conhecimento separado, ou o tracker de issues.

**O que conta como uma fonte primária de "alta confiança", e quem decide?**

O [model](https://www.aihero.dev/ai-coding-dictionary/model) decide. O skill nomeia os *tipos* de fonte que qualificam (documentação oficial, código-fonte, specs, APIs de primeira parte), e não há allowlist, nem gate de domínio, nem passo de verificação. Esta foi a objeção mais forte quando o skill foi proposto pela primeira vez e nunca foi respondida publicamente: "Cinco subagentes de pesquisa apontados para lixo só te dão cinco respostas erradas confiantes mais rápido. Como você controla o que conta como fontes de alta confiança?" A mitigação que você realmente tem é a citação em cada afirmação. Siga duas ou três delas. Se elas caírem em um resumo da coisa em vez da coisa, a execução falhou em seu único trabalho.

**Uma session posterior reutiliza o que uma execução anterior descobriu?**

Não. Nada carrega automaticamente um arquivo de pesquisa passado; é um documento no repo até que um humano ou skill aponte para ele. Isso foi levantado cedo como o maior desafio ao design: "o valor é o markdown se tornando contexto que o agent relê depois, não a busca em si. Um arquivo write-once morto é apenas uma busca elegante." O skill publicado não resolve isso. Na prática, o arquivo ganha sua manutenção ao ser alimentado no próximo passo deliberadamente: anexe-o a uma spec, cite-o em uma sessão de questionamento, aponte um [ticket](https://www.aihero.dev/ai-coding-dictionary/ticket) para ele.

**Por que não simplesmente pedir ao agent para ler a documentação?**

Você pode, e um prompt de duas linhas dizendo exatamente isso era a prática que este skill substituiu. Duas coisas que o skill ganha sobre o prompt: ele roda em segundo plano para que sua session mantenha seu [context](https://www.aihero.dev/ai-coding-dictionary/context) limpo, e a restrição de fonte primária e a saída do arquivo citado vêm da mesma forma cada vez em vez de como você aconteceu de frasear. Contra o modo de [harness](https://www.aihero.dev/ai-coding-dictionary/harness) de deep-research, a diferença é o artefato e a disciplina de fonte, não a busca. Se um prompt de duas linhas te dá o que precisa em uma pergunta pequena, use o prompt de duas linhas.

**Quando para de ler?**

Não há critério de parada no skill, e isso se manifesta como duas reclamações que parecem opostas mas são a mesma lacuna: agents que vão fundo demais, e agents que cobrem um tópico amplamente enquanto perdem o detalhe específico que importava. Um profissional resumiu como "skills de deep-research são às vezes profundas demais. E pedir a um agent para pesquisar geralmente resulta em perder detalhes cruciais." O escopo é por sua conta. Uma pergunta estreita e respondível (uma API, um comportamento, uma afirmação de versão) volta muito melhor do que "pesquise X".

**`/wayfinder` criou tickets de pesquisa. Resolvo esses eu mesmo?**

Não, agora ele os dispara para você. Nas mudanças não publicadas desde a v1.1, uma sessão de mapeamento gera um subagent `/research` por ticket de pesquisa e os consome em paralelo, capturando descobertas em um branch descartável `research/<name>` com um [context pointer](https://www.aihero.dev/ai-coding-dictionary/context-pointer) do ticket. Tickets de pesquisa são a única exceção à regra de um ticket por session do wayfinder, porque são [AFK](https://www.aihero.dev/ai-coding-dictionary/afk): nada espera por você. Dois problemas conhecidos com esses branches: o subagent já foi visto abrindo um draft PR de um branch que não deveria ser mergeado ([issue #576](https://github.com/mattpocock/skills/issues/576)), e deletar o branch depois quebra os context pointers que os tickets mantêm.

## Está funcionando se

- Sua própria session continua rodando. Se você está sentado assistindo ele ler, a delegação não aconteceu.
- Exatamente uma nova tarefa de fundo aparece. Uma segunda com nome quase idêntico é o bug de aninhamento.
- Um novo arquivo Markdown aparece, na pasta que o repo já usa para notas, e o agent te diz o caminho.
- Cada afirmação nele carrega um link, e seguir dois aleatoriamente te leva a uma documentação oficial, uma spec, ou o arquivo-fonte real, não ao relato de alguém.
- Você consegue tomar a decisão em que estava travado a partir do arquivo apenas, sem voltar às fontes você mesmo.

## Onde se encaixa

Um standalone que você usa a qualquer momento que alimenta as skills de pensamento em vez de ficar na cadeia de construção. Seu arquivo é algo para levar *para dentro* do fluxo: [grilling](https://aihero.dev/skills-grilling) e [grill-with-docs](https://aihero.dev/skills-grill-with-docs) fazem perguntas mais afiadas quando os fatos já estão na mesa, e [to-spec](https://aihero.dev/skills-to-spec) pode sintetizar contra ele. [wayfinder](https://aihero.dev/skills-wayfinder) é a única skill que o invoca diretamente, resolvendo cada ticket de pesquisa em seu mapa com um subagent `/research`. Para o mapa inteiro, veja [how-works](https://aihero.dev/skills-how-works).
