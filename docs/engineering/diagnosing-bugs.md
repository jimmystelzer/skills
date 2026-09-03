## O que faz

`diagnosing-bugs` roda um diagnóstico de seis fases em um bug difícil ou uma regressão de desempenho: constrói uma reprodução, a minimiza, ordena hipóteses, instrumenta, corrige com um teste de regressão, e limpa.

Ela não permite que o agente forme uma teoria até que exista um loop de feedback **tight**: um comando nomeado, já executado uma vez, que fica vermelho com *este* bug e verde quando ele é corrigido. O comportamento padrão de um agente de código recebendo um relatório de bug é ler código e adivinhar; esta skill bloqueia isso. Se não existe nenhum comando que possa ficar vermelho, não há Fase 2. Esse único gate é o motivo da skill existir. Tudo depois disso (bissecção, teste de hipóteses, instrumentação) é mecânico uma vez que o sinal existe.

## Quando usá-la

Digite `/diagnosing-bugs`, ou o agente a usa por conta própria quando uma tarefa se encaixa: ela é model-invoked e dispara em "diagnose" / "debug this" ou em um relatório de que algo está quebrado, lançando exceções, falhando ou lento.

Use-a nos casos difíceis: um bug que resiste a uma primeira olhada, uma intermitência intermitente, uma regressão que se infiltrou entre dois estados conhecidos-bons. Ela é pesada por design, e a ferramenta errada para uma pergunta que você quer respondida em uma mensagem.

| Sua situação | Onde ir |
| --- | --- |
| Um defeito específico que você pode descrever como um sintoma | Esta skill |
| Um endpoint lento ou uma regressão de timing com um antes-e-depois conhecido | Esta skill: ela tem um branch de desempenho (medir uma linha de base, depois bisseccionar) |
| "Onde estão os gargalos neste codebase?", sem sintoma específico | Não esta skill. Ela diagnostica uma falha conhecida, não audita |
| Um relatório de bug bruto de outra pessoa, ainda não confirmado ou documentado | [triage](https://aihero.dev/skills-triage) primeiro |
| Código descartável para responder uma questão de design, não perseguir um defeito | [prototype](https://www.aihero.dev/skills-prototype) |
| Construir um teste planejado test-first | [tdd](https://aihero.dev/skills-tdd) |
| Não existe uma boa seam para isolar o bug | [improve-codebase-architecture](https://aihero.dev/skills-improve-codebase-architecture): esta skill encaminha para lá |

## O tight loop é a skill

A Fase 1 recebe um esforço desproporcional porque é a única fase que é difícil. A skill oferece uma escada de formas de construir o loop, aproximadamente em ordem de preferência:

1. Um teste falhando em qualquer seam que alcance o bug.
2. Um script curl ou HTTP contra um servidor de desenvolvimento rodando.
3. Uma invocação de CLI com um input de fixture, comparada contra um snapshot conhecido-bom.
4. Um script de headless browser verificando DOM, console ou rede.
5. Uma replay de captura: uma requisição, payload ou log de eventos salvo, rodado pelo caminho de código isoladamente.
6. Um harness descartável: um subconjunto mínimo do sistema, uma chamada de função.
7. Um property ou fuzz loop, para "saída às vezes errada".
8. Um harness de bissecção que você pode passar para `git bisect run`.
9. Um loop diferencial: mesmo input, versão antiga versus nova.
10. Um script bash [human-in-the-loop](https://www.aihero.dev/ai-coding-dictionary/human-in-the-loop), último recurso. A skill entrega `scripts/hitl-loop.template.sh` para isso: o agente roda o script, você segue os prompts no seu terminal, e suas respostas voltam como output parseável.

*Um* loop não é o objetivo. **Tight** é: rápido (segundos), determinístico (mesmo veredito toda execução), nítido (verifica seu sintoma exato, não "não crashou"), e executável pelo agente sem supervisão. Um loop instável de 30 segundos é pouco melhor que nada. Para um bug que só aparece às vezes, o objetivo não é uma reprodução limpa, mas uma **taxa de reprodução mais alta**: looping o gatilho, paralelizando, adicionando estresse, injetando sleeps, até a taxa de instabilidade ser alta o suficiente para depurar.

Quando ela genuinely não consegue construir um, ela é instruída a parar e dizer isso, listar o que tentou, e pedir acesso ao seu [environment](https://www.aihero.dev/ai-coding-dictionary/environment), um artefato capturado, ou permissão para adicionar instrumentação temporária. Ela não deveria prosseguir para hipotetizar de qualquer forma.

## Os gates entre as fases

As fases são gates, não uma checklist. Cada uma se recusa a abrir até que algo específico seja verdade.

| Gate | O que precisa ser verdade |
| --- | --- |
| Para a Fase 2 | Um comando nomeado, já executado e colado com sua saída, que pode ficar vermelho com este bug |
| Para a Fase 3 | A reprodução é reproduzida *e* minimizada: cada elemento restante é load-bearing |
| Para a Fase 4 | 3–5 hipóteses ordenadas, falsificáveis, existem, cada uma afirmando sua previsão, mostradas a você antes que qualquer uma seja testada |
| Para a Fase 5 | Sondas mapeiam para uma previsão específica, uma variável por vez, cada log de debug marcada com estilo `[DEBUG-a4f2]` para que a limpeza seja um grep |
| Concluído | A reprodução original não mais reproduz, instrumentação removida, e a hipótese que se revelou correta é escrita na mensagem do commit |

A Fase 5 tem uma saída de emergência que vale a pena conhecer. O teste de regressão é escrito antes da correção, mas apenas se existe uma **seam correta** para ele: uma onde o teste exercita o padrão real do bug conforme ele ocorre no local da chamada. Onde a seam disponível é muito superficial, a skill é instruída a dizer isso em vez de escrever um teste que dá falsa confiança. Essa ausência é em si o achado, e é o que direciona o post-mortem para `improve-codebase-architecture`.

## Perguntas comuns

**Ela dispara em perguntas rápidas onde eu só queria uma resposta direta.**
Esse é o problema mais reportado sobre a skill, e é real. Especialmente no GPT-5.6-Sol, usuários reportam que ela dispara com uma descrição simples de um problema: "o modelo dispara a skill formal diagnosing-bugs em vez disso. Então continua construindo um cenário de reprodução (frequentemente criando um cenário mock com valor limitado) antes de me dar uma resposta ou sugestão. Isso resulta em atrasos consideráveis na resposta." Quatro pessoas separadas reportaram o mesmo formato na [issue #578](https://github.com/mattpocock/skills/issues/578). A correção aceita é começar com uma abordagem mais leve e graduar para a mais pesada apenas quando o problema justificar, mas essa alteração não foi entregue. A skill é calibrada contra o comportamento de invocação do Claude Code; um [model](https://www.aihero.dev/ai-coding-dictionary/model) com um limiar de ativação mais baixo a dispara em excesso. Até ser graduada, a correção prática é dizer o que você quer ("apenas responda isso, não diagnostique") ou desabilitar a invocação de model para ela no seu [harness](https://www.aihero.dev/ai-coding-dictionary/harness).

**Posso apontá-la para um codebase e perguntar onde estão os problemas de desempenho?**
Não. Ela diagnostica uma falha que você já pode nomear. Seu branch de desempenho é para uma regressão com um sintoma (estabelecer uma medição de linha de base, depois bisseccionar, medir primeiro e corrigir depois), não para uma varredura proativa. Uma skill para a versão proativa foi [proposta e fechada](https://github.com/mattpocock/skills/issues/431); atualmente não há skill para isso.

**Ela para e me pergunta antes de escrever a correção?**
Não. Apenas a Fase 3 tem um checkpoint humano: a lista de hipóteses ordenadas é mostrada a você antes que qualquer uma seja testada, e ela prossegue com sua própria ordenação se você estiver ausente. Não há gate entre instrumentação e correção, então o agente pode começar a escrever código antes que você concorde com sua causa raiz. A [Issue #124](https://github.com/mattpocock/skills/issues/124) pede esse gate e ainda está aberta. Se você quer ele, diga isso quando invocar a skill.

**Eu já executei `/triage` neste relatório de bug. É o mesmo trabalho de novo?**
Parcialmente, e nenhuma skill admite isso. Como um leitor colocou: "O passo 3 do Triage é essencialmente uma instância superficial e delimitada da Fase 1–2 do diagnosing-bugs, mas nenhum arquivo menciona o outro." Triage faz uma passagem delimitada "isso é realmente um bug, e qual é a superfície"; esta skill faz a versão completa. Rodar triage primeiro não é desperdício (sua verificação frequentemente dá a maior parte do material bruto da Fase 1), mas espere refazê-la aqui adequadamente, e espere nenhuma referência cruzada para lhe dizer isso.

**A saída da reprodução que ela cola pode vazar secrets?**
Pode. A skill pede ao agente para colar a invocação e sua saída, e para solicitar artefatos como arquivos HAR, dumps de log e core dumps. Nenhum desses é sanitizado por instrução. A [Issue #674](https://github.com/mattpocock/skills/issues/674) levanta exatamente isso (credenciais, tokens, cookies e dados pessoais indo junto para um chat, uma issue ou um PR) e propõe um guardrail de redação. Está aberta e não implementada. Trate a redação como sua responsabilidade por enquanto, particularmente antes que a saída vá para qualquer lugar público.

**Meu scanner de segurança sinalizou esta skill como de alto risco.**
O Snyk sinaliza, e a sinalização é um falso positivo. É a única skill do conjunto que entrega um script shell executável (`hitl-loop.template.sh`) junto com instruções para rodá-lo e fazer curl em um servidor de desenvolvimento. Um `.sh` entregue mais instruções de execução mais HTTP de saída é suficiente para acionar um scanner estático. O script em si tem cerca de 30 linhas de prompts `read -r -p` que pausam para input humano. O scanner está avaliando a superfície de capacidade, não uma exploração comprovada.

**O que aconteceu com `/diagnose`?**
Renomeada para `/diagnosing-bugs` na v1.0.0. O nome antigo não existe mais. Qualquer coisa sua que encadeia `/diagnose` (uma skill wrapper, um prompt salvo) precisa ser atualizada.

## Está funcionando se

- Ela mostra um comando e sua saída vermelha antes de oferecer uma única teoria. Se a teoria chega primeiro, a skill não está rodando.
- A falha que ela reproduz é a que você reportou, não uma próxima que encontrou no caminho.
- Ela minimiza a reprodução antes de começar a adivinhar, e pode dizer por que cada peça restante é load-bearing.
- Você recebe uma lista ordenada de 3–5 hipóteses, cada uma com uma previsão que você poderia falsificar, antes que qualquer uma seja testada.
- Cada log de debug que ela adiciona carrega uma tag como `[DEBUG-a4f2]`, e um grep por essa tag volta vazio quando ela declara concluído.
- A mensagem do commit ou PR nomeia qual hipótese estava correta.
- Quando ela não consegue isolar o bug com um teste, ela diz isso claramente em vez de escrever um superficial.

## Onde se encaixa

`diagnosing-bugs` é um standalone para usar a qualquer momento. Você entra nela quando algo está quebrado e sai quando a correção e seu teste de regressão estão prontos; ela não mantém estado e não precisa de configuração prévia. [how-works](https://aihero.dev/skills-how-works) direciona "Algo está quebrado" para cá.

Duas vizinhas são importantes. [improve-codebase-architecture](https://aihero.dev/skills-improve-codebase-architecture) recebe o [handoff](https://www.aihero.dev/ai-coding-dictionary/handoff) quando o achado real é que o código não tem uma seam para isolar o bug; a recomendação é feita depois que a correção está implementada, quando há mais informação. [triage](https://aihero.dev/skills-triage) fica a montante para bugs que chegam como relatórios brutos de outras pessoas, e faz uma versão mais superficial das mesmas duas primeiras fases.
