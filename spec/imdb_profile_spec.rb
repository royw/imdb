require File.dirname(__FILE__) + '/spec_helper'

require 'tempfile'

TMPDIR = File.join(File.dirname(__FILE__), '../tmp')

# Time to add your specs!
# http://rspec.info/

describe "ImdbProfile" do

  before(:all) do
    File.mkdirs(TMPDIR)
  end

  after(:each) do
    Dir.glob(File.join(TMPDIR, "imdb_profile_spec*")).each { |filename| File.delete(filename) }
  end

  describe "Simple finds using ImdbProfile.first" do
    it "should find by imdb_id that is prefixed with a 'tt'" do
      profile = ImdbProfile.first(:imdb_id => 'tt0465234')
      profile.should_not == nil
    end

    it "should find by imdb_id that is not prefixed with 'tt'" do
      profile = ImdbProfile.first(:imdb_id => '0465234')
      profile.should_not == nil
    end

    it "should find by single title" do
      profile = ImdbProfile.first(:titles => ['National Treasure: Book of Secrets'])
      profile.should_not == nil
    end

    it "should find by multiple title" do
      profile = ImdbProfile.first(:titles => ['National Treasure: Book of Secrets', 'National Treasure 2'])
      profile.should_not == nil
    end

    it "should find by multiple title embedded in arrays" do
      profile = ImdbProfile.first(:titles => [['National Treasure: Book of Secrets'], 'National Treasure 2'])
      profile.should_not == nil
    end

    it "should find by AKA title" do
      profile = ImdbProfile.first(:titles => ['National Treasure 2'])
      profile.should_not == nil
    end
  end

  describe "multiple finds using ImdbProfile.all" do
    # We use two versions of "The Alamo" to test for year discrimination
    #  John Wayne's The Alamo produced and released in 1960, IMDB ID => tt0053580
    #  John Lee Hancock's The Alamo produced and released in 2004, IMDB ID => tt0318974

    # test all()
    it "should find multiple versions of The Alamo" do
      profiles = ImdbProfile.all(:titles => ['The Alamo'])
      profiles.length.should > 1
    end

    it "should find the two versions of The Alamo that we are interested in" do
      profiles = ImdbProfile.all(:titles => ['The Alamo'])
      imdb_ids = profiles.collect{|profile| profile.imdb_id}
      imdb_ids = imdb_ids.select{|ident| ident == 'tt0053580' || ident == 'tt0318974'}
      imdb_ids.uniq.compact.length.should == 2
    end
  end

  describe "find first using title and media year" do
    it "should find John Wayne's The Alamo by title with media year" do
      profile = ImdbProfile.first(:titles => ['The Alamo'], :media_years => [1960])
      profile.imdb_id.should == 'tt0053580'
    end

    it "should find John Lee Hancock's The Alamo by title with media year" do
      profile = ImdbProfile.first(:titles => ['The Alamo'], :media_years => [2004])
      profile.imdb_id.should == 'tt0318974'
    end
  end

  describe "find first using title and production year" do
    it "should find John Wayne's The Alamo by title with production year" do
      profile = ImdbProfile.first(:titles => ['The Alamo'], :production_years => [1960])
      profile.imdb_id.should == 'tt0053580'
    end

    it "should find John Lee Hancock's The Alamo by title with production year" do
      profile = ImdbProfile.first(:titles => ['The Alamo'], :production_years => [2004])
      profile.imdb_id.should == 'tt0318974'
    end
  end

  describe "find first using title and released year" do
    it "should find John Wayne's The Alamo by title with released year" do
      profile = ImdbProfile.first(:titles => ['The Alamo'], :released_years => [1960])
      profile.imdb_id.should == 'tt0053580'
    end

    it "should find John Lee Hancock's The Alamo by title with released year" do
      profile = ImdbProfile.first(:titles => ['The Alamo'], :released_years => [2004])
      profile.imdb_id.should == 'tt0318974'
    end
  end

  describe "fuzzy year matching (plus or minus a year)" do
    # fuzzy years are only supported for production and released years, not media years
    it "should not find John Wayne's The Alamo by title with the media year off by a year" do
      profile1 = ImdbProfile.first(:titles => ['The Alamo'], :media_years => [1959])
      profile2 = ImdbProfile.first(:titles => ['The Alamo'], :media_years => [1961])
      (profile1.should be_nil) && (profile2.should be_nil)
    end

    it "should find John Wayne's The Alamo by title with the production year off by a year" do
      profile1 = ImdbProfile.first(:titles => ['The Alamo'], :production_years => [1959])
      profile2 = ImdbProfile.first(:titles => ['The Alamo'], :production_years => [1961])
      (profile1.imdb_id.should == 'tt0053580') && (profile2.imdb_id.should == 'tt0053580')
    end

    it "should find John Wayne's The Alamo by title with the released year off by a year" do
      profile1 = ImdbProfile.first(:titles => ['The Alamo'], :released_years => [1959])
      profile2 = ImdbProfile.first(:titles => ['The Alamo'], :released_years => [1961])
      (profile1.imdb_id.should == 'tt0053580') && (profile2.imdb_id.should == 'tt0053580')
    end

    it "should not find John Wayne's The Alamo by title with the production year off by two years" do
      profile1 = ImdbProfile.first(:titles => ['The Alamo'], :production_years => [1958])
      profile2 = ImdbProfile.first(:titles => ['The Alamo'], :production_years => [1962])
      (profile1.should be_nil) && (profile2.should be_nil)
    end

    it "should not find John Wayne's The Alamo by title with the released year off by two years" do
      profile1 = ImdbProfile.first(:titles => ['The Alamo'], :released_years => [1958])
      profile2 = ImdbProfile.first(:titles => ['The Alamo'], :released_years => [1962])
      (profile1.should be_nil) && (profile2.should be_nil)
    end
  end

  describe "let's make sure the generated xml from to_xml() is valid" do
    it "should be able to convert to xml and then from xml" do
      hash = nil
      begin
        profile = ImdbProfile.first(:imdb_id => 'tt0465234')
        xml = profile.to_xml
        hash = XmlSimple.xml_in(xml)
      rescue
        hash = nil
      end
      hash.should_not be_nil
    end
  end

  describe "test caching the profile to/from a file" do
    it "should not create a file if a :filespec option is passed that is nil" do
      profile = ImdbProfile.first(:titles => ['The Alamo'], :released_years => [1960], :filespec => nil)
      Dir.glob(File.join(TMPDIR, "imdb_profile_spec*")).empty?.should be_true
    end

    it "should create a file if a :filespec option is passed" do
      filespec = get_temp_filename
      profile = ImdbProfile.first(:titles => ['The Alamo'], :released_years => [1960], :filespec => filespec)
      (File.exist?(filespec) && (File.size(filespec) > 0)).should be_true
    end

    it "should load from a file if a :filespec option is passed and the file exists" do
      filespec = get_temp_filename
      profile1 = ImdbProfile.first(:titles => ['The Alamo'], :released_years => [1960], :filespec => filespec)
      profile2 = ImdbProfile.first(:filespec => filespec)
      profile1.imdb_id.should == profile2.imdb_id
    end

    it "should not load from a file if a :filespec option is passed and the file does not exists" do
      filespec = get_temp_filename
      profile = ImdbProfile.first(:filespec => filespec)
      profile.should be_nil
    end
  end

  describe "When years are invalid (nil, 0, or '0')" do
    it "should handle media year == nil" do
      profile = ImdbProfile.first(:titles => ['National Treasure: Book of Secrets'], :media_years => [nil])
      profile.should_not == nil
    end

    it "should handle media year == 0" do
      profile = ImdbProfile.first(:titles => ['National Treasure: Book of Secrets'], :media_years => [0])
      profile.should_not == nil
    end

    it "should handle media year == '0'" do
      profile = ImdbProfile.first(:titles => ['National Treasure: Book of Secrets'], :media_years => ['0'])
      profile.should_not == nil
    end

    it "should handle production year == nil" do
      profile = ImdbProfile.first(:titles => ['National Treasure: Book of Secrets'], :production_years => [nil])
      profile.should_not == nil
    end

    it "should handle media production == 0" do
      profile = ImdbProfile.first(:titles => ['National Treasure: Book of Secrets'], :production_years => [0])
      profile.should_not == nil
    end

    it "should handle production year == '0'" do
      profile = ImdbProfile.first(:titles => ['National Treasure: Book of Secrets'], :production_years => ['0'])
      profile.should_not == nil
    end

    it "should handle released year == nil" do
      profile = ImdbProfile.first(:titles => ['National Treasure: Book of Secrets'], :released_years => [nil])
      profile.should_not == nil
    end

    it "should handle released year == 0" do
      profile = ImdbProfile.first(:titles => ['National Treasure: Book of Secrets'], :released_years => [0])
      profile.should_not == nil
    end

    it "should handle released year == '0'" do
      profile = ImdbProfile.first(:titles => ['National Treasure: Book of Secrets'], :released_years => ['0'])
      profile.should_not == nil
    end
  end

  def get_temp_filename
    outfile = Tempfile.new('imdb_profile_spec', TMPDIR)
    filespec = outfile.path
    outfile.unlink
    filespec
  end
end