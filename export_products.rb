require 'csv'
require 'json'
require 'pry'
require 'shopify_api'

class ImportProduct
  DOMAIN = "pdc-promovision.myshopify.com".freeze
  TOKEN = "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".freeze
  API_VERSION = "2021-01".freeze

  def self.retrive()
    ShopifyAPI::Session.temp(domain: DOMAIN, token: TOKEN, api_version: API_VERSION) do
      next_page = true
      CSV.open("files/products.csv", 'wb') do |csv|
        csv << ['ID', 'SKU']
        products = ShopifyAPI::Product.all(:params => { limit: 250 })
        while next_page == true
          products.entries.each do |entry|
            variant = entry.variants.first
            csv << [ entry.id, variant.sku ]
          end
          sleep(0.2)
          next_page = products.next_page?
          products = products.fetch_next_page
        end
      end

    end
  end

end

ImportProduct.retrive

