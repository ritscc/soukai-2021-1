import unittest

from setup import setup_create_files as create_files
from setup import setup_config as config

class SetupCreateFilesTest(unittest.TestCase):
    def setUp(self):
        # 初期化処理
        pass

    def tearDown(self):
        # 終了処理
        pass

    def test_correct_is_subsection_path(self):
        for path in ['soukatsu/zentai/1_soukatsu', 'houshin/soumu/1_zentai']:
            with self.subTest(path=path + '.tex'):
                self.assertTrue(create_files.is_subsection_path(path + '.tex'))

    def test_incorrect_is_subsection_path(self):
        for path in ['hajimeni', 'soukatsu/1kai']:
            with self.subTest(path=path + '.tex'):
                self.assertFalse(create_files.is_subsection_path(path + '.tex'))

    def test_correct_is_kaisei_tex(self):
        for kaisei in [1, 2, 3, 4]:
            with self.subTest(kaisei='/soukatsu/' + str(kaisei) + '.tex'):
                self.assertTrue(create_files.is_kaisei_tex('/soukatsu/' + str(kaisei) + 'kai.tex'))

    def test_incorrect_is_kaisei_tex(self):
        for kaisei in ['hajimeni', 'soukatsu/zentai/1_soukatsu']:
            with self.subTest(kaisei=kaisei + '.tex'):
                self.assertFalse(create_files.is_kaisei_tex(kaisei + '.tex'))

    def test_correct_is_hajimeni_tex(self):
        self.assertTrue(create_files.is_hajimeni_tex('hajimeni.tex'))

    def test_incorrect_is_hajimeni_tex(self):
        self.assertFalse(create_files.is_hajimeni_tex('hajimejanai.tex'))

    def test_get_positions(self):
        for department in config.DEPARTMENTS:
            with self.subTest(section=department):
                result = ['\\' + department + 'Chief', '\\' + department + 'Staff']
                self.assertEqual(result, create_files.get_positions(department))
        with self.subTest(section='kaisei'):
            result = config.KAISEI_COMMANDS
            self.assertEqual(result, create_files.get_positions('kaisei'))
        for section in ['hajimeni', 'systemjanai', 'kaiseijanai']:
            with self.subTest(section=section):
                result = ['\president', '\subPresident'] + config.KAISEI_COMMANDS
                self.assertEqual(result, create_files.get_positions(section))

    def test_get_section_from_subsection_path(self):
        subsection_path: str = 'soukatsu/system/1_zentai.tex'
        self.assertEqual('system', create_files.get_section_from_subsection_path(subsection_path))
