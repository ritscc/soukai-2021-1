require 'rspec'

require_relative '../lib/config'
require_relative '../lib/model/general_meeting'

describe ProjectConfig do
  describe ".from_hash" do
    it "は、正しい設定を返す" do
      input = <<-EOF
      version: 2.0.0
      project:
          date: 2017-08-20
          ordinal: 1
      EOF

      input_hash = YAML.load(input)
      result = ProjectConfig.from_hash(input_hash)

      date    = ::Model::GeneralMeeting::MeetingDate.new(Date.new(2017, 8, 20))
      ordinal = ::Model::GeneralMeeting::Ordinal.new(1)

      is_asserted_by { result.date == date }
      is_asserted_by { result.ordinal == ordinal }
    end
  end
end

describe AssigneesConfig do

  let(:rcc_taro_expected) {
    ::Model::Assignee::Assignee.new(
      "rcc_taro",
      ::Model::Assignee::Name.new("RCC", "太郎"),
      ::Model::Assignee::Grade.new(3),
      ::Model::Assignee::Position.new(
        ::Model::Assignee::Department::EXEC,
        ::Model::Assignee::Post::PRESIDENT,
      ),
      ::Model::Repository::User.new("rcc_taro_desu"),
    )
  }

  describe ".from_hash" do
    let(:input_hash) {
      input = <<-EOF
      version: 2.0.0
      assignees:
          rcc_taro:
              name: RCC 太郎
              bitbucket_user: rcc_taro_desu
              grade: 3
              department: 執行部
              post: 執行委員長
          rcc_jiro:
              name: RCC 次朗
              bitbucket_user: rcc_jiro_dayo
              department: system
              post: staff
      EOF

      YAML.load(input)
    }

    it "は、正しい設定を返す" do
      assignees = AssigneesConfig.from_hash(input_hash).assignees

      rcc_taro = assignees['rcc_taro'];

      is_asserted_by { rcc_taro                == rcc_taro_expected }
      is_asserted_by { rcc_taro.id             == rcc_taro_expected.id }
      is_asserted_by { rcc_taro.name           == rcc_taro_expected.name }
      is_asserted_by { rcc_taro.grade          == rcc_taro_expected.grade }
      is_asserted_by { rcc_taro.position       == rcc_taro_expected.position }
      is_asserted_by { rcc_taro.bitbucket_user == rcc_taro_expected.bitbucket_user }

      is_asserted_by { assignees.to_a.length == 2 }

      #is_asserted_by { result['rcc_jiro'] == rcc_jiro }
      # TODO assert_equal assignees_config["rcc_taro"], 
    end
  end
end
