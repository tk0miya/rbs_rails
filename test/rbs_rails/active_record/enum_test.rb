require 'test_helper'

class EnumTest < Minitest::Test
  def test_enum
    model_path = app_dir.join('app/models/article.rb')
    ast = Parser::CurrentRuby.parse model_path.read

    enum = RbsRails::ActiveRecord::Enum.new(ast)
    assert_equal enum.methods, %w[draft published category_news category_tech]
  end

  def app_dir
    Pathname(__dir__).join('../../app')
  end
end
