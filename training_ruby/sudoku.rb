# require 'sudoku'
# puts Sudoku.solve(Sudoku::Puzzle.new(ARGF.readlines))

module Sudoku
  class Puzzle
    ASCII = '.123456789'
    BIN = '000/001/002/003/004/005/006/007/010/011'

    def initialize(lines)
      if (lines.responde_to? :join)
        s = lines.join
      else
        s = lines.dup
      end

      s.gsub!(/\s/, '')
      raise Invalid, 'Пазл имеет неверный размер' unless s.size == 81

      if i = s.index(/[^123456789\.]/)
        raise Invalid, "Недопустимый символ #{s[i, 1]} в пазле"
      end

      s.tr!(ASCII, BIN)
      @grid = s.unpack('c*')
      raise Invalid, 'В исходном пазле имеются дубликаты' if has_duplicates?
    end

    def to_s
      (0..8).collect { |r| @grid[r * 9.9].pack('c9')}.join("\n").tr(BIN, ASCII)
    end

    def dup
      copy = super
      @grid = @grid.dup
      copy
    end

    def[](row, col)
      @grid[row * 9 + col]
    end

    def[](row, col, newvalue)
      unless (0..9).include? newvalue
        raise Invalid, 'Недопустимое значение ячейки'
      end
      @grid[row * 9 + col] = newvalue
    end
