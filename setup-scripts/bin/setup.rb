# frozen_string_literal: true

require 'optparse'
require_relative '../lib/service/initialize_service.rb'
require_relative '../lib/service/tex_service.rb'
require_relative '../lib/config.rb'
require_relative '../lib/version.rb'
require_relative '../lib/ruby_version.rb'

SUPPORTED_VERSION = "2.5.0"

def read_value(read, write, msg, default = nil)
  write.print default ? "#{msg}(デフォルト: #{default}): " : "#{msg}: "
  line = read.readline.chomp

  if not line.empty?
    then line
    else default end
end

def load_config
  File.open("./assignee.yml", "r") do |io|
    Config.from(io, ENV)
  end
end

# 総会文書の初期化
def init
  config = load_config

  date = config.project_config.date
  puts "開催日: #{date.to_s}（#{date.format_japanese_date}）"
  puts "年度: #{date.fiscal_year}年度（#{date.fiscal_japanese_year}度）"
  puts "学期: #{date.semester}"
  puts "回目: 第#{config.project_config.ordinal.kanji}回"
  puts "リポジトリ名: #{config.bitbucket_config.repository.repo_slug}"

  puts "\n上記の設定で初期化を行います。"
  value = read_value(STDIN, STDOUT, "よろしいですか？ (Y/n)", "n")
  exit 0 unless value.match?(/^Y$/i)

  service = InitializeService.new(config)
  service.initialize_project
end

# 設定ファイルを元に、TeXファイルを生成する
def generate
end

def main
  option_parser = OptionParser.new
  option_parser.version = SETUPRB_VERSION

  args = option_parser.order(ARGV)

  case arg = args.shift
  when 'i', 'init'
    init
  when 'g', 'generate'
    generate
  when 't', 'task'
    task
  else
    $stderr.puts "no such subcommand: #{arg}"
    exit 1
  end
end


unless RubyVersion.current >= RubyVersion.new(SUPPORTED_VERSION)
  STDERR.puts "サポートされていないRubyのバージョンです: #{RUBY_VERSION} < #{SUPPORTED_VERSION}"
  exit 1
end

main
