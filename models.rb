# Models
# Non ActiveRecord models are classes which encapsulate unique business logic
# out of your ActiveRecord model

# Fat Controllers are bad, they can get worse when new behavior is added
# Bad
class ItemsController < ApplicationController
  def publish
    if @item.is_approved? && @item.user != 'Loblaw'
      @item.publishes_on = Time.now
      if @item.save
        flash[:notice] = 'Your item was published!'
      else
        flash[:notice] = 'There was an error'
      end
    else
      flash[:notice] = 'There was an error'
    end
    redirect_to @item
  end
end

# Good
# Tell Don't Ask: You should tell objects what to do, and not ask them questions about their state
class Item < ActiveRecord::Base
  belongs_to :user

  def publish
    if !is_approved? || user == 'Loblaw'
      return false
    end

    self.published_on = Time.now
    self.save
  end
end

class ItemsController < ApplicationController
  def publish
    if @item.publish
      flash[:notice] = 'Your item was published!'
    else
      flash[:notice] = 'There was an error'
    end
    redirect_to @item
  end
end


# Avoid calling other domain objects from callbacks
# Referencing other models in a callback introduces tight coupling and afftects the object's database lifecycle

# Bad
class User < ActiveRecord::Base
  before_create :set_token

  protected

  def set_token
    self.token = TokenGenerator.create(self)
  end
end

# Good
class User < ActiveRecord::Base
  def register
    self.token = TokenGenerator.create(self)
    save
  end
end

class UsersController < ApplicationController
  def create
    @user = User.new(user_params)
    if @user.register
      redirect_to @user, notice: 'Success'
    else
      ...
    end
end

# Callbacks should only be used for modifying internal state
 
 class User < ActiveRecord::Base
  before_create :set_name

  protected
  def set_name
    self.set_name = self.login.capitalize if name.blank?
  end
end

# Not all models need to be activerecord
# Bad
# Too much logic in suspend! Breaks Single Responsability Principle
# An object that controls too many other objects in the system is an anti pattern known as a God object
class User < ActiveRecord::Base
  has_many :items
  has_many :reviews

  def suspend!
    self.class.transaction do
      self.update!(is_approved: false)
      self.items.each { |item| item.update!(is_approved: false)}
      self.reviews.each { |review| review.update!(is_approved: false)}
    end
  end
end

# First refactor could be:
# But still a lot of responsability for user model
class User < ActiveRecord::Base
  def suspend!
    self.class.transaction do
      disapprove_user!
      disapprove_items!
      disapprove_reviews!
    end
  end

  def disapprove_user!
  def disapprove_items!
  def disapprove_reviews!
end

# Not everything involving a user needs to go into the User model
# Good
# Non active record class with only one responsability
class UserSuspension
  def initialize(user)
    @user = user
  end

  def create
    @user.class.transaction do
      disapprove_user!
      disapprove_items!
      disapprove_reviews!
    end
  end

  private
  def disapprove_user!
  def disapprove_items!
  def disapprove_reviews!
end

class UsersController < ApplicationController
  def suspend
    @user = User.find(params[:id])
    suspension = UserSuspension.new(@user)
    suspension.create!
    if @user.register
      redirect_to @user, notice: 'Success'
    else
      ...
    end
end
