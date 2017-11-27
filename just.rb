start = Time.now

arr = []

range = (0..30000)
range.each do |f|
  puts f += f
end

finish = Time.now
# 
puts full_time = finish - start

if full_time >= 3600
  hours = (full_time / 3600).round
  min = (full_time / 60 - hours * 60).round
  sec = (full_time - (min * 60 + hours * 3600)).round
  puts "#{hours} hours   #{min} min   #{sec} sec"
elsif full_time >= 60
  min = (full_time / 60).round
  sec = (full_time - min * 60).round.to_s
  puts "#{min} min   #{sec} sec"
else
  puts full_time.round.to_s + ' sec'
end
