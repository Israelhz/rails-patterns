# Serializers
# ActiveModelSerializers replaces "hash-driven-development"
# with object oriented development

# - Decouples serialization code from the model
# - Convention over configuration
# - Access to url helper methods
# - Support for associations

# Serialization code should not be in controller

# Bad
class ItemsController < ApplicationController
  def index
    @items = Item.all

    respond_to do |format|
      format.html
      format.json {
        render json: @items,
                except: [:created_at, :updated_at],
                include: { comments: { only: :id} }
      }
    end
  end
end

# You can place the code in the model in as_json method
# but that breaks Single Responsability Principle

class Item < ActiveRecord::Base
  has_many :comments

  def as_json(params={})
    super(except: [:created_at, :updated_at],
      include: { comments: { only: :id}} )
  end
end

# To use active model serializers

gem 'active_model_serializers', github: 'rails-api/active_model_serializers'

# remove gem 'jbuilder', '~> 1.2'

class ItemsController < ApplicationController
  respond_to :json, :html
  def index
    @items = Item.all
    respond_with @items
  end
end

# Custom serializers
# rails g serializer Item
# app/serializers/item_serializer.br

class ItemSerializer < ActiveModel::Serializer
  attributes :id
end

# By convention, it looks for a serializer names after the class
render json: @items => { 'items': [{"id":1}, {"id":2}]}

# To override convention
render json: @items, serializer: SomeOtherSerializer

# To remove root node
render json: @items, root: false => [{"id":1}, {"id":2}]

class ItemsCollectionSerializer < ActiveModel::ArraySerializer
  self.root = false
end


# Custom properties

class ItemSerializer < ActiveModel::Serializer
  attributes :id, :name, :url

  def url
    item_url(object)
  end
  # item_url is a helper
  # object is the object being serialized
end

# Associations
class ItemSerializer < ActiveModel::Serializer
  attributes :id, :name, :url

  has_many :comments
  # When a custom serializer isnt found, the default Rails serialization is used
  def url
    item_url(object)
  end
end

# To embed only ids of associations
class ItemSerializer < ActiveModel::Serializer
  attributes :id, :name, :url

  has_many :comments, embed: :ids
  # When a custom serializer isnt found, the default Rails serialization is used
  def url
    item_url(object)
  end
end

class ItemSerializer < ActiveModel::Serializer
  attributes :id, :name, :url

  has_many :comments
  has_many :pictures

  # All existing associations will embed ids instead of objects
  embed :ids

  # Association will be included at the root level
  embed :ids, include: true
  # { 
  #    "comments" : [ { "id": 1106....}] 
  #    "items": [{"id": 133, "comment_ids":[1106,1107]}]
  # }
  # When a custom serializer isnt found, the default Rails serialization is used
  def url
    item_url(object)
  end
end

# Modify a method

class Comments < ActiveRecord::Base
  belongs_to :item
  scope :approved, -> { where(approved: true) }
end

class ItemSerializer < ActiveModel::Serializer
  attributes :id, :name
  has_many :comments
  def comments
    object.comments.approved
  end
end

# Add specific properties based on a condition
class ItemSerializer < ActiveModel::Serializer
  attributes :id, :name, :price

  def attributes
    data = super
    if current_user.premium_account?
      data[:discounted_price] = object.discounted_price
    end
    data
  end
end
