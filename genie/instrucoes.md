# Espaço Genie: instruções

**Tabela:** `workspace.gold.obt_voos` (uma linha por voo, já com nomes de empresa e aeroportos).

## Texto de instruções (colar no espaço)

- Sempre responda com **nomes** de empresa e aeroporto (`empresa_nome`, `origem_nome`, `destino_nome`), nunca só com o código ICAO.
- Para atraso, considere só voos com `situacao = 'REALIZADO'` e exclua voos circulares (`origem_icao <> destino_icao`).
- `atraso_partida_min` e `atraso_chegada_min` estão em minutos; valores negativos são voos adiantados.
- Pontual = `pontual_chegada = 1` (chegada com até 15 min de atraso). Partida atrasada = `atrasou_partida_15 = 1`.
- Cancelamento = `cancelado = 1`; a taxa é sobre o total de voos programados da empresa.
- Doméstico/internacional está em `escopo_voo`. Não use `tipo_linha_codigo` para isso.
- Ao comparar empresas ou rotas, exija volume mínimo (ex.: 1.000 voos por empresa, 500 por rota) para evitar médias de amostras pequenas.
- Hora do dia = `hora_prevista` (hora da partida prevista).
- Nunca afirme "atraso herdado": os dados não têm matrícula da aeronave.

## Consultas de exemplo

Use as de `databricks/perguntas/` (P1 a P5) como exemplos de SQL no espaço.

## Teste

Faça as cinco perguntas de `docs/perguntas-de-negocio.md` e compare cada resposta com a consulta SQL correspondente. Registre prints em `evidencias/`.
