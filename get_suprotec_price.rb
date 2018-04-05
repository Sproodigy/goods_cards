# encoding: utf-8
require 'mechanize'
require 'csv'
require 'simple-spreadsheet'
require 'http'
require 'open-uri'
require 'nokogiri'
require 'base64'
require 'json'

def update_product_extrapost(price, purch_price, sku, barcode, weight_num)
  response = HTTP.headers(authorization: "Token e541dfef128f4f93cbdb09b320ea3fb7").put("https://xp.extrapost.ru/api/v1/products/#{barcode}",
                      json: {product: {price: price,
                                       purchase_price: purch_price,
                                       sku: sku,
                                       barcode: barcode,
                                       weight: weight_num
                                      }})
end

def update_product_extrastore(sku, price, old_price)
  page = HTTP.headers(authorization: "Token $2a$10$h1Of14AYJkYa5kpiKJTQ7uw/r96shHcgswG/J6rcuaQJAtgFLpjYK").put("http://extrastore.org/api/v1/products/#{sku}",
                     json: {product: { sku: sku,
                                       price: price,
                                       old_price: old_price
                                      }})
end


  # s = SimpleSpreadsheet::Workbook.read("app/assets/prices/Price_Suprotec_20.xlsx")
  s = SimpleSpreadsheet::Workbook.read("app/assets/prices/Price_Suprotec_10.xlsx")
  s.selected_sheet = s.sheets[0].to_s
  s.first_row.upto(s.last_row) do |line|
    barcode = s.cell(line, 6).to_s.to_i

    if barcode

      sku = barcode
      title = s.cell(line, 1)
      purch_price = s.cell(line, 3)
      old_price = s.cell(line, 4)
      price = s.cell(line, 5)
      weight = s.cell(line, 2)

      if weight.nil?
        next
      else
        weight_num = (weight.split(' ').first.to_f) / 1000
      end

    end
    # puts "Title:   #{title}   Price:   #{price},   Purch_price:   #{purch_price},   SKU:   #{sku},   Barcode:   #{barcode},   Weight_num:   #{weight_num}"
    update_product_extrastore(sku, price, old_price)
    update_product_extrapost(price, purch_price, sku, barcode, weight_num)
  end
