-- P2. Como o atraso evolui ao longo do dia?
-- Hora = hora da partida PREVISTA. Limite do dataset: não há matrícula da aeronave, então
-- "atraso herdado" (a mesma aeronave atrasando o voo seguinte) não pode ser medido diretamente;
-- esta curva só mostra o padrão agregado.
SELECT hora_prevista,
       COUNT(*)                                   AS voos,
       ROUND(AVG(atraso_partida_min), 1)          AS atraso_partida_medio_min,
       ROUND(100.0 * AVG(atrasou_partida_15), 1)  AS pct_atraso_15,
       ROUND(AVG(atraso_chegada_min), 1)          AS atraso_chegada_medio_min
FROM obt_voos
WHERE situacao = 'REALIZADO' AND origem_icao <> destino_icao
GROUP BY hora_prevista
ORDER BY hora_prevista;
