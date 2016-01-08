# encoding: utf-8
# Macだとこれしないといけない可能性 http://qiita.com/kidachi_/items/d0137d96bed9ac381fd5

require "readline"
require "yaml"
require "net/https"
require "io/console"

# 種別ごとに文責を生成
# nilやどれにも当てはまらなければ, デフォルトを返す
def generate_position(section)
  case section
  when 'kaikei' then ['\kaikeiChief', '\kaikeiStaff']
  when 'kensui' then ['\kensuiChief', '\kensuiStaff']
  when 'syogai' then ['\syogaiChief', '\syogaiStaff']
  when 'system' then ['\systemChief', '\systemStaff']
  when 'soumu'  then ['\soumuChief', '\soumuStaff']
  else               ['\president', '\subPresident', '\firstGrade', '\secondGrade', '\thirdGrade', '\fourthGrade']
  end
end

# 文責の生成
def add_positions(lines, info, section = nil)
  return nil unless lines.is_a?(Array)

  positions = generate_position(section)
  assignee = (info && info[:assignee]) || {family: "xxxx", name: "xxxx"}

  positions.each do |pos|
    lines.push("%\\writtenBy{#{pos}}{#{assignee[:family]}}{#{assignee[:name]}}")
  end
end

# ファイルパス（./src/〜.tex）の存在を確認する
def check_file_exists?(filepath)
  subsection_file = "./src/#{filepath}.tex"

  if File.exist?(subsection_file)
    puts("#{subsection_file} is exist.")
    return true
  end
end

# 指定のパスのファイルを生成する
def create_file(filepath, info)
  # 普通のパスで指定できるもの
  if match = filepath.match(%r{^([^/]+)/([^/]+)/(.+)$})
    # 正規表現による切り出し
    type = match[1]; section = match[2]; subsection = match[3];
    section_file = "./src/#{type}/#{section}.tex"
    subsection_file = "./src/#{filepath}.tex"

    return if check_file_exists?(filepath)

    # 文責の生成
    lines = ["\\subsection*{#{info[:title]}}"]
    add_positions(lines, info, section)

    # ファイルを生成し、書き込みを行う
    File.write(subsection_file, lines.join("\n"))

    # section_fileにinputが書かれていなかったら、追加
    s = File.read(section_file, :encoding => Encoding::UTF_8)
    unless s =~ /#{subsection_file}/
      File.open(section_file, 'a') do |file|
        file.puts("\\input{#{subsection_file}}")
      end
    end
  # 回生別総括の場合
  elsif filepath =~ %r{/[1234]kai$}
    puts("warning: '#{filepath}' will be changed.")
    type = nil;
    subsection_file = "./src/#{filepath}.tex"
    if File.exist?(subsection_file) && assignee = info[:assignee] # assigneeが空の場合は作成されない.
      s = File.read(subsection_file, :encoding => Encoding::UTF_8)
      s.gsub!('\writtenBy{役職}{姓}{名}', '') # 該当行の削除
      lines = []
      add_positions(lines, info)
      s << lines.join("\n") << "\n"
      File.write(subsection_file, s)
    end
  else
    puts("unsupported file path.")
    return false
  end

  puts "created '#{subsection_file}'"
end

def create_task(filepath, info, user, passwd)
  assignee = info[:assignee] || {}
  data = {
    "title"       => "#{filepath}:#{info[:title]}",
    "content"     => "担当者は、#{assignee[:family]} #{assignee[:name]}さんです。\n'src/#{filepath}.tex'を編集してください。",
    "responsible" => "#{assignee[:bitbucket_id]}",
    "status"      => "new",
    "priority"    => "major",
    "kind"        => "task"
  }

  # get git info
  if match = `git remote -v`.match(%r{bitbucket\.org[:/]([^/]+)/([^\.]+)\.git})
    repo_username = match[1]; repo_slug = match[2];
  else
    puts "fatal error: git repository is not found!!"
  end

  # check task existence
  # uri = URI.parse("https://api.bitbucket.org/1.0/repositories/#{repo_username}/#{repo_slug}/issues/")
  # uri.query = URI.encode_www_form({"search" => info[:title]})
  # uri.userinfo = [user, passwd]
  # p uri.request_uri

  # req = Net::HTTP::Get.new(uri.request_uri)
  # http = Net::HTTP.new(uri.host, uri.port)
  # res = http.request(req)

  # p res.each.to_a
  # p res
  # case res
  # when Net::HTTPSuccess
  #   if res
  #     puts "issue '#{data["title"]}' is already created."
  #     return
  #   end
  # else
  #   return
  # end

  # create a task
  res = Net::HTTP.post_form(URI.parse("https://#{user}:#{passwd}@api.bitbucket.org/1.0/repositories/#{repo_username}/#{repo_slug}/issues/"), data)
  case res
  when Net::HTTPSuccess
    puts "created '#{data["title"]}' issue."
  else
    puts "HTTP Error: #{res.message}: '#{filepath}'"
  end
end

def parse_file(filename)
  file = File::open(filename, 'r')
  str = file.read
  file.close

  yaml = YAML::load(str)

  while yaml.values.any?{|e| e.is_a?(Hash) }
    keys = yaml.keys
    keys.each do |key|
      data = yaml[key]
      if data.is_a?(Hash)
        yaml.delete(key)
        data.each_key {|inner| yaml["#{key}/#{inner}"] = data[inner] }
      end
    end
  end

  keys = yaml.keys
  keys.each do |key|
    match = key.match(/^([^:]+):([^:]+)$/)
    if (match)
      path = match[1]; title = match[2];
      assignee_match = yaml[key] && yaml[key].match(/^([^ ]+) ([^ <]+) *<([^>]+)>$/)
      yaml["#{path}"] = {
        title: match[2],
        assignee: (assignee_match ? { family: assignee_match[1], name: assignee_match[2], bitbucket_id: assignee_match[3] } : yaml[key])
      }
      yaml.delete(key)
    else
      yaml[key] = nil
    end
  end

  return nil if yaml.values.include?(nil)
  return yaml
end

def get_value(msg, default)
  prompt = default.to_s.empty? ? "#{msg}: " : "#{msg}(default #{default}): "
  s = Readline.readline(prompt)
  return s.empty? ? default : s
end

def set_replace_word(list)
  t = Time.now

  list[:current_year] = get_value('開催年度', t.year - (t.month < 4 ? 1 : 0))
  list[:last_year] = list[:current_year].to_i - 1
  list[:next_year] = list[:current_year].to_i + 1
  list[:heisei] = list[:current_year].to_i - 1988
  list[:month] = get_value('開催月', t.month)
  list[:day] = get_value('開催日', t.day)
  list[:ordinal] = get_value('第何回目?', ((4..9).include?(t.month) ? 1 : 2))
  list[:ordinal_kanji] = (list[:ordinal].to_i == 1 ? '一' : '二')
  list[:semester] = (list[:ordinal].to_i == 1 ? '\zenki' : '\kouki')
end

def replace_text(file, list)
  s = File.read(file, :encoding => Encoding::UTF_8)

  list.each{ |key, val|
    s.gsub!("#[#{key}]", val.to_s);
  }

  File.write(file, s)
end

def create_files
  if ['soukatsu', 'houshin'].include?(ARGV[1]) && ['zentai', 'kaikei', 'kensui', 'syogai', 'system', 'soumu'].include?(ARGV[2]) && !ARGV[3].to_s.empty?
    ARGV[3..-1].each do |file|
      filepath = "#{ARGV[1]}/#{ARGV[2]}/#{file}"
      next if check_file_exists?(filepath)

      subsection = get_value('小節名', '')
      family = get_value('苗字', '')
      name = get_value('名前', '')
      create_file(filepath, { title: subsection, assignee: { family: family, name: name } })
    end
    return true
  end
  return false
end

def yaml_latex()
  if yaml = parse_file(ARGV[1])
    yaml.each{|k, v| create_file(k, v) }
  else
    puts "Format Error."
  end
end

def yaml_issue()
  puts  "Please type these infomations in order to create issues on Bitbucket: "
  puts 'empty id is bad. retype.' until bitbucket_id = get_value('Bitbucket ID', nil)
  puts 'empty id is bad. retype.' until bitbucket_passwd = $stdin.noecho { print 'Bitbucket Password: '; $stdin.gets; }.chomp
  puts ""

  if yaml = parse_file(ARGV[1])
    yaml.each{|k, v| create_task(k, v, bitbucket_id, bitbucket_passwd) }
  else
    puts "Format Error."
  end
end

def print_help
  print(<<"EOS")
Usage: ruby setup.rb [argument(s)]
Commands:
i,  init                                      Initialize document.tex and README.md
g,  generate [type] [section] [subsection(s)] Generate something awesome
t,  template                                  Print a YAML template
l,  yaml-latex [filename]                     Generate LaTeX files from YAML template
I,  yaml-issue [filename]                     Generate Issues on Bitbucket from YAML template

Please choose a generator below.

type:
  soukatsu
  houshin

section:
  zentai
  kaikei
  kensui
  syogai
  system
  soumu

Example:
  ruby setup.rb g soukatsu zentai welcome_zemi group_works
EOS
end

def print_template
  print(<<"EOS")
# RCC 自動生成用テンプレート
# 【書式】 filename:タイトル:    姓 名 <BitbucketID>
# （例）1kai:1回生総括:    RCC 太郎 <RCC_Tarou>
---
soukatsu:
  zentai:
    zentai:前期／後期活動総括:
    unei:運営総括:
  1kai:1回生総括:
  2kai:2回生総括:
  3kai:3回生総括:
  4kai:4回生総括:
  kaikei:
    kaikei:会計局総括:
  kensui:
    kensui:研究推進局:
  syogai:
    syogai:渉外局:
  system:
    system:システム管理局:
  soumu:
    soumu:総務局:
houshin:
  zentai:
    zentai:前期／後期活動方針:
    unei:運営方針:
  1kai:1回生方針:
  2kai:2回生方針:
  3kai:3回生方針:
  kaikei:
    kaikei:会計局方針:
  kensui:
    kensui:研究推進局方針:
  syogai:
    syogai:渉外局方針:
  system:
    system:システム管理局方針:
  soumu:
    soumu:総務局方針:
EOS
end

case ARGV[0]
when 'i', 'init'
  list = { }
  set_replace_word(list)

  replace_text("document.tex", list)
  replace_text("README.md", list)
when 'g', 'generate'
  print_help unless create_files
when 'l', 'yaml-latex'
  yaml_latex()
when 'I', 'yaml-issue'
  yaml_issue()
when 't', 'template'
  print_template
else
  print_help
end
