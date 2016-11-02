class OrdersController < ApplicationController
  before_filter :fetch_order, except: [:index,:create]

  # GET /orders
  def index
    orders = Order.all.order(order_date: :desc)

    if orders.any?
      format_response(orders.map{|o|
        {
          id: o.id,
          user: o.user.email,
          status: o.aasm_state,
          net_total: o.net_total
        }
      }, "orders") and return
    else
      format_response({ status: 404, message: "No orders found" }) and return
    end
  end

  # GET /orders/:id
  def show
    o = {
      id: @order.id,
      email: @order.user.email,
      status: @order.aasm_state,
      items: @order.line_items.map{|li|
        {
          name: li.name,
          init_price: li.net_price,
          quantity: li.quantity,
          net_subtotal: li.subtotal
        }
      },
      net_total: @order.net_total,
      gross_total: @order.gross_total
    }
    if @order.cancelled?
      o[:cancel_reason] = @order.cancel_reason
    end
    
    format_response(o,"order") and return
  end

  # POST /orders
  # Parameters
  #   :user_id
  def create
  end

  # ----------------------------------------------- #
  # Status changes
  # ----------------------------------------------- #
  # GET|POST /orders/:id/place
  def place
    if @order.may_place?
      @order.place!
      redirect_to order_path(@order.id, format: params[:format]) and return
    else
      format_response({ status: 403, message: "The requested order could not be placed (current status: #{@order.aasm_state})"}) and return
    end
  end

  # GET|POST /orders/:id/pay
  def pay
    if @order.may_pay?
      @order.pay!
      redirect_to order_path(@order.id, format: params[:format]) and return
    else
      format_response({ status: 403, message: "The requested order could be paid (current status: #{@order.aasm_state})"}) and return
    end
  end

  # GET|POST /orders/:id/cancel
  # Parameters
  #   :cancel_reason    A short reason for the cancellation
  def cancel
    if params[:cancel_reason].blank?
      format_response({ status: 400, message: "A cancellation reason is required"}) and return
    end

    @order.cancel_reason = params[:cancel_reason]
    if @order.may_cancel?
      @order.cancel!
      redirect_to order_path(@order.id, format: params[:format]) and return
    else
      format_response({ status: 403, message: "The requested order could not be cancelled (current status: #{@order.aasm_state})"}) and return
    end
  end

  private
  def fetch_order
    @order = Order.find_by_id(params[:id])
    format_response({ status: 404, message: "The requested order could not be found" }) and return if @order.blank?
  end
end
