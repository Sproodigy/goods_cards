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
    sku: page.css('.two-thirds strong')[1..-1].to_a,

    weight1: ((page.css('.half-page p').to_s.split('Упаковка')[-1].split('<')[0].lstrip) unless (page.css('.half-page').first&.content.nil?)),
    weight2: (page.css('.one-third').to_s unless
              page.css('.one-third').first&.content.nil?)
  }
end

# def get_weight(product_id)
#   weight_data = get_mafra_product_data(product_id)
#   weight = weight_data[:weight2]
# end

(3736..3736).each do |page|
  res = get_mafra_product_data(page)

  res[:sku].each do |article|
      next if article.nil?
      art = article.to_s.split('>')[1].split('<')[0]
      title = res[:title]

      # puts res[:weight1], '- - - - - - -'
      # puts res[:weight2]

      if res[:weight1].nil?
        weight = res[:weight2].split('Упаковка')[0]
        # weight = weight[0]
      else
        weight = res[:weight1].split('<br>').shift
      end

      # weight = get_weight(art)

      puts art, title, weight, '= = = = ='
    end
  end
