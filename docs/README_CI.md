継続的インテグレーション(CI)の手引き
=====================

概要
---------------------
RCCでは，総会文書のビルドをCIツールを用いて自動化しています．
ビルド自動化のメリットは，ビルドの手間を減らすことができるということに尽きるでしょう．

現在の設定では，ブランチへのファイル変更があった場合、すぐに文章校正とビルドテストを行っています．
ビルドに関しては，Dockerコンテナのイメージであるalpine上にLatex環境を組み込んだ環境で行い，
文章校正は，文章校正ツールである[unagi](https://gitlab.com/ritscc/soukai/unagi)を利用しています．

この文書では，GitLab CIを用いたCIの設定方法について解説します．

GitLab CIを用いたCI
---------------------
### GitLab CIとは
GitLabに備わっている継続的インテグレーションサービスです．
ビルド手順やデプロイ手順を書いた設定ファイル(.gitlab-ci.yml)を用意するだけで利用することができます．
過去に使用されていた，WerckerやCircleCIなどのCIサービスは連携設定が必要でしたが，
GitLab CIではその設定が不要なため，気軽に利用できます．

### 作業手順
ビルドの設定に必要な手順を最初から順に示します．
現在，総会文章リポジトリでは，文章校正ツールである[unagi](https://gitlab.com/ritscc/soukai/unagi)以外で特殊な設定を行う必要はありません．

0. .gitlab-ci.yml.sampleを.gitlab-ci.ymlに名前を変更します．
[総会文章テンプレート](https://gitlab.com/ritscc/soukai/soukai-template/-/blob/master/README.md)の手順でリポジトリを初期化した場合はすでに完了していると思われます．
1. GitLabのシス管アカウント(ritscc)でログインし，`ユーザー設定 - アクセストークン`から
- api
- r/w repository
の権限を付与したトークンを発行してください．

2. プロジェクトの設定にある`CI/CD - Variables`から

```
Key : GITLAB_UNAGI_TOKEN
Value : 発行したトークン
```

と

```
Key : AUTHOR_ID
Value : ritsccアカウントのアカウントID
```

を設定してください。

3. Complete!

なお，最新のSetup方法に関しては，必ず文章校正ツールであるunagiの(README)[https://gitlab.com/ritscc/soukai/unagi/-/blob/master/README.md]を確認し，
その手順に進めることをおすすめします．

執筆作業中のunagi更新について
---------------------
GitLab Pipelinesは，ブランチに存在する`.gitlab-ci.yml`を参照しながら実行されます．
そのため，一度執筆作業が開始された後には原則更新をかけることができないので注意してください．

しかしながら，世の中そんなに甘くなく途中で更新したい時があると思いますので，手順を記しておきます．

### 作業手順
1. developブランチから新規にブランチを切る
2. `.gitmodules`を以下の内容に書き換える

```
[submodule "constitution"]
	path = constitution
	url = git@gitlab.com:ritscc/soukai/constitution.git
[submodule "tex-commands"]
	path = tex-commands
	url = git@gitlab.com:ritscc/soukai/tex-commands.git
[submodule "unagi"]
	path = unagi
	url = git@gitlab.com:ritscc/soukai/unagi.git
```

3. 以下のコマンドを実行する

```
git submodule init
git submodule update --remote
```

4. `.gitmodules`を以下の内容に書き換える

```
[submodule "constitution"]
	path = constitution
	url = ../../constitution.git
	# url = git@gitlab.com:ritscc/soukai/constitution.git
	branch = master
[submodule "tex-commands"]
	path = tex-commands
	url = ../../tex-commands.git
	# url = git@gitlab.com:ritscc/soukai/tex-commands.git
	branch = master
[submodule "unagi"]
	path = unagi
	url = ../../unagi.git
	# url = git@gitlab.com:ritscc/soukai/unagi.git
	branch = master
```

5. commit後pushする．
6. マージリクエストを立て，正しく更新されているか確認する．
7. developブランチにマージする．
8. 【会員に対し】新規にブランチを切る前に`git pull`を行うように指示する．


カスタマイズ
---------------------

カスタマイズを行ってくれる人を募集しています．総会文書の執筆をよりよくするようなソリューションを待っています．

本リポジトリの.gitlab-ci.ymlには，Dockerコンテナ内で行なわれるビルドとデプロイの手順が記述されています．
このファイルを変更することで，ビルドの動作やデプロイの方法を変更することが可能です．

GitLab CIの仕様については，[GitLab CI/CD](https://docs.gitlab.com/ee/ci/)を参照してください．

