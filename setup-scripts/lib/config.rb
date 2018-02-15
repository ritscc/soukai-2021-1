require 'yaml'
require_relative 'model/repository.rb'
require_relative 'model/assignee.rb'

# 一般的な設定
class ProjectConfig
  attr_reader :times, :date

  # ハッシュから設定を生成する
  def self.from_hash(hash)
    times, date = hash.values_at('times', 'date')

    self.new(times, date)
  end

  # @param times [Integer] 第何回目かを表す数値
  # @param date [String, Time, Date] 日付
  def initialize(times, date)
    @times = times
    @date =
      case date.class
      when String then Date.parse date
      when Time   then date.to_date
      when Date   then date
      else Date.parse date.to_s
      end
  end
end

# Bitbucket関連の設定
class BitbucketConfig
  include ::Model::Repository

  attr_reader :repository, :credential

  # ハッシュから設定を生成する
  def self.from_hash(hash)
    username, repo_slug = hash.values_at('username', 'repo_slug')

    repository = Repository.new(User.new(username), repo_slug)

    password_credential = hash.values_at('password_credential')

    credential =
      case
      when password_credential
        PasswordCredential.new(password_credential['username', 'password'])
      else
        throw ArgumentError, "認証情報が不足しています。"
      end

    self.new(repository, credential)
  end

  # @param repository [Repository] リポジトリ
  # @param credential [PasswordCredential] 認証情報
  def initialize(repository, credential)
    @repository = repository
    @credential = credential
  end
end

# 担当者の設定
class AssigneesConfig
  include ::Model::Assignee

  # ハッシュから設定を生成する
  def self.from_hash(config)
    assignees = {}

    config.each_pair.map do |key, info|
      family_name, first_name = (
        case
        when info['family_name'] && info['first_name']
          info.values_at('family_name', 'first_name')
        when info['name']
          info['name'].split(/\s|　/)
        else
          throw ArgumentError, "名前のフォーマットが間違っています: #{info}"
        end
      )

      name = Name.new(family_name, first_name)

      grade = Grade.new(info['grade'])

      position = Position.new(
        Department.from(info['department']),
        Post.from(info['post'])
      )

      bitbucket_user =
        info['bitbucket_user'] ? Bitbucket::User.new(info['bitbucket_user']) : nil

      assignees[key] = Assignee.new(name, grade, position, bitbucket_user)
    end

    self.new(assignees)
  end

  # @param assignees [Hash<String, Assignee>, Array<Assignee>] 担当者のマップまたはリスト
  def initialize(assignees)
    @assignees = Assignees.new(assignees)
  end

  def each(&proc)
    @assignees.each(&proc)
  end
end

class DocumentsConfig
  attr_reader

  def self.from_hash(hash)
  end

  def initialize()
  end
end

class Config
  attr_reader :project_config, :documents_config

  def self.from_file(file)
    file = File::open(file.to_s, "r") if not file.is_a? File

    config = YAML::load file.read

    file.close

    self.new(config)
  end

  def initialize(config)
    @project_config = ProjectConfig.from_hash(config['project'])
    @documents_config = DocumentsConfig.from_hash(config['documents'])
  end
end
