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

def get
  get_bardahl_product_data.map do |link|
    data = link.click
    manufacturing = data.search('.item-name h2').text.split.last
    next if manufacturing != 'Бельгия'
    art = data.search('#art-value').text
    full_desc = data.search('.item-text').to_s
    weight = data.search('.left span').text.rstrip
    title = 'Bardahl ' + data.search('.item-name h1').text + " (#{weight})"
    image_path = data.search('.item-image img').first[:src]
    store_id = 3
    country_of_origin = 'BE'
    # barcode = barcode_from_product_art
    # sku = barcode
    data = {manufacturing: manufacturing,
            art: art
           }
  end
end

puts get


def get_bardahl_product_image
  product_data = get_bardahl_product_data
  src = 'https://allbardahl.ru' + product_data[:image_path]

  content_type_data = File.extname(src)
  content_type = 'image/' + content_type_data[1,3]
  image_base64_data = Base64.encode64(open(src) { |f| f.read })
  image = "data:#{content_type};base64,#{image_base64_data}"

  {image: image, filename: File.basename(src).gsub(/-/, '_')}
end

def barcode_from_product_art
  s = "32667201#{get_bardahl_product_data[:art].gsub(/[^\d]/, ' ').rstrip}"
  "#{s}#{checkdigit(s)}"
end

def checkdigit(barcode)
  evens, odds = *barcode.scan(/\d/).map { |d| d.to_i }.partition.with_index { |d, i| (i&1).zero? }
  (10 - ((odds.reduce(:+)) * 3 + evens.reduce(:+)) % 10) % 10
end

# array_links.each_with_index { |el, i| puts el, i }
