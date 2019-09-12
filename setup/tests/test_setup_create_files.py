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

    def test_correct_is_target_path_with_filepath(self):
        input_pathes = [
            ['./src/soukatsu', 'soukatsu/system/1_zentai.tex'],
            ['./src/soukatsu', 'soukatsu/1kai.tex'],
            ['./src/soukatsu/system', 'soukatsu/system/1_zentai.tex'],
            ['soukatsu/system', 'soukatsu/system/1_zentai.tex'],
        ]
        for input_path, target_path in input_pathes:
            with self.subTest(input_path=input_path, target_path=target_path):
                self.assertTrue(create_files.is_target_path(target_path, input_path))

    def test_incorrect_is_target_path_with_filepath(self):
        input_pathes = [
            ['./src/soukatsu', 'houshin/system/1_zentai.tex'],
            ['./src/soukatsu', 'hajimeni.tex'],
            ['./src/soukatsu/system', 'houshin/system/1_zentai.tex'],
            ['./src/soukatsu/system', 'soukatsu/soumu/1_zentai.tex'],
            ['./src/soukatsu/system', 'hajimeni.tex'],
            ['soukatsu/system', 'houshin/system/1_zentai.tex'],
            ['soukatsu/system', 'soukatsu/soumu/1_zentai.tex'],
            ['soukatsu/system', 'hajimeni.tex'],
        ]
        for input_path, target_path in input_pathes:
            with self.subTest(input_path=input_path, target_path=target_path):
                self.assertFalse(create_files.is_target_path(target_path, input_path))

    def test_correct_is_target_path_with_type(self):
        type_names = [
            ['hajimeni', 'hajimeni.tex'],
            ['soukatsu', 'soukatsu/system/1_zentai.tex'],
            ['soukatsu', 'soukatsu/1kai.tex'],
            ['houshin', 'houshin/system/1_zentai.tex'],
            ['houshin', 'houshin/1kai.tex'],
        ]
        for type_name, target_path in type_names:
            with self.subTest(type_name=type_name, target_path=target_path):
                self.assertTrue(create_files.is_target_path(target_path, type_name))

    def test_incorrect_is_target_path_with_type(self):
        type_names = [
            ['hajimeni', 'soukatsu/system/1_zentai.tex'],
            ['hajimeni', 'houshin/system/1_zentai.tex'],
            ['soukatsu', 'houshin/system/1_zentai.tex'],
            ['soukatsu', 'hajimeni.tex'],
            ['houshin', 'soukatsu/system/1_zentai.tex'],
            ['houshin', 'hajimeni.tex'],
        ]
        for type_name, target_path in type_names:
            with self.subTest(type_name=type_name, target_path=target_path):
                self.assertFalse(create_files.is_target_path(target_path, type_name))

    def test_correct_is_target_path_with_type_and_section(self):
        type_name_and_sections = [
            ['soukatsu', 'zentai', 'soukatsu/zentai/1_zentai.tex'],
            ['soukatsu', 'kaikei', 'soukatsu/kaikei/1_zentai.tex'],
            ['soukatsu', 'kensui', 'soukatsu/kensui/1_zentai.tex'],
            ['soukatsu', 'syogai', 'soukatsu/syogai/1_zentai.tex'],
            ['soukatsu', 'system', 'soukatsu/system/1_zentai.tex'],
            ['soukatsu', 'soumu', 'soukatsu/soumu/1_zentai.tex'],
            ['houshin', 'zentai', 'houshin/zentai/1_zentai.tex'],
            ['houshin', 'kaikei', 'houshin/kaikei/1_zentai.tex'],
            ['houshin', 'kensui', 'houshin/kensui/1_zentai.tex'],
            ['houshin', 'syogai', 'houshin/syogai/1_zentai.tex'],
            ['houshin', 'system', 'houshin/system/1_zentai.tex'],
            ['houshin', 'soumu', 'houshin/soumu/1_zentai.tex'],
        ]
        for type_name, section, target_path in type_name_and_sections:
            with self.subTest(type_name=type_name, section=section, target_path=target_path):
                self.assertTrue(create_files.is_target_path(target_path, type_name, section))

    def test_incorrect_is_target_path_with_type_and_section(self):
        type_name_and_sections = [
            ['soukatsu', 'zentai', 'houshin/zentai/1_zentai.tex'],
            ['soukatsu', 'zentai', 'soukatsu/kaikei/1_zentai.tex'],
            ['soukatsu', 'kaikei', 'hoishin/kaikei/1_zentai.tex'],
            ['soukatsu', 'kaikei', 'soukatsu/kensui/1_zentai.tex'],
            ['soukatsu', 'kensui', 'houshin/kensui/1_zentai.tex'],
            ['soukatsu', 'kensui', 'soukatsu/syogai/1_zentai.tex'],
            ['soukatsu', 'syogai', 'houshin/syogai/1_zentai.tex'],
            ['soukatsu', 'syogai', 'soukatsu/system/1_zentai.tex'],
            ['soukatsu', 'system', 'houshin/system/1_zentai.tex'],
            ['soukatsu', 'system', 'soukatsu/soumu/1_zentai.tex'],
            ['soukatsu', 'soumu', 'houshin/soumu/1_zentai.tex'],
            ['soukatsu', 'soumu', 'soukatsu/zentai/1_zentai.tex'],
            ['houshin', 'zentai', 'soukatsu/zentai/1_zentai.tex'],
            ['houshin', 'zentai', 'houshin/kaikei/1_zentai.tex'],
            ['houshin', 'kaikei', 'soukatsu/kaikei/1_zentai.tex'],
            ['houshin', 'kaikei', 'houshin/kensui/1_zentai.tex'],
            ['houshin', 'kensui', 'soukatsu/kensui/1_zentai.tex'],
            ['houshin', 'kensui', 'houshin/syogai/1_zentai.tex'],
            ['houshin', 'syogai', 'soukatsu/syogai/1_zentai.tex'],
            ['houshin', 'syogai', 'houshin/system/1_zentai.tex'],
            ['houshin', 'system', 'soukatsu/system/1_zentai.tex'],
            ['houshin', 'system', 'houshin/soumu/1_zentai.tex'],
            ['houshin', 'soumu', 'soukatsu/soumu/1_zentai.tex'],
            ['houshin', 'soumu', 'houshin/zentai/1_zentai.tex'],
        ]
        for type_name, section, target_path in type_name_and_sections:
            with self.subTest(type_name=type_name, section=section, target_path=target_path):
                self.assertFalse(create_files.is_target_path(target_path, type_name, section))

    def test_correct_is_target_path_with_no_args(self):
        target_pathes = [
            'hajimeni.tex',
            'soukatsu/1kai.tex',
            'soukatsu/system/1_zentai.tex',
            'houshin/1kai.tex',
            'houshin/system/1_zentai.tex',
        ]
        for target_path in target_pathes:
            with self.subTest(target_path=target_path):
                self.assertTrue(create_files.is_target_path(target_path, *[]))


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

    def test_get_root_ignore_path(self):
        path1: str = './src/soukatsu/system/1_zentai.tex'
        self.assertEqual('soukatsu/system/1_zentai.tex', create_files.get_root_ignore_path(path1))
        path2: str = 'src/soukatsu/system/1_zentai.tex'
        self.assertEqual('soukatsu/system/1_zentai.tex', create_files.get_root_ignore_path(path2))

    def test_get_section_from_subsection_path(self):
        subsection_path: str = 'soukatsu/system/1_zentai.tex'
        self.assertEqual('system', create_files.get_section_from_subsection_path(subsection_path))