require_relative 'model'

module Model::Assignee
  # 担当者を管理する
  class Assignees
    def initialize(assignees)
      @assignees =
        if assignees.is_a? Hash
          assignees.clone
        elsif assignees.is_a? Enumerable
          assignees.map{|assignee| [ assignee.name.format, assignee] }.to_h
        end
    end

    def [](key)
      @Assignees[key]
    end
  end

  # 担当者
  class Assignee
    attr_reader :name, :grade, :position, :bitbucket_user

    def initialize(name, grade, position, bitbucket_user = nil)
      @name = name
      @grade = grade
      @position = position
      @bitbucket_user = bitbucket_user
    end
  end

  # 学年
  class Grade
    attr_reader :grade

    # grade should be a integer
    def initialize(grade)
      throw ArgumentError, "学年は、Integerでなければなりません。"  unless grade.is_a? Integer
      throw ArgumentError, "学年は、1〜4の間でなければなりません。" unless (1..4).include? grade
      @grade = grade
    end
  end

  # 役職
  class Post
    private_class_method :new

    def self.from(post)
      case post.to_s
      when /president/i      then PRESIDENT
      when /sub_?president/i then SUB_PRESIDENT
      when /chief/i          then CHIEF
      when /staff/i          then STAFF
      else throw ArgumentError, "そのような役職は、存在しません: #{post}"
      end
    end

    PRESIDENT     = new
    SUB_PRESIDENT = new
    CHIEF         = new
    STAFF         = new
  end

  # 局
  class Department
    private_class_method :new
    attr_reader :tex_prefix

    def self.from(department)
      case department.to_s
      when /exec|sikkou|執行部/i       then EXEC
      when /kaikei|会計局?/i           then KAIKEI
      when /kensui|研究推進局?/i       then KENSUI
      when /syogai|渉外局?/            then SYOGAI
      when /system|システム(管理局?)?/ then SYSTEM
      when /soumu|総務局?/             then SOUMU
      else throw ArgumentError, "そのような局は存在しません: #{department.to_s}"
      end
    end

    def initialize(tex_prefix: , allowed_posts: )
      @tex_prefix = tex_prefix.freeze
      @allowed_posts = allowed_posts.freeze
    end

    def has_post?(post)
      @allowed_posts.include? post
    end

    EXECTIVE_POSTS = [Post::PRESIDENT, Post::SUB_PRESIDENT].freeze
    NORMAL_POSTS   = [Post::CHIEF, Post::STAFF].freeze

    EXEC   = new(tex_prefix: "",       allowed_posts: EXECTIVE_POSTS)
    KAIKEI = new(tex_prefix: "kaikei", allowed_posts: NORMAL_POSTS)
    KENSUI = new(tex_prefix: "kensui", allowed_posts: NORMAL_POSTS)
    SYOGAI = new(tex_prefix: "syogai", allowed_posts: NORMAL_POSTS)
    SYSTEM = new(tex_prefix: "system", allowed_posts: NORMAL_POSTS)
    SOUMU  = new(tex_prefix: "soumu",  allowed_posts: NORMAL_POSTS)
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
    def initialize(family_name, first_name)
      @family_name = family_name
      @first_name  = first_name
    end

    attr_reader :family_name, :first_name
  end
end
