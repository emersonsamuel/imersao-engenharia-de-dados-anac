-- P4b. Em quais aeroportos brasileiros a diferença é maior?
-- Aeroportos de origem no Brasil com pelo menos 300 partidas domésticas E 300 internacionais.
-- diferenca_min = atraso médio de partida internacional - doméstico (positivo = internacional atrasa mais).
WITH por_escopo AS (
    SELECT origem_icao, origem_nome, escopo_voo,
           COUNT(*) AS voos, AVG(atraso_partida_min) AS atraso
    FROM obt_voos
    WHERE situacao = 'REALIZADO' AND origem_icao <> destino_icao
      AND substr(origem_icao, 1, 2) IN ('SB','SD','SI','SJ','SN','SS','SW')
    GROUP BY origem_icao, origem_nome, escopo_voo
)
SELECT i.origem_icao, i.origem_nome,
       d.voos AS voos_domesticos, i.voos AS voos_internacionais,
       ROUND(d.atraso, 1) AS atraso_domestico_min,
       ROUND(i.atraso, 1) AS atraso_internacional_min,
       ROUND(i.atraso - d.atraso, 1) AS diferenca_min
FROM por_escopo i
JOIN por_escopo d ON d.origem_icao = i.origem_icao AND d.escopo_voo = 'Doméstico'
WHERE i.escopo_voo = 'Internacional' AND i.voos >= 300 AND d.voos >= 300
ORDER BY diferenca_min DESC
LIMIT 15;
