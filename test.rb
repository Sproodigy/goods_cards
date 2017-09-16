# encoding: utf-8

# require 'axlsx'   # For create xlsx files
require 'rubyXL'
require 'roo-xls'
require 'simple-spreadsheet'
# require 'simple-xls'
# require 'httparty'
require 'csv'
# require 'uri'
# require 'net/http'
require 'http'
require 'open-uri'
require 'nokogiri'
require 'base64'
require 'json'
require 'active_support/core_ext/string/access'

def get_lm_product_data(product_id)
# Load page html and parse it with Nokogiri
  page = Nokogiri::HTML(HTTP.follow.get("http://www.lm-shop.ru/index.php?route=product/product&product_id=#{product_id}").to_s)
# Select html element from page and print it
  [
# Art (0)
    page.css('#tab-attribute > table.attribute > tbody > tr:nth-last-child(2) > td:nth-child(2)').first&.content,
# Full description (1)
    page.css('.product-description').first,
# Name, short decription and volume (2)
    (page.css('.product-info h1').first&.content unless page.css('.product-info h1').first&.content.nil?),
# New price (3)
    page.css('.product-info span.price-new').first&.content&.gsub(/[^0-9\.]/, '')&.to_f,
# Image (4)
    (page.css('a#zoom_link1').first[:href] unless page.css('a#zoom_link1').first.nil?),
# Weight (5)
    page.css('#tab-attribute > table.attribute > tbody > tr:nth-last-child(1) > td:nth-child(2)').first&.content,
# Old price (6)
    page.css('.product-info .price').first&.content&.gsub(/[^0-9\.]/, '')&.to_f
  ]
end

def get_lm_product_data_liquimoly_ru(product_id)
# Load page html and parse it with Nokogiri
  page = Nokogiri::HTML(HTTP.follow.get("http://liquimoly.ru/item/#{product_id}.html").to_s)
# Select html element from page and print it
  [
# Art (0)
  page.css('.card_desc strong').first&.content,
# Full description
  # Properties (1)
  page.css('#tabs-1 p').first,
  # Application of goods (2)
  page.css('#tabs-2 p').last,
# Name, short decription (3)
    page.css('.fl_f_div h1').first&.content,
# Image (4)
    (page.css('.fl_f_div a.big_img_l.loupe_target').first[:href] unless page.css('.fl_f_div a.big_img_l.loupe_target').first.nil?),
# Weight (5)
    page.css('.card_desc a').first&.content
  ]
end

(2282..2282).each do |product_id|   # Art from 1007 to 77169
  result = get_lm_product_data_liquimoly_ru(product_id)
  puts result[3].gsub(/ё/, 'е').gsub(/[^0-9А-Яа-я]/, ' ').rstrip + '.'
  puts result[3]
end
