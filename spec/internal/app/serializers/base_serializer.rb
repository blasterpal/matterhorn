class BaseSerializer < Matterhorn::Serialization::BaseSerializer
  attributes :_id,
             :_type

  def _type
    object.class.name.underscore
  end

end
