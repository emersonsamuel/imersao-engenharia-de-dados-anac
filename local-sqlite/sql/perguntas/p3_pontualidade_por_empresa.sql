-- P3. Qual companhia entrega melhor pontualidade e menor cancelamento, controlando pelo porte?
-- Porte = volume de voos no período (realizados + cancelados). Faixas definidas neste projeto:
--   Grande >= 50.000 | Médio 5.000-49.999 | Pequeno 1.000-4.999. Empresas com < 1.000 voos ficam de fora.
-- pct_pontual = % dos voos REALIZADOS com chegada até 15 min de atraso.
-- pct_cancelado = % de voos cancelados sobre o total programado da empresa.
WITH base AS (
    SELECT empresa_nome,
           COUNT(*)                                                    AS voos_programados,
           SUM(CASE WHEN situacao = 'REALIZADO' THEN 1 ELSE 0 END)     AS voos_realizados,
           ROUND(100.0 * SUM(cancelado) / COUNT(*), 2)                 AS pct_cancelado,
           ROUND(100.0 * AVG(pontual_chegada), 1)                      AS pct_pontual
    FROM obt_voos
    WHERE origem_icao <> destino_icao
    GROUP BY empresa_nome
    HAVING COUNT(*) >= 1000
)
SELECT CASE WHEN voos_programados >= 50000 THEN '1-Grande'
            WHEN voos_programados >= 5000  THEN '2-Médio'
            ELSE '3-Pequeno' END AS porte,
       empresa_nome, voos_programados, pct_pontual, pct_cancelado
FROM base
ORDER BY porte, pct_pontual DESC
LIMIT 60;
