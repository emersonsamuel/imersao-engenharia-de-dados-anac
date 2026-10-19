#!/usr/bin/env python3
"""Pipeline local do projeto Aviação ANAC (Bronze -> Silver -> Qualidade -> Gold -> Perguntas).

Só usa a biblioteca padrão do Python (sqlite3, csv). Exemplo:

    python src/pipeline.py --dados ./dados

Estrutura esperada em --dados (os mesmos arquivos públicos da ANAC):
    dados/vra/*.csv
    dados/referencias/AerodromosPublicos.csv
    dados/referencias/pda_empresas_aereas_nacionais.csv
    dados/referencias/pda_empresas_aereas_estrangeiros.csv
"""
import argparse
import csv
import sqlite3
import sys
import time
from pathlib import Path

RAIZ = Path(__file__).resolve().parent.parent

VRA_COLUNAS = [
    "ICAO Empresa Aérea", "Número Voo", "Código Autorização (DI)", "Código Tipo Linha",
    "ICAO Aeródromo Origem", "ICAO Aeródromo Destino", "Partida Prevista", "Partida Real",
    "Chegada Prevista", "Chegada Real", "Situação Voo", "Código Justificativa",
]
VRA_DESTINO = [
    "empresa_icao", "numero_voo", "codigo_di", "tipo_linha", "origem_icao", "destino_icao",
    "partida_prevista", "partida_real", "chegada_prevista", "chegada_real", "situacao",
    "codigo_justificativa",
]


def log(msg):
    print(f"[{time.strftime('%H:%M:%S')}] {msg}", flush=True)


def ler_csv_anac(caminho, encoding, quoting=csv.QUOTE_MINIMAL):
    """Os CSVs da ANAC trazem 'Atualizado em: <data>' na 1ª linha e o cabeçalho na 2ª."""
    with open(caminho, encoding=encoding, newline="") as fh:
        primeira = fh.readline().strip()
        atualizado_em = primeira.split(":", 1)[1].strip() if ":" in primeira else None
        leitor = csv.reader(fh, delimiter=";", quotechar='"', quoting=quoting)
        cabecalho = next(leitor)
        linhas = [r for r in leitor if r]
    return atualizado_em, cabecalho, linhas


# ---------------------------------------------------------------- BRONZE
def bronze(con, dados):
    """Guarda o dado como veio (tudo texto). Só descartamos os campos de contato das empresas."""
    con.execute("DROP TABLE IF EXISTS b_vra")
    con.execute(
        "CREATE TABLE b_vra (id INTEGER PRIMARY KEY, arquivo TEXT, "
        + ", ".join(f"{c} TEXT" for c in VRA_DESTINO) + ")"
    )
    total = 0
    arquivos = sorted((dados / "vra").glob("*.csv"))
    if not arquivos:
        sys.exit(f"Nenhum CSV em {dados / 'vra'}")
    for arq in arquivos:
        _, cab, linhas = ler_csv_anac(arq, "utf-8-sig")
        if cab != VRA_COLUNAS:
            sys.exit(f"Cabeçalho inesperado em {arq.name}: {cab}")
        ruins = [i for i, r in enumerate(linhas) if len(r) != len(VRA_COLUNAS)]
        if ruins:
            sys.exit(f"{arq.name}: {len(ruins)} linhas com número de colunas errado")
        con.executemany(
            f"INSERT INTO b_vra (arquivo, {', '.join(VRA_DESTINO)}) VALUES (?{',?' * len(VRA_DESTINO)})",
            [[arq.name] + r for r in linhas],
        )
        total += len(linhas)
        log(f"bronze: {arq.name} -> {len(linhas):,} linhas")

    # Aeródromos públicos (ISO-8859-1, sem aspas: as coordenadas em graus contêm aspas literais)
    _, cab, linhas = ler_csv_anac(
        dados / "referencias" / "AerodromosPublicos.csv", "iso-8859-1", csv.QUOTE_NONE
    )
    con.execute("DROP TABLE IF EXISTS b_aerodromos")
    con.execute(
        "CREATE TABLE b_aerodromos (codigo_oaci TEXT, ciad TEXT, nome TEXT, municipio TEXT, uf TEXT, "
        "latitude_decimal TEXT, longitude_decimal TEXT, situacao TEXT)"
    )
    ok = [r for r in linhas if len(r) == len(cab)]
    con.executemany(
        "INSERT INTO b_aerodromos VALUES (?,?,?,?,?,?,?,?)",
        [(r[0], r[1], r[2], r[3], r[4], r[7], r[8], r[14]) for r in ok],
    )
    log(f"bronze: aeródromos -> {len(ok):,} linhas ({len(linhas) - len(ok)} descartadas por formato)")

    # Empresas aéreas: mantemos só o necessário (sem endereço, telefone ou e-mail)
    con.execute("DROP TABLE IF EXISTS b_empresas")
    con.execute(
        "CREATE TABLE b_empresas (origem_cadastro TEXT, icao TEXT, razao TEXT, servico TEXT, ativa TEXT)"
    )
    n_emp = 0
    for nome, origem in [("pda_empresas_aereas_nacionais.csv", "nacional"),
                         ("pda_empresas_aereas_estrangeiros.csv", "estrangeira")]:
        _, cab, linhas = ler_csv_anac(dados / "referencias" / nome, "utf-8-sig")
        esperado = ["ICAO", "Estrangeira", "Razao", "Servico"]
        if cab[:4] != esperado or cab[-1] != "Ativa":
            sys.exit(f"Cabeçalho inesperado em {nome}: {cab}")
        con.executemany(
            "INSERT INTO b_empresas VALUES (?,?,?,?,?)",
            [(origem, r[0].strip(), r[2].strip(), r[3].strip(), r[-1].strip()) for r in linhas],
        )
        n_emp += len(linhas)
    log(f"bronze: empresas -> {n_emp:,} linhas")
    con.commit()
    return total


# ---------------------------------------------------------------- SQL
def rodar_sql(con, caminho):
    con.executescript(caminho.read_text(encoding="utf-8"))
    con.commit()
    log(f"sql: {caminho.relative_to(RAIZ)}")


def exportar(con, nome, sql, saida):
    cur = con.execute(sql)
    cabecalho = [d[0] for d in cur.description]
    linhas = cur.fetchall()
    with open(saida / f"{nome}.csv", "w", encoding="utf-8", newline="") as fh:
        w = csv.writer(fh)
        w.writerow(cabecalho)
        w.writerows(linhas)
    return cabecalho, linhas


def tabela_md(cabecalho, linhas, limite=None):
    def fmt(v):
        if v is None:
            return ""
        if isinstance(v, float):
            return f"{v:,.2f}"
        if isinstance(v, int):
            return f"{v:,}"
        return str(v).replace("|", "/")
    linhas = linhas[:limite] if limite else linhas
    out = ["| " + " | ".join(cabecalho) + " |", "|" + "|".join("---" for _ in cabecalho) + "|"]
    out += ["| " + " | ".join(fmt(v) for v in r) + " |" for r in linhas]
    return "\n".join(out)


def principal():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--dados", default=str(RAIZ.parent / "dados"), help="pasta com vra/ e referencias/")
    ap.add_argument("--banco", default=str(RAIZ / "build" / "anac.db"), help="arquivo SQLite de saída")
    args = ap.parse_args()

    inicio = time.time()
    dados, banco = Path(args.dados), Path(args.banco)
    banco.parent.mkdir(parents=True, exist_ok=True)
    saida = RAIZ / "outputs"
    saida.mkdir(exist_ok=True)
    if banco.exists():
        banco.unlink()
    con = sqlite3.connect(banco)

    n_bronze = bronze(con, dados)
    for f in ["01_silver.sql", "02_qualidade.sql", "03_gold.sql"]:
        rodar_sql(con, RAIZ / "sql" / f)

    # Conciliação: nada some no caminho
    n_silver = con.execute("SELECT COUNT(*) FROM silver_voos").fetchone()[0]
    n_quar = con.execute("SELECT COUNT(*) FROM voos_quarentena").fetchone()[0]
    n_gold = con.execute("SELECT COUNT(*) FROM fato_voos").fetchone()[0]
    log(f"conciliação: bronze={n_bronze:,} silver={n_silver:,} quarentena={n_quar:,} gold={n_gold:,}")
    assert n_bronze == n_silver == n_gold + n_quar, "As contagens não fecham"

    secoes = []
    cab, lin = exportar(con, "qualidade_resumo",
                        "SELECT regra, severidade, linhas, pct_do_total FROM qualidade_resumo", saida)
    secoes.append(("Qualidade dos dados: o que cada regra encontrou", cab, lin, None))
    cab, lin = exportar(con, "conciliacao", f"""
        SELECT 'bronze' AS camada, {n_bronze} AS linhas UNION ALL
        SELECT 'silver', {n_silver} UNION ALL
        SELECT 'quarentena', {n_quar} UNION ALL
        SELECT 'gold (fato_voos)', {n_gold}""", saida)
    secoes.append(("Conciliação entre camadas", cab, lin, None))

    for arq in sorted((RAIZ / "sql" / "validacoes").glob("*.sql")):
        cab, lin = exportar(con, arq.stem, arq.read_text(encoding="utf-8"), saida)
        secoes.append((f"Validação: {arq.stem}", cab, lin, 40))
    for arq in sorted((RAIZ / "sql" / "perguntas").glob("*.sql")):
        cab, lin = exportar(con, arq.stem, arq.read_text(encoding="utf-8"), saida)
        secoes.append((arq.stem, cab, lin, 25))

    md = ["# Resultados da execução\n",
          f"Gerado por `src/pipeline.py` em {time.strftime('%Y-%m-%d %H:%M')} a partir dos CSVs públicos da ANAC. "
          "Cada tabela abaixo é a saída de uma consulta em `sql/`.\n"]
    for titulo, cab, lin, lim in secoes:
        md.append(f"\n## {titulo}\n\n" + tabela_md(cab, lin, lim) + "\n")
    (saida / "resultados.md").write_text("\n".join(md), encoding="utf-8")
    con.close()
    log(f"pronto em {time.time() - inicio:.0f}s. Banco: {banco}. Resultados: outputs/")


if __name__ == "__main__":
    principal()
