-- Databricks notebook source
USE CATALOG workspace;

-- COMMAND ----------

-- P1b. Quais aeroportos de origem concentram os maiores atrasos de partida?
-- Aeroportos com pelo menos 5.000 partidas realizadas, sem voos circulares.
SELECT origem_icao, origem_nome, origem_uf,
       COUNT(*)                                   AS voos,
       ROUND(AVG(atraso_partida_min), 1)          AS atraso_medio_min,
       ROUND(100.0 * AVG(atrasou_partida_15), 1)  AS pct_atraso_15
FROM gold.obt_voos
WHERE situacao = 'REALIZADO' AND origem_icao <> destino_icao
GROUP BY origem_icao, origem_nome, origem_uf
HAVING COUNT(*) >= 5000
ORDER BY atraso_medio_min DESC
LIMIT 15;
