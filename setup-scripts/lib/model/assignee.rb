# frozen_string_literal: true

require_relative 'model'

module Model::Assignee
  # 担当者を管理する
  class Assignees
    extend Enumerable

    def initialize(assignees)
      @assignees =
        if assignees.is_a? Hash
          assignees.clone
        elsif assignees.is_a? Enumerable
          assignees.map{|assignee| [ assignee.name.format, assignee] }.to_h
        else
          throw TypeError.new("Enumerableではありません")
        end
    end

    def each(&proc)
      @assignees.each(&proc)
    end

    def [](key)
      @assignees[key]
    end
  end

  # 担当者
  class Assignee
    attr_reader :id, :name, :grade, :position, :bitbucket_user

    def initialize(id, name, grade, position, bitbucket_user = nil)
      @id = id
      @name = name
      @grade = grade
      @position = position
      @bitbucket_user = bitbucket_user
    end
  end

  # 学年
  class Grade
    # grade should be a integer
    def initialize(grade)
      throw ArgumentError, "学年は、Integerでなければなりません。"  unless grade.is_a? Integer
      throw ArgumentError, "学年は、1〜4の間でなければなりません。" unless (1..4).include? grade
      @grade = grade
    end

    def to_i
      @grade.to_i
    end
  end

  # 役職
  class Post
    private_class_method :new
    attr_reader :inspect

    def self.from(post)
      case post.to_s
      when /president|執行委員長/i        then PRESIDENT
      when /sub_?president|副執行委員長/i then SUB_PRESIDENT
      when /chief|局長/i                  then CHIEF
      when /staff|局員/i                  then STAFF
      else throw ArgumentError, "そのような役職は、存在しません: #{post}"
      end
    end

    def initialize(inspect)
      @inspect = inspect
    end

    PRESIDENT     = new("PRESIDENT")
    SUB_PRESIDENT = new("SUB_PRESIDENT")
    CHIEF         = new("CHIEF")
    STAFF         = new("STAFF")
  end

  # 局
  class Department
    private_class_method :new
    attr_reader :tex_prefix, :inspect

    def self.from(department)
      case department.to_s
      when /exec|sh?ikkou|執行部/i     then EXEC
      when /kaikei|会計局?/i           then KAIKEI
      when /kensui|研究推進局?/i       then KENSUI
      when /syogai|渉外局?/            then SYOGAI
      when /system|システム(管理局?)?/ then SYSTEM
      when /soumu|総務局?/             then SOUMU
      else throw ArgumentError, "そのような局は存在しません: #{department.to_s}"
      end
    end

    def initialize(inspect: , allowed_posts: )
      @inspect = inspect
      @allowed_posts = allowed_posts.freeze
    end

    def has_post?(post)
      @allowed_posts.include? post
    end

    EXECTIVE_POSTS = [Post::PRESIDENT, Post::SUB_PRESIDENT].freeze
    NORMAL_POSTS   = [Post::CHIEF, Post::STAFF].freeze

    EXEC   = new(inspect: "EXEC",   allowed_posts: EXECTIVE_POSTS)
    KAIKEI = new(inspect: "KAIKEI", allowed_posts: NORMAL_POSTS)
    KENSUI = new(inspect: "KENSUI", allowed_posts: NORMAL_POSTS)
    SYOGAI = new(inspect: "SYOGAI", allowed_posts: NORMAL_POSTS)
    SYSTEM = new(inspect: "SYSTEM", allowed_posts: NORMAL_POSTS)
    SOUMU  = new(inspect: "SOUMU" , allowed_posts: NORMAL_POSTS)
  end

  # 局と役職
  class Position
    def initialize(department, post)
      unless department.has_post?(post)
        throw ArgumentError, "局「#{department}」に対して、役職「#{post}」は定義されていません。"
      end

      @department = department
      @post = post
    end

    attr_reader :department, :post
  end

  # 名前
  class Name
    # OK例1:
    #   family_name: 西園寺
    #   first_name: 公望
    # OK例2:
    #   name: 西園寺 公望
    # NG例1:
    #   name: 西園寺
    def self.from_hash(hash)
      family_name, first_name = case
        when hash['family_name'] && hash['first_name']
          hash.values_at('family_name', 'first_name')
        when (name = hash['name'].split(/\s|　/)).length == 2
          name
        else
          throw ArgumentError, "名前のフォーマットが間違っています: #{hash}"
        end

      self.new(family_name, first_name)
    end

    def initialize(family_name, first_name)
      @family_name = family_name
      @first_name  = first_name
    end

    attr_reader :family_name, :first_name
  end
end
