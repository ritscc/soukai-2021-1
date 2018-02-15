require 'rspec'
require_relative '../lib/config'

describe ProjectConfig do
  describe ".from_hash" do
    it "は、正しい設定を返す" do
      config = { 'times' => 1, 'date' => "2017-08-12" }

      project_config = ProjectConfig.from_hash(config)

      expect(project_config.times).to eq(1)
      expect(project_config.date).to eq(Date.new(2017, 8, 12))
    end
  end
end

describe AssigneesConfig do
  describe ".from_hash" do
    it "は、正しい設定を返す" do
      assignees = {
        'rcc_taro' => {
          'family_name' => 'RCC',
          'first_name' => '太郎',
          'department' => 'system',
          'post' => 'chief',
          'grade' => 2,
          'bitbucket_user' => 'rcc_taro',
        },
        'rcc_jiro' => {
          'name' => 'RCC 次朗',
          'department' => 'exective',
          'post' => 'president',
          'grade' => 3,
          'bitbucket_user' => 'rcc_jiro',
        },
      }

      assignees_config = Config::AssigneesConfig.from_hash(assignees)

      expect(assignees_config[0]).to exist
      # TODO assert_equal assignees_config["rcc_taro"], 
    end
  end
end
