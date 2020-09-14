# 文責情報を読み込むためのモジュール

import yaml
import os.path as path
import re

from setup import setup_config as config

class Assignee:
    def __init__(self, github_id: str = None, family: str = '姓', name: str = '名'):
        self.github_id: str = github_id
        self.family: str = family
        self.name: str = name

    def __str__(self):
        return 'family: ' + self.family + ' name: ' + self.name + ' github_id: ' + str(self.github_id)

    def __eq__(self, value):
        return self.family == value.family and\
            self.name == value.name and\
            self.github_id == self.github_id

    def get_github_id(self) -> str:
        return self.github_id

    def set_github_id(self, github_id: str) -> None:
        self.github_id = github_id

    def get_family(self) -> str:
        return self.family

    def set_family(self, family: str) -> None:
        self.family = family

    def get_name(self) -> str:
        return self.name

    def set_name(self, name: str) -> None:
        self.name = name

class ArticleInfo:
    def __init__(self, title: str = None, assignee: Assignee = Assignee()):
        self.title: str = title
        self.assignee: Assignee = assignee

    def __str__(self):
        return 'title: ' + str(self.title) + ' assignee: [ ' + str(self.assignee) + ' ]'

    def __eq__(self, value):
        return self.title == value.title and\
            self.assignee == value.assignee

    def get_title(self) -> str:
        return self.title

    def set_title(self, title: str) -> None:
        self.title = title

    def get_assignee(self) -> Assignee:
        return self.assignee

    def set_assignee(self, assignee: str) -> None:
        self.assignee = assignee

def assignees() -> dict:
    # yamlのロード
    with open(config.ASSIGNEE_PATH) as f:
        yml = yaml.load(f, Loader=yaml.FullLoader)

    assignee_list: dict = create_type_assignees_data(yml)

    return assignee_list

# ルート（タイプ）レベルの文責情報を作成
def create_type_assignees_data(yml: dict) -> dict:
    assignee_list: dict = {}

    for type_name, type_data in yml.items():
        if type_data is None:
            continue
        if is_type_hajimeni(type_name):
            assignee_list[get_tex_path(file_name=type_name)] = parse_assignee(type_data)
        elif is_type_soukatsu_or_houshin(type_name):
            assignee_list = create_section_assignees_data(type_data, assignee_list, type_name)

    return assignee_list

# セクションレベルの文責情報を作成
def create_section_assignees_data(type_data: dict, assignee_list: dict, type_name: str) -> dict:
    for section_name, section_data in type_data.items():
        if section_data is None:
            continue
        if is_section_nkai(section_name):
            assignee_list[get_tex_path(type_name, file_name=section_name)] = parse_assignee(section_data)
        elif is_section_department_or_zentai(section_name):
            assignee_list = create_subsection_assignees_data(section_data, assignee_list, type_name, section_name)

    return assignee_list

# サブセクションレベルの文責情報を作成
def create_subsection_assignees_data(\
  section_data: dict, assignee_list: dict, type_name: str, section_name: str) -> dict:
    for subsection_name, subsection_data in section_data.items():
        assignee_list[get_tex_path(type_name, section_name, file_name=subsection_name)] = parse_assignee(subsection_data)

    return assignee_list

# タイトル,氏名,GitHub IDをArticleInfoクラスに変換します
def parse_assignee(assignee_data: str) -> ArticleInfo:
    result: ArticleInfo = ArticleInfo(assignee=Assignee())

    parsed_data = assignee_data.split(',')
    if len(parsed_data) == 1:
        parsed_data += [None, None]
    elif len(parsed_data) == 2:
        parsed_data += [None]

    title, full_name, github_id = parsed_data
    result.set_title(title)
    result.get_assignee().set_github_id(github_id)

    if is_not_full_name_none(full_name):
        family, name = full_name.split(' ')
        result.get_assignee().set_family(family)
        result.get_assignee().set_name(name)

    return result

def get_tex_path(*parents, file_name: str) -> str:
    pathes: tuple = parents + (file_name + '.tex', )
    return path.join(*pathes)

def is_type_hajimeni(type_name: str) -> bool:
    return type_name == 'hajimeni'

def is_type_soukatsu_or_houshin(type_name: str) -> bool:
    return type_name in ['soukatsu', 'houshin']

def is_section_nkai(section_name: str) -> bool:
    return re.match('^.+kai$', section_name) is not None

def is_section_department_or_zentai(section_name: str) -> bool:
    return section_name in config.DEPARTMENTS + ['zentai']

def is_not_full_name_none(full_name: str) -> bool:
    return full_name is not None