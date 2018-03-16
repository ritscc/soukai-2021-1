# frozen_string_literal: true

require_relative 'model'
require 'pathname'

module Model::Document

  # 文書
  class Document
    attr_reader :path, :title, :assignee

    def initialize(path, title, assignee)
      @path = path
      @title = title
      @assignee = assignee
    end

  end

  class DocumentPath
    to_pathname = proc {|p| Pathname.new(p).freeze }

    ALLOWED_DIRS = %w{
      houshin/kaikei
      houshin/kensui
      houshin/soumu
      houshin/syogai
      houshin/system
      houshin/zentai
      soukatsu/kaikei
      soukatsu/kensui
      soukatsu/soumu
      soukatsu/syogai
      soukatsu/system
      soukatsu/zentai
    }.map(&to_pathname).freeze

    ALLOWED_PATHS = %w{
      houshin/1kai.tex
      houshin/2kai.tex
      houshin/3kai.tex
      houshin/4kai.tex
      soukatsu/1kai.tex
      soukatsu/2kai.tex
      soukatsu/3kai.tex
      soukatsu/4kai.tex
    }.map(&to_pathname).freeze

    def initialize(path)
      path_obj = Pathname.new(path)
      raise ArgumentError, "ここ文書を置くことは許可されていません: #{path_obj}" unless validate_path(path_obj)
      raise ArgumentError, "拡張子はtexでなければなりません: #{path_obj}" unless [".tex"].include?(path_obj.extname.downcase)

      @path = path_obj
    end

    private
    def validate_path(path)
      ALLOWED_DIRS.include?(path.parent.cleanpath) || ALLOWED_PATHS.include?(path.cleanpath)
    end

  end

  class Documents
    include Enumerable

    def initialize(documents)
      @documents =
        if documents.is_a? Array
          documents.clone
        elsif assignees.is_a? Enumerable
          documents.to_a
        else
          raise TypeError.new("Enumerableではありません")
        end
    end

    def each(&p)
      @documents.each(&p)
    end
  end
end
