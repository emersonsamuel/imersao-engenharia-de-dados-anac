# Databricks notebook source
# MAGIC %md
# MAGIC # Bronze: voos (VRA)
# MAGIC Guarda o dado como veio da ANAC, tudo texto. Cada CSV tem 'Atualizado em: ...' na 1ª linha e o cabeçalho na 2ª,
# MAGIC então lemos sem cabeçalho, com schema explícito, e descartamos essas duas linhas.

# COMMAND ----------

from pyspark.sql import functions as F, types as T

CATALOGO = "workspace"          # ajuste se o seu catálogo tiver outro nome
PASTA = f"/Volumes/{CATALOGO}/bronze/arquivos"

COLUNAS = [
    "empresa_icao", "numero_voo", "codigo_di", "tipo_linha", "origem_icao", "destino_icao",
    "partida_prevista", "partida_real", "chegada_prevista", "chegada_real", "situacao",
    "codigo_justificativa",
]
schema = T.StructType([T.StructField(c, T.StringType()) for c in COLUNAS])

# COMMAND ----------

lido = (
    spark.read.schema(schema)
    .option("header", "false")
    .option("sep", ";")
    .option("quote", '"')
    .option("encoding", "UTF-8")
    .option("mode", "PERMISSIVE")
    .csv(f"{PASTA}/vra/*.csv")
    .withColumn("arquivo", F.col("_metadata.file_name"))
)

# Descarta a linha 'Atualizado em' e a linha de cabeçalho de cada arquivo
voos = (
    lido
    .filter(~F.col("empresa_icao").contains("Atualizado em"))
    .filter(F.col("empresa_icao") != "ICAO Empresa Aérea")
    .withColumn("id", F.monotonically_increasing_id())
)

# COMMAND ----------

# Checagem: linha com a última coluna vazia indica linha malformada
incompletas = voos.filter(F.col("codigo_justificativa").isNull()).count()
assert incompletas == 0, f"{incompletas} linhas com número de colunas errado"

voos.write.mode("overwrite").option("overwriteSchema", "true").saveAsTable(f"{CATALOGO}.bronze.vra")

# COMMAND ----------

display(spark.table(f"{CATALOGO}.bronze.vra").groupBy("arquivo").count().orderBy("arquivo"))
print("total:", spark.table(f"{CATALOGO}.bronze.vra").count())
