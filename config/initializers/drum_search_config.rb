# Try to load a local version of the config file if it exists -
# expected to be in quicksearch
# _root/config/searchers/<my_searcher_name>_config.yml

config_file = [
  File.join(Rails.root, '/config/searchers/drum_config.yml'),
  File.expand_path('../drum_config.yml', __dir__)
].select { |file| File.exist? file }.first

QuickSearch::Engine::DRUM_CONFIG =
  YAML.load(ERB.new(IO.read(config_file)).result)[Rails.env]
