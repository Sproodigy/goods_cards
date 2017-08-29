require 'active_support/all'
require 'csv'

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


# class User
#   @@users_count = 0
#
#   def initialize(login, password, email)
#     @id       = @@users_count += 1
#     @login    = login
#     @password = password
#     @email    = email
#   end
#
#   def user_data
#     @user_data ||=
#     {
#       id: @id,
#       login: @login,
#       password: @password,
#       email: @email
#     }
#   end
#
#   def just
#     puts 'Just an inscription'
#   end
#
#   def self.users_count
#     @@users_count
#   end
#
# end

# user = User.new('John', '123', 'sample@mail.ru')
# user = User.new('Smith', '456', 'another@mail.ru')
# user.just
# User.just

# puts user.user_data
# p = Array.new( ( print "Введите размерность массива: " ; gets.to_i ) ){ |i|
#   print "Введите #{i}-й элемент массива: " ; gets.to_f }
# puts p



    #
    # Dragon.new('Jilly')
    # Dragon.new('Wally')
    # Dragon.new('Flippy')
    # Dragon.count


class Ranged
  def by(start, step)
    start = self.begin
    if exclude_end?
      while start < self.end
        yield start
        start += step
      end
    else
      while start <= self.end
        yield start
        start += step
      end
    end
  end

  # (0..40).by(10) do |d|
  #   p d
  # end

end

def doSelfImportantly (proct)
  puts 'Everybody just HOLD ON!  I have something to do...'
  proct.call
  puts 'Ok everyone, I\'m done.  Go on with what you were doing.'
end

sayHello = Proc.new do
  puts 'hello'
end

sayGoodbye = Proc.new do
  puts 'goodbye'
end



def maybeDo someProc
  if rand(2) == 0
    someProc.call
  end
end

def twiceDo someProc
  someProc.call
  someProc.call
end

wink = Proc.new do
  puts '<wink>'
end

glance = Proc.new do
  while rand(4) == 3
    puts '<glance>'
  end
end

def doUntilFalse firstInput, someProc
  input  = firstInput
  output = firstInput

  while output
    input  = output
    output = someProc.call input
  end

  input
end

buildArrayOfSquares = Proc.new do |array|
  lastNumber = array.last
  if lastNumber <= 0
    false
  else
    array.pop                         # Take off the last number...
    array.push lastNumber*lastNumber  # ...and replace it with its square...
    array.push lastNumber-1           # ...followed by the next smaller number.
  end
end

alwaysFalse = Proc.new do |justIgnoreMe|
  false
end

# puts doUntilFalse([5], buildArrayOfSquares).inspect

def compose proc1, proc2
  Proc.new do |x|
    proc2.call(proc1.call(x))
  end
end

squareIt = Proc.new do |x|
  x * x
end

doubleIt = Proc.new do |x|
  x + x
end

doubleThenSquare = compose doubleIt, squareIt
squareThenDouble = compose squareIt, doubleIt

# puts doubleThenSquare.call(5)
# puts squareThenDouble.call(5)
# @@sides = 6

class Polygon
  def self.sides
    @@sides
  end

  def self.angles
    @angles
  end

  @@sides = 8
  @angles = 7

  puts @angles.to_s + ' Angles'
end

class Triangle < Polygon
  # puts @@sides.to_s + ' Sides '
end
