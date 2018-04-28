# encoding: utf-8

require 'openssl'
require 'roo-xls'
require 'simple-spreadsheet'
require 'http'
require 'open-uri'
require 'nokogiri'
require 'base64'
require 'json'
require 'active_support/core_ext/string/access'

def get_mafra_product_data(page)
  ctx = OpenSSL::SSL::SSLContext.new
  ctx.verify_mode = OpenSSL::SSL::VERIFY_NONE
  page_data = Nokogiri::HTML(HTTP.get("http://www.mafrarussia.ru/?page_id=#{page}", :ssl_context => ctx).to_s)

  {
    page_response: page_data.css('h1').text,
    availability: page_data.css('.two-thirds p a').last&.content,
    title: page_data.css('.headline strong').first&.content,
    desc1: page_data.css('.two-thirds h1').last.to_s + "\n<p></p>\n" +
           page_data.css('.two-thirds p')[1].to_s + "\n<p></p>\n" +
           page_data.css('.two-thirds h3')[0].to_s + "\n<p></p>\n" +
           page_data.css('.two-thirds p')[2].to_s + "\n<p></p>\n" +
           page_data.css('.two-thirds h3')[1].to_s + "\n<p></p>\n" +
           page_data.css('.two-thirds p')[3].to_s,
    short_desc2: page_data.css('.two-thirds'),
    desc2: page_data.css('.two-thirds .half-page h1').first.to_s + "\n<p></p>\n" +
           page_data.css('.two-thirds .half-page p')[0].to_s + "\n<p></p>\n" +
           page_data.css('.two-thirds .half-page h3')[0].to_s + "\n<p></p>\n" +
           page_data.css('.two-thirds .half-page p')[1].to_s + "\n<p></p>\n" +
           page_data.css('.two-thirds .half-page h3')[1].to_s + "\n<p></p>\n" +
           page_data.css('.two-thirds .half-page p')[2].to_s,
    sku_weight_img_data1: page_data.css('.two-thirds .one-third').to_a,
    sku_weight_img_data2: page_data.css('.two-thirds').to_a
  }
end

def get_art_pur_price_and_barcode
  articles = {}
  s = SimpleSpreadsheet::Workbook.read('app/assets/prices/Price_Mafra_20_04_18.xlsx')
  s.selected_sheet = s.sheets[0]
  s.first_row.upto(s.last_row) do |line|
    art = s.cell(line, 2).to_s
    purch_price = s.cell(line, 5).to_f
    price = s.cell(line, 7).to_f
    barcode = s.cell(line, 8).to_s

    next if art == ''
    next if art.match(/[А-Яа-я]/)
    if art.include?('/')
      next if art == 'KT012/*'
      art_arr = art.split('/').each do |art|
        articles[art] = {purch_price: purch_price, price: price, barcode: barcode}
      end
    else
      articles[art] = {purch_price: purch_price, price: price, barcode: barcode}
    end
  end

  return articles
end

def create_product_extrastore(sku, price, old_price, title, short_desc, full_desc, image, filename, store_ids, category_ids, availability, yandex_market_export)
  page = HTTP.headers(authorization: "Token $2a$10$h1Of14AYJkYa5kpiKJTQ7uw/r96shHcgswG/J6rcuaQJAtgFLpjYK").post("http://extrastore.org/api/v1/products/",
                     json: {product: { sku: sku,
                                       price: price,
                                       old_price: old_price,
                                       title: title,
                                       description: short_desc,
                                       long_description: full_desc,
                                       image: image,
                                       image_file_name: filename,
                                       store_ids: store_ids,
                                       category_ids: category_ids,
                                       availability: availability,
                                       yandex_market_export: yandex_market_export
                                      }})
end

def update_product_extrastore(sku, price, store_ids, old_price)
  create_product_extrapost(purch_price, sku, barcode, store_id, price, short_desc, title, weight_num, image, filename, country_of_origin)
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

start = Time.now
goods = []
# [(626..634), (3238..3238), (3407..3407), (3522..4169)].each do |range|
[(3893..3893)].each do |range|
  range.each do |page_id|
    source = get_mafra_product_data(page_id)

    if source[:page_response] == '404'
      puts "Page:   #{page_id} not exist", '-----------------------'
    elsif source[:availability] == 'НЕТ В НАЛИЧИИ'
      puts "Page:   #{page_id} #{source[:availability]}", '-----------------------'
    else
      puts "Page:   #{page_id}"
    end

    next if source[:sku_weight_img_data1].nil? && source[:sku_weight_img_data2].nil?
    # puts "Data 1:     #{source[:sku_weight_img_data1]}", '======================', "Data 2:     #{source[:sku_weight_img_data2]}", '[[[[[[[[[[[[[[[[[[[]]]]]]]]]]]]]]]]]]]'

    if source[:sku_weight_img_data1].length == 0
      source[:sku_weight_img_data2].each do |data|

        sku = data.css('strong').last&.content

        if sku.include?('/')
          sku_arr = sku.split('/').each do |art|
            sku = art

            if sku.nil? || get_art_pur_price_and_barcode[sku].nil?
              puts "Page:   #{page_id} SKU not exist", '------------------------'
              next
            end

            barcode = get_art_pur_price_and_barcode[sku][:barcode]
            if barcode == ''
              barcode = sku
            end

            purch_price = get_art_pur_price_and_barcode[sku][:purch_price]
            if purch_price == 0.0
              puts 'Purchase price:   0.0', '------------------------'
              next
            end
            price = get_art_pur_price_and_barcode[sku][:price]

            goods.push(sku)

            if data.text.include?('Упаковка')
              weight = data.text.split('Упаковка')[1].partition('.')[0].lstrip.gsub(/,/, '.').gsub(/кг/, 'kg').gsub(/г/, 'gr')
              if weight.include?('gr')
                weight_num = (weight.gsub(/[^\d]/, '').to_f) / 1000
              else
                weight_num = weight.gsub(/[^\d]/, '')
              end
            elsif data.text.include?('Канистра')
              weight = data.text.split('Канистра')[1].partition('.')[0].lstrip.gsub(/,/, '.').gsub(/кг/, 'kg').gsub(/г/, 'gr')
              if weight.include?('gr')
                weight_num = (weight.gsub(/[^\d]/, '').to_f) / 1000
              else
                weight_num = weight.gsub(/[^\d]/, '')
              end
            else
              weight = '0.1 kg'
              weight_num = 0.1
            end
            if weight.include?('шт')
              weight = '0.1 kg'
              weight_num = 0.1
            end

            title = "Mafra #{source[:title]} (art: #{sku}) (#{(weight)})"
            short_desc_data = data.css('p')[1].text
            if short_desc_data.length > 64
              short_desc = short_desc_data[0..64].split(' ')
              short_desc.pop
              short_desc = short_desc.join(' ') + '.'
            else
              short_desc = short_desc_data
            end
            full_desc = source[:desc2]

            image_src = data.css('img').first[:src]
            content_type_data = File.extname(image_src)
            content_type = 'image/' + content_type_data[1,3]
            image_base64_data = Base64.encode64(open(image_src, {ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE}) { |f| f.read })
            image = "data:#{content_type};base64,#{image_base64_data}"
            filename = "#{page_id}#{content_type_data}"

          # For Extrastore
            country_of_origin = 'IT'
            store_id = 3   # AvtoRaketa in Extrapost
          # # # # #

          # For Extrastore
            old_price = (purch_price * 1.7).round
            store_ids = [100]   # AvtoRaketa in Extrastore
            category_ids = [1339]
            availability = 'on_demand'
            yandex_market_export = true
         # # # # #

            puts "Barcode:   #{barcode}", "Purch price:   #{purch_price}", "Price:   #{price}",
                 "Title:   #{title}", "Short_desc:  #{short_desc}", "SKU:   #{sku}",
                 "Weight:   #{weight}", "Description:   \n#{full_desc}", '= = = = ='
            # create_product_extrastore(sku, price, old_price, title, short_desc, full_desc, image, filename, store_ids, category_ids, availability, yandex_market_export)
            # update_product_extrastore(sku, price, store_ids, old_price)
            # create_product_extrapost(purch_price, sku, barcode, store_id, price, short_desc, title, weight_num, image, filename, country_of_origin)
          end
        else
          sku = sku

          if sku.nil? || get_art_pur_price_and_barcode[sku].nil?
            puts "Page:   #{page_id} SKU not exist", '------------------------'
            next
          end

          barcode = get_art_pur_price_and_barcode[sku][:barcode]
          if barcode == ''
            barcode = sku
          end

          purch_price = get_art_pur_price_and_barcode[sku][:purch_price]
          if purch_price == 0.0
            puts 'Purchase price:   0.0', '------------------------'
            next
          end
          price = get_art_pur_price_and_barcode[sku][:price]

          goods.push(sku)

          if data.text.include?('Упаковка')
            weight = data.text.split('Упаковка')[1].partition('.')[0].lstrip.gsub(/,/, '.').gsub(/кг/, 'kg').gsub(/г/, 'gr')
            if weight.include?('gr')
              weight_num = (weight.gsub(/[^\d]/, '').to_f) / 1000
            else
              weight_num = weight.gsub(/[^\d]/, '')
            end
          elsif data.text.include?('Канистра')
            weight = data.text.split('Канистра')[1].partition('.')[0].lstrip.gsub(/,/, '.').gsub(/кг/, 'kg').gsub(/г/, 'gr')
            if weight.include?('gr')
              weight_num = (weight.gsub(/[^\d]/, '').to_f) / 1000
            else
              weight_num = weight.gsub(/[^\d]/, '')
            end
          else
            weight = '0.1 kg'
            weight_num = 0.1
          end
          if weight.include?('шт')
            weight = '0.1 kg'
            weight_num = 0.1
          end

          title = "Mafra #{source[:title]} (art: #{sku}) (#{(weight)})"
          short_desc_data = data.css('p')[1].text
          if short_desc_data.length > 64
            short_desc = short_desc_data[0..64].split(' ')
            short_desc.pop
            short_desc = short_desc.join(' ') + '.'
          else
            short_desc = short_desc_data
          end
          full_desc = source[:desc2]

          image_src = data.css('img').first[:src]
          content_type_data = File.extname(image_src)
          content_type = 'image/' + content_type_data[1,3]
          image_base64_data = Base64.encode64(open(image_src, {ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE}) { |f| f.read })
          image = "data:#{content_type};base64,#{image_base64_data}"
          filename = "#{page_id}#{content_type_data}"

        # For Extrastore
          country_of_origin = 'IT'
          store_id = 3   # AvtoRaketa in Extrapost
        # # # # #

        # For Extrastore
          old_price = (purch_price * 1.7).round
          store_ids = [100]   # AvtoRaketa in Extrastore
          category_ids = [1339]
          availability = 'on_demand'
          yandex_market_export = true
        # # # # #

          puts "Barcode:   #{barcode}", "Purch price:   #{purch_price}", "Price:   #{price}",
               "Title:   #{title}", "Short_desc:  #{short_desc}", "SKU:   #{sku}",
               "Weight:   #{weight}", "Weight number:   #{weight_num}", "Description:   \n#{full_desc}", '= = = = ='
          # create_product_extrastore(sku, price, old_price, title, short_desc, full_desc, image, filename, store_ids, category_ids, availability, yandex_market_export)
          # update_product_extrastore(sku, price, store_ids, old_price)
          # create_product_extrapost(purch_price, sku, barcode, store_id, price, short_desc, title, weight_num, image, filename, country_of_origin)
        end
      end
    else
      source[:sku_weight_img_data1].each do |data|

        sku = data.css('strong').last&.content
        if sku.include?('/')
          sku_arr = sku.split('/').each do |art|
            sku = art

            if sku.nil? || get_art_pur_price_and_barcode[sku].nil?
              puts "Page:   #{page_id} SKU not exist", '------------------------'
              next
            end

            barcode = get_art_pur_price_and_barcode[sku][:barcode]
            if barcode == ''
              barcode = sku
            end

            purch_price = get_art_pur_price_and_barcode[sku][:purch_price]
            if purch_price == 0.0
              puts 'Purchase price:   0.0', '-----------------------'
              next
            end
            price = get_art_pur_price_and_barcode[sku][:price]

            goods.push(sku)

            if data.text.include?('Упаковка')
              weight = data.text.split('Упаковка')[1].partition('.')[0].lstrip.gsub(/,/, '.').gsub(/кг/, 'kg').gsub(/г/, 'gr')
              if weight.include?('gr')
                weight_num = (weight.gsub(/[^\d]/, '').to_f) / 1000
              else
                weight_num = weight.gsub(/[^\d]/, '')
              end
            elsif data.text.include?('Канистра')
              weight = data.text.split('Канистра')[1].partition('.')[0].lstrip.gsub(/,/, '.').gsub(/кг/, 'kg').gsub(/г/, 'gr')
              if weight.include?('gr')
                weight_num = (weight.gsub(/[^\d]/, '').to_f) / 1000
              else
                weight_num = weight.gsub(/[^\d]/, '')
              end
            else
              weight = '0.1 kg'
              weight_num = 0.1
            end
            if weight.include?('шт')
              weight = '0.1 kg'
              weight_num = 0.1
            end

            title = "Mafra #{source[:title]} (art: #{sku}) (#{(weight)})"
            short_desc_data = source[:short_desc2].css('p')[1].text
            if short_desc_data.length > 64
              short_desc = short_desc_data[0..64].split(' ')
              short_desc.pop
              short_desc = short_desc.join(' ') + '.'
            else
              short_desc = short_desc_data
            end
            full_desc = source[:desc1]

            image_src = data.css('img').first[:src]
            content_type_data = File.extname(image_src)
            content_type = 'image/' + content_type_data[1,3]
            image_base64_data = Base64.encode64(open(image_src, {ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE}) { |f| f.read })
            image = "data:#{content_type};base64,#{image_base64_data}"
            filename = "#{page_id}#{content_type_data}"

          # For Extrastore
            country_of_origin = 'IT'
            store_id = 3   # AvtoRaketa in Extrapost
          # # # # #

          # For Extrastore
            old_price = (purch_price * 1.7).round
            country_of_origin = 'IT'
            store_ids = [100]   # AvtoRaketa in Extrastore
            category_ids = [1339]
            availability = 'on_demand'
            yandex_market_export = true
          # # # # #

            puts "Barcode:   #{barcode}", "Purch price:   #{purch_price}", "Price:   #{price}",
                 "Title:   #{title}", "Short_desc:  #{short_desc}", "SKU:   #{sku}",
                 "Weight:   #{weight}", "Description:   \n#{full_desc}", '= = = = ='
            # create_product_extrastore(sku, price, old_price, title, short_desc, full_desc, image, filename, store_ids, category_ids, availability, yandex_market_export)
            # update_product_extrastore(sku, price, store_ids, old_price)
            # create_product_extrapost(purch_price, sku, barcode, store_id, price, short_desc, title, weight_num, image, filename, country_of_origin)
          end
        else
          sku = sku

          if sku.nil? || get_art_pur_price_and_barcode[sku].nil?
            puts "Page:   #{page_id} SKU not exist", '------------------------'
            next
          end

          barcode = get_art_pur_price_and_barcode[sku][:barcode]
          if barcode == ''
            barcode = sku
          end

          purch_price = get_art_pur_price_and_barcode[sku][:purch_price]
          if purch_price == 0.0
            puts 'Purchase price:   0.0', '-----------------------'
            next
          end
          price = get_art_pur_price_and_barcode[sku][:price]

          goods.push(sku)

          if data.text.include?('Упаковка')
            weight = data.text.split('Упаковка')[1].partition('.')[0].lstrip.gsub(/,/, '.').gsub(/кг/, 'kg').gsub(/г/, 'gr')
            if weight.include?('gr')
              weight_num = (weight.gsub(/[^\d]/, '').rstrip.to_f) / 1000
            else
              weight_num = weight.gsub(/[^\d]/, '')
            end
          elsif data.text.include?('Канистра')
            weight = data.text.split('Канистра')[1].partition('.')[0].lstrip.gsub(/,/, '.').gsub(/кг/, 'kg').gsub(/г/, 'gr')
            if weight.include?('gr')
              weight_num = (weight.gsub(/[^\d]/, '').to_f) / 1000
            else
              weight_num = weight.gsub(/[^\d]/, '')
            end
          else
            weight = '0.1 kg'
            weight_num = 0.1
          end
          if weight.include?('шт')
            weight = '0.1 kg'
            weight_num = 0.1
          end

          title = "Mafra #{source[:title]} (art: #{sku}) (#{(weight)})"
          short_desc_data = source[:short_desc2].css('p')[1].text
          if short_desc_data.length > 64
            short_desc = short_desc_data[0..64].split(' ')
            short_desc.pop
            short_desc = short_desc.join(' ') + '.'
          else
            short_desc = short_desc_data
          end
          full_desc = source[:desc1]

          image_src = data.css('img').first[:src]
          content_type_data = File.extname(image_src)
          content_type = 'image/' + content_type_data[1,3]
          image_base64_data = Base64.encode64(open(image_src, {ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE}) { |f| f.read })
          image = "data:#{content_type};base64,#{image_base64_data}"
          filename = "#{page_id}#{content_type_data}"

        # For Extrastore
          country_of_origin = 'IT'
          store_id = 3   # AvtoRaketa in Extrapost
        # # # # #

        # For Extrastore
          old_price = (purch_price * 1.7).round
          country_of_origin = 'IT'
          store_ids = [100]   # AvtoRaketa in Extrastore
          category_ids = [1339]
          availability = 'on_demand'
          yandex_market_export = true
        # # # # #

          puts "Barcode:   #{barcode}", "Purch price:   #{purch_price}", "Price:   #{price}",
               "Title:   #{title}", "Short_desc:  #{short_desc}", "SKU:   #{sku}",
               "Weight:   #{weight}", "Weight number:   #{weight_num}", "Description:   \n#{full_desc}", '= = = = ='
          # create_product_extrastore(sku, price, old_price, title, short_desc, full_desc, image, filename, store_ids, category_ids, availability, yandex_market_export)
          # update_product_extrastore(sku, price, store_ids, old_price)
          # create_product_extrapost(purch_price, sku, barcode, store_id, price, short_desc, title, weight_num, image, filename, country_of_origin)
        end
      end
    end
  end
end

puts 'Number of goods:   ' + goods.length.to_s
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
