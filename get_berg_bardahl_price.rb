# encoding: utf-8

# require 'axlsx'   # For create xlsx files
require 'rubyXL'
require 'roo-xls'
require 'simple-spreadsheet'
# require 'simple-xls'
require 'csv'
# require 'uri'
# require 'net/http'
require 'http'
require 'open-uri'
require 'nokogiri'
require 'base64'
require 'json'

def get_bardahl_product_data(product_id)
  # page = Nokogiri::HTML(HTTP.follow.get("https://berg.ru/article/#{product_id}").to_s)
  # page = Nokogiri::HTML(HTTP.follow.get("https://berg.ru/search/step2?search=#{product_id}&brand=BARDAHL").to_s)
  page = Nokogiri::HTML(HTTP.follow.get("http://www.bardahlrussia.ru/?page_id=#{product_id}").to_s)

  {
    # art_2: page.css('.search_card__table_col tbody td.price_col').to_s
    title: page.css('.two-thirds h1.headline strong').first&.content&.to_s,
    image_path: (page.css('.two-thirds img').first[:src] unless page.css('.two-thirds img').first.nil?),
    full_desc: page.css('.half-page').first
  }
end

def get_berg_bardahl_product_data
  page = Nokogiri::HTML(HTTP.follow.get("https://berg.ru/search?search=bardahl").to_s)

  {
    price: page.css('.search_result__row .search_card__table tbody')
  }
end

def get_bardahl_product_image(product_id)

  src = get_bardahl_product_data(product_id)[4]
  name = get_bardahl_product_data(product_id)[2]

  @content_type_data = File.extname(src)
  content_type = 'image/' + @content_type_data[1,3]
  image_base64_data = Base64.encode64(open(src) { |f| f.read })
  @image = "data:#{content_type};base64,#{image_base64_data}"
  # File.open('Liqui_Moly_' + "#{name}" + '_' + File.extname(src)[1, 3], 'wb') { |f| f.write(open(src).read) }
  # Save image to folder on the hard drive
  # IO.copy_stream(open(src), "/home/sproodigy/Foto/Liqui_Moly_#{name}_#{get_bardahl_product_data(product_id)[1].first(-1)}_#{File.basename(src)}")
  # IO.copy_stream(open(src), "Users/extra/Изображения/Foto/Liqui_Moly_#{name}_#{get_bardahl_product_data(product_id)[1].first(-1)}_#{File.basename(src)}")
end


def barcode_from_product_art(product_art)
  s = "41004200#{product_art}"
  "#{s}#{checkdigit(s)}"
end

def checkdigit(barcode)
  evens, odds = *barcode.scan(/\d/).map { |d| d.to_i }.partition.with_index { |d, i| (i&1).zero? }
  (10 - ((odds.reduce(:+)) * 3 + evens.reduce(:+)) % 10) % 10
end

                           # sku пока использовать только при создании новых товаров.

def put_lm_product_price(purchase_price, barcode, store_id, price, short_desc, title, weight, image, filename, country_of_origin)
  page = HTTP.headers(authorization: "Token e541dfef128f4f93cbdb09b320ea3fb7").put("https://xp.extrapost.ru/api/v1/products/#{barcode}",
                      json: {product: {purchase_price: purchase_price,
                                       barcode: barcode,
                                       store_id: store_id,
                                       price: price,
                                       description: short_desc,
                                       title: title,
                                       weight: weight,
                                       image: image,
                                       image_file_name: filename,
                                       country_of_origin: country_of_origin
                                      }})
end

def create_product(purchase_price, sku, barcode, store_id, price, short_desc, title, weight, image, filename, country_of_origin)
  page = HTTP.headers(authorization: "Token e541dfef128f4f93cbdb09b320ea3fb7").post("https://xp.extrapost.ru/api/v1/products/",
                     json: {product: { purchase_price: purchase_price,
                                       sku: sku,
                                       barcode: barcode,
                                       store_id: store_id,
                                       price: price,
                                       description: short_desc,
                                       title: title,
                                       weight: weight,
                                       image: image,
                                       image_file_name: filename,
                                       country_of_origin: country_of_origin
                                      }})
end




# @src_for_csv = []
# array_of_articles = [(59..59), (290..300)]
array_of_articles = [(334040..334040)]
array_of_articles.each do |range|
  range.each do |product_id|   # art from 59 to ...
    result = get_bardahl_product_data(product_id)
    result_berg = get_berg_bardahl_product_data

    # next if (result[:avail].match('не поставляется') unless result[:avail].nil?)
    # next if (result[:avail].match('снят') unless result[:avail].nil?)

    # title_data = result[:title].split(' ').pop

    # title = 'Свеча зажигания' + result[:title].split(' ')

    # art = result[:art].gsub(/[^0-9]/, ' ').rstrip

    # barcode = barcode_from_product_art(art)

    # price = result[3]

    # purchase_price = get_purchase_price(result[:art])

    store_id = 3   # Avto-Raketa
    # puts result
    puts result_berg

    # if result[:title].nil?
    #   next
    # else
    #   puts result[:title] + '   ' + "#{product_id}", '= = = = = = ='
    # end

      #, result[:art], art, result[:title], barcode, '- - - - - - - -'

    # if result[2].include?(' — ')
    #   data = result[2].partition(' — ')
    #   short_desc = data.last.split
    #   short_desc[-2, 2] = nil
    #   short_desc = short_desc.compact!.join(' ') + '.'
    #   sku_full = "lm_#{data.first.downcase.gsub(/-|[ ]/, '_')}_#{weight}"
    #   title = "Liqui Moly #{data.first} (#{weight} L) (art: #{art})"
    # elsif
    #   result[2].include?(' - ')
    #   data = result[2].partition(' - ')
    #   short_desc = data.last.split
    #   short_desc[-2, 2] = nil
    #   short_desc = short_desc.compact!.join(' ') + '.'
    #   title = "Liqui Moly #{data.first} (#{weight} L) (art: #{art})"
    #   sku_full = "lm_#{data.first.downcase.gsub(/-|[ ]/, '_')}_#{weight}"
    # else
    #   short_desc = ''
    #   title_src = ''
    #   data = result[2].split(' ') unless result[2].nil?
    #   data.each do |word|
    #     if /[А-Яа-я]/.match(word)
    #       short_desc = short_desc + word + ' '
    #     else
    #       /[a-zA-Z]/.match(word)
    #       title_src = title_src + word + ' '
    #     end
    #     sku_full = "lm_#{title_src.downcase.gsub(/-|[ ]/, '_')}_#{weight}"
    #     title = "Liqui Moly #{title_src} (#{weight} L) (art: #{art})"
    #   end
    # end

  #   if short_desc.length > 64
  #     data = short_desc[0..63].split(' ')
  #     data.pop
  #     short_desc = data.join(' ')
  #   end
  #
  #   if sku_full.length > 32
  #       sku_full_part = sku_full.gsub(/_/, ' ').split
  #       sku_full_part_new = sku_full_part.map { |word| word.length >= 10 ? word = word[0..4] : word }
  #       sku_full_part_new = "#{sku_full_part_new.join('_')}"
  #       sku_full = sku_full_part_new
  #
  #       if sku_full_part_new.length > 32
  #           sku_part = sku_full_part_new.gsub(/_/, ' ').split
  #           sku_part_new = sku_part.map { |word| word.length <= 9 && word.length >= 5 ? word = word[0..2] : word }
  #           sku_part_new = "#{sku_part_new.join('_')}"
  #           sku_full = sku_part_new
  #
  #           if sku_part_new.length > 32
  #               sku_part_end = sku_part_new.gsub(/_/, ' ').split
  #               sku_part_end.delete_at(1)
  #               sku_full = "#{sku_part_end.join('_')}"
  #           else
  #             sku_full
  #           end
  #       else
  #         sku_full
  #       end
  #   else
  #     sku_full
  #   end
  #
  #   @src_for_csv << ["#{art}", "#{title}", "#{short_desc}", "#{sku_full}", "#{barcode}", "#{purchase_price}", "#{price}", "#{weight}"]
  #
  #   case
  #   when purchase_price.to_f <= 30
  #     puts "purchase_price too small   #{art}"
  #   when price.to_f <= 30
  #     puts "price too small   #{art}"
  #   when price.to_f < purchase_price.to_f
  #     puts "purchase_price too big   #{art}"
  #   when /[^0-9.,]/.match(purchase_price.to_s)
  #     puts "purchase_price is NAN   #{art}"
  #   when /[^0-9.,]/.match(price.to_s)
  #     puts "price is NAN   #{art}"
  #   when /[^0-9.,]/.match(weight.to_s)
  #     puts "weight is NAN   #{art}"
  #   when weight.to_f > 20
  #     puts "weight > 20    #{art}"
  #   when short_desc.length > 64
  #     puts "short_desc length > 64    #{art}"
  #   when sku_full.length > 32
  #     puts "sku length > 32    #{art}"
  #   end
  #
  end
end
#
# # To add a header, the columns should be written monotonously with the header (each data column separately)
#
# # The method is used once for one file.
# def save_new_file
#   header = ["Art", "Title", "Short description", "SKU", "Barcode", "Purchase price", "Price", "Weight"]
#   CSV.open('Price_Berg.csv', 'w', { encoding: "UTF-8", col_sep: ';', headers: true }) do |csv|
#     csv << header
#     @src_for_csv.sort.each do |row|
#       csv << row
#     end
#   end
# end
# save_new_file

# Read file as individual rows, can translate it into an array (with a header representation) and string (without header representation)
# table.delete('Name') - Remove the column
# table.delete(0) - Remove a row
# def add_new_products
#   table = CSV.read('Price_Berg.csv', { encoding: "UTF-8", col_sep: ';', headers: true })  # Same as CSV.parse(File.read('Price_Berg.csv'))
#   @src_for_csv.sort.each do |row|
#     if table['Art'].include?(row[0])
#       next
#     else
#       table << row
#     end
#   end
#
#   header = ["Art", "Title", "Short description", "SKU", "Barcode", "Purchase price", "Price", "Weight"]
#    CSV.open('Price_Berg.csv', 'w', { encoding: "UTF-8", col_sep: ';', headers: true }) do |csv|
#      csv << header
#      table.each do |row|
#        csv << row
#      end
#    end
#
# # Sorting rows in a file by art
#   data = CSV.read('Price_Berg.csv', { encoding: "UTF-8", col_sep: ';' }).to_a.sort
#   data.pop
#
#   header = ["Art", "Title", "Short description", "SKU", "Barcode", "Purchase price", "Price", "Weight"]
#    CSV.open('Price_Berg.csv', 'w', { encoding: "UTF-8", col_sep: ';', headers: true }) do |csv|
#      csv << header
#      data.each do |row|
#        csv << row
#      end
#    end
# end
# # add_new_products
#
# def add_goods_to_extrapost
# # Read the file as individual columns.
#   CSV.foreach('Price_Berg.csv', { encoding: "UTF-8", col_sep: ';', headers:true }) do |col|   # Same as CSV.parse('Price_Berg.csv') { |row| puts row}
#     art = col[0]
#     if art
#       title = col[1]
#       short_desc = col[2]
#       sku = col[3]
#       barcode = col[4]
#       purchase_price = col[5]
#       price = col[6]
#       weight = col[7]
#       store_id = 3
#       country_of_origin = 'DE'
#       # puts filename, purchase_price, sku, barcode, store_id, price, short_desc, title, weight, '- - - - - - - -'
#     end
#     # create_product(purchase_price, barcode, store_id, price, short_desc, title, weight, image, filename, country_of_origin)
#     put_lm_product_price(purchase_price, barcode, store_id, price, short_desc, title, weight, image, filename, country_of_origin)
#   end
# end
# # add_goods_to_extrapost
