総会議案書テンプレート
========================
これは，総会議案書のテンプレートリポジトリです．
コマンドを使って簡単に総会議案書リポジトリを生成することができます．

セットアップ手順
--------------------
セットアップですべきことは，次の2つです．

1. リポジトリのセットアップ
2. テンプレートファイルとGitLabの課題の生成
3. CIのセットアップ

1つ目はリポジトリのセットアップです．以下の通りにセットアップしてください．
1. `$ git clone git@gitlab.com:ritscc/soukai/soukai-template.git`
でこのテンプレートをcloneしてください．（ここでフォークではないことに注意してください．）
2. 自身のターミナルで `soukai-template` フォルダがあるディレクトリに移動してください．
3. `$ cp -r soukai-template soukai-{年度}-{回数}` を実行してください． (e.g.) `cp -r soukai-template soukai-2019-2`
4. コピーした先のディレクトリに移動してください．
5. `$ git remote` を実行して `origin` が表示されていることを確認してください．
6. `$ git remote rm origin` を実行してください．
7. `$ git remote` を実行して何も表示されないことを確認してください．
8. [GitLab](https://gitlab.com/ritscc/soukai) にアクセスして新しいリポジトリを作成してください．
名前は `soukai-{年度}-{回数}` としましょう．
9. `$ git remote add origin git@gitlab.com:ritscc/soukai/{年度}/soukai-{年度}-{回数}.git` を実行します．
(e.g.) `git remote add origin git@gitlab.com:ritscc/soukai/2019/soukai-2019-1.git`
10. `$ git remote` を実行して `origin` が表示されていることを確認してください．
11. `$ git push -u origin master` を実行してください．
12. GitLab上でリポジトリが更新されたことを確認します．
13. `$ mv .gitlab-ci.yml.sample .gitlab-ci.yml` を実行します．
14. `$ git add -A` `$ git commit -m 'setup gitlab-ci.yml'` `$ git push` を順に実行します．

セットアップ作業の2つ目は，
担当者が編集するファイルの間違いを少なくし，
すべての担当部分を課題として管理できるようにするために必要です．
これらの作業は，Pythonスクリプトと設定ファイルを用いることで，簡単に設定することができます．
作業方法は，このあとの「setup.pyについて」や[README\_setup.md](docs/README_setup.md)をご覧ください．

3つ目のCIとは，継続的インテグレーションのことです．
設定を行うと，次のことがコミットのタイミングなどで自動的に行われるようになります．

* 誤字や表記ゆれの指摘をGitLabのissueにコメント

人手でやることを減らせるので，設定することを推奨します．
リポジトリを作成したら一番に設定しましょう．
作業方法は，[README\_CI.md](docs/README_CI.md)をご覧ください．

setup.pyについて
---------------------
年度などの初期設定をしたり，テンプレートファイルを生成するツールです．
soukai-templateからコピーした直後や，各局のブランチを作るときに使ってください．

Pythonの動作環境は以下の通りです．
- Python ver3.7
- 必須ライブラリ
    - jinja2
    - pyyaml

必須ライブラリは
```shell
$ pip install jinja2
$ pip install pyyaml
```
でインストールしてください

soukai-templateからコピーした後の作業の大まかな流れは以下のようになります．
1. 以下のコマンドを実行して，年度などの情報を設定する．
    ```shell
    $ cd setup
    $ python setup.py init
    ```
1. 生成されたassignee.ymlを書き換える．
1. 以下のコマンドを実行して，予めsubsection以降の文書を書くためのテンプレートファイルを生成する．
    ```shell
    $ python setup.py g
    ```
1. 以下のコマンドを実行して，GitLabのリポジトリにissueを発行する．
    ```shell
    $ python setup.py i
    ```

必ずこのツールを使って，予めsubsection以降の文書を書くためのファイルを生成して，
それを編集するように呼びかけてください．
これはコンフリクトを避けるためです．
タスクを作成する時に編集するべきファイルパスを明示しておくと混乱が減ると思われます．

詳しくは，[README\_setup.md](docs/README_setup.md)を見てください．

CIについて
-----------------------
継続的インテグレーションを支援するサービスとしてGitLab CIが利用できます．
これらを用いて，総会文書のビルドを自動化しています．
CIのセットアップ方法については，[README\_CI.md](docs/README_CI.md)に詳しく紹介しています．
