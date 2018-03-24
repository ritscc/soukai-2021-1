# frozen_string_literal: true

require 'optparse'
require_relative '../lib/service/initialize_service.rb'
require_relative '../lib/service/tex_service.rb'
require_relative '../lib/config.rb'
require_relative '../lib/version.rb'
require_relative '../lib/ruby_version.rb'

SUPPORTED_VERSION = RubyVersion.new("2.5.0")
PROJECT_PATH = File.expand_path("../../../", __FILE__)

def read_value(read, write, msg, default = nil)
  write.print default ? "#{msg}(デフォルト: #{default}): " : "#{msg}: "
  line = read.readline.chomp

  if not line.empty?
    then line
    else default end
end

def read_yes?(stdin, stdout, msg)
  value = read_value(stdin, stdout, "#{msg} (Y/n)", "n")
  value.match?(/^y(es)?$/i)
end

def load_config
  path = File.expand_path("./assignee.yml", PROJECT_PATH)

  File.open(path, "r") do |io|
    Config.from(io, ENV)
  end
end

def strip_margin(str)
  margin = str[/^[ \t]*/] || ""
  str.gsub(/^#{margin}/, "")
end

# 総会文書の初期化
def init(args)
  config = load_config

  date = config.project_config.date
  puts strip_margin(<<-EOS)
  開催日: #{date.to_s}（#{date.format_japanese}）
  年度: #{date.fiscal_year}年度（#{date.fiscal_year_japanese}度）
  学期: #{date.semester}
  回目: 第#{config.project_config.ordinal.kanji}回
  リポジトリ名: #{config.bitbucket_config.repository.repo_slug}
  EOS

  puts "\n上記の設定で初期化を行います。"
  exit 0 unless read_yes?(STDIN, STDOUT, "よろしいですか？")

  service = InitializeService.new(config)
  service.initialize_project
end

# 設定ファイルを元に、TeXファイルを生成する
def generate(args)
end

def main
  args = OptionParser.new {|opt|
    opt.version = SETUPRB_VERSION
  }.order(ARGV)

  case arg = args.shift
  when 'i', 'init'
    init(args)
  when 'g', 'generate'
    generate(args)
  when 't', 'task'
    task(args)
  else
    $stderr.puts "no such subcommand: #{arg}"
    exit 1
  end
end

unless RubyVersion.current >= SUPPORTED_VERSION
  STDERR.puts "サポートされていないRubyのバージョンです: #{RubyVersion.current} < #{SUPPORTED_VERSION}"
  exit 1
end

main
