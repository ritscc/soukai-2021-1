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
  not_input_list = exists_list(src_dir) - input_list(src_dir, log_file)
  unless not_input_list.empty?
    puts '以下のファイルが \input{} コマンドで総会文書に取り込まれていません．'
    puts not_input_list.join("\n")
    puts ''
    puts '総会文書執筆では，担当箇所ごとにファイルを分割しています．'
    puts '分割されたファイルは，章のファイルや局別のファイルで'
    puts '\input{} コマンドを用いて取り込む必要があります．'
  end
end
