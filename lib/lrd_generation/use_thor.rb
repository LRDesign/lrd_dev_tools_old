begin
  require 'thor/group'
rescue LoadError
  puts "Thor is not available.\nIf you ran this command from a git checkout " \
    "of Rails, please make sure thor is installed,\nand run this command " \
    "as `ruby /path/to/rails myapp --dev`"
  exit
end

module LrdGeneration
  module UseThor
    protected

    def build_thor(&block)
      source = File::join(File::dirname(File::expand_path(caller[0].sub(/:.*$/,''))), "templates")
      klass = Class.new(ThorManifest, &block)
      #Fugly, but a lot of the machinery depends on it
      name = self.class.name.to_s.split('::').last.sub!(/Generator$/,"Manifest")
      self.class.const_set(name,klass)
      klass.source_paths << source
      klass
    end
  end

  class Error < Thor::Error
  end

  class ThorManifest < Thor::Group
    include Thor::Actions
    include LrdGeneration::Actions

    def self.replay(command)
      case command
      when Rails::Generator::Commands::Create
        start(command.args, command.options)
      else
        puts "ThorManifests only Create, never destroy.  It's in their code"
      end
    end

    def self.start(args, config)
      debugging = true
      super
    end

    # Automatically sets the source root based on the class name.
    #
    def self.source_root
      @_rails_source_root ||= begin
                                if base_name && generator_name
                                  File.expand_path(File.join(base_name, generator_name, 'templates'), File.dirname(__FILE__))
                                end
                              end
    end

    # Tries to get the description from a USAGE file one folder above the source
    # root otherwise uses a default description.
    #
    def self.desc(description=nil)
      return super if description
      usage = File.expand_path(File.join(source_root, "..", "USAGE"))

      @desc ||= if File.exist?(usage)
                  File.read(usage)
                else
                  "Description:\n    Create #{base_name.humanize.downcase} files for #{generator_name} generator."
                end
    end

    # Convenience method to get the namespace from the class name. It's the
    # same as Thor default except that the Generator at the end of the class
    # is removed.
    #
    def self.namespace(name=nil)
      return super if name
      @namespace ||= super.sub(/_generator$/, '').sub(/:generators:/, ':')
    end

    def self.hook_for(*names, &block)
      options = names.extract_options!
      in_base = options.delete(:in) || base_name
      as_hook = options.delete(:as) || generator_name

      names.each do |name|
        defaults = if options[:type] == :boolean
                     { }
                   elsif [true, false].include?(default_value_for_option(name, options))
                     { :banner => "" }
                   else
                     { :desc => "#{name.to_s.humanize} to be invoked", :banner => "NAME" }
                   end

        unless class_options.key?(name)
          class_option(name, defaults.merge!(options))
        end

        hooks[name] = [ in_base, as_hook ]
        invoke_from_option(name, options, &block)
      end
    end

    # Remove a previously added hook.
    #
    # ==== Examples
    #
    #   remove_hook_for :orm
    #
    def self.remove_hook_for(*names)
      remove_invocation(*names)

      names.each do |name|
        hooks.delete(name)
      end
    end

    # Make class option aware of Rails::Generators.options and Rails::Generators.aliases.
    #
    def self.class_option(name, options={}) #:nodoc:
      options[:desc]    = "Indicates when to generate #{name.to_s.humanize.downcase}" unless options.key?(:desc)
      #options[:aliases] = default_aliases_for_option(name, options) #JDL #Rails3
      #options[:default] = default_value_for_option(name, options) #Rails3
      super(name, options)
    end

    # Cache source root and add lib/generators/base/generator/templates to
    # source paths.
    #
    def self.inherited(base) #:nodoc:
      super

      # Cache source root, we need to do this, since __FILE__ is a relative value
      # and can point to wrong directions when inside an specified directory.
      base.source_root

      ##JDL: As I understand it, Rails3 provides a search path for templates.  
      #Not so much Rails2, so this wouldn't work.
#      if base.name && base.name !~ /Base$/
#        Rails::Generators.templates_path.each do |path|
#          if base.name.include?('::')
#            base.source_paths << File.join(path, base.base_name, base.generator_name)
#          else
#            base.source_paths << File.join(path, base.generator_name)
#          end
#        end
#      end
    end

    protected

    # Check whether the given class names are already taken by user
    # application or Ruby on Rails.
    #
    def class_collisions(*class_names) #:nodoc:
      return unless behavior == :invoke

      class_names.flatten.each do |class_name|
        class_name = class_name.to_s
        next if class_name.strip.empty?

        # Split the class from its module nesting
        nesting = class_name.split('::')
        last_name = nesting.pop

        # Hack to limit const_defined? to non-inherited on 1.9
        extra = []
        extra << false unless Object.method(:const_defined?).arity == 1

        # Extract the last Module in the nesting
        last = nesting.inject(Object) do |last, nest|
          break unless last.const_defined?(nest, *extra)
          last.const_get(nest)
        end

        if last && last.const_defined?(last_name.camelize, *extra)
          raise Error, "The name '#{class_name}' is either already used in your application " <<
          "or reserved by Ruby on Rails. Please choose an alternative and run "  <<
          "this generator again."
        end
      end
    end

    # Use Rails default banner.
    #
    def self.banner
      "rails generate #{generator_name} #{self.arguments.map{ |a| a.usage }.join(' ')} [options]"
    end

    # Sets the base_name taking into account the current class namespace.
    #
    def self.base_name
      @base_name ||= begin
                       if base = name.to_s.split('::').first
                         base.underscore
                       end
                     end
    end

    # Removes the namespaces and get the generator name. For example,
    # Rails::Generators::MetalGenerator will return "metal" as generator name.
    #
    def self.generator_name
      @generator_name ||= begin
                            if generator = name.to_s.split('::').last
                              generator.sub!(/Manifest$/, '')
                              generator.underscore
                            end
                          end
    end

    # Return the default value for the option name given doing a lookup in
    # Rails::Generators.options.
#    #
#    def self.default_value_for_option(name, options)
#      default_for_option(Rails::Generators.options, name, options, options[:default])
#    end
#
#    # Return default aliases for the option name given doing a lookup in
#    # Rails::Generators.aliases.
#    #
#    def self.default_aliases_for_option(name, options)
#      default_for_option(Rails::Generators.aliases, name, options, options[:aliases])
#    end
#
#    # Return default for the option name given doing a lookup in config.
#    #
#    def self.default_for_option(config, name, options, default)
#      if generator_name and c = config[generator_name.to_sym] and c.key?(name)
#        c[name]
#      elsif base_name and c = config[base_name.to_sym] and c.key?(name)
#        c[name]
#      elsif config[:rails].key?(name)
#        config[:rails][name]
#      else
#        default
#      end
#    end
#
    # Keep hooks configuration that are used on prepare_for_invocation.
    #
    def self.hooks #:nodoc:
      @hooks ||= from_superclass(:hooks, {})
    end

    # Prepare class invocation to search on Rails namespace if a previous
    # added hook is being used.
    #
#    def self.prepare_for_invocation(name, value) #:nodoc:
#      return super unless value.is_a?(String) || value.is_a?(Symbol)
#
#      if value && constants = self.hooks[name]
#        value = name if TrueClass === value
#        Rails::Generators.find_by_namespace(value, *constants)
#      elsif klass = Rails::Generators.find_by_namespace(value)
#        klass
#      else
#        super
#      end
#    end

    # Small macro to add ruby as an option to the generator with proper
    # default value plus an instance helper method called shebang.
    #
    def self.add_shebang_option!
      class_option :ruby, :type => :string, :aliases => "-r", :default => Thor::Util.ruby_command,
        :desc => "Path to the Ruby binary of your choice", :banner => "PATH"

      no_tasks {
        define_method :shebang do
        @shebang ||= begin
                       command = if options[:ruby] == Thor::Util.ruby_command
                                   "/usr/bin/env #{File.basename(Thor::Util.ruby_command)}"
                                 else
                                   options[:ruby]
                                 end
                       "#!#{command}"
                     end
        end
      }
    end

  end
end
