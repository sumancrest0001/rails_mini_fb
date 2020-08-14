# frozen_string_literal: true

module PostsHelper
  def display_likes(post)
    likes = post.number_of_likes
    if likes > 0
      return "(#{likes})"
    end
  end

  def display_comments(post)
    comments = post.number_of_comments
    if comments > 0
      return "(#{comments})"
    end
  end

end
