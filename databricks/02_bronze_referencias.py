# Databricks notebook source
# MAGIC %md
# MAGIC # Bronze: referências (aeródromos e empresas aéreas)
# MAGIC - Aeródromos: ISO-8859-1 e **sem aspas** (as coordenadas em graus contêm aspas literais), então lemos como CSV com `quote` desligado.
# MAGIC - Empresas: guardamos só ICAO, razão social, serviço e situação (endereço, telefone e e-mail ficam de fora de propósito).

# COMMAND ----------

from pyspark.sql import functions as F, types as T

CATALOGO = "workspace"
PASTA = f"/Volumes/{CATALOGO}/bronze/arquivos/referencias"

# COMMAND ----------

# Aeródromos: 18 colunas; usamos código OACI, nome, município, UF, coordenadas decimais e situação.
# Lido como CSV (e não como texto) para respeitar a codificação ISO-8859-1; aspas desligadas (quote = "")
# porque as coordenadas em graus contêm aspas literais.
COLS_AER = ["codigo_oaci", "ciad", "nome", "municipio", "uf", "municipio_servido", "uf_servido",
            "latgeopoint", "longeopoint", "latitude", "longitude", "altitude", "operacao_diurna",
            "operacao_noturna", "situacao", "validade_registro", "portaria_registro", "link_portaria"]
schema_aer = T.StructType([T.StructField(c, T.StringType()) for c in COLS_AER])

lido_aer = (
    spark.read.schema(schema_aer)
    .option("header", "false").option("sep", ";").option("quote", "").option("encoding", "ISO-8859-1")
    .csv(f"{PASTA}/AerodromosPublicos.csv")
)
aerodromos = (
    lido_aer
    .filter(~F.coalesce(F.col("codigo_oaci"), F.lit("")).contains("Atualizado em"))   # 1ª linha do arquivo
    .filter(F.coalesce(F.col("codigo_oaci"), F.lit("")) != "Código OACI")             # cabeçalho
    .select(
        F.col("codigo_oaci"), F.col("ciad"), F.col("nome"), F.col("municipio"), F.col("uf"),
        F.col("latgeopoint").alias("latitude_decimal"),
        F.col("longeopoint").alias("longitude_decimal"),
        F.col("situacao"),
    )
)
aerodromos.write.mode("overwrite").option("overwriteSchema", "true").saveAsTable(f"{CATALOGO}.bronze.aerodromos")

# COMMAND ----------

# Empresas: 13 colunas, com aspas
COLS_EMP = ["icao", "estrangeira", "razao", "servico", "endereco", "cidade", "uf", "cep",
            "telefone", "email", "instrumento", "data", "ativa"]
schema_emp = T.StructType([T.StructField(c, T.StringType()) for c in COLS_EMP])


def ler_empresas(arquivo, origem):
    return (
        spark.read.schema(schema_emp)
        .option("header", "false").option("sep", ";").option("quote", '"').option("encoding", "UTF-8")
        .csv(f"{PASTA}/{arquivo}")
        # ICAO vazio é comum no cadastro nacional (~97% das linhas): vira "" em vez de NULL
        .withColumn("icao", F.coalesce(F.col("icao"), F.lit("")))
        .filter(~F.col("icao").contains("Atualizado em"))
        .filter(F.col("icao") != "ICAO")
        .select(
            F.lit(origem).alias("origem_cadastro"),
            F.trim("icao").alias("icao"),
            F.trim("razao").alias("razao"),
            F.trim("servico").alias("servico"),
            F.trim("ativa").alias("ativa"),
        )
    )


empresas = ler_empresas("pda_empresas_aereas_nacionais.csv", "nacional").unionByName(
    ler_empresas("pda_empresas_aereas_estrangeiros.csv", "estrangeira")
)
empresas.write.mode("overwrite").option("overwriteSchema", "true").saveAsTable(f"{CATALOGO}.bronze.empresas")

# COMMAND ----------

for t in ["aerodromos", "empresas"]:
    print(t, spark.table(f"{CATALOGO}.bronze.{t}").count())   # esperado: aerodromos 496, empresas 877
display(spark.table(f"{CATALOGO}.bronze.aerodromos").limit(5))   # confira se os acentos estão corretos
