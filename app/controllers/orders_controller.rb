class OrdersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_item, only: [:index, :create]
  before_action :set_public_key, only: [:index, :create]
  before_action :redirect_unless_available, only: [:index]

  def index
    @order_shipping = OrderShipping.new
  end

  def create
    @order_shipping = OrderShipping.new(order_params)
    if @order_shipping.valid?
      pay_item # 決済処理を実行
      @order_shipping.save
      redirect_to root_path, notice: 'Order was successfully created.'
    else
      render :index, status: :unprocessable_entity # 公開鍵のセットを削除
    end
  end

  private

  def order_params
    params.require(:order_shipping).permit(
      :postal_code, :prefecture_id, :city, :address, :building, :phone_number
    ).merge(item_id: @item.id, user_id: current_user.id, token: params[:token])
  end

  def set_item
    @item = Item.find(params[:item_id])
  end

  def set_public_key
    gon.public_key = ENV['PAYJP_PUBLIC_KEY']
    Rails.logger.info "Setting public key: #{gon.public_key}" # ログ出力
  end

  def redirect_unless_available
    return unless current_user.id == @item.user_id || @item.order.present?

    redirect_to root_path, alert: 'This item is not available for purchase.'
  end

  def pay_item
    Payjp.api_key = ENV['PAYJP_SECRET_KEY']
    charge = Payjp::Charge.create(
      amount: @item.price,
      card: order_params[:token],
      currency: 'jpy'
    )
    return if charge.paid

    render :index, alert: 'Payment failed.', status: :unprocessable_entity
    nil
  end
end
