class OrdersController < ApplicationController
  before_filter :fetch_order, except: [:index,:create]

  # GET /orders
  def index
    orders = Order.all.order(order_date: :desc)

     format_response(orders.map{|o|
      {
        id: o.id,
        user: o.user.email,
        status: o.aasm_state,
        net_total: o.net_total
      }
     }, "orders") and return
  end

  # GET /orders/:id
  def show
    format_response({
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
    },"order") and return
  end

  # POST /orders
  # Parameters
  #   :user_id
  def create
  end

  # POST /orders/:id
  def update
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
      format_response({ status: 403, message: "The requested order could not be placed"}) and return
    end
  end

  # GET|POST /orders/:id/pay
  def pay
    if @order.may_pay?
      @order.pay!
      redirect_to order_path(@order.id, format: params[:format]) and return
    else
      format_response({ status: 403, message: "The requested order could be paid"}) and return
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
      format_response({ status: 403, message: "The requested order could not be cancelled"}) and return
    end
  end

  # ----------------------------------------------- #
  # Item management
  # Might be better putting this in its own controller?
  # ----------------------------------------------- #

  # GET|POST /orders/:id/add_item?product=:product_id&quantity=:quantity
  def add_item
    product = Product.find_by_id(params[:product])
    if product.blank?
      format_response({ status: 404, message: "Product not found" }) and return
    end

    # we should check for an existing line item with this product id and increase the quantity
    existing_items = @order.line_items.where(product_id: product.id)
    if existing_items.any?
      existing_items.first.increment!(:quantity,params[:quantity].to_i)
    else
      line_item = LineItem.new(
        order: @order,
        product: product,
        quantity: params[:quantity].to_i
      )

      unless line_item.save
        format_response({ status: 500, message: line_item.errors.full_messages.to_sentence }) and return
      end
    end
    redirect_to order_path(@order.id, format: params[:format]) and return
  end

  def delete_item
  end

  private
  def fetch_order
    @order = Order.find_by_id(params[:id])
    format_response({ status: 404, message: "The requested order could not be found" }) and return if @order.blank?
  end
end
