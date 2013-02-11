module BigTuna
  class Hooks::Deploy < Hooks::Base

    NAME = "deploy"
    # CHEF_DIR = "/srv/iditto-chef"

    def build_passed(build, config)
      BigTuna::Runner.execute build.build_dir, merge_command(build.commit)
      BigTuna::Runner.execute config['chef_repo_path'], deploy_command(config)
    rescue BigTuna::Runner::Error => e
      BigTuna.logger.error(e)
      BigTuna.logger.error(e.output)
    end

    private

    def merge_command(commit)
      "git clean -d -f && git checkout -- . && git checkout qa && git merge --ff-only #{commit} && git push origin qa"
    end

    def deploy_command(config)
      "bundle exec knife ssh 'chef_environment:qa AND role:app_server' -x ubuntu -a ec2.public_hostname -i #{config['deploy_key_path']} 'sudo chef-client'"
    end

  end
end
