-- QUALIDADE: marcar -> auditar -> quarentena.
-- Nenhuma linha é apagada: cada regra grava um "flag" por linha, e a Gold só usa o que não está em quarentena.
-- Severidade 'quarentena' = fora da Gold. Severidade 'alerta' = fica na Gold, mas registrado.
-- Os limites (ex.: 24 h) são decisões deste projeto, não da ANAC.

DROP TABLE IF EXISTS qualidade_regras;
CREATE TABLE qualidade_regras (
    regra      TEXT PRIMARY KEY,
    severidade TEXT NOT NULL CHECK (severidade IN ('quarentena', 'alerta')),
    descricao  TEXT NOT NULL
);

INSERT INTO qualidade_regras VALUES
 ('Q01_sem_horario_previsto',     'quarentena', 'Voo REALIZADO sem partida ou chegada prevista: impossível medir o atraso.'),
 ('Q02_duplicata_exata',          'quarentena', 'Linha idêntica a outra em todas as colunas; só a primeira é mantida.'),
 ('Q03_atraso_extremo',           'quarentena', 'Atraso (partida ou chegada) maior que 24 h em módulo: indício de data registrada errada.'),
 ('Q04_cancelado_com_horario_real','quarentena','Voo CANCELADO com horário real preenchido.'),
 ('Q05_realizado_sem_horario_real','quarentena','Voo REALIZADO sem partida ou chegada real.'),
 ('Q06_chegada_antes_da_partida', 'quarentena', 'Chegada prevista anterior à partida prevista.'),
 ('Q07_situacao_desconhecida',    'quarentena', 'Situação diferente de REALIZADO ou CANCELADO.'),
 ('Q08_origem_igual_destino',     'alerta',     'Origem = destino (voo circular, treino ou erro). Fica na Gold, mas fora das análises de rota.'),
 ('Q09_horario_com_fracao',       'alerta',     'Horário previsto vinha com fração espúria; normalizado na Silver.');

DROP TABLE IF EXISTS qualidade_flags;
CREATE TABLE qualidade_flags (id INTEGER NOT NULL, regra TEXT NOT NULL);

INSERT INTO qualidade_flags
SELECT id, 'Q01_sem_horario_previsto' FROM silver_voos
WHERE situacao = 'REALIZADO' AND (partida_prevista IS NULL OR chegada_prevista IS NULL);

INSERT INTO qualidade_flags
SELECT id, 'Q02_duplicata_exata' FROM (
    SELECT id, row_number() OVER (
        PARTITION BY empresa_icao, numero_voo, tipo_linha, origem_icao, destino_icao, situacao,
                     partida_prevista, partida_real, chegada_prevista, chegada_real
        ORDER BY id) AS rn
    FROM silver_voos
) WHERE rn > 1;

INSERT INTO qualidade_flags
SELECT id, 'Q03_atraso_extremo' FROM silver_voos
WHERE abs(atraso_partida_min) > 1440 OR abs(atraso_chegada_min) > 1440;

INSERT INTO qualidade_flags
SELECT id, 'Q04_cancelado_com_horario_real' FROM silver_voos
WHERE situacao = 'CANCELADO' AND (partida_real IS NOT NULL OR chegada_real IS NOT NULL);

INSERT INTO qualidade_flags
SELECT id, 'Q05_realizado_sem_horario_real' FROM silver_voos
WHERE situacao = 'REALIZADO' AND (partida_real IS NULL OR chegada_real IS NULL);

INSERT INTO qualidade_flags
SELECT id, 'Q06_chegada_antes_da_partida' FROM silver_voos
WHERE chegada_prevista < partida_prevista;

INSERT INTO qualidade_flags
SELECT id, 'Q07_situacao_desconhecida' FROM silver_voos
WHERE situacao NOT IN ('REALIZADO', 'CANCELADO');

INSERT INTO qualidade_flags
SELECT id, 'Q08_origem_igual_destino' FROM silver_voos WHERE origem_icao = destino_icao;

INSERT INTO qualidade_flags
SELECT id, 'Q09_horario_com_fracao' FROM silver_voos WHERE prevista_com_fracao = 1;

CREATE INDEX ix_flags_id ON qualidade_flags(id);

-- Quarentena: uma linha por voo com ao menos uma regra de severidade 'quarentena'.
DROP TABLE IF EXISTS voos_quarentena;
CREATE TABLE voos_quarentena AS
SELECT f.id, group_concat(f.regra, ', ') AS regras
FROM qualidade_flags f
JOIN qualidade_regras r USING (regra)
WHERE r.severidade = 'quarentena'
GROUP BY f.id;
CREATE INDEX ix_quarentena_id ON voos_quarentena(id);

-- Auditoria: quanto cada regra pegou.
DROP TABLE IF EXISTS qualidade_resumo;
CREATE TABLE qualidade_resumo AS
SELECT r.regra, r.severidade, r.descricao,
       COUNT(f.id) AS linhas,
       ROUND(100.0 * COUNT(f.id) / (SELECT COUNT(*) FROM silver_voos), 3) AS pct_do_total
FROM qualidade_regras r
LEFT JOIN qualidade_flags f USING (regra)
GROUP BY r.regra, r.severidade, r.descricao
ORDER BY r.regra;
