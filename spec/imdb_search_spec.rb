
require File.dirname(__FILE__) + '/spec_helper'

describe ImdbSearch do

  describe 'search that returns multiple movies' do

    before(:each) do
      @imdb_search = ImdbSearch.new('indiana jones')
      @imdb_search.stub!(:open).and_return(open("#{$samples_dir}/sample_search.html"))
    end

    it "should query IMDB url" do
      @imdb_search.should_receive(:open).with("http://www.imdb.com/find?q=indiana+jones;s=tt").and_return(open("#{$samples_dir}/sample_search.html"))
      @imdb_search.send(:document)
    end

    describe "movies" do

      it "should be a collection of ImdbMovie instances" do
        @imdb_search.movies.should be_an_instance_of(Array)
        @imdb_search.movies.should_not be_empty
        @imdb_search.movies.each do |movie|
          movie.should be_an_instance_of(ImdbMovie)
        end
      end

      # it "should include 'Indiana Jones and the Last Crusade'" do
      #   @imdb_search.movies.map { |m| m.title }.should include('Indiana Jones and the Last Crusade')
      # end

      it "should not have titles with HTML tags" do
        @imdb_search.movies.each do |movie|
          movie.title.should_not match(/<.+>/)
        end
      end

      it "should not have duplicate movies" do
        all_movie_ids = @imdb_search.movies.collect {|m| m.id}
        unique_movie_ids = all_movie_ids.uniq
        all_movie_ids.should == unique_movie_ids
      end
    end

  end

  describe 'search that redirects to the lone matching movie' do

    before(:each) do
      @imdb_search = ImdbSearch.new('some extremely specific search for indiana jones')
      @imdb_search.stub!(:open).and_return(open("#{$samples_dir}/sample_movie.html"))
    end

    describe "movies" do

      it "should be a collection containing a single ImdbMovie instance" do
        @imdb_search.movies.size.should == 1
        @imdb_search.movies.first.should be_an_instance_of(ImdbMovie)
      end

      it "should have the correct ID" do
        @imdb_search.movies.first.id.should == '0097576'
      end

      it "should have the correct title" do
        @imdb_search.movies.first.title.should == 'Indiana Jones and the Last Crusade'
      end
    end

  end

  describe 'searches with potential encoding issues' do

    before(:each) do
      @imdb_search = ImdbSearch.new('torrente')
      @imdb_search.stub!(:open).and_return(open("#{$samples_dir}/sample_spanish_search.html"))
    end

    describe "movies" do

      # it "should include 'Misión en Marbella'" do
      #   @imdb_search.movies.map { |m| m.title }.should include('Misión en Marbella')
      # end

    end

  end

end
