require "#{File.dirname(__FILE__)}/spec_helper"

describe 'article' do

  before do
    @repo_path = new_git_repo
    Aerial.stub!(:repo).and_return(Grit::Repo.new(@repo_path))
  end

  describe Aerial::Helper do

    it "should return 'Never' for in valide dates" do
      humanized_date("Invalid Date").should == "Never"
    end

    it "should properly format a valid date" do
      humanized_date(DateTime.now).should_not == "Never"
    end

    it "should create a list of hyperlinks for each tag" do
      tags = ["ruby", "sinatra"]
      link_to_tags(tags).should == "<a href='/tags/ruby' rel='ruby'>ruby</a>, <a href='/tags/sinatra' rel='sinatra'>sinatra</a>"
    end

  end

  describe Aerial::Git do

    before do
      #Grit.debug = true
      Aerial.repo.stub!(:add).and_return(true)
      Aerial.repo.stub!(:commit_index).and_return(true)
      Aerial.repo.status.untracked.stub!(:empty?).and_return(false)
    end

    it "should commit changes" do
      Aerial::Git.commit("/path/to/change", "message").should == true
    end

    it "should commit all changes" do
      Aerial::Git.commit_all.should == true
    end

    it "should add the remote repository " do
      Grit.debug = true
      Aerial::Git.push
      Aerial.repo.remotes.should == ""
    end

  end

  after do
    delete_git_repo
  end

end
