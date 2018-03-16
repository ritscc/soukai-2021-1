# frozen_string_literal: true

require_relative 'model'

# Bitbucket
module Model::Repository
  # ユーザ
  class User
    attr_reader :username

    def initialize(username)
      @username = username
    end

    def ==(other)
      username == other.username
    end
  end

  # リポジトリ
  class Repository
    attr_accessor :user, :repo_slug

    def initialize(user, repo_slug)
      @user  = user
      @repo_slug = repo_slug
    end
  end

  # 課題
  class Issue
    # 状態
    class State
      private_class_method :new

      def initialize(string: )
        @string = string
      end

      def to_s
        @string
      end

      def inspect
        @string.upcase
      end

      NEW = new(string: 'new').freeze
    end

    # 優先度
    class Priority
      private_class_method :new

      def initialize(string: )
        @string = string
      end

      def to_s
        @string
      end

      TRIVIAL  = new(string: 'trivial').freeze
      MINOR    = new(string: 'minor').freeze
      MAJOR    = new(string: 'major').freeze
      CRITICAL = new(string: 'critical').freeze
      BLOCKER  = new(string: 'blocker').freeze
    end

    # 種別
    class Kind
      private_class_method :new

      def initialize(string: )
        @string = string
      end

      def to_s
        @string
      end

      BUG         = new(string: 'bug').freeze
      ENHANCEMENT = new(string: 'enchancement').freeze
      PROPOSAL    = new(string: 'proposal').freeze
      TASK        = new(string: 'task').freeze
    end

    attr_reader :title, :content, :responsible, :state, :priority, :kind

    def initialize(title: , content: nil, responsible: nil, state: State::NEW, priority: Priority::MAJOR, kind: Kind::TASK)
      @title       = title
      @content     = content
      @responsible = responsible
      @state       = state
      @priority    = priority
      @kind        = kind
    end
  end
end
