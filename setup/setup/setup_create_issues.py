import urllib.error as http_error
import urllib.request as request
import urllib.parse as url_parse
import json

from setup import assignees
from setup.assignees import ArticleInfo
from setup.assignees import Assignee
from setup import create_util as util
from setup import setup_config as config
from setup import setup_msg as msg

#yamlの情報からissueを作成
def create_issues(*args) -> None:
    print(msg.GITLAB_INFO_INPUT_GUIDE)

    # ProjectのIDを取得
    while True:
        try:
            project_id: int = int(input(msg.REPOSITORY_ID_INPUT_GUIDE))

            # 結果表示
            print(msg.DELETE_LAST_LINE)
            print(msg.REPOSITORY_ID_INPUT_GUIDE + str(project_id))

            break
        except:
            print(msg.ERROR_NOT_NUMBER)

    # PRIVATE-TOKENを取得
    while True:
        private_token: str = input(msg.PRIVATE_TOKEN_INPUT_GUIDE)

        if private_token != '':
            # 結果表示
            print(msg.DELETE_LAST_LINE)
            print(msg.PRIVATE_TOKEN_INPUT_GUIDE + private_token)

            break

        print(msg.ERROR_INPUT_EMPTY)

    # 既に作られたissueを取得
    created_issues: list = get_already_created_issues(project_id, private_token)
    created_issue_titles: list = get_created_issue_titles(created_issues)

    # 入力されたpathを元にissueを発行していく
    for path, assignee_info in assignees.assignees().items():
        if util.is_target_path(path, *args):
            create_issue(path, assignee_info, project_id, private_token, created_issue_titles)

def create_issue(filepath: str, info: ArticleInfo, project_id: int, private_token: str,\
      created_issue_titles: list) -> None:
    assignee: Assignee = info.get_assignee()

    if assignee.get_gitlab_id() is None:
        print(msg.ERROR_MISSING_GITLAB_ID(filepath))
        return

    # 情報をセットする
    title: str = filepath + ':' + info.get_title()
    description: str = '担当者は、' + assignee.get_family() + ' ' + assignee.get_name() + 'さんです。\n' +\
        'src/' + filepath + 'を編集してください。'
    assignee_id: str = assignee.get_gitlab_id()

    # 既にissueが作られていたらworningを出して終了
    if is_issue_already_created(title, created_issue_titles):
        print(msg.WORNING_ISSUE_DUPLICATED(title))
        return

    result_title: str = post_issue(project_id, private_token, title, description, assignee_id)
    print(msg.CREATED_ISSUE_MSG(result_title))

# 既に作られたissueを取得します
def get_already_created_issues(project_id: int, private_token: str) -> list:
    # refs https://docs.gitlab.com/ee/api/issues.html#list-project-issues
    get_issues_uri: str = config.GITLAB_BASE_URI + '/projects/' + str(project_id) + '/issues'

    headers: dict = {
        'PRIVATE-TOKEN': private_token
    }

    req = request.Request(get_issues_uri, headers=headers, method='GET')

    try:
        with request.urlopen(req) as res:
            issues: list = json.load(res)
            return issues

    except http_error.HTTPError as err :
        err_body: dict = json.load(err)
        print(msg.ERROR_HTTP_REQUEST_FAILED(err.code, err.reason, err_body['message']))
        exit()

    except http_error.URLError as err:
        print(msg.ERROR_UNEXPECTED_ERROR)
        exit()

# gitlabにissueを新規作成します
def post_issue(project_id: int, private_token: str, title: str, description: str, assignee_id: str) -> str:
    # refs https://docs.gitlab.com/ee/api/issues.html#new-issue
    post_issue_uri: str = config.GITLAB_BASE_URI + '/projects/' + str(project_id) + '/issues'

    query: dict = {
        'title': title,
        'description': description,
        'assignee_ids': assignee_id
    }

    headers: dict = {
        'PRIVATE-TOKEN': private_token
    }

    req = request.Request(get_uri_with_query(post_issue_uri, query), headers=headers, method='POST')
    try:
        with request.urlopen(req) as res:
            issue: dict = json.load(res)
            return issue['title']

    except http_error.HTTPError as err :
        err_body: dict = json.load(err)
        print(msg.ERROR_HTTP_REQUEST_FAILED(err.code, err.reason, err_body['message']))
        exit()

    except http_error.URLError as err:
        print(msg.ERROR_UNEXPECTED_ERROR)
        exit()

# 取得されたissueからtitleだけを取り出します
def get_created_issue_titles(issues: list) -> list:
    issue_titles: list = []

    for issue in issues:
        issue_titles.append(issue['title'])

    return issue_titles

def get_uri_with_query(uri: str, query: dict) -> str:
    return '{}?{}'.format(uri, url_parse.urlencode(query))

def is_issue_already_created(title: str, titles: list) -> bool:
    return title in titles