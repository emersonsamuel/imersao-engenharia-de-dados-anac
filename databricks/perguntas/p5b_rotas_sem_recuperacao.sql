-- Databricks notebook source
USE CATALOG workspace;

-- COMMAND ----------

-- P5b. Em que rotas o atraso NÃO é recuperado (ou piora) em voo?
-- Rotas com pelo menos 200 partidas atrasadas (> 15 min); ordenadas do pior (mais negativo) ao melhor.
SELECT rota, origem_nome, destino_nome,
       COUNT(*)                              AS partidas_atrasadas,
       ROUND(AVG(atraso_partida_min), 1)     AS atraso_partida_medio_min,
       ROUND(AVG(atraso_chegada_min), 1)     AS atraso_chegada_medio_min,
       ROUND(AVG(recuperado_em_voo_min), 1)  AS recuperado_medio_min
FROM gold.obt_voos
WHERE situacao = 'REALIZADO' AND origem_icao <> destino_icao AND atrasou_partida_15 = 1
GROUP BY rota, origem_nome, destino_nome
HAVING COUNT(*) >= 200
ORDER BY recuperado_medio_min ASC
LIMIT 15;
