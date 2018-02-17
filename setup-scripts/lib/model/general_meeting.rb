# frozen_string_literal: true

require 'date'
require_relative 'model'

module Model::GeneralMeeting
  # 総会
  class GeneralMeeting
    attr_reader :date, :times

    # @param date [MeetingDate] 開催日
    # @param times [Integer] 第n回
    def initialize(date, times)
      @date = date
      @times = times
    end
  end

  # 和暦
  class JapaneseEra
    attr_reader :start_date, :end_date, :kanji

    def initialize(start_date: , end_date: , kanji: )
      @start_date = start_date
      @end_date = end_date
      @kanji = kanji
    end

    # 与えられた日付が、自身（元号）の範囲に含まれるかを判定する
    #
    # @param date [Date] 日付
    def include?(date)
      start_date  = self.start_date
      end_date    = self.end_date || Date.today

      (start_date .. end_date).include? date.to_date
    end

    # 与えられた日付の年を、自身の元号における和暦の文字列に変換する
    #
    # @param date [Date] 日付
    def format_year(date)
      year = self.era_year_of(date)
      year = if year.equal? 1
        then '元年'
        else "#{year}年"
        end

      "#{self.kanji}#{year}"
    end

    # 与えられた日付の年を、自身の元号における年に変換する
    #
    # @param date [Date] 日付
    def era_year_of(date)
      date = date.to_date
      throw ArgumentError, "与えられた日付が、元号の開始日より前です。"   if date < @start_date
      throw ArgumentError, "与えられた日付が、元号の終了日より後ろです。" if @end_date and date > @end_date

      date.to_date.year - self.start_date.year + 1
    end

    # 与えられた日付の年に対応する元号を返す
    #
    # @param date [Date] 日付
    def self.from(date)
      ERAS.find {|era| era.include?(date.to_date) }
    end

    # 与えられた日付の年を、和暦の文字列に変換する
    #
    # @param date [Date] 日付
    def self.format_year(date)
      era = self.from(date)

      throw ArgumentError, "日付に対応する元号はありません。コードの修正が必要かもしれません。" if era.nil?

      era.format_year(date)
    end

    private_class_method :new

    SHOWA  = new start_date: Date.new(1926, 12, 25), end_date: Date.new(1989, 1,  7), kanji: '昭和'
    HEISEI = new start_date: Date.new(1989, 1, 8),   end_date: Date.new(2019, 4, 30), kanji: '平成'
    NEW    = new start_date: Date.new(2019, 5, 1),   end_date: nil                  , kanji: '新年号'

    ERAS = [ SHOWA, HEISEI, NEW ]
  end

  # 総会開催日
  class MeetingDate
    # @param 
    def initialize(date)
      @date = date.to_date
    end

    def japanese_era_year
      JapaneseEra.format_date(@date)
    end

    # 前期
    def is_first_semester?
      (4..9).include? @date.month
    end

    # 後期
    def is_second_semester?
      [10..12, 1..3].any? {|range| range.include? @date.month }
    end
  end
end
