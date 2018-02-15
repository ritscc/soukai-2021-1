# Texファイルの生成に関わるサービス
class TexService
  def post_to_tex
  end

  # 担当者の文責を回生を付けて生成する
  def assignee_to_tex_with_grade(assignee)
    grade_tex = grade_to_tex(assignee.grade)
    family_name = assignee.name.family_name 
    first_name = assignee.name.first_name 

    "\\writtenBy{#{grade_tex}}{#{family_name}}{#{first_name}}"
  end

  # 担当者の文責を役職を付けて生成する
  def assignee_to_tex_with_position(assignee)
    position_tex = position_to_tex(assignee.grade)
    family_name = assignee.name.family_name 
    first_name = assignee.name.first_name 

    "\\writtenBy{#{position_tex}}{#{family_name}}{#{first_name}}"
  end

  # 回生をTeXコマンドの表現に変換する
  def grade_to_tex(grade)
    ['\firstGrade', '\secondGrade', '\thirdGrade', '\fourthGrade'].at(grade.grade - 1)
  end

  # 役職を
  def position_to_tex(position)
    "\\#{position.department.tex_prefix}#{position.post.tex_postfix}"
  end
end
