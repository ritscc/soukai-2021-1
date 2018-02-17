# frozen_string_literal: true

require 'yaml'
require 'pathname'
require_relative 'model/general_meeting.rb'
require_relative 'model/repository.rb'
require_relative 'model/assignee.rb'
require_relative 'model/document.rb'

class ConfigVersion
  include Comparable

  attr_reader :version
  protected :version

  def initialize(str)
    @version = str.split('.').map(&:to_i)
  end

  def to_s
    @version.join(?.)
  end

  def inspect
    "#<#{self.class}: #{to_s}>"
  end

  def <=>(other)
    return nil unless other.is_a? self.class
    self.version <=> other.version
  end

  V2_0_0 = ConfigVersion.new("2.0.0")
end

# 一般的な設定
class ProjectConfig
  include ::Model::GeneralMeeting
  attr_reader :times, :date

  # ハッシュから設定を生成する
  def self.from_hash(hash)
    case version = ConfigVersion.new(hash['version'])
    when ConfigVersion::V2_0_0
      config = hash['project']
      date,  _ = config.fetch_values('date')
      times, _ = config.values_at('times')

      self.new(date, times)
    else
      raise ArgumentError, "未対応の設定のバージョンです: #{version}"
    end
  end

  # @param date [String, Time, Date] 日付
  # @param times [Integer, NilClass] 第何回目かを表す数値
  def initialize(date, times)
    @date = MeetingDate.new case date.class
      when String then Date.parse date
      when Time   then date.to_date
      when Date   then date
      else             Date.parse date.to_s
      end

    @times = times&.to_i || @date.semester_number
  end
end

# Bitbucket関連の設定
class BitbucketConfig
  include ::Model::Repository

  attr_reader :repository, :credential

  # ハッシュから設定を生成する
  def self.from_hash(hash)
    case version = ConfigVersion.new(hash['version'])
    when ConfigVersion::V2_0_0
      config = hash['bitbucket']
      env = hash['env']

      username, repo_slug = config.fetch_values('username', 'repo_slug')

      repository = Repository.new(User.new(username), repo_slug)

      credential = case
        when (username = env['BITBUCKET_USERNAME']) && (password = env['BITBUCKET_PASSWORD'])
          PasswordCredential.new(username, password)
        when password_credential = config['password_credential']
          PasswordCredential.new(*password_credential.fetch_values('username', 'password'))
        else
          # raise ArgumentError, "認証情報が不足しています。"
        end

      self.new(repository, credential)
    else
      raise ArgumentError, "未対応の設定のバージョンです: #{version}"
    end
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
  include ::Model::Repository

  attr_reader

  # ハッシュから設定を生成する
  def self.from_hash(hash)
    case version = ConfigVersion.new(hash['version'])
    when ConfigVersion::V2_0_0
      assignees = {}

      hash['assignees'].each_pair.map do |key, info|
        # name: required
        # grade: optional
        # position: optional
        # bitbucket_user: optional

        name  = Name.from_hash(info)
        grade = info['grade']&.yield_self {|v| Grade.new(v) }

        department = info['department']&.yield_self {|v| Department.from(v) }
        post       = info['post']&.yield_self {|v| Post.from(v) }
        position   = department && post && Position.new(department, post)

        bitbucket_user = info['bitbucket_user']&.yield_self {|v| User.new(v) }

        assignees[key] = Assignee.new(key, name, grade, position, bitbucket_user)
      end

      self.new(Assignees.new(assignees))
    else
      raise ArgumentError, "未対応の設定のバージョンです: #{version}"
    end
  end

  # @param assignees [Hash<String, Assignee>, Array<Assignee>] 担当者のマップまたはリスト
  def initialize(assignees)
    @assignees = assignees
  end
end

# 文書と担当者の設定
class DocumentsConfig
  attr_reader

  include ::Model::Assignee
  include ::Model::Document

  def self.from_hash(hash)
    case version = ConfigVersion.new(hash['version'])
    when ConfigVersion::V2_0_0
      # path: required
      # title: required
      # assignee: optional
      documents_ary = hash['documents'].each do |doc|
        path, title = doc.fetch_values('path', 'title')
        assignee, _ = doc.values_at('assignee')

        next Document.new(DocumentPath.new(path), title, assignee)
      end

      documents = Documents.new(documents_ary)

      self.new(documents)
    else
      raise ArgumentError, "未対応の設定のバージョンです: #{version}"
    end
  end

  def initialize(documents)
    @documents = documents
  end
end

class Config
  attr_reader :project_config, :documents_config, :assignees_config, :bitbucket_config

  def self.from(io, env)
    hash = YAML::load(io)
    hash["env"] = env

    self.from_hash(hash)
  end

  def self.from_hash(hash)
    self.new(hash)
  end

  def initialize(config)
    @version = ConfigVersion.new(config['version'])
    @project_config = ProjectConfig.from_hash(config)
    @assignees_config = AssigneesConfig.from_hash(config)
    @documents_config = DocumentsConfig.from_hash(config)
    @bitbucket_config = BitbucketConfig.from_hash(config)
  end
end
