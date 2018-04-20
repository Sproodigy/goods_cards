# encoding: utf-8

# require 'axlsx'   # For create xlsx files
require 'openssl'
require 'roo-xls'
require 'simple-spreadsheet'
# require 'csv'
# require 'uri'
# require 'net/http'
require 'http'
require 'open-uri'
require 'nokogiri'
require 'base64'
require 'json'
require 'active_support/core_ext/string/access'

def get_mafra_product_data(page)
  ctx = OpenSSL::SSL::SSLContext.new
  ctx.verify_mode = OpenSSL::SSL::VERIFY_NONE
  page_data = Nokogiri::HTML(HTTP.get("http://www.mafrarussia.ru/?page_id=#{page}", :ssl_context => ctx).to_s)

  {
    page_response: page_data.css('h1').text,
    title: page_data.css('.headline strong').first&.content,
    desc1: page_data.css('.two-thirds h1').last.to_s + "\n<p></p>\n" +
           page_data.css('.two-thirds p')[1].to_s + "\n<p></p>\n" +
           page_data.css('.two-thirds h3')[0].to_s + "\n<p></p>\n" +
           page_data.css('.two-thirds p')[2].to_s + "\n<p></p>\n" +
           page_data.css('.two-thirds h3')[1].to_s + "\n<p></p>\n" +
           page_data.css('.two-thirds p')[3].to_s,
    desc2: page_data.css('.two-thirds .half-page h1').first.to_s + "\n<p></p>\n" +
           page_data.css('.two-thirds .half-page p')[0].to_s + "\n<p></p>\n" +
           page_data.css('.two-thirds .half-page h3')[0].to_s + "\n<p></p>\n" +
           page_data.css('.two-thirds .half-page p')[1].to_s + "\n<p></p>\n" +
           page_data.css('.two-thirds .half-page h3')[1].to_s + "\n<p></p>\n" +
           page_data.css('.two-thirds .half-page p')[2].to_s,
    sku_and_weight_data1: page_data.css('.two-thirds .one-third').to_a,
    sku_and_weight_data2: page_data.css('.two-thirds .half-page p').last&.content
  }
end

start = Time.now
goods = []
(4027..4027).each do |page_id|
# (3813..3818).each do |page_id|
  source = get_mafra_product_data(page_id)

  if source[:page_response] == '404'
    puts "Page:   #{page_id} not exist"
  else
    puts "Page:   #{page_id}"
  end

  if source[:sku_and_weight_data1].nil? || source[:sku_and_weight_data1].length == 0

      sku = source[:sku_and_weight_data2].split('Упаковка')[0].split(' ')[1]
      goods.push(sku)
      weight = source[:sku_and_weight_data2].split('Упаковка')[1].partition('.')[0].lstrip.gsub(/,/, '.').gsub(/кг/, 'kg')
      title = "#{source[:title]} (art: #{sku}) (#{(weight)})"
      desc = source[:desc2]

    # For Extrastore
      # price = (purch_price * 1.34).round
      # old_price = (purch_price * 1.49).round
      country_of_origin = 'IT'
      store_ids = [100]   # AvtoRaketa in Extrastore
      availability = 'on_demand'
      yandex_market_export = true
   # # # # #
      puts "Title:   #{title}", "SKU:   #{sku}", "Weight:   #{weight}", "Description:   #{desc}", '= = = = ='
  else

    source[:sku_and_weight_data1].each do |data|
      sku = data.text.split('Упаковка')[0].split(' ')[1]
      goods.push(sku)
      weight = data.text.split('Упаковка')[1].partition('.')[0].lstrip.gsub(/,/, '.').gsub(/кг/, 'kg')
      title = "#{source[:title]} (art: #{sku}) (#{(weight)})"
      desc = source[:desc1]

    # For Extrastore
      # price = (purch_price * 1.34).round
      # old_price = (purch_price * 1.49).round
      country_of_origin = 'IT'
      store_ids = [100]   # AvtoRaketa in Extrastore
      availability = 'on_demand'
      yandex_market_export = true
    # # # # #
      puts "Title:   #{title}", "SKU:   #{sku}", "Weight:   #{weight}", "Description:   #{desc}", '= = = = ='
    end
  end
end

puts 'Number of goods:   ' + goods.length.to_s
finish = Time.now
full_time = (finish - start)
if full_time >= 3600
  hours = (full_time / 3600).floor
  min = (full_time / 60 - hours * 60).floor
  sec = (full_time - (min * 60 + hours * 3600))
  puts "#{hours} hours   #{min} min   #{sec} sec"
elsif full_time >= 60
  min = (full_time / 60).floor
  sec = (full_time - min * 60).floor
  puts "#{min} min   #{sec} sec"
else
  puts full_time.round.to_s + ' sec'
end
