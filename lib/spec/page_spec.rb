require "#{File.dirname(__FILE__)}/spec_helper"

describe 'page' do

  before do
    @repo_path = new_git_repo
    Aerial.stub!(:repo).and_return(Grit::Repo.new(@repo_path))
  end

  describe "when creating new instances" do

    before do
      @page = Page.new(:title        => "Test Title",
                       :author       => "Test Case",
                       :body         => "Test **Content**",
                       :published_at => DateTime.now)
    end

    it "should assign attributes appropriatley" do
      @page.should_not be_nil
    end

    it "should assign the title attribute" do
      @page.title.should == "Test Title"
    end

    it "should assign the author attribute" do
      @page.author.should == "Test Case"
    end

    it "should assign the published_at attribute" do
      @page.published_at.should be_instance_of(DateTime)
    end

    it "should assign the body attribute" do
      @page.body.should == "Test **Content**"
    end

    it "should translate the body markdown to html" do
      @page.to_html.should have_tag('//strong').with_text('Content')
    end

  end

  describe "when finding all pages" do

    before do
      @pages = Page.all
    end

    it "should return an array of Page objects" do
      @pages.should be_instance_of(Array)
      @pages.size.should == 2
    end

  end

  describe "when finding a single page with the file name" do

    before do
      @homepage = Page.with_name("home")
    end

    it "should return a valid Page object" do
      @homepage.should_not be_nil
    end

    it "should assign the page's title" do
      @homepage.title.should == "Welcome"
    end

    it "should assign the page's author" do
      @homepage.author.should == "Matt Sears"
    end

    it "should assign the page name based on the file name" do
      @homepage.name.should == "home"
    end

    it "should assign the publication date" do
      @homepage.published_at.should be_instance_of(DateTime)
    end

    it "should assign the page's body" do
      @homepage.body.should =~ /Lorem/
    end

    it "should find the second page in the directory" do
      @aboutpage = Page.with_name("about")
      @aboutpage.should_not be_nil
      @aboutpage.title.should =="About Us"
    end

  end

  after do
    delete_git_repo
  end

end
