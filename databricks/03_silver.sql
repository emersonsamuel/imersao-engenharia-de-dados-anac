-- Databricks notebook source
-- SILVER: tipos corretos, nulos reais e métricas de atraso.
-- Decisões:
--   * O CSV usa a palavra 'null' (texto) para ausência: vira NULL de verdade.
--   * Parte dos horários previstos vem com fração espúria ('.100000000'): usamos só os 19 primeiros caracteres
--     (AAAA-MM-DD HH:MM:SS) e registramos que a fração existia (prevista_com_fracao).
--   * Atrasos em minutos inteiros: negativo = adiantado.

USE CATALOG workspace;

-- COMMAND ----------

CREATE OR REPLACE TABLE silver.voos AS
WITH t AS (
    SELECT
        id, arquivo, empresa_icao, numero_voo, tipo_linha, origem_icao, destino_icao, situacao,
        to_timestamp(substr(NULLIF(partida_prevista, 'null'), 1, 19)) AS pp,
        to_timestamp(substr(NULLIF(partida_real,     'null'), 1, 19)) AS pr,
        to_timestamp(substr(NULLIF(chegada_prevista, 'null'), 1, 19)) AS cp,
        to_timestamp(substr(NULLIF(chegada_real,     'null'), 1, 19)) AS cr,
        CAST(length(partida_prevista) = 29 AS INT) AS prevista_com_fracao
    FROM bronze.vra
)
SELECT
    id, arquivo, empresa_icao, numero_voo, tipo_linha, origem_icao, destino_icao, situacao,
    pp AS partida_prevista,
    pr AS partida_real,
    cp AS chegada_prevista,
    cr AS chegada_real,
    CAST(round((unix_timestamp(pr) - unix_timestamp(pp)) / 60.0) AS INT) AS atraso_partida_min,
    CAST(round((unix_timestamp(cr) - unix_timestamp(cp)) / 60.0) AS INT) AS atraso_chegada_min,
    CAST(pp AS DATE) AS data_prevista,
    hour(pp)         AS hora_prevista,
    prevista_com_fracao
FROM t;

-- COMMAND ----------

-- Conferência: a Silver tem o mesmo número de linhas da Bronze?
SELECT (SELECT COUNT(*) FROM bronze.vra) AS bronze, (SELECT COUNT(*) FROM silver.voos) AS silver;
