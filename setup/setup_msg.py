class FontColors:
    GREEN: str = '\033[32m'
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

DELETE_LAST_LINE: str = '\033[1A\033[2K\033[1A'

ERROR_INVAID_FORMAT: str = 'Invaid format. Try again.'
ERROR_NOT_1_OR_2: str = 'Input isn\'t 1 or 2. Try again.'

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