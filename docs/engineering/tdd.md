## O que faz

`tdd` constrói uma funcionalidade ou corrige um bug em primeiro lugar por testes: um teste falhando, depois apenas código suficiente para fazê-lo passar, depois o próximo comportamento. Ele carrega os padrões que fazem esse loop produzir testes que valem a pena manter: o que é um bom teste, onde os testes ficam, para que servem mocks, e os três anti-padrões que silenciosamente arruinam uma suíte.

Ele não escreve nenhum teste em um seam que você não tenha concordado antes. Antes que qualquer teste exista, ele nomeia os limites públicos nos quais pretende testar e para para sua confirmação, porque o esforço de teste é finito e é aqui que você o gasta nos caminhos críticos em vez de em cada caso de borda. A outra coisa a saber é que `tdd` é uma **referência**, não um controlador. Ele mantém as regras do loop, e outra coisa (você, ou [implement](https://aihero.dev/skills-implement)) executa a [session](https://www.aihero.dev/ai-coding-dictionary/session) que as aplica.

## Quando acessá-lo

Digite `/tdd`, ou o [agent](https://www.aihero.dev/ai-coding-dictionary/agent) o acessa automaticamente quando uma tarefa se encaixa: construir uma funcionalidade ou corrigir um bug em primeiro lugar por testes, ou quando você diz "red-green-refactor".

Acesse-o quando há um comportamento concreto para construir, com uma entrada e uma saída observável, e você quer testes que sobrevivam a um refactor.

| Sua situação | Para onde ir |
| --- | --- |
| Um comportamento com entradas e saídas definidas (lógica de negócio, um contrato request/response, uma transformação, validação) | `tdd` |
| O comportamento ainda não foi fixado | [to-spec](https://aihero.dev/skills-to-spec), que também concorda com os seams de teste antes que qualquer código seja escrito |
| A questão é realmente a forma da interface, não os testes | [codebase-design](https://aihero.dev/skills-codebase-design) |
| Você tem uma [spec](https://www.aihero.dev/ai-coding-dictionary/spec) ou [tickets](https://www.aihero.dev/ai-coding-dictionary/ticket) e quer que toda a construção seja executada para você | [implement](https://aihero.dev/skills-implement), que conduz `tdd` por ticket |
| Configuração, wiring, glue, anotações de tipo, delegação CRUD direta | Nada aqui se encaixa bem; veja a lacuna aberta abaixo |

Aquela última linha é uma lacuna real, não uma preferência estilística. A skill decide *onde* os seams ficam; nada nela decide *se* uma mudança vale o loop. Execute-a em uma mudança sem uma fonte independente de verdade para afirmar contra e você obterá um teste que reenuncia a implementação: o anti-padrão tautológico que a skill em si avisa, chegando pela outra direção. É o [issue #746](https://github.com/mattpocock/skills/issues/746) e está aberto. Até que feche, esse julgamento é seu ou do seu `CLAUDE.md`.

## Pré-requisitos

[codebase-design](https://aihero.dev/skills-codebase-design) precisa estar instalado. `tdd` costumava carregar suas próprias notas de deep-module e interface-design; na v1.0 essas foram deletadas em favor da skill compartilhada, e `tdd` agora se apoia nela para o vocabulário de interface-design. Mais nada; a skill é [stateless](https://www.aihero.dev/ai-coding-dictionary/stateless) e não escreve arquivos próprios.

## O loop, e o seam onde ele roda

Três palavras carregam esta skill.

**Red-green.** Escreva o teste falhando, depois apenas código suficiente para fazê-lo passar. Sem antecipar o teste seguinte. Não há fase de refactor: ela foi removida em junho de 2026 porque agentes basicamente nunca a executaram, e porque revisão e implementação funcionam melhor como sessões separadas. Refactor pertence ao [code-review](https://aihero.dev/skills-code-review).

**Vertical slice.** Um seam, um teste, uma implementação mínima, depois repita, sendo o primeiro ciclo uma **tracer bullet** que prova um único caminho de ponta a ponta. O oposto é o corte horizontal: todos os testes primeiro, depois todo o código. Testes em massa verificam comportamento *imaginado*, eles verificam a forma das coisas em vez do que um usuário faz, e te comprometem com uma estrutura de teste antes de você entender a implementação.

**Seam pré-acordado.** Um seam é o limite público onde você observa o comportamento sem reaching inside. A regra é absoluta: nenhum teste em um seam não confirmado. Na cadeia completa os seams são acordados antes, durante [to-spec](https://aihero.dev/skills-to-spec): "`/tdd` é informado para trabalhar apenas em seams de teste pré-acordados, `/code-review` verifica que apenas os seams de teste acordados foram usados." Invocado sozinho, `tdd` pergunta diretamente a você.

Os três anti-padrões que foi escrito para prevenir:

| Anti-padrão | O sinal |
| --- | --- |
| Acoplado à implementação | O teste quebra quando você renomeia uma função interna, embora o comportamento não tenha mudado. Colaboradores internos mocked, contagens de chamadas afirmadas, consultas de banco de dados usadas para verificar em vez da interface. |
| Tautológico | O valor esperado é computado da mesma forma que o código computa, então o teste passa por construção. Valores esperados devem vir de algum outro lugar: um literal conhecido como bom, um exemplo trabalhado, a spec. |
| Corte horizontal | Um lote de testes lançados antes de qualquer implementação |

Mocks são apenas para limites do sistema: APIs externas, tempo, aleatoriedade, às vezes o sistema de arquivos ou o banco de dados. Não os seus próprios módulos.

## Perguntas comuns

**Por que ele não faz refactor? A descrição diz "red-green-refactor".**

Porque a etapa de refactor foi removida e a descrição não foi. A remoção foi deliberada: agentes basicamente nunca a faziam, e manter implementação e revisão em sessões separadas funciona melhor. Se o resultado ainda conta como TDD pelo livro importa menos do que se o loop produz código melhor. A discrepância entre a frase de ativação e o corpo está registrada como [issue #589](https://github.com/mattpocock/skills/issues/589) e continua aberta, então "red-green-refactor" continua funcionando como frase que ativa a skill. O que você obtém é red → green, e refactor em [code-review](https://aihero.dev/skills-code-review).

**Ele me pediu para escolher um seam de teste e eu não tinha ideia qual escolher.**

Esta é a fricção mais reportada com a skill ([issue #607](https://github.com/mattpocock/skills/issues/607)). O prompt lista candidatos a seams apenas pelo nome, sem nada sobre o que cada um pega ou perde, então você está escolhendo entre rótulos. Não há correção lançada ainda. A solução prática é pedir ao agent os trade-offs antes de responder: o que o seam de nível de componente perde que o seam de integração pega, e o quão mais lento é. É também por isso que a cadeia concorda com os seams antecipadamente em `to-spec`, onde você tem a funcionalidade inteira em vista em vez de um único prompt.

**Ele escreveu a implementação antes do teste, embora a skill diga red primeiro.**

Acontece. Um usuário pressionou o [model](https://www.aihero.dev/ai-coding-dictionary/model) sobre isso e obteve uma resposta incomumente honesta: "Eu sabia que a skill dizia 'um teste por vez, veja ele falhar pelo motivo certo'. Eu li. Apenas voltei ao meu hábito normal." A skill foi escrita para conviver com isso. Nenhuma instrução faz um agent cumprir 100% do tempo, e forçar mais restrige a criatividade do agent com pouco ganho; o loop vale a pena ser executado mesmo quando não é seguido estritamente, porque os resultados ainda são melhores no geral. Se a aderência estrita importa para um slice específico, observe a execução em vez de confiar que a skill a impõe.

**Deveria escrever testes de browser ou end-to-end primeiro?**

Geralmente não, e a skill não o impedirá. Um usuário reportou o agent escrevendo um teste Playwright primeiro, depois gastando um longo loop re-executando-o e concluindo que o *teste* estava quebrado para uma funcionalidade que ainda não existia. Configure isso no seu `CLAUDE.md`. Testes de browser são lentos o suficiente para que o loop de feedback red-green pare de se pagar; declare no `CLAUDE.md` do seu repo que eles são escritos depois que o comportamento funciona.

**`/tdd` substitui `/implement`, ou o `/do-work` do curso?**

Não. `/tdd` documenta a metodologia; `/implement` é um loop muito simples de trabalho→feedback→commit e é o substituto direto para `/do-work`. O passo único `/do-work` do curso agora está dividido entre `/implement`, `/tdd` e `/code-review`. Se você está perguntando qual executar contra um ticket, a resposta é quase sempre `/implement`.

**Para onde foram os deep-modules e o guia de interface-design?**

Para [codebase-design](https://aihero.dev/skills-code-design) na v1.0, generalizado para que várias skills compartilhem um vocabulário. `refactoring.md` saiu ao mesmo tempo; refactoring agora é trabalho do [code-review](https://aihero.dev/skills-code-review), e essa skill carrega a linha de base de smells do Fowler.

**Ele conhece meus outros tickets?**

Não. Executado contra um ticket, ele propõe felizmente trabalho que pertence a um ticket irmão, porque não tem visão do resto do grafo de issues ([issue #129](https://github.com/mattpocock/skills/issues/129)). A posição de Matt é que isso não é trabalho do `tdd`. Passar a spec junto com o ticket ajuda; dimensionar corretamente os tickets desde o início ajuda mais.

## Está funcionando se

- Ele para e nomeia os seams onde pretende testar, e espera, antes que qualquer arquivo de teste exista.
- Um teste aparece, fica vermelho, recebe código suficiente para passar, e somente então o próximo teste aparece, não um lote de testes seguido de um lote de código.
- Nomes de testes leem como capacidades ("user can checkout with valid cart"), não como internos ("checkout calls paymentService.process").
- Valores esperados em asserções são literais que você pode rastrear até a spec, não valores recomputados da forma que o código computa.
- Renomear uma função interna não quebra nada na suíte.
- Mocks aparecem apenas em limites externos (a API de pagamento, o relógio) e nunca ao redor de seus próprios módulos.

## Onde se encaixa

`tdd` é o motor dentro da etapa de construção da cadeia principal, em vez de uma etapa própria:

```txt
grill-with-docs → to-spec → to-tickets → implement → code-review
```

[to-spec](https://aihero.dev/skills-to-spec) concorda com os seams de teste antecipadamente, [implement](https://aihero.dev/skills-implement) conduz `tdd` por ticket, e [code-review](https://aihero.dev/skills-code-review) verifica depois que apenas os seams acordados foram usados, e assume o refactoring que `tdd` não faz mais. Seu outro vizinho é [codebase-design](https://aihero.dev/skills-codebase-design), a fonte compartilhada do vocabulário de seams e deep-modules que `tdd` fala. Você também pode acessá-lo sozinho, sempre que há um comportamento concreto para construir e nenhuma spec completa em jogo. Quando você não tem certeza de qual skill se encaixa em sua situação, [how-works](https://aihero.dev/skills-how-works) o direciona.
