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

array_of_articles_bardahl = [(59..59)] #290..
array_of_articles_bardahl.each do |range|
  range.each do |product_id|   # art from 59 to ...
    result = get_bardahl_product_data(product_id)

    puts title = result[:title]
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
