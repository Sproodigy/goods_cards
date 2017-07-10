class PrepaymentPrice < Prawn::Document
  include ActionView::Helpers::NumberHelper

  def print_prepayment
    font_families.update(
      "DejaVuSans" => {
        normal: "#{Rails.root}/app/assets/fonts/DejaVuSans.ttf",
        bold: "#{Rails.root}/app/assets/fonts/DejaVuSans-Bold.ttf",
        italic: "#{Rails.root}/app/assets/fonts/DejaVuSans-Oblique.ttf",
        bold_italic: "#{Rails.root}/app/assets/fonts/DejaVuSans-BoldOblique.ttf",
        extra_light: "#{Rails.root}/app/assets/fonts/DejaVuSans-ExtraLight.ttf",
        condensed: "#{Rails.root}/app/assets/fonts/DejaVuSansCondensed.ttf",
        condensed_bold: "#{Rails.root}/app/assets/fonts/DejaVuSansCondensed-Bold.ttf"
      })
    font "DejaVuSans", size: 8

# разметка страницы
    stroke_horizontal_line 0, 540, at:  755

    stroke do
       vertical_line 735, 495, at: 270
       vertical_line 475, 235, at: 270
       vertical_line 210, -30, at: 270
    end

# определение сегмента
    def print_segment(x, y)

      line_width 1

      bounding_box([x, y], width: 280, height: 90) do

        text '______________________20       г. На _________________руб.______коп.'

        move_down 3
        text 'сумма прописью', size: 6, align: :center

        move_down 1
        12.times do |a|
          stroke_color 'dddddd'
          stroke_horizontal_line 0, 265, at:  cursor - (2 * a)
        end

        stroke_color '000000'
        move_down 30
        text 'м. п.          Дата_________________________№___________поручение'

        move_down 5
        text 'Гл. бухгалтер                            Бухгалтер', style: :bold

        line_width 2
        stroke_horizontal_line 0, 265, at: cursor-2
      end
    end

# определение блока сегментов
    def print_segments_block(x_1, y_1)

      bounding_box([x_1, y_1], width: 540) do
        text_box 'ПОСТУПЛЕНИЯ АВАНСОВ ПО РАСЧЁТАМ ЗА УСЛУГИ СВЯЗИ',
        at: [0, cursor+753], align: :center, style: :bold
          3.times do |c|
          2.times do |d|
            base_x = -10
            base_y = 740
            print_segment(base_x + (295 * d), base_y - (85 * c))
          end
          end

      end
    end

# печать блока сегментов
    3.times do |e|
      base_x = 0
      base_y = 0
      print_segments_block(base_x, base_y - (265 * e))
    end

      render

  end
end
