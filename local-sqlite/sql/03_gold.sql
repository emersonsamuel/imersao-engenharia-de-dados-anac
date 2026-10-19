-- GOLD: dimensões, fato e tabela larga (OBT) para consumo.
-- Granularidade do fato: uma linha por voo (etapa), sem os voos em quarentena.

-- Aeroportos usados nos voos, com nome/UF do cadastro público da ANAC quando existir.
-- "Brasil" = está no cadastro da ANAC OU o código ICAO tem prefixo brasileiro (SB, SD, SI, SJ, SN, SS, SW).
-- Essa classificação é validada contra o código de tipo de linha em outputs/validacao_tipo_linha.csv.
DROP TABLE IF EXISTS dim_aeroporto;
CREATE TABLE dim_aeroporto AS
WITH usados AS (
    SELECT origem_icao AS icao FROM silver_voos
    UNION
    SELECT destino_icao FROM silver_voos
),
cadastro AS (
    SELECT codigo_oaci, MIN(nome) AS nome, MIN(municipio) AS municipio, MIN(uf) AS uf
    FROM b_aerodromos
    WHERE codigo_oaci <> ''
    GROUP BY codigo_oaci
)
SELECT
    u.icao                                 AS aeroporto_icao,
    COALESCE(c.nome, u.icao)               AS aeroporto_nome,
    c.municipio                            AS municipio,
    c.uf                                   AS uf,
    CASE WHEN c.codigo_oaci IS NOT NULL
           OR substr(u.icao, 1, 2) IN ('SB','SD','SI','SJ','SN','SS','SW')
         THEN 'Brasil' ELSE 'Exterior' END AS localizacao,
    c.codigo_oaci IS NOT NULL              AS no_cadastro_anac
FROM usados u
LEFT JOIN cadastro c ON c.codigo_oaci = u.icao;

-- Empresas aéreas (cadastro nacional + estrangeiro da ANAC). Uma linha por código ICAO.
DROP TABLE IF EXISTS dim_empresa;
CREATE TABLE dim_empresa AS
SELECT icao AS empresa_icao, razao AS empresa_nome, origem_cadastro, servico, ativa
FROM (
    SELECT e.*, row_number() OVER (
               PARTITION BY icao
               ORDER BY (ativa = 'ATIVA') DESC, origem_cadastro, razao) AS rn
    FROM b_empresas e
    WHERE icao <> ''
)
WHERE rn = 1;

DROP TABLE IF EXISTS fato_voos;
CREATE TABLE fato_voos AS
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
    (s.situacao = 'CANCELADO')        AS cancelado,
    s.atraso_partida_min,
    s.atraso_chegada_min,
    -- minutos recuperados em voo: positivo = chegou com menos atraso do que saiu
    s.atraso_partida_min - s.atraso_chegada_min AS recuperado_em_voo_min,
    -- pontual = chegada com até 15 min de atraso (definição deste projeto)
    CASE WHEN s.situacao = 'REALIZADO' THEN (s.atraso_chegada_min <= 15) END AS pontual_chegada,
    CASE WHEN s.situacao = 'REALIZADO' THEN (s.atraso_partida_min > 15)  END AS atrasou_partida_15
FROM silver_voos s
WHERE s.id NOT IN (SELECT id FROM voos_quarentena);

CREATE INDEX ix_fato_empresa ON fato_voos(empresa_icao);

DROP TABLE IF EXISTS obt_voos;
CREATE TABLE obt_voos AS
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
FROM fato_voos f
LEFT JOIN dim_empresa   e ON e.empresa_icao   = f.empresa_icao
LEFT JOIN dim_aeroporto o ON o.aeroporto_icao = f.origem_icao
LEFT JOIN dim_aeroporto d ON d.aeroporto_icao = f.destino_icao;

CREATE INDEX ix_obt_empresa ON obt_voos(empresa_icao);
CREATE INDEX ix_obt_origem  ON obt_voos(origem_icao);
