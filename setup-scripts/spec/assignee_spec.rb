require 'rspec'
require_relative '../lib/model/assignee'

RSpec.describe Model::Assignee::Assignee do
  # name = double("Name", family_name: "RCC", first_name: "太郎")
  # grade = double("Grade", grade: 3)
  # position = Position.new(Post::PRESIDENT)

  describe "#to_tex_with_grade" do
    it "は、学年を含む文責を返す" do
      # assignee = Assignee::Assignee.new()
      # expect(assignee.to_tex_with_grade).to eq("")
    end
  end

  describe "#to_tex_with_position" do
    it "は、役職を含む文責を返す" do
    end
  end
end
