# encoding: utf-8

# Macだとこれしないといけない可能性 http://qiita.com/kidachi_/items/d0137d96bed9ac381fd5

require "readline"

def get_value(msg, default)
  prompt = default.to_s.empty? ? "#{msg}: " : "#{msg}(default #{default}): "
  s = Readline.readline(prompt)
  return s.empty? ? default : s
end

def set_replace_word(list)
  t = Time.now

  list[:current_year] = get_value('開催年度', t.year - (t.month < 4 ? 1 : 0))
  list[:last_year] = list[:current_year].to_i - 1
  list[:next_year] = list[:current_year].to_i + 1
  list[:heisei] = list[:current_year].to_i - 1988
  list[:month] = get_value('開催月', t.month)
  list[:day] = get_value('開催日', t.day)
  list[:ordinal] = get_value('第何回目?', ((4..9).include?(t.month) ? 1 : 2))
  list[:ordinal_kanji] = (list[:ordinal].to_i == 1 ? '一' : '二')
  list[:semester] = (list[:ordinal].to_i == 1 ? '\zenki' : '\kouki')
end

def replace_text(file, list)
  s = File.read(file, :encoding => Encoding::UTF_8)

  list.each{ |key, val|
    s.gsub!("#[#{key}]", val.to_s);
  }

  File.write(file, s)
end

def create_files
  if ['soukatsu', 'houshin'].include?(ARGV[1]) && ['zentai', 'kaikei', 'kensui', 'syogai', 'system', 'soumu'].include?(ARGV[2]) && !ARGV[3].to_s.empty?
    section_file = "./src/#{ARGV[1]}/#{ARGV[2]}.tex"
    case ARGV[2]
    when 'zentai'
      positions = ['\firstGrade', '\secondGrade', '\thirdGrade', '\forthGrade']
    when 'kaikei'
      positions = ['\kaikeiChief', '\kaikeiStaff']
    when 'kensui'
      positions = ['\kensuiChief', '\kensuiStaff']
    when 'syogai'
      positions = ['\syogaiChief', '\syogaiStaff']
    when 'system'
      positions = ['\systemChief', '\systemStaff']
    when 'soumu'
      positions = ['\soumuChief', '\soumuStaff']
    end

    ARGV[3..-1].each do |file|
      subsection_file = "src/#{ARGV[1]}/#{ARGV[2]}/#{file}.tex"
      if File.exist?(subsection_file)
        puts("#{subsection_file} is exist.")
      else
        puts(subsection_file)
        subsection = get_value('小節名', '')
        family = get_value('苗字', '')
        name = get_value('名前', '')
        line = ["\\subsection*{#{subsection}}"]
        positions.each do |pos|
          line.push("%\\writtenBy{#{pos}}{#{family}}{#{name}}")
        end

        File.write(subsection_file, line.join("\n"))

        s = File.read(section_file, :encoding => Encoding::UTF_8)
        unless s =~ /#{subsection_file}/
            File.open(section_file, 'a') do |file|
            file.puts("\\input{#{subsection_file}}")
          end
        end
      end
    end
    return 0
  else
    return -1
  end
end

def print_help
  print(<<"EOS")
Usage: ruby setup.rb [argument(s)]
Commands:
i,  init                                      Initialize document.tex and README.md
g,  generate [type] [section] [subsection(s)] Generate something awesome

Please choose a generator below.

type:
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
  ruby setup.rb g soukatsu zentai welcome_zemi group_works
EOS
end


case ARGV[0]
when 'i', 'init'
  list = { }
  set_replace_word(list)

  replace_text("document.tex", list)
  replace_text("README.md", list)
when 'g', 'generate'
  if create_files < 0
    print_help
  end
else
  print_help
end
