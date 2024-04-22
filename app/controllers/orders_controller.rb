class OrdersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_item, :set_public_key, only: [:index, :create]
  before_action :redirect_unless_available, only: [:index]

  def index
    @order_shipping = OrderShipping.new
  end

  def create
    @order_shipping = OrderShipping.new(order_shipping_params)
    if @order_shipping.valid?
      @order_shipping.save
      redirect_to root_path, notice: 'Order was successfully created.'
    else
      render :index
    end
  end

  private

  def set_item
    @item = Item.find(params[:item_id])
  end

  def set_public_key
    gon.public_key = ENV['PAYJP_PUBLIC_KEY']
  end

  def redirect_unless_available
    unless current_user.id != @item.user_id && @item.order.nil?
      redirect_to root_path, alert: 'This item is not available for purchase.'
    end
  end

  def order_shipping_params
    params.require(:order_shipping).permit(:postal_code, :prefecture_id, :city, :address, :building, :phone_number, :token).merge(user_id: current_user.id, item_id: @item.id)
  end
end
