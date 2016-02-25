setup.rb
===

年度などの初期設定をしたり，テンプレートファイルを生成するツールです．
soukai-templateからforkした直後や，各局のブランチを作るときに使ってください．

Macではreadlineをインストールする必要があるかもしれません.
[参考リンク](http://qiita.com/kidachi_/items/d0137d96bed9ac381fd5)

## 各コマンドの使い方

### initコマンド
`document.tex`と`README.md`をその年に合わせて作成します．
実行すると開催年などが入力できる状態になるので，それに応じて正しい値を入力してください．

例:

```shell
$ ruby setup.rb init
```

WerckerのShare Badgeが最後に聞かれます．
Werckerで継続的インテグレーションの設定を行っている場合に利用できます．
WerckerのShare Badge (Markdown表記) は，
Werckerのアプリケーション別の設定ページから，
左メニューの「Sharing」をクリックすると見つけることができます．
Werckerをまだ使っていない場合は空欄にしておいてください．
後からでも変更ができます．

### generateコマンド
subsection以降を書くためのテンプレートファイルを生成します．
それと同時に`\input`コマンドもファイルに追記します．
実行する際に，総括と方針のどちらなのか，扱う局はどこなのか，
作成するsubsectionのファイル名を指定する必要があります．
実行時にはsubsectionで用いる小節名や，担当者の名前を入力してください．

例:

```shell
$ ruby setup.rb generate soukatsu zentai welcome group hackathon
$ ruby setup.rb generate houshin syogai kc3 webpage
```
