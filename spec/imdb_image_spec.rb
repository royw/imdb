require File.dirname(__FILE__) + '/spec_helper'

describe ImdbMovie do
  
  describe 'Indiana Jones and the Last Crusade' do
    
    before(:each) do
      @imdb_image = ImdbImage.new("/rg/action-box-title/primary-photo/media/rm1203608832/tt0097576")
      @imdb_image.stub!(:open).and_return(open("#{$samples_dir}/sample_image.html"))
    end
  
    it "should query IMDB url" do
      @imdb_image.should_receive(:open).with("http://www.imdb.com/rg/action-box-title/primary-photo/media/rm1203608832/tt0097576").and_return(open("#{$samples_dir}/sample_image.html"))
      @imdb_image.send(:document)
    end
   
    it "should get the image" do
      @imdb_image.image.should == "http://ia.media-imdb.com/images/M/MV5BMTkzODA5ODYwOV5BMl5BanBnXkFtZTcwMjAyNDYyMQ@@._V1._SX216_SY316_.jpg"
    end
    
  end
  
end