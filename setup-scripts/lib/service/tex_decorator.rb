module TexDecorator

  module Decorator
    def initialize(orig)
      @orig = orig
    end

    def method_missing(name, *args, &block)
      @orig.method(name).call(*args, &block)
    end
  end

  class PostDecorator
    include Decorator

    def to_tex
      case @orig
      when Post
      else
        raise RuntimeError, "未知の役職です"
      end
    end
  end

  class DepartmentDecorator
    include Decorator

    def tex_prefix
      case @orig
      when Post::EXEC
        ""
      when Post::KAIKEI
        "kaikei"
      when Post::KENSUI
        "kensui"
      when Post::SYOGAI
        "syogai"
      when Post::SYSTEM
        "system"
      when Post::SOUMU
        "soumu"
      else
        raise RuntimeError, "未知の役職です"
      end
    end
  end

  class PositionDecorator
    include Decorator

    def department
      DepartmentDecorator.new(super)
    end

    def post
      PostDecorator.new(super)
    end

    def to_tex
      "\\#{self.department.to_tex}#{self.post.to_tex}"
    end
  end

  class GradeDecorator
    include Decorator

    # 回生をTeXコマンドの表現に変換する
    def to_tex
      ['\firstGrade', '\secondGrade', '\thirdGrade', '\fourthGrade'].at(self.to_i - 1)
    end
  end

  class AssigneeDecorator
    include Decorator

    def grade
      GradeDecorator.new(super)
    end

    def position
      PositionDecorator.new(super)
    end

    # 担当者の文責を回生を付けて生成する
    def to_tex_with_grade
      grade_tex = self.grade.to_tex
      family_name = self.name.family_name 
      first_name = self.name.first_name 

      "\\writtenBy{#{grade_tex}}{#{family_name}}{#{first_name}}"
    end

    # 担当者の文責を役職を付けて生成する
    def to_tex_with_position
      position_tex = self.position.to_tex(assignee.grade)
      family_name = self.name.family_name 
      first_name = self.name.first_name 

      "\\writtenBy{#{position_tex}}{#{family_name}}{#{first_name}}"
    end
  end
end
