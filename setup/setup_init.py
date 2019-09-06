import datetime
from datetime import datetime as dt
import os
from jinja2 import Environment, FileSystemLoader

import setup_msg as msg
import setup_config as config

# soukai.texのための情報クラス
class SoukaiInfo:
    def __init__(self):
        self.date: dt
        self.last_year: int
        # 年度
        self.fiscal_year: int
        self.next_year: int
        # 開催回数(1 or 2)
        self.ordinal: int
        self.ordinal_kanji: str
        self.semester: str
        self.repo_name: str

def init():
    soukaiInfo: SoukaiInfo = SoukaiInfo()

    today: datetime = datetime.date.today()

    # 開催日の設定
    while True:
        try:
            input_str = input(msg.MEETING_DAY_INPUT_GUIDE(today.strftime(config.DATE_FORMAT))) \
                or today.strftime(config.DATE_FORMAT)
            soukaiInfo.date = dt.strptime(input_str, config.DATE_FORMAT)

            # 結果表示
            print(msg.DELETE_LAST_LINE)
            print(msg.MEETING_DAY_INPUT_GUIDE(today.strftime(config.DATE_FORMAT)) + \
                soukaiInfo.date.strftime(config.DATE_FORMAT))

            soukaiInfo.fiscal_year = get_fiscal_year(soukaiInfo.date.year, soukaiInfo.date.month)
            soukaiInfo.last_year = soukaiInfo.fiscal_year - 1
            soukaiInfo.next_year = soukaiInfo.fiscal_year + 1
            break
        except:
            print(msg.ERROR_INVAID_FORMAT)

    # 回数の指定（1 or 2）
    while True:
        try:
            # デフォルト値は4月〜9月の間なら1、そうでなければ2
            default_ordinal_str = get_default_ordinal_str(soukaiInfo.date.month)
            input_str = input(msg.ORDINAL_INPUT_GUIDE(default_ordinal_str)) or default_ordinal_str
            soukaiInfo.ordinal = int(input_str)
            if is_correct_ordinal(soukaiInfo.ordinal):
                # 結果表示
                print(msg.DELETE_LAST_LINE)
                print(msg.ORDINAL_INPUT_GUIDE(default_ordinal_str) + str(soukaiInfo.ordinal))

                soukaiInfo.ordinal_kanji = get_ordinal_kanji(soukaiInfo.ordinal)
                soukaiInfo.semester = get_semester(soukaiInfo.ordinal)
                soukaiInfo.repo_name = get_repo_name(soukaiInfo.fiscal_year, soukaiInfo.ordinal)
                break
            else:
                print(msg.ERROR_NOT_1_OR_2)
        except:
            print(msg.ERROR_NOT_1_OR_2)

    # テンプレートファイルのパスを指定
    file_loader = FileSystemLoader(config.TEMPLATE_ROOT_PATH)
    env = Environment(loader=file_loader)

    # READMEの生成
    readme_template = env.get_template(config.README_TEMPLATE)
    # 書き込み
    with open(config.README_PATH, mode='w') as readme:
        readme.write(readme_template.render(info=soukaiInfo))

    # document.texの生成
    document_tex_template = env.get_template(config.DOCUMENT_TEX_TEMPLATE)
    #書き込み
    with open(config.DOCUMENT_TEX_PATH, mode='w') as document_tex:
        document_tex.write(document_tex_template.render(info=soukaiInfo))

    # 不要ファイルの削除
    for file_name in config.REMOVE_FILES[soukaiInfo.ordinal]:
        os.remove(file_name)

    # 担当者のyamlテンプレートファイルを生成
    assignee_tamplate = env.get_template(config.ASSIGNEE_TEMPLATE)
    # 書き込み
    with open(config.ASSIGNEE_PATH, mode='w') as assignee:
        assignee.write(assignee_tamplate.render(info=soukaiInfo))

def is_correct_ordinal(ordinal: int) -> bool:
    return ordinal in [1, 2]

def get_fiscal_year(current_year: int, current_month: int) -> int:
    return current_year - (1 if current_month < 4 else 0)

def get_default_ordinal_str(current_month: int) -> str:
    return '1' if current_month in range(4, 10) else '2'

def get_ordinal_kanji(ordinal: int) -> str:
    return '一' if ordinal == 1 else '二'

def get_semester(ordinal: int) -> str:
    return '\zenki' if ordinal == 1 else '\kouki'

def get_repo_name(fiscal_year: int, ordinal: int) -> str:
    return 'soukai-' + str(fiscal_year) + '-' + str(ordinal)