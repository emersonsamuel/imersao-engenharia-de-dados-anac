-- Databricks notebook source
-- GOLD: dimensões, fato e tabela larga (OBT) para consumo.
-- Granularidade do fato: uma linha por voo (etapa), sem os voos em quarentena.

USE CATALOG workspace;

-- COMMAND ----------

-- Aeroportos usados, com nome/UF do cadastro público da ANAC quando existir.
-- "Brasil" = está no cadastro da ANAC OU o código ICAO tem prefixo brasileiro (SB, SD, SI, SJ, SN, SS, SW).
CREATE OR REPLACE TABLE gold.dim_aeroporto AS
WITH usados AS (
    SELECT origem_icao AS icao FROM silver.voos
    UNION
    SELECT destino_icao FROM silver.voos
),
cadastro AS (
    SELECT codigo_oaci, MIN(nome) AS nome, MIN(municipio) AS municipio, MIN(uf) AS uf
    FROM bronze.aerodromos
    WHERE codigo_oaci <> ''
    GROUP BY codigo_oaci
)
SELECT
    u.icao                                  AS aeroporto_icao,
    COALESCE(c.nome, u.icao)                AS aeroporto_nome,
    c.municipio                             AS municipio,
    c.uf                                    AS uf,
    CASE WHEN c.codigo_oaci IS NOT NULL
           OR substr(u.icao, 1, 2) IN ('SB','SD','SI','SJ','SN','SS','SW')
         THEN 'Brasil' ELSE 'Exterior' END  AS localizacao,
    c.codigo_oaci IS NOT NULL               AS no_cadastro_anac
FROM usados u
LEFT JOIN cadastro c ON c.codigo_oaci = u.icao;

-- COMMAND ----------

-- Empresas aéreas (cadastro nacional + estrangeiro). Uma linha por código ICAO.
CREATE OR REPLACE TABLE gold.dim_empresa AS
SELECT icao AS empresa_icao, razao AS empresa_nome, origem_cadastro, servico, ativa
FROM (
    SELECT e.*, row_number() OVER (
               PARTITION BY icao
               ORDER BY (ativa = 'ATIVA') DESC, origem_cadastro, razao) AS rn
    FROM bronze.empresas e
    WHERE icao <> ''
) x
WHERE rn = 1;

-- COMMAND ----------

CREATE OR REPLACE TABLE gold.fato_voos AS
SELECT
    s.id                              AS voo_id,
    s.empresa_icao,
    s.numero_voo,
    s.tipo_linha                      AS tipo_linha_codigo,
    s.origem_icao,
    s.destino_icao,
    s.data_prevista,
    s.hora_prevista,
    s.situacao,
    CAST(s.situacao = 'CANCELADO' AS INT) AS cancelado,
    s.atraso_partida_min,
    s.atraso_chegada_min,
    -- minutos recuperados em voo: positivo = chegou com menos atraso do que saiu
    s.atraso_partida_min - s.atraso_chegada_min AS recuperado_em_voo_min,
    -- pontual = chegada com até 15 min de atraso (definição deste projeto)
    CASE WHEN s.situacao = 'REALIZADO' THEN CAST(s.atraso_chegada_min <= 15 AS INT) END AS pontual_chegada,
    CASE WHEN s.situacao = 'REALIZADO' THEN CAST(s.atraso_partida_min > 15 AS INT) END  AS atrasou_partida_15
FROM silver.voos s
WHERE s.id NOT IN (SELECT id FROM silver.voos_quarentena);

-- COMMAND ----------

CREATE OR REPLACE TABLE gold.obt_voos AS
SELECT
    f.voo_id, f.numero_voo, f.data_prevista, f.hora_prevista, f.situacao, f.cancelado,
    f.tipo_linha_codigo,
    CASE WHEN o.localizacao = 'Brasil' AND d.localizacao = 'Brasil'
         THEN 'Doméstico' ELSE 'Internacional' END          AS escopo_voo,
    f.empresa_icao,
    COALESCE(e.empresa_nome, f.empresa_icao)                AS empresa_nome,
    f.origem_icao,
    COALESCE(o.aeroporto_nome, f.origem_icao)               AS origem_nome,
    o.uf                                                    AS origem_uf,
    f.destino_icao,
    COALESCE(d.aeroporto_nome, f.destino_icao)              AS destino_nome,
    d.uf                                                    AS destino_uf,
    f.origem_icao || ' > ' || f.destino_icao                AS rota,
    f.atraso_partida_min, f.atraso_chegada_min, f.recuperado_em_voo_min,
    f.pontual_chegada, f.atrasou_partida_15
FROM gold.fato_voos f
LEFT JOIN gold.dim_empresa   e ON e.empresa_icao   = f.empresa_icao
LEFT JOIN gold.dim_aeroporto o ON o.aeroporto_icao = f.origem_icao
LEFT JOIN gold.dim_aeroporto d ON d.aeroporto_icao = f.destino_icao;

-- COMMAND ----------

-- Conciliação: nenhuma linha some (bronze = silver = gold + quarentena)
SELECT (SELECT COUNT(*) FROM bronze.vra)             AS bronze,
       (SELECT COUNT(*) FROM silver.voos)            AS silver,
       (SELECT COUNT(*) FROM silver.voos_quarentena) AS quarentena,
       (SELECT COUNT(*) FROM gold.fato_voos)         AS gold;
