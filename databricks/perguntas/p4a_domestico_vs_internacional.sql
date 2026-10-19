-- Databricks notebook source
USE CATALOG workspace;

-- COMMAND ----------

-- P4a. Voos internacionais atrasam mais que domésticos?
-- Escopo por TRECHO: Doméstico = origem e destino no Brasil. Internacional = ao menos um aeroporto fora.
SELECT escopo_voo,
       COUNT(*)                                   AS voos_realizados,
       ROUND(AVG(atraso_partida_min), 1)          AS atraso_partida_medio_min,
       ROUND(100.0 * AVG(atrasou_partida_15), 1)  AS pct_partida_atrasada_15,
       ROUND(AVG(atraso_chegada_min), 1)          AS atraso_chegada_medio_min,
       ROUND(100.0 * AVG(pontual_chegada), 1)     AS pct_pontual_chegada
FROM gold.obt_voos
WHERE situacao = 'REALIZADO' AND origem_icao <> destino_icao
GROUP BY escopo_voo
ORDER BY escopo_voo;
