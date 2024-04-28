FactoryBot.define do
    factory :order_shipping do
      postal_code { '123-4567' }
      prefecture_id { 1 }
      city { '東京都' }
      address { '1-1' }
      building { '東京ハイツ' }
      phone_number { '09012345678' }
      token { 'tok_abcdefghijk00000000000000000' }
      user_id { nil }  # これはbeforeブロックで設定します
      item_id { nil }  # これはbeforeブロックで設定します
    end
  end