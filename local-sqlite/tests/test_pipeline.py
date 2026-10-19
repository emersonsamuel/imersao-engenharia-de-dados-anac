"""Testes do pipeline. Rodam contra o banco gerado por src/pipeline.py.

    python src/pipeline.py --dados ./dados
    ANAC_DADOS=./dados python -m unittest discover -s tests -v

O teste "recalculo independente" não usa o SQL do projeto: lê os CSVs brutos com a biblioteca csv,
reaplica as regras de qualidade em Python e compara o resultado com o que está na Gold.
"""
import csv
import os
import sqlite3
import unittest
from datetime import datetime
from pathlib import Path

RAIZ = Path(__file__).resolve().parent.parent
BANCO = RAIZ / "build" / "anac.db"
DADOS = Path(os.environ.get("ANAC_DADOS", RAIZ.parent / "dados"))


def ts(s):
    return None if s == "null" else datetime.strptime(s[:19], "%Y-%m-%d %H:%M:%S")


def minutos(real, prev):
    return None if real is None or prev is None else round((real - prev).total_seconds() / 60)


@unittest.skipUnless(BANCO.exists(), "rode src/pipeline.py antes")
class TestPipeline(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.con = sqlite3.connect(BANCO)

    def um(self, sql):
        return self.con.execute(sql).fetchone()[0]

    def test_conciliacao_entre_camadas(self):
        bronze = self.um("SELECT COUNT(*) FROM b_vra")
        silver = self.um("SELECT COUNT(*) FROM silver_voos")
        quar = self.um("SELECT COUNT(*) FROM voos_quarentena")
        gold = self.um("SELECT COUNT(*) FROM fato_voos")
        self.assertEqual(bronze, silver)
        self.assertEqual(silver, quar + gold)

    def test_quarentena_nunca_chega_na_gold(self):
        self.assertEqual(
            self.um("SELECT COUNT(*) FROM fato_voos WHERE voo_id IN (SELECT id FROM voos_quarentena)"), 0)

    def test_chave_do_fato_e_unica(self):
        self.assertEqual(self.um("SELECT COUNT(*) - COUNT(DISTINCT voo_id) FROM fato_voos"), 0)

    def test_gold_respeita_os_limites_de_atraso(self):
        self.assertEqual(self.um(
            "SELECT COUNT(*) FROM fato_voos WHERE abs(atraso_partida_min) > 1440 OR abs(atraso_chegada_min) > 1440"), 0)

    def test_realizado_tem_atraso_e_cancelado_nao(self):
        self.assertEqual(self.um(
            "SELECT COUNT(*) FROM fato_voos WHERE situacao='REALIZADO' AND atraso_chegada_min IS NULL"), 0)
        self.assertEqual(self.um(
            "SELECT COUNT(*) FROM fato_voos WHERE situacao='CANCELADO' AND atraso_chegada_min IS NOT NULL"), 0)

    def test_nao_ha_texto_null_na_silver(self):
        self.assertEqual(self.um(
            "SELECT COUNT(*) FROM silver_voos WHERE partida_prevista='null' OR partida_real='null'"), 0)

    @unittest.skipUnless((DADOS / "vra").exists(), "defina ANAC_DADOS com a pasta dos CSVs")
    def test_recalculo_independente_pontualidade_de_uma_empresa(self):
        """Recalcula, direto do CSV bruto, a pontualidade da GOL (GLO) e compara com o SQL."""
        vistos, pontuais, realizados, programados, cancelados = set(), 0, 0, 0, 0
        for arq in sorted((DADOS / "vra").glob("*.csv")):
            with open(arq, encoding="utf-8-sig", newline="") as fh:
                fh.readline()
                leitor = csv.reader(fh, delimiter=";")
                next(leitor)
                for r in leitor:
                    if not r:
                        continue
                    chave = tuple(r)
                    duplicada = chave in vistos
                    vistos.add(chave)
                    emp, _, _, _, org, dst, pp, pr, cp, cr, sit, _ = r
                    pp, pr, cp, cr = ts(pp), ts(pr), ts(cp), ts(cr)
                    ap, ac = minutos(pr, pp), minutos(cr, cp)
                    if emp != "GLO" or duplicada or org == dst:
                        continue
                    if sit == "REALIZADO" and (pp is None or cp is None):
                        continue
                    if (ap is not None and abs(ap) > 1440) or (ac is not None and abs(ac) > 1440):
                        continue
                    programados += 1
                    if sit == "CANCELADO":
                        cancelados += 1
                    else:
                        realizados += 1
                        pontuais += ac <= 15
        esperado_pontual = round(100.0 * pontuais / realizados, 1)
        esperado_cancel = round(100.0 * cancelados / programados, 2)
        sql_pontual, sql_cancel, sql_prog = self.con.execute("""
            SELECT ROUND(100.0*AVG(pontual_chegada),1), ROUND(100.0*SUM(cancelado)/COUNT(*),2), COUNT(*)
            FROM obt_voos WHERE empresa_icao='GLO' AND origem_icao<>destino_icao""").fetchone()
        self.assertEqual(sql_prog, programados)
        self.assertEqual(sql_pontual, esperado_pontual)
        self.assertEqual(sql_cancel, esperado_cancel)


if __name__ == "__main__":
    unittest.main()
