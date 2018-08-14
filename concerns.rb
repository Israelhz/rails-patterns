# CONCERNS
# Help extract duplicate code into reusable modules that can be mixed
# into multiple controllers or models

class Post < ActiveRecord::Base
  has_many :comments, as: :commentable

  def comments_by_user(id)
    comments.where(user_id: id)
  end
end

class Image < ActiveRecord::Base
  has_many :comments, as: :commentable

  def comments_by_user(id)
    comments.where(user_id: id)
  end
end

class Comment < ActiveRecord::Base
  belongs_to :commentable, polymorphic: true
end

# We have duplicated code in Post and Image
# Concerns help us to extract functionality

# path: app/models/concerns/commentable.rb

module Commentable
  extend ActiveSupport::Cocern

  included do
    has_many :comments, as: :commentable
  end

  def comments_by_user(id)
    comments.where(user_id: id)
  end
end

class Post < ActiveRecord::Base
  include Commentable
end

class Image < ActiveRecord::Base
  include Commentable
end

# To insert class methods:
module Commentable
  extend ActiveSupport::Concern

  module ClassMethods
    def upvote(comment)
      ...
    end
  end
end

Image.upvote(@comment)

#ActiveSupport::Concern automatically includes methods from
# the ClassMethods module as class methods on the target class

# Concerns for controllers:
# Include concern in app/controllers/concerns/concern_name.rb

class VideoController < ApplicationController
  include Previewable
  def show
    @video = Video.find(params[:id])
    @thumbnail = thumbnail(@video)
  end
end

module Previewable
  def thumbnail(attachment)
    file_name = File.basename(attachment.path)
    "/thumbs/#{file_name}"
  end
end
