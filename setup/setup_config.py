# 日付フォーマット
DATE_FORMAT: str = '%Y/%m/%d'

# テンプレートファイル類
TEMPLATE_ROOT_PATH: str = '../template'
README_TEMPLATE: str = 'README.md.jinja'
README_PATH: str = '../README.md'
DOCUMENT_TEX_TEMPLATE: str = 'document.tex.jinja'
DOCUMENT_TEX_PATH: str = '../document.tex'
ASSIGNEE_TEMPLATE: str = 'assignee.yml.jinja'
ASSIGNEE_PATH: str = '../assignee.yml'

# 不要ファイル
REMOVE_FILES: dict = {
    1: ('../src/houshin/4kai.tex', '../src/kouki.tex'),
    2: ('../src/houshin/1kai.tex', '../src/soukatsu/4kai.tex', '../src/zenki.tex')
}

# Gitlab API類
BASE_URI: str = 'https://gitlab.com/api/v4'
POST_ISSUE_URI: str = ''