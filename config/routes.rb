GoodsCards::Application.routes.draw do

  root to: 'prices#prepayment'
  match '/welcome' => 'prices#welcome'
  # match '/price_liqui_moly' => 'prices#price_liqui_moly'      # second route

end
