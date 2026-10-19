# Perguntas de negócio

O pipeline existe para responder cinco perguntas sobre atrasos de voos no Brasil. Cada uma tem uma consulta em `databricks/perguntas/` (e a versão SQLite em `local-sqlite/sql/perguntas/`).

| id | pergunta | arquivo |
|---|---|---|
| P1 | Quais rotas e aeroportos concentram os maiores atrasos de partida? | `p1a_rotas_mais_atrasadas`, `p1b_aeroportos_mais_atrasados` |
| P2 | Como o atraso evolui ao longo do dia? | `p2_atraso_por_hora` |
| P3 | Qual companhia tem melhor pontualidade e menos cancelamentos, comparando empresas do mesmo porte? | `p3_pontualidade_por_empresa` |
| P4 | Voos internacionais atrasam mais que domésticos? Em quais aeroportos a diferença é maior? | `p4a_domestico_vs_internacional`, `p4b_diferenca_por_aeroporto` |
| P5 | Quanto atraso as companhias recuperam em voo, e em que rotas isso não acontece? | `p5a_recuperacao_por_empresa`, `p5b_rotas_sem_recuperacao` |

## Decisões de escopo

- **Só o "onde, quando e quanto".** O campo de justificativa do atraso não traz informação útil nos dados (sempre `N/A` nos arquivos que usei), então não tento explicar o motivo declarado. Uso fatores medidos: hora do dia, aeroporto, companhia, doméstico/internacional.
- **Atraso herdado não é mensurável.** Não há matrícula da aeronave, então a curva por hora de P2 mostra um padrão agregado, não a propagação de um voo para o seguinte.
- **Definições minhas:** pontual = chegada com até 15 min de atraso; partida atrasada = mais de 15 min; recuperado em voo = atraso de partida − atraso de chegada.
- **Doméstico/internacional por trecho**, derivado dos aeroportos (cadastro da ANAC ou prefixo ICAO brasileiro), porque os códigos de tipo de linha incluem trechos domésticos em `I` e `G`.

## Como conferir uma resposta

Toda resposta do Genie deve ser conferida contra a consulta SQL correspondente. Se divergirem, vale o SQL, e a divergência vira um ajuste nas instruções do Genie.
