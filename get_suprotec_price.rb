# encoding: utf-8

require 'simple-spreadsheet'
require 'http'
require 'open-uri'
require 'nokogiri'
require 'base64'
require 'json'

def get_suprotec_product_data(name)
  # page = Nokogiri::HTML(HTTP.follow.get("https://berg.ru/article/#{product_id}").to_s)
  # page = Nokogiri::HTML(HTTP.follow.get("https://berg.ru/search/step2?search=#{product_id}&brand=BARDAHL").to_s)
  page = Nokogiri::HTML(HTTP.follow.get("https://suprotecshop.ru/#{name}").to_s)

  {
    art: page.css('.product-intro__addition-item span').first&.content.to_s,

    full_desc: page.css('.product-tabs__content-pane').to_s,
    title: page.css('.content__header').first&.content.to_s,

    price_new: page.css('.product-price__main .product-price__item-value').first&.content.to_s,
    price_old: page.css('.product-price__old .product-price__item-value').first&.content.to_s,

    image_path: page.css('.product-photo a').first[:href]

    # title: page.css('.two-thirds h1.headline strong').first&.content&.to_s,
    # image_path: (page.css('.two-thirds img').first[:src] unless page.css('.two-thirds img').first.nil?),
    # full_desc: page.css('.half-page').first
  }
end

def get_suprotec_product_image(name)

  product_data = get_suprotec_product_data(name)
  src = product_data[:image_path]

  content_type_data = File.extname(src)
  content_type = 'image/' + content_type_data[1,3]
  image_base64_data = Base64.encode64(open(src) { |f| f.read })
  image = "data:#{content_type};base64,#{image_base64_data}"

  {image: image, filename: "#{name.gsub(/[-| ]/, '_')}#{content_type_data}"}
end

def put_lm_product_price(purchase_price, barcode, store_id, price, short_desc, title, weight, image, filename, country_of_origin)
  page = HTTP.headers(authorization: "Token e541dfef128f4f93cbdb09b320ea3fb7").put("https://xp.extrapost.ru/api/v1/products/#{barcode}",
                      json: {product: {purchase_price: purchase_price,
                                       barcode: barcode,
                                       store_id: store_id,
                                       price: price,
                                       description: short_desc,
                                       title: title,
                                       weight: weight,
                                       image: image,
                                       image_file_name: filename,
                                       country_of_origin: country_of_origin
                                      }})
end

def create_product(purchase_price, sku, barcode, store_id, price, short_desc, title, weight, image, filename, country_of_origin)
  page = HTTP.headers(authorization: "Token e541dfef128f4f93cbdb09b320ea3fb7").post("https://xp.extrapost.ru/api/v1/products/",
                     json: {product: { purchase_price: purchase_price,
                                       sku: sku,
                                       barcode: barcode,
                                       store_id: store_id,
                                       price: price,
                                       description: short_desc,
                                       title: title,
                                       weight: weight,
                                       image: image,
                                       image_file_name: filename,
                                       country_of_origin: country_of_origin
                                      }})
end

  array_of_names = [
                    'suprotec-tribotechnical-composition-of-active-petrol', 'suprotec-asset-gasoline-plus',
                    'suprotec-tribotechnical-composition-of-active-diesel', 'suprotec-tribotechnical-composition-active-plus-diesel',
                    'suprotec-tribotechnical-composition-of-the-active-regular', 'suprotec-tribotechnical-composition-off-road-4x4-engine-gasoline',
                    'suprotec-tribotechnical-composition-off-road-4x4-engine-diesel', 'suprotec-tribotechnical-composition-max-ice',
                    'suprotec-tribotechnical-composition-mototec-2', 'suprotec-tribotechnical-composition-mototec-4',
                    'fuel-system-cleaner-suprotec-petrol', 'fuel-system-cleaner-suprotec-diesel', 'suprotec-antigel-3-in-1',
                    'suprotec-max-antigel-3-in-1', 'suprotec-tribotechnical-composition-max-pump', 'suprotec-tribotechnical-composition-injection-pump',
                    'long-term-flushing-the-engine-with-suprotec', 'suprotec-tribotechnical-composition-off-road-4x4-automatic-transmission',
                    'suprotec-tribotechnical-composition-off-road-4x4-manual-transmission', 'suprotec-tribotechnical-composition-mkpp',
                    'suprotec-tribotechnical-composition-automatic', 'suprotek-tribotehnicheskii-sostav-maks-mkpp',
                    'suprotec-tribotechnical-composition-hur', 'suprotec-tribotechnical-composition-reducer', 'suprotec-tribotechnical-composition-off-road-gear',
                    'suprotec-tribotechnical-composition-max-hydraulics', 'silikonovyi-vosk-sr100', 'tribological-lubrication-of-the-universal-pro',
                    'tribological-grease-suprotec-universal-m', 'tribological-concentrate-suprotec', 'ochistitel-sistemy-ventiliatsii-i-konditsionera-plius',
                    'cleaner-ventilation-and-air-conditioning-suprotec', 'legkii-avtomobilnyi-aromatizator-vozduha', 'car-diffuser-air',
                    'gift-set-active-plus-petrol-', 'gift-set-suprotec-active-plus-diesel'
                  ]

  array_of_names.each do |name|

    result = get_suprotec_product_data(name)

    title = result[:title]
    full_desc = result[:full_desc]

    price_old = result[:price_old]
    price_new = result[:price_new]

    image_result = get_suprotec_product_image(name)
    image = image_result[:image]
    filename = image_result[:filename]

    barcode = "4660007#{result[:art]}"

    store_id = 3   # Avto-Raketa

    puts barcode, title, price_old, price_new, filename, '- - - - - - -'
  end

    # next if (result[:avail].match('не поставляется') unless result[:avail].nil?)
    # next if (result[:avail].match('снят') unless result[:avail].nil?)

    # title_data = result[:title].split(' ').pop

    # title = 'Свеча зажигания' + result[:title].split(' ')

    # art = result[:art].gsub(/[^0-9]/, ' ').rstrip

    # barcode = barcode_from_product_art(art)

    # price = result[3]

    # purchase_price = get_purchase_price(result[:art])


    # puts result
