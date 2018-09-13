# encoding: utf-8

# require 'axlsx'   # For create xlsx files
require 'openssl'
require 'roo-xls'
require 'simple-spreadsheet'
# require 'csv'
# require 'uri'
# require 'net/http'
require 'http'
require 'open-uri'
require 'nokogiri'
require 'base64'
require 'json'
require 'active_support/core_ext/string/access'

def get_lm_product_data_liquimoly_ru(product_id)
  ctx = OpenSSL::SSL::SSLContext.new
  ctx.verify_mode = OpenSSL::SSL::VERIFY_NONE
  page = Nokogiri::HTML(HTTP.follow.get("http://liquimoly.ru/item/#{product_id}.html", :ssl_context => ctx).to_s)

  {
    sku: page.css('.card_desc strong').first&.content,

  # Full description
    props: page.css('#tabs-1 p').first,
    apps: page.css('#tabs-2 p').last,

    short_desc: page.css('.fl_f_div h1').first&.content,
    image_path: (page.css('.fl_f_div a.big_img_l.loupe_target').first[:href] unless page.css('.fl_f_div a.big_img_l.loupe_target').first.nil?),
    weight: page.css('.card_desc a').first&.content
  }
end

def get_arts_and_pur_price
  articles = {}
  s = SimpleSpreadsheet::Workbook.read('app/assets/prices/price_lm_12.09.2018.xlsx')
  s.selected_sheet = s.sheets[0]
  s.first_row.upto(s.last_row) do |line|
    art = s.cell(line, 4).to_s
    price_data = s.cell(line, 7).to_f
    purch_price = price_data - (price_data / 10)
    next if art == ''
    next if art.match(/[A-Za-zА-Яа-я]/)

    if art.include?('/')
      art = art.split('/')[1]
      articles[art] = purch_price
    else
      articles[art] = purch_price
    end

  end
  return articles
end

def get_lm_product_image(product_id)
  product_data = get_lm_product_data_liquimoly_ru(product_id)
  src = 'https://liquimoly.ru/' + product_data[:image_path]
  # name = get_lm_product_data(product_id)[2]

  content_type_data = File.extname(src)
  content_type = 'image/' + content_type_data[1,3]
  image_base64_data = Base64.encode64(open(src, {ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE}) { |f| f.read })
  image = "data:#{content_type};base64,#{image_base64_data}"

  {image: image, filename: "#{product_id}#{content_type_data}"}
# Save file in project foldet
  # File.open(@title + '.' + File.extname(src)[1, 3], 'wb') { |f| f.write(open(src).read) }
# Save file to folder on the hard drive
  # IO.copy_stream(open(src), "/home/sproodigy/Foto/Liqui_Moly_#{name}_#{get_lm_product_data(product_id)[1].first(-1)}_#{File.basename(src)}")
  # IO.copy_stream(open(src), "/Users/extra/Documents/Авторакета/LiquiMoly/Фото Liqui Moly/#{@title.gsub(/[\/ ]/, '_') + @content_type_data}")
end

def barcode_from_product_art(product_art)
  if product_art.length == 5

    if product_art.start_with?('25')
      s = "4100420#{product_art}"
      "#{s}#{checkdigit(s)}"
    elsif product_art.start_with?('24')
      s = "4017777#{product_art}"
      "#{s}#{checkdigit(s)}"
    elsif product_art.start_with?('0')
      s = "4606746#{product_art}"
      "#{s}#{checkdigit(s)}"
    else
      s = "4607071#{product_art}"
      "#{s}#{checkdigit(s)}"
    end

  else
    s = "41004200#{product_art}"
    "#{s}#{checkdigit(s)}"
  end
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

 def update_product_extrapost(purch_price, sku, barcode, price)
   response = HTTP.headers(authorization: "Token e541dfef128f4f93cbdb09b320ea3fb7").put("https://xp.extrapost.ru/api/v1/products/#{barcode}",
                       json: {product: {purchase_price: purch_price,
                                        sku: sku,
                                        barcode: barcode,
                                       #  store_id: store_id,
                                        price: price
                                       #  description: short_desc,
                                       #  title: title,
                                       #  weight: weight_num,
                                        # image: image
                                       #  image_file_name: filename,
                                       #  country_of_origin: country_of_origin
                                       }})
 end

 def create_product_extrastore(sku, old_price, price, short_desc, full_desc, title, image, filename, store_ids, yandex_market_export, availability)
   page = HTTP.headers(authorization: "Token $2a$10$h1Of14AYJkYa5kpiKJTQ7uw/r96shHcgswG/J6rcuaQJAtgFLpjYK").post("http://extrastore.org/api/v1/products/",
                      json: {product: { sku: sku,
                                        price: price,
                                        description: short_desc,
                                        title: title,
                                        image: image,
                                        image_file_name: filename,
                                        long_description: full_desc,
                                        store_ids: store_ids,
                                        availability: availability,
                                        old_price: old_price,
                                        yandex_market_export: yandex_market_export
                                       }})
 end

 def update_product_extrastore(sku, price, store_ids, old_price)
   page = HTTP.headers(authorization: "Token $2a$10$h1Of14AYJkYa5kpiKJTQ7uw/r96shHcgswG/J6rcuaQJAtgFLpjYK").put("http://extrastore.org/api/v1/products/#{sku}",
                      json: {product: { sku: sku,
                                        price: price,
                                        # description: short_desc,
                                        # title: title
                                        # image: image,
                                        # image_file_name: filename,
                                        # long_description: full_desc,
                                        store_ids: store_ids,
                                        old_price: old_price
                                        # yandex_market_export: yandex_market_export
                                       }})
 end

# @src_for_csv = []
start = Time.now

get_arts_and_pur_price.each do |product_id, purch_price|

    if product_id.include?('*')
      category_ids = [1338, 1201]
      product_id = product_id.split('*')[0]
    else
      category_ids = [1201]
    end

    result = get_lm_product_data_liquimoly_ru(product_id)
    next if result[:sku].nil?

    if result[:weight].include?('шт')
      weight = ' (' + 0.1.to_s + ' кг)'
      weight_num = 0.1
    else
      weight_data = result[:weight].split(' ')[-2]
      weight = ' (' + weight_data + ' л)'
      weight_num = weight_data
    end

    if /[0-9]-[A-Z]/.match(result[:short_desc])
      data = result[:short_desc].partition(/[0-9]-[A-Z]/)
      short_desc = data[0].to_s.lstrip.rstrip.squeeze(" ") + '.'
      title ='Liqui Moly ' + data[1..data.length].join.squeeze(" ") + ' — ' + data[0].to_s.lstrip.rstrip.squeeze(" ") + weight + " (art: #{product_id})"

      if /[A-Z]/.match(short_desc)
        data_array = short_desc.split
        data_title = data_array.pop
        short_desc = data_array.join(' ') + '.'
        title ='Liqui Moly ' + data_title.gsub(/[.]/, ' ').rstrip + data[1..data.length].join.squeeze(" ") + ' — ' + data_array.join(' ') + weight + " (art: #{product_id})"
      end
    else
      data = result[:short_desc].partition(/[A-Z]/)
      short_desc = data[0].to_s.rstrip.lstrip.squeeze(" ") + '.'
      title = 'Liqui Moly ' + data[1..data.length].join.squeeze(" ") + ' — ' + data[0].to_s.rstrip.lstrip.squeeze(" ") + weight + " (art: #{product_id})"
    end

    image_result = get_lm_product_image(product_id)
    image = image_result[:image]
    filename = image_result[:filename]

    full_desc = '<p><h3>Свойства</h3></p>' + "#{result[:props]}" + '<p><h3>Применение</h3></p>' + "#{result[:apps]}"   # For Extrastore

    barcode = barcode_from_product_art(product_id)

    sku = barcode

  # For Extrapost
    store_id = 3   # AvtoRaketa in Extrapost
    if product_id
      purch_price = purch_price.to_f
    end
    next if purch_price <= 30
  # # # # #

  # For Extrastore
    price = (purch_price * 1.34).round
    old_price = (purch_price * 1.49).round
    country_of_origin = 'DE'
    store_ids = [100]   # AvtoRaketa in Extrastore
    availability = 'on_demand'
    yandex_market_export = true

    if short_desc.length > 64
      data = short_desc[0..63].split(' ')
      data.pop
      short_desc = data.join(' ').rstrip + '.'
    end

    if title.downcase.include?('marine')
      category_ids = [1282, 1201]
    elsif title.downcase.include?('pro-')
      category_ids = [1283, 1201]
    end
  # # # # #

    # puts result[:image_path], image, '- - - - - - -'

    # create_product_extrapost(purch_price, sku, barcode, store_id, price, short_desc, title, weight_num, image, filename, country_of_origin)
    # update_product_extrapost(purch_price, sku, barcode, price)
    # create_product_extrastore(sku, old_price, price, short_desc, full_desc, title, image, filename, store_ids, yandex_market_export, availability)
    # update_product_extrastore(sku, price, store_ids, old_price)

    puts "Weight:       #{weight}", "Title:         #{title}", "Barcode:       #{barcode}", "Old price:     #{old_price} руб.",
         "Price:         #{price} руб.", "Purch price:   #{purch_price} руб.", "Art:           #{product_id}",
         "Short_desc:    #{short_desc}", "Full_desc:     #{full_desc}", "Cat_ids:   #{category_ids}", '- - - - - - - - - - - - - -'

    case
      when short_desc.length > 64
        puts "short_desc length > 64    #{product_id}"
      when /[^0-9]/.match(barcode)
        puts "barcode is NAN   #{product_id}"
      when barcode.length > 13
        puts "barcode too big   #{product_id}"
      when purch_price.to_f <= 30
        puts "purchase_price too small   #{product_id}"
      when price.to_f <= 30
        puts "price too small   #{product_id}"
      when price.to_f < purch_price.to_f
        puts "purchase_price too big   #{product_id}"
      when /[^0-9.,]/.match(purch_price.to_s)
        puts "purchase_price is NAN   #{product_id}"
      when /[^0-9.,]/.match(price.to_s)
        puts "price is NAN   #{product_id}"
      when short_desc.length > 64
        puts "sku > 32   #{product_id}"
    end
  end

puts 'Number of goods:   ' + get_arts_and_pur_price.length.to_s
finish = Time.now
full_time = (finish - start)
if full_time >= 3600
  hours = (full_time / 3600).floor
  min = (full_time / 60 - hours * 60).floor
  sec = (full_time - (min * 60 + hours * 3600))
  puts "#{hours} hours   #{min} min   #{sec} sec"
elsif full_time >= 60
  min = (full_time / 60).floor
  sec = (full_time - min * 60).floor
  puts "#{min} min   #{sec} sec"
else
  puts full_time.round.to_s + ' sec'
end

# # To add a header, the columns should be written monotonously with the header (each data column separately)
#
# # The method is used once for one file.
# def save_new_file
#   header = ["Art", "Title", "Short description", "SKU", "Barcode", "Purchase price", "Price", "Weight", "Full_desc"]
#   CSV.open('Price_LM.csv', 'w', { encoding: "UTF-8", col_sep: ';', headers: true }) do |csv|
#     csv << header
#     @src_for_csv.sort.each do |row|
#       csv << row
#     end
#   end
# end
# # save_new_file
#
# # Read file as individual rows, can translate it into an array (with a header representation) and string (without header representation)
# # table.delete('Name') - Remove the column
# # table.delete(0) - Remove a row
# def add_new_products
#   table = CSV.read('Price_LM.csv', { encoding: "UTF-8", col_sep: ';', headers: true })  # Same as CSV.parse(File.read('Price_LM.csv'))
#   @src_for_csv.sort.each do |row|
#     if table['Art'].include?(row[0])
#       next
#     else
#       table << row
#     end
#   end
#
#   header = ["Art", "Title", "Short description", "SKU", "Barcode", "Purchase price", "Price", "Weight", "Full_desc"]
#    CSV.open('Price_LM.csv', 'w', { encoding: "UTF-8", col_sep: ';', headers: true }) do |csv|
#      csv << header
#      table.each do |row|
#        csv << row
#      end
#    end
#
# # Sorting rows in a file by art
#   data = CSV.read('Price_LM.csv', { encoding: "UTF-8", col_sep: ';' }).to_a.sort
#   data.pop
#
#   header = ["Art", "Title", "Short description", "SKU", "Barcode", "Purchase price", "Price", "Weight", "Full_desc"]
#    CSV.open('Price_LM.csv', 'w', { encoding: "UTF-8", col_sep: ';', headers: true }) do |csv|
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
#   CSV.foreach('Price_LM.csv', { encoding: "UTF-8", col_sep: ';', headers:true }) do |col|   # Same as CSV.parse('Price_LM.csv') { |row| puts row}
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
#     filename = title + @content_type_data
#     image = @image
#     # create_product_extrapost(purchase_price, barcode, store_id, price, short_desc, title, weight, image, filename, country_of_origin)
#     update_product_extrapost(purchase_price, barcode, store_id, price, short_desc, title, weight, image, filename, country_of_origin)
#   end
# end
# # add_goods_to_extrapost
#
# def add_goods_to_extrastore
# # Read the file as individual columns.
#   CSV.foreach('Price_LM.csv', { encoding: "UTF-8", col_sep: ';', headers:true }) do |col|   # Same as CSV.parse('Price_LM.csv') { |row| puts row}
#     art = col[0]
#     if art
#       title = col[1]
#       short_desc = col[2]
#       sku = col[3]
#       price = col[6]
#       full_desc = col[8]
#       store_ids = [100]
#       filename = title + @content_type_data
#       image = @image
#       puts filename, sku, price, short_desc, title, '- - - - - - - -'
#     end
#     create_product_extrastore(sku, price, short_desc, title, image, filename, full_desc, store_ids)
#   end
# end
# # add_goods_to_extrastore
