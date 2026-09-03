## O que faz

`setup-skills` responde três perguntas sobre um repo: onde as issues vivem, quais são os nomes dos labels de triagem, e onde ficam os docs de domínio. Ele registra as respostas como arquivos markdown sob `docs/agents/`, mais um arquivo de diretrizes resumido em `.ai/guidelines/agent-skills.md`.

Esses arquivos são a única coisa que varia entre repos. Os skills em si são idênticos em todos os lugares; eles leem `docs/agents/issue-tracker.md` em tempo de execução e fazem o que diz. É por isso que o conjunto não está vinculado ao GitHub, e por que nenhum arquivo de skill precisa ser editado para apontá-lo para outro lugar. Invocá-lo com "vincule os skills a um tracker de issues customizado" funciona com qualquer coisa que você possa conectar programaticamente, com zero alterações nos skills.

Ele é um skill baseado em prompt, não um script determinístico. Ele lê seu `git remote`, seus `CLAUDE.md` e `AGENTS.md` existentes (sem nunca editá-los), seu `CONTEXT.md` existente, propõe o que encontrou, e espera que você confirme antes de escrever qualquer coisa.

## Quando usar

Você invoca isso digitando `/setup-skills`; o [agent](https://www.aihero.dev/ai-coding-dictionary/agent) não vai usar por conta própria. Ele é deliberadamente marcado como não-invocável, então nenhum outro skill pode dispará-lo para você.

Use uma vez por repo, antes da primeira uso de qualquer outra skill de engenharia. Se [triage](https://aihero.dev/skills-triage), [to-spec](https://aihero.dev/skills-to-spec), [to-tickets](https://aihero.dev/skills-to-tickets) ou [wayfinder](https://aihero.dev/skills-wayfinder) começam a adivinhar onde suas issues vão, ou aplicam labels que seu tracker não tem, eles ainda não foram configurados aqui. Um repo que já está no meio de um projeto é um bom lugar para rodar; o skill lê o que já existe e nenhum trabalho anterior é desperdiçado.

## Pré-requisitos

Ele escreve no repo que você roda:

| Ele escreve | Onde |
| --- | --- |
| `issue-tracker.md` | `docs/agents/` |
| `domain.md` | `docs/agents/` |
| `triage-labels.md` | `docs/agents/`, apenas quando o skill `triage` está instalado |
| `agent-skills.md` | `.ai/guidelines/`, um arquivo de diretrizes nomeado pelo que documenta |

Tudo é markdown commitado. Não há modo de usuário ou global: a configuração vive no repo, então cada repo tem sua própria cópia.

O skill não escreve nada em `CLAUDE.md` ou `AGENTS.md`. Esses arquivos são deixados para você, ou para [Laravel Boost](https://laravel.com/docs/boost): quando o projeto tem Boost instalado, `boost:install` / `boost:update` regeneram `AGENTS.md` e/ou `CLAUDE.md` mesclando as diretrizes do framework, as diretrizes dos pacotes instalados, e seus arquivos `.ai/guidelines/*.md`, o mesmo mecanismo que o Filament usa para fornecer suas próprias diretrizes.

## As três decisões

Ele lidera cada seção com a resposta recomendada, e pula qualquer exploração que já se estabeleceu. A maioria das execuções são duas confirmações e pronto.

| Decisão | O que ele propõe | Quando realmente pergunta |
| --- | --- | --- |
| **Issue tracker** | aquele que corresponde ao seu `git remote` | sempre: essa é a única escolha real |
| **Labels de triagem** | manter os cinco nomes canônicos (`needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix`) | apenas se o skill `triage` estiver instalado |
| **Docs de domínio** | contexto único: um `CONTEXT.md` mais `docs/adr/` na raiz | apenas se ele detectar sinais de monorepo, e então oferece um `CONTEXT-MAP.md` multi-contexto |

As opções do tracker:

| Opção | Onde as issues vivem | Precisa |
| --- | --- | --- |
| **GitHub** | GitHub Issues do repo | o CLI `gh` |
| **GitLab** | GitLab Issues do repo | o CLI `glab` |
| **Markdown local** | arquivos sob `.scratch/<feature>/` neste repo | nada: sem remote nenhum |
| **Outro** | onde você disser | um parágrafo seu descrevendo o workflow |

Os três primeiros vêm como templates no skill e funcionam imediatamente. Markdown local é uma opção de primeira classe, não um fallback: um projeto solo sem remote é totalmente suportado. Uma ressalva vale repetir: não use markdown local se você estiver usando GitHub. Eles são alternativas, não camadas.

"Outro" também não é um placeholder. É a razão pela qual Jira, Azure DevOps e Beads todos funcionam: você descreve o workflow, o skill registra seu texto em `docs/agents/issue-tracker.md`, e os skills downstream seguem o texto. A comunidade já fez isso: uma variante Jira-over-[MCP](https://www.aihero.dev/ai-coding-dictionary/mcp), um CLI Gitea moldado como `gh`, um dashboard local construído manualmente.

## Perguntas frequentes

**Preciso usar GitHub?**

Não. GitHub, GitLab e markdown local sob `.scratch/` todos vêm como templates prontos, e qualquer outro funciona através do caminho "outro". Esta é a pergunta mais repetida no registro, mais ou menos nestas palavras: *"hard locked to github"*, *"can I use GitLab / Jira"*, *"what about Azure DevOps"*. A resposta toda vez é que o tracker é uma resposta de configuração, não uma propriedade do skill.

**Preciso rodá-lo novamente após atualizar os skills?**

Perguntado diretamente após a v1.1, Matt disse que sim. A mensagem de encerramento do próprio skill é mais suave: diz que rodar novamente só é necessário para trocar trackers ou recomeçar. Ambos são justificáveis e a razão da lacuna é real: os templates semente mudam entre versões, então um `docs/agents/issue-tracker.md` escrito por uma versão mais antiga pode ficar desatualizado em relação aos skills que agora o leem. Se um skill downstream começa a fazer algo que os docs descrevem diferente, rodar novamente é a correção barata.

**Ele toca no meu `CLAUDE.md` ou `AGENTS.md`?**

Não. Versões anteriores escolhiam um desses arquivos e escreviam um bloco `## Agent skills` nele, o que significava que um repo com um `CLAUDE.md` do Claude Code recebia o bloco em algum lugar que o Codex nunca lê. Essa regra foi removida. O skill agora escreve apenas em `.ai/guidelines/agent-skills.md`, o diretório que o [Laravel Boost](https://laravel.com/docs/boost) mergeia em quaisquer arquivos de instrução que a configuração Boost do seu projeto gera, então a mesma saída cai no lugar certo em qualquer [harness](https://www.aihero.dev/ai-coding-dictionary/harness). Em um repo sem Boost, os skills downstream ainda encontram sua configuração através dos caminhos `docs/agents/` em tempo de execução; adicione um pointer de uma linha no seu `AGENTS.md` se quiser os resumos sempre no contexto. Um bloco `## Agent skills` remanescente de uma execução mais antiga é migrado para o arquivo de diretrizes e deletado do arquivo raiz.

**Ele não criou meus labels de triagem.**

Ele não cria. `docs/agents/triage-labels.md` é um *mapeamento*: diz ao `/triage` quais strings no seu tracker correspondem aos cinco papéis canônicos. Ele não roda `gh label create`. Em um repo GitHub novo, os labels genuinamente não existem ainda, e isso foi reportado como bug mais de duas vezes. Duas observações:

- Se seu tracker já usa os nomes canônicos, o mapeamento é uma tabela de identidade e não há nada a configurar. Esse é o caso comum pretendido, não uma etapa faltando.
- Os labels `wayfinder:map` e `wayfinder:<type>` do [wayfinder](https://aihero.dev/skills-wayfinder) também não são criados aqui, e `gh issue create --label <missing>` falha em vez de criar o label. Crie-os manualmente antes da primeira execução do wayfinder em um repo GitHub.

**Posso configurar o comportamento dos outros skills aqui ([cadência de questionamento](https://www.aihero.dev/ai-coding-dictionary/grilling), formato de pergunta, tom)?**

Não. Ele configura três coisas: tracker, labels, layout de docs. Houve pedidos diretos para torná-lo o local para preferências por usuário, e a resposta permanente é que os skills continuam opinativos: *"Config é morte."* Preferências pertencem ao seu `CLAUDE.md` como instruções simples, que todo skill já lê.

**Posso manter a configuração em `~/.claude` em vez de fazer commit em cada repo?**

Não hoje. Há um pedido em aberto exatamente disso de alguém rodando os skills em muitos repos, e nenhum modo de usuário existe. Cada repo carrega seu próprio `docs/agents/`.

**Não é estranho ter um skill que configura os outros skills?**

Uma reclamação de longa data diz que sim, nestas palavras: *"ter um skill para configurar o outro skill não parece certo para mim: isso significa que o LLM está configurando seus próprios skills."* O trade-off é real e reconhecido: a alternativa a uma etapa de configuração é duplicar as instruções do tracker em cada skill que toca em issues. A saída é markdown inspecionável e editável, o que é a mitigação: você pode ler cada arquivo que ele escreveu e alterá-lo manualmente, e os ajustes diários são exatamente isso, não outra execução.

## Está funcionando se

- `docs/agents/issue-tracker.md` e `docs/agents/domain.md` existem, mais `triage-labels.md` se `triage` estiver instalado.
- `.ai/guidelines/agent-skills.md` existe com um resumo de uma linha apontando para cada um desses arquivos, e `CLAUDE.md` / `AGENTS.md` foram deixados intocados. Em um projeto Boost, um `boost:update` incorpora o arquivo de diretrizes nos arquivos de instrução gerados.
- O tracker que ele propôs corresponde ao remote que você realmente usa, e as strings dos labels correspondem a labels que realmente existem no seu tracker.
- Depois, `/to-tickets` publica sem perguntar onde as issues vivem, e `/triage` aplica labels em vez de inventá-los.
- Nada nos arquivos de skill em si mudou. Se o setup editou um `SKILL.md`, algo deu errado.

## Onde se encaixa

`setup-skills` é a **configuração de uma única execução** para o fluxo de engenharia, a pré-condição que todos os outros assumem em vez de uma etapa na cadeia. Seus vizinhos são seus leitores: [triage](https://aihero.dev/skills-triage), que aplica o vocabulário de labels escrito aqui; [to-spec](https://aihero.dev/skills-to-spec) e [to-tickets](https://aihero.dev/skills-to-tickets), que publicam no tracker nomeado aqui; e [wayfinder](https://aihero.dev/skills-wayfinder), que lê a seção "Wayfinding operations" do mesmo arquivo do tracker para saber como mapas e [tickets](https://www.aihero.dev/ai-coding-dictionary/ticket) filhos são armazenados. O layout de docs de domínio que ele registra é o que [domain-modeling](https://aihero.dev/skills-domain-modeling) preenche depois: ele cria `CONTEXT.md` e ADRs preguiçosamente, quando um termo ou decisão é realmente resolvido, então um repo vazio após a configuração é o estado esperado. Para qual skill usar depois, [how-works](https://aihero.dev/skills-how-works) roteia o conjunto inteiro.
