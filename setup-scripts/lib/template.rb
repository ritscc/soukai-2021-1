# frozen_string_literal: true

require 'erb'
require 'pathname'

module Template
  class GenericTemplate
    TEMPLATE_BASE_PATH = File.expand_path('../../template/', __FILE__)

    def initialize(template_path)
      @template_path = template_path
    end

    def save(path)
      File.open(path, "w") do |file|
        file << self.build
      end
    end

    def build
      template = ERB.new File.read(@template_path)
      template.result(binding)
    end
  end

  # 文書のテンプレート
  class DocumentTemplate < GenericTemplate
    PATH = TEMPLATE_BASE_PATH + '/document.tex.erb'

    attr_writer :date

    def initialize(template_path = PATH)
      super(template_path)
    end
  end

  # 担当者の割り当てが出来る文書のテンプレート
  class SubSectionTemplate < GenericTemplate
    PATH = TEMPLATE_BASE_PATH + '/section.tex.erb'

    attr_writer :title, :assignee

    def initialize(template_path = PATH)
      super(template_path)
    end
  end

  # READMEのテンプレート
  class ReadmeTemplate < GenericTemplate
    PATH = TEMPLATE_BASE_PATH + '/README.md.erb'

    attr_writer :japanese_year
    attr_writer :ordinal_kanji
    attr_writer :wercker_badge
    attr_writer :last_year
    attr_writer :next_year
    attr_writer :repository_name

    def initialize(template_path = PATH)
      super(template_path)
    end
  end
end
