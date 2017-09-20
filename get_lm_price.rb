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

  def get_lm_product_data_liquimoly_ru(product_id)
  # Load page html and parse it with Nokogiri
    page = Nokogiri::HTML(HTTP.follow.get("http://liquimoly.ru/item/#{product_id}.html").to_s)
  # Select html element from page and print it
    {
    sku: page.css('.card_desc strong').first&.content,

  # Full description
    props: page.css('#tabs-1 p').first,
    apps: page.css('#tabs-2 p').last,

    short_desc: page.css('.fl_f_div h1').first&.content,
    image_path: (page.css('.fl_f_div a.big_img_l.loupe_target').first[:href] unless page.css('.fl_f_div a.big_img_l.loupe_target').first.nil?),
    weight: page.css('.card_desc a').first&.content
    }
  end

  def get_purchase_price(product_art)
  # Also supports csv, csvt and tsv formats
    s = SimpleSpreadsheet::Workbook.read('app/assets/prices/Price_LM_02.08.2017.xlsx')
    s.selected_sheet = s.sheets[0]
    data = []
    s.first_row.upto(s.last_row) do |line|
      art_shen = s.cell(line, 4).to_s
      pur_price = s.cell(line, 8).to_s
      data_1 = Hash.new
      data_2 = Hash.new
      data_3 = Hash.new

      next if art_shen == nil
      next if /[^0-9\/*]/.match(art_shen.to_s)

      if art_shen.to_s.include?('/')
        double_art = art_shen.to_s.gsub(/[\/]/, ' ').partition(' ')
        double_art.each do |art|
          next if art == ' '
          art_shu = art.gsub(/[^0-9]/, '')
          data_1[art_shu] = pur_price
        end
      elsif art_shen.to_s.include?('*')
        data_3[art_shen] = pur_price
      else
        art_shu = art_shen.to_s.gsub(/[^0-9]/, '')
        data_2[art_shu] = pur_price
      end

      data_full = data_1.merge!(data_2).merge!(data_3)
      data_full.each do |key, value|
        if key == product_art then value = pur_price
          return pur_price.to_f
        end
      end
    end
  end

  def get_lm_product_image(product_id)
    product_data = get_lm_product_data_liquimoly_ru(product_id)
    src = 'http://liquimoly.ru/' + product_data[:image_path]
    # name = get_lm_product_data(product_id)[2]

    content_type_data = File.extname(src)
    content_type = 'image/' + content_type_data[1,3]
    image_base64_data = Base64.encode64(open(src) { |f| f.read })
    image = "data:#{content_type};base64,#{image_base64_data}"

    {image: image, filename: "#{product_id}#{content_type_data}"}
  # Save file in project foldet
    # File.open(@title + '.' + File.extname(src)[1, 3], 'wb') { |f| f.write(open(src).read) }
  # Save file to folder on the hard drive
    # IO.copy_stream(open(src), "/home/sproodigy/Foto/Liqui_Moly_#{name}_#{get_lm_product_data(product_id)[1].first(-1)}_#{File.basename(src)}")
    # IO.copy_stream(open(src), "/Users/extra/Documents/Авторакета/LiquiMoly/Фото Liqui Moly/#{@title.gsub(/[\/ ]/, '_') + @content_type_data}")
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

  def create_product_extrapost(purch_price, sku, barcode, store_id, price, short_desc, title, weight_num, image, filename, country_of_origin)
    page = HTTP.headers(authorization: "Token e541dfef128f4f93cbdb09b320ea3fb7").post("https://xp.extrapost.ru/api/v1/products/",
                       json: {product: { purchase_price: purch_price,
                                         sku: sku,
                                         barcode: barcode,
                                         store_id: store_id,
                                         price: price,
                                         description: short_desc,
                                         title: title,
                                         weight: weight_num,
                                         image: image,
                                         image_file_name: filename,
                                         country_of_origin: country_of_origin
                                        }})
  end

  def update_product_extrapost(purch_price, sku, barcode, store_id, price, short_desc, title, weight_num, image, filename, country_of_origin)
    response = HTTP.headers(authorization: "Token e541dfef128f4f93cbdb09b320ea3fb7").put("https://xp.extrapost.ru/api/v1/products/#{barcode}",
                        json: {product: {purchase_price: purch_price,
                                         sku: sku,
                                         barcode: barcode,
                                         store_id: store_id,
                                         price: price,
                                         description: short_desc,
                                         title: title,
                                         weight: weight_num,
                                         image: image,
                                         image_file_name: filename,
                                         country_of_origin: country_of_origin
                                        }})
  end

  def create_product_extrastore(sku, old_price, price, short_desc, full_desc, title, image, filename, category_ids, store_ids, yandex_market_export, availability)
    page = HTTP.headers(authorization: "Token $2a$10$h1Of14AYJkYa5kpiKJTQ7uw/r96shHcgswG/J6rcuaQJAtgFLpjYK").post("http://extrastore.org/api/v1/products/",
                       json: {product: { sku: sku,
                                         price: price,
                                         description: short_desc,
                                         title: title,
                                         image: image,
                                         image_file_name: filename,
                                         long_description: full_desc,
                                         store_ids: store_ids,
                                         category_ids: category_ids,
                                         availability: availability,
                                         old_price: old_price,
                                         yandex_market_export: yandex_market_export
                                        }})
  end

  def update_product_extrastore(sku, old_price, price, short_desc, full_desc, title, image, filename, category_ids, store_ids, yandex_market_export)
    page = HTTP.headers(authorization: "Token $2a$10$h1Of14AYJkYa5kpiKJTQ7uw/r96shHcgswG/J6rcuaQJAtgFLpjYK").put("http://extrastore.org/api/v1/products/4100420015403",
                       json: {product: { sku: sku,
                                         price: price,
                                         description: short_desc,
                                         title: title,
                                         image: image,
                                         image_file_name: filename,
                                         long_description: full_desc,
                                         store_ids: store_ids,
                                         category_ids: category_ids,
                                         old_price: old_price,
                                         yandex_market_export: yandex_market_export
                                        }})
  end

  # @src_for_csv = []
  art_count = []
  start = Time.now
  array_of_articles = [(1540..1540)]
  # array_of_articles = [(1005..4800), (5100..5320), (6050..6970), (7050..7950), (8000..9100), (20624..20780), (39000..39010), (77160..77170)]
  array_of_articles.each do |range|
    range.each do |product_id|   # Art from 1007 to 77169

      result = get_lm_product_data_liquimoly_ru(product_id)
      next if result[:sku].nil?
      art = result[:sku].rpartition(' ').last
      art_count << art

      if result[:weight].include?('шт')
        weight = ' (' + 0.1.to_s + ' кг)'
        weight_num = 0.1
      else
        weight = ' (' + result[:weight].split(' ')[-2] + ' л)'
        weight_num = result[:weight].split(' ')[-2]
      end

      if /[0-9]-[A-Z]/.match(result[:short_desc])
        data = result[:short_desc].partition(/[0-9]-[A-Z]/)
        short_desc = data[0].to_s.lstrip.rstrip.squeeze(" ") + '.'
        title ='Liqui Moly ' + data[1..data.length].join.squeeze(" ") + weight + " (art: #{art})"

        if /[A-Z]/.match(short_desc)
          data_array = short_desc.split
          data_title = data_array.pop
          short_desc = data_array.join(' ') + '.'
          title ='Liqui Moly ' + data_title.gsub(/[.]/, ' ').rstrip + data[1..data.length].join.squeeze(" ") + weight + " (art: #{art})"
        end
      else
        data = result[:short_desc].partition(/[A-Z]/)
        short_desc = data[0].to_s.rstrip.lstrip.squeeze(" ") + '.'
        title = 'Liqui Moly ' + data[1..data.length].join.squeeze(" ") + weight + " (art: #{art})"
      end

      case
      when short_desc.length > 64
        puts "short_desc length > 64    #{art}"
      end

      if short_desc.length > 64   # For Extrastore
        data = short_desc[0..63].split(' ')
        data.pop
        short_desc = data.join(' ').rstrip + '.'
      end

      if short_desc.include?('масло')   # For Extrastore
        category_ids = [1206]
      elsif short_desc.include?('салфетки')
        category_ids = [1277]
      else
        category_ids = [1201]
      end

      image_result = get_lm_product_image(product_id)
      image = image_result[:image]
      filename = image_result[:filename]

      full_desc = '<p><h3>Свойства</h3></p>' + "#{result[:props]}" + '<p><h3>Применение</h3></p>' + "#{result[:apps]}"   # For Extrastore

      barcode = barcode_from_product_art(art)

      sku = barcode

      purch_price = get_purchase_price(art)   # For Extrapost
      next if purch_price <= 30

      price = (purch_price * 1.357).round

      old_price = (purch_price * 1.531).round   # For Extrastore

      country_of_origin = 'DE'  # For Extrapost

      store_ids = [100]   # Avto-Raketa in Extrastore

      store_id = 3   # Avto-Raketa in Extrapost

      availability = 'on_demand'   # For Extrastore

      yandex_market_export = true   # For Extrastore

      # puts short_desc, title, '- - - - - - -'

      # create_product_extrapost(purch_price, sku, barcode, store_id, price, short_desc, title, weight_num, image, filename, country_of_origin)
      # update_product_extrapost(purch_price, sku, barcode, store_id, price, short_desc, title, weight_num, image, filename, country_of_origin)
      # create_product_extrastore(sku, old_price, price, short_desc, full_desc, title, image, filename, category_ids, store_ids, yandex_market_export, availability)
      update_product_extrastore(sku, old_price, price, short_desc, full_desc, title, image, filename, category_ids, store_ids, yandex_market_export)

      puts sku, old_price, price, short_desc, full_desc, title, filename, category_ids, store_ids, yandex_market_export, '= = = = = = ='
      # puts weight, weight_num, store_id, sku, purch_price, price, old_price, short_desc, title, filename, category_ids, availability, store_ids, '= = = = = = = ='
      # puts title, short_desc

      case
      when /[^0-9]/.match(barcode)
        puts "barcode is NAN   #{art}"
      when barcode.length > 13
        puts "barcode too big   #{art}"
      when art.include?('*')
        puts "product is not available for order   #{art}"
      when purch_price.to_f <= 30
        puts "purchase_price too small   #{art}"
      when price.to_f <= 30
        puts "price too small   #{art}"
      when price.to_f < purch_price.to_f
        puts "purchase_price too big   #{art}"
      when /[^0-9.,]/.match(purch_price.to_s)
        puts "purchase_price is NAN   #{art}"
      when /[^0-9.,]/.match(price.to_s)
        puts "price is NAN   #{art}"
      when short_desc.length > 64
        puts "short_desc length > 64    #{art}"
      when sku.length > 32
        puts "sku > 32   #{art}"
      end
    end
  end

  puts 'Number of goods:   ' + "#{art_count.size}", '- - - - -'
  finish = Time.now
  end_time = (finish - start).round
  if end_time >= 3600
    puts end_time/60.round.to_s + ' hours ' + (end_time - (end_time/60.round)).to_s + ' sec'
  else
    puts end_time.to_s + ' sec'
  end

        # if /[0-9]/.match(result[3])
        #   short_desc = /.+[А-Яа-я0-9]-.+[А-Яа-я]/.match(result[3]).to_s + '.'
        #   if short_desc == '.'
        #     short_desc = result[3].gsub(/[^А-Яа-я ( ) . "]/, ' ').rstrip.squeeze(" ") + '.'
        #   end
        #
        #   title_data = result[3].split
        #   data_array = []
        #   title_data.each do |name|
        #     if /[A-Za-z0-9]/.match(name)
        #       title_data = data_array << name
        #       @title ='Liqui Moly ' + title_data.join(' ').squeeze(" ") + " (#{weight} л)" + " (art: #{art})"
        #     end
        #   end
        # else
        #   short_desc = result[3].gsub(/[^А-Яа-я ( ) . "]/, ' ').rstrip.squeeze(" ") + '.'
        #   @title ='Liqui Moly ' + result[3].gsub(/[А-Яа-я ( ) . "]/, ' ').lstrip.squeeze(" ") + " (#{weight} л)" + " (art: #{art})"
        # end

    # result = get_lm_product_data(product_id)
    # next if result[0].nil?
    #
    # get_purchase_price(result[0])
    #
    # art = result[0]
    # art_count << art
    #
    # barcode = barcode_from_product_art(result[0])
    #
    # sku = barcode
    #
    # price = result[3]
    # old_price = result[6]
    # if result[3] == nil then old_price end
    #
    # purchase_price = get_purchase_price(result[0])   # For Extrapost
    #
    # weight = result[5][0..-2].gsub(/[a-zA-Zа-яА-Я ]/, '') if /[a-zA-Zа-яА-Я]/.match(result[5])   # For Extrapost

    #
    # full_desc = result[1]   # For Extrastore
    #

    #
    # if result[2].include?(' — ')
    #   data = result[2].partition(' — ')
    #   short_desc = data.last.split
    #   short_desc[-2, 2] = nil
    #   short_desc = short_desc.compact!.join(' ') + '.'
    #   # sku_full = "lm_#{data.first.downcase.gsub(/-|[ ]/, '_')}_#{weight}"
    #   @title = "Liqui Moly #{data.first} (#{weight} kg) (art: #{art})"
    # elsif
    #   result[2].include?(' - ')
    #   data = result[2].partition(' - ')
    #   short_desc = data.last.split
    #   short_desc[-2, 2] = nil
    #   short_desc = short_desc.compact!.join(' ') + '.'
    #   @title = "Liqui Moly #{data.first} (#{weight} kg) (art: #{art})"
    #   # sku_full = "lm_#{data.first.downcase.gsub(/-|[ ]/, '_')}_#{weight}"
    # else
    #   short_desc = ''
    #   title_src = ''
    #   data = result[2].split(' ') unless result[2].nil?
    #   data.each do |word|
    #     if /[А-Яа-я]/.match(word)
    #       short_desc = short_desc + word + ' '
    #     else
    #       /[a-zA-Z]/.match(word)
    #       title_src = title_src + word + ' '
    #     end
    #     # sku_full = "lm_#{title_src.downcase.gsub(/-|[ ]/, '_')}_#{weight}"
    #     @title = "Liqui Moly #{title_src} (#{weight} kg) (art: #{art})"
    #   end
    # end
    #




    # @src_for_csv << ["#{art}", "#{title}", "#{short_desc}", "#{sku_full}", "#{barcode}", "#{purchase_price}", "#{price}", "#{weight}", "#{full_desc}"]

    # if sku_full.length > 32
    #     sku_full_part = sku_full.gsub(/_/, ' ').split
    #     sku_full_part_new = sku_full_part.map { |word| word.length >= 10 ? word = word[0..4] : word }
    #     sku_full_part_new = "#{sku_full_part_new.join('_')}"
    #     sku_full = sku_full_part_new
    #
    #     if sku_full_part_new.length > 32
    #         sku_part = sku_full_part_new.gsub(/_/, ' ').split
    #         sku_part_new = sku_part.map { |word| word.length <= 9 && word.length >= 5 ? word = word[0..2] : word }
    #         sku_part_new = "#{sku_part_new.join('_')}"
    #         sku_full = sku_part_new
    #
    #         if sku_part_new.length > 32
    #             sku_part_end = sku_part_new.gsub(/_/, ' ').split
    #             sku_part_end.delete_at(1)
    #             sku_full = "#{sku_part_end.join('_')}"
    #         else
    #           sku_full
    #         end
    #     else
    #       sku_full
    #     end
    # else
    #   sku_full
    # end

  # # To add a header, the columns should be written monotonously with the header (each data column separately)
  #
  # # The method is used once for one file.
  # def save_new_file
  #   header = ["Art", "Title", "Short description", "SKU", "Barcode", "Purchase price", "Price", "Weight", "Full_desc"]
  #   CSV.open('Price_LM.csv', 'w', { encoding: "UTF-8", col_sep: ';', headers: true }) do |csv|
  #     csv << header
  #     @src_for_csv.sort.each do |row|
  #       csv << row
  #     end
  #   end
  # end
  # # save_new_file
  #
  # # Read file as individual rows, can translate it into an array (with a header representation) and string (without header representation)
  # # table.delete('Name') - Remove the column
  # # table.delete(0) - Remove a row
  # def add_new_products
  #   table = CSV.read('Price_LM.csv', { encoding: "UTF-8", col_sep: ';', headers: true })  # Same as CSV.parse(File.read('Price_LM.csv'))
  #   @src_for_csv.sort.each do |row|
  #     if table['Art'].include?(row[0])
  #       next
  #     else
  #       table << row
  #     end
  #   end
  #
  #   header = ["Art", "Title", "Short description", "SKU", "Barcode", "Purchase price", "Price", "Weight", "Full_desc"]
  #    CSV.open('Price_LM.csv', 'w', { encoding: "UTF-8", col_sep: ';', headers: true }) do |csv|
  #      csv << header
  #      table.each do |row|
  #        csv << row
  #      end
  #    end
  #
  # # Sorting rows in a file by art
  #   data = CSV.read('Price_LM.csv', { encoding: "UTF-8", col_sep: ';' }).to_a.sort
  #   data.pop
  #
  #   header = ["Art", "Title", "Short description", "SKU", "Barcode", "Purchase price", "Price", "Weight", "Full_desc"]
  #    CSV.open('Price_LM.csv', 'w', { encoding: "UTF-8", col_sep: ';', headers: true }) do |csv|
  #      csv << header
  #      data.each do |row|
  #        csv << row
  #      end
  #    end
  # end
  # # add_new_products
  #
  # def add_goods_to_extrapost
  # # Read the file as individual columns.
  #   CSV.foreach('Price_LM.csv', { encoding: "UTF-8", col_sep: ';', headers:true }) do |col|   # Same as CSV.parse('Price_LM.csv') { |row| puts row}
  #     art = col[0]
  #     if art
  #       title = col[1]
  #       short_desc = col[2]
  #       sku = col[3]
  #       barcode = col[4]
  #       purchase_price = col[5]
  #       price = col[6]
  #       weight = col[7]
  #       store_id = 3
  #       country_of_origin = 'DE'
  #       # puts filename, purchase_price, sku, barcode, store_id, price, short_desc, title, weight, '- - - - - - - -'
  #     end
  #     filename = title + @content_type_data
  #     image = @image
  #     # create_product_extrapost(purchase_price, barcode, store_id, price, short_desc, title, weight, image, filename, country_of_origin)
  #     update_product_extrapost(purchase_price, barcode, store_id, price, short_desc, title, weight, image, filename, country_of_origin)
  #   end
  # end
  # # add_goods_to_extrapost
  #
  # def add_goods_to_extrastore
  # # Read the file as individual columns.
  #   CSV.foreach('Price_LM.csv', { encoding: "UTF-8", col_sep: ';', headers:true }) do |col|   # Same as CSV.parse('Price_LM.csv') { |row| puts row}
  #     art = col[0]
  #     if art
  #       title = col[1]
  #       short_desc = col[2]
  #       sku = col[3]
  #       price = col[6]
  #       full_desc = col[8]
  #       store_ids = [100]
  #       filename = title + @content_type_data
  #       image = @image
  #       puts filename, sku, price, short_desc, title, '- - - - - - - -'
  #     end
  #     create_product_extrastore(sku, price, short_desc, title, image, filename, full_desc, store_ids)
  #   end
  # end
  # # add_goods_to_extrastore
