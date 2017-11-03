# encoding: utf-8

# require 'axlsx'   # For create xlsx files
# require 'simple-spreadsheet'
require 'http'
require 'open-uri'
require 'nokogiri'
require 'base64'
require 'mechanize'
require 'date'
require 'json'

# Spare links
# page  = agent.get("http://www.bardahlrussia.ru/")
# page  = agent.get("https://oilbardahl.ru/avtomobili/maslo_v_dvigatel/")
# page  = agent.get("http://bardahl-motor.ru/motornye-masla/")

def get_bardahl_product_data
  agent = Mechanize.new
  page = agent.get('https://allbardahl.ru/catalog/additives/')
  review_links = page.links_with(text: /[a-zA-Z]/, href: %r{/\w+})[1, 76]

  array_links = []
  review_links.map.with_index do |elem, i|
    i % 2 == 0 ? array_links << elem : next
  end
  array_links
end


def checkdigit(barcode)
  evens, odds = *barcode.scan(/\d/).map { |d| d.to_i }.partition.with_index { |d, i| (i&1).zero? }
  (10 - ((odds.reduce(:+)) * 3 + evens.reduce(:+)) % 10) % 10
end

def barcode_from_product_art(art)
  s = "32667201#{art}"
  "#{s}#{checkdigit(s)}"
end

def get_bardahl_product_image(image_path)
  product_data = get_bardahl_product_data
  src = 'https://allbardahl.ru' + image_path.to_s

  content_type_data = File.extname(src)
  content_type = 'image/' + content_type_data[1,3]
  image_base64_data = Base64.encode64(open(src) { |f| f.read })
  image = "data:#{content_type};base64,#{image_base64_data}"

  {image: image, filename: File.basename(src).gsub(/-/, '_')}
end

get_bardahl_product_data[0..3].each do |link|
  data = link.click
  manufacturing = data.search('.item-name h2').text.split.last
  next if manufacturing != 'Бельгия'
  art = data.search('#art-value').text
  full_desc = data.search('.item-text').to_s
  weight_1 = data.search('.left span').first.text.rstrip
  weight_2 = data.search('.left span').last.text.rstrip
  weight_1_num = weight_1.gsub(/[^\d]/, ' ').rstrip.to_f
  weight_2_num = weight_2.gsub(/[^\d]/, ' ').rstrip.to_f
  title_1 = 'Bardahl ' + data.search('.item-name h1').text + " (#{weight_1})"
  title_2 = 'Bardahl ' + data.search('.item-name h1').text + " (#{weight_2})"
  image_path = data.search('.item-image img').first[:src]
  store_id = 3
  country_of_origin = 'BE'
  barcode = barcode_from_product_art(art)
  sku = barcode
  image = get_bardahl_product_image(image_path)[:image]
  filename  = get_bardahl_product_image(image_path)[:filename]
  puts '- - - - - - - - - -'
end
# array_links.each_with_index { |el, i| puts el, i }
