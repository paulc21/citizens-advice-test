class LineItemsController < ApplicationController
  before_filter :fetch_order

  # POST /orders/:order_id/items
  def create
    product = Product.find_by_id(params[:product])
    if product.blank?
      format_response({ status: 404, message: "Product not found" }) and return
    end

    # we should check for an existing line item with this product id and increase the quantity
    existing_items = @order.line_items.where(product_id: product.id)
    if existing_items.any?
      format_response({ status: 403, message: "The requested product is already in your order" }) and return
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

  # PUT|PATCH /orders/:order_id/items/:id
  # Parameters
  #   :quantity   The new quantity
  def update
    item = @order.line_items.where(id: params[:id]).first
    format_response({ status: 404, message: "The requested item could not be found" }) and return if item.blank?

    item.quantity = params[:quantity].to_i
    if item.save
      redirect_to order_path(@order.id,format:params[:format]) and return
    else
      format_response({ status: 500, message: item.errors.full_messages.to_sentence }) and return
    end
  end
  
  # DELETE /orders/:order_id/items/:id
  def destroy
    item = @order.line_items.where(id: params[:id]).first
    format_response({ status: 404, message: "The requested item could not be found" }) and return if item.blank?

    item.destroy
    redirect_to order_path(@order.id, format: params[:format]) and return
  end

  private
  def fetch_order
    @order = Order.find_by_id(params[:order_id])
    format_response({ status: 404, message: "The requested order could not be found" }) and return if @order.blank?
    format_response({ status:400, message: "The requested order can no longer be edited" }) and return unless @order.draft?
  end
end
