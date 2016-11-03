class ProductsController < ApplicationController
  before_filter :fetch_product, only: [:update,:delete]

  # GET /products
  def index
    products = Product.all.order(name: :asc).map{|p|
      {
        id: p.id,
        name: p.name,
        net_price: p.net_price
      }
    }
    format_response(products,"products") and return
  end

  # POST /products
  # Parameters
  #   :name       The name of the product
  #   :net_price  The net price of the product
  def create
    product = Product.new(
      name: params[:name],
      net_price: params[:net_price]
    )

    if product.save
      format_response({ success: true, message: "Product '#{product.name}' has been created" }) and return
    else
      format_response({ success: false, message: product.errors.full_messages.to_sentence }) and return
    end
  end

  # PUT|PATCH /products/:id
  # Parameters
  #   :name       The new name of the product (optional)
  #   :net_price  The new net price of the product (optional)
  def update
    @product.name = params[:name] unless params[:name].blank?
    @product.net_price = params[:net_price].to_d unless params[:net_price].blank?
    
    if @product.save
      format_response({ success: true, message: "Product '#{@product.name}' has been updated" }) and return
    else
      format_response({ success: false, message: @product.errors.full_messages.to_sentence }) and return
    end
  end

  # DELETE /products/:id
  def destroy
    unless @product.orders.any?
      name = @product_name
      @product.destroy
      format_response({ success: true, message: "Product '#{name}' has been deleted" }) and return
    else
      format_response({ success: false, message: "Product '#{name}' has been ordered and cannot be deleted" }) and return
    end
  end

  private
  def fetch_product
    @product = Product.find_by_id(params[:id])
    format_response({ success: false, message: "Product not found" }) and return if @product.blank?
  end
end
