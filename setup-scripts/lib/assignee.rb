# 学年
class Grade
  # grade should be a integer
  def initialize(grade)
    throw ArgumentError, "grade number should be in 1..4"   unless (1..4).include? grade
    throw ArgumentError, "grade number should be a integer" unless grade.is_a? Integer
    @grade = grade
  end

  def to_tex
    ['\firstGrade', '\secondGrade', '\thirdGrade', '\fourthGrade'].at(@grade - 1)
  end
end

# 役職
class Post
  private
  def initialize(tex_postfix: )
    @tex_postfix = tex_postfix
  end

  public
  attr_reader :tex_postfix

  PRESIDENT     = self.new(tex_postfix: "president"   )
  SUB_PRESIDENT = self.new(tex_postfix: "subPresident")
  CHIEF         = self.new(tex_postfix: "Chief"       )
  STAFF         = self.new(tex_postfix: "Staff"       )
end

# 局
class Section
  private
  def initialize(tex_prefix: , allowed_posts: )
    @tex_prefix = tex_prefix
    @allowed_posts = allowed_posts
  end

  EXECTIVE_POSTS = [Post::PRESIDENT, Post::SUB_PRESIDENT].freeze
  NORMAL_POSTS   = [Post::CHIEF, Post::STAFF].freeze
  public
  def is_exective?
    @is_exective
  end

  def is_normal?
    @is_normal
  end

  def has_post?(post)
    @allowed_posts.include? post
  end

  attr_reader :tex_prefix

  SIKKOU = self.new(tex_prefix: "",       allowed_posts: EXECTIVE_POSTS)
  KAIKEI = self.new(tex_prefix: "kaikei", allowed_posts: NORMAL_POSTS)
  KENSUI = self.new(tex_prefix: "kensui", allowed_posts: NORMAL_POSTS)
  SYOGAI = self.new(tex_prefix: "syogai", allowed_posts: NORMAL_POSTS)
  SYSTEM = self.new(tex_prefix: "system", allowed_posts: NORMAL_POSTS)
  SOUMU  = self.new(tex_prefix: "soumu",  allowed_posts: NORMAL_POSTS)
end

# 局と役職
class Position
  def initialize(section, post)
    unless section.has_post?(post)
      throw ArgumentError, "局「#{section_name}」に対して、役職「#{post_name}」は定義されていません。"
    end

    @section = section
    @post    = post
  end

  def to_tex
    "\\#{section.tex_prefix}#{post.tex_postfix}"
  end

  attr_reader :section, :post
end

# 名前
class Name
  def initialize(family_name, first_name)
    @family_name = family_name
    @first_name  = first_name
  end

  attr_reader :family_name, :first_name
end

# 担当者
class Assignee
  def initialize(name, position, bitbucket_user = nil)
    @name = name
    @position = position
    @bitbucket_user = bitbucket_user
  end

  def to_tex
    "\\writtenBy{#{@position.to_tex}}{#{@name.family_name}}{#{@name.first_name}}"
  end

  attr_reader :name, :position, :bitbucket_user
end
