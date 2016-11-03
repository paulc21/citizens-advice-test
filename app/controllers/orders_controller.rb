class OrdersController < ApplicationController
  before_filter :fetch_order, except: [:index,:create]

  # GET /orders
  def index
    orders = Order.all.order(order_date: :desc).map{|o|
      order_to_hash(o)
    }
    format_response(orders, "orders") and return
  end

  # GET /orders/:id
  def show
    o = order_to_hash(@order)
    format_response(o,"order") and return
  end

  # POST /orders
  # Parameters
  #   :user             The ID of the User who is creating this order
  #   :vat_percentage   The VAT percentage to apply to this order (optional)
  def create
    order = Order.new(
      user_id: params[:user]
    )
    order.vat_percentage = params[:vat_percentage].to_d unless params[:vat_percentage].blank?
    if order.save
      format_response({ success: true, message: "Order #{order.id} created" }) and return
    else
      format_response({ success: false, message: order.errors.full_messages.to_sentence }) and return
    end
  end

  # ----------------------------------------------- #
  # Status changes
  # ----------------------------------------------- #
  # GET|POST /orders/:id/place
  def place
    if @order.may_place?
      @order.place!
      format_response({ success: true, message: "Order ##{@order.id} has been placed" }) and return
    else
      format_response({ success: false, message: "The requested order could not be placed (current status: #{@order.aasm_state})"}) and return
    end
  end

  # GET|POST /orders/:id/pay
  def pay
    if @order.may_pay?
      @order.pay!
      format_response({ success: true, message: "Order ##{@order.id} has been paid" }) and return
    else
      format_response({ success: false, message: "The requested order could be paid (current status: #{@order.aasm_state})"}) and return
    end
  end

  # GET|POST /orders/:id/cancel
  # Parameters
  #   :cancel_reason    A short reason for the cancellation
  def cancel
    if params[:cancel_reason].blank?
      format_response({ success: false, message: "A cancellation reason is required"}) and return
    end

    @order.cancel_reason = params[:cancel_reason]
    if @order.may_cancel?
      @order.cancel!
      format_response({ success: true, message: "Order ##{@order.id} has been cancelled (#{@order.cancel_reason})" }) and return
    else
      format_response({ success: false, message: "The requested order could not be cancelled (current status: #{@order.aasm_state})"}) and return
    end
  end

  private
  def fetch_order
    @order = Order.find_by_id(params[:id])
    format_response({ success: false, message: "The requested order could not be found" }) and return if @order.blank?
  end

  def order_to_hash(_order)
    o = {
      id: _order.id,
      user: _order.user.email,
      order_date: _order.order_date,
      status: _order.aasm_state,
      items: _order.line_items.map{|li|
        {
          name: li.name,
          unit_price: li.net_price,
          quantity: li.quantity,
          net_subtotal: li.subtotal
        }
      },
      net_total: _order.net_total,
      vat_percentage: _order.vat_percentage,
      gross_total: _order.gross_total
    }
    if _order.cancelled?
      o[:cancel_reason] = _order.cancel_reason
    end

    return o
  end
end
