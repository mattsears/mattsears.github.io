require "#{File.dirname(__FILE__)}/spec_helper"

describe 'system configuration settings' do

  it "should set theme directory" do
    Aerial.config.theme.directory.should == "themes"
  end

  it "should set a value for blog directory" do
    Aerial.config.blog.directory.should == "blog"
  end

  it "should set a value for the pages directory" do
    Aerial.config.pages.directory.should == "pages"
  end

  it "should set a value for the cache directory" do
    Aerial.config.cache.directory.should == "cache"
  end

  it "should define the directory for the theme directory" do
    Aerial.config.theme_directory.should == "#{AERIAL_ROOT}/themes/default"
  end

  it "should define the directory for the public directory" do
    Aerial.config.public.directory.should == "public"
  end

  it "should defin the git options" do
    Aerial.config.git.url.should == "git://github.com/mattsears/mattsears.git"
  end

end
