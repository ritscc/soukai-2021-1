継続的インテグレーション(CI)の手引き
=====================

概要
---------------------
RCCでは，総会文書のビルドをCIツールを用いて自動化しています．
ビルド自動化のメリットは，ビルドの手間を減らすことができるということに尽きるでしょう．
総会文書のレビューをするために，プルリクエストが更新されるたびに時間のかかる面倒なビルドする必要がなくなり，
文書の相互レビューがしやすくなることが期待できます．また，執筆者は必ずしも自分の環境でビルドする必要がなくなります．

この文書では，CIの設定方法について解説します．

Werckerを用いたCI
---------------------
本章では，Werckerを用いたCIの設定方法を説明します．

### Werckerとは
[Wercker](http://wercker.com/) (ワーカー) は，継続的インテグレーションを支援するサービスです．
Werckerはリポジトリ単位で，ビルドやデプロイを行ってくれるというものです．
恐らく，有名なCircleCIと類似したサービスだと思ってもらって構わないでしょう．

Werckerの特徴は，非常に柔軟性が高いことです．
プロジェクトに合わせて好きなDockerコンテナを選ぶことができ，その上でビルドやデプロイをすることができます．
ビルド手順やデプロイ手順も，設定ファイルを通してを柔軟に指定することができます．

### 動作の仕組み
1. ユーザがコミットをBitbucketのリモートリポジトリにプッシュする
2. プッシュされると，BitbucketのサービスはWerckerに通知を行う(サービス連携機能)
3. Werckerは，Bitbucketからリポジトリをクローンして，wercker.ymlにしたがってビルドとデプロイを行う．

### 作業手順
ビルドの設定に必要な手順を最初から順に示します．
1〜4の作業が終わると，自動ビルドが行えるようになっていると思われます．
`setup.rb`を使ったセットアップ作業をしながら，ビルドが行えるかどうか確認してみてください．

#### 1. 前準備
1. Bitbucketのアカウントはお持ちでしょうか？ まだなら，システム管理局に作ってもらうように頼みましょう．
2. BitbucketのRCCチームには参加できていますか？ まだなら，システム管理局に招待するように頼みましょう．
3. Bitbucketの総会リポジトリは，作成済みですか？ まだであれば，soukai-templateをフォークして新たな総会リポジトリを作りましょう．総会リポジトリの名前は，例年のフォーマットに従うと良いでしょう．
4. Bitbucketのチームの管理権限は設定されていますか？ まだであれば，システム管理局に設定してもらうように頼むか，システム管理局に当該作業を代行してもらいましょう．
5. WerckerのRCCのOrganizationに参加します．前担当者や執行委員長に招待するように頼みましょう．
6. Slackの[Botユーザ](https://ritscc.slack.com/apps/manage/custom-integrations)のアクセストークンを確認します．アクセストークンをいつでもコピーできるようにしておいてください．

#### 2. Werckerでのアプリケーション追加
まずは，Werckerにリポジトリを登録するところから始めます．
[Werckerのアプリケーション作成ページ](https://app.wercker.com/#applications/create)にアクセスして，次の通り作業を行ってください．

1. "Choose a Git provider"で，Bitbucketを選択して，次のステップに移ります．
2. "Select a repository"では，ビルドを行いたい総会リポジトリを選択し，"Use selected Repo"をクリックします．ここでは，"soukai-2015-1"を選択したとします．
3. "Select Owner"では，"rcc"を選択し，"Use selected owner"をクリックします．この項目が表示されない場合，1.3がうまく行えていません．
4. "Configure access"では，1番目の"Add the deploy key to the selected repository for me"を選択し，"Next step"をクリックします．  
	（Bitbucketのリポジトリ設定でSSHデプロイキーとサービス連携が自動的に設定されます）
5. "Setup your wercker.yml"では，リポジトリのwercker.ymlを正常に読み込めるかがチェックされます．エラーが表示されなければ，"Next step"をクリックします．
6. "Awesome! You are all done!"では，"Make my app public"にチェックを入れないでそのまま何もせずに"Finish"をクリックしてください．

#### 3. WerckerとBitbucketでのビルドの詳細設定
ここでは，WerckerのDockerコンテナ内からBitbucketのプライベートリポジトリを読み込むために，
WerckerでSSHキーを生成して，それをBitbucketに登録する手順を説明します．

1. Werckerに追加した総会リポジトリのアプリケーションページで，右上の設定アイコンをクリックして，管理ページを開きます．
2. 左メニューの"SSH Keys"をクリックして開きます．
3. "Generate new keypair"をクリックしてSSHキーを生成します．Nameの入力欄には，`for_sub_module`と入力します．
4. "Generate"ボタンをクリックして，SSHキーを生成します．
5. "Public key"の表記の下に，SSHパブリックキーが表示されます．これをコピーしておいてください．
6. [BitbucketのSSHキー設定ページ](https://bitbucket.org/account/user/ritscc/ssh-keys/)を開きます． 
	この作業には，Bitbucketのシステム管理権限が必要です．権限がない場合は，システム管理局に作業代行頼むか，1.4の項目を実施してください．
7. "鍵を追加"ボタンを押すと，SSHキーの追加ウィンドウが表示されます．
8. "Label"に`RCC Wercker for soukai-XXXX-X`(XXXXの部分は読み替えてください)と入力し，"Key"入力欄に先ほどコピーしておいたパブリックキーをペーストします．入力が終わったら，鍵を追加ボタンを押します．
9. Werckerの管理ページに戻り，左メニューの"Environment variables"をクリックします．
10. "Add new variable"ボタンをクリックします．
11. "name"入力欄に`KEY_FOR_SUBMODULE`と入力し，2つの選択ボタンの2番目の"SSH key pair"を選択．"Select a key pair"では，先ほど追加した`for_sub_module`を選択します．
12. "Save"ボタンをクリックして，設定を反映させます．

#### 4. デプロイ設定
デプロイとは，英語で「展開」「配置」を意味し，CIでいうとビルドしたソフトウェアを利用可能な状態に自動構成することをいいます．
しかし，総会文書はソフトウェアではなく文書なので，また違った「デプロイ」を行います．
総会文書のデプロイ設定では，Slackの #soukai チャンネルに自動的に生成したPDFをアップロードしてくれるようにしています．
ここでは，デプロイ設定の手順を説明します．

1. Werckerの管理ページを開きます．(3.1参照)
2. 左メニューの"Targets"をクリックして開きます．
3. "Add deploy target"ボタンをクリックし，プルダウンメニューの中から"custom deploy"を選択します．
4. "Deploy target name"の入力欄に`Slack Upload`に設定，"Auto Deploy"のチェックボックスにチェックを入れ，"auto deploy successful builds to branch(es):"の入力欄に`*`と入力します．`*`は全てのブランチを意味します．ここで`*`ではなく，他のブランチ名をスペース区切りで入力すると，そのブランチのみに対して，デプロイが実行されるようになります．
5. "Deploy pipeline"の項の"Add new variable"ボタンをクリックします．
6. "name"に`SLACK_TOKEN`と入力し，2つの選択ボタンのうち"text"の方を選択します．"value"の入力欄には，1.6で確認したSlackのアクセストークンを入力します．トークンがわからないように，`Protected`のチェックボックスにチェックを入れておきます．
7. 入力が完了したら，"OK"ボタンを押して，設定を反映します．
8. すべて終わったら，"Save"を押してTargetを保存します．

### カスタマイズ
本リポジトリのwercker.ymlには，Werckerサービス上で動いているDockerコンテナ内で行なわれるビルドとデプロイの手順が記述されています．
このファイルを変更することで，ビルドの動作やデプロイの方法を変更することが可能です．
設定方法については，[Werckerによる説明ページ](http://devcenter.wercker.com/learn/wercker-yml/introduction.html)を参照してください．
動作確認を行うには，[Wercker CLI](http://devcenter.wercker.com/learn/basics/the-wercker-cli.html)が便利です．
