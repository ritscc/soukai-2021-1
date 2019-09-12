import os.path as path
import re

from jinja2 import Environment, FileSystemLoader

from setup import assignees
from setup.assignees import ArticleInfo
from setup import setup_config as config
from setup import setup_msg as msg
from setup import create_util as util

# yamlの情報からファイルを生成
def create_files(*args) -> None:
    for path, assignee_info in assignees.assignees().items():
        if util.is_target_path(path, *args):
            create_file(path, assignee_info)

# texファイルを生成
def create_file(filepath: str, info: ArticleInfo) -> None:
    # テンプレートファイルのパスを指定
    file_loader = FileSystemLoader(config.TEMPLATE_ROOT_PATH)
    env = Environment(loader=file_loader)
    tex_template = env.get_template(config.DOCUMENT_PARTS_TEX_TEMPLATE)

    if is_subsection_path(filepath):
        section: str = get_section_from_subsection_path(filepath)
        subsection_filepath: str = path.join(config.SRC_ROOT_PATH, filepath)

        # ファイルがあれば何もしない
        if path.exists(subsection_filepath):
            print(msg.ERROR_FILE_EXIST(subsection_filepath))
            return

        positions:list = get_positions(section)

        # ファイル生成
        with open(subsection_filepath, mode='w') as f:
            f.write(tex_template.render(title=info.get_title(), positions=positions, assignee=info.get_assignee(), is_newfile=True))

        print(msg.CREATED_FILE_MSG(subsection_filepath))

    elif is_kaisei_tex(filepath) or is_hajimeni_tex(filepath):
        # 回生別 または はじめに の場合
        subsection_filepath: str = path.join(config.SRC_ROOT_PATH, filepath)
        type_name: str = None if is_hajimeni_tex(filepath) else 'kaisei'

        print(msg.WORNING_FILE_CHANGE(subsection_filepath))

        positions:list = get_positions(type_name)

        # ファイルを上書き
        with open(subsection_filepath, mode='a') as f:
            f.write(tex_template.render(title=info.get_title(), positions=positions, assignee=info.get_assignee(), is_newfile=False))

        print(msg.OVERWRITTEN_FILE_MSG(subsection_filepath))

    else:
        print(msg.ERROR_UNSUPPORTED_FILE_PATH)
        return

# パスがサブセクションに相当するものか
def is_subsection_path(path: str) -> bool:
    return re.match(r'^([^/]+)/([^/]+)/(.+)$', path) is not None

def is_kaisei_tex(path: str) -> bool:
    return re.search(r'/[1234]kai.tex$', path) is not None

def is_hajimeni_tex(path: str) -> bool:
    return path == 'hajimeni.tex'

# 役職リストを生成
def get_positions(section: str = None) -> list:
    if section in config.DEPARTMENTS:
        return ['\\' + section + 'Chief', '\\' + section + 'Staff']
    elif section == 'kaisei':
        return config.KAISEI_COMMANDS
    else:
        return ['\president', '\subPresident'] + config.KAISEI_COMMANDS

# サブセクションに相当するパスからセクションを取得
def get_section_from_subsection_path(path: str) -> str:
    result = re.search(r'/[^/]+/', path)
    return re.search(r'[^/]+', result.group(0)).group(0)