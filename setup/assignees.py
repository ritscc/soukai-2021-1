# 文責情報を読み込むためのモジュール

import yaml
import os.path as path

from setup import setup_config as config

class Assignee:
    def __init__(self):
        self.gitlab_id: str
        self.family: str
        self.name: str

class ArticleInfo:
    def __init__(self):
        self.title: str
        self.assignee: Assignee

def assignees() -> dict:
    # yamlのロード
    with open(config.ASSIGNEE_PATH) as f:
        yml = yaml.load(f)

    assignee_list: dict = create_type_assignees_data(yml)

    return assignee_list

# ルート（タイプ）レベルの文責情報を作成
def create_type_assignees_data(yml: dict) -> dict:
    assignee_list: dict = {}

    for type_name, type_data in yml:
        if type_data is None:
            continue
        if is_type_hajimeni(type_name):
            assignee_list[get_tex_path(file_name=type_name)] = parse_assignee(type_data)
        elif is_type_soukatsu_or_houshin(type_name):
            assignee_list = create_section_assignees_data(type_data, assignee_list, type_name)

    return assignee_list

# セクションレベルの文責情報を作成
def create_section_assignees_data(type_data: dict, assignee_list: dict, type_name: str) -> dict:
    for section_name, section_data in type_data:
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
    for subsection_name, subsection_data in section_data:
        assignee_list[get_tex_path(type_name, section_name, file_name=subsection_name)] = parse_assignee(subsection_data)

    return assignee_list

# タイトル,氏名,GitLab IDをArticleInfoクラスに変換します
def parse_assignee(assignee_data: str) -> ArticleInfo:
    result: ArticleInfo = ArticleInfo()

    result.title, full_name, result.assignee.gitlab_id = assignee_data.split(',')

    if full_name is not None:
        result.assignee.family, result.assignee.name = full_name.split(' ')
    else:
        # デフォルト値を設定
        result.assignee.family = '姓'
        result.assignee.name = '名'

    return result

def get_tex_path(*parents, file_name: str) -> str:
    pathes: tuple = parents + (file_name + '.tex', )
    return path.join(*pathes)

def is_type_hajimeni(type_name: str) -> bool:
    return type_name == 'hajimeni'

def is_type_soukatsu_or_houshin(type_name: str) -> bool:
    return type_name in ['soukatsu', 'houshin']

def is_section_nkai(section_name: str) -> bool:
    return 'kai' in section_name

def is_section_department_or_zentai(section_name: str) -> bool:
    return section_name in config.DEPARTMENTS + ['zentai']