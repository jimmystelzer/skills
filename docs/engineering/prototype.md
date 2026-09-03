## O que faz

`prototype` escreve **código descartável que responde uma pergunta**: este modelo de estado está certo, ou como deveria parecer esta tela. A pergunta vem primeiro e decide a forma de tudo que segue; um protótipo que responde a pergunta errada é desperdício puro, não importa o quão bom pareça.

Descartável é uma restrição sobre como o código é *escrito*, não uma promessa de destruí-lo. Sem testes, sem tratamento de erros além do que faz ele rodar, sem abstrações, sem persistência, porque nada disso ajuda você a aprender a única coisa que está tentando aprender. O que sobrevive é a resposta, incorporada no código real, e o protótipo em si, estacionado em um branch fora do main como evidência de que a resposta veio de lá.

## Quando usar

Digite `/prototype`, ou o [agent](https://www.aihero.dev/ai-coding-dictionary/agent) o usa automaticamente quando uma tarefa se encaixa.

Use no momento em que você encontrar uma pergunta que não pode resolver conversando: uma máquina de estados cujos edge cases você não consegue manter na cabeça, uma tela que não consegue visualizar até ver três versões lado a lado. Sessões de [questionamento](https://www.aihero.dev/ai-coding-dictionary/grilling) explodem exatamente nessas perguntas: o agent reformula, você adivinha, e o escopo cresce para preencher a incerteza. Pare de questionar, construa a versão descartável, olhe para ela, depois responda em uma linha. Se, em vez disso, algo já construído está se comportando mal e você quer saber por quê, use [diagnosing-bugs](https://aihero.dev/skills-diagnosing-bugs); prototipar explora o que construir, não por que a coisa construída está quebrada.

Você também vai chegar aqui sem escolher. [wayfinder](https://aihero.dev/skills-wayfinder) arquiva tickets de decisão de [prototype](https://www.aihero.dev/ai-coding-dictionary/ticket) em seu mapa, e trabalhar um deles é este skill.

## Dois branches

A pergunta escolhe o branch, e os branches produzem artefatos muito diferentes:

- **"Esta lógica / modelo de estado está certo?"**: um **arquivo HTML compartilhável**. Uma página autocontida, sem build e sem servidor, que alguém abre com um duplo clique. Ela traz um painel de estado rotulado que re-renderiza após cada clique, botões de teste livre para explorar o modelo em qualquer ordem, e **guias passo-a-passo** em abas (um cenário por aba, cada um com os botões ordenados para pressionar abaixo). Tudo é rotulado em linguagem de domínio, então você pode entregar a um designer, um PM ou um especialista em domínio e deixá-los sentir o modelo. A lógica por trás da página é um módulo puro pequeno (um reducer, uma máquina, um conjunto de funções) mantido limpo do DOM para que a versão validada seja incorporada direto no código real.
- **"Como deveria parecer?"**: várias variações de UI **radicalmente diferentes** em uma rota, trocáveis de uma barra flutuante inferior e um parâmetro de URL `?variant=`. As variantes devem discordar sobre estrutura, não cor; três grids de cards ajustados são wallpaper, não um protótipo. Elas renderizam dentro de uma página real sempre que possível, com dados reais e densidade real, porque uma variante avaliada no vácuo sempre parece bem.

Ambas mantêm estado em memória, começam sem exigir pensamento, e mostram o estado completo após cada etapa. No momento em que você se encontrar fortalecendo um (adicionando um teste, conectando o banco de dados real, generalizando para um caso que pode querer depois), você parou de prototipar.

## O protótipo é uma fonte primária

Um protótipo terminado deixa duas coisas, e elas vão para lugares diferentes.

A **resposta** (o veredicto mais a pergunta que resolveu) é capturada de forma duradoura: uma mensagem de commit, um ADR, a issue de implementação. Isso é o que o branch main mantém, incorporado no código real.

O **protótipo** é a evidência executável de onde a resposta veio, e ele não é deletado. Ele também não pertence ao main: não há nada ali para manter e ele degrada rápido. Então ele é commitado em um branch descartável `prototype/<name>` fora do main, nunca mergeado, com um [context pointer](https://www.aihero.dev/ai-coding-dictionary/context-pointer) para aquele branch deixado na issue de implementação. Main fica limpo; a exploração fica encontrável e re-executável por quem pegar o trabalho depois.

## Perguntas frequentes

**Espera, o protótipo não deveria ser deletado?**
Não mais. Costumava ser: construa, guarde a resposta, descarte o código. A objeção mais forte a isso nunca foi sobre velocidade: era *quem pega o trabalho na próxima [session](https://www.aihero.dev/ai-coding-dictionary/session), e com o que trabalha?* Um resumo em texto de um protótipo perde a coisa que o tornou convincente. Então o protótipo agora é tratado como uma [fonte primária](https://www.aihero.dev/ai-coding-dictionary/primary-source): ele cai em um branch `prototype/<name>` fora do main e a issue de implementação aponta para ele. O que mudou é onde o código vive, não a disciplina; ele ainda nunca é mergeado no main.

**Costumava construir um app de terminal. Para onde foi isso?**
A branch de lógica agora emite um único arquivo HTML compartilhável. Um app de terminal só pode ser executado por alguém com o repo clonado e um runtime instalado, o que exclui exatamente as pessoas cuja opinião o protótipo precisa: o designer, o PM, o especialista em domínio que sabe o que o modelo de estado deveria significar. Um arquivo autocontido que abre com duplo clique e sobrevive a ser enviado por email pode ser executado por qualquer um. O módulo de lógica pura por baixo está inalterado, e ainda é a parte que é incorporada no código real.

**Um agent me disse para `/prototype` quando eu deveria estar implementando.**
Conhecido, e é um problema de nomenclatura. `prototype` é uma palavra genérica e atraente que para um agent sem consciência de fluxo lê como "o próximo passo óbvio" quando tickets existem, então é recomendada por nome mesmo quando o design foi completamente resolvido na conversa. Se você já sabe o que construir, o próximo passo é `/implement`, por ticket. Use um protótipo apenas quando uma questão de design específica esteja genuinamente não resolvida e conversar não resolver.

**Devo prototipar a aplicação inteira antes de construir qualquer uma de suas features de produção (por exemplo, para fazer demo para prospectos)?**
Isso é um artefato diferente usando o nome deste skill. Um protótipo aqui está escopado a uma pergunta, e "o que é o app inteiro?" não é uma. Um protótipo de app completo não tem ponto de parada natural, então ele se torna o app de produção por inércia: a etapa de limpeza nunca acontece, e código escrito sob regras de protótipo (sem testes, sem tratamento de erros) acaba na frente dos usuários. Se você precisa de uma demo de vendas, construa-a deliberadamente como uma demo e seja explícito de que nada disso é produção. Se você precisa resolver uma questão de design, reduza-a a essa pergunta.

**Como rodo ele em sua própria session?**
Um protótipo vive em seu próprio diretório e gera muito [context](https://www.aihero.dev/ai-coding-dictionary/context) que você não quer no thread que fez a pergunta, então rode-o em outro lugar e traga de volta apenas a resposta. [handoff](https://aihero.dev/skills-handoff) é a ponte em ambas as direções.

**Isso não é a forma mais rápida de queimar tokens?**
Pode ser, se você prototipar perguntas que poderia ter respondido conversando, ou deixar um protótipo se espalhar por uma feature inteira. A comparação que importa não é tokens contra zero; é [tokens](https://www.aihero.dev/ai-coding-dictionary/token) contra construir o modelo de estado errado e descobrir depois que ele tem chamadores de produção. Mantenha a pergunta estreita e a execução curta, e o gasto fica proporcional.

## Está funcionando se

- Você consegue dizer em uma frase qual pergunta o protótipo existe para responder, e ela está escrita no topo da demo, não apenas na sua cabeça.
- Alguém que não lê código consegue executar a demo de lógica. Eles abrem o arquivo, pressionam os botões em uma aba de guia, e descrevem o que veem em suas próprias palavras.
- Alguém diz "espera, isso não deveria ser possível" ou "huh, eu assumei X". Isso é um bug na *ideia*, que é todo o ponto.
- As variantes de UI discordam sobre layout e hierarquia de informação, não apenas cor e texto, e o feedback que você recebe é "o header de B com a sidebar de C".
- É respondido em uma sessão. Se você ainda está construindo um dia depois, a pergunta era grande demais; divida-a.
- Quando termina, main contém a decisão e nenhum do protótipo, e a issue de implementação aponta para o branch que ainda o mantém.

## Onde se encaixa

`prototype` é um **standalone que você usa a qualquer momento**: você entra nele para resolver uma questão de design, depois sai, e também é mecanismo que outra skill executa.

Seu maior consumidor é [wayfinder](https://aihero.dev/skills-wayfinder). Um mapa wayfinder é feito de **tickets de decisão**, e `prototype` é um dos quatro tipos que um ticket pode ser: o usado quando a pergunta bloqueante é "como deveria parecer" ou "como deveria se comportar", que nenhuma quantidade de discussão resolve. Wayfinder aumenta a fidelidade de uma discussão nebulosa ao tornar algo concreto para reagir, e este skill é como essa coisa concreta é construída. Um ticket de protótipo é resolvido pela resposta, e o protótipo é linkado do mapa como um ativo.

Os outros vizinhos são upstream e downstream disso. [grill-me](https://aihero.dev/skills-grill-me) e [grill-with-docs](https://aihero.dev/skills-grill-with-docs) respondem perguntas questionáveis; as não questionáveis vão para cá, e a resposta de uma linha volta para a entrevista. Downstream, um modelo de estado validado ou direção de UI se torna input estabelecido para [to-spec](https://aihero.dev/skills-to-spec), que pode incorporar o trecho rico em decisões que o protótipo produziu em vez de descrevê-lo em texto. Para qualquer outra coisa, [how-works](https://aihero.dev/skills-how-works) te roteia pelo conjunto inteiro.
