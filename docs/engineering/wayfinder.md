## O que faz

`wayfinder` pega um esforço grande demais para uma única [session](https://www.aihero.dev/ai-coding-dictionary/session) de agent: uma ideia cujo **destino** você pode nomear mas cuja rota você ainda não consegue ver, e a mapeia como um **mapa** compartilhado de **tickets de decisão** no seu issue tracker, depois os resolve um por vez até que o caminho esteja claro.

Ele planeja, ele não faz. Cada ticket contém uma pergunta cuja resolução é uma decisão, não um slice de construção a ser executado, e o mapa está terminado quando não resta nada para decidir antes que alguém vá e construa a coisa. Essa única regra é o que separa um ticket de wayfinder de um [ticket](https://www.aihero.dev/ai-coding-dictionary/ticket) de implementação comum, e é a regra que os agents mais quebram. Quando o mapa é liberado, wayfinder passa adiante; ele não continua indo para o código.

## Quando acessá-lo

Você invoca isso digitando `/wayfinder`; o [agent](https://www.aihero.dev/ai-coding-dictionary/agent) não o acessará sozinho.

É o fluxo mais pesado e denso do conjunto, então o gatilho é estreito: o esforço tem que ser genuinamente maior do que uma sessão de agent pode conter, e a rota até o destino tem que estar nebulosa. A divisão é limpa: `/grill-with-docs` para planejamento de sessão única, `/wayfinder` para planejamento multi-sessão.

| O que você tem diante de si | O que executar |
| --- | --- |
| Uma funcionalidade bem delimitada que você pode definir em uma sessão | [grill-me](https://aihero.dev/skills-grill-me), ou [grill-with-docs](https://aihero.dev/skills-grill-with-docs) quando há um codebase |
| Um projeto greenfield, ou uma construção abrangendo muitas sessões, com a rota ainda nebulosa | `/wayfinder` |
| Uma thread onde a decisão já foi tomada | [to-spec](https://aihero.dev/skills-to-spec): pule direto para além do mapa |
| Um mapa wayfinder liberado | [to-spec](https://aihero.dev/skills-to-spec), depois [to-tickets](https://aihero.dev/skills-to-tickets) e [implement](https://aihero.dev/skills-implement) |
| Uma sessão existente que já cresceu demais | digite "hand off to `/wayfinder`" ([handoff](https://aihero.dev/skills-handoff) faz a ponte tanto para dentro quanto para fora de um mapa) |

Greenfield não é um requisito. Wayfinder é usado rotineiramente em codebases legados e meio construídos, e é argumentavelmente mais nítido lá, porque muito da nebulosidade é "o que já é verdade aqui" em vez de "o que devemos fazer".

## Pré-requisitos

O mapa e seus tickets ficam no issue tracker do repo, então wayfinder precisa da configuração do tracker que [setup-skills](https://aihero.dev/skills-setup-skills) estabelece. Essa etapa escreve uma seção "Wayfinding operations" descrevendo como o mapa, seus tickets filhos, arestas de bloqueio e consultas de fronteira são expressos para GitHub, GitLab ou markdown local. Wayfinder resolve esse documento através do ponteiro no seu `CLAUDE.md` / `AGENTS.md` em vez de um caminho fixo; sem nenhum tracker configurado ele cai para arquivos markdown locais.

O tracker não é decoração. Bloqueio é o que renderiza a fronteira visualmente na UI própria do tracker, e um tracker sem links de dependência nativos (um Gitea auto-hospedado, por exemplo) degrada wayfinder para inferir bloqueadores a partir do texto do mapa, o que funciona mas precisa de supervisão mais próxima.

## O mapa, a nebulosidade e a fronteira

O **mapa** é uma única issue rotulada `wayfinder:map`; seus tickets são suas issues filhas. É um **índice, não um armazenamento**: uma decisão vive em exatamente um lugar, seu ticket, e o mapa apenas o resumo e vincula. Uma sessão carrega o mapa em baixa resolução e amplia para tickets individuais sob demanda, o que permite que um mapa continue crescendo sem que cada sessão pague por toda a sua história.

Quatro coisas vivem nele:

- **Destino**: o que chegar ao final deste mapa parece. Nomeá-lo é o primeiro ato de mapear, antes que qualquer ticket exista, porque o destino fixa o escopo contra o qual cada ticket é medido.
- **Decisões até agora**: uma linha por ticket fechado, cada uma vinculando ao onde o detalhe realmente vive.
- **Ainda não especificado**: a **fog of war**. Decisões que você sabe que estão chegando mas ainda não consegue frasear com precisão. O teste para nebulosidade versus ticket é se você pode estabelecer a pergunta precisamente *agora*, não se pode respondê-la. Resolver um ticket limpa a nebulosidade à frente dele e gradua qualquer coisa que agora seja especificável em tickets novos.
- **Fora do escopo**: trabalho considerado além do destino. Nebulosidade sempre se acumula *em direção* ao destino, então trabalho fora do escopo é fechado e nunca se gradua.

A **fronteira** são os tickets abertos, desbloqueados, não reivindicados (a borda do conhecido). Uma sessão reivindic um ticket atribuindo-o a si mesma antes de fazer qualquer trabalho, então o atribuído *é* a reivindicação e sessões concorrentes o pulam. Tickets são referenciados por nome ao longo, nunca por um `#42` solto; uma parede de números de issue é ilegível na narração.

## Os quatro tipos de ticket de decisão

Cada ticket carrega um rótulo `wayfinder:<type>`, e é **[HITL](https://www.aihero.dev/ai-coding-dictionary/human-in-the-loop)** (trabalhado com uma pessoa que fala por si mesma) ou **[AFK](https://www.aihero.dev/ai-coding-dictionary/afk)**, conduzido pelo agent sozinho. Um ticket HITL só se resolve através da troca ao vivo; um agent que responde suas próprias perguntas de [grilling](https://www.aihero.dev/ai-coding-dictionary/grilling) o quebrou.

| Tipo | Modo | Acesse-o quando | Resolvido por |
| --- | --- | --- | --- |
| `grilling` | HITL | O padrão. A pergunta pode ser definida conversando sobre ela. | [grilling](https://aihero.dev/skills-grilling) mais [domain-modeling](https://www.aihero.dev/skills-domain-modeling), em uma sessão nova |
| `prototype` | HITL | "Como isso deve parecer" ou "como isso deve se comportar": uma pergunta que conversar não define. | [prototype](https://aihero.dev/skills-prototype), com o artefato construído vinculado do ticket como um asset |
| `research` | AFK | Um fato fora do diretório de trabalho está bloqueando uma decisão. | Um [research](https://aihero.dev/skills-research) [subagent](https://www.aihero.dev/ai-coding-dictionary/subagent), disparado no momento do mapeamento e executado em paralelo em uma branch `research/<name>` |
| `task` | Ambos | Nada a decidir, mas trabalho manual bloqueia uma decisão, como provisionar acesso, cadastrar-se em um serviço, ou mover dados para que sua forma possa ser vista. | O agent sozinho onde puder, caso contrário um checklist preciso para a pessoa |

`task` é o único tipo que *faz* em vez de decide, e ganha seu lugar desbloqueando uma decisão, nunca por entregar um pedaço do destino. Este é o tipo que mais dá errado na prática: agents o interpretam como uma etapa de implementação e começam a escrever código de produto dentro do mapa.

Research é a única exceção à regra de *um ticket por sessão*.

## Perguntas comuns

**Como isso difere de `/grill-with-docs`? Qual devo começar?**
Contagem de sessões, não tamanho do projeto. `/grill-with-docs` é planejamento de sessão única; wayfinder é planejamento multi-sessão. Se você pode manter tudo em uma conversa, grilling é a ferramenta mais barata e melhor, e wayfinder é genuinamente mais lento e denso para esse caso. A abreviação comunitária que se estabeleceu: wayfinder só faz sentido se o trabalho não cabe em uma única sessão. Esta é, à distância, a pergunta mais feita sobre wayfinder, e continua sendo porque as descrições não te dizem onde sua própria tarefa se sente nessa linha. Você tem que julgar a contagem de sessões sozinho.

**Quando ele pede o "destino", ele significa o final desta sessão ou o final de tudo?**
O mapa inteiro. Isso significa o destino de todo o mapa, não apenas da sessão inicial. A pergunta é ambígua porque wayfinder é por definição uma ferramenta multi-sessão, então uma resposta com escopo de sessão nunca faz sentido. Destinos típicos são uma [spec](https://www.aihero.dev/ai-coding-dictionary/spec) para passar adiante, uma decisão a ser travada antes do planejamento começar, uma prova de conceito, ou uma mudança feita no local como uma migração de dados.

**O mapa foi liberado. O wayfinder não já escreveu a spec e fez os tickets? Por que eu ainda preciso de `/to-spec` e `/to-tickets`?**
Não. Os tickets de wayfinder são tickets de decisão, e quando o mapa fecha eles também estão todos fechados. O que resta é um mapa cheio de decisões vinculadas, que não é um plano de construção. [to-spec](https://aihero.dev/skills-to-spec) colapsa essas decisões vinculadas em uma spec (`/to-spec #<map_issue>`) e [to-tickets](https://aihero.dev/skills-to-tickets) corta isso em tickets de implementação tracer bullet. Alimentar o mapa direto em [implement](https://aihero.dev/skills-implement) pula o colapso e descarta o detalhe vinculado. Vá direto para a implementação apenas quando o esforço se revelou genuinamente pequeno. As pessoas executam o pipeline abreviado e reportam funcionando; as duas etapas extras compram um artefato de spec explícito que um revisor ou colega pode ler, o que importa mais quanto menos solo você estiver.

**Meu agent começou a escrever código de produção no meio de uma sessão wayfinder.**
A falha mais reportada com esta skill, e há uma lacuna real por trás. O padrão "planeje, não faça" do wayfinder pode ser sobrescrito nas **Notes** do mapa, mas as Notes são escritas pelo agent, então a restrição e sua exceção vivem no mesmo arquivo que a parte restrita possui. Um usuário observou um agent escrever "este mapa carrega execução" em suas próprias Notes e depois ler de volta em sessões posteriores como sua própria licença, construindo em um servidor ao vivo. Não há uma parada硬性 dentro da skill para "eu queria o padrão." Até que haja: leia as Notes em qualquer mapa que você não mapeou sozinho, mantenha implementação em suas próprias sessões, e trate qualquer `wayfinder:task` que pareça um slice da construção como com tipo errado.

**Eu mapeei 27 tickets, e quando cheguei ao décimo terceiro, o resto não fazia mais sentido.**
Um resultado real e repetidamente reportado, textual de um relatório de campo. O instinto padrão do wayfinder é planejar de forma abrangente, e um mapa cujos tickets posteriores repousam em suposições que os anteriores invalidam é exatamente a armadilha de waterfall pela qual a skill é acusada. Duas coisas combatem isso. Delimite o mapa a um destino limitado em vez de ao produto inteiro. Praticantes reportam consistentemente que mapas delimitados a um epic definido se comportam melhor do que um "implement V1" espalhado, e planejar algo muito grande não é o objetivo desde o início: entregar incrementos pequenos é. E faça [prototype](https://aihero.dev/ai-coding-dictionary/prototyping) agressivamente: toda a razão pela qual a rota permanece atual é que a incerteza é descarregada por artefatos baratos e concretos antes que a implementação dependa disso. Wayfinder é "prototypemaxxing", não "planmaxxing".

**Posso trabalhar vários tickets em paralelo?**
A fronteira é construída para te mostrar o que é selecionável, e as arestas de bloqueio estão lá para que o trabalho paralelo seja seguro no papel. Na prática uma-por-vez é o padrão mais seguro. Usuários trabalhando em dois tickets de grilling ao mesmo tempo são perguntados em uma sessão uma pergunta que acabaram de responder na outra, porque as sessões não compartilham [contexto](https://www.aihero.dev/ai-coding-dictionary/context). Há também uma lacuna conhecida em tickets de prototype: foi reportado um agent construindo três variações de UI, escolhendo uma sozinho, e fechando o ticket. A seleção é sua para fazer, e a skill atualmente não diz isso alto o suficiente. Se você executar em paralelo, revise o grafo de dependências você mesmo primeiro.

**Preciso usar GitHub Issues?**
Não. Qualquer issue tracker funciona. GitHub é o caminho mais suportado porque suas sub-issues e relações de bloqueio nativas são o que tornam a fronteira visível sem abrir o mapa; GitLab, Jira e markdown local são todos usados. Duas ressalvas honestas. Um tracker sem bloqueio nativo significa que o grafo de dependências é inferido a partir do texto e precisa de correção manual. E markdown local coloca os artefatos no seu repo, o que não é recomendado: armazenar esse material no repo tende a levar à persistência acidental. Mantenedores de open-source encontram o problema oposto (trackers públicos enchendo de tickets de planejamento gerados por agent) e tendem a escolher markdown local de qualquer forma.

**O grilling é exaustivo. Cada pergunta tem três parágrafos de comprimento.**
Esta é a queixa ao vivo mais nítida sobre wayfinder e não está resolvida. A decomposição que um usuário deu: a verbosidade em si causa exaustão de decisão, e o comprimento remove o *por que* a pergunta está sendo feita, então você perde a cadeia de decisão para decisão conforme o mapa fica mais longo. A verbosidade parece ser uma propriedade do atual conjunto de [models](https://www.aihero.dev/ai-coding-dictionary/model) em vez da skill, e nenhuma correção chegou. Mitigações de praticantes em circulação: execute com um [reasoning effort](https://www.aihero.dev/ai-coding-dictionary/effort) menor, e coloque uma instrução em linguagem simples no seu `CLAUDE.md` global. Espere gastar pensamento real aqui de qualquer forma, porque a quantidade de pensamento que wayfinder demanda de você não é um defeito mas a maior parte do motivo de existir.

**Uma decisão que eu já fechei se revelou errada. Eu edito o ticket antigo ou faço um novo?**
Não há orientação oficial, e o instinto do agent não é útil: ele tende a contornar a decisão ruem em vez de desafiá-la, então você tem que guiar manualmente. O que funciona é contar ao wayfinder diretamente o que mudou; ele atualiza o mapa, revisa os tickets afetados, e comenta nos já fechados. Mudanças de escopo no meio do mapa são recuperáveis. Um mapa que você *projetou* para mudar é um cheiro de escopo.

**Para onde foi `decision-mapping`?**
Esta é a skill, renomeada para `wayfinder` na v1.1 e invocada como `/wayfinder`. "Decision map" era jargão e também era impreciso, já que apenas um dos quatro tipos de ticket é realmente uma decisão por si só. A rearticulação deu à skill um vocabulário coerente (destino, fog of war, fronteira, o mapa) em vez de um termo inventado sobreposto. A unidade manteve a palavra "decision", porém: um **decision ticket** é o que um ticket de wayfinder é chamado, precisamente para impedir que as pessoas o leiam como um ticket de implementação.

## Está funcionando se

- O destino está escrito e acordado antes que um único ticket exista.
- Cada ticket aberto lê como uma pergunta. Qualquer ticket que lê "construa o X" ou está com tipo errado ou pertence a jusante do mapa.
- Você pode olhar para seu tracker e ver quais tickets são selecionáveis sem abrir o mapa, já que a fronteira se renderiza através do bloqueio nativo.
- Uma sessão resolve um ticket, publica a resposta como um comentário de resolução, o fecha, e deixa uma linha nas *Decisões até agora* do mapa. Então para.
- **Ainda não especificado** encolhe ao longo do tempo. Uma área de nebulosidade que se gradua em um ticket desaparece daquela seção em vez de viver em ambos os lugares.
- Quando o grilling inicial em largura não encontra nebulosidade alguna, a skill para e te diz que o esforço é pequeno o suficiente para pular o mapa.
- A sessão que termina o mapa te direciona para uma spec, não para um pull request.

## Onde se encaixa

`wayfinder` é uma **rampa de entrada situacional**, não a porta da frente padrão. A cadeia guiada por grill → entrega é onde a maioria do trabalho ainda começa; wayfinder é o que você escala quando a ideia é grande demais para caber em uma sessão, e se funde de volta nessa cadeia em [to-spec](https://aihero.dev/skills-to-spec), porque um mapa liberado passa adiante em vez de construir.

Por baixo, é principalmente outras skills vestindo o agendamento do wayfinder: [grilling](https://aihero.dev/skills-grilling) e [domain-modeling](https://aihero.dev/skills-domain-modeling) resolvem o tipo de ticket padrão, [prototype](https://aihero.dev/skills-prototype) resolve os tickets que conversar não resolve, e [research](https://aihero.dev/skills-research) roda como subagent para que sua leitura nunca aterre na sua sessão. [handoff](https://www.aihero.dev/skills-handoff) é a ponte para dentro e para fora: para dentro de um mapa a partir de uma conversa que cresceu demais, para fora quando uma side quest aparece no meio de uma sessão. Para qualquer outra coisa, [how-works](https://aihero.dev/skills-how-works) direciona sobre todo o conjunto.
