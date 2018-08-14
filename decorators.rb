# DECORATORS
# Help extract presentation logic out of the models by
# a) Wrapping them
# b) Providing a transparent API
# c) Adding a couple of methods of their own

# Model is polluted with view-related business logic
class Post < ActiveRecord::Base
  def is_front_page?
    published_at > 2.days.ago
  end
end

class PostsController < ApplicationController
  def show
    @post = Post.find(params[:id])
  end
end

# app/views/posts/show.html.erb
#<% if @post.is_front_page? %>
#  <%= image_tag(@post.image) $>
#<% end %>

# Decorators help us to extract presentation logic
# app/decorators/post_decorator.rb

class PostDecorator
  attr_reader :post

  def initialize(post)
    @post = post
  end

  def is_front_page?
    post.published_at > 2.days.ago
  end

  # Forwards any undefined method to the wrapped object
  def method_missing(method_name, *args, &block)
    post.send(method_name, *args, &block)
  end

  def respond_to_missing?(method_name, include_private = false)
    post.respond_to?(method_name, include_private) || super
  end
end

class Post < ActiveRecord::Base
end

class PostsController < ApplicationController
  def show
    post = Post.find(params[:id])
    @post_decorator = PostDecorator.new(post)
  end
end

#<% if @post.is_front_page? %>
#  <%= image_tag(@post.image) $>
#<% end %>

# Using decorators for view output

# Bad
module PostHelper
  def publication_date(post)
    post.created_at.strftime '%Y-%m-%d'
  end
end

#app/views/posts/show.html.erb
# <span><%= publication_date @post %> </span>

# Issues with using helpers receiving an object as argument
# - Pollute the global namespace with methods specific to a model
# - Forces a functional approach within an object oriented domain model
# - Still allowed to be used with other objects, that would be wrong

# Good

class PostDecorator
  ...
  def publication_date
    post.created_at.strftime '%Y-%m-%d'
  end
end

# Using decorators for HTML output

# Bad
# Does not scale well as the view-logic grows
module PostsHelper
  def post_classes(post)
    classes = ['page']
    classes < 'front-page' if post.is_front_page?
    classes
  end
end

# app/views/posts/show.html.erb
# <article class="<%= post_classes(@post) %>" >
#   <%= @post.content %>
# </article>

# Good
class PostDecorator
  ...
  def post_classes(post)
    classes = ['page']
    classes < 'front-page' if post.is_front_page?
    classes
  end
end

# app/views/posts/show.html.erb
# <article class="<%= @post_decorator.classes %>" >
#   <%= @post_decorator.content %>
# </article>