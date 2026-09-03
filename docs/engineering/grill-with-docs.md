## O que faz

`grill-with-docs` entrevista você sobre um plano ou design até que você e o [agent](https://www.aihero.dev/ai-coding-dictionary/agent) compartilhem um entendimento dele, e escreve o vocabulário e as decisões difíceis no seu repositório enquanto faz isso. É a mesma entrevista que [grill-me](https://aihero.dev/skills-grill-me) roda (um rodada de perguntas, depois espera, depois a próxima rodada), apontada para um codebase.

Ela é **[stateful](https://www.aihero.dev/ai-coding-dictionary/stateful)**. Toda outra skill de grilling deixa a [session](https://www.aihero.dev/ai-coding-dictionary/session) na sua cabeça; esta deixa arquivos no disco. Um termo é resolvido e chega em `CONTEXT.md` no momento em que é resolvido, não em lote no final. Uma decisão passa três gates e chega como um ADR. Essa é toda a diferença, e também é a fonte da maioria dos problemas que pessoas têm com a skill: os artefatos são arquivos reais em um repositório real, então podem estar ausentes quando você os esperava, e podem se deslocar quando mais de uma pessoa os escreve.

## Quando usá-la

Você invoca esta digitando `/grill-with-docs`; o agente não a usa por conta própria.

Use-a no início de uma alteração, em um repositório, quando o plano ainda é vago e as palavras para a coisa ainda não foram decididas. É a ferramenta de session única. Qual skill de grilling você quer depende do que está na sua frente:

| O que você tem | Use |
| --- | --- |
| Você não está trabalhando em um diretório de trabalho | [grill-me](https://aihero.dev/skills-grill-me) |
| Um repositório, e uma alteração que pode ser decidida em uma session | `grill-with-docs` |
| Um esforço grande demais para caber em uma session (uma construção greenfield, uma feature grande) | [wayfinder](https://aihero.dev/skills-wayfinder) |
| Um repositório sem documentação de domínio, e nenhuma feature específica em mente | `grill-with-docs`, apontada para o repositório em vez de uma alteração |
| Uma decisão bloqueada em conhecimento na cabeça de outra pessoa | [to-questionnaire](https://aihero.dev/skills-to-questionnaire) |

A divisão com wayfinder se resume à contagem de sessões: `/grill-with-docs` para planejamento de session única, `/wayfinder` para planejamento multi-session.

## Pré-requisitos

A skill escreve no seu repositório, então você precisa estar em um lugar seguro para escrever. Termos resolvidos vão para um glossário `CONTEXT.md` na raiz, ou para o `CONTEXT.md` do contexto relevante, se um `CONTEXT-MAP.md` na raiz marca o repositório como multi-contexto. Decisões vão para `docs/adr/`. Ambos são criados preguiçosamente; nada existe até que o primeiro termo ou decisão se cristalize, então não há nada para scaffold antecipadamente.

Ela também precisa de duas outras skills presentes, porque sua própria `SKILL.md` é uma linha que delega para elas: [grilling](https://aihero.dev/skills-grilling) fornece a entrevista, [domain-modeling](https://www.aihero.dev/skills-domain-modeling) fornece a escrita. Instalar `grill-with-docs` sozinha lhe dá uma skill que não funciona.

## O rastro de papel

Três coisas saem de uma session, e elas não são iguais.

| O que foi resolvido | Onde chega |
| --- | --- |
| Um termo: a própria palavra do projeto para uma coisa | `CONTEXT.md`, inline, no momento em que é resolvido |
| Uma decisão difícil de reverter, surpreendente sem contexto, e um trade-off real | Um ADR em `docs/adr/` |
| Tudo o mais que você decidiu | A conversa, e mais nada |

A terceira linha é a que pega as pessoas. `CONTEXT.md` é um glossário e é deliberadamente mantido como um: sem detalhes de implementação, sem [spec](https://www.aihero.dev/ai-coding-dictionary/spec), sem notas de rascunho. ADRs são gated nas três condições ao mesmo tempo, então a maioria das decisões não qualifica e a maioria das sessões não produz nenhuma. Uma session que produz um glossário mais apurado e zero ADRs está funcionando como projetado, mas significa que a maior parte do que você concordou existe apenas na [context window](https://www.aihero.dev/ai-coding-dictionary/context-window) em que concordou. Passe essa mesma conversa para [to-spec](https://aihero.dev/skills-to-spec) em vez de [clearing](https://www.aihero.dev/ai-coding-dictionary/clearing) ela.

O glossário é o ponto. Linguagem de domínio é o que esta skill realmente constrói: as próprias palavras do projeto, acordadas uma vez, para que você, o agente e seus colegas parem de pagar para rederivá-las. Vale dizer que nem todos concordam que isso lhe dá desempenho de agente: a objeção pública mais nítida é que um termo e sua expansão em inglês simples dão o mesmo resultado do [model](https://www.aihero.dev/ai-coding-dictionary/model), e que o vocabulário realmente comprime a comunicação entre os humanos que o compartilham. Essa leitura ainda deixa o glossário valioso; apenas move o valor.

## Perguntas comuns

**Devo usar esta ou `/wayfinder`?**
Escopo decide. Use esta para qualquer coisa que possa ser decidida em uma session; use [wayfinder](https://aihero.dev/skills-wayfinder) quando o esforço é grande demais para caber em uma, e ela traça o trabalho como um mapa de [tickets](https://www.aihero.dev/ai-coding-dictionary/ticket) de decisão primeiro. Wayfinder é mais lenta e densa, e usá-la em uma feature bem delimitada é o erro comum. Ela não substitui esta skill: ela pode cair em uma session de grilling para as partes do mapa que se encaixam.

**Ela rodou, mas nenhum `CONTEXT.md` e nenhum ADR apareceram.**
Duas causas conhecidas. A mundana: nada qualificou. ADRs precisam dos três gates, e uma session sobre uma alteração sem novo vocabulário genuinamente não tem nada para escrever. O bug real: quando a skill roda dentro de outra camada de orquestração (um wrapper de spec-driven-development, um framework multi-agent, uma regra que a invoca como passo no pipeline de outra pessoa), a metade de escrita de arquivos é reportada como silenciosamente não acontecendo, enquanto a entrevista continua rodando. Isso está registrado e não corrigido. Se você está nessa configuração, verifique o diretório de trabalho antes de confiar na saída da session.

**Ela perguntou tudo de uma vez, sem recomendações, e nunca mencionou `CONTEXT.md`.**
Isso é a skill falhando em carregar suas duas dependências. Porque `SKILL.md` é uma delegação de uma linha, um agente que não pega [grilling](https://aihero.dev/skills-grilling) e [domain-modeling](https://www.aihero.dev/skills-domain-modeling) adivinha o que grilling significa, e você recebe um despejo indiferenciado de perguntas. Carregamento parcial é o caso mais confuso: `grilling` carrega, `domain-modeling` não, e você recebe uma boa entrevista sem rastro de papel. Isso se correlaciona com o modelo e o nível de [effort](https://www.aihero.dev/ai-coding-dictionary/effort), e é o problema mais reportado sobre esta skill. Se você suspeita disso, pergunte diretamente ao agente quais skills ele carregou.

**Onde foram parar todas as minhas outras decisões?**
Apenas na conversa. Essa é a reclamação aberta mais substantiva sobre a skill: o glossário não é uma spec, a maioria das respostas não merece um ADR, e não há um livro-razo ligando cada resposta resolvida até uma spec, um ticket e um teste. Respostas precisas (garantias de ordenação, requisitos negativos, padrões numéricos) são suavizadas em texto mais fraco abaixo, e o resultado pode parecer completo enquanto falta o que você realmente decidiu. A mitigação disponível hoje é manter a session e passá-la direto para [to-spec](https://aihero.dev/skills-to-spec), e reler a spec contra suas próprias respostas em vez de presumir que ela as capturou.

**Posso apontá-la para um repositório existente que não tem nenhuma documentação?**
Sim. Esta é a skill certa para um codebase sem ADRs, sem linguagem de domínio e sem princípios de design: invoque-a e diga "ajude-me a documentar meu repositório". O padrão da comunidade a combina com [improve-codebase-architecture](https://aihero.dev/skills-improve-codebase-architecture) para construir ou reparar um `CONTEXT.md`. Espere guiá-la: ela vai ler código e perguntar sobre o que encontrar, e você é quem diz quais das palavras já no codebase são as certas.

**O que devo fazer quando a session termina?**
A mensagem de fechamento da skill tende a ser aberta, o que é uma aspereza conhecida. No fluxo principal a resposta é [to-spec](https://aihero.dev/skills-to-spec), na mesma conversa. Se a alteração for pequena o suficiente para construir imediatamente, vá direto para [implement](https://aihero.dev/skills-implement).

**Por que tem esse nome?**
Ninguém está feliz com o nome. Há uma sugestão aberta para renomeá-la `grill-domain-model`, que descreve o comportamento mais honestamente. Nada aconteceu com isso. Se uma renomeação acontecer, a página de documentação se move com ela e a URL muda.

## Está funcionando se

- `CONTEXT.md` muda *durante* a session, termo por termo, em vez de aparecer em um bloco no final.
- O glossário lê-se como puro vocabulário (as palavras do seu projeto com definições rigorosas) e contém nenhum detalhe de implementação ou texto de spec.
- Perguntas que o codebase pode responder são respondidas lendo o codebase, não perguntadas a você.
- Você recebe poucos ou nenhum ADR, e os que recebe são decisões que você ficaria irritado em ter que relitigar.
- Ela desafia uma palavra que você usou porque seu glossário existente a define de forma diferente.

## Onde se encaixa

`grill-with-docs` é a cabeça da cadeia principal de construção:

```txt
grill-with-docs → to-spec → to-tickets → implement → code-review
```

Ela vem antes que qualquer coisa seja escrita como spec: ela produz o entendimento compartilhado e o vocabulário decidido que [to-spec](https://aihero.dev/skills-to-spec) depois sintetiza sem entrevistar você novamente. Seus vizinhos próximos são [grill-me](https://aihero.dev/skills-grill-me), a mesma entrevista sem repositório e sem arquivos, e [domain-modeling](https://www.aihero.dev/skills-domain-modeling), a disciplina de glossário-que-ela-conduz; ambas ficam na primitiva [grilling](https://www.aihero.dev/skills-grilling). A montante, [wayfinder](https://www.aihero.dev/skills-wayfinder) traça esforços grandes demais para uma session e pode repassar partes do mapa de volta para ela. Quando não tem certeza de qual skill ou fluxo se encaixa, [how-works](https://aihero.dev/skills-how-works) te direciona.
