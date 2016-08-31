require 'semverly'

require_relative 'project/check.rb'
require_relative 'project/license.rb'

module Veye
  # Project module includes commands for managing
  # projects on VersionEye and presenting results
  # on command line.
  module Project
    @supported_files = [
      'project\.clj', 'bower\.json', 'project\.json', 'gemfile',
      'gemfile\.lock', '*\.gradle', '*\.sbt', '*\.pom\.xml', 'podfile'
    ]

    @default_upgrade_heuristics = {
      difficulty: 'unknown',
      is_semver: false,
      dv_major: 0.0, #absolute major version difference between 2 semver
      dv_minor: 0.0, 
      dv_patch: 0.0,
      dv_score: 0.0 # total dv score on logarithmic scale
    }

    def self.supported_files
      @supported_files
    end

    def self.supported?(filename)
      @supported_files.any? {|ptrn| filename.to_s.downcase.match(/^#{ptrn}$/) }  
    end

    #returns list of supported filenames in the working folder
    def self.get_files(path)
      files = Set.new
      Dir.foreach(path) do |filename|
        files << filename if supported?(filename)
      end

      if files.include?('Gemfile') and files.include?('Gemfile.lock')
        files.delete 'Gemfile'
      end

      files
    end

    #estimates how difficult it would be to upgrade to current version
    def self.calc_upgrade_heuristics(version_requested, version_current)
      scores = @default_upgrade_heuristics
      
      semver_A = SemVer.parse(version_requested)
      semver_B = SemVer.parse(version_current)

      #if any of versions are not semver, then shortcut execution
      if ( semver_A.nil? or semver_B.nil? )
        #hack: float unknown outdated semvers top of up-to-date packages
        scores[:dv_score] = 0.01 if version_requested != version_current
        return scores
      end

      scores = {
        :is_semver  => true,
        :dv_major   => (semver_A.major - semver_B.major).abs,
        :dv_minor   => (semver_A.minor - semver_B.minor).abs,
        :dv_patch   => (semver_A.patch - semver_B.patch).abs
      }

      dv_score = Math.log10(scores[:dv_major] * 1e3 + scores[:dv_minor] * 1e2 + scores[:dv_patch] + 1)
      scores[:dv_score] = dv_score.round(3)

      scores[:difficulty] = humanize_dv_score(scores[:dv_score], scores[:is_semver])

      scores
    end

    def self.humanize_dv_score(the_score, is_semver)
      if is_semver == false
        'unknown'
      elsif the_score == 0
        'up-to-date'
      elsif the_score < 1
        'low'
      elsif the_score >= 1 and the_score < 3
        'medium'
      elsif the_score >= 3
        'high'
      else
        'unknown'
      end
    end
  end
end
