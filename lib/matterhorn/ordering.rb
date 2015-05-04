require "matterhorn/ordering/order_config"
module Matterhorn
  module Ordering

    extend ActiveSupport::Concern

    module ClassMethods

      attr_accessor :order_config

      def allow_order(name, *order)
        self.order_config.add_order(name, *order)
      end

      def default_order(name)
        self.order_config.set_default_order(name)
      end
    end

    included do
      self.order_config = OrderConfig.new

      allow_collection_params :order

      def order_config
        self.class.order_config
      end
    end
  end
end
