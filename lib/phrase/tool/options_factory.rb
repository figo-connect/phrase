require 'optparse'

class OptionsFactory
  def self.options_for(command, options)
    OptionParser.new do |opts|
      self.send(command, opts, options[command])
    end
  end

  def self.init(opts, set)
    opts.banner = "phrase init"

    opts.on("--secret=YOUR_AUTH_TOKEN", String, "Your auth token") do |secret|
      set[:secret] = secret
    end
    
    opts.on("--default-locale=en", String, "The default locale for your application") do |default_locale|
      set[:default_locale] = default_locale
    end

    opts.on("--default-format=json", String, "The default format for locale files") do |format|
      set[:format] = format
    end
    
    opts.on("--domain=phrase", String, "The default domain or app prefix for locale files") do |domain|
      set[:domain] = domain
    end
    
    opts.on("--locale-directory=./", String, "The directory naming for locale files, e.g ./<locale.name>/ for subfolders with 'en' or 'de'") do |locale_directory|
      set[:locale_directory] = locale_directory
    end
    
    opts.on("--locale-filename=<domain>.<format>", String, "The filename for locale files") do |locale_filename|
      set[:locale_filename] = locale_filename
    end
    
    opts.on("--default-target=phrase/locales/", String, "The default target directory for locale files") do |target_directory|
      set[:target_directory] = target_directory
    end
  end
  private_class_method :init

  def self.push(opts, set)
    opts.banner = "phrase push FILE|DIRECTORY"

    opts.on("--tags=foo,bar", Array, "List of tags for phrase push (separated by comma)") do |tags|
      set[:tags] = tags
    end
    
    opts.on("-R", "--recursive", "Push files in subfolders as well (recursively)") do |recursive|
      set[:recursive] = true
    end
    
    opts.on("--locale=en", String, "Locale of the translations your file contain (required for formats that do not include the name of the locale in the file content)") do |locale|
      set[:locale] = locale
    end

    opts.on("--format=yml", String, "See documentation for list of allowed formats") do |format|
      set[:format] = format
    end

    opts.on("--force-update-translations", "Force update of existing translations with the file content") do |update_translations|
      set[:update_translations] = update_translations
    end

    opts.on("--skip-unverification", "When force updating translations, skip unverification of non-main locale translations") do |skip_unverification|
      set[:skip_unverification] = skip_unverification
    end
  end
  private_class_method :push

  def self.pull(opts, set)
    opts.banner = "phrase pull [LOCALE]"

    opts.on("--format=yml", String, "See documentation for list of allowed formats") do |format|
      set[:format] = format
    end
    
    opts.on("--target=./phrase/locales", String, "Target folder to store locale files") do |target|
      set[:target] = target
    end

    opts.on("--tag=foo", String, "Limit results to a given tag instead of all translations") do |tag|
      set[:tag] = tag
    end
  end
  private_class_method :pull

  def self.sync_keys(opts, set)
    opts.banner = "phrase sync_keys FILE|DIRECTORY"

    opts.on("-p", "--push-only", "Only push new translation keys and do not delete obsolete ones") do |push_only|
      set[:push_only] = push_only
    end

    opts.on("-l", "--language=ObjectiveC", String, "Programming language of the code to be parsed by gettext") do |lang|
      set[:lang] = lang
    end

    opts.on("-e", "--extensions=m", String, "Extensions of the files to be parsed") do |extensions|
      set[:extensions] = extensions
    end

    opts.on("-x", "--extra=", String, "Extra parameters/arguments to pass to gettext") do |gettext_params|
      set[:gettext_params] = gettext_params
    end
  end
  private_class_method :sync_keys

  def self.tags(opts, set)
    opts.banner = "phrase tags"

    opts.on("-l", "--list", "List all tags") do |list|
      set[:list] = list
    end
  end
  private_class_method :tags
  
  def self.default(opts, set)
    opts.banner = ""
    
    opts.on_tail("-v", "--version", "Show version number") do |version|
     set[:version] = true
    end
    
    opts.on_tail("-h", "--help", "Show help") do |help|
      set[:help] = true
    end
  end
  private_class_method :default
end
