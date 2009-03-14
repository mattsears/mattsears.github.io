require "#{File.dirname(__FILE__)}/spec_helper"

describe 'cache' do

  describe "when using the file store" do

    before do
      @cache = Sinatra::Cache::FileStore.new
    end

    it "should create a valid object" do
      @cache.should_not be_nil
    end

    it "should assign the name of the cache directory" do
      @cache.cache_path.should == "cache"
    end

    it "should default the filename to 'index' if no path was given " do
      @cache.write("/", "cached content")
      File.exist?("#{@cache.cache_path}/index.html").should == true
    end

    it "should make all directories and file extensions" do
      @cache.write("/path/to/article", "cached content")
      File.exist?("#{@cache.cache_path}/path/to/article.html").should == true
    end

    it "should determine if cached file exists" do
      @cache.write("/home", "home page")
      @cache.exist?("/home").should == true
    end

    it "should determine if a cached file does NOT exists " do
      @cache.exist?("/does/not/exist").should == false
    end

    it "should add a timestamp to the end of the cached file" do
      @cache.write("/", "cached content").should =~ /<!-- page cached:/
    end

    it "should delete the cached file" do
      @cache.write("/home", "home page")
      @cache.exist?("/home").should == true
      @cache.delete("/home")
      @cache.exist?("/home").should == false
    end

    it "should log an error if cached file could not be saved" do
      File.stub!(:open).and_raise(Exception)
      lambda {
        @cache.write("/home", "home page")
      }.should raise_error(Exception)
    end

    after do
      if File.directory? @cache.cache_path
        FileUtils.rm_rf @cache.cache_path
      end
    end

  end

end
