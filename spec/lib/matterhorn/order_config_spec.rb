require 'spec_helper'

RSpec.describe 'Matterhorn::Serialization' do

  let!(:order_config) { Matterhorn::Ordering::OrderConfig.new }

  it "should allow adding orders" do
    order_config.add_order(:recent, :created_at.desc)
    order_config.order_for(:recent).should == [:created_at.desc]
  end

  it "should raise an exception if an invalid order is asked" do
    expect { order_config.order_for(:recent) }.to raise_exception(Matterhorn::Ordering::InvalidOrder)
  end

  it "should raise an exception if you try to set an invalid default order" do
    expect { order_config.set_default_order(:recent) }.to raise_exception(Matterhorn::Ordering::InvalidDefaultOrder)
  end

  it "should set a default order" do
    order_config.add_order(:recent, :created_at.desc)
    order_config.set_default_order(:recent)
    order_config.default_order.should == :recent
  end
end
