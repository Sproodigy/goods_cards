  # encoding: utf-8

  require 'simple-spreadsheet'
  require 'http'
  require 'open-uri'
  require 'nokogiri'
  require 'base64'
  require 'json'
  require 'active_support/core_ext/string/access'


  start = Time.now

  def get_purchase_price
  # Also supports csv, csvt and tsv formats
    s = SimpleSpreadsheet::Workbook.read('app/assets/prices/Price_VMPAuto_Samara.xlsx')
    s.selected_sheet = s.sheets[0]
    s.first_row.upto(s.last_row) do |line|
      barcode = s.cell(line, 8).to_i.to_s
      # art_count << barcode
      if barcode.length < 12
        puts "Barcode length < 12"
        next
      end

      if barcode
        sku = barcode
        art = s.cell(line, 1).to_i.to_s
        title = s.cell(line, 2) + " (art: #{art})"
        purch_price = s.cell(line, 3)
        price = s.cell(line, 4)
      end
      puts "Title:   #{title}", "Barcode:   #{barcode}", "Price:   #{price}", "Purch price:   #{purch_price}", '- - - - - - - - - - - - - -'
    end
  end

get_purchase_price

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

  def update_product_extrapost(purch_price, sku, barcode, price, image, title)
    response = HTTP.headers(authorization: "Token e541dfef128f4f93cbdb09b320ea3fb7").put("https://xp.extrapost.ru/api/v1/products/#{barcode}",
                        json: {product: {purchase_price: purch_price,
                                         sku: sku,
                                         barcode: barcode,
                                        #  store_id: store_id,
                                         price: price,
                                        #  description: short_desc,
                                         title: title,
                                        #  weight: weight_num,
                                         image: image
                                        #  image_file_name: filename,
                                        #  country_of_origin: country_of_origin
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

  def update_product_extrastore(sku, old_price, price)
    page = HTTP.headers(authorization: "Token $2a$10$h1Of14AYJkYa5kpiKJTQ7uw/r96shHcgswG/J6rcuaQJAtgFLpjYK").put("http://extrastore.org/api/v1/products/#{sku}",
                       json: {product: { sku: sku,
                                         price: price,
                                        #  description: short_desc,
                                        #  title: title,
                                        #  image: image,
                                        #  image_file_name: filename,
                                        #  long_description: full_desc,
                                        #  store_ids: store_ids,
                                         old_price: old_price
                                        #  yandex_market_export: yandex_market_export
                                        }})
  end

  finish = Time.now
  full_time = (finish - start)
  if full_time >= 3600
    hours = (full_time/3600).round
    min = (full_time/60 - hours*60).round
    sec = (full_time - (min*60 + hours*3600)).round
    puts "#{hours} hours   #{min} min   #{sec} sec"
  elsif full_time >= 60
    min = (full_time/60).round
    sec = (full_time - min*60).round.to_s
    puts "#{min} min   #{sec} sec"
  else
    puts full_time.round.to_s + ' sec'
  end
