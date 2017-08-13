require 'csv'

# Read file as individual rows, can translate it into an array (with a header representation) and string (without header representation).
  # m = CSV.read('test.csv', headers: true).to_a   # Same as CSV.parse(File.read('test.csv'))
  # puts m.inspect, m.class, '- - - - - - - -'
  # m.each do |arr|
  #   puts arr.to_s[0..6].gsub(/[^0-9]/, '').inspect, arr.to_s.class, ' = = = = = = = = = '
  # end

  m = CSV.foreach('test.csv',col_sep: ';', headers: true) do |col|  # Same as CSV.parse(File.read('test.csv'))
    col['Art']
  end

  # puts m
  # src_for_csv.each do |row|   # Array
  #     if row[0] == m[1][0][0..4].gsub(/[^0-9]/, '')
  #       next
  #     else
  #       m << row
  #     end
  # end
    # m.delete('Name')   # Remove the column
    # m.delete(0)   # Remove a row
    # m.each do |row|
    #   puts row, '= = = = = ='
    #   puts row.to_a.inspect, '- - - - - - -'
    #   puts row.to_s.inspect, '+ + + + + + + +'
    # end

# Read the file as individual columns.
  # m = CSV.foreach('test.csv', col_sep: ';', headers:true) do |col|   # Same as CSV.parse('test.csv') { |row| puts row.inspect}
  #   puts col[0]
      # p col.inspect, '- - - - - - -'
      # p col, '= = = = = = = ='
      # puts col['Price'], '+ + + + + + +'
      # puts col[1], '+ + + + + + +'
  # end
