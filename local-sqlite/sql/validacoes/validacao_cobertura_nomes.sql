-- Validação: quantos voos ficam com nome legível (empresa e aeroportos) e quantos caem no código ICAO?
SELECT 'empresa com nome'      AS verificacao, SUM(empresa_nome  <> empresa_icao) AS voos, COUNT(*) AS total FROM obt_voos
UNION ALL
SELECT 'origem com nome',      SUM(origem_nome   <> origem_icao),  COUNT(*) FROM obt_voos
UNION ALL
SELECT 'destino com nome',     SUM(destino_nome  <> destino_icao), COUNT(*) FROM obt_voos;
