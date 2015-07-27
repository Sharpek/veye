require 'test_helper'

class GithubSyncTest < Minitest::Test
  def setup
    init_environment # load config files and initialize options
    @api_key = 'ba7d93beb5de7820764e'
  end

  def test_api_call
    VCR.use_cassette('github_sync') do
      resp = Veye::Github::API.import_all(@api_key)
      refute_nil resp
      assert_equal 200, resp.code
      assert_equal( {"status"=>"running"}, resp.data )
    end
  end

  def test_sync_when_success
    VCR.use_cassette('github_sync') do
      output = capture_stdout do
        Veye::Github::Sync.import_all(@api_key, {})
      end

      refute_nil output
      expected_str = "\e[31mNo changes.\e[0m - Use `force` flag if you want to reload everything.\n"
      assert_equal expected_str, output
    end
  end
end
