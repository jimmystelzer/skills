## O que faz

`to-questionnaire` transforma uma decisão que você não pode resolver sozinho em um **questionário**: um documento Markdown que você passa para a pessoa que detém o que você está faltando, para que preencha de forma assíncrona ou para que ambos trabalhem juntos em uma reunião.

Ele te entrevista sobre o **envio**, nunca sobre o assunto. Entrevistar você sobre o tópico é inútil aqui: não saber o tópico é por que você está escrevendo para outra pessoa. Então ele pergunta as duas coisas que você sempre pode responder (para quem vai, e o que precisa de volta) e direciona cada pergunta no documento para a **lacuna** entre as duas.

## Quando usar

Você invoca isso digitando `/to-questionnaire`; o [agent](https://www.aihero.dev/ai-coding-dictionary/agent) não busca por conta própria.

Busque quando uma decisão está bloqueada por conhecimento que vive na cabeça de outra pessoa: um cliente, um especialista de domínio, um executivo que possui as regras de negócio, um colega em uma equipe com a qual você não trabalha. Qual skill você quer depende de onde as respostas realmente estão:

| As respostas estão em... | Busque por |
| --- | --- |
| Sua própria cabeça, não refinada | [grill-me](https://aihero.dev/skills-grill-me) |
| O codebase | [grill-with-docs](https://aihero.dev/skills-grill-with-docs) |
| A cabeça de outra pessoa | `to-questionnaire` |
| Ninguém ainda, a pergunta precisa de algo para reagir | [prototype](https://aihero.dev/skills-prototype) |

O caso comum é uma session de [grilling](https://www.aihero.dev/ai-coding-dictionary/grilling) que trava: algo que surgiu não é sua responsabilidade resolver. Execute `/to-questionnaire` naquela mesma conversa para tirar aquelas perguntas do caminho, depois traga as respostas de volta e continue.

## O envio, não o assunto

A entrevista são dois intercâmbios, e depois para.

- **Para quem vai?** O papel deles, a expertise deles, o relacionamento deles com você. Isso fixa o tom e quanto contexto o documento precisa carregar: um cliente externo precisa de orientação, um colega de equipe não.
- **O que você precisa de volta?** As decisões ou fatos concretos que você não pode resolver sozinho. Isso se torna a checklist contra a qual o documento final é medido: cada item que você nomeou recebe uma pergunta direcionada.

Tudo depois disso é rascunho. O arquivo cai em `to-questionnaire-<slug>.md` no diretório atual. Não há configuração, não há workspace, e nada a configurar.

## O documento

Ele é estruturado como um **questionário de descoberta** (você falta o contexto, o destinatário o possui), e essa estruturação direciona sua forma:

- Uma linha de propósito nomeando a decisão pendente, e uma breve seção de contexto para um destinatário que nunca esteve na sua cabeça.
- Perguntas ordenadas **mais-importante-primeiro** e agrupadas sob cabeçalhos temáticos, porque assíncrono significa que você pode obter apenas uma passagem.
- Uma ideia por pergunta, nunca composta, com um rascunho de resposta abaixo e uma linha de *por que isso importa* apenas onde uma pergunta pode ser mal interpretada.
- Permissão explícita para responder "não sei": uma incerteza sinalizada é útil; um palpite confiante que se lê como fato não é.
- Um encerramento abrangente: algo que não perguntamos e deveríamos saber?

Duas coisas que ele deliberadamente não é. Não é **ramificado**: as perguntas são uma lista plana e agrupada, não uma árvore que pula a seção D se você respondeu a A. E não é **multi-destinatário**: uma execução produz um documento para uma pessoa.

## Perguntas frequentes

**Ele lê minha session de grilling e extrai as perguntas dela?**
Não como etapa própria. A skill não tem fase de ingestão: pergunta sobre o envio, depois rascunha. O que faz funcionar após uma session de grilling é que você a executa na **mesma conversa**, então a [session](https://www.aihero.dev/ai-coding-dictionary/session) já está em [context](https://www.aihero.dev/ai-coding-dictionary/context) e o rascunho pode se basear nela. Comece em uma session fresca e ele não sabe nada sobre o grilling; você vai estar re-abastecendo o tópico quando responder "o que você precisa de volta?".

**As respostas faltantes não estão todas com a mesma pessoa. Ele pode dividir por destinatário?**
Não. O passo um pede *o* destinatário, no singular, e o tom e contexto de todo o documento são direcionados a eles. Se três pessoas detêm três partes da resposta, execute três vezes, uma por pessoa. Roteamento de perguntas por disciplina ou papel dentro de um único documento é um pedido que pessoas fizeram; não é o que foi lançado.

**As perguntas são dependentes: ele pula seções baseado em respostas anteriores?**
Não. O design de perguntas dependentes foi explorado e não foi lançado. A saída é um documento estático: grupos temáticos, mais-importante-primeiro, cada pergunta ativa. A objeção contra isso é justa: um [model](https://www.aihero.dev/ai-coding-dictionary/model) planejando mais de duas ou três perguntas à frente de uma resposta real planeja mal, e um documento ramificado tem que planejar todas à frente de cada resposta.

**E se o destinatário também não souber?**
O documento diz para eles dizer isso. "Não sei" e respostas parciais são pedidas explicitamente, e uma incerteza sinalizada vale mais do que um palpite, porque uma resposta vaga e uma incorreta confiante parecem idênticas uma vez que voltam ao seu context.

**Ele envia para algum lugar (Slack, um issue tracker, email)?**
Não. Ele escreve um arquivo Markdown no diretório atual e diz o caminho. Entrega é sua: cole em um [ticket](https://www.aihero.dev/ai-coding-dictionary/ticket), solte em um thread do Slack, anexe a um email, ou abra em uma tela compartilhada e trabalhe ao vivo. Pessoas já montaram os quatro manualmente.

**Isso não é apenas `/grill-me` em modo batch?**
Não, e a distinção vale manter. `grilling-me` já pergunta em **rodadas**: a fronteira inteira de uma vez, depois recalculada das suas respostas, então a necessidade de "me dê todas as perguntas de uma vez" é atendida lá. `to-questionnaire` é sobre um eixo diferente: não como as perguntas são entregues, mas de quem é a cabeça das respostas. Respondê-las você mesmo mais rápido é `grill-me`; tirá-las de outra pessoa é isso.

**Não poderia simplesmente pedir ao agent isso sem uma skill?**
Sim, e muitas pessoas faziam antes que existisse: arquivos `OPEN_QUESTIONS.md`, planilhas enviadas a clientes, um ticket "precisa de mais info" por pergunta não respondida. A skill oferece duas coisas: a entrevista nunca derivar para o assunto, e o documento sair em uma forma que um destinatário não-técnico pode realmente preencher. Se você já tem um formato interno que funciona, a resposta honesta é que você não precisa disso.

## Está funcionando se

- Ele pergunta sobre o destinatário e sobre o que você precisa de volta, depois para de perguntar. Uma pergunta sobre o assunto em si é a skill fora dos trilhos.
- Cada item que você nomeou como "o que preciso de volta" é rastreável a uma pergunta no arquivo.
- As perguntas se leem como direcionadas ao que o *destinatário* sabe, não como suas próprias perguntas abertas copiadas textualmente.
- Você poderia passar o arquivo para alguém que não estava na conversa e eles saberiam por que o receberam e até quando responder.
- As respostas que voltam são input utilizável para uma nova rodada de grilling, em vez de um conjunto novo de perguntas.

## Onde se encaixa

`to-questionnaire` é uma standalone para buscar a qualquer momento. Sita na fronteira do seu próprio conhecimento, onde o próximo movimento é outra pessoa em vez de outra skill, mais frequentemente no meio do fluxo, quando o planejamento travou em algo que não é sua responsabilidade decidir.

Seu vizinho é [grill-me](https://aihero.dev/skills-grill-me), e os dois se separam em onde as respostas vivem: grilling minera você, um questionário minera outra pessoa. O que volta é matéria-prima: alimente em outra rodada de grilling, ou em [grill-with-docs](https://aihero.dev/skills-grill-with-docs) ou [to-spec](https://aihero.dev/skills-to-spec) se o trabalho estiver indo para construção. Quando não tem certeza qual skill se encaixa no momento, [how-works](https://aihero.dev/skills-how-works) o direciona.
