require 'test_helper'

class EnumTest < Minitest::Test
  def test_rails5_style_enum
    model_path = app_dir.join('app/models/article.rb')
    ast = Parser::CurrentRuby.parse model_path.read

    enum = RbsRails::ActiveRecord::Enum.new(ast, rails_version: 5)
    assert_equal enum.methods, %w[draft published category_news category_tech]
  end

  def test_rails7_style_enum
    model_path = app_dir.join('app/models/comment.rb')
    ast = Parser::CurrentRuby.parse model_path.read

    enum = RbsRails::ActiveRecord::Enum.new(ast, rails_version: 7)
    assert_equal enum.methods, %w[status_new status_moderated status_rejected anonymous named]
  end

  def app_dir
    Pathname(__dir__).join('../../app')
  end
end
