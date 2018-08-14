class PostsController < ApplicationController
  def index
    @posts = Post.where('published = ? AND published_on > ?', true, 2.days.ago)
  end
end

# Query implemented as a class method
class PostsController < ApplicationController
  def index
    @posts = Post.recent
  end
end

class Post < ActiveRecord
  def self.recent
    where('published = ? AND published_on > ?', true, 2.days.ago)
  end
end

# Class methods vs Scopes

class Post < ActiveRecord
  def self.by_author(author)
    where(author: author)
  end

  def self.recent
    where('published_on > ?', 2.days.ago)
  end
end

author = 'Carlos'
Post.by_author(author).recent

# SELECT "posts".* FROM "posts" WHERE "posts"."author" = 'Carlos' AND (published_on > '..')

# params[:author] => nil
Post.by_author(params[:author]).recent

# SELECT "posts".* FROM "posts" WHERE "posts"."author" IS NULL AND (published_on > '..')
# Can lead to unexpected behavior with chains of conditions

# With scopes
# Scopes always return a chainable object
class Post < ActiveRecord
  scope :by_author, -> (author) { where(author: author) if author.present? }
  scope :recent, -> { where('published_on > ?', 2.days.ago)}
end

# Merging scopes
class Comment < ActiveRecord
  belongs_to :posts
  scope :approved, -> {where(approved: true)}
end

class Post < ActiveRecord
  has_many :comments
  scope :with_approved_comments, -> { joins(:comments).where('comments.approved = ?', true)}
end

Post.with_approved_comments
# Duplicated condition where(approved: true)

# Use merge to combine conditions from different models
class Comment < ActiveRecord
  belongs_to :posts
  scope :approved, -> {where(approved: true)}
end

class Post < ActiveRecord
  has_many :comments
  scope :with_approved_comments, -> { joins(:comments).merge(Comment.approved)}
end