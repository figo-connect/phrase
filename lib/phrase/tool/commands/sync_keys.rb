# -*- encoding : utf-8 -*-

require "get_pomo"

class Phrase::Tool::Commands::SyncKeys < Phrase::Tool::Commands::Base
  def initialize(options, args)
    super(options, args)
    require_auth_token!

    @file_names = @args[1..-1]
    @push_only = @options.get(:push_only)
    @extensions = @options.get(:extensions).split(',')
    @lang = @options.get(:lang)
    @gettext_params = @options.get(:gettext_params)
  end

  def execute!
    check_gettext!

    print_message "Parsing local files for translation keys..."

    # collect files to parse
    files = choose_files_to_parse(@file_names, @extensions)
    if files.empty?
      print_message "Could not find any files to parse".light_red
      exit_command
    end

    # collect keys from local files
    local_keys = files.collect { |file| parse_file(file, @lang, @gettext_params).reject { |msgid| msgid == "" } }
    local_keys.flatten!
    local_keys.uniq!

    print_message "Finished parsing local files".green

    # collect keys from PhraseApp
    pa_keys = api_client.find_keys_by_name.collect { |key| key['name'] }

    # figure out differences
    new_keys = local_keys.reject { |key| pa_keys.include?(key) }
    obsolete_keys = pa_keys.reject { |key| local_keys.include?(key) }

    # upload new keys
    # 1. figure out dummy locale
    locales = api_client.fetch_locales
    if locales.empty?
        print_message "You need to have at least one locale defined".light_red
        exit_command
    end
    dummy_locale = locales[0]

    # 2. pseudo-translate new keys
    print_message "Uploading new keys..."
    new_keys.each do |key|
        api_client.store_translation(key, dummy_locale[:name])
    end
    print_message "Finished uploading new keys...".green

    # if not disabled, delete obsolete keys
    print_message "Removing obsolete keys..."
    if not @push_only
        print_message "Removing obsolete keys is not implemented yet".light_red
        exit_command
    end
    print_message "Finished removing obsolete keys...".green
  end

private

  def check_gettext!
    begin
      gettext_version = `xgettext -V`
    rescue
      print_message "No gettext found in path.".light_red
      exit_command
    end
  end

  def choose_files_to_parse(file_names, extensions)
    files = []
    file_names.each do |file_name|
      if File.directory?(file_name)
        files += Dir.glob("#{File.expand_path(file_name)}/**/*")
      else
        files << file_name
      end
    end

    files.reject { |file| File.directory?(file) or (not extensions.include?(File.extname(file)[1..-1])) }
  end

  def parse_file(file, lang, gettext_params)
    # compile gettext arguments
    GetPomo::PoFile.parse(`xgettext -L #{lang} --no-wrap --no-location --from-code UTF-8 #{gettext_params} -o - #{file}`).collect { |translation| translation.msgid }
  end
end
