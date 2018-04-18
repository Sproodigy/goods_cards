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

def get_mafra_product_data(product_id)
  ctx = OpenSSL::SSL::SSLContext.new
  ctx.verify_mode = OpenSSL::SSL::VERIFY_NONE
  page = Nokogiri::HTML(HTTP.follow.get("http://www.mafrarussia.ru/?page_id=#{product_id}", :ssl_context => ctx).to_s)

  {
    title: page.css('.headline strong').first&.content,
    desc: page.css('.two-thirds h1').last.to_s + "\n" + page.css('.two-thirds p')[1].to_s + "\n" +
          page.css('.two-thirds h3').first.to_s + "\n" + page.css('.two-thirds p')[2].to_s,

    sku: page.css('.two-thirds strong')[1..-1].to_a
  #   sku: page.css('.card_desc strong').first&.content,
  #
  # # Full description
  #   props: page.css('#tabs-1 p').first,
  #   apps: page.css('#tabs-2 p').last,

    # short_desc: page.css('.fl_f_div h1').first&.content,
    # image_path: (page.css('.fl_f_div a.big_img_l.loupe_target').first[:href] unless page.css('.fl_f_div a.big_img_l.loupe_target').first.nil?),
    # weight: page.css('.card_desc a').first&.content
  }
end
(3230..3235).each do |page|
  res = get_mafra_product_data(page)
  res[:sku].each do |article|
    # next if art.nil?
    art = article.to_s.split('>')[1].split('<')[0]
    title = res[:title]

    puts art, title, '= = = = ='
  end

end
