require 'test_helper'

class CLIIntegrationTest < Minitest::Test
  include Minitest::Hooks

  def before_all
    Bundler.with_unbundled_env do
      sh!('bundle', 'install', chdir: app_dir)
      sh!('bin/rake', 'db:create', 'db:schema:load', chdir: app_dir)
    end
  end

  def setup
    clean_test_signatures
  end

  def test_generate_without_args_exits_with_error
    Bundler.with_unbundled_env do
      assert_raises(RuntimeError) do
        sh!('bundle', 'exec', 'rbs_rails', 'generate', chdir: app_dir)
      end
    end
  end

  def test_generate_model_file
    Bundler.with_unbundled_env do
      sh!('bundle', 'exec', 'rbs_rails', 'generate', 'app/models/user.rb', chdir: app_dir)
    end

    rbs_path = app_dir.join('sig/rbs_rails/app/models/user.rbs')
    assert rbs_path.exist?, "Expected user.rbs to be generated"
    assert_equal (expectations_dir / 'user.rbs').read, rbs_path.read
    refute app_dir.join('sig/rbs_rails/app/models/order.rbs').exist?
  end

  def test_generate_multiple_model_files
    Bundler.with_unbundled_env do
      sh!('bundle', 'exec', 'rbs_rails', 'generate', 'app/models/user.rb', 'app/models/order.rb', chdir: app_dir)
    end

    assert app_dir.join('sig/rbs_rails/app/models/user.rbs').exist?
    assert app_dir.join('sig/rbs_rails/app/models/order.rbs').exist?
    refute app_dir.join('sig/rbs_rails/app/models/blog.rbs').exist?
  end

  def test_generate_routes_file
    Bundler.with_unbundled_env do
      sh!('bundle', 'exec', 'rbs_rails', 'generate', 'config/routes.rb', chdir: app_dir)
    end

    assert app_dir.join('sig/rbs_rails/path_helpers.rbs').exist?
    refute app_dir.join('sig/rbs_rails/app/models/user.rbs').exist?
  end
end
