module Aerial

  # Represents a single page of the website
  class Page < Content

    # Find all pages
    def self.all(options={})
      self.find_all
    end

    # Find a single page
    def self.with_name(name, options={})
      self.find_by_name(name, options)
    end

    private

    # Retreive all pages from the repository
    def self.find_all(options = {})
      pages = []
      if tree = Aerial.repo.tree/"#{Aerial.config.pages.directory}/"
        tree.contents.first( options[:limit] || 100 ).each do |entry|
          pages << self.find_page(entry, options)
        end
      end
      return pages.sort_by { |page| page.title}.reverse
    end

    # Find a single page given the file name
    #   +name+ file name
    def self.find_by_name(name, options={})
      if blob = Aerial.repo.tree/"#{Aerial.config.pages.directory}/#{name}.page"
        return self.find_page(blob)
      end
    end

    # Look in the given tree, find the page
    #   +tree+ repository tree
    #   +options+ :blob_id
    def self.find_page(blob, options = {})
      attributes = nil
      if blob.name =~ /page/
        attributes = self.extract_info_from(blob, options)
        attributes[:file_name] = blob.name
      end
      return Page.new(attributes) if attributes
    end

    # Extract the Page attributes from the file
    def self.extract_info_from(blob, options={})
      file                = blob.data
      page                = Hash.new
      page[:id]           = blob.id
      page[:author]       = self.extract_header("author", file)
      page[:title]        = self.extract_header("title", file)
      page[:published_at] = DateTime.parse(self.extract_header("published", file))
      page[:body]         = self.scan_for_field(file, self.body_field)
      return page
    end

  end
end
