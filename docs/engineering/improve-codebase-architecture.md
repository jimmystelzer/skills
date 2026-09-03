## O que faz

`improve-codebase-architecture` analisa uma codebase em busca de **oportunidades de aprofundamento**: lugares onde um módulo raso (uma interface quase tão complexa quanto o que ela esconde) poderia se tornar profundo. Ele escreve um relatório HTML autocontido e depois [questiona](https://www.aihero.dev/ai-coding-dictionary/grilling) você sobre qual deles escolher.

Ele nunca altera o código. A execução inteira produz um arquivo HTML no diretório temporário do OS e uma conversa; o refatoramento em si acontece depois, em uma [session](https://www.aihero.dev/ai-coding-dictionary/session) separada, através do fluxo normal de construção. É isso que faz dele um levantamento e não uma ferramenta de refatoramento, e é por que o skill vale a pena rodar em uma codebase que você ainda não está pronto para tocar.

Dois filtros impedem que o relatório se torne um conselho genérico de limpeza. Todo candidato precisa passar no **teste de exclusão**: remover este módulo concentraria a complexidade por trás de uma interface menor, ou apenas a espalharia entre chamadores? Apenas os casos que "concentram" ganham um card. E, a menos que você aponte para uma área específica, ele primeiro lê o histórico de commits recentes e enviesa a varredura para caminhos que estão ativamente mudando, com base na ideia de que um aprofundamento em código que ninguém toca é um refatoramento que você nunca vai realizar.

## Quando usar

Você invoca isso digitando `/improve-codebase-architecture`; o [agent](https://www.aihero.dev/ai-coding-dictionary/agent) não vai usar por conta própria.

Ele fica fora do loop de construção: não é um passo no loop principal, mas algo que você roda periodicamente para enfileirar mais trabalho para melhorar a codebase. As quatro situações em que é usado:

| Situação | Como é usado |
| --- | --- |
| Manutenção rotineira | Rode a cada poucos dias, ou sempre que aparecer um momento livre, para impedir que a estrutura decaia entre features. |
| Antes de uma grande construção | Aponte para a [spec](https://www.aihero.dev/ai-coding-dictionary/spec): "como podemos facilitar essa mudança?" Este é o prompt mais eficaz. |
| Auditoria de brownfield | Rode em um repo grande, desestruturado ou [vibe-coded](https://www.aihero.dev/ai-coding-dictionary/vibe-coding) para descobrir qual é o estado real. |
| Trabalho legado em testes | Use para encontrar os seams faltantes primeiro, antes de escrever testes contra código não testável. |

Onde pode ser confundido com skills parecidas:

- Para projetar um módulo que você já escolheu, use [codebase-design](https://aihero.dev/skills-codebase-design): essa é a bancada, este é o levantamento que descobre o que colocar nela.
- Para um esforço grande demais para caber em uma session, use [wayfinder](https://aihero.dev/skills-wayfinder).
- Para "esta coisa específica está quebrada", use [diagnosing-bugs](https://aihero.dev/skills-diagnosing-bugs). Ele volta aqui quando a descoberta real é que não há um bom seam para isolar o bug.

## Pré-requisitos

Nenhum para rodar. Ele lê `CONTEXT.md` e quaisquer ADRs em `docs/adr/` se existirem, e fala nos substantivos do seu domínio quando existem: um candidato aparece como "aprofundar o módulo de recebimento de pedidos", não "refatorar o FooBarHandler".

Ele escreve em dois lugares. O relatório vai para `<tmpdir>/architecture-review-<timestamp>.html`, fora do repo. Durante o loop de questionamento, ele adicionará ou refinará termos em `CONTEXT.md`, criando esse arquivo se não existir, e oferecerá registrar um candidato rejeitado como um ADR para que uma execução futura não o sugira novamente.

## Profundidade, e o relatório que a procura

O skill gira em torno de uma ideia: **profundidade**. Um módulo profundo coloca muito comportamento por trás de uma interface pequena e estável. Um raso vaza sua implementação através de uma interface quase tão larga quanto o código por baixo dela. O relatório procura por superficialidade em três formas: funções puras extraídas apenas para testabilidade enquanto os bugs reais vivem na forma como são chamadas (sem **localidade**), módulos vazando por seus **seams**, e um conceito que você não consegue entender sem abrir cinco arquivos. Ele fecha com uma proposta para o aprofundamento que o corrige.

Cada candidato é um card: os arquivos envolvidos, a atrito, uma solução em linguagem clara, o benefício expresso em termos de **localidade** e **leverage**, um diagrama antes/depois, e um badge de força.

| Badge | O que significa para você |
| --- | --- |
| `Strong` | O teste de exclusão passa claramente e o atrito é real. Leve isso a sério. |
| `Worth exploring` | Aprofundamento plausível, mas o retorno depende de onde o código vai seguir. |
| `Speculative` | Superficial para completude. A maioria pode ser ignorada com segurança. |

O relatório termina com uma **Recomendação principal** (aquela que ele atacaria primeiro), e então o skill para e pergunta qual candidato você quer explorar. Nada foi decidido naquele ponto, e nenhum código foi alterado.

## O que acontece depois que você escolhe um

Escolher um candidato inicia uma sessão de [questionamento](https://aihero.dev/skills-grilling) sobre ele: restrições, o que fica por trás do seam, quais testes sobrevivem, como a interface aprofundada deveria parecer. A saída dessa sessão é uma decisão, não um diff. A partir daí o fluxo normal se aplica: leve a decisão para [to-spec](https://aihero.dev/skills-to-spec), depois [to-tickets](https://aihero.dev/skills-to-tickets), depois [implement](https://aihero.dev/skills-implement).

## Perguntas frequentes

**Ele me questionou por uma hora sobre uma ideia em vez de mostrar opções. Posso desligar isso?**

Sim: diga isso quando invocar ("não me questione, apenas mostre o relatório"). Esta é a reclamação mais comum do skill. Um usuário foi direto: gostava dele como "uma forma conveniente de obter uma análise completa de melhorias", e depois que o loop de questionamento foi adicionado o achou "praticamente inutilizável", relatando sessões em que ele propunha uma solução e depois fazia "dezenas a centenas de perguntas". A intenção de design é que o relatório venha primeiro e o questionamento só comece em um candidato que você escolheu, mas [models](https://www.aihero.dev/ai-coding-dictionary/model) mais fracos pulem direto para entrevistá-lo sobre a primeira ideia que tiveram. Os relatos na thread variam muito por model, e é um problema em aberto: o skill ainda não tem um modo documentado sem questionamento.

**O relatório abriu como HTML cru sem estilo, sem diagramas. O que aconteceu?**

O relatório carrega Tailwind e Mermaid de CDNs, então precisa de acesso à rede quando você o abre, e falha silenciosamente quando algo bloqueia esses scripts. O caso registrado foi um hook de segurança exigindo hashes SRI: o agent adicionou-os, o CDN serviu bytes diferentes para o navegador do que para o `curl` usado para calcular o hash, e o navegador bloqueou o script. Ambientes offline e restritos encontram o mesmo obstáculo. O agent não consegue ver isso, porque nunca renderiza a página. A solução é pedir CSS inline e diagramas SVG manuais em vez da estrutura CDN. Este é um problema em aberto e uma aresta áspera real.

**Ele me deu doze candidatos. Trabalho neles na mesma sessão ou inicio uma nova?**

Um candidato por sessão. Trabalhar vários em uma conversa preenche a [context window](https://www.aihero.dev/ai-coding-dictionary/context-window) com o relatório, o questionamento, as edições do domain-model e as mudanças de código tudo de uma vez. O relatório só vive em um arquivo temporário, então leve o candidato em si e não o arquivo: escolha um, questione-o, leve a decisão para `/to-spec`, e transforme os demais em [tickets](https://www.aihero.dev/ai-coding-dictionary/ticket) que você pode pegar independentemente depois. Coloque a melhoria escolhida em uma spec em vez de ir direto para a implementação. Esta é uma pergunta recorrente sem workflow documentado no próprio skill.

**Como devo dar o prompt?**

Com a próxima coisa que você está construindo em mente. Quando uma grande construção estiver próxima, aponte para a spec e pergunte "como podemos facilitar essa mudança?" Uma execução sem prompt varredura hot spots por conta própria, o que é bom para manutenção rotineira, mas nomear uma direção é o que torna o relatório acionável.

**Funciona em uma codebase legado grande?**

Parcialmente. Ele é forte em codebases grandes existentes que faltam estrutura consistente, e é o mecanismo de manutenção recomendado após qualquer configuração estrutural pontual. A contrapartida honesta: usuários com projetos genuinamente descontrolados relatam que "ajudou um pouco mas ainda não parece resolver", e um desenvolvedor com uma codebase legado de oito anos relatou o model ficando em loop enquanto o mesmo skill produz um gráfico limpo em um repo organizado. Não há uma skill dedicada `/refactor` para esse caso ainda. Se a codebase não tem vocabulário compartilhado algum, [grill-with-docs](https://aihero.dev/skills-grill-with-docs) para estabelecer um primeiro tende a fazer com que a saída deste skill fique muito melhor.

**Como isso é diferente de `/codebase-design`?**

`/codebase-design` é uma referência, não um driver de sessão. Ele fornece o vocabulário (módulo, interface, profundidade, seam, adapter, leverage, localidade), e este skill o empresta. Apontar um agent novo para `/codebase-design` como o que "fazer" é uma falha conhecida: sem seu próprio processo a seguir, o agent inventa um, re-explora código e roda por um longo tempo antes de perguntar qualquer coisa. Dirija com este skill; consuma aquele.

**Ele alguma vez vai me dizer que a codebase está bem?**

Raramente, e você deveria saber disso antes de começar. O skill é construído para produzir descobertas, então o enquadramento o empurrar para produzir candidatos em vez de concluir que nada está errado. Os badges de força são a defesa: um relatório onde tudo é `Speculative` é o skill dizendo que não encontrou nada, da única forma que sabe.

**Funciona no Codex ou em outro harness?**

Parcialmente. A etapa de exploração nomeia a ferramenta `Agent` do Claude Code com `subagent_type=Explore` diretamente, então um [harness](https://www.aihero.dev/ai-coding-dictionary/harness) sem essa ferramenta pode pular a exploração paralela em vez de substituir pela própria. O skill ainda roda; a varredura é apenas menos completa. Uma reescrita neutra de harness foi proposta mas não foi mergeada.

**Como implemento módulos profundos de verdade em TypeScript?**

Não há uma boa resposta vinda com o skill. O pedido recorrente é por um `TYPESCRIPT.md` com layouts concretos de arquivos e módulos para os princípios, e ele não existe. O skill vai dizer onde um aprofundamento pertence e o que deveria ficar por trás do seam; traduzir isso em uma estrutura de pacotes ou diretórios está atualmente por sua conta.

## Está funcionando se

- Os candidatos nomeiam conceitos do seu domínio, não nomes de classes inventados: "o módulo de recebimento de pedidos", não "o FooBarHandler".
- Os candidatos se agrupam em arquivos que você editou recentemente, não em cantos dormientes do repo.
- Nenhum código mudou durante a execução. O único arquivo novo é o relatório HTML no seu diretório temporário.
- Ele para após o relatório e pergunta qual candidato você quer, em vez de continuar por conta própria.
- Cada card explica o retorno como localidade ou leverage, e diz quais testes ficam mais simples, não apenas "isso é mais limpo".
- Rejeitar um candidato por uma razão duradoura te oferece registrar um ADR, para que a próxima execução não o sugira novamente.

## Onde se encaixa

`improve-codebase-architecture` é **manutenção periódica**: rode a cada poucos dias, fora de qualquer cadeia, para enfileirar trabalho em vez de fazer. Seus vizinhos são [codebase-design](https://aihero.dev/skills-codebase-design), que possui o vocabulário de profundidade-e-seam no qual todo candidato é escrito, [grilling](https://aihero.dev/skills-grilling), que percorre a árvore de decisão uma vez que você escolheu um candidato, e [domain-modeling](https://aihero.dev/skills-domain-modeling), que mantém `CONTEXT.md` e os ADRs atualizados conforme a decisão se estabelece. O que ele produz é uma ideia, que volta ao fluxo principal de construção em [grill-with-docs](https://aihero.dev/skills-grill-with-docs) ou [to-spec](https://aihero.dev/skills-to-spec). Para qual skill se encaixa em uma situação, [how-works](https://aihero.dev/skills-how-works) é o roteador sobre o conjunto inteiro.
