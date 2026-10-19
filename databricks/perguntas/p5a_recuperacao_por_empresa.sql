-- Databricks notebook source
USE CATALOG workspace;

-- COMMAND ----------

-- P5a. Quanto atraso as companhias recuperam em voo?
-- recuperado = atraso de partida - atraso de chegada (positivo = chegou com menos atraso do que saiu).
-- Empresas com pelo menos 1.000 voos realizados. A coluna "nos_atrasados" olha só partidas com > 15 min de atraso.
SELECT empresa_nome,
       COUNT(*)                                                            AS voos_realizados,
       ROUND(AVG(recuperado_em_voo_min), 1)                                AS recuperado_medio_min,
       ROUND(AVG(CASE WHEN atrasou_partida_15 = 1 THEN recuperado_em_voo_min END), 1) AS recuperado_nos_atrasados_min
FROM gold.obt_voos
WHERE situacao = 'REALIZADO' AND origem_icao <> destino_icao
GROUP BY empresa_nome
HAVING COUNT(*) >= 1000
ORDER BY recuperado_nos_atrasados_min DESC
LIMIT 20;
