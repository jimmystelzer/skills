## O que faz

`handoff` compacta a conversa em que você está em um **documento de handoff**: um arquivo markdown, escrito no diretório temporário do seu OS em vez do workspace, que um [agent](https://www.aihero.dev/ai-coding-dictionary/agent) fresco pode ler para retomar o trabalho.

O que ele oferece é **portabilidade**, não compressão. Isso torna a skill mais estreita do que parece. Você só precisa de um arquivo quando o trabalho tem que *viajar*: para um novo [harness](https://www.aihero.dev/ai-coding-dictionary/harness), um novo diretório, um colega, ou uma tarefa paralela que você quer bifurcar. Se nada está viajando, você não precisa de um handoff: ficar na [session](https://www.aihero.dev/ai-coding-dictionary/session), `/clear`, um [subagent](https://www.aihero.dev/ai-coding-dictionary/subagent) e `/compact` cobrem o caso comum de fim de fase, e `/compact` cobre mais frequentemente do que esta skill.

## Quando usar

Você invoca isso digitando `/handoff`; o agent não busca por conta própria. Passe uma nota sobre para que serve a próxima session, e o documento é escrito para ela.

Situações são todo o gatilho:

| Situação | Por que um arquivo |
| --- | --- |
| Trocando de harness (Claude → Codex) | O novo harness não consegue ver o [context](https://www.aihero.dev/ai-coding-dictionary/context) antigo |
| Mudando para um diretório ou repo diferente | Um diretório de protótipo é o caso comum |
| Enviando o trabalho para um colega | Eles precisam de algo que possam ler |
| Bifurcando uma tarefa paralela encontrada no meio da fase | Você continua trabalhando; um segundo agent assume a bifurcação |

Para qualquer outra coisa (mesmo harness, mesmo diretório, você terminou de [grillar](https://www.aihero.dev/ai-coding-dictionary/grilling) e está passando para implementação), `/compact` é a jogada. [how-works](https://aihero.dev/skills-how-works) carrega a árvore ordenada sobre todas as cinco opções em uma fronteira de fase.

## Bifurcar é o uso que as pessoas ignoram

A descrição da skill parece retomada de session: escreva um resumo, termine aqui, retome ali. Lida assim, parece um `/compact` pior, então é pulada. O caso de bifurcação é o que vale conhecer. Você **fica na sua session** e passa uma cópia do context acumulado para um segundo agent trabalhando em paralelo.

É isso que o desvio por [prototype](https://aihero.dev/skills-prototype) usa. Você está fundo em uma conversa de design, encontra uma pergunta que apenas código rodando resolve, e não quer gastar o fio que construiu para descobrir. Faça handoff para uma session de protótipo, obtenha a resposta, passe a resposta de volta, e referencie-a da thread original. Dois cruzamentos, uma conversa ativa, nada re-explicado.

Três das cinco opções em uma fronteira de fase preservam coisas diferentes: `/compact` preserva sua intenção, `/clear` não preserva nada, `/handoff` preserva a capacidade do trabalho de se mover.

## O que viaja, e o que não viaja

O documento carrega a thread ativa (o que está em andamento, por quê, e o que vem a seguir) mais uma seção **suggested skills** nomeando o que o próximo agent deve buscar. Segredos são redatados antes de ser escrito.

O que ele deliberadamente não carrega é qualquer coisa já escrita. Specs, planos, ADRs, issues, commits e diffs são referenciados por caminho ou URL, nunca copiados. Isso mantém o arquivo pequeno, e mantém os detalhes resolvidos em um lugar em vez de dois que derivam.

## Perguntas frequentes

**Handoff ou compact?**
`/compact` a menos que algo esteja viajando. Ficar na mesma tarefa é um compact, não um handoff: mesmo harness, mesmo diretório, e você precisa ficar no loop é onde a árvore de fronteira de fase chega na maioria dos dias. A vantagem do `/handoff` não é que resume melhor; é que o resultado é um arquivo que você pode levar para algum lugar que `/compact` não alcança.

**Então qual é a diferença real entre compact, clear e handoff?**
Três coisas diferentes sendo preservadas. `/compact` comprime este context e continua você em uma janela fresca: a intenção sobrevive. `/clear` esvazia a janela e começa do zero: correto quando tudo atrás de você é descartável, e irreversível se não for. `/handoff` escreve um arquivo portável: o trabalho sobrevive à mudança para outro lugar. Note que os três transformam uma **[primary source](https://www.aihero.dev/ai-coding-dictionary/primary-source)** (a conversa como aconteceu) em uma **[secondary source](https://www.aihero.dev/ai-coding-dictionary/secondary-source)** (um resumo dela). Continuar é o único movimento que não faz isso, por isso é o primeiro a descartar.

**Onde foi meu arquivo de handoff?**
O diretório temporário, que é a fricção mais relatada com a skill: os caminhos são longos, diferem por OS, e no Windows agents às vezes precisam de várias tentativas para encontrar o certo. Peça o caminho de volta e guarde antes de seguir. Temp é deliberado: um handoff é um documento de trânsito, não um artefato que você mantém. Tampouco é um durável; veja a próxima pergunta.

**Meu handoff desapareceu entre sessions.**
Alguns ambientes limpam o temp entre sessions (Codex é o caso relatado), e `/private/tmp` some no reboot. Se a próxima session não está começando dentro de uma hora, ou está começando sob um harness diferente, copie o arquivo para algum lugar durável assim que ele for escrito. O mesmo se aplica a qualquer coisa que o documento *aponte*: um dispatch que referencia outros arquivos no temp é um dispatch que o próximo agent não consegue seguir.

**Como eu passo isso para o próximo agent?**
Abra a session fresca e aponte para o caminho: leia este arquivo, depois continue. Aponte para o arquivo em vez de colar o resumo em um comando shell: um resumo contendo backticks ou `$(...)` é prejudicado quando interpolado em `claude "<summary>"`, e a falha comum é truncamento silencioso em vez de erro, então o novo agent começa com um briefing silenciosamente incompleto.

**Isso é o mesmo que `/branch`, `--fork-session`, ou o `/handoff` embutido?**
Análogo, não idêntico, e `/branch` não é uma skill lançada aqui; `/handoff` é o nome canônico. Um fork herda uma cópia exata do context; esta skill produz uma compressão *direcionada* voltada para uma próxima tarefa declarada, em um arquivo. Quando um fork basta (mesma máquina, mesmo harness, mesmo diretório), um fork é menos trabalho. O arquivo vence no momento em que o destino é um lugar que o fork não pode ir.

**Quando algo pertence ao `CLAUDE.md` em vez disso?**
Pergunte se será verdade no próximo mês. `CLAUDE.md` é context permanente sobre o projeto, carregado em toda session quer seja relevante ou não. Um handoff é sobre uma peça de trabalho em andamento e está morto quando aquele trabalho aterrissa. Fatos que continuam sendo re-explicados são um problema de `CLAUDE.md`; uma tarefa pela metade é um handoff.

**Ele captura o quê, não o porquê.**
Uma crítica justa e repetida. Duas coisas ajudam. Passe o argumento (diga para que serve a próxima session) para que o raciocínio que se aplica *àquilo* seja preservado em vez de achatado. E fique atento a alegações confiantes que a session nunca realmente verificou: "X não é construído", "Y está feito". O próximo agent trata o documento como um contrato e não vai re-checar, então uma crença escrita como fato se torna uma premissa falsa para tudo que se segue. Leia o documento antes de passar, e rebaixe qualquer coisa que você apenas assumiu.

**Por que é uma skill em vez de um slash command?**
Ambos funcionam; servem a situações diferentes. Como skill, é lançada e atualizada pelo mesmo caminho de instalação que tudo mais aqui, o que a torna compartilhável; a restrição de que o agent não a aciona sozinha é definida pelo seu frontmatter em vez do mecanismo.

## Está funcionando se

- O documento é uma pequena fração da conversa, e specs, issues e diffs aparecem como caminhos e URLs em vez de texto copiado.
- Você pode ler frio, sem a session original aberta, e saber o que fazer a seguir.
- O agent fresco começa a trabalhar em vez de pedir que você re-explique a configuração.
- No caso de bifurcação, sua session original ainda está parada intocada quando você volta.
- A seção suggested-skills nomeia a skill que você teria buscado por conta própria.
- Nada nele é uma chave, um token, ou uma senha.

## Onde se encaixa

`handoff` é uma **standalone para buscar a qualquer momento** que vive na junção entre sessions em vez de dentro de uma cadeia de construção, mas uma estreita, e o mapa honesto é que você vai usá-la menos frequentemente do que as outras quatro opções em uma fronteira de fase. Seu vizinho mais próximo é [prototype](https://aihero.dev/skills-prototype), porque um protótipo vive em seu próprio diretório e a ida e volta é exatamente o cruzamento para o qual esta skill serve. Quando você está em uma fronteira e não tem certeza se continuar, limpar, handoff, delegar ou compactar, [how-works](https://aihero.dev/skills-how-works) carrega a árvore que ordena essas cinco, e o direciona pelo resto do conjunto.
