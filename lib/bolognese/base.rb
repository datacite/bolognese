module Bolognese
  module Base
    # load ENV variables from .env file if it exists
    env_file = File.expand_path("../../../.env", __FILE__)
    if File.exist?(env_file)
      require 'dotenv'
      Dotenv.load! env_file
    end

    # load ENV variables from container environment if json file exists
    # see https://github.com/phusion/baseimage-docker#envvar_dumps
    env_json_file = "/etc/container_environment.json"
    if File.exist?(env_json_file)
      env_vars = JSON.parse(File.read(env_json_file))
      env_vars.each { |k, v| ENV[k] = v }
    end
  end
end
