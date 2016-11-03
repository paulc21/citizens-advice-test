class LineItemsController < ApplicationController
  before_filter :fetch_order

  # POST /orders/:order_id/items
  # Parameters
  #   :product    The product ID
  #   :quantity   The quantity to add to the order
  def create
    product = Product.find_by_id(params[:product])
    format_response({ success: false, message: "Product ##{params[:product_id]} not found" }) and return if product.blank?

    existing_items = @order.line_items.where(product_id: product.id)
    format_response({ success: false, message: "Product #{product.name} is already in Order ##{@order.id}" }) and return if existing_items.any?

    line_item = LineItem.new(
      order: @order,
      product: product,
      quantity: params[:quantity].to_i
    )

    if line_item.save
      format_response({ success: true, message: "Product #{line_item.name} (#{line_item.quantity}) added to Order ##{@order.id}" }) and return
    else
      format_response({ success: false, message: line_item.errors.full_messages.to_sentence }) and return
    end
  end

  # PUT|PATCH /orders/:order_id/items/:id
  # Parameters
  #   :quantity   The new quantity
  def update
    line_item = @order.line_items.where(id: params[:id]).first
    format_response({ success: false, message: "Item ##{line_item.id} could not be found" }) and return if line_item.blank?

    line_item.quantity = params[:quantity].to_i
    if line_item.save
      format_response({ success: true, message: "Item ##{line_item.id} has been updated" }) and return
    else
      format_response({ success: false, message: line_item.errors.full_messages.to_sentence }) and return
    end
  end
  
  # DELETE /orders/:order_id/items/:id
  def destroy
    line_item = @order.line_items.where(id: params[:id]).first
    format_response({ success: false, message: "Item ##{params[:id]} could not be found" }) and return if line_item.blank?

    line_item.destroy
    format_response({ success: true, message: "Item ##{params[:id]} has been deleted from Order ##{@order.id}" }) and return
  end

  private
  def fetch_order
    @order = Order.find_by_id(params[:order_id])
    format_response({ success: false, message: "The requested order could not be found" }) and return if @order.blank?
    format_response({ success: false, message: "The requested order can no longer be edited" }) and return unless @order.draft?
  end
end
