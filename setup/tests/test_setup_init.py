import unittest

from setup import setup_init

# setup_init.pyのテストコード

class SetupInitTest(unittest.TestCase):
    def setUp(self):
        # 初期化処理
        pass

    def tearDown(self):
        # 終了処理
        pass

    # 何回目？の入力が正しいとき
    def test_correct_ordinal(self):
        for ordinal in [1, 2]:
            with self.subTest(ordinal=ordinal):
                self.assertTrue(setup_init.is_correct_ordinal(ordinal))

    # 何回目？の入力が正しくないとき
    def test_incorrect_ordinal(self):
        for ordinal in [0, 3]:
            with self.subTest(ordinal=ordinal):
                self.assertFalse(setup_init.is_correct_ordinal(ordinal))

    # 年度取得のテスト
    def test_get_fiscal_year(self):
        for month in range(1, 4):
            with self.subTest(month=month):
                self.assertEqual(2018, setup_init.get_fiscal_year(2019, month))
        for month in range(4, 13):
            with self.subTest(month=month):
                self.assertEqual(2019, setup_init.get_fiscal_year(2019, month))

    # デフォルト何回目？のテスト
    def test_get_default_ordinal_str(self):
        for month in range(1, 4):
            with self.subTest(month=month):
                self.assertEqual('2', setup_init.get_default_ordinal_str(month))
        for month in range(4, 10):
            with self.subTest(month=month):
                self.assertEqual('1', setup_init.get_default_ordinal_str(month))
        for month in range(10, 13):
            with self.subTest(month=month):
                self.assertEqual('2', setup_init.get_default_ordinal_str(month))

    # 何回目？の漢字版が取得できるかのテスト
    def test_get_ordinal_kanji(self):
        for ordinal, result in [(1, '一'), (2, '二')]:
            with self.subTest(ordinal=ordinal, result=result):
                self.assertEqual(result, setup_init.get_ordinal_kanji(ordinal))

    # セメスターが取得できるかのテスト
    def test_get_semester(self):
        for ordinal, result in [(1, '\zenki'), (2, '\kouki')]:
            with self.subTest(ordinal=ordinal, result=result):
                self.assertEqual(result, setup_init.get_semester(ordinal))

    # リポジトリ名が取得できるかのテスト
    def test_get_repo_name(self):
        self.assertEqual('soukai-2019-1', setup_init.get_repo_name(2019, 1))

if __name__ == "__main__":
    unittest.main()