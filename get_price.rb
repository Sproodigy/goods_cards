require 'rubyXL'
require 'roo-xls'
require 'simple-spreadsheet'
# require 'simple-xls'
# require 'httparty'
# require 'pry'
# require 'csv'
# require 'uri'
# require 'net/http'
# require 'http'
require 'open-uri'
require 'nokogiri'
require 'base64'
require 'json'
require 'active_support/core_ext/string/access'

# file = File.open("app/assets/prices/Price_LM_10.05.2017.xlsx")
# puts file
# workbook = RubyXL::Parser.parse('app/assets/prices/Price_LM_10.05.2017.xlsx') # ("path/to/Excel/file.xlsx")
# puts workbook

s = SimpleSpreadsheet::Workbook.read('app/assets/prices/Price_LM_10.05.2017.xlsx')
s.selected_sheet = s.sheets.first
s.first_row.upto(s.last_row) do |line|
  data = s.cell(line, 2)
  puts data
end

# def get_purchase_price
#   response = HTTP.follow.get('https://docs.google.com/spreadsheets/d/1oEZHsE-Wb3W4RLWu1Hewm9Xj4hj6_6eQ_NtbJCdwFUc/gviz/tq?tqx=out:csv&sheet=OrderLiquiMolySamara011116(13)')
#   response_price = HTTP.follow.get('https://docs.google.com/spreadsheets/d/1r-nchqB-LELEDhDz79s5yNJCAox8W2vo8Uo-E8H9Lio/gviz/tq?tqx=out:csv&sheet=1')
#   csv = CSV.parse(response.to_s)
#   price = CSV.parse(response_price.to_s)
#   puts price
# end

def get_lm_product_data(product_id)
  # Load page html and parse it with Nokogiri
  page = Nokogiri::HTML(HTTP.follow.get("http://www.lm-shop.ru/index.php?route=product/product&product_id=#{product_id}").to_s)

  # Select html element from page and print it
  [
    # Art (0)
    page.css('#tab-attribute > table.attribute > tbody > tr:nth-last-child(2) > td:nth-child(2)').first&.content,
    # Full description (1)
    page.css('.product-description').first&.content,
    # Name, short decription and volume (2)
    page.css('.product-info h1').first&.content.partition(' — '),
    # Price (3)
    page.css('.product-info span.price-new').first&.content&.gsub(/[^0-9\.]/, '')&.to_f,
    # Source for image (4)
    page.css('a#zoom_link1').first[:href]
  ]
end

def get_lm_product_image(product_id)

  src = get_lm_product_data(product_id)[4]
  name = get_lm_product_data(product_id)[2].first.gsub(/[ ]/, '_')

  # Base64.encode64(open(src) { |f| f.read })
  File.open('Liqui_Moly_' + "#{name}" + '_' + File.basename(src), 'wb') { |f| f.write(open(src).read) }
  # Save image to folder on the hard drive
  # IO.copy_stream(open(src), "/home/sproodigy/Foto/Liqui_Moly_#{name}_#{get_lm_product_data(product_id)[1].first(-1)}_#{File.basename(src)}")
end

def barcode_from_product_art(product_art)
  s = "41004200#{product_art}"
  "#{s}#{checkdigit(s)}"
end

def checkdigit(barcode)
  evens, odds = *barcode.scan(/\d/).map { |d| d.to_i }.partition.with_index { |d, i| (i&1).zero? }
  (10 - ((odds.reduce(:+)) * 3 + evens.reduce(:+)) % 10) % 10
end

# def put_lm_product_price(product_barcode, price, short_description, title, weight, weight_1)
#   page = HTTP.headers(authorization: "Token 69be0fb43ae944941c9aea1f12e16497").put("https://xp.extrapost.ru/api/v1/products/#{product_barcode}",
#                       json: {product: {price: price,
#                                        description: short_description,
#                                        title: title,
#                                        weight: weight_1
#                                       }})
# end

# def create_product(product_barcode, price)
#   page = HTTP.headers(authorization: "Token 69be0fb43ae944941c9aea1f12e16497").post("https://xp.extrapost.ru/api/v1/products/",
#                       json: {product: {price: "#{price}"}})
# end

# get_purchase_price

# (402..402).each do |product_id|
#   result = get_lm_product_data(product_id)
#   next if result[0].nil?
#
#   barcode = barcode_from_product_art(result[0])
#   price = result[3]
#
#   short_description = result[2][2].split(' ')
#   short_description[-2..-1] = nil
#   short_description = short_description.join(' ')
#
#   weight = result[2][2].split(' ')
#   weight_1 = weight[-2]
#   weight = weight_1 + ' L'
#
#   name = result[2].first.partition(' — ').first
#   title = "Liqui Moly #{name} (#{weight}) (art: #{result[0]})"
#
# #
# #
#   # puts name, title, weight
# #
#     # puts get_lm_product_image(product_id)
# #   # puts price, barcode
# #   get_lm_product_data(product_id)
#
#   # put_lm_product_price(barcode, price, short_description, title, weight, weight_1)
# end
