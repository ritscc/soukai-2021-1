# frozen_string_literal: true

require 'optparse'
require_relative '../lib/service/initialize_service.rb'
require_relative '../lib/service/tex_service.rb'
require_relative '../lib/config.rb'
require_relative '../lib/version.rb'

def read_value(io, msg, default = nil)
  prompt = default ? "#{msg}(デフォルト: #{default}): " : "#{msg}: "
  line = io.readline(prompt).chomp

  if not line.empty?
    then line
    else default end
end

def load_config
  File.open("./assignee.yml", "r") do |io|
    Config.from_io(io)
  end
end

# 総会文書の初期化
def init
  config = load_config

  date = config.project_config.date
  puts "開催日: #{date.to_s}（#{date.format_japanese_date}）"
  puts "年度: #{date.fiscal_year}年度（#{date.fiscal_japanese_year}度）"
  puts "学期: #{date.semester}"
  puts "回目: #{config.project_config.times}"
  puts "リポジトリ名: #{config.bitbucket_config.repository.repo_slug}"

  puts "\n上記の設定で、初期化を行います。"

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

main
