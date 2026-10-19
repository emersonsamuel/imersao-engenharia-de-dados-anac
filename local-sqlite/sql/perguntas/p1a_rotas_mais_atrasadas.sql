-- P1a. Quais rotas concentram os maiores atrasos de partida?
-- Só voos REALIZADOS, rotas com pelo menos 500 voos, sem voos circulares (origem = destino).
-- atraso_medio_min inclui partidas adiantadas (valores negativos); pct_atraso_15 = % com partida > 15 min atrasada.
SELECT rota,
       origem_nome, destino_nome,
       COUNT(*)                                   AS voos,
       ROUND(AVG(atraso_partida_min), 1)          AS atraso_medio_min,
       ROUND(100.0 * AVG(atrasou_partida_15), 1)  AS pct_atraso_15
FROM obt_voos
WHERE situacao = 'REALIZADO' AND origem_icao <> destino_icao
GROUP BY rota, origem_nome, destino_nome
HAVING COUNT(*) >= 500
ORDER BY atraso_medio_min DESC
LIMIT 15;
