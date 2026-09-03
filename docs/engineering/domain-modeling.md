## O que faz

`domain-modeling` construi e aperfeiçoa a **língua ubíqua** de um projeto enquanto você está desenhando: desafia um termo que conflita com o glossário, força uma palavra precisa onde você usou uma vaga, e testa estresse em um relacionamento com um cenário concreto até que os limites sejam exatos.

É a disciplina **ativa**, não a passiva. Ler `CONTEXT.md` para emprestar seu vocabulário é um hábito de uma linha que qualquer skill pode fazer; esta skill é para quando você está *mudando* o modelo. É o que faz dela interrompente. Ela escreve um termo resolvido em `CONTEXT.md` no momento em que é resolvido, no meio da conversa, em vez de produzir um glossário organizado no final, porque a versão em lote é um resumo de uma [session](https://www.aihero.dev/ai-coding-dictionary/session), e a versão inline é a saída real da session.

## Quando usá-la

Digite `/domain-modeling`, ou o agente a usa automaticamente quando uma tarefa se encaixa. Na prática, a invocação automática é a parte mais fraca da skill: quando `grill-with-docs` ou `wayfinder` dizem para carregá-la, os [models](https://www.aihero.dev/ai-coding-dictionary/model) frequentemente carregam `grilling` e ignoram esta. Se uma session de [grilling](https://www.aihero.dev/ai-coding-dictionary/grilling) roda e `CONTEXT.md` está intocada no final, foi isso que aconteceu; invoque-a pelo nome junto com a outra skill.

Use-a quando as *palavras* são o problema:

| A situação | A ação |
| --- | --- |
| Duas pessoas entendem coisas diferentes por "cancellation" | `domain-modeling`: escolha o termo canônico, liste o outro sob `_Avoid_` |
| "Account" está fazendo três trabalhos em três arquivos | `domain-modeling`: divida em Customer e User |
| Você acabou de tomar uma escolha arquitetônica difícil de reverter | `domain-modeling`: ela oferece um ADR, se a escolha atender ao critério |
| A *forma* do módulo é o problema: onde vai a seam, o quão profunda a interface é | [codebase-design](https://aihero.dev/skills-codebase-design) |
| Você quer que todo o plano seja questionado antes de construir | [grill-with-docs](https://aihero.dev/skills-grill-with-docs), que conduz esta skill por baixo |
| Você quer que um termo seja consultado, não alterado | Nada. Leia `CONTEXT.md`. É um arquivo. |

## Pré-requisitos

Nenhum antecipadamente. A skill escreve em dois lugares e cria ambos preguiçosamente:

- **`CONTEXT.md`** na raiz do repositório, criada pelo primeiro termo resolvido. Em um repositório com um `CONTEXT-MAP.md` na raiz, os termos vão para o `CONTEXT.md` do contexto apontado pelo mapa.
- **`docs/adr/`**, criada pelo primeiro ADR que atende ao critério.

Nada precisa existir antes de você começar, e nada é criado especulativamente.

## Dois artefatos, dois critérios

O glossário e o ADR são mantidos a padrões diferentes, e confundi-los é de onde vem a maioria dos problemas nesta skill.

| | `CONTEXT.md` | `docs/adr/NNNN-slug.md` |
| --- | --- | --- |
| Contém | Termos. O que uma coisa **é**, em uma ou duas frases, com sinônimos rejeitados sob `_Avoid_` | Uma decisão, em uma a três frases: contexto, escolha, razão |
| Critério para escrever | Um termo vago se tornou canônico | **Todos os três**: difícil de reverter, surpreendente sem contexto, resultado de um trade-off real |
| Escrito | Inline, no momento em que o termo é decidido | Oferecido, não presumido |
| Nunca contém | Detalhes de implementação, uma [spec](https://www.aihero.dev/ai-coding-dictionary/spec), um rascunho, conceitos gerais de programação | Um diário de cada escolha feita nesta session |

Se qualquer um dos três testes do ADR falhar, não há ADR. Uma decisão facilmente reversível será simplesmente revertida; uma não surpreendente não é a pergunta de ninguém; uma sem alternativa real registra que você fez a coisa óbvia.

A regra de `CONTEXT.md` é a que vale realmente segurar, porque é a que quebra no campo. **É um glossário e nada mais.** Sem supervisão, modelos tratam "escreva em `CONTEXT.md`" como permissão para persistir toda resposta que você dá, e o arquivo se transforma em uma spec em execução. Esse é o problema mais reportado sobre a skill, em vários modelos.

## Referências cruzadas, e onde param

O movimento que faz a skill funcionar: quando você declara como algo funciona, ela verifica o código e traz à tona a contradição. *"Seu código cancela Pedidos inteiros, mas você acabou de dizer que cancelamento parcial é possível, qual está certo?"* A linguagem e o código são colocados em acordo, em voz alta, antes que qualquer um seja alterado.

O limite vale a pena conhecer. Ela faz referência cruzada ao **código** e ao `CONTEXT.md`/ADRs commitados, e nada mais. Ela não busca no seu issue tracker, então uma colisão de nomenclatura que foi discutida e deliberadamente resolvida em uma issue fechada meses atrás é trazida como se fosse nova. Há [um pedido aberto](https://github.com/mattpocock/skills/issues/717) para corrigir isso; até lá, a alternativa é colocar a instrução no seu próprio `docs/agents/domain.md`, que as skills já leem.

## Perguntas comuns

**Meu `CONTEXT.md` tem 500 linhas. 1.000. 3.000. O que eu faço?**
O tamanho é um sintoma, não a doença: o arquivo absorveu detalhes de implementação e decisões que nunca foram material de glossário. A correção é uma instrução direta: `/grill-with-docs make my CONTEXT.md more concise and remove any implementation details from it`. Execute-a contra um arquivo inchado e a maior parte vai embora. Só use um `CONTEXT-MAP.md` separado uma vez que o arquivo esteja genuinamente enxuto e ainda cubra dois domínios que um leitor não gostaria de reter ao mesmo tempo; dividir um arquivo inchado só lhe dá vários arquivos inchados. A orientação da skill aqui ainda não é forte o suficiente para prevenir o crescimento desde o início, e a issue rastreando isso ainda está aberta.

**Por que é `CONTEXT.md` e não `GLOSSARY.md`?**
Essa é a questão de nomenclatura mais debatida em todo o conjunto de skills e não tem uma resposta assentada. O argumento contra o nome atual é bom: se é "um glossário e nada mais", `GLOSSARY.md` diz isso, e, como um leitor colocou, "com agentes de IA tudo é [context](https://www.aihero.dev/ai-coding-dictionary/context)". O argumento a favor é o mapa: `CONTEXT-MAP.md` apontando para vários arquivos `CONTEXT.md` lê-se naturalmente de uma forma que `GLOSSARY-MAP.md` não, e `context` é a palavra DDD de longa data para uma área delimitada do modelo. Pelo menos uma pessoa mantém um fork local apenas para renomear o arquivo. Você pode fazer o mesmo, mas cada outra skill no conjunto procura por `CONTEXT.md`, então renomear significa corrigir todas.

**Onde foi parar `/ubiquitous-language`?**
Foi removida, e não foi descontinuada. Seu trabalho foi para dentro de `domain-modeling`, que mantém o modelo todo continuamente em vez de despejar um glossário de uma conversa. A aplicação do vocabulário ganhou mais peso, não menos: agora roda por baixo de grilling, triage e mapeamento em vez de ser uma passagem separada que você se lembra de fazer.

**Como eu obtenho um glossário para um codebase que não tem nenhum?**
Peça explicitamente em vez de esperar que ele se acumule. `/grill-with-docs help me scaffold my existing repo with a CONTEXT.md` é a rota documentada; espere um longo interrogatório: um usuário reportou 50+ perguntas antes que o arquivo estivesse na forma certa. Uso incidental constrói o glossário lentamente demais em um repo brownfield.

**Posso manter o domain model e usar meu próprio formato de ADR?**
Não de forma limpa hoje. A metade do glossário e a metade do ADR vêm em uma skill, então um time com uma convenção de ADR estabelecida (modelo diferente, local diferente, nomenclatura diferente) recebe instruções que conflitam com seu estilo interno. As opções atuais são copiar a skill localmente e editá-la, ou sobrescrever as convenções de ADR na documentação de agentes do seu próprio repositório. Separar as duas é [um pedido aberto](https://github.com/mattpocock/skills/issues/557).

**Um glossário realmente vale o esforço? É mais um artefato para revisar, e pode ficar obsoleto.**
Às vezes não vale, e vale a pena ser honesto sobre onde. DDD fica menos útil quanto mais perto da implementação: o retorno está a montante, no alinhamento de nomenclatura e conceitos, não em agregados e cerimônias de camada. Controle de sinônimos importa nas fronteiras de nomenclatura: nomes de módulos, nomes de tabelas, enums de status, títulos de issues, comandos de CLI. Importa muito menos em texto corrido. Há também uma objeção viva de que termos de domínio comprimem a comunicação *entre humanos* que já os compartilham, e que um agente responde da mesma forma à descrição em inglês simples. Nessa leitura, o valor do glossário é manter você e seus revisores alinhados com o que o agente está fazendo, não tornar o agente melhor. Em uma construção de um dia, ignore-o. E um glossário não revisado, escrito por agente, é pior que nenhum: ele se torna uma lore que soa confiante que sessions subsequentes tratam como verdade.

**Ela pode transformar meus prompts vagos em linguagem de domínio por mim?**
Não, e não há plano para uma skill que faça isso. Uma linguagem de domínio que você não entende por si se torna babado sem sentido uma vez escrita. Esta skill aplica precisão quando você tem o entendimento; ela não fabrica vocabulário que você não tem. A armadilha relacionada é usar palavras de domínio sem fazer o modelagem: substantivos certos sobre uma estrutura conceitual errada produzem saída que lê corretamente e não é.

## Está funcionando se

- Ela interrompe você no meio de uma frase para perguntar qual das duas coisas você quis dizer, em vez de escolher uma e seguir em frente.
- `CONTEXT.md` muda **durante** a conversa, não em uma rajada no final.
- Ela se recusa a escrever um ADR para algo que você poderia desfazer amanhã, e diz qual dos três testes falhou.
- Novas entradas definem o que uma coisa *é* em uma ou duas frases e nomeiam as palavras que você está abandonando sob `_Avoid_`.
- Ela cita seu código de volta quando seu código e sua frase discordam.
- `CONTEXT.md` fica menor tantas vezes quanto fica maior.

## Onde se encaixa

`domain-modeling` é uma **referência model-invoked** que roda *por baixo* de outras skills mais frequentemente do que roda sozinha. [grill-with-docs](https://aihero.dev/skills-grill-with-docs) a conduz através de uma session de grilling, [wayfinder](https://aihero.dev/skills-wayfinder) a carrega enquanto traça um mapa, [triage](https://aihero.dev/skills-triage) a usa para manter [tickets](https://www.aihero.dev/ai-coding-dictionary/ticket) nas próprias palavras do projeto, e [improve-codebase-architecture](https://aihero.dev/skills-improve-codebase-architecture) a chama quando decisões se cristalizam. Seu parente mais próximo é [codebase-design](https://aihero.dev/skills-codebase-design): as duas são a camada de vocabulário sob tudo mais, esta para o *domínio*, aquela para a *forma* do módulo. Ela também é acessível diretamente, quando você quer a disciplina sem se comprometer com os passos de qualquer skill que normalmente a puxaria. Quando não tem certeza de qual skill se encaixa, [how-works](https://aihero.dev/skills-how-works) te direciona.
