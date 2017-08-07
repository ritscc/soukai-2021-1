require 'yaml'

class Config
  def self.from_file(file)
    file = File::open(file.to_s, "r") if not file.is_a? File or not file.readable?

    config = YAML::load file.read

    file.close

    self.new(config)
  end

  def self.create_example(file)
    conf = Config.new({
      'general' => {
        'ordinal' => nil,
        'date' => nil,
      },
      'bitbucket' => {
        'username' =>  nil,
        'repo_slug' => nil,
        'password_credential' => nil,
      },
      'assignees' => {
        'rcc_tarou' => {
          'family_name' => 'RCC',
          'first_name' => '太郎',
          'section' => 'system',
          'post' => 'chief',
          'grade' => 2,
        },
        'rcc_jiro' => {
          'family_name' => 'RCC',
          'first_name' => '二郎',
          'section' => 'exective',
          'post' => 'president',
          'grade' => 3,
        },
      },
      'files' => [
        { 'path' => 'src/hajimeni',                 'title' => 'はじめに',  'assignee' => nil },
        { 'path' => 'src/soukatsu/zentai/1_zentai', 'title' => '全体総括',  'assignee' => nil },
        { 'path' => 'src/soukatsu/zentai/2_unei',   'title' => '運営総括',  'assignee' => nil },
        { 'path' => 'src/soukatsu/1kai',            'title' => '1回生総括', 'assignee' => nil },
        { 'path' => 'src/soukatsu/2kai',            'title' => '2回生総括', 'assignee' => nil },
        { 'path' => 'src/soukatsu/3kai',            'title' => '3回生総括', 'assignee' => nil },
        { 'path' => 'src/soukatsu/4kai',            'title' => '4回生総括', 'assignee' => nil },
        { 'path' => 'src/soukatsu/kaikei/1_zentai', 'title' => '全体総括', 'assignee' => nil },
        { 'path' => 'src/soukatsu/kensui/1_zentai', 'title' => '全体総括', 'assignee' => nil },
        { 'path' => 'src/soukatsu/syogai/1_zentai', 'title' => '全体総括', 'assignee' => nil },
        { 'path' => 'src/soukatsu/system/1_zentai', 'title' => '全体総括', 'assignee' => nil },
        { 'path' => 'src/soukatsu/soumu/1_zentai',  'title' => '全体総括', 'assignee' => nil },
        { 'path' => 'src/houshin/zentai/1_zentai',  'title' => '全体方針',  'assignee' => nil },
        { 'path' => 'src/houshin/zentai/2_unei',    'title' => '運営方針',  'assignee' => nil },
        { 'path' => 'src/houshin/1kai',             'title' => '1回生方針', 'assignee' => nil },
        { 'path' => 'src/houshin/2kai',             'title' => '2回生方針', 'assignee' => nil },
        { 'path' => 'src/houshin/3kai',             'title' => '3回生方針', 'assignee' => nil },
        { 'path' => 'src/houshin/4kai',             'title' => '4回生方針', 'assignee' => nil },
        { 'path' => 'src/houshin/kaikei/1_zentai',  'title' => '全体方針', 'assignee' => nil },
        { 'path' => 'src/houshin/kensui/1_zentai',  'title' => '全体方針', 'assignee' => nil },
        { 'path' => 'src/houshin/syogai/1_zentai',  'title' => '全体方針', 'assignee' => nil },
        { 'path' => 'src/houshin/system/1_zentai',  'title' => '全体方針', 'assignee' => nil },
        { 'path' => 'src/houshin/soumu/1_zentai',   'title' => '全体方針', 'assignee' => nil },
      ]
    })
    conf.save()
  end

  def initialize(config = nil)
    @config = {
      'general' => { }
      'bitbucket' => { },
      'assignees' => { },
      'files' => { },
    }.merge(config)
  end

  def save(file)
    file = File::open(file.to_s, "r") if not file.is_a? File

    file.write = YAML::dump @config

    file.close
  end
end
