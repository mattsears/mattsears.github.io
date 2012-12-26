module Jekyll

  class Page

    alias_method :_pagination_original_dir=, :dir=

      # Overwrites the original method to also set +basename+ when there's
      # a +pager+. NOTE: Depends on +pager+ being set before setting +dir+.
      def dir=(dir)
        @basename = 'index' if @pager
        @dir = dir
      end

      alias_method :_pagination_original_index?, :index?

      # Overwrites the original method to also include the configured
      # paginate file(s) in the evaluation.
      def index?
        Pager.paginate_files(@site.config).include?("#{basename}.html")
      end

    end

    class Pager

      class << self

        def paginate_files(config)
          config['paginate_files'] ||= ['index.html']
          config.pluralized_array('paginate_file', 'paginate_files')
        end

        alias_method :_pagination_original_pagination_enabled?, :pagination_enabled?

        # Overwrites the original method to check +paginate_file+ and
        # +paginate_files+ configuration options.
        def pagination_enabled?(config, file)
          paginate_files(config).include?(file) if config['paginate']
        end

      end

    end

  end
