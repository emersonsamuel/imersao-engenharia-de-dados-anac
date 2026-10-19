# Resultados da execução

Gerado por `src/pipeline.py` em 2026-10-19 14:58 a partir dos CSVs públicos da ANAC. Cada tabela abaixo é a saída de uma consulta em `sql/`.


## Qualidade dos dados: o que cada regra encontrou

| regra | severidade | linhas | pct_do_total |
|---|---|---|---|
| Q01_sem_horario_previsto | quarentena | 30,800 | 3.04 |
| Q02_duplicata_exata | quarentena | 41 | 0.00 |
| Q03_atraso_extremo | quarentena | 295 | 0.03 |
| Q04_cancelado_com_horario_real | quarentena | 0 | 0.00 |
| Q05_realizado_sem_horario_real | quarentena | 0 | 0.00 |
| Q06_chegada_antes_da_partida | quarentena | 0 | 0.00 |
| Q07_situacao_desconhecida | quarentena | 0 | 0.00 |
| Q08_origem_igual_destino | alerta | 4,097 | 0.40 |
| Q09_horario_com_fracao | alerta | 79,793 | 7.86 |


## Conciliação entre camadas

| camada | linhas |
|---|---|
| bronze | 1,014,705 |
| silver | 1,014,705 |
| quarentena | 31,133 |
| gold (fato_voos) | 983,572 |


## Validação: validacao_cobertura_nomes

| verificacao | voos | total |
|---|---|---|
| empresa com nome | 983,520 | 983,572 |
| origem com nome | 886,037 | 983,572 |
| destino com nome | 886,558 | 983,572 |


## Validação: validacao_tipo_linha

| tipo_linha_codigo | escopo_voo | voos |
|---|---|---|
| C | Doméstico | 12,192 |
| G | Doméstico | 1,144 |
| G | Internacional | 13,928 |
| I | Doméstico | 716 |
| I | Internacional | 165,601 |
| N | Doméstico | 789,991 |


## p1a_rotas_mais_atrasadas

| rota | origem_nome | destino_nome | voos | atraso_medio_min | pct_atraso_15 |
|---|---|---|---|---|---|
| KMIA > SBGL | KMIA | RIO DE JANEIRO/GALEÃO - ANTÔNIO CARLOS JOBIM | 541 | 114.70 | 42.10 |
| KMIA > SBKP | KMIA | Viracopos | 843 | 82.90 | 41.00 |
| KMIA > SBGR | KMIA | Guarulhos - Governador André Franco Montoro | 1,912 | 52.10 | 34.70 |
| KJFK > SBGR | KJFK | Guarulhos - Governador André Franco Montoro | 1,052 | 37.80 | 25.20 |
| SBGR > MDPC | Guarulhos - Governador André Franco Montoro | MDPC | 545 | 37.40 | 39.30 |
| MDPC > SBGR | MDPC | Guarulhos - Governador André Franco Montoro | 539 | 34.00 | 50.10 |
| SABE > SBFL | SABE | Hercílio Luz | 1,011 | 30.00 | 32.40 |
| LPPT > SBKP | LPPT | Viracopos | 636 | 29.40 | 47.60 |
| SBGR > SCEL | Guarulhos - Governador André Franco Montoro | SCEL | 4,260 | 27.30 | 32.90 |
| SBGR > SAEZ | Guarulhos - Governador André Franco Montoro | SAEZ | 1,492 | 27.20 | 43.90 |
| SBFL > SAEZ | Hercílio Luz | SAEZ | 615 | 25.70 | 27.50 |
| LPPT > SBRF | LPPT | AEROPORTO INTERNACIONAL RECIFE/GUARARAPES - GILBERTO FREYRE | 556 | 25.00 | 54.70 |
| SBGR > OTHH | Guarulhos - Governador André Franco Montoro | OTHH | 817 | 24.90 | 24.40 |
| OTHH > SBGR | OTHH | Guarulhos - Governador André Franco Montoro | 794 | 24.40 | 39.20 |
| LPPT > SBGL | LPPT | RIO DE JANEIRO/GALEÃO - ANTÔNIO CARLOS JOBIM | 613 | 23.60 | 55.30 |


## p1b_aeroportos_mais_atrasados

| origem_icao | origem_nome | origem_uf | voos | atraso_medio_min | pct_atraso_15 |
|---|---|---|---|---|---|
| LPPT | LPPT |  | 5,833 | 26.00 | 54.50 |
| SAEZ | SAEZ |  | 5,879 | 15.50 | 21.90 |
| SABE | SABE |  | 10,310 | 13.40 | 23.10 |
| SBGR | Guarulhos - Governador André Franco Montoro | São Paulo | 140,820 | 13.30 | 27.20 |
| SBKP | Viracopos | São Paulo | 55,567 | 10.30 | 17.70 |
| SCEL | SCEL |  | 10,660 | 9.10 | 16.40 |
| SBEG | Eduardo Gomes | Amazonas | 14,357 | 7.90 | 14.80 |
| SBFL | Hercílio Luz | Santa Catarina | 17,856 | 7.50 | 16.00 |
| SBSP | São Paulo/Congonhas - Deputado Freitas Nobre | São Paulo | 93,061 | 7.20 | 19.40 |
| SBFI | Cataratas | Paraná | 8,351 | 7.00 | 16.80 |
| SBGL | RIO DE JANEIRO/GALEÃO - ANTÔNIO CARLOS JOBIM | Rio de Janeiro | 59,531 | 6.10 | 14.40 |
| SBCF | Tancredo Neves | Minas Gerais | 54,598 | 5.10 | 14.70 |
| SBCT | Afonso Pena | Paraná | 25,083 | 4.90 | 14.50 |
| SBRF | AEROPORTO INTERNACIONAL RECIFE/GUARARAPES - GILBERTO FREYRE | Pernambuco | 36,052 | 4.60 | 13.70 |
| SBPS | Porto Seguro | Bahia | 9,230 | 4.10 | 15.00 |


## p2_atraso_por_hora

| hora_prevista | voos | atraso_partida_medio_min | pct_atraso_15 | atraso_chegada_medio_min |
|---|---|---|---|---|
| 0 | 9,795 | 22.90 | 22.60 | 19.40 |
| 1 | 10,148 | 11.60 | 17.40 | 6.00 |
| 2 | 17,702 | 5.00 | 14.30 | 1.10 |
| 3 | 20,080 | 2.60 | 12.20 | -1.40 |
| 4 | 17,955 | 2.80 | 9.50 | -1.00 |
| 5 | 32,008 | 0.80 | 8.40 | -2.00 |
| 6 | 44,037 | 3.00 | 9.50 | 0.10 |
| 7 | 37,920 | 5.90 | 13.60 | 2.40 |
| 8 | 62,336 | 5.80 | 13.80 | 2.70 |
| 9 | 57,197 | 6.30 | 14.30 | 2.70 |
| 10 | 45,442 | 6.00 | 15.20 | 2.20 |
| 11 | 51,206 | 5.90 | 15.50 | 1.90 |
| 12 | 52,589 | 6.40 | 17.20 | 3.30 |
| 13 | 47,784 | 7.40 | 17.90 | 3.60 |
| 14 | 54,231 | 7.10 | 17.80 | 3.50 |
| 15 | 50,221 | 8.30 | 18.40 | 5.40 |
| 16 | 39,850 | 9.00 | 19.90 | 5.60 |
| 17 | 65,740 | 9.10 | 21.90 | 5.80 |
| 18 | 48,885 | 9.10 | 21.90 | 6.00 |
| 19 | 42,436 | 9.80 | 22.70 | 6.70 |
| 20 | 39,212 | 8.50 | 21.40 | 5.20 |
| 21 | 39,588 | 9.90 | 20.30 | 4.90 |
| 22 | 33,797 | 12.30 | 25.90 | 7.60 |
| 23 | 34,273 | 10.90 | 26.00 | 6.30 |


## p3_pontualidade_por_empresa

| porte | empresa_nome | voos_programados | pct_pontual | pct_cancelado |
|---|---|---|---|---|
| 1-Grande | GOL LINHAS AÉREAS S.A. (EX- VRG LINHAS AÉREAS S.A.) | 254,505 | 87.00 | 1.16 |
| 1-Grande | AZUL LINHAS AÉREAS BRASILEIRAS S/A | 277,930 | 85.70 | 1.59 |
| 1-Grande | TAM LINHAS AÉREAS S.A. | 297,591 | 80.90 | 1.51 |
| 2-Médio | COMPAÑIA PANAMEÑA DE AVIACION S.A. (COPA AIRLINES) | 9,515 | 88.80 | 2.89 |
| 2-Médio | AZUL CONECTA LTDA. (EX TWO TAXI AEREO LTDA) | 12,943 | 84.70 | 16.11 |
| 2-Médio | SKY AIRLINE S.A. | 5,475 | 82.80 | 11.40 |
| 2-Médio | LATAM AIRLINES GROUP (EX - LAN AIRLINES S/A) | 12,853 | 79.30 | 0.70 |
| 2-Médio | AEROVIAS DEL CONTINENTE AMERICANO S.A. AVIANCA | 5,379 | 75.90 | 1.86 |
| 2-Médio | IBÉRIA LINEAS AEREAS DE ESPAÑA SOCIEDAD ANONIMA OPERADORA | 5,066 | 72.20 | 56.04 |
| 2-Médio | TAP - TRANSPORTES AÉREOS PORTUGUESES S/A | 10,268 | 70.50 | 1.45 |
| 2-Médio | AEROLINEAS ARGENTINAS S/A | 8,292 | 69.40 | 3.03 |
| 3-Pequeno | ATA - AEROTÁXI ABAETÉ LTDA. | 1,224 | 95.10 | 10.87 |
| 3-Pequeno | KLM CIA. REAL HOLANDESA DE AVIAÇÃO | 1,443 | 86.10 | 2.77 |
| 3-Pequeno | BRITISH AIRWAYS PLC | 2,186 | 85.50 | 1.37 |
| 3-Pequeno | JETSMART AIRLINES S.A - ARGENTINA | 4,299 | 85.10 | 2.07 |
| 3-Pequeno | JETSMART AIRLINES SPA - CHILE | 3,806 | 82.40 | 2.23 |
| 3-Pequeno | AIR EUROPA LINEAS AEREAS SOCIEDAD ANONIMA | 1,099 | 77.70 | 3.91 |
| 3-Pequeno | DELTA AIR LINES INC. | 2,597 | 76.20 | 2.50 |
| 3-Pequeno | ITALIA TRANSPORTO AEREO S.P.A. | 2,559 | 76.20 | 23.52 |
| 3-Pequeno | LATAM AIRLINES PERU (EX-LAN PERU S.A.) | 4,240 | 75.80 | 0.59 |
| 3-Pequeno | EMIRATES | 2,509 | 73.40 | 9.76 |
| 3-Pequeno | SOCIÉTÉ AIR FRANCE | 3,241 | 73.00 | 0.93 |
| 3-Pequeno | AMERICAN AIRLINES, INC. | 4,592 | 72.20 | 2.37 |
| 3-Pequeno | TURKISH AIRLINES INC | 3,010 | 72.00 | 1.46 |
| 3-Pequeno | TRANSPORTE AÉREOS DEL MERCOSUR S.A. (TAM MERCOSUR) | 1,291 | 71.50 | 0.70 |


## p4a_domestico_vs_internacional

| escopo_voo | voos_realizados | atraso_partida_medio_min | pct_partida_atrasada_15 | atraso_chegada_medio_min | pct_pontual_chegada |
|---|---|---|---|---|---|
| Doméstico | 789,554 | 5.20 | 15.90 | 1.90 | 84.60 |
| Internacional | 164,878 | 17.80 | 25.50 | 12.90 | 74.50 |


## p4b_diferenca_por_aeroporto

| origem_icao | origem_nome | voos_domesticos | voos_internacionais | atraso_domestico_min | atraso_internacional_min | diferenca_min |
|---|---|---|---|---|---|---|
| SBKP | Viracopos | 51,653 | 3,914 | 7.10 | 52.10 | 45.00 |
| SBEG | Eduardo Gomes | 13,275 | 1,082 | 4.70 | 47.50 | 42.90 |
| SBBE | INTERNACIONAL DE BELÉM/VAL DE CANS/JÚLIO CEZAR RIBEIRO | 14,725 | 884 | 2.50 | 17.50 | 15.00 |
| SBCT | Afonso Pena | 24,313 | 770 | 4.50 | 16.80 | 12.20 |
| SBSV | DEPUTADO LUÍS EDUARDO MAGALHÃES | 28,228 | 1,488 | 2.20 | 9.90 | 7.70 |
| SBGL | RIO DE JANEIRO/GALEÃO - ANTÔNIO CARLOS JOBIM | 42,605 | 16,926 | 4.10 | 11.10 | 7.00 |
| SBFL | Hercílio Luz | 13,876 | 3,980 | 6.10 | 12.40 | 6.40 |
| SBFZ | Pinto Martins | 18,921 | 1,129 | 2.80 | 9.20 | 6.40 |
| SBRF | AEROPORTO INTERNACIONAL RECIFE/GUARARAPES - GILBERTO FREYRE | 34,402 | 1,650 | 4.40 | 8.70 | 4.30 |
| SBGR | Guarulhos - Governador André Franco Montoro | 99,751 | 41,069 | 12.50 | 15.20 | 2.70 |
| SBSG | Aeroporto Internacional do Rio Grande do Norte / São Gonçalo do Amarante - Governador Aluizio Alves | 8,371 | 573 | 2.30 | 4.70 | 2.30 |
| SBCF | Tancredo Neves | 53,191 | 1,407 | 5.00 | 7.10 | 2.10 |
| SBBR | Presidente Juscelino Kubitschek | 56,373 | 2,810 | 2.90 | 4.00 | 1.00 |
| SBPA | Salgado Filho | 27,999 | 1,376 | 3.50 | 3.70 | 0.20 |


## p5a_recuperacao_por_empresa

| empresa_nome | voos_realizados | recuperado_medio_min | recuperado_nos_atrasados_min |
|---|---|---|---|
| IBÉRIA LINEAS AEREAS DE ESPAÑA SOCIEDAD ANONIMA OPERADORA | 2,227 | 18.20 | 34.50 |
| KLM CIA. REAL HOLANDESA DE AVIAÇÃO | 1,403 | 16.00 | 33.00 |
| ITALIA TRANSPORTO AEREO S.P.A. | 1,957 | 10.50 | 15.20 |
| ETHIOPIAN AIRLINES GROUP | 1,389 | 8.30 | 11.70 |
| TAP - TRANSPORTES AÉREOS PORTUGUESES S/A | 10,119 | 9.80 | 11.40 |
| COMPAÑIA PANAMEÑA DE AVIACION S.A. (COPA AIRLINES) | 9,240 | 3.30 | 11.30 |
| AIR EUROPA LINEAS AEREAS SOCIEDAD ANONIMA | 1,056 | 12.60 | 10.40 |
| BRITISH AIRWAYS PLC | 2,156 | 5.20 | 9.20 |
| TAMPA CARGO S.A. | 1,299 | 7.60 | 9.10 |
| AIR CANADA | 1,738 | 5.00 | 9.10 |
| SKY AIRLINE S.A. | 4,851 | 8.30 | 8.70 |
| QATAR AIRWAYS GROUP | 2,013 | 4.80 | 8.70 |
| SOCIÉTÉ AIR FRANCE | 3,211 | 6.40 | 7.90 |
| TURKISH AIRLINES INC | 2,966 | 7.70 | 7.60 |
| UNITED AIRLINES, INC | 3,572 | 6.20 | 7.50 |
| DEUTSCHE LUFTHANSA A.G. | 1,452 | 4.60 | 5.80 |
| JETSMART AIRLINES S.A - ARGENTINA | 4,210 | 5.30 | 5.10 |
| GOL LINHAS AÉREAS S.A. (EX- VRG LINHAS AÉREAS S.A.) | 251,565 | 4.50 | 4.90 |
| EMIRATES | 2,264 | 2.50 | 4.90 |
| AEROVIAS DEL CONTINENTE AMERICANO S.A. AVIANCA | 5,279 | 4.10 | 4.70 |


## p5b_rotas_sem_recuperacao

| rota | origem_nome | destino_nome | partidas_atrasadas | atraso_partida_medio_min | atraso_chegada_medio_min | recuperado_medio_min |
|---|---|---|---|---|---|---|
| SBGR > SLVR | Guarulhos - Governador André Franco Montoro | SLVR | 265 | 50.90 | 56.80 | -5.90 |
| KMIA > SBGR | KMIA | Guarulhos - Governador André Franco Montoro | 664 | 162.20 | 164.80 | -2.60 |
| SBNF > SBGR | Ministro Victor Konder | Guarulhos - Governador André Franco Montoro | 402 | 48.90 | 51.40 | -2.60 |
| SBCF > SBSP | Tancredo Neves | São Paulo/Congonhas - Deputado Freitas Nobre | 1,174 | 49.10 | 50.80 | -1.70 |
| SBNF > SBSP | Ministro Victor Konder | São Paulo/Congonhas - Deputado Freitas Nobre | 445 | 45.50 | 46.50 | -1.00 |
| SBRJ > SBSP | Santos Dumont | São Paulo/Congonhas - Deputado Freitas Nobre | 1,843 | 48.90 | 49.80 | -0.80 |
| SBVT > SBCF | Eurico de Aguiar Salles | Tancredo Neves | 219 | 63.20 | 63.80 | -0.60 |
| KMIA > SBGL | KMIA | RIO DE JANEIRO/GALEÃO - ANTÔNIO CARLOS JOBIM | 228 | 287.20 | 287.70 | -0.50 |
| SBGR > KMIA | Guarulhos - Governador André Franco Montoro | KMIA | 356 | 81.20 | 81.60 | -0.40 |
| SBGR > SBCA | Guarulhos - Governador André Franco Montoro | Aeroporto Regional do Oeste - Cel. Adalberto Mendes da Silva - Cascavel - Paraná | 228 | 44.10 | 44.50 | -0.40 |
| SBCG > SBGR | Aeroporto Internacional de Campo Grande - Ueze Elias Zahran | Guarulhos - Governador André Franco Montoro | 342 | 51.40 | 51.80 | -0.30 |
| SBGR > SBFL | Guarulhos - Governador André Franco Montoro | Hercílio Luz | 1,088 | 44.60 | 44.60 | -0.00 |
| SBKP > SBCF | Viracopos | Tancredo Neves | 428 | 44.70 | 44.70 | -0.00 |
| SBPS > SBSP | Porto Seguro | São Paulo/Congonhas - Deputado Freitas Nobre | 271 | 47.00 | 46.90 | 0.00 |
| SABE > SBGR | SABE | Guarulhos - Governador André Franco Montoro | 939 | 53.50 | 53.40 | 0.10 |
