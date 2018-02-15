require 'minitest/autorun'
require 'minitest/unit'
require_relative '../lib/model/assignee'

class TestAssignee < MiniTest::Test
  include Assignee

  def setup
    @name = Name.new("RCC", "太郎")
    @grade = Grade.new(3)
    @position = Position.new(Department::SYSTEM, Post::CHIEF)
    @assignee = Assignee.new(@name, @grade, @position)
  end

  def test_assignee_to_tex_with_position_returns_correct_tex
    assert_equal "\\writtenBy{\\systemChief}{RCC}{太郎}", @assignee.to_tex_with_position
  end

  def test_assignee_to_tex_with_grade_returns_correct_tex
    assert_equal "\\writtenBy{\\thirdGrade}{RCC}{太郎}", @assignee.to_tex_with_grade
  end
end
