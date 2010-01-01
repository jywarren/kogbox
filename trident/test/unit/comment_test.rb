require File.dirname(__FILE__) + '/../test_helper'

class CommentTest < Test::Unit::TestCase
  fixtures :comments,:snippets

  # Replace this with your real tests.
  def test_truth
    assert true
  end
  
  def test_add_comment
    comment = comments(:jeffs_test_comment)
    comment2 = comments(:gabes_response)
    snippet = snippets(:second)
    #snippet.add_comment comments(:jeffs_test_comment)
    #snippet.add_comment comments(:gabes_response)
    assert_equal 2, snippet.comments.size
  end 
  
end
