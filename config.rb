require "zurb-foundation"

###
# Blog
###

activate :syntax
set :markdown_engine, :redcarpet
set :markdown,
    :fenced_code_blocks => true,
    :autolink => true,
    :tables => true,
    :no_intra_emphasis => true

activate :blog do |blog|
  blog.prefix = "articles"
  blog.taglink = "tags/:tag.html"
  blog.tag_template = "tag.html"
  blog.layout = "post"
  blog.default_extension = ".md"
  blog.paginate = true
  blog.page_link = "p:num"
  blog.per_page = 3
end


# Change Compass configuration
#compass_config do |config|
#  config.output_style = :compact
#end

###
# Page options, layouts, aliases and proxies
###

# Per-page layout changes:
#
# With no layout
page "/feed.xml", :layout => false

# Proxy (fake) files
# page "/this-page-has-no-template.html", :proxy => "/template-file.html" do
#   @which_fake_page = "Rendering a fake page with a variable"
# end

###
# Helpers
###

# Automatic image dimensions on image_tag helper
# activate :automatic_image_sizes

# Methods defined in the helpers block are available in templates
# helpers do
#   def some_helper
#     "Helping"
#   end
# end

# Pretty urls
activate :directory_indexes
set :trailing_slash, false

set :css_dir, 'stylesheets'

set :js_dir, 'javascripts'

set :images_dir, 'images'

# Build-specific configuration
configure :build do
  # For example, change the Compass output style for deployment
  activate :minify_css

  # Minify Javascript on build
  activate :minify_javascript

  # Enable cache buster
  activate :cache_buster

end
