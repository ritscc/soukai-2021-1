# coding: utf-8
require 'pathname'

base_dir = File.expand_path('../', File.dirname(__FILE__))
src_dir = "#{base_dir}/src"
types = %w(houshin soukatsu)
sections = %w(kaikei kensui soumu syogai system zentai)

command = ARGV[0] || 'input'
types.each do |type|
  sections.each do |section|
    tex_files = Dir.glob("#{src_dir}/#{type}/#{section}/**/*.tex").sort.map do |path|
      Pathname(path).relative_path_from(Pathname(base_dir)).to_s
    end
    case command
    when 'input'
      input_text = tex_files.map{ |tex| "\\input{#{tex}}" }.join("\n") + "\n"
      File.write("#{src_dir}/#{type}/#{section}.tex", input_text)
    when 'show'
      unless tex_files.empty?
        puts tex_files.join("\n")
      end
    end
  end
end
