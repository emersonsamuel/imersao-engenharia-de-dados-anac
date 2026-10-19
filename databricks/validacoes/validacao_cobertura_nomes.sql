-- Databricks notebook source
USE CATALOG workspace;

-- COMMAND ----------

-- Validação: quantos voos ficam com nome legível (empresa e aeroportos) e quantos caem no código ICAO?
SELECT 'empresa com nome'      AS verificacao, SUM(CAST(empresa_nome <> empresa_icao AS INT)) AS voos, COUNT(*) AS total FROM gold.obt_voos
UNION ALL
SELECT 'origem com nome',      SUM(CAST(origem_nome <> origem_icao AS INT)),  COUNT(*) FROM gold.obt_voos
UNION ALL
SELECT 'destino com nome',     SUM(CAST(destino_nome <> destino_icao AS INT)), COUNT(*) FROM gold.obt_voos;
