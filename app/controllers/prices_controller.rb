class PricesController < ApplicationController

  def prepayment
    pdf = PrepaymentPrice.new
    pdf.print_prepayment
    send_data pdf.render, type: 'application/pdf', filename: 'prepayment.pdf', disposition: 'inline'
  end

end
