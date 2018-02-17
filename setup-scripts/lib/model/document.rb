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

  class Documents
    extend Enumerable

    def initialize(documents)
      @documents = 
        if documents.is_a? Array
          documents.clone
        elsif assignees.is_a? Enumerable
          documents.to_a
        else
          throw TypeError.new("Enumerableではありません")
        end
    end

    def each(&p)
      @documents.each(&p)
    end
  end
end
