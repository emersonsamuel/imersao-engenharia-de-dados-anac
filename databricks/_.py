# Databricks notebook source
# MAGIC %md
# MAGIC # Bronze: referências (aeródromos e empresas aéreas)
# MAGIC - Aeródromos: ISO-8859-1 e **sem aspas** (as coordenadas em graus contêm aspas literais), então lemos como texto e dividimos por ';'.
# MAGIC - Empresas: guardamos só ICAO, razão social, serviço e situação (endereço, telefone e e-mail ficam de fora de propósito).

# COMMAND ----------

from pyspark.sql import functions as F, types as T

CATALOGO = "workspace"
PASTA = f"/Volumes/{CATALOGO}/bronze/arquivos/referencias"

# COMMAND ----------

# Aeródromos: 18 colunas; usamos código OACI, nome, município, UF, coordenadas decimais e situação
texto = spark.read.option("encoding", "ISO-8859-1").text(f"{PASTA}/AerodromosPublicos.csv")
p = F.split("value", ";")
aerodromos = (
    texto.select(p.alias("p"))
    .filter(F.size("p") == 18)
    .filter(F.col("p")[0] != "Código OACI")
    .select(
        F.col("p")[0].alias("codigo_oaci"),
        F.col("p")[1].alias("ciad"),
        F.col("p")[2].alias("nome"),
        F.col("p")[3].alias("municipio"),
        F.col("p")[4].alias("uf"),
        F.col("p")[7].alias("latitude_decimal"),
        F.col("p")[8].alias("longitude_decimal"),
        F.col("p")[14].alias("situacao"),
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
    print(t, spark.table(f"{CATALOGO}.bronze.{t}").count())
