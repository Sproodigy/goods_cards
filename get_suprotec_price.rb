# encoding: utf-8
require 'mechanize'
require 'csv'
require 'simple-spreadsheet'
require 'http'
require 'open-uri'
require 'nokogiri'
require 'base64'
require 'json'

def get_suprotec_product_data
# Load page html and parse it with Nokogiri
  page = HTTP.follow.get("https://docs.google.com/spreadsheets/d/1IMtLg2PYozVgFFfxxYvgzBJLKxt2nkC5OiAfO4kOJ8Y/gviz/tq?tqx=out:csv&sheet=1")
  csv = CSV.parse(page.to_s)
  puts csv
# Select html element from page and print it
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

get_suprotec_product_data

# def get_suprotec_product_data
#   agent = Mechanize.new
#   page = agent.get('https://suprotec.ru/produktsiya-suprotec/')
#   review_links = page.links_with(href: %r{/\w+})
#   # puts review_links.inspect
#   # puts review_links.reject { |link| link.text.include?('Супротек')}
#   review_links = review_links.reject do |link|
#     puts parent_classes = link.node.parent['class'].split
#     parent_classes.delete_if? { |pc| pc.text != 'item-title' }
#   end
#   # puts review_links
# end

# def get_suprotec_product_image
#
#   product_data = get_suprotec_product_data
#   src = product_data[:image_path]
#
#   content_type_data = File.extname(src)
#   content_type = 'image/' + content_type_data[1,3]
#   image_base64_data = Base64.encode64(open(src) { |f| f.read })
#   image = "data:#{content_type};base64,#{image_base64_data}"
#
#   {image: image, filename: "#{name.gsub(/[-| ]/, '_')}#{content_type_data}"}
# end

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

  # array_of_names.each do |name|

    # result = get_suprotec_product_data
    #
    # title = result[:title]
    # full_desc = result[:full_desc]
    #
    # price_old = result[:price_old]
    # price_new = result[:price_new]
    #
    # image_result = get_suprotec_product_image
    # image = image_result[:image]
    # filename = image_result[:filename]
    #
    # barcode = "4660007#{result[:art]}"
    #
    # store_id = 3   # Avto-Raketa
    #
    # puts barcode, title, '- - - - - - -'

    # next if (result[:avail].match('не поставляется') unless result[:avail].nil?)
    # next if (result[:avail].match('снят') unless result[:avail].nil?)

    # title_data = result[:title].split(' ').pop

    # title = 'Свеча зажигания' + result[:title].split(' ')

    # art = result[:art].gsub(/[^0-9]/, ' ').rstrip

    # barcode = barcode_from_product_art(art)

    # price = result[3]

    # purchase_price = get_purchase_price(result[:art])


    # puts result
