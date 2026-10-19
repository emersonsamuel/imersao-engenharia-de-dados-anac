-- SILVER: tipos corretos, nulos reais e métricas de atraso.
-- A Bronze guarda o texto como veio da ANAC; aqui acontece a limpeza.
--
-- Decisões:
--   * O CSV usa a palavra 'null' (texto) para ausência: vira NULL de verdade.
--   * Parte dos horários previstos vem com fração espúria ('.100000000'): usamos só os 19 primeiros
--     caracteres (AAAA-MM-DD HH:MM:SS) e registramos que a fração existia (prevista_com_fracao).
--   * Atrasos em minutos inteiros: negativo = adiantado.

DROP TABLE IF EXISTS silver_voos;
CREATE TABLE silver_voos AS
WITH t AS (
    SELECT
        id, arquivo, empresa_icao, numero_voo, tipo_linha, origem_icao, destino_icao, situacao,
        CASE WHEN partida_prevista = 'null' THEN NULL ELSE substr(partida_prevista, 1, 19) END AS pp,
        CASE WHEN partida_real     = 'null' THEN NULL ELSE substr(partida_real,     1, 19) END AS pr,
        CASE WHEN chegada_prevista = 'null' THEN NULL ELSE substr(chegada_prevista, 1, 19) END AS cp,
        CASE WHEN chegada_real     = 'null' THEN NULL ELSE substr(chegada_real,     1, 19) END AS cr,
        length(partida_prevista) = 29 AS prevista_com_fracao
    FROM b_vra
)
SELECT
    id,
    arquivo,
    empresa_icao,
    numero_voo,
    tipo_linha,
    origem_icao,
    destino_icao,
    situacao,
    pp AS partida_prevista,
    pr AS partida_real,
    cp AS chegada_prevista,
    cr AS chegada_real,
    CAST(round((strftime('%s', pr) - strftime('%s', pp)) / 60.0) AS INTEGER) AS atraso_partida_min,
    CAST(round((strftime('%s', cr) - strftime('%s', cp)) / 60.0) AS INTEGER) AS atraso_chegada_min,
    date(pp)                                                                  AS data_prevista,
    CAST(substr(pp, 12, 2) AS INTEGER)                                        AS hora_prevista,
    prevista_com_fracao
FROM t;

CREATE INDEX ix_silver_id ON silver_voos(id);
