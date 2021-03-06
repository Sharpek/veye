require 'test_helper'
require 'csv'

class GithubInfoTest < Minitest::Test
  def setup
    init_environment
    @api_key = ENV['VEYE_API_KEY']
    @repo_name = 'versioneye/veye'
  end

  def test_get_repo_default
    VCR.use_cassette('github_info') do
      output = capture_stdout do
        Veye::Github::Info.get_repo(@api_key, @repo_name, {})
      end

      refute_nil output
      rows = output.split(/\n/)
      assert_equal "\t\e[32mversioneye/veye\e[0m - \e[1mruby\e[0m", rows[0]
      assert_equal "\tDescription    : VersionEye command line tool implemented in Ruby" , rows[1]
      assert_equal "\tOwner login    : versioneye", rows[2]
      assert_equal "\tOwner type     : organization", rows[3]
      assert_equal "\tPrivate        : false", rows[4]
      assert_equal "\tFork           : false", rows[5]
      assert_equal "\tBranches       : ", rows[6]
    end
  end

  def test_get_repo_csv
    VCR.use_cassette('github_info') do
      output = capture_stdout do
        Veye::Github::Info.get_repo(@api_key, @repo_name, {format: 'csv'})
      end

      refute nil, output
      rows = CSV.parse(output)
      assert_equal ["name", "language", "owner_login", "owner_type", "private", "fork", "branches", "imported_projects", "description"], rows[0]
      assert_equal(
        ["versioneye/veye", "ruby", "versioneye", "organization", "false", "false",
         nil, nil, "VersionEye command line tool implemented in Ruby"],
        rows[1]
      )
    end
  end

  def test_get_repo_json
    VCR.use_cassette('github_info') do
      output = capture_stdout do
        Veye::Github::Info.get_repo(@api_key, @repo_name, {format: 'json'})
      end

      refute nil, output
      dt = JSON.parse(output)
      repo = dt["repo"]
      assert_equal "versioneye/veye", repo["fullname"]
      assert_equal "ruby", repo["language"]
      assert_equal "versioneye", repo["owner_login"]
      assert_equal "organization", repo["owner_type"]
      assert_equal false, repo["private"]
      assert_equal false, repo["fork"]
      assert_equal nil, repo["branches"]
    end
  end

  def test_get_repo_table
    VCR.use_cassette('github_info') do
      output = capture_stdout do
        Veye::Github::Info.get_repo(@api_key, @repo_name, {format: 'table'})
      end

      refute nil, output
      rows = output.split(/\n/)
      assert_match(/\| name\s+| language | owner_login | owner_type\s| private | fork\s+| branches\s+| imported_projects | description\s+|/, rows[3])
      assert_match(/| versioneye\/veye | ruby\s+| versioneye\s+| organization\s+| false\s+| false\s+| \s+|\s+| VersionEye command line tool\s+|/, rows[5])
    end
  end
end
