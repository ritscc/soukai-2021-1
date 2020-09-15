import os.path as path
import re

# createする系のスクリプトが共通して使用するモジュールです
def is_target_path(target_path: str, *input_path) -> bool:
    if len(input_path) == 0:
        return True
    return target_path.startswith(get_root_ignore_path(path.join(*input_path)))

# src以下のファイルパスを取得
def get_root_ignore_path(path: str) -> str:
    return re.sub(r'^(\./)?src/', '', path)
