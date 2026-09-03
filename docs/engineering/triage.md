## O que faz

`triage` trabalha através das issues no tracker do seu projeto, movendo cada uma através de uma pequena máquina de estados de **funções de triagem** (uma função de categoria e uma função de estado) e deixando para trás ou um brief pronto para agent, uma pergunta específica para o reportador, ou uma issue fechada com um motivo registrado.

É apenas para issues **que você não criou**. Relatórios brutos de bugs, pedidos de funcionalidades recebidos, um pull request externo que chegou sem aviso: trabalho que caiu no tracker vindo de fora, na forma que o reportador deixou. [Tickets](https://www.aihero.dev/ai-coding-dictionary/ticket) que [to-tickets](https://aihero.dev/skills-to-tickets) produziu são agent-ready por construção, e executar `triage` sobre eles é trabalho desperdiçado no máximo. A regra é direta: `/triage` é apenas para issues recebidas, não para issues que você mesmo criou.

A segunda coisa que o separa de rotular à mão: ele recomenda e espera. Ele te diz sua chamada de categoria e estado com raciocínio, além do que encontrou no codebase, e não aplica nada até você direcioná-lo.

## Quando acessá-lo

Você invoca isso digitando `/triage` e então descrevendo o que quer em linguagem simples. O [agent](https://www.aihero.dev/ai-coding-dictionary/agent) não o acessará sozinho. "Me mostre qualquer coisa que precise da minha atenção", "vamos ver #42", "mova #42 para ready-for-agent".

| O que você tem | Para onde ir |
| --- | --- |
| Um tracker cheio de relatórios brutos de outras pessoas | `/triage` |
| Uma ideia vaga sua, nada escrito | [grill-with-docs](https://aihero.dev/skills-grill-with-docs) |
| Uma conversa definida para virar uma [spec](https://www.aihero.dev/ai-coding-dictionary/spec) | [to-spec](https://aihero.dev/skills-to-spec) |
| Uma spec para dividir em tickets agent-ready | [to-tickets](https://aihero.dev/skills-to-tickets) |
| Um bug confirmado que precisa de uma causa raiz, não de um rótulo | [diagnosing-bugs](https://aihero.dev/skills-diagnosing-bugs) |

## Pré-requisitos

`triage` lê e escreve no seu issue tracker, então [setup-skills](https://aihero.dev/skills-setup-skills) deve ter configurado esse tracker e seu vocabulário de rótulos primeiro. Os nomes de função abaixo são **canônicos**; as strings de rótulo no seu tracker podem diferir, e o mapeamento é o que o setup fornece. Se seu tracker já usa os nomes canônicos exatamente, não há nada para mapear e nada para configurar.

A configuração do tracker também decide se pull requests externos contam como superfície de requisição, e quem conta como externo. Esse flag é desligado por padrão e não é mais uma questão de setup, então ative-o em `docs/agents/issue-tracker.md` se quiser PRs no escopo.

## A máquina de estados

Cada item triaged termina carregando exatamente uma função de categoria e uma função de estado. Duas categorias: `bug` (algo está quebrado) e `enhancement` (nova funcionalidade ou melhoria). Cinco estados:

| Estado | Significa |
| --- | --- |
| `needs-triage` | Você precisa avaliar. Onde uma issue sem rótulo normalmente pousa primeiro. |
| `needs-info` | Esperando o reportador. Retorna para `needs-triage` quando ele responde. |
| `ready-for-agent` | Totalmente especificada, com um brief de agent anexado. Um [AFK](https://www.aihero.dev/ai-coding-dictionary/afk) agent pode pegá-la. |
| `ready-for-human` | O mesmo brief, além do por que isso não pode ser delegado: julgamento, acesso externo, teste manual. |
| `wontfix` | Fechada, com o motivo registrado. |

Esse é todo o vocabulário, e a invariante "exatamente uma função de estado" é o que mantém as consultas simples. É também a área mais solicitada da [skill](https://www.aihero.dev/ai-coding-dictionary/skill): usuários pediram um sexto estado para trabalho que está especificado mas bloqueado em outra issue, para trabalho `deferred` condicionado a um futuro gatilho, e para um estado terminal `implemented`. Nenhum deles foi lançado. Veja as perguntas abaixo.

`wontfix` se divide em três caminhos, e a diferença importa porque apenas um deles escreve na base de conhecimento:

| Por que você está fechando | O que acontece |
| --- | --- |
| Já implementado | Um comentário apontando onde já existe. Nada é escrito em `.out-of-scope/`, porque é uma funcionalidade construída, não rejeitada, e registrar lá envenenaria as verificações de dedup. |
| Bug rejeitado | Explicação educada, depois fechar. |
| Enhancement rejeitado | Um arquivo em `.out-of-scope/`, vinculado do comentário de fechamento, depois fechar. |

`.out-of-scope/` é um arquivo markdown por **conceito** rejeitado, não por issue, escrito como um curto documento de design em vez de uma linha do banco de dados: o que foi rejeitado, por quê, e toda issue que pediu isso. `triage` lê o diretório inteiro antes de avaliar qualquer coisa, e combina por conceito em vez de palavra-chave, então "night theme" combina com `dark-mode.md`. Quando ele encontra uma correspondência, ele apresenta a decisão antiga e pergunta se você ainda sente da mesma forma, em vez de relitigar a requisição do zero.

## Verifique antes de fazer o brief

Antes de qualquer [grilling](https://www.aihero.dev/ai-coding-dictionary/grilling), `triage` verifica se a afirmação realmente é válida. Para um bug, ele o reproduz a partir dos passos do reportador. Para um PR, ele verifica a branch e executa os testes relevantes. Então ele relata qual das três coisas aconteceu: confirmado, com o caminho do código; falha ao reproduzir; ou detalhes insuficientes para tentar, o que é por si só o sinal mais forte de `needs-info`.

Ele executa duas verificações adicionais contra o codebase na mesma passada: **redundância** (isso já está implementado, buscando por conceito de domínio em vez da formulação do reportador?) e **rejeição prévia** (`.out-of-scope/` já diz não?). Ambas são baratas, e ambas produzem um `wontfix` quando encontram correspondência.

Tudo isso existe para fazer um artefato ficar bom: o **brief de agent**, o comentário estruturado postado quando uma issue se move para `ready-for-agent`. Uma vez postado, o brief é o contrato e o relatório original é apenas contexto. Briefs são escritos para ser **duráveis** em vez de precisos, porque uma issue pode ficar em `ready-for-agent` por semanas enquanto o código se move sob ela. Então eles nomeiam tipos, assinaturas e contratos de comportamento, e nunca caminhos de arquivo ou números de linha. Uma reprodução confirmada faz um brief muito mais forte do que um palpite.

## Um PR é uma issue com código anexado

Onde o tracker trata pull requests externos como uma superfície de requisição, eles passam pela mesma máquina, com as mesmas categorias, mesmos estados, mesmas transições. Os estados apenas são lidos contra o diff: `ready-for-agent` significa que um brief está anexado e um agent deve tomar o próximo passo no código, `ready-for-human` significa que está pronto para uma pessoa fazer merge. Um brief em um PR descreve o que resta fazer no diff existente, não como construir a coisa do zero.

A descoberta surface apenas PRs *externos*, porque a branch em andamento de um colaborador não é trabalho de triagem. Esse filtro é apenas para descobert, e nomear um PR explicitamente o faz ser triaged independente de quem escreveu. Uma aresta áspera: o comando de listagem de PR externo do template do GitHub pede um campo `authorAssociation` para `gh pr list` que `gh` não expõe, então o comando como escrito falha completamente ([#468](https://github.com/mattpocock/skills/issues/468)).

## Perguntas comuns

**Executei `/to-spec` e `/to-tickets`, e agora esses tickets estão ali sem triagem. Executo `/triage` sobre eles?**
Não. Eles já são agent-ready, porque `to-tickets` aplica o rótulo `ready-for-agent` enquanto publica, precisamente para que um runner AFK os pegue sem outra passada. O usuário que encontrou isso tinha executado o fluxo de spec, visto `needs-triage` na saída, e encontrado seu runner AFK ignorando tudo. `triage` é a rampa de entrada para trabalho que chega de fora; o fluxo de spec é o lane para trabalho que você origina. Eles se encontram em `ready-for-agent`, não antes.

**`triage` ainda é relevante agora que há um fluxo `to-spec` → `to-tickets` → `implement`?**
Apenas se você tem trabalho recebido. `triage` precede essa espinha e faz um trabalho diferente: é o lane para relatórios que outras pessoas registraram. Se tudo no seu tracker veio do seu próprio planejamento, você raramente o abrirá. Se você mantém algo público, ou sua equipe registra bugs para você, é a porta da frente. O uso principal é repos de open-source pegando issues de contribuidores externos.

**O agent tentou aplicar `ready-for-agent` e `gh` disse que o rótulo não existe.**
Bug conhecido e aberto ([#616](https://github.com/mattpocock/skills/issues/616)). `setup-skills` escreve o vocabulário de rótulos em `docs/agents/triage-labels.md`, mas não cria os rótulos no seu tracker. Crie os cinco rótulos de estado e dois rótulos de categoria você mesmo, uma vez, com `gh label create` ou a UI do tracker, e isso para. Há um branch de correção comunitária vinculado na issue que não foi mergeado.

**Cinco estados não são suficientes: e os bloqueados, ou os deferred, ou os implemented?**
Esta é a lacuna mais registrada na skill, em três formas. Uma issue totalmente especificada mas esperando outra issue fechar ([#139](https://github.com/mattpocock/skills/issues/139)), onde a queixa do reportador era que `ready-for-agent` é "tecnicamente verdadeiro" ali mas enganoso, então um agent pega ela e bate num muro. Trabalho futuro condicionado a gatilho que está pretendido mas não acionável ainda ([#297](https://github.com/mattpocock/skills/issues/297)). E um estado terminal para "implementado, aguardando verificação", sem o qual um runner AFK pode re-enfileirar tickets finalizados. Matt concordou que o caso bloqueado é real e está indeciso sobre o nome (`blocked` versus `paused`). Nenhum foi lançado. A solução que as pessoas usam é um rótulo extra local no repo ao lado da categoria, que mantém o slot de estado canônico ocupado por algo honesto ao custo de a skill não saber disso. Uma derivação comunitária vai além, adicionando `needs-slicing`, `tracking` e rótulos de esforço. Isso funciona, mas é deles, não da skill.

**Como isso difere de `/diagnosing-bugs`?**
A etapa de verificação aqui é intencionalmente rasa (o suficiente para responder "isso é real, e mais ou menos onde vive"), não para encontrar uma causa raiz. Quando um bug não reproduce dos passos do reportador em alguns minutos, a jogada honesta é `needs-info`, ou [diagnosing-bugs](https://aihero.dev/skills-diagnosing-bugs) se você quiser perseguir agora. Nenhuma skill menciona a outra atualmente; um usuário encontrou esse seam, e ainda está aberto.

**Posso apontá-lo para todo o meu backlog e deixá-lo rodar?**
Você pode pedir, mas observe o que ele lê. A passada "mostre o que precisa de atenção" é uma listagem barata destinada à *seleção*, onde você escolhe um, e então ele coleta [contexto](https://www.aihero.dev/ai-coding-dictionary/context) completo sobre o que você escolheu. Executá-la em vinte issues de uma vez e um agent pode silenciosamente recair naquela listagem barata como sua base de evidências, que retorna corpos de issues mas não comentários. Um usuário encontrou exatamente isso: três issues já carregavam um comentário dizendo "já corrigido, recomendo fechar", e todas três receberam briefs de agent novos. Se você quiser uma passagem em massa, diga explicitamente que comentários devem ser lidos por issue.

**Funciona com qualquer coisa além de GitHub Issues?**
Sim, o tracker é configuração, não uma suposição codificada, e as pessoas o executam contra GitLab e arquivos markdown locais sob `.scratch/`. No tracker de markdown local há um bug aberto no template onde o arquivo gerado pode carregar os critérios de aceitação duas vezes, uma vez no nível superior e uma vez dentro do brief de agent ([#200](https://github.com/mattpocock/skills/issues/200)).

## Está funcionando se

- Cada item que toca termina com exatamente uma função de categoria e uma função de estado, nunca zero, nunca dois estados em conflito.
- Ele te dá uma recomendação com raciocínio e para, em vez de relotular e seguir em frente.
- O bug foi reproduzido, ou o PR foi verificado e executado, antes que qualquer coisa alcançasse `ready-for-agent`.
- Os briefs que ele escreve nomeiam tipos e comportamentos, e contêm nenhum caminho de arquivo e nenhum número de linha.
- Uma requisição que foi rejeitada六个月前 volta, e ele diz isso e cita o motivo antigo em vez de triaged do zero.
- Cada comentário que ele posta começa com `> *This was generated by AI during triage.*`

## Onde se encaixa

`triage` é uma **rampa de entrada**, não uma etapa na cadeia principal. O fluxo principal roda a partir de uma ideia que você teve (grill, spec, tickets, implement, review), e `triage` é o lane paralelo para trabalho que chegou ao invés. Ele se funde no mesmo lugar: uma issue rotulada `ready-for-agent` com um brief nela, que [implement](https://aihero.dev/skills-implement) pega exatamente como pegaria um ticket de [to-tickets](https://aihero.dev/skills-to-tickets). Quando uma requisição precisa ser aprimorada antes de poder ser briefada, `triage` executa [grilling](https://aihero.dev/skills-grilling) e [domain-modeling](https://aihero.dev/skills-domain-modeling) juntos, uma rodada de perguntas por vez, para que decisões aterrem em `CONTEXT.md` e nos ADRs conforme são tomadas. Quando você não tem certeza de qual lane está, [how-works](https://aihero.dev/skills-how-works) o direciona.
