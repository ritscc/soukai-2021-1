require 'erb'

module Template
  class GenericTemplate
    TEMPLATE_BASE_PATH = Pathname.new('../template')

    def initialize(path, template_path)
      @path = path
      @template_path = template_path
    end

    def save
      File.open(@path, "w") do |file|
        file << self.build_tex
      end
    end

    private
    def build_tex
      template = ERB.new File.read(@template_path)
      template.result(binding)
    end
  end

  # 文書のテンプレート
  class DocumentTemplate < GenericTemplate
    PATH = TEMPLATE_BASE_PATH + 'document.tex.erb'

    def initialize(path, template_path = PATH)
      super(path, template_path)
    end

    def title=(title)
      @title = title
    end

    def date=(date)
      @date = date
    end
  end

  # 担当者の割り当てが出来る文書のテンプレート
  class SubSectionTemplate < GenericTemplate
    PATH = TEMPLATE_BASE_PATH + 'section.tex.erb'

    def initialize(path, template_path = PATH)
      super(path, template_path)
    end

    def title=(assginee)
      @title = assignee
    end

    def assignee=(assginee)
      @assignee = assignee
    end
  end

  # READMEのテンプレート
  class ReadmeTemplate < GenericTemplate
    PATH = TEMPLATE_BASE_PATH + 'README.md.erb'

    def initialize(path, template_path = PATH)
      super(path, template_path)
    end

    def date=(date)
      @date = date
    end

    def repository=(repository)
      @repository = repository
    end
  end
end
