require 'csv'

  table = CSV.read('test.csv', { encoding: "UTF-8", col_sep: ';', headers: true }).to_a.sort  # Same as CSV.parse(File.read('test.csv'))
  puts table


  header = ["Art", "Title", "Short description", "SKU", "Barcode", "Purchase price", "Price", "Weight"]
   CSV.open('test.csv', 'w', { encoding: "UTF-8", col_sep: ';', headers: true }) do |csv|
     csv << header
     table.each do |row|
       csv << row
     end
   end
