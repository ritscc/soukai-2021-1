# frozen_string_literal: true

require 'optparse'
require_relative '../lib/service/initialize_service.rb'
require_relative '../lib/service/tex_service.rb'
require_relative '../lib/config.rb'
require_relative '../lib/version.rb'

def config
  File.open("./assignee.yml", "r") do |io|
    Config.from_io(io)
  end
end

# 総会文書の初期化
def init
  config
  puts "上記の設定で、初期化を行います。"
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
