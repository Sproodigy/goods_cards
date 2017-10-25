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

agent = Mechanize.new
# Spare links
# page  = agent.get("http://www.bardahlrussia.ru/productions/for_cars/engine_oils")
# page  = agent.get("https://oilbardahl.ru/avtomobili/maslo_v_dvigatel/")
page  = agent.get("http://bardahl-motor.ru/motornye-masla/")

review_links = page.links_with(text: /\w+/, href: %r{/motornye-masla/\w+})[0, 59]
info = review_links.each do |link|
  data = link.click
  puts art = data.search('.articul strong').text
  puts title = data.search('.hed-card.bold').text
end
# data = review_links[0].click
# puts data.search.text
# review_links = page.links_with(text: /\w+/, href: %r{/motornye-masla/\w+})[0, 59]
# data_source = review_links.each do |l|
  # data = l.click
  # pp art = data.search('.articul strong').text
  # artist = review_meta.search('h1')[0].text
# end
# agent.get('http://bardahl-motor.ru/motornye-masla/xtc-5w30-20-l').search("strong").first.content


# puts data = review_links[0].click

# review_links = review_links.reject do |link|
#   parent_classes = link.node.parent['class']&.split
#   parent_classes.any? { |p| %w[next-container page-number].include?(p) }
# end
