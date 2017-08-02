  require 'rubyXL'
  require 'roo-xls'
  require 'simple-spreadsheet'
  # require 'simple-xls'
  # require 'httparty'
  # require 'pry'
  # require 'csv'
  # require 'uri'
  # require 'net/http'
  require 'http'
  require 'open-uri'
  require 'nokogiri'
  require 'base64'
  require 'json'
  require 'active_support/core_ext/string/access'

  # file = File.open("/Users/extra/RubymineProjects/goods_cards/app/assets/prices/Price_LM_10.05.2017.xlsx")
  # workbook = RubyXL::Parser.parse('/Users/extra/RubymineProjects/goods_cards/app/assets/prices/Price_LM_10.05.2017.xlsx') # ("path/to/Excel/file.xlsx")
  # worksheet = workbook[0]
  # cell = worksheet[3][3]
  # puts cell

  # def get_purchase_price
  #   response = HTTP.follow.get('https://docs.google.com/spreadsheets/d/1oEZHsE-Wb3W4RLWu1Hewm9Xj4hj6_6eQ_NtbJCdwFUc/gviz/tq?tqx=out:csv&sheet=OrderLiquiMolySamara011116(13)')
  #   response_price = HTTP.follow.get('https://docs.google.com/spreadsheets/d/1r-nchqB-LELEDhDz79s5yNJCAox8W2vo8Uo-E8H9Lio/gviz/tq?tqx=out:csv&sheet=1')
  #   csv = CSV.parse(response.to_s)
  #   price = CSV.parse(response_price.to_s)
  #   puts price
  # end

  def get_lm_product_data(product_id)
    # Load page html and parse it with Nokogiri
    page = Nokogiri::HTML(HTTP.follow.get("http://www.lm-shop.ru/index.php?route=product/product&product_id=#{product_id}").to_s)
    # Select html element from page and print it
    [
      # Art (0)
      page.css('#tab-attribute > table.attribute > tbody > tr:nth-last-child(2) > td:nth-child(2)').first&.content,
      # Full description (1)
      page.css('.product-description').first&.content,
      # Name, short decription and volume (2)
      page.css('.product-info h1').first&.content&.partition(/( - | — )/),
      # Price (3)
      page.css('.product-info span.price-new').first&.content&.gsub(/[^0-9\.]/, '')&.to_f,
      # Source for image (4)
      (page.css('a#zoom_link1').first[:href] unless page.css('a#zoom_link1').first.nil?)
    ]
  end

  def get_purchase_price(product_art)
    # Also supports csv, csvt and tsv formats

    s = SimpleSpreadsheet::Workbook.read('/Users/extra/RubymineProjects/goods_cards/app/assets/prices/Price_LM_10.05.2017.xlsx')
    s.selected_sheet = s.sheets[0]
    s.first_row.upto(s.last_row) do |line|
      art_shen = s.cell(line, 4)
      pur_price = s.cell(line, 7)

      next if art_shen == nil

      if art_shen.to_s.include?('/')
        double_art = art_shen.to_s.gsub(/[\/ |*]/, ' ').partition(' ')
        double_art.each do |art|
          next if art == ' '
          art_shu = art.gsub(/[^0-9]/, '')
        end
      else
        art_shu = art_shen.to_s.gsub(/[^0-9]/, '')
      end

      data = Hash[art_shu, pur_price]
      data.each { |key, value| puts "#{key}: #{value}" if key == 1995}

      data.each do |key, value|
        if key == product_art then value = pur_price
          return pur_price
        end
      end
    end
  end

  def get_lm_product_image(product_id)

    src = get_lm_product_data(product_id)[4]
    name = get_lm_product_data(product_id)[2].first.gsub(/[ ]/, '_')

    Base64.encode64(open(src) { |f| f.read })
    # File.open('Liqui_Moly_' + "#{name}" + '_' + File.basename(src), 'wb') { |f| f.write(open(src).read) }
    # Save image to folder on the hard drive
    # IO.copy_stream(open(src), "/home/sproodigy/Foto/Liqui_Moly_#{name}_#{get_lm_product_data(product_id)[1].first(-1)}_#{File.basename(src)}")
    # IO.copy_stream(open(src), "/home/extra/Liqui_Moly_#{name}_#{get_lm_product_data(product_id)[4].first(-1)}_#{File.basename(src)}")
  end

  def barcode_from_product_art(product_art)
    s = "41004200#{product_art}"
    "#{s}#{checkdigit(s)}"
  end

  def checkdigit(barcode)
    evens, odds = *barcode.scan(/\d/).map { |d| d.to_i }.partition.with_index { |d, i| (i&1).zero? }
    (10 - ((odds.reduce(:+)) * 3 + evens.reduce(:+)) % 10) % 10
  end

                             # sku пока использовать только при создании новых товаров.

  # def put_lm_product_price(purchase_price, barcode, store_id, price, short_desc, title, weight_number)
  #   page = HTTP.headers(authorization: "Token 69be0fb43ae944941c9aea1f12e16497").put("https://xp.extrapost.ru/api/v1/products/#{barcode}",
  #                       json: {product: {purchase_price: purchase_price,
  #                                        barcode: barcode,
  #                                        store_id: store_id,
  #                                        price: price,
  #                                        description: short_desc,
  #                                        title: title,
  #                                        weight: weight_number
  #                                       }})
  # end
  #
  # def create_product(purchase_price, sku, barcode, store_id, price, short_desc, title, weight_number)
  #   page = HTTP.headers(authorization: "Token 69be0fb43ae944941c9aea1f12e16497").post("https://xp.extrapost.ru/api/v1/products/",
  #                      json: {product: { purchase_price: purchase_price,
  #                                        sku: sku,
  #                                        barcode: barcode,
  #                                        store_id: store_id,
  #                                        price: price,
  #                                        description: short_desc,
  #                                        title: title,
  #                                        weight: weight_number
  #                                       }})
  # end

  (9..9).each do |product_id|
    result = get_lm_product_data(product_id)
    next if result[0].nil?

    name = result[2].first.partition(' — ').first

    weight_number_sourse = result[2].last.split(' ')
    weight_number = weight_number_sourse[-2]
    next if weight_number.to_f > 20

    barcode = barcode_from_product_art(result[0])

    price = result[3]

    purchase_price = get_purchase_price(result[0])

    store_id = 3 # Avto-Raketa

    if result[2].include?(' — ')
      short_desc = result[2].last
      short_desc = short_desc.split(' ')
      short_desc.pop
      short_desc.pop
      short_desc = short_desc.join(' ')

      weight = weight_number + ' L'

      title = "Liqui Moly #{name} (#{weight}) (art: #{result[0]})"
    else
      short_desc = get_lm_product_data(product_id)[2].last

      title = "Liqui Moly #{name} (art: #{result[0]})"
    end

    if short_desc.length > 64
      short_desc = short_desc[0..63]
    end

    def generate_sku(name, weight_number)

      sku_full = "lm_#{name.downcase.gsub(/-|[ ]/, '_')}_#{weight_number}"

      if sku_full.length > 32
          sku_full_part = sku_full.gsub(/_/, ' ').split
          sku_full_part_new = sku_full_part.map { |word| word.length >= 10 ? word = word[0..4] : word }
          sku = sku_full_part_new = "#{sku_full_part_new.join('_')}"

          if sku_full_part_new.length > 32
              sku_part = sku_full_part_new.gsub(/_/, ' ').split
              sku_part_new = sku_part.map { |word| word.length <= 9 && word.length >= 5 ? word = word[0..2] : word }
              sku = sku_part_short = "#{sku_part_new.join('_')}"

              if sku_part_short.length > 32
                  sku_part_end = sku_part_short.gsub(/_/, ' ').split
                  sku_part_end.delete_at(1)
                  sku = "#{sku_part_end_new.join('_')}"
              else
                sku_full
              end
          else
            sku_full
          end
      else
        sku_full
      end
    end

    sku = generate_sku(name, weight_number)

    # puts purchase_price, sku, barcode, store_id, price, short_desc, title, weight_number
    puts purchase_price, title, price, '= - = - ='
    # puts put_lm_product_price(purchase_price, barcode, store_id, price, short_desc, title, weight_number)
    # create_product(purchase_price, sku, barcode, store_id, price, short_desc, title, weight_number)
  end
