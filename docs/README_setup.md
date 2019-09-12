setup.py
===

年度などの初期設定をしたり，テンプレートファイルを生成するツールです．
soukai-templateからforkした直後や，各局のブランチを作るときに使ってください．

Pythonの実行環境は`ver 3.7`です．

Pythonが標準でインストールしていないライブラリがあるので，以下のライブラリをインストールしてください．
  - jinja2
  - pyyaml

インストール方法
```shell
$ pip install jinja2
$ pip install pyyaml
```

## スクリプトを実行するときの注意
rootディレクトリにある`setup`ディレクトリに移動してから実行するようにしてください．

## セットアップ時にすること

1. 全体の初期化
2. `assignee.yml`の編集
3. テンプレートファイルの作成
4. GitLabに課題登録

### 全体の初期化
`document.tex`と`README.md`をその年に合わせて作成します．

```bash
$ python setup.py init
```

実行すると開催年などが入力できる状態になるので，それに応じて正しい値を入力してください．

### `assignee.yml`の編集
`assignee.yml`を編集します．
タイトルや氏名，GitLabIDなどを適切に記述してください．
詳しくは「assignee.ymlについて」を見てください．

### テンプレートファイルの作成
`assignee.yml`の内容を元にテンプレートファイルを作成します．

```
$ python setup.py generate
```

実行した後はコミットしてファイルをリポジトリに追加してください．
詳しい使い方は「各コマンドの使い方」の「generateコマンド」を見てください．

### GitLabに課題登録
`assignee.yml`の内容を元にGitLabに課題を登録します．

```
$ python setup.py issue
```

詳しい使い方は「各コマンドの使い方」の「issueコマンド」を見てください．


## assignee.ymlについて
章の担当者を管理するファイルです．
テンプレートファイルの生成やGitLabへの課題追加時に利用されます．
フォーマットは以下のようになっています．

`filename:タイトル,姓 名,GitLabID`

フォーマットの注意点
- カンマの後ろにはスペースを入れないようにしてください．
- 姓と名の間は**半角スペース**を入れてください．
- GitLabIDは半角数字から構成されています．GitLabユーザの「設定」画面の「User ID」に記載されています．

YAMLファイルは以下のようなフォーマットで記述します．
YAMLのハッシュのキーはディレクトリ構造と一致するように記述してください．
`filename`の先頭に数字を入れることで，pdfにした時の順番を制御することができます．数字が一桁のときは先頭に0をつけてください．

```yaml
soukatsu:
  zentai:
    01_zentai: 後期活動総括,RCC 会長,114514
    02_unei: 運営総括,RCC 副会長,1919810
```

例えば，全体総括の中に学園祭総括を追加したい場合は以下のように編集します．

```yaml
soukatsu:
  zentai:
    01_zentai: 後期活動総括,RCC 会長,114514
    02_unei: 運営総括,RCC 副会長,1919810
    03_gakuensai: 学園祭総括,RCC 学祭担当者,8101000
```

## 各コマンドの使い方

### initコマンド
`document.tex`と`README.md`をその年に合わせて作成します．
実行すると開催年などが入力できる状態になるので，それに応じて正しい値を入力してください．

例:

```bash
$ python setup.py init
$ python setup.py I
```

### generateコマンド
`assignee.yml`を読み込んで，subsection以降を書くためのテンプレートファイルを生成します．
`assignee.yml`に正しいフォーマットで担当者の情報を記入する必要があります．

フィルターを指定して生成するファイルを制御することができます．
フィルターを利用することで局のファイルだけ生成するということが可能になります．
フィルターは以下のいずれかで指定できます．

- `filepath`
- `<type>`
- `<type> <section>`

おそらくファイルパスでディレクトリを指定するのが一番簡単でしょう．
`type`と`section`はそれぞれ以下のパラメータから選ぶことができます．

```
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
```

例:

```bash
$ python setup.py generate
$ python setup.py g src/soukatsu/soumu
$ python setup.py g houshin
```

### issueコマンド
`assignee.yml`を読み込んで，GitLabに課題を登録します．
generateコマンドと同様にフィルターを指定できます．

例:

```bash
$ python setup.py issue
$ python setup.py i src/soukatsu/soumu
$ python setup.py i houshin
```

## 局別ブランチを作る例
ここではシステム管理局を例として局別ブランチを作る方法を説明します．

まずdevelopブランチから局別ブランチを切ります．
局別ブランチは総括と方針で分けておいたほうが管理しやすいです．

```bash
$ git checkout develop
$ git checkout -b system_soukatsu
```

ブランチを作り終えたら`assignee.yml`を編集します．
システム管理局総括の章を増やします．
以下はその一部抜粋です．

```yaml
soukatsu:
  syogai:
#    1_zentai: 全体総括,
  system:
    1_zentai: 全体総括, シス管 局長, kyokucho
    2_torikumi: 会内の技術を高める取り組み, シス管 局員その1, kyokuin1
    3_service: サービスの運用, シス管 局員その2, kyokuin2
  soumu:
#    1_zentai: 全体総括,
```

編集が終わったらテンプレートファイルを生成しましょう．
以下のコマンドを打って生成します．
また，GitLabの課題にも追加しましょう

```bash
$ python setup.py g src/soukatsu/system
$ python setup.py i src/soukatsu/system
```

テンプレートの生成は完了したので，ブランチをpushします．

```bash
$ git push -u origin system_soukatsu
```

以上が局別ブランチの作り方でした．
局別ブランチを作って，面倒な手動マージ作業を減らしましょう！
