# Fontes dos dados

Dados abertos da **ANAC** (Agência Nacional de Aviação Civil), usados como arquivos CSV:

| arquivo | conteúdo | codificação |
|---|---|---|
| `vra/*.csv` (12 arquivos mensais, ago/2025 a jul/2026) | registro de voos: empresa, trecho, horários previstos e reais, situação | UTF-8 (com BOM) |
| `referencias/AerodromosPublicos.csv` | cadastro de aeródromos públicos | ISO-8859-1, sem aspas |
| `referencias/pda_empresas_aereas_nacionais.csv` | cadastro de empresas aéreas nacionais | UTF-8 (com BOM) |
| `referencias/pda_empresas_aereas_estrangeiros.csv` | cadastro de empresas aéreas estrangeiras | UTF-8 (com BOM) |

Todo CSV traz `Atualizado em: <data>` na primeira linha e o cabeçalho na segunda. A data de atualização dos arquivos que usei está nessa primeira linha de cada arquivo.

Portal de dados abertos da ANAC: https://sistemas.anac.gov.br/dadosabertos/ 

Os dados do cadastro de empresas incluem endereço, telefone e e-mail; este projeto **não carrega** esses campos.
