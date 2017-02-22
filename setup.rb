# encoding: utf-8
# Macだとこれしないといけない可能性 http://qiita.com/kidachi_/items/d0137d96bed9ac381fd5

require 'readline'
require 'singleton'
require 'yaml'
require 'net/https'
require 'io/console'
require 'erb'
require 'date'

class Setup
  include Singleton

  README_TEMPLATE = 'template/README.md.erb'
  README_PATH = 'README.md'
  DOCUMENT_TEX_TEMPLATE = 'template/document.tex.erb'
  DOCUMENT_TEX_PATH = 'document.tex'
  ASSIGNEE_PATH = 'assignee.yml'

  def initialize
  end

  # リポジトリの初期化
  def init_repo
    info = {}
    rm_list = [
      %w(src/houshin/4kai.tex src/kouki.tex),
      %w(src/houshin/1kai.tex src/soukatsu/4kai.tex src/zenki.tex)
    ]

    info[:date] = Date.parse(get_value('開催日', Date.today.to_s))
    info[:fiscal_year] = info[:date].year - (info[:date].month < 4 ? 1 : 0)
    info[:last_year] = info[:fiscal_year] - 1
    info[:next_year] = info[:fiscal_year] + 1
    info[:heisei] = info[:date].year - 1988
    info[:ordinal] = get_value('第何回目?', ((4..9).include?(info[:date].month) ? 1 : 2)).to_i
    info[:ordinal_kanji] = (info[:ordinal] == 1 ? '一' : '二')
    info[:semester] = (info[:ordinal] == 1 ? '\zenki' : '\kouki')
    info[:wercker_badge] = get_value('WerckerのShare Badge （Markdown表記）', '')
    info[:repo_name] = "soukai-#{info[:fiscal_year]}-#{info[:ordinal]}"

    readme = ERB.new(File.read(README_TEMPLATE))
    File.write(README_PATH, readme.result(binding))

    tex = ERB.new(File.read(DOCUMENT_TEX_TEMPLATE))
    File.write(DOCUMENT_TEX_PATH, tex.result(binding))

    rm_list[info[:ordinal] - 1].each do |file_name|
      File.delete file_name
    end

    create_assignee_template(info[:ordinal])
  end

  def create_files(*dir)
    assignees.each do |path, info|
      create_file(path, info) if path.start_with? File.join(*dir).gsub(%r{^(./)?src/}, '')
    end
  end

  def create_issue(*dir)
    puts 'Please type these infomations in order to create issues on Bitbucket: '
    puts 'empty id is bad. retype.' until bitbucket_id = get_value('Bitbucket ID', nil)
    puts 'empty id is bad. retype.' until bitbucket_passwd = $stdin.noecho { print 'Bitbucket Password: '; $stdin.gets; }.chomp
    puts ''

    assignees.each do |path, info|
      create_task(path, info, bitbucket_id, bitbucket_passwd) if path.start_with? File.join(*dir).gsub(%r{^(./)?src/}, '')
    end
  end

  private

  # 担当者のyamlファイルのテンプレートを生成
  def create_assignee_template(ordinal)
    template = <<-"EOS"
# RCC 自動生成用テンプレート
# 【書式】 filename: タイトル, 姓 名, BitbucketID
# （例）1kai: 1回生総括, RCC 太郎, RCC_Tarou
#
# 回生別のファイル名は変更しないでください
# それ以外のファイル名は先頭に数字を付けることで、順番を制御できます
---
hajimeni: はじめに,
soukatsu:
  zentai:
    1_zentai: #{ordinal == 1 ? '前期' : '後期'}活動総括,
    2_unei: 運営総括,
  1kai: 1回生総括,
  2kai: 2回生総括,
  3kai: 3回生総括,
  4kai: 4回生総括,
  kaikei:
#    1_zentai: 全体総括,
  kensui:
#    1_zentai: 全体総括,
  syogai:
#    1_zentai: 全体総括,
  system:
#    1_zentai: 全体総括,
  soumu:
#    1_zentai: 全体総括,
houshin:
  zentai:
    1_zentai: #{ordinal == 2 ? '前期' : '後期'}活動方針,
    2_unei: 運営方針,
  1kai: #{ordinal == 2 ? '新' : ''}1回生方針,
  2kai: #{ordinal == 2 ? '新' : ''}2回生方針,
  3kai: #{ordinal == 2 ? '新' : ''}3回生方針,
  4kai: #{ordinal == 2 ? '新' : ''}4回生方針,
  kaikei:
#    1_zentai: 全体方針,
  kensui:
#    1_zentai: 全体方針,
  syogai:
#    1_zentai: 全体方針,
  system:
#    1_zentai: 全体方針,
  soumu:
#    1_zentai: 全体方針,
    EOS

    [
      %w(4回生方針),
      %w(4回生総括 1回生方針)
    ][ordinal - 1].each do |target|
      template.gsub!(/^.*#{target}.*\n/, '')
    end

    File.write(ASSIGNEE_PATH, template);
  end

  # 文責情報を読み込む
  def assignees
    yaml = File::open(ASSIGNEE_PATH) do |file|
      YAML::load(file.read)
    end

    assignee_list = {}

    yaml.each do |type, type_data|
      case type
      when 'hajimeni'
        assignee_list['hajimeni.tex'] = parse_assignee(type_data)
      when 'soukatsu', 'houshin'
        type_data && type_data.each do |section, section_data|
          case section
          when /^\dkai$/
            assignee_list[File.join(type, "#{section}.tex")] = parse_assignee(section_data)
          when 'zentai', 'kaikei', 'kensui', 'syogai', 'system', 'soumu'
            section_data && section_data.each do |subsection, subsection_data|
              assignee_list[File.join(type, section, "#{subsection}.tex")] = parse_assignee(subsection_data)
            end
          end
        end
      end
    end

    assignee_list
  end

  def parse_assignee(data)
    {}.tap do |info|
      info[:title], full_name, bitbucket_id = data.split(',').map(&:strip)
      if full_name || bitbucket_id
        info[:assignee] = {}
        info[:assignee][:bitbucket_id] = bitbucket_id
        info[:assignee][:family], info[:assignee][:name] = full_name.split(' ') if full_name
      end
    end
  end

  # 指定のパスのファイルを生成する
  def create_file(filepath, info)
    # 普通のパスで指定できるもの
    if match = filepath.scan(%r{^([^/]+)/([^/]+)/(.+)$})[0]
      # 正規表現による切り出し
      section = match[1]
      section_file = File.join('./src', "#{File.dirname(filepath)}.tex")
      subsection_file = File.join('./src', filepath)

      if File.exist?(subsection_file)
        puts("#{subsection_file} is exist.")
        return
      end

      # 文責の生成
      lines = ["\\subsection*{#{info[:title]}}"] + positions(info, section)

      # ファイルを生成し、書き込みを行う
      File.write(subsection_file, lines.join("\n") + "\n")

      # section_fileにinputが書かれていなかったら、追加
      # TODO: 自動inputにする
      s = File.read(section_file, encoding: Encoding::UTF_8)
      unless s =~ /#{subsection_file}/
        File.open(section_file, 'a') do |file|
          file.puts("\\input{#{subsection_file}}")
        end
      end
    elsif filepath =~ %r{/[1234]kai.tex$} || filepath == 'hajimeni.tex'
      # 回生別 または はじめに の場合
      subsection_file = File.join('./src', filepath)
      type = filepath == 'hajimeni.tex' ? nil : 'kaisei'
      puts("warning: '#{subsection_file}' will be changed.")

      File.open(subsection_file, 'a') do |file|
        file.puts(positions(info, type).join("\n") + "\n")
      end
    else
      puts('unsupported file path.')
      return
    end

    puts "created '#{subsection_file}'"
  end

  # 種別ごとに文責を生成
  # nilやどれにも当てはまらなければ, デフォルトを返す
  def positions(info, section = nil)
    assignee = (info && info[:assignee]) || { family: '姓', name: '名' }
    kaisei = ['\firstGrade', '\secondGrade', '\thirdGrade', '\fourthGrade']

    list =
      case section
      when 'kaikei', 'kensui', 'syogai', 'system', 'soumu'
        ["\\#{section}Chief", "\\#{section}Staff"]
      when 'kaisei'
        kaisei
      else
        ['\president', '\subPresident'] + kaisei
      end

    list.map do |pos|
      "%\\writtenBy{#{pos}}{#{assignee[:family]}}{#{assignee[:name]}}"
    end
  end

  def create_task(filepath, info, user, passwd)
    assignee = info[:assignee] || {}
    data = {
      'title'       => "#{filepath}:#{info[:title]}",
      'content'     => "担当者は、#{assignee[:family]} #{assignee[:name]}さんです。\n`src/#{filepath}`を編集してください。",
      'responsible' => assignee[:bitbucket_id].to_s,
      'status'      => 'new',
      'priority'    => 'major',
      'kind'        => 'task'
    }

    # get git info
    if match = `git remote -v`.match(%r{bitbucket\.org[:/]([^/]+)/([^\.]+)(\.git)? })
      repo_username = match[1]; repo_slug = match[2];
    else
      puts 'fatal error: git repository is not found!!'
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

  def get_value(msg, default)
    prompt = default.to_s.empty? ? "#{msg}: " : "#{msg}(default #{default}): "
    s = Readline.readline(prompt)
    return s.empty? ? default : s
  end

end

def print_help
  print(<<"EOS")
Usage: ruby setup.rb [argument(s)]
Commands:
I,  init                        Initialize document.tex and README.md and so on
g,  generate [filter]           Generate LaTeX files from YAML template
i,  issue [filter]              Generate Issues on Bitbucket from YAML template

filter format is below
- filepath
- <type>
- <type> <section>

type:
  hajimeni
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
  ruby setup.rb I
  ruby setup.rb g
  ruby setup.rb i src/soukatsu/syogai
  ruby setup.rb i soukatsu
  ruby setup.rb g houshin kensui

EOS
end

setup = Setup.instance

begin
  case ARGV[0]
  when 'I', 'init'
    setup.init_repo
  when 'g', 'generate'
    setup.create_files ARGV[1..-1]
  when 'i', 'issue'
    setup.create_issue ARGV[1..-1]
  else
    print_help
  end
end
