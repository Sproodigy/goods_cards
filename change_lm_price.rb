# encoding: utf-8

require 'simple-spreadsheet'
require 'http'
require 'open-uri'
require 'nokogiri'
require 'base64'
require 'json'
require 'active_support/core_ext/string/access'


start = Time.now

def update_product_extrapost(purch_price, sku, barcode, price)
  response = HTTP.headers(authorization: "Token e541dfef128f4f93cbdb09b320ea3fb7").put("https://xp.extrapost.ru/api/v1/products/#{barcode}",
                      json: {product: {purchase_price: purch_price,
                                       sku: sku,
                                       barcode: barcode,
                                      #  store_id: store_id,
                                       price: price,
                                      #  description: short_desc,
                                      #  title: title,
                                      #  weight: weight_num,
                                       # image: image
                                      #  image_file_name: filename,
                                      #  country_of_origin: country_of_origin
                                      }})
end

def update_product_extrastore(sku, old_price, price)
  page = HTTP.headers(authorization: "Token $2a$10$h1Of14AYJkYa5kpiKJTQ7uw/r96shHcgswG/J6rcuaQJAtgFLpjYK").put("http://extrastore.org/api/v1/products/#{sku}",
                     json: {product: { sku: sku,

                                      #  description: short_desc,
                                      #  title: title,
                                      #  image: image,
                                      #  image_file_name: filename,
                                      #  long_description: full_desc,
                                      #  store_ids: store_ids,
                                       old_price: old_price,
                                       price: price
                                      #  yandex_market_export: yandex_market_export
                                      }})
end


  def barcode_from_product_art(product_art)
    if product_art.length == 5

      if product_art.start_with?('25')
        # || product_art.start_with?('24') ||
        #  product_art.start_with?('20') || product_art.start_with?('29')
        s = "4100420#{product_art}"
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


  # Also supports csv, csvt and tsv formats
    s = SimpleSpreadsheet::Workbook.read('app/assets/prices/Price_LM_02_04_2018.xlsx')
    s.selected_sheet = s.sheets[0]
    art_count = []
    s.first_row.upto(s.last_row) do |line|
      art = s.cell(line, 4).to_s
      next if art == ''
      next if art.match(/[A-Za-zА-Яа-я]/)
      next if art.include?('*')

      if art.include?('/')
        art = art.split('/')[0]
      end
      art_count << art

      if art
        purch_price = s.cell(line, 8).to_f
      end

      price = (purch_price * 1.33).round
      old_price = (purch_price * 1.48).round

      barcode = barcode_from_product_art(art)
      sku = barcode
      store_id = '3'
      store_ids = [100]

      puts "Art:   #{art}", "Barcode:   #{barcode}", "Purchase price:   #{purch_price}",
           "Old price:   #{old_price}", "Price:   #{price}", '- - - - - - - - - - -'

      # update_product_extrapost(purch_price, sku, barcode, price)
      # update_product_extrapost(sku, old_price, price)

      case
      when /[^0-9]/.match(barcode)
        puts "barcode is NAN   #{art}"
      when barcode.length > 13
        puts "barcode too big   #{art}"
      when art.include?('*')
        puts "product is not available for order   #{art}"
      when purch_price.to_f <= 30
        puts "purchase_price too small   #{art}"
      when price.to_f <= 30
        puts "price too small   #{art}"
      when price.to_f < purch_price.to_f
        puts "purchase_price too big   #{art}"
      when /[^0-9.,]/.match(purch_price.to_s)
        puts "purchase_price is NAN   #{art}"
      when /[^0-9.,]/.match(price.to_s)
        puts "price is NAN   #{art}"
      # when short_desc.length > 64
      #   puts "sku > 32   #{art}"
      end
    end

    puts 'Number of goods:   ' + "#{art_count.size}"
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

    puts "Full time:   #{full_time}"
