-- Databricks notebook source
-- QUALIDADE: marcar -> auditar -> quarentena.
-- Nenhuma linha é apagada: cada regra grava um "flag" por linha, e a Gold só usa o que não está em quarentena.
-- Severidade 'quarentena' = fora da Gold. 'alerta' = fica na Gold, mas registrado.
-- Os limites (ex.: 24 h) são decisões deste projeto, não da ANAC.

USE CATALOG workspace;

-- COMMAND ----------

CREATE OR REPLACE TABLE silver.qualidade_regras (regra STRING, severidade STRING, descricao STRING);

-- COMMAND ----------

INSERT INTO silver.qualidade_regras VALUES
 ('Q01_sem_horario_previsto',      'quarentena', 'Voo REALIZADO sem partida ou chegada prevista: impossível medir o atraso.'),
 ('Q02_duplicata_exata',           'quarentena', 'Linha idêntica a outra em todas as colunas; só a primeira é mantida.'),
 ('Q03_atraso_extremo',            'quarentena', 'Atraso (partida ou chegada) maior que 24 h em módulo: indício de data registrada errada.'),
 ('Q04_cancelado_com_horario_real','quarentena', 'Voo CANCELADO com horário real preenchido.'),
 ('Q05_realizado_sem_horario_real','quarentena', 'Voo REALIZADO sem partida ou chegada real.'),
 ('Q06_chegada_antes_da_partida',  'quarentena', 'Chegada prevista anterior à partida prevista.'),
 ('Q07_situacao_desconhecida',     'quarentena', 'Situação diferente de REALIZADO ou CANCELADO.'),
 ('Q08_origem_igual_destino',      'alerta',     'Origem = destino (voo circular, treino ou erro). Fica na Gold, mas fora das análises de rota.'),
 ('Q09_horario_com_fracao',        'alerta',     'Horário previsto vinha com fração espúria; normalizado na Silver.');

-- COMMAND ----------

CREATE OR REPLACE TABLE silver.qualidade_flags AS
SELECT id, 'Q01_sem_horario_previsto' AS regra FROM silver.voos
WHERE situacao = 'REALIZADO' AND (partida_prevista IS NULL OR chegada_prevista IS NULL)
UNION ALL
SELECT id, 'Q02_duplicata_exata' FROM (
    SELECT id, row_number() OVER (
        PARTITION BY empresa_icao, numero_voo, tipo_linha, origem_icao, destino_icao, situacao,
                     partida_prevista, partida_real, chegada_prevista, chegada_real
        ORDER BY id) AS rn
    FROM silver.voos
) d WHERE rn > 1
UNION ALL
SELECT id, 'Q03_atraso_extremo' FROM silver.voos
WHERE abs(atraso_partida_min) > 1440 OR abs(atraso_chegada_min) > 1440
UNION ALL
SELECT id, 'Q04_cancelado_com_horario_real' FROM silver.voos
WHERE situacao = 'CANCELADO' AND (partida_real IS NOT NULL OR chegada_real IS NOT NULL)
UNION ALL
SELECT id, 'Q05_realizado_sem_horario_real' FROM silver.voos
WHERE situacao = 'REALIZADO' AND (partida_real IS NULL OR chegada_real IS NULL)
UNION ALL
SELECT id, 'Q06_chegada_antes_da_partida' FROM silver.voos
WHERE chegada_prevista < partida_prevista
UNION ALL
SELECT id, 'Q07_situacao_desconhecida' FROM silver.voos
WHERE situacao NOT IN ('REALIZADO', 'CANCELADO')
UNION ALL
SELECT id, 'Q08_origem_igual_destino' FROM silver.voos WHERE origem_icao = destino_icao
UNION ALL
SELECT id, 'Q09_horario_com_fracao' FROM silver.voos WHERE prevista_com_fracao = 1;

-- COMMAND ----------

-- Quarentena: uma linha por voo com ao menos uma regra de severidade 'quarentena'.
CREATE OR REPLACE TABLE silver.voos_quarentena AS
SELECT f.id, concat_ws(', ', sort_array(collect_list(f.regra))) AS regras
FROM silver.qualidade_flags f
JOIN silver.qualidade_regras r ON r.regra = f.regra
WHERE r.severidade = 'quarentena'
GROUP BY f.id;

-- COMMAND ----------

-- Auditoria: quanto cada regra pegou.
CREATE OR REPLACE TABLE silver.qualidade_resumo AS
SELECT r.regra, r.severidade, r.descricao,
       COUNT(f.id) AS linhas,
       ROUND(100.0 * COUNT(f.id) / (SELECT COUNT(*) FROM silver.voos), 3) AS pct_do_total
FROM silver.qualidade_regras r
LEFT JOIN silver.qualidade_flags f ON f.regra = r.regra
GROUP BY r.regra, r.severidade, r.descricao;

-- COMMAND ----------

SELECT * FROM silver.qualidade_resumo ORDER BY regra;
