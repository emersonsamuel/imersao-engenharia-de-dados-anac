-- Databricks notebook source
-- Ambiente: schemas e volume. Ajuste o catálogo na linha abaixo se o seu não for "workspace".

USE CATALOG workspace;

-- COMMAND ----------

CREATE SCHEMA IF NOT EXISTS bronze;

-- COMMAND ----------

CREATE SCHEMA IF NOT EXISTS silver;

-- COMMAND ----------

CREATE SCHEMA IF NOT EXISTS gold;

-- COMMAND ----------

-- Volume onde os CSVs da ANAC são enviados:
--   /Volumes/workspace/bronze/arquivos/vra/          (os 12 CSVs mensais de voos)
--   /Volumes/workspace/bronze/arquivos/referencias/  (AerodromosPublicos.csv e os dois pda_empresas_*.csv)
CREATE VOLUME IF NOT EXISTS bronze.arquivos;
