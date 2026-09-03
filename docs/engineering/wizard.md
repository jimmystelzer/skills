## O que faz

`wizard` gera um script bash interativo que guia uma pessoa, passo a passo, por um procedimento manual: configurar serviços de terceiros, executar uma migração pontual, mover um projeto do estado A para o estado B. Ele abre cada URL, diz o que clicar e copiar, captura o que volta, e o escreve em arquivos `.env` e GitHub Actions secrets.

O [agent](https://www.aihero.dev/ai-coding-dictionary/agent) escreve o script; ele nunca o executa. Você o executa, na sua própria máquina. Então um wizard não é uma lista de instruções que você segue; é um programa que conduz o procedimento e mantém o estado, e sua parte é clicar, colar, e pressionar Enter.

## Quando acessá-lo

Você pode digitar `/wizard`, e o agent também pode acessá-lo sozinho. Quando ele encontra um passo que você precisa dar (uma chave que ele não pode gerar, um dashboard que ele não pode clicar), ele constrói um wizard para você em vez de escrever as instruções no chat, onde elas rolam para fora.

Acesse-o quando a próxima coisa bloqueando você é uma ida ao dashboard:

| Situação | O que o wizard faz |
| --- | --- |
| Um novo dev precisa de seis serviços configurados antes do app iniciar | Abre cada dashboard em sequência, captura as chaves, as escreve em `.env` e CI |
| Uma migração pontual precisa de switches virados em uma ordem específica | Sequencia os passos irreversíveis atrás de gates de confirmação |
| Um projeto precisa mover do estado A para o estado B uma vez | Guia a transição e relata o que não conseguiu fazer |
| Você está prestes a escrever esses passos em um README | Escreve uma versão executável ao invés, que não pode estragar silenciosamente |

Não acesse para *decidir* o que construir; para isso, [grill-with-docs](https://aihero.dev/skills-grill-with-docs) e [to-spec](https://aihero.dev/skills-to-spec) são as ferramentas.

## Pré-requisitos

Nenhum para gerar um. O wizard que ele escreve roda em bash, e usa `gh` quando uma etapa configura um GitHub secret ou variável. Se `gh` estiver faltando ou não autenticado, aquela etapa se torna um aviso e o resumo final te diz o que configurar à mão, em vez de falhar a execução.

## Etapas

Uma **etapa** é uma tarefa focada em uma tela. O script limpa o terminal entre etapas, então uma etapa que transborda a tela perde a parte que rolou para fora. Você escreve as etapas em ordem de dependência e configura `TOTAL_STAGES`, que controla a exibição de progresso.

O escopo acontece antes que uma linha seja escrita. A [skill](https://www.aihero.dev/ai-coding-dictionary/skill) lê o repo em vez de perguntar friamente: `.env*`, `docker-compose*`, configuração do framework, e toda referência `secrets.*` / `vars.*` em `.github/workflows/`: cada uma dessas é um valor que o wizard precisa produzir. Então ele te mostra a lista ordenada de etapas para confirmar, e só depois mapeia cada etapa ao caminho exato que uma pessoa segue ("Dashboard → Developers → API keys → Reveal test key → copy"). Onde ele não conhece a UI atual, ele pergunta ou verifica a documentação em vez de inventar cliques.

Para cada valor capturado, o escopo determina onde ele vai:

| Destino | Quando |
| --- | --- |
| Apenas `.env` | Dev local precisa, CI não |
| GitHub secret | CI lê, e é sensível |
| GitHub variável | CI lê, e é pública |
| Ambos `.env` e um secret | Dev local e CI precisam |
| Nenhum | A etapa é uma ação pura: um switch virado, um plano atualizado |

## O template já resolve a UX

O [template](https://github.com/mattpocock/skills/blob/main/skills/engineering/wizard/template.sh) entrega toda a experiência: progresso com tempo restante, gates de confirmação, abertura de URL cross-platform incluindo WSL, entrada oculta para secrets, upserts idempotentes de `.env`, escritas `gh secret` / `gh variable`, e um resumo final de tudo que teve que pular. Tudo acima do marcador `STAGES` é uma biblioteca fixa, idêntica em todo wizard e nunca editada à mão. A consistência é o ponto. Seu trabalho é apenas delimitar o procedimento e escrever suas etapas.

O agent que escreve um wizard nunca o executa de ponta a ponta, porque ele abre browsers e espera input humano. Ele verifica estaticamente: `bash -n`, `shellcheck` quando disponível, e uma verificação de que cada valor aterra onde o escopo disse que aterraria, com cada nome `set_secret` correspondendo a uma referência real `secrets.*` no CI. Defina suas expectativas de acordo: a primeira execução é sua, e essa execução é o teste.

## Efêmero por padrão

| O que você tem | O que fazer com o script |
| --- | --- |
| Uma migração pontual, uma configuração pessoal, uma transição que você nunca repetirá | Salve em um caminho scratch ou `scripts/`, execute, delete |
| Um caminho de setup que a próxima pessoa no repo também precisará | Comite e vincule no README, para que ela execute o script em vez de perguntar a um agent novamente |

## Perguntas comuns

**Minhas chaves de API acabam no contexto do model?**

Não. O agent escreve um script; ele não o executa. Você executa o script sozinho, e ele captura a chave com entrada oculta de terminal e a escreve direto em `.env` ou `gh secret`. O wizard é um CLI, e o model não está conectado a ele. Uma ressalva: isso vale para valores que o wizard captura em tempo de execução. Se você colar uma chave no chat ao delimitar o procedimento, ela está no [contexto](https://www.aihero.dev/ai-coding-dictionary/context) como qualquer outro texto colado.

**Posso voltar e corrigir um valor que digitei errado?**

Não no meio da execução. Não há botão voltar: as etapas vão para frente, e uma resposta errada na etapa 3 significa Ctrl-C e re-executar. Re-executar é barato por design: qualquer valor já escrito em `.env` é oferecido de volta como padrão, então você pressiona Enter nas etapas que acertou e redigita apenas a errada. Isso surgiu na semana de lançamento e não foi fechado desde: "adoro! Uma coisa porém, há uma maneira de voltar e corrigir o que você entrou?"

Há um bug relacionado aberto. As setas em um prompt `ask` inserem `^[[D` / `^[[C` em vez de mover o cursor, porque o prompt usa `read -r` em vez de Readline ([issue #741](https://github.com/mattpocock/skills/issues/741)). Backspace funciona; setas não. Delete de volta até o erro em vez de mover o cursor até ele.

**Ele sabe o que eu já configurei?**

Parcialmente, e menos do que as reações de lançamento assumiram. Ele lê o repo antes de perguntar (seus arquivos `.env`, `docker-compose`, configuração do framework, as referências `secrets.*` no CI), então ele delimita para valores que estão genuinamente faltando em vez de começar do zero como um README faz. O que ele não faz é verificar o serviço de terceiros. Se uma chave existe no seu `.env` o wizard a oferece de volta e Enter a mantém; se você já criou a conta do Stripe mas nunca salvou a chave, o wizard ainda te envia para o dashboard.

**Onde ele se sente no workflow, depois de grilling e a spec?**

Em nenhum lugar em particular. É um standalone, não uma etapa de cadeia. O palpite comum é `/grill-with-docs → /to-spec → /wizard`, e essa sequência é fine, mas o gatilho é um procedimento manual aparecendo, o que pode acontecer em qualquer momento: antes de começar, no meio da construção, ou muito depois da entrega. Ele também funciona como ferramenta de descoberta: o escopo surface os pré-requisitos ocultos de uma tarefa, como as três chaves de API que você não tinha pensado, antes de você se comprometer com o trabalho.

**Funciona fora do Claude Code?**

O artefato sim, incondicionalmente: é um script bash comum e não se importa que [harness](https://www.aihero.dev/ai-coding-dictionary/harness) o gerou. A skill em si é model-invoked, então está listada em todo lugar: digite `/wizard` no Claude Code ou `$wizard` no Codex, ou apenas descreva a configuração em que você está travado. Ser model-invoked também a mantém fora do [#693](https://github.com/mattpocock/skills/issues/693), onde as superfícies desktop e web do Claude removem skills *user-invoked* da listagem do [model](https://www.aihero.dev/ai-coding-dictionary/model) e as reportam como não instaladas.

**Isso antes não era user-invoked?**

Era. Agora é model-invoked, então o agent o acessa sem ser pedido quando encontra um passo que você precisa dar. Nada que você fazia antes parou de funcionar: model-invocation *adiciona* o acesso do agent, nunca remove o seu, então `/wizard` se comporta exatamente como antes. O que mudou é o modo de falha que ele aposenta: o agent batendo num muro de credenciais no meio da construção e despejando seis passos numerados no chat para você seguir à mão.

**Isso antes ficava em `in-progress/`: onde está agora?**

`engineering/`, a partir da v1.2. Ele se formou do bucket beta e é entregue com o resto do conjunto promovido em vez de precisar de uma instalação individual. Seu comportamento não mudou na formatura.

## Está funcionando se

- Você é mostrado uma lista ordenada de etapas, e os valores que cada uma produz, e pedido para confirmar, antes que qualquer script exista.
- Cada URL é aberta antes que o valor daquela página seja pedido. Você nunca é pedido para colar algo que não foi enviado para buscar.
- Secrets são digitados às cegas. Nada sensível ecoa no seu scrollback.
- Cada etapa cabe em uma tela. Nada que você ainda precisa rolou para fora.
- Ctrl-C e re-executar retoma de onde você parou, oferecendo os valores já salvos como padrões.
- A tela final lista o que escreveu, e separadamente lista o que não conseguiu e você tem que terminar à mão.

## Onde se encaixa

`wizard` é um standalone que pode ser acessado a qualquer momento, sentado na linha onde a automação para e uma pessoa precisa clicar. Seu vizinho mais próximo é [setup-skills](https://aihero.dev/skills-setup-skills), porque ambos existem para colocar um repo em estado funcional: aquele configura este conjunto de skills, enquanto `wizard` gera um caminho de setup para todo o resto. Ele também combina com [implement](https://aihero.dev/skills-implement): quando uma construção entrega uma funcionalidade que precisa de credenciais ou um corte manual, um wizard é como a metade humana é feita. Quando você não tem certeza de qual skill se encaixa no momento, [how-works](https://aihero.dev/skills-how-works) o direciona.
