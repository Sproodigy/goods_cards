require 'active_support/all'

# def name
#   while true
#     names = []
#     print 'Name:'
#     response = gets
#     case response
#     when /^[a-zA-Z]/
#       names << response
#       puts response
#     when /^[0-9]/, /^$/
#       puts 'Jerk'
#     when /[q]/
#       puts names
#       return true
#     end
#   end
# end

# def name
#   while true
#     print 'Name: '
#     name = gets.chomp
#     names = []
#     count = names << name
#     array = Array.new(count.count)
#     puts array
#   end

# end

# name

class Sequence
  include Enumerable

    def initialize(from, to, by)
      @from, @to, @by = from, to, by
    end

    module Sequences
      def self.fromtoby(from, to, by)
        x = from
        while x <= to
          yield x
          x += by
        end
      end
    end

    def each
      x = @from
      while x <= @to
        yield x
        x += @by
      end
    end

    def length
      return 0 if @from > @to
      Integer ((@to-@from)/@by) + 1
    end

    def[](index)
      retutn nil if index < 0
      v = @from + index*@by
      if v <= @to
        v
      else
        nil
      end
    end

    def *(factor)
      Sequence.new(@from*factor, @to*factor, @by*factor)
    end

    def +(offset)
      Sequence.new(@from+offset, @to+offset, @by)
    end

    # s = Sequence.new(1, 10, 2)
    # s.each { |x| p x }
    # print s[s.length-1]
    # t = (s+1)*2
    # p t

    # Sequences.fromtoby(1, 20, 2) { |x| p x}
end


class Dragon

  def initialize(name)
    @@name = name
    puts @@name + ' родился.'
  end

  # def count
  #
  #   while @@name = gets.chomp
  #     if @@name == 'q'
  #       break
  #     else
  #       puts @@name + ' родился.'
  #     end
  #     puts @@name
  #   end
  # end

  Dragon.new('Flippy')
  Dragon.new('Jimmy')
end

# p = Array.new( ( print "Введите размерность массива: " ; gets.to_i ) ){ |i|
#   print "Введите #{i}-й элемент массива: " ; gets.to_f }
# puts p



    #
    # Dragon.new('Jilly')
    # Dragon.new('Wally')
    # Dragon.new('Flippy')
    # Dragon.count


class Range
  def by(step)
    x = self.begin
    if exclude_end?
      while x < self.end
        yield x
        x += step
      end
    else
      while x <=self.end
        yield x
        x += step
      end
    end
  end

    # (0..40).by(10) do |d|
    #   p d
    # end
end

# weirdHash = Hash.new
#
# weirdHash = {monkeys: 12}
# weirdHash['rats'] = 8
# weirdHash['cats'] = 8
# weirdHash['space'] = 0
# weirdHash['birds'] = 8
# weirdHash = weirdHash.to_a
# weirdHash.each do |k|
#   if k[1] = 8
#     puts "Caught you (#{k})"
#   end
#   puts k
# end

# class Die  #  игральная кость
#   def roll
#     @numberShowing = 1 + rand(6)
#   end
#
#   def showing
#     @numberShowing
#   end
#
# end
#
# die = Die.new
# die.roll
# puts die.showing
# puts die.showing
# die.roll
# puts die.showing
# puts die.showing


#
# class Polygon
#   def self.sides
#     @@sides
#   end
#
#   def self.angles
#     @angles
#   end
#
#   @@sides = 8
#   @angles = 7
#
#   puts @angles.to_s + ' Angles'
# end
#
# puts @angles.to_s + ' Angles'
#
# puts Polygon.sides
#
# class Triangle < Polygon
#   # @angles = 9
#   puts @@sides.to_s + ' Sides ' + @angles.to_s
# end
