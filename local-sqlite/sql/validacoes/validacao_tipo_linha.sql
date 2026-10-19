-- Validação: o código de tipo de linha (N, I, C, G) bate com a localização derivada dos aeroportos?
-- Serve para decidir se dá para usar o código como "doméstico/internacional" sem documentação oficial à mão.
SELECT f.tipo_linha_codigo,
       o.escopo_voo,
       COUNT(*) AS voos
FROM (SELECT voo_id, tipo_linha_codigo, escopo_voo FROM obt_voos) o
JOIN fato_voos f USING (voo_id)
GROUP BY f.tipo_linha_codigo, o.escopo_voo
ORDER BY f.tipo_linha_codigo, o.escopo_voo;
