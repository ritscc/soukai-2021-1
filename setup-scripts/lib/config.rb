# frozen_string_literal: true

require 'yaml'
require 'pathname'
require_relative 'model/general_meeting.rb'
require_relative 'model/repository.rb'
require_relative 'model/assignee.rb'
require_relative 'model/document.rb'

# 一般的な設定
class ProjectConfig
  include ::Model::GeneralMeeting
  attr_reader :times, :date

  # ハッシュから設定を生成する
  def self.from_hash(hash)
    case version = hash['version']
    when "2.0.0"
      config = hash['project']
      date, times = config.fetch_values('date', 'times')

      self.new(date, times)
    else
      throw ArgumentError, "未対応のバージョンです: #{version}"
    end
  end

  # @param date [String, Time, Date] 日付
  # @param times [Integer, NilClass] 第何回目かを表す数値
  def initialize(date, times)
    date_obj = case date.class
      when String then Date.parse date
      when Time   then date.to_date
      when Date   then date
      else Date.parse date.to_s
      end
    @date = MeetingDate.new(date_obj)
    @times = times || case
    when @date.is_first_semester?  then 1
    when @date.is_second_semester? then 2
    else
      throw RuntimeError, ""
    end
  end
end

# Bitbucket関連の設定
class BitbucketConfig
  include ::Model::Repository

  attr_reader :repository, :credential

  # ハッシュから設定を生成する
  def self.from_hash(hash)
    config = hash['bitbucket']

    username, repo_slug = config.fetch_values('username', 'repo_slug')

    repository = Repository.new(User.new(username), repo_slug)

    credential = case
      when password_credential = config['password_credential']
        PasswordCredential.new(password_credential['username', 'password'])
      else
        # throw ArgumentError, "認証情報が不足しています。"
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
  include ::Model::Repository

  attr_reader

  # ハッシュから設定を生成する
  def self.from_hash(hash)
    case version = hash['version']
    when "2.0.0"
      assignees = {}

      hash['assignees'].each_pair.map do |key, info|

        name = Name.from_hash(info)

        grade = info['grade']&.yield_self {|v| Grade.new(v) }

        department = info['department']&.yield_self {|v| Department.from(v) }
        post = info['post']&.yield_self {|v| Post.from(v) }
        position = department && post && Position.new(department, post)

        bitbucket_user = info['bitbucket_user']&.yield_self {|v| User.new(v) }

        assignees[key] = Assignee.new(key, name, grade, position, bitbucket_user)
      end

      self.new(Assignees.new(assignees))
    else
      throw ArgumentError, "未対応のバージョンです: #{version}"
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
    case version = hash['version']
    when "2.0.0"
      documents_ary = hash['documents'].each do |doc|
        path, title, assignee = doc.fetch_values('path', 'title', 'assignee')

        next Document.new(path, title, assignee)
      end

      documents = Documents.new(documents_ary)

      self.new(documents)
    else
      throw ArgumentError, "未対応のバージョンです: #{version}"
    end
  end

  def initialize(documents)
    @documents = documents
  end
end

class Config
  attr_reader :project_config, :documents_config, :assignees_config, :bitbucket_config

  def self.from_io(io)
    hash = YAML::load(io)
    self.from_hash(hash)
  end

  def self.from_hash(hash)
    self.new(hash)
  end

  def initialize(config)
    @version = config['version']
    @project_config = ProjectConfig.from_hash(config)
    @assignees_config = AssigneesConfig.from_hash(config)
    @documents_config = DocumentsConfig.from_hash(config)
    @bitbucket_config = BitbucketConfig.from_hash(config)
  end
end
