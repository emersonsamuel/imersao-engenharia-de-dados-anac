# Aviação ANAC: onde, quando e com quem os voos atrasam no Brasil

Projeto desenvolvido após a **Imersão Engenharia de Dados (Alura)**: pipeline Medallion no Databricks e no SQLite, com camada de qualidade e validação das respostas. Venho de SQL Server (5 anos como DBA), então o foco é **modelagem, qualidade de dados e conferência dos resultados**.

## O problema

Imagine uma consultoria que precisa responder: **quais voos, companhias e rotas mais atrasam no Brasil?** Os dados são os registros mensais de voos da ANAC (12 meses, ago/2025 a jul/2026, 1.014.705 linhas) mais cadastros de aeródromos e empresas aéreas. As cinco perguntas de negócio estão em [`docs/perguntas-de-negocio.md`](docs/perguntas-de-negocio.md).

## Arquitetura

```
CSVs ANAC → Bronze (como veio) → Silver (tipos, nulos, atrasos em minutos)
          → Qualidade (marcar → auditar → quarentena) → Gold (dimensões, fato, OBT)
          → Genie / consultas SQL
```

| pasta | conteúdo |
|---|---|
| `databricks/` | notebooks Bronze (Python/Spark) e SQL de Silver, Qualidade, Gold, perguntas e validações |
| `local-sqlite/` | o mesmo fluxo em SQLite (Python padrão), com testes, para validar os resultados sem Spark |
| `genie/` | instruções para o espaço Genie |
| `docs/` | perguntas de negócio, decisões de escopo e fontes dos dados |

## Validação independente (SQLite)

Reescrevi o fluxo em SQL puro rodando em SQLite, sem instalar nada, para conferir o que o Databricks deve entregar.

```bash
# dados/ na raiz do projeto, na estrutura descrita em docs/fontes.md
python local-sqlite/src/pipeline.py        # ~30 s
python -m unittest discover -s local-sqlite/tests -v
```

O pipeline aborta se `bronze ≠ silver ≠ gold + quarentena`. Um dos testes recalcula, direto do CSV bruto e em Python puro, a pontualidade e o cancelamento da Gol e compara com o SQL. Resultados completos: [`local-sqlite/outputs/resultados.md`](local-sqlite/outputs/resultados.md).

**Conciliação:** bronze 1.014.705 = silver 1.014.705 = gold 983.572 + quarentena 31.133.

## Como rodar no Databricks

1. `databricks/00_ambiente.sql` (schemas e volume; ajuste o catálogo se não for `workspace`).
2. Envie os CSVs para `/Volumes/workspace/bronze/arquivos/vra/` e `.../referencias/`.
3. `01_bronze_voos.py` → `02_bronze_referencias.py` → `03_silver.sql` → `04_qualidade.sql` → `05_gold.sql`.
4. Perguntas em `databricks/perguntas/` e validações em `databricks/validacoes/`.
5. Opcional: espaço Genie com `workspace.gold.obt_voos`, usando `genie/instrucoes.md`.

## O que os dados me ensinaram

- **Qualidade vem antes da análise.** 30.800 voos (3,04%) estavam como realizados sem horário previsto; 41 eram duplicatas exatas; 295 tinham atraso acima de 24 h (provável data errada). Nada foi apagado: foi para quarentena, com a regra registrada.
- **Cuidado com o texto `'null'`.** Os CSVs trazem a palavra `null` em vez de vazio, e 7,86% dos horários previstos vinham com fração espúria de segundo.
- **Atrasa mais no fim do dia.** O atraso médio de partida vai de ~0,8 min (5h) a ~12,3 min (22h). Não dá para afirmar que é "atraso herdado": o arquivo não tem matrícula da aeronave.
- **Internacional atrasa mais.** 74,5% de pontualidade contra 84,6% no doméstico.
- **Entre as três grandes** (≥ 50 mil voos): Gol 87,0% pontual, Azul 85,7%, TAM 80,9%.
- **Os códigos de tipo de linha enganam.** `I` e `G` incluem trechos domésticos, então classifiquei doméstico/internacional pelo aeroporto de cada trecho e validei contra o código (`local-sqlite/outputs/validacao_tipo_linha.csv`).

Definições que são escolhas minhas, e não da ANAC: pontual = chegada com até 15 min de atraso; partida atrasada = mais de 15 min; atraso extremo = mais de 24 h; cortes de volume (rotas ≥ 500 voos, empresas ≥ 1.000 voos).

## Genie (opcional)

Etapa opcional, fora da validação do projeto: as respostas validadas são as consultas SQL de `databricks/perguntas/`.

1. No menu lateral do Databricks, **Genie Agents** → **New**.
2. Em fontes de dados, selecione a tabela `workspace.gold.obt_voos` e clique em **Create**.
3. Em **Configure → Settings**, escolha um SQL warehouse (o **Serverless Starter Warehouse** serve).
4. Em **Configure → Instructions**, cole o texto de [`genie/instrucoes.md`](genie/instrucoes.md) (seção "Texto de instruções") e, se quiser, adicione como consultas de exemplo as de `databricks/perguntas/`.
5. Faça as perguntas de [`docs/perguntas-de-negocio.md`](docs/perguntas-de-negocio.md) e compare cada resposta com a consulta SQL correspondente (os resultados esperados estão em `local-sqlite/outputs/resultados.md`).

## Estado e limites

- **SQLite (local):** executado e testado, 7 testes ok (Windows, Python 3.15).
- **Databricks (Free Edition, serverless), executado em 19/10/2026:** Bronze, Silver, Qualidade, Gold, as consultas P1 a P5 e as validações rodaram, e os números batem com a validação local (conciliação 1.014.705 = 983.572 + 31.133; regras de qualidade idênticas; tabelas das perguntas iguais).
  - Na primeira execução a Bronze de referências divergiu (empresas com ICAO vazio eram descartadas; a leitura dos aeródromos ignorava a codificação ISO-8859-1). Os dois pontos foram corrigidos e revalidados.
  - Nas consultas ranqueadas, empates no valor principal saíam em ordem diferente em cada motor; adicionei critério de desempate fixo.
- Checklist:
  - [x] CSVs no Volume e notebooks Bronze
  - [x] Silver, Qualidade e Gold
  - [x] Conciliação e resultados conferidos com a validação local
  - [x] Consultas P1 a P5 e validações (cobertura de nomes e tipo de linha) executadas e conferidas
  - [x] Prints em `evidencias/`


## Créditos

Projeto desenvolvido após a Imersão Engenharia de Dados da Alura. Dados: ANAC (ver `docs/fontes.md`).
