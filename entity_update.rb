require 'csv'
require 'json'
require 'pry'
require 'shopify_api'

class Update

  DOMAIN = "pdc-promovision.myshopify.com".freeze
  TOKEN = "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".freeze
  API_VERSION = "2021-01".freeze
  
  KEY = "also-known-as".freeze
  NAMESPACE = "global".freeze
  VALUE_TYPE = "string".freeze
  
  JSON_FILE = "files/data.json"
  PRODUCT_DATA = "files/products.csv"
  # Change your file name here
  SKU_FILE = "files/product-pv-number.csv"

  def self.create_json
    puts "#{SKU_FILE}=========="
    rows = CSV.read(SKU_FILE)
    header = rows.delete rows.first
    sku  = header.find_index('sku')

    # Change your file column name here
    entity = header.find_index('pv_partno')
    tmp_val = []
    File.open(JSON_FILE, 'wb') do |f|
      rows.each do |values|
        if values != nil && values[0] != nil
          tmp_val << { sku: values[sku], content: values[entity] }
        end
      end
      f.puts JSON.pretty_generate(tmp_val)
    end
  end

  def self.price
    file = File.open JSON_FILE
    data = JSON.load file

    rows = CSV.read(PRODUCT_DATA)
    header = rows.delete rows.first

    sku, id = header.find_index('SKU'), header.find_index('ID')
    count = 0 
    rows.each do |row|
      prod = nil;
      next unless row[sku].present?

      prod = data.find { |h1| next if h1 == nil; h1["sku"] == row[sku] }
      next  unless prod.present?
      puts "Running no: --- #{count}"
      update_to_shopify(row[id], prod["quantity"])
      count += 1
    end

  end

  def self.update_to_shopify(product_id, quantity)
    puts "#{product_id}-----------#{quantity}"
    ShopifyAPI::Session.temp(domain: DOMAIN, token: TOKEN, api_version: API_VERSION) do
      data = ShopifyAPI::Product.find(product_id)
      data.published_scope = "global"
      data.published_at = Time.now
      data.status = "active"
      # data.variants.each do |variant|
      #   # variant.price = price.to_f
      #   begin
      #     params = { inventory_item_ids: "#{variant.inventory_item_id}" }
      #     puts params
      #     inventory = ShopifyAPI::InventoryLevel.find(:all, params: params)
      #     inventory[0].set(quantity.to_i)
      #     sleep(0.4)
      #   rescue StandardError => error
      #     puts "#{product_id}&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&#{quantity}, #{error}"
      #   end
      # end
      data.save
      sleep(0.3)
    end
  end

  def self.shopify_tags
   
    file = File.open JSON_FILE
    data = JSON.load file

    rows = CSV.read(PRODUCT_DATA)
    header = rows.delete rows.first

    sku, id = header.find_index('SKU'), header.find_index('ID')
    
    rows.each do |row|
      prod = nil;
      next unless row[sku].present?

      prod = data.find { |h1| next if h1 == nil; h1["sku"] == row[sku] }
      next  unless prod.present?

      puts "#{row[id]}-----------#{prod["content"]}"
      ShopifyAPI::Session.temp(domain: DOMAIN, token: TOKEN, api_version: API_VERSION) do
        product = ShopifyAPI::Product.find(row[id])
        puts "#{product.tags}, #{prod["content"]}"
        product.tags = "#{product.tags}, #{prod["content"]}"
        product.save
        sleep(0.3)
      end
    end

  end


  def self.metafiled
    file = File.open JSON_FILE
    data = JSON.load file

    rows = CSV.read(PRODUCT_DATA)
    header = rows.delete rows.first

    sku, id = header.find_index('SKU'), header.find_index('ID')
    ShopifyAPI::Session.temp(domain: DOMAIN, token: TOKEN, api_version: API_VERSION) do
      rows.each do |row|
        prod = nil;
        next unless row[sku].present?
  
        prod = data.find { |h1| next if h1 == nil; h1["sku"] == row[sku] }
        next  unless prod.present?
        
        puts "======================#{row[id]}------#{row[sku]}--------------#{prod["content"]}"
        product = ShopifyAPI::Product.find(row[id])
        metafield = ShopifyAPI::Metafield.new(key: KEY, namespace: NAMESPACE, value: prod["content"], value_type: VALUE_TYPE)
        product.add_metafield(metafield)
        sleep(0.2)
      end
    end
  end

end

Update.create_json
Update.metafiled



