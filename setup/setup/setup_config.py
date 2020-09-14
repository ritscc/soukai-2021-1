# 日付フォーマット
DATE_FORMAT: str = '%Y/%m/%d'

# テンプレートファイル類
TEMPLATE_ROOT_PATH: str = '../template'
README_TEMPLATE: str = 'README.md.jinja'
README_PATH: str = '../README.md'
DOCUMENT_TEX_TEMPLATE: str = 'document.tex.jinja'
DOCUMENT_TEX_PATH: str = '../document.tex'
DOCUMENT_PARTS_TEX_TEMPLATE: str = 'document_parts.tex.jinja'
ASSIGNEE_TEMPLATE: str = 'assignee.yml.jinja'
ASSIGNEE_PATH: str = '../assignee.yml'
SRC_ROOT_PATH: str = '../src'

# 定数系
DEPARTMENTS: list = ['kaikei', 'kensui', 'syogai', 'system', 'soumu']
KAISEI_COMMANDS: list = ['\\firstGrade', '\\secondGrade', '\\thirdGrade', '\\fourthGrade']

# 不要ファイル
REMOVE_FILES: dict = {
    1: ('../src/houshin/4kai.tex', '../src/kouki.tex'),
    2: ('../src/houshin/1kai.tex', '../src/soukatsu/4kai.tex', '../src/zenki.tex')
}

# GitHub API類
GITHUB_BASE_URI: str = 'https://api.github.com/'
GITHUB_BASE_ORGANIZATION: str = 'ritscc'