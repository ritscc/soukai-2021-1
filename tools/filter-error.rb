# coding: utf-8
log_file = ARGV.shift

File.open(log_file) do |file|
  tex_file = ""
  error_msg = []
  error_flag = false

  file.each_line do |line|
    line = line.chomp
    # inputされているtexファイル名を見つけて、エラー内容の起点とする
    tmp_tex_file = line.scan(%r{^[^!]*\(\./(.*?\.tex)}).flatten.last
    if tmp_tex_file
      # 一つ前に見つかったtexファイル名がエラーが起きているファイル
      # ファイル名とエラーを出力
      if error_flag
        puts tex_file
        puts error_msg.join("\n")
        puts ''
      end

      # リセットして次を探す
      tex_file = tmp_tex_file
      error_msg = []
      error_flag = false
    else
      # texファイル名が含まれない場合で
      # 先頭が「!」が含まれるとエラーと判定
      error_flag = true if line =~ /^!.*/
      error_msg << line
    end
  end
end
