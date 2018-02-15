require 'minitest/autorun'
require 'minitest/unit'
require_relative '../lib/config'
require_relative '../lib/model/general_meeting'

class TestConfig < MiniTest::Test
  def test_general_config_from_hash
    config = {
      'times' => 1,
      'date' => "2017-08-12"
    }

    general_config = GeneralConfig.from_hash(config)

    assert_equal general_config.times, 1
    assert_equal general_config.date, MeetingDate.new 
  end

  def test_assigees_config_from_hash
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
    # TODO assert_equal assignees_config["rcc_taro"], 
  end
end
