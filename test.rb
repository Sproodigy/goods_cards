# encoding: utf-8

# require 'axlsx'   # For create xlsx files
require 'rubyXL'
require 'roo-xls'
require 'simple-spreadsheet'
require 'http'
require 'open-uri'
require 'nokogiri'
require 'base64'
require 'json'
require 'active_support/core_ext/string/access'
require 'mechanize'
require 'date'
require 'json'

agent = Mechanize.new
page  = agent.get("http://bardahl-motor.ru/motornye-masla")

review_links = page.links_with(href: %r{/motornye-masla/\w+})

puts review_links

# review_links = review_links.reject do |link|
#   parent_classes = link.node.parent['class']&.split
#   parent_classes.any? { |p| %w[next-container page-number].include?(p) }
# end

# needed_links = []
# review_links.each do |link|
#   links = link.node['class']
#   next if links.nil?
#   next if /[^nowrap]/.match(links)
#   needed_links << links
# end
#
# needed_links.map do |link|
#   link.click
#   puts link
# end


# review_links = review_links.reject do |link|
#   needed_classes = link.node['class']
#   next if needed_classes.nil?
#   next if /[^nowrap]/.match(needed_classes)
#   needed_classes = needed_classes.split(' ')
# end
