import unittest

from setup import assignees
from setup.assignees import ArticleInfo
from setup.assignees import Assignee
from setup import setup_config as config

class AssigneesTest(unittest.TestCase):
    def setUp(self):
        # 初期化処理
        self.addTypeEqualityFunc(ArticleInfo, self.ArticleInfo_assertEqual)
        self.addTypeEqualityFunc(Assignee, self.Assignee_assertEqual)

    def tearDown(self):
        # 終了処理
        pass

    def test_create_type_assignees_data(self):

        yml_data: dict = {
            'hajimeni': 'はじめに,田所 浩二,114514',
            'soukatsu': {
                'zentai': {
                    '1_zentai': '前期活動総括,田所 浩二',
                    '2_unei': '運営総括'
                },
                '1kai': '1回生総括',
                '2kai': '2回生総括',
                '3kai': '3回生総括',
                '4kai': '4回生総括',
                'kaikei': None,
                'kensui': None,
                'syogai': None,
                'system': {
                    '1_zentai': '全体総括',
                },
                'soumu': None
            },
            'houshin': {
                'zentai': {
                    '1_zentai': '前期活動方針',
                    '2_unei': '運営方針'
                },
                '1kai': '1回生方針',
                '2kai': '2回生方針',
                '3kai': '3回生方針',
                'kaikei': None,
                'kensui': None,
                'syogai': None,
                'system': {
                    '1_zentai': '全体方針',
                },
                'soumu': None
            }
        }

        result: dict = {
            'hajimeni.tex': ArticleInfo('はじめに', Assignee('114514', '田所', '浩二')),
            'soukatsu/zentai/1_zentai.tex': ArticleInfo('前期活動総括', Assignee(family='田所', name='浩二')),
            'soukatsu/zentai/2_unei.tex': ArticleInfo('運営総括', Assignee()),
            'soukatsu/1kai.tex': ArticleInfo('1回生総括', Assignee()),
            'soukatsu/2kai.tex': ArticleInfo('2回生総括', Assignee()),
            'soukatsu/3kai.tex': ArticleInfo('3回生総括', Assignee()),
            'soukatsu/4kai.tex': ArticleInfo('4回生総括', Assignee()),
            'soukatsu/system/1_zentai.tex': ArticleInfo('全体総括', Assignee()),
            'houshin/zentai/1_zentai.tex': ArticleInfo('前期活動方針', Assignee()),
            'houshin/zentai/2_unei.tex': ArticleInfo('運営方針', Assignee()),
            'houshin/1kai.tex': ArticleInfo('1回生方針', Assignee()),
            'houshin/2kai.tex': ArticleInfo('2回生方針', Assignee()),
            'houshin/3kai.tex': ArticleInfo('3回生方針', Assignee()),
            'houshin/system/1_zentai.tex': ArticleInfo('全体方針', Assignee()),
        }

        for key, value in assignees.create_type_assignees_data(yml_data).items():
            with self.subTest(yml_data=str(result[key]), result=str(value)):
                self.assertEqual(result[key], value)

        self.assertEqual(result, assignees.create_type_assignees_data(yml_data))

    def test_create_section_assignees_data(self):
        test_data: dict = {
            'zentai': {
                '1_zentai': '前期活動総括,田所 浩二,114514',
                '2_unei': '運営総括,田所 浩二',
                '3_gakusai': '学園祭総括',
            },
            'system': {
                '1_zentai': '全体方針',
            },
        }

        result: dict = {
            'soukatsu/zentai/1_zentai.tex': ArticleInfo('前期活動総括', Assignee('114514', '田所', '浩二')),
            'soukatsu/zentai/2_unei.tex': ArticleInfo('運営総括', Assignee(family='田所', name='浩二')),
            'soukatsu/zentai/3_gakusai.tex': ArticleInfo('学園祭総括', Assignee()),
            'soukatsu/system/1_zentai.tex': ArticleInfo('全体方針', Assignee()),
        }

        for key, value in assignees.create_section_assignees_data(test_data, {}, 'soukatsu').items():
            with self.subTest(test_data=str(result[key]), result=str(value)):
                self.assertEqual(result[key], value)

        self.assertEqual(result, assignees.create_section_assignees_data(test_data, {}, 'soukatsu'))

    def test_create_subsection_assignees_data(self):
        test_data: dict = {
            '1_zentai': '前期活動総括,田所 浩二,114514',
            '2_unei': '運営総括,田所 浩二',
            '3_gakusai': '学園祭総括',
        }

        result: dict = {
            'soukatsu/zentai/1_zentai.tex': ArticleInfo('前期活動総括', Assignee('114514', '田所', '浩二')),
            'soukatsu/zentai/2_unei.tex': ArticleInfo('運営総括', Assignee(family='田所', name='浩二')),
            'soukatsu/zentai/3_gakusai.tex': ArticleInfo('学園祭総括', Assignee()),
        }

        for key, value in assignees.create_subsection_assignees_data(test_data, {}, 'soukatsu', 'zentai').items():
            with self.subTest(test_data=str(result[key]), result=str(value)):
                self.assertEqual(result[key], value)

        self.assertEqual(result, assignees.create_subsection_assignees_data(test_data, {}, 'soukatsu', 'zentai'))

    def test_parse_assignee_three_args(self):
        test_data: str = 'はじめに,田所 浩二,114514'
        result: ArticleInfo = ArticleInfo('はじめに', Assignee('114514', '田所', '浩二'))
        self.assertEqual(result, assignees.parse_assignee(test_data))

    def test_parse_assignee_two_args(self):
        test_data: str = 'はじめに,田所 浩二'
        result: ArticleInfo = ArticleInfo('はじめに', Assignee(family='田所', name='浩二'))
        self.assertEqual(result, assignees.parse_assignee(test_data))

    def test_parse_assignee_one_args(self):
        test_data: str = 'はじめに'
        result: ArticleInfo = ArticleInfo('はじめに', Assignee())
        self.assertEqual(result, assignees.parse_assignee(test_data))

    def test_get_tex_path_three_args(self):
        type_name = 'houshin'
        section_name = 'kensui'
        subsection_name = '1_zentai'
        result = 'houshin/kensui/1_zentai.tex'
        self.assertEqual(result, assignees.get_tex_path(type_name, section_name, file_name=subsection_name))

    def test_get_tex_path_two_args(self):
        type_name = 'houshin'
        section_name = '1kai'
        result = 'houshin/1kai.tex'
        self.assertEqual(result, assignees.get_tex_path(type_name, file_name=section_name))

    def test_get_tex_path_one_args(self):
        type_name = 'hajimeni'
        result = 'hajimeni.tex'
        self.assertEqual(result, assignees.get_tex_path(file_name=type_name))

    def test_correct_is_type_hajimeni(self):
        type_name = 'hajimeni'
        self.assertTrue(assignees.is_type_hajimeni(type_name))

    def test_incorrect_is_type_hajimeni(self):
        for type_name in ['hajimejanai', 'soukatsu', 'houshin']:
            with self.subTest(type_name=type_name):
                self.assertFalse(assignees.is_type_hajimeni(type_name))

    def test_correct_is_type_soukatsu_or_houshin(self):
        for type_name in ['soukatsu', 'houshin']:
            with self.subTest(type_name=type_name):
                self.assertTrue(assignees.is_type_soukatsu_or_houshin(type_name))

    def test_incorrect_is_type_soukatsu_or_houshin(self):
        for type_name in ['hajimeni', 'soukatsujanai', 'houshinjanai']:
            with self.subTest(type_name=type_name):
                self.assertFalse(assignees.is_type_soukatsu_or_houshin(type_name))

    def test_correct_is_section_nkai(self):
        for section_name in ['1kai', '2kai', '3kai', '4kai']:
            with self.subTest(type_name=section_name):
                self.assertTrue(assignees.is_section_nkai(section_name))

    def test_incorrect_is_section_nkai(self):
        for section_name in config.DEPARTMENTS + ['zentai']:
            with self.subTest(type_name=section_name):
                self.assertFalse(assignees.is_section_nkai(section_name))

    def test_correct_is_section_department_or_zentai(self):
        for section_name in config.DEPARTMENTS + ['zentai']:
            with self.subTest(type_name=section_name):
                self.assertTrue(assignees.is_section_department_or_zentai(section_name))

    def test_incorrect_is_section_department_or_zentai(self):
        for section_name in ['1kai', '2kai', '3kai', '4kai']:
            with self.subTest(type_name=section_name):
                self.assertFalse(assignees.is_section_department_or_zentai(section_name))

    def test_correct_is_not_full_name_none(self):
        self.assertTrue(assignees.is_not_full_name_none('田所 浩二'))

    def test_incorrect_is_not_full_name_none(self):
        self.assertFalse(assignees.is_not_full_name_none(None))

    def ArticleInfo_assertEqual(self, first: ArticleInfo, second: ArticleInfo, msg=None):
        self.assertEqual(first.title, second.title)
        self.Assignee_assertEqual(first.assignee, second.assignee)

    def Assignee_assertEqual(self, first: Assignee, second: Assignee, msg=None):
        self.assertEqual(first.family, second.family)
        self.assertEqual(first.name, second.name)
        self.assertEqual(first.github_id, second.github_id)
