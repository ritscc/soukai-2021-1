# frozen_string_literal: true
require_relative '../model/assignee.rb'

module TexDecorator

  refine Post do
    def to_tex
      case @orig
      when Post
      else
        raise RuntimeError, "未知の役職です"
      end
    end
  end

  refine Department do
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

  refine Position do
    def to_tex
      "\\#{self.department.to_tex}#{self.post.to_tex}"
    end
  end

  refine Grade do
    def to_tex
      ['\firstGrade', '\secondGrade', '\thirdGrade', '\fourthGrade'].at(self.to_i - 1)
    end
  end

  refine Assignee do
    # 担当者の文責を生成する。回生が含まれる。
    def to_tex_with_grade
      grade_tex = self.grade.to_tex
      family_name = self.name.family_name 
      first_name = self.name.first_name 

      "\\writtenBy{#{grade_tex}}{#{family_name}}{#{first_name}}"
    end

    # 担当者の文責を生成する。役職が含まれる。
    def to_tex_with_position
      position_tex = self.position.to_tex(assignee.grade)
      family_name = self.name.family_name 
      first_name = self.name.first_name 

      "\\writtenBy{#{position_tex}}{#{family_name}}{#{first_name}}"
    end
  end
end
