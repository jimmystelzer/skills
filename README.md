# Skills

Skills para agentes de IA focadas em engenharia de software real. Baseadas no projeto [mattpocock/skills](https://github.com/mattpocock/skills), adaptadas e simplificadas.

## Instalação

```bash
npx skills@latest add mattpocock/skills
```

Escolha as skills que quer instalar. Para atualizar depois: `npx skills update`.

### Configuração inicial

Execute `/setup-skills` uma vez por repo. Ele vai configurar:

- O issue tracker (GitHub ou arquivos locais)
- As labels de triagem
- O local dos documentos de domínio

## Skills disponíveis

### Engenharia

| Skill | Descrição |
|---|---|
| `/how-works` | Roteador que indica qual skill usar para sua situação |
| `/grill-with-docs` | Sessão de perguntas que também constrói o modelo de domínio |
| `/triage` | Move issues por um ciclo de triagem |
| `/improve-codebase-architecture` | Analisa o codebase para oportunidades de melhoria |
| `/setup-skills` | Configura issue tracker, labels e docs por repo |
| `/to-spec` | Transforma a conversa em uma spec |
| `/to-tickets` | Divide um plano em tickets com dependências |
| `/implement` | Constrói o trabalho descrito por uma spec ou tickets |
| `/wayfinder` | Planeja trabalho grande como mapa de tickets de decisão |
| `/tdd` | Test-driven development com ciclo red-green-refactor |
| `/code-review` | Review de diff em dois eixos: Standards e Spec |
| `/diagnosing-bugs` | Diagnóstico disciplinado para bugs e regressões |
| `/prototype` | Gera protótipo descartável para perguntas de design |
| `/research` | Investiga questões e salva como Markdown citado |
| `/domain-modeling` | Constrói e afina o modelo de domínio do projeto |
| `/codebase-design` | Disciplina para projetar módulos profundos |
| `/resolving-merge-conflicts` | Resolve conflitos de merge hunk por hunk |
| `/wizard` | Gera wizard bash interativo para passos manuais |

### Produtividade

| Skill | Descrição |
|---|---|
| `/grill-me` | Entrevista incansável sobre plano ou design |
| `/handoff` | Compacta a conversa para outro agente continuar |
| `/teach` | Ensina conceitos ao longo de múltiplas sessões |
| `/to-questionnaire` | Transforma decisão em questionário Markdown |
| `/wait-what` | Repitcha mensagens que não foram compreendidas |
