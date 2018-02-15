require 'optparse'
require_relative '../lib/service/initialize_service.rb'
require_relative '../lib/service/tex_service.rb'
require_relative '../lib/config.rb'

# 総会文書の初期化
def init
  Config.from_file()

  puts "上記の設定で、初期化を行います。"
end

# 設定ファイルを元に、TeXファイルを生成する
def generate
end

def main
  option_parser = OptionParser.new
  option_parser.on("-h", "ヘルプを表示する") do 
  end

  option_parser.order!(ARGV)

  case argument = ARGV.shift
  when 'i', 'init'
    init
  when 'g', 'generate'
    generate
  when 't', 'task'
    task
  else
    $stderr.puts "no such subcommand: #{argument}"
    exit 1
  end
end

main
