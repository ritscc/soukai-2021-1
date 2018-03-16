# frozen_string_literal: true

# Rubyのバージョンを比較するためのクラス
class RubyVersion
  include Comparable

  attr_reader :version
  protected :version

  # 現在の実行環境のバージョンのオブジェクトを返す
  def self.current
    RubyVersion.new(RUBY_VERSION)
  end

  # 文字列からバージョンオブジェクトを生成する
  def initialize(str)
    @version = str.split('.').map(&:to_i)
  end

  def to_s
    @version.join(?.)
  end

  def inspect
    "#<#{self.class}: #{to_s}>"
  end

  def <=>(other)
    return nil unless other.is_a? self.class
    self.version <=> other.version
  end
end
