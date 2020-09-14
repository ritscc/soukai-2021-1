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
    print(msg.GITHUB_INFO_INPUT_GUIDE)

    # Organization Nameを取得
    while True:
        try:
            organization_name: str = str(input(msg.ORGANIZATION_NAME_INPUT_GUIDE))

            # 結果表示
            print(msg.DELETE_LAST_LINE)
            print(msg.ORGANIZATION_NAME_INPUT_GUIDE + str(organization_name))
            
            # 未入力時デフォルト設定
            if organization_name == '':
                organization_name: str = config.GITHUB_BASE_ORGANIZATION
            
            break
        except:
            print(msg.ERROR_NOT_NUMBER)

    print(organization_name)

    # ProjectのIDを取得
    while True:
        try:
            project_id: str = str(input(msg.REPOSITORY_ID_INPUT_GUIDE))

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
    created_issues: list = get_already_created_issues(organization_name, project_id, private_token)
    created_issue_titles: list = get_created_issue_titles(created_issues)

    # 入力されたpathを元にissueを発行していく
    for path, assignee_info in assignees.assignees().items():
        if util.is_target_path(path, *args):
            create_issue(path, assignee_info, organization_name, project_id, private_token, created_issue_titles)

def create_issue(filepath: str, info: ArticleInfo, organization_name: str, project_id: str, private_token: str,\
      created_issue_titles: list) -> None:
    assignee: Assignee = info.get_assignee()

    if assignee.get_github_id() is None:
        print(msg.ERROR_MISSING_GITHUB_ID(filepath))
        return

    # 情報をセットする
    title: str = filepath + ':' + info.get_title()
    description: str = '担当者は、' + assignee.get_family() + ' ' + assignee.get_name() + 'さんです。\n' +\
        'src/' + filepath + 'を編集してください。'
    assignee_id: str = assignee.get_github_id()

    # 既にissueが作られていたらworningを出して終了
    if is_issue_already_created(title, created_issue_titles):
        print(msg.WORNING_ISSUE_DUPLICATED(title))
        return

    result_title: str = post_issue(organization_name,project_id, private_token, title, description, assignee_id)
    print(msg.CREATED_ISSUE_MSG(result_title))

# 既に作られたissueを取得します
def get_already_created_issues(organization_name: str, project_id: str, private_token: str) -> list:
    # refs https://developer.github.com/v3/issues/#list-repository-issues
    get_issues_uri: str = config.GITHUB_BASE_URI + '/repos/' + str(organization_name) + '/' + str(project_id) + '/issues'

    headers: dict = {
        'Authorization': 'token ' + private_token
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

# GitHubにissueを新規作成します
def post_issue(organization_name: str, project_id: str, private_token: str, title: str, description: str, assignee_id: str) -> str:
    # refs https://developer.github.com/v3/issues/#create-an-issue
    post_issue_uri: str = config.GITHUB_BASE_URI + '/repos/' + str(organization_name) + '/' + str(project_id) + '/issues'

    query: dict = {
        'title': title,
        'body': description,
        'assignees': assignee_id
    }

    headers: dict = {
        'Authorization': 'token ' + private_token
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