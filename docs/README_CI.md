継続的インテグレーション(CI)の手引き
=====================

概要
---------------------
RCCでは，総会文書のビルドをCIツールを用いて自動化しています．
ビルド自動化のメリットは，ビルドの手間を減らすことができるということに尽きるでしょう．

現在の設定では，developブランチへの変更をすぐにビルドしてデプロイも行うようになっています．
デプロイとは，英語で「展開」「配置」を意味し，CIでいうとビルドしたソフトウェアを利用可能な状態に自動構成することをいいます．
しかし，総会文書はソフトウェアではなく文書なので，ソフトウェアとは違った「デプロイ」を行います．
総会文書のデプロイ設定では，Slackの #soukai チャンネルに自動的に生成したPDFをアップロードしてくれるようにしています．
こうして，最新の総会文書をいつでも入手できます．

この文書では，Bitbucket Pipelinesを用いたCIの設定方法とWerckerを用いたCIの設定方法について解説します．
特に理由がない限り，Bitbucket Pipelinesを用いるほうがいいでしょう．

前準備
---------------------
1. Bitbucketのアカウントはお持ちでしょうか？ まだなら，システム管理局に作ってもらうように頼みましょう．
2. BitbucketのRCCチームには参加できていますか？ まだなら，システム管理局に招待するように頼みましょう．
3. Bitbucketの総会リポジトリは，作成済みですか？ まだであれば，soukai-templateをフォークして新たな総会リポジトリを作りましょう．
総会リポジトリの名前は，例年のフォーマット (soukai-XXXX-X) に従うと良いでしょう．
4. Bitbucketの管理権限を持っていますか？ まだであれば，システム管理局に設定してもらうように頼むか，システム管理局に当該作業を代行してもらいましょう．
5. Slackの[Botユーザ](https://ritscc.slack.com/apps/manage/custom-integrations)のアクセストークンを確認します．
Slackへの通知には，`wercker`を使用しています(以前の名残です)．
アクセストークンがわからない場合は，新しくBotを作成する必要があります．
古いものは削除しておくと良いでしょう（要管理者権限？）．
アクセストークンをいつでもコピーできるようにしておいてください．
6. OAuth連携アプリケーションの登録は完了していますか？まだであれば"OAuth連携アプリケーションの登録"を読んで登録してください．
6. Werckerを利用する場合，WerckerのRCCのOrganizationに参加します．前担当者や執行委員長に招待するように頼みましょう．


### OAuth連携アプリケーションの登録
OAuth連携アプリケーションを作成して，CIの利用時にそのキーを使用します．
サブモジュールのcloneやプルリクエストへのコメントを行うために利用されます．

1. [Bitbucketのritscc\_deployユーザのOAuth設定ページ](https://bitbucket.org/account/user/ritscc_deploy/api)を開きます．
2. "OAuthコンシューマー"の欄を確認して，一つもキーがなければ"コンシューマーキーを追加"ボタンをクリックします．
3. "Name"には`pullreq comment`と入力し，"Callback URL"には`urn:ietf:wg:oauth:2.0:oob`と入力します．
4. "This is a private consumer"にチェックが入っていることを確認し，アカウントのRead権限とプルリクエストのWrite権限を有効にして保存します．
5. "OAuthコンシューマー"の欄に作成したものがあることを確認して，キーやSecretキーが見れることを確認します．


Bitbucket Pipelinesを用いたCI
---------------------
本章ではBitbucket Pipelinesを用いたCIの設定方法を説明します．

### Bitbucket Pipelinesとは
Bitbucketに備わっている継続的インテグレーションサービスです．
ビルド手順やデプロイ手順を書いた設定ファイル(bitbucket-pipelines.yml)を用意するだけで利用することができます．
後述するWerckerやCircleCIなどのCIサービスはBitbucketと連携設定が必要でしたが，
Bitbucketに追加されたBitbucket Pipelinesではその設定が不要なため，気軽に利用できます．

### 作業手順
ビルドの設定に必要な手順を最初から順に示します．
ここでは，Bitbucket PipelinesのDockerコンテナ内からBitbucketのプライベートリポジトリを読み込むために，
BitbucketのOAuth連携アプリケーションのキーをBitbucket Pipelinesに登録する手順を説明します．
また，この設定を行うことで自動コメント機能も有効になります．
ついでにSlackのトークンの設定も行っています．

1. bitbucket-pipelines.yml.sampleをbitbucket-pipelines.ymlに名前を変更します．
setup.rbのinitコマンドを使ってリポジトリを初期化した場合はすでに完了していると思われます．
2. 総会リポジトリの設定ページの"Environment variables"を開きます．
3. "Type variable"の欄に`CLIENT_ID`，"Type value"にOAuth連携アプリケーションのコンシューマーキーを入力してAddボタンを押します．
4. 更に"Type variable"に`CLIENT_SECRET`，"Type value"にコンシューマーキーのSecretを入力してAddボタンを押します．
この時`Secured`のチェックボックスにチェックを入れておきます．
5. 最後にもう一つ，"Type variable"に`SLACK_TOKEN`と入力し，"Type value"の入力欄には，1.5で確認したSlackのアクセストークンを入力します．

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

### ビルドとデプロイの動作の流れ
1. ユーザがコミットをBitbucketのリモートリポジトリにプッシュする
2. プッシュされると，BitbucketのサービスはWerckerに通知を行う(サービス連携機能)
3. Werckerは，Bitbucketからリポジトリをクローンして，wercker.ymlにしたがってビルドとデプロイを行う．

### 作業手順
ビルドの設定に必要な手順を最初から順に示します．
1〜3の作業が終わると，自動ビルドが行えるようになっていると思われます．
`setup.rb`を使ったセットアップ作業をしながら，ビルドが行えるかどうか確認してみてください．

#### 1. Werckerでのアプリケーション追加
まずは，Werckerにリポジトリを登録するところから始めます．
[Werckerのアプリケーション作成ページ](https://app.wercker.com/#applications/create)にアクセスして，次の通り作業を行ってください．

1. "Choose a Git provider"で，Bitbucketを選択して，次のステップに移ります．
2. "Select a repository"では，ビルドを行いたい総会リポジトリを選択し，"Use selected Repo"をクリックします．ここでは，"soukai-2015-1"を選択したとします．
3. "Select Owner"では，"rcc"を選択し，"Use selected owner"をクリックします．この項目が表示されない場合，1.3がうまく行えていません．
4. "Configure access"では，1番目の"Add the deploy key to the selected repository for me"を選択し，"Next step"をクリックします．  
	（Bitbucketのリポジトリ設定でSSHデプロイキーとサービス連携が自動的に設定されます）
5. "Setup your wercker.yml"では，リポジトリのwercker.ymlを正常に読み込めるかがチェックされます．エラーが表示されなければ，"Next step"をクリックします．
6. "Awesome! You are all done!"では，"Make my app public"にチェックを入れないでそのまま何もせずに"Finish"をクリックしてください．

#### 2. WerckerとBitbucketでのビルドの詳細設定
ここでは，WerckerのDockerコンテナ内からBitbucketのプライベートリポジトリを読み込むために，
BitbucketのOAuth連携アプリケーションの登録を行い、それをWerckerに登録する手順を説明します．
また，この設定を行うことで自動コメント機能も有効になります．

1. Werckerに追加した総会リポジトリのアプリケーションページで，上にあるタブの"Environment"をクリックして，環境変数設定ページを開きます．
2. "Environment variables"の項の空の入力欄に移動し，
"Variable name"に`CLIENT_ID`，"Value"にOAuth連携アプリケーションのコンシューマーキーを入力してAddボタンを押します．
3. 更に"Variable name"に`CLIENT_SECRET`，"Value"にコンシューマーキーのSecretを入力してAddボタンを押します．
この時`Protected`のチェックボックスにチェックを入れておきます．
4. Werckerに追加した総会リポジトリのアプリケーションページで，"Workflow"をクリックしてワークフロー設定ページを開きます．
5. 一番下にある"Pipelines"に移動して，"build"と名前のついたパイプラインをクリックして，パイプライン設定ページに移動します．
6. パイプライン設定ページの一番下にある"Settings"の"Report to SCM"にチェックを入れて，右下の"Update"ボタンをクリックします．こうするとGitHub の Pull Request 画面にパイプラインの実行結果を反映できます．

#### 3. デプロイ設定
ここでは，デプロイ設定の手順を説明します．

1. Werckerに追加した総会リポジトリのアプリケーションページで，"Workflow"をクリックしてワークフロー設定ページを開きます．
2. 一番下の"Pipelines"の項まで移動します．
3. "Add new pipeline"ボタンをクリックして，新しいパイプラインを設定します．
4. "Name"の入力欄に`Slack_Upload`と入力，"YML Pipeline name"には`deploy`と入力，"Hook type"は`default`を選択します．完了したら，"Create"ボタンをクリックします．
5. "Environment variables"の項の入力欄に移動します．
6. "Name"に`SLACK_TOKEN`と入力し，"Value"の入力欄には，1.6で確認したSlackのアクセストークンを入力します．
7. 入力が完了したら，"Add"ボタンを押して，設定を反映します．
8. 再び"Workflow"をクリックしてワークフロー設定ページを開きます．
9. 一番上の"Editor"の項で，"build"の右横にある"＋"ボタンをクリックします．
10. "On Branch"の入力欄に，`master develop`と入力します．これで，masterブランチとdevelopブランチのビルド完了時に，パイプラインが実行されます．
11. "Execute pipeline"は，先ほど作成したパイプライン`Slack_Upload`を指定します．
12. 完了したら，"Add"ボタンをクリックします．


カスタマイズ
---------------------

カスタマイズを行ってくれる人を募集しています．総会文書の執筆をよりよくするようなソリューションを待っています．

今のところ，プルリクエストのコメントにビルドしたPDFへのリンクや，
文章チェックソフトウェアのta9bohによる指摘点を自動で記入できるようになることを目指しています．
これにより，プルリクエストが更新されるたびに，（総会文書のレビューをするために）時間のかかる面倒なビルドする必要がなくなり，
文書の相互レビューがしやすくなることが期待できます．また，執筆者は必ずしも自分の環境でビルドする必要がなくなり，pLaTeX環境の導入の負担が減るでしょう．
また，誰もが犯すような細かなミスは，人手でなくta9bohが自動的にやってくれるので，レビュアーは文章の内容に集中できるようになります．

本リポジトリのbitbucket-pipelines.ymlやwercker.ymlには，Dockerコンテナ内で行なわれるビルドとデプロイの手順が記述されています．
このファイルを変更することで，ビルドの動作やデプロイの方法を変更することが可能です．
Bitbucket Pipelinesの設定方法については，[Bitbucket Pipelinesのページ](https://ja.confluence.atlassian.com/bitbucket/bitbucket-pipelines-792496469.html)を参照してください．
Werckerの設定方法については，[Werckerによる説明ページ](http://devcenter.wercker.com/learn/basics/configuration.html)を参照してください．
動作確認やローカルで動作させるには，ローカル環境で実行できる[Wercker CLI](http://wercker.com/cli/install/)が便利です．
なお，Wercker CLIが動作するOSは，Linuxか，OS X (macOS)です．
