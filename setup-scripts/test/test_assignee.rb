require 'minitest/autorun'
require 'minitest/unit'
require_relative '../lib/assignee'

class TestAssignee < MiniTest::Unit::TestCase
  def test_assignee_to_tex_returns_correct_tex
    name = Name.new("RCC", "太郎")
    position = Position.new(Section::SYSTEM, Post::CHIEF)
    assignee = Assignee.new(name, position)

    assert_equal "\\writtenBy{\\systemChief}{RCC}{太郎}", assignee.to_tex
  end
end
