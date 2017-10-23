# encoding: utf-8

# require 'axlsx'   # For create xlsx files
require 'rubyXL'
require 'roo-xls'
require 'simple-spreadsheet'
# require 'simple-xls'
require 'csv'
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
    title: page.css('.two-thirds h1.headline strong').first&.content&.to_s,
    image_path: (page.css('.two-thirds img').first[:src] unless page.css('.two-thirds img').first.nil?),
    full_desc: page.css('.half-page').first
  }
end

def get_berg_bardahl_product_data(product_id)
  page = Nokogiri::HTML(HTTP.follow.get("https://berg.ru/search/step2?search=#{product_id}&brand=BARDAHL").to_s)

  {
    # short_desc: page.css('.search__description_cart h1').first&.content.gsub(/[^А-Яа-я]/, ' ').rstrip + '.',
    # avail: (page.css('.additional_info .value_col')[4].content.to_s unless page.css('.additional_info .value_col')[4].nil?)
    price: page.css('.search_card__table_col td.price_col').first&.content
  }
end

def get_bardahl_product_image(product_id)

  src = get_bardahl_product_data(product_id)[:image_path]

  content_type_data = File.extname(src)
  content_type = 'image/' + content_type_data[1, 3]
  image_base64_data = Base64.encode64(open(src) { |f| f.read })
  image = "data:#{content_type};base64,#{image_base64_data}"

  {image: image, filename: "#{product_id}.#{content_type_data[1, 3]}"}
end


def barcode_from_product_art(product_art)
  s = "32667200#{product_art}"
  "#{s}#{checkdigit(s)}"
end

def checkdigit(barcode)
  evens, odds = *barcode.scan(/\d/).map { |d| d.to_i }.partition.with_index { |d, i| (i&1).zero? }
  (10 - ((odds.reduce(:+)) * 3 + evens.reduce(:+)) % 10) % 10
end

                           # sku пока использовать только при создании новых товаров.

def create_product_extrapost(purch_price, sku, barcode, store_id, price, short_desc, title, weight_num, image, filename, country_of_origin)
 page = HTTP.headers(authorization: "Token e541dfef128f4f93cbdb09b320ea3fb7").post("https://xp.extrapost.ru/api/v1/products/",
                    json: {product: { purchase_price: purch_price,
                                      sku: sku,
                                      barcode: barcode,
                                      store_id: store_id,
                                      price: price,
                                      description: short_desc,
                                      title: title,
                                      weight: weight_num,
                                      image: image,
                                      image_file_name: filename,
                                      country_of_origin: country_of_origin
                                     }})
end

def update_product_extrapost(purch_price, sku, barcode, store_id, price, short_desc, title, weight_num, image, filename, country_of_origin)
 response = HTTP.headers(authorization: "Token e541dfef128f4f93cbdb09b320ea3fb7").put("https://xp.extrapost.ru/api/v1/products/#{barcode}",
                     json: {product: {purchase_price: purch_price,
                                      sku: sku,
                                      barcode: barcode,
                                      store_id: store_id,
                                      price: price,
                                      description: short_desc,
                                      title: title,
                                      weight: weight_num,
                                      image: image,
                                      image_file_name: filename,
                                      country_of_origin: country_of_origin
                                     }})
end

def create_product_extrastore(sku, old_price, price, short_desc, full_desc, title, image, filename, category_ids, store_ids, yandex_market_export, availability)
 page = HTTP.headers(authorization: "Token $2a$10$h1Of14AYJkYa5kpiKJTQ7uw/r96shHcgswG/J6rcuaQJAtgFLpjYK").post("http://extrastore.org/api/v1/products/",
                    json: {product: { sku: sku,
                                      price: price,
                                      description: short_desc,
                                      title: title,
                                      image: image,
                                      image_file_name: filename,
                                      long_description: full_desc,
                                      store_ids: store_ids,
                                      category_ids: category_ids,
                                      availability: availability,
                                      old_price: old_price,
                                      yandex_market_export: yandex_market_export
                                     }})
end

def update_product_extrastore(sku, old_price, price, short_desc, full_desc, title, image, filename, store_ids, yandex_market_export)
 page = HTTP.headers(authorization: "Token $2a$10$h1Of14AYJkYa5kpiKJTQ7uw/r96shHcgswG/J6rcuaQJAtgFLpjYK").put("http://extrastore.org/api/v1/products/#{sku}",
                    json: {product: { sku: sku,
                                      price: price,
                                      description: short_desc,
                                      title: title,
                                      image: image,
                                      image_file_name: filename,
                                      long_description: full_desc,
                                      store_ids: store_ids,
                                      old_price: old_price,
                                      yandex_market_export: yandex_market_export
                                     }})
end

array_of_art_bard_berg = []
(1210..1220).each do |product_id|

  result = get_berg_bardahl_product_data(product_id)


  next if (result[:avail].match('не поставляется') unless result[:avail].nil?)
  next if (result[:avail].match('снят') unless result[:avail].nil?)

  art = product_id


  short_desc = result[:short_desc]

  next if result[:price].nil?
  purch_price = (result[:price].sub(/,/, '.').to_f * 51.5).round(2)
  price = (purch_price * 1.2).floor

  puts barcode = barcode_from_product_art(art)

  sku = barcode

  array_of_art_bard_berg << art unless barcode.nil?
end
puts array_of_art_bard_berg

array_of_articles_bardahl = [(59..59)] #290..
array_of_articles_bardahl.each do |range|
  range.each do |product_id|   # art from 59 to ...
    result = get_bardahl_product_data(product_id)

    title = result[:title]
    full_desc = result[:full_desc]

    image_result = get_bardahl_product_image(product_id)
    image = image_result[:image]
    filename = image_result[:filename]

    store_ids = [100]   # Avto-Raketa in Extrastore

    availability = 'on_demand'   # For Extrastore

    yandex_market_export = true   # For Extrastore

    store_id = 3   # Avto-Raketa in Extrastore

    # price = result[3]

    # purchase_price = get_purchase_price(result[:art])

    # if result[:title].nil?
    #   next
    # else
    #   puts result[:full_desc], result[:title] + '   ' + "#{product_id}", '= = = = = = ='
    # end

      # puts result[:art], art, result[:title], barcode, '- - - - - - - -'
  end
end



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
