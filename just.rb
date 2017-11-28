full_time = (3600..3720)

full_time.each do |full_time|
if full_time >= 3600
  hours = (full_time / 3600).floor
  min = (full_time / 60 - hours * 60).floor
  sec = (full_time - (min * 60 + hours * 3600))
  puts "#{hours} hours   #{min} min   #{sec} sec"
elsif full_time >= 60
  min = (full_time / 60).floor
  sec = (full_time - min * 60)
  puts "#{min} min   #{sec} sec"
else
  puts full_time.round.to_s + ' sec'
end
end
# 
# puts full_time.to_f / 60
# puts (full_time - min * 60)
