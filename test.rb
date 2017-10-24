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
page  = agent.get("http://bardahl-motor.ru/motornye-masla/")
review_links = page.links_with(text: /\w+/, href: %r{/motornye-masla/\w+})[0, 59]
data_source = review_links.each do |l|
  data = l.click
  data = data.search('#main .review-meta .info')
  pp art = data.search('strong').text
  # artist = review_meta.search('h1')[0].text
end
# agent.get('http://bardahl-motor.ru/motornye-masla/xtc-5w30-20-l').search("strong").first.content


# puts data = review_links[0].click

# review_links = review_links.reject do |link|
#   parent_classes = link.node.parent['class']&.split
#   parent_classes.any? { |p| %w[next-container page-number].include?(p) }
# end
