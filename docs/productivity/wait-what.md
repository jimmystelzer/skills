## O que faz

`wait-what` é o que você digita quando uma mensagem não ficou clara. O [agent](https://www.aihero.dev/ai-coding-dictionary/agent) então reformula o que acabou de dizer. Adiciona o contexto que faltava, escreve em inglês simples, e usa o vocabulário do `CONTEXT.md` do seu projeto.

A skill tem três linhas de comprimento. Isso é o design, não um rascunho inacabado. Skills que combatem verbosidade falham por crescer: uma skill de concisão de quatrocentas linhas ainda deixa o [model](https://www.aihero.dev/ai-coding-dictionary/model) verboso, porque o model lê o volume, não o apelo. Esta carrega uma única palavra inicial precisa e nada mais.

## Quando usar

Você invoca digitando `/wait-what`. O agent não busca por conta própria, e não deveria. Só você sabe quando parou de acompanhar.

Use no momento em que notar que está lendo por cima. O agent derivou para jargão que inventou, empilhou cinco siglas, ou explicou uma decisão cuja premissa você nunca viu. Ele conserta a conversa que você já está. Para parar o jargão de chegar, use [grill-with-docs](https://aihero.dev/skills-grill-with-docs), que constrói a linguagem compartilhada de antemão.

## O nome é o mecanismo

A palavra inicial é **wait**. "Seja conciso" é uma instrução sobre a saída do agent, e o model obedece recortando palavras e te perdendo ainda mais. **Wait** é sobre *seu* estado. Diz que a compreensão falhou aqui. Um agent que ouve "seja breve" escreve telegraficamente. Um agent que ouve "wait, você me perdeu" volta e explica.

Essa diferença é a skill inteira. Toda correção popular para verbosidade nomeia a *saída*: `/tldr`, `/no-fluff`, `/talk-normal`. O model super-corrige para um registro primitivo que é mais curto e não mais claro. Nomear o *ouvinte* pede as duas metades ao mesmo tempo: menos palavras **e** o contexto que faltava.

A skill diz reformular **aquilo**, não "essa última mensagem". O que te perdeu geralmente é maior do que um parágrafo, então o agent decide quão longe voltar.

## Ele se conecta à linguagem que você já tem

O corpo reutiliza as palavras iniciais que já estão no seu `CLAUDE.md` global e no `CONTEXT.md` do seu projeto. ASD-STE100 Simplified Technical English define o registro. A linguagem ubíqua fornece os substantivos. A skill, `CLAUDE.md` e `CONTEXT.md` buscam os mesmos [tokens](https://www.aihero.dev/ai-coding-dictionary/token), então invocá-la não é uma nova instrução. É um lembrete de uma que o agent já concordou.

Se você não tem `CONTEXT.md` (e nenhum `CONTEXT-MAP.md` apontando para um no contexto atual), a skill ainda funciona. Você só perde a metade do vocabulário de domínio.

## Está funcionando se

- A reformulação é **mais curta e mais clara**, não mais curta e mais abrupta.
- Adiciona a premissa que faltava, em vez de apenas apagar palavras.
- Substantivos do projeto substituem os inventados. Os termos do seu `CONTEXT.md` voltam.
- Você pode usá-la duas vezes seguidas, e ela não degrada para concisão brusca.

## Onde se encaixa

Você pode usar `wait-what` a qualquer momento, em qualquer conversa, dentro de qualquer outra skill. Ela conserta uma mensagem após o fato. A cura real é uma linguagem compartilhada acordada de antemão, e isso é [grill-with-docs](https://aihero.dev/skills-grill-with-docs): uma session de [grilling](https://www.aihero.dev/ai-coding-dictionary/grilling) que executa [domain-modeling](https://aihero.dev/skills-domain-modeling) conforme avança, para que as palavras que ambos usam aterrissem no seu `CONTEXT.md`. Se não tem certeza qual skill se encaixa no momento, [how-works](https://aihero.dev/skills-how-works) o direciona.
