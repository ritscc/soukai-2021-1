class FontColors:
    RED: str = '\033[31m'
    GREEN: str = '\033[32m'
    YELLOW: str = '\033[33m'
    RESET: str = '\033[0m'

HELP_MSG: str = '''\
Usage: python setup.py [argument(s)]
Commands:
I,  init                        Initialize document.tex and README.md and so on
g,  generate [filter]           Generate LaTeX files from YAML template
i,  issue [filter]              Generate Issues on Bitbucket from YAML template

filter format is below
- filepath
- <type>
- <type> <section>

type:
  hajimeni
  soukatsu
  houshin

section:
  zentai
  kaikei
  kensui
  syogai
  system
  soumu

Example:
  python setup.py I
  python setup.py g
  python setup.py i src/soukatsu/syogai
  python setup.py i soukatsu
  python setup.py g houshin kensui'''

def CREATED_FILE_MSG(file_name: str) -> str:
    msg: str = 'Created ' + file_name + ' .'
    return msg

def CREATED_ISSUE_MSG(file_name: str) -> str:
    msg: str = 'Created ' + file_name + ' issue.'
    return msg

def OVERWRITTEN_FILE_MSG(file_name: str) -> str:
    msg: str = 'Overwritten ' + file_name + ' .'
    return msg

DELETE_LAST_LINE: str = '\033[1A\033[2K\033[1A'

ERROR_INVAID_FORMAT: str = FontColors.RED + 'Invaid format. Try again.' + FontColors.RESET
ERROR_INPUT_EMPTY: str = FontColors.RED + 'Input is empty. Try again.' + FontColors.RESET
ERROR_NOT_1_OR_2: str = FontColors.RED + 'Input isn\'t 1 or 2. Try again.' + FontColors.RESET
ERROR_NOT_NUMBER: str = FontColors.RED + 'Input isn\'t number. Try again.' + FontColors.RESET
ERROR_UNSUPPORTED_FILE_PATH: str = FontColors.RED + 'Unsupported file path.' + FontColors.RESET
ERROR_UNEXPECTED_ERROR: str = FontColors.RED + 'Unexpected error.' + FontColors.RESET

def ERROR_FILE_EXIST(file_name: str) -> str:
    error_msg: str = FontColors.RED + \
        file_name + ' is exist.' + \
        FontColors.RESET
    return error_msg

def ERROR_HTTP_REQUEST_FAILED(code: int, reason: str, message: str) -> str:
    error_msg: str = FontColors.RED + \
        '[ ' + str(code) + ' ' + reason + ' ] ' + message +\
        FontColors.RESET
    return error_msg

def WORNING_FILE_CHANGE(file_name: str) -> str:
    worning_msg: str = FontColors.YELLOW + \
        'worning: ' + file_name + ' will be changed.' + \
        FontColors.RESET
    return worning_msg

def WORNING_ISSUE_DUPLICATED(title: str) -> str:
    worning_msg: str = FontColors.YELLOW + \
        'worning: issue[title : ' + title + '] already exist. It\'s skiped.' + \
        FontColors.RESET
    return worning_msg

GITLAB_INFO_INPUT_GUIDE: str = 'Please type these infomations in order to create issues on GitLab:'
REPOSITORY_ID_INPUT_GUIDE: str = 'Project(Repository) ID (number) : '
PRIVATE_TOKEN_INPUT_GUIDE: str = 'PRIVATE-TOKEN (string) : '

def MEETING_DAY_INPUT_GUIDE(default_date_str: str) -> str:
    guide_msg: str = '開催日 ' + \
        FontColors.GREEN + \
        default_date_str + \
        FontColors.RESET + \
        ' : '
    return guide_msg

def ORDINAL_INPUT_GUIDE(default_ordinal_str: str) -> str:
    guide_msg: str = '第何回目? ' + \
        FontColors.GREEN + \
        default_ordinal_str + \
        ' (1 or 2)' + \
        FontColors.RESET + \
        ' : '
    return guide_msg
