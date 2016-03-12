require 'test_helper'

class PackageFollowTest < MiniTest::Test
  def setup
    init_environment
    @api_key = ENV['VEYE_API_KEY']
  end

  def test_get_follow_status
    VCR.use_cassette('package_follow_status') do
      out = capture_stdout do
        Veye::Package::Follow.get_follow_status(@api_key, 'ruby/ruby')
      end
      expected = "Following `ruby`: \e[32mfalse\e[0m\n"
      assert_equal expected, out
    end
  end

  def test_follow
    VCR.use_cassette('package_follow') do
      out = capture_stdout do
        Veye::Package::Follow.follow(@api_key, 'ruby/ruby')
      end
      expected = "Following `ruby`: \e[32mtrue\e[0m\n"
      assert_equal expected, out
    end
  end

  def test_unfollow
    VCR.use_cassette('package_unfollow') do
      out = capture_stdout do
        Veye::Package::Follow.unfollow(@api_key, 'ruby/ruby')
      end
      expected = "Following `ruby`: \e[32mfalse\e[0m\n"
      assert_equal expected, out
    end
  end
end
