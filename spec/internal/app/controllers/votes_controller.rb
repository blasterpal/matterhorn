class VotesController < Matterhorn::Base
  include Matterhorn::Resources
  resources!

  # belongs_to :post

  allow_collection_params \
    :include

protected ######################################################################

  def read_resource_scope
    end_of_association_chain
  end

  def write_resource_scope
    end_of_association_chain
  end

end
