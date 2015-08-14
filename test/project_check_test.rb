require 'test_helper'
require 'csv'

class ProjectCheckTest < MiniTest::Test
  def setup
    init_environment
    @api_key = 'ba7d93beb5de7820764e'
    @test_file = "test/files/maven-1.0.1.pom.xml"
    @project_key = "maven2_openejb_maven_plugins_1" 
  end

  def test_get_list_api_call
    VCR.use_cassette('project_list') do
      res = Veye::Project::API.get_list(@api_key)

      assert_equal 200, res.code
      assert_equal true, res.success

      proj = res.data.first
      assert_equal "bugtraqer", proj["name"]
      assert_equal "lein_project_clj_1", proj["project_key"]
      assert_equal "Lein", proj["project_type"]
      assert_equal false, proj["public"]
      assert_equal "upload", proj["source"]
    end
  end

  def test_get_list_default
    VCR.use_cassette('project_list') do
      output = capture_stdout do
        Veye::Project::Check.get_list(@api_key, {})
      end

      rows = output.split(/\n/)
      assert_equal "  1 - \e[32m\e[1mbugtraqer\e[0m", rows[0]
      assert_equal "\tProject key    : \e[1mlein_project_clj_1\e[0m", rows[1]
      assert_equal "\tProject type   : Lein", rows[2]
      assert_equal "\tPublic         : false", rows[3]
      assert_equal "\tPeriod         : weekly", rows[4]
      assert_equal "\tSource         : upload", rows[5]
      assert_equal "\tDependencies   : \e[1m9\e[0m", rows[6]
      assert_equal "\tOutdated       : \e[31m8\e[0m", rows[7]
    end
  end

  def test_get_list_csv
    VCR.use_cassette("project_list") do
      output = capture_stdout do
        Veye::Project::Check.get_list(@api_key, {format: 'csv'})
      end

      rows = CSV.parse(output)
      assert_equal ["nr", "name", "project_key", "public", "period", "source",
                    "dep_number", "out_number", "created_at"], rows[0]
      assert_equal ["1", "bugtraqer", "lein_project_clj_1", "false", "weekly",
                    "upload", "9", "8", "19.08.2013-18:31"], rows[1]
      assert_equal ["2", "Calidu/API", "lein_calidu_api_1", "true", "daily",
                    "github", "13", "1"], rows[2].take(8)
    end
  end

  def test_get_list_json
    VCR.use_cassette("project_list") do
      output = capture_stdout do
        Veye::Project::Check.get_list(@api_key, {format: 'json'})
      end

      res = JSON.parse(output)
      projects = res["projects"]
      assert_equal("bugtraqer", projects[0]["name"])
      assert_equal("lein_project_clj_1", projects[0]["project_key"])
      assert_equal(false, projects[0]["public"])
      assert_equal("upload", projects[0]["source"])
      assert_equal("weekly", projects[0]["period"])
    end
  end

  def test_get_list_table
    VCR.use_cassette("project_list") do
      output = capture_stdout do
        Veye::Project::Check.get_list(@api_key, {format: 'table'})
      end

      rows = output.split(/\n/)
      assert_equal(
        "|                                                              \
List of projects                                                              |",
        rows[1]
      )
      assert_equal(
        "| index | name                    | project_key                     \
| private | period | source | dependencies | outdated | created_at       |",
        rows[3]
      )

      assert_match(/| 1\s+| bugtraqer\s+| lein_project_clj_1/, rows[5])
    end
  end

  def test_check_file
    assert_match(
      /.*veye\/test\/files\/maven-1\.0\.1\.pom\.xml$/, 
      Veye::Project::API.check_file(@test_file)
    )

    assert_nil(Veye::Project::API.check_file("files/nO_such_file.exe"))
  end

  def test_upload_api_call_when_file_doesnt_exists
    assert_nil Veye::Project::API.upload("files/nofile.erb", @api_key)
  end

  def test_upload_api_call_when_file_exists
    VCR.use_cassette('project_upload') do
      res = Veye::Project::API.upload(@test_file, @api_key)
      refute_nil res
      assert_equal 201, res.code
      assert_equal true, res.success
      assert_equal "maven2_openejb_maven_plugins_1", res.data["project_key"]
      assert_equal "OpenEJB :: Maven Plugins", res.data["name"]
      assert_equal "Maven2", res.data["project_type"]
      assert_equal true, res.data["public"]
      assert_equal "API", res.data["source"]
    end
  end

  def test_upload_default
    VCR.use_cassette('project_upload') do
      output = capture_stdout do
        Veye::Project::Check.upload(@test_file, @api_key, {})
      end

      refute_nil output
      rows = output.split(/\n/)
      assert_equal "  1 - \e[32m\e[1mOpenEJB :: Maven Plugins\e[0m", rows[0]
      assert_equal "\tProject key    : \e[1mmaven2_openejb_maven_plugins_1\e[0m", rows[1]
      assert_equal "\tProject type   : Maven2", rows[2]
      assert_equal "\tPublic         : true", rows[3]
      assert_equal "\tPeriod         : daily", rows[4]
      assert_equal "\tSource         : API", rows[5]
      assert_equal "\tDependencies   : \e[1m11\e[0m", rows[6]
      assert_equal "\tOutdated       : \e[31m10\e[0m", rows[7]
    end
  end

  def test_upload_csv
    VCR.use_cassette('project_upload') do
      output = capture_stdout do
        Veye::Project::Check.upload(@test_file, @api_key, {format: "csv"})
      end

      refute_nil output
      rows = CSV.parse(output)
      assert_equal ["nr", "name", "project_key", "public", "period", "source",
                    "dep_number", "out_number", "created_at"], rows[0]
      assert_equal ["1", "OpenEJB :: Maven Plugins", "maven2_openejb_maven_plugins_1",
                    "true", "daily", "API", "11", "10"],
                    rows[1].take(8)

    end
  end

  def test_upload_json
    VCR.use_cassette('project_upload') do
      output = capture_stdout do
        Veye::Project::Check.upload(@test_file, @api_key, {format: "json"})
      end

      refute_nil output
      res = JSON.parse(output)
      assert_equal "maven2_openejb_maven_plugins_1", res["projects"]["project_key"]
      assert_equal "OpenEJB :: Maven Plugins", res["projects"]["name"]
      assert_equal "Maven2", res["projects"]["project_type"]
      assert_equal true, res["projects"]["public"]
      assert_equal "daily", res["projects"]["period"]
      assert_equal "API", res["projects"]["source"]
    end
  end

  def test_upload_table
    VCR.use_cassette('project_upload') do
      output = capture_stdout do
        Veye::Project::Check.upload(@test_file, @api_key, {format: "table"})
      end

      refute_nil output
      rows = output.split(/\n/)
      assert_equal(
      "|                                                                  \
List of projects                                                                  |",
      rows[1]
      )

      assert_equal(
        "| index | name                     | project_key                    \
| private | period | source | dependencies | outdated | created_at               |",
        rows[3]
      )

      assert_match(
        /\| 1\s+\| OpenEJB :: Maven Plugins \| maven2_openejb_maven_plugins_1/,
        rows[5]
      )
    end
  end

  def test_update_api_call
    VCR.use_cassette('project_update') do
      res = Veye::Project::API.update(@project_key, @test_file, @api_key)
      refute_nil res
      assert_equal 201, res.code
      assert_equal true, res.success
      proj = res.data
      assert_equal @project_key, proj["project_key"]
      assert_equal "OpenEJB :: Maven Plugins", proj["name"]
      assert_equal "Maven2", proj["project_type"]
      assert_equal true, proj["public"]
      assert_equal "API", proj["source"]
      assert_equal 11, proj["dependencies"].count
    end
  end

  def test_update_default
    VCR.use_cassette('project_update') do
      output = capture_stdout do
        Veye::Project::Check.update(@project_key, @test_file, @api_key, {})
      end
      refute_nil output
      rows = output.split(/\n/)
      assert_equal "  1 - \e[32m\e[1mOpenEJB :: Maven Plugins\e[0m", rows[0]
      assert_equal "\tProject key    : \e[1mmaven2_openejb_maven_plugins_1\e[0m", rows[1]
      assert_equal "\tProject type   : Maven2", rows[2]
      assert_equal "\tPublic         : true", rows[3]
      assert_equal "\tPeriod         : daily", rows[4]
      assert_equal "\tSource         : API", rows[5]
      assert_equal "\tDependencies   : \e[1m11\e[0m", rows[6]
      assert_equal "\tOutdated       : \e[31m10\e[0m", rows[7]
    end
  end

  def test_update_csv
    VCR.use_cassette('project_update') do
      output = capture_stdout do
        Veye::Project::Check.update(@project_key, @test_file, @api_key, {format: 'csv'})
      end

      refute_nil output
      rows = CSV.parse(output)
      assert_equal ["nr", "name", "project_key", "public", "period", "source",
                    "dep_number", "out_number", "created_at"], rows[0]
      assert_equal ["1", "OpenEJB :: Maven Plugins", "maven2_openejb_maven_plugins_1",
                    "true", "daily", "API", "11", "10"], rows[1].take(8)
    end
  end

  def test_update_json
    VCR.use_cassette('project_update') do
      output = capture_stdout do
        Veye::Project::Check.update(@project_key, @test_file, @api_key, {format: 'json'})
      end

      refute_nil output
      res = JSON.parse(output)
      proj = res["projects"]
      assert_equal @project_key, proj["project_key"]
      assert_equal "OpenEJB :: Maven Plugins", proj["name"]
      assert_equal "Maven2", proj["project_type"]
      assert_equal true, proj["public"]
      assert_equal "API", proj["source"]
      assert_equal 11, proj["dependencies"].count
    end
  end

  def test_update_table
    VCR.use_cassette('project_update') do
      output = capture_stdout do
        Veye::Project::Check.update(@project_key, @test_file, @api_key, {format: 'table'})
      end

      refute_nil output
      rows = output.split(/\n/)
      assert_match(
        /| index \| name\s+\| project_key\s\| private \| period \| source \|/,
        rows[4]
      )
      assert_match(
        /\| 1\s+\| OpenEJB :: Maven Plugins \| maven2_openejb_maven_plugins_1 \|/,
        rows[5]
      )

      assert_match(
      /\| index \| name\s+\| prod_key\s+\| version_current \| version_requested\s+\| outdated | stable/,
        rows[10]
      )

      assert_match(
        /\| 1\s+\| aether-api\s+\| org.sonatype.aether\/aether-api/,
        rows[12]
      )
    end
  end

  def test_get_project_api_call
    VCR.use_cassette("project_get") do
      res = Veye::Project::API.get_project(@project_key, @api_key)
      refute_nil res
      assert_equal true, res.success
      assert_equal 200, res.code
      
      proj = res.data
      assert_equal @project_key, proj["project_key"]
      assert_equal "OpenEJB :: Maven Plugins", proj["name"]
      assert_equal "Maven2", proj["project_type"]
      assert_equal true, proj["public"]
      assert_equal "API", proj["source"]
      assert_equal 11, proj["dependencies"].count
    end
  end

  def test_get_project_default
    VCR.use_cassette("project_get") do
      output = capture_stdout do
        Veye::Project::Check.get_project(@project_key, @api_key, {})
      end

      refute_nil output
      rows = output.split(/\n/)
      assert_equal "  1 - \e[32m\e[1mOpenEJB :: Maven Plugins\e[0m", rows[0]
      assert_equal "\tProject key    : \e[1mmaven2_openejb_maven_plugins_1\e[0m", rows[1]
      assert_equal "\tProject type   : Maven2", rows[2]
      assert_equal "\tPublic         : true", rows[3]
      assert_equal "\tPeriod         : daily", rows[4]
      assert_equal "\tSource         : API", rows[5]
      assert_equal "\tDependencies   : \e[1m11\e[0m", rows[6]
      assert_equal "\tOutdated       : \e[31m10\e[0m", rows[7]
    end
  end

  def test_get_project_csv
    VCR.use_cassette("project_get") do
      output = capture_stdout do
        Veye::Project::Check.get_project(@project_key, @api_key, {format: 'csv'})
      end

      refute_nil output
      rows = CSV.parse(output)
      assert_equal ["nr", "name", "project_key", "public", "period", "source", "dep_number", "out_number", "created_at"], rows[0]

      assert_equal ["1", "OpenEJB :: Maven Plugins", "maven2_openejb_maven_plugins_1", "true", "daily", "API", "11", "10"], rows[1].take(8)
    end
  end

  def test_get_project_json
    VCR.use_cassette("project_get") do
      output = capture_stdout do
        Veye::Project::Check.get_project(@project_key, @api_key, {format: 'json'})
      end

      refute_nil output
      doc = JSON.parse(output)
      proj = doc["projects"]
      assert_equal @project_key, proj["project_key"]
      assert_equal "OpenEJB :: Maven Plugins", proj["name"]
      assert_equal true, proj["public"]
      assert_equal "API", proj["source"]
      assert_equal "daily", proj["period"]
      assert_equal 11, proj["dependencies"].count
    end
  end

  def test_get_project_table
    VCR.use_cassette("project_get") do
      output = capture_stdout do
        Veye::Project::Check.get_project(@project_key, @api_key, {format: 'table'})
      end

      refute_nil output

      rows = output.split(/\n/)
      assert_match(
        /| index \| name\s+\| project_key\s\| private \| period \| source \|/,
        rows[4]
      )
      assert_match(
        /\| 1\s+\| OpenEJB :: Maven Plugins \| maven2_openejb_maven_plugins_1 \|/,
        rows[5]
      )

      assert_match(
      /\| index \| name\s+\| prod_key\s+\| version_current \| version_requested\s+\| outdated | stable/,
        rows[10]
      )

      assert_match(
        /\| 1\s+\| aether-api\s+\| org.sonatype.aether\/aether-api/,
        rows[12]
      )
    end
  end

  def test_delete_project_api_call
    VCR.use_cassette("project_delete") do
      res = Veye::Project::API.delete_project(@project_key, @api_key)
      refute_nil res
      assert_equal 200, res.code
      assert_equal true, res.success
      assert_equal(
        {"success"=>true, "message"=>"Project deleted successfully."},
        res.data
      )
    end
  end

  def test_delete_project_default
    VCR.use_cassette("project_delete") do
      output = capture_stdout do 
        Veye::Project::Check.delete_project(@project_key, @api_key)
      end

      refute_nil output
      assert_equal "\e[32mDeleted\n\e[0m", output
    end
  end
end