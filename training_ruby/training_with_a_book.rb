def are_you_sure?
  while true
    print 'Are you sure? [y/n]:'
    response = gets
    case response
    when /^[yY]/
      puts 'Good'
    when /^[nN]/, /^$/
      puts 'Jerk'
    when /[q]/
      return true
    end
  end
end

# are_you_sure?

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

    # Sequences.fromtoby(1, 20, 2) { |x| p x}






    # s = Sequence.new(1, 10, 2)
    # s.each { |x| p x }
    # print s[s.length-1]
    # t = (s+1)*2
    # p t
end

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

    (0..40).by(10) do |d|
      p d
  end
end
