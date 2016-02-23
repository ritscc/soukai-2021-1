# coding: utf-8

# 第一引数はサブコマンド
# 第二引数はtexが入っているディレクトリ
# 第三引数はtexのコンパイルログのパス

command = ARGV.shift
src_dir = ARGV.shift
log_file = ARGV.shift

def input_list(src_dir, log_file)
  File.open(log_file) do |file|
    (file.read.scan %r!\(\./(#{src_dir}/.*?\.tex)!).flatten
  end
end

def exists_list(src_dir)
  Dir.glob "#{src_dir}/**/*.tex"
end

case command
when 'input'
  puts input_list(src_dir, log_file).join("\n")
when 'not-input'
  puts '以下のファイルがinputされていません'
  puts (exists_list(src_dir) - input_list(src_dir, log_file)).join("\n")
end
