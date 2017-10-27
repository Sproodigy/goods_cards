# encoding: utf-8

# require 'axlsx'   # For create xlsx files
# require 'simple-spreadsheet'
# require 'http'
# require 'open-uri'
# require 'nokogiri'
# require 'base64'
require 'mechanize'
require 'date'
require 'json'

# Spare links
# page  = agent.get("http://www.bardahlrussia.ru/")
# page  = agent.get("https://oilbardahl.ru/avtomobili/maslo_v_dvigatel/")
# page  = agent.get("http://bardahl-motor.ru/motornye-masla/")


# puts array_links.each_with_index { |it, ind| puts it, ind }
def get_bardahl_product_data
  agent = Mechanize.new

  page = agent.get('https://allbardahl.ru/catalog/additives/')

  review_links = page.links_with(text: /[a-zA-Z]/, href: %r{/\w+})[1, 76]
  array_links = []
  review_links.each_with_index do |elem, i|
    i % 2 == 0 ? array_links << elem : next
  end

  puts art = array_links[4].click.search('#art-value').text
  puts manufacturing = array_links[4].click.search('.item-name h2').text.split.last
  full_desc = array_links[4].click.search('.item-text')
  puts weight = array_links[4].click.search('.left span').text.rstrip
  puts title = 'Bardahl ' + array_links[4].click.search('.item-name h1').text + " (#{weight})"
  puts image_path = 'https://allbardahl.ru/' + "#{array_links[4].click.search('.item-image img src')}"
  puts '- - - - - - - - - - - - - -'
  { image_path: image_path}
end
get_bardahl_product_data

def get_bardahl_product_image(product_id)
  product_data = get_lm_product_data_liquimoly_ru(product_id)
  src = 'http://liquimoly.ru/' + product_data[:image_path]
  # name = get_lm_product_data(product_id)[2]

  content_type_data = File.extname(src)
  content_type = 'image/' + content_type_data[1,3]
  image_base64_data = Base64.encode64(open(src) { |f| f.read })
  image = "data:#{content_type};base64,#{image_base64_data}"

  {image: image, filename: "#{product_id}#{content_type_data}"}
end

# info = array_links.each do |link|
  # data = link.click
  # puts art = data.search('.articul strong').text
  # puts title = data.search('.hed-card.bold').text
# end
# data = review_links[0].click
# puts data.search.text
# review_links = page.links_with(text: /\w+/, href: %r{/motornye-masla/\w+})[0, 59]
# data_source = review_links.each do |l|
  # data = l.click
  # pp art = data.search('.articul strong').text
  # artist = review_meta.search('h1')[0].text
# end
# agent.get('http://bardahl-motor.ru/motornye-masla/xtc-5w30-20-l').search("strong").first.content
