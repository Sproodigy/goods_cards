# def data(count)
#   input = 0..count-1
#   @data = []
#   input.each do |num|
#     input_data = gets.chomp
#     @data << input_data
#   end
#   puts @data.class
# end
#
# def equation
#   range = 0..100000
#   @data.each do |n|
#     if /\d/.match(n) then n = n.to_i end
#   end
# end
#
# data(5)
# equation
z = 8
s = '3 + z + 3'
puts equation = (s.sub(/z/, "#{z}"))
puts s
