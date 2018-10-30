
describe "Head" do

  describe "title" do
    it "accepts a String" do
      actual = DA_HTML.to_html { head { title "the title" } }
      expect = %(<head><title>the title</title></head>)
      assert actual == expect
    end # === it
  end # === desc "title"

  describe "meta_utf8" do
    it "renders a META tag" do
      actual = DA_HTML.to_html { head { meta_utf8 } }
      expect = %(<head><meta http-equiv="Content-Type" content="text/html; charset=UTF-8"></head>)
      assert actual == expect
    end # === it
  end # === desc "meta_utf8"

  describe "name(String)" do
    it "returns an Attribute" do
      actual = DA_HTML.to_html { tag(:something, name("Bob")) }
      expect = %(<something name="Bob">)
      assert actual == expect
    end # === it
  end # === desc "name"

  describe "content(String)" do
    it "returns an Attribute" do
      actual = DA_HTML.to_html { tag(:something, content("The 90s")) }
      expect = %(<something content="The 90s">)
      assert actual == expect
    end # === it
  end # === desc "content(String)"

  describe "description(String)" do
    it "renders a META tag" do
      actual = DA_HTML.to_html { head { description("Something special.") } }
      expect = %(<head><meta name="description" content="Something special."></head>)
      assert actual == expect
    end # === it
  end # === desc

  describe "author(String)" do
    it "renders a META tag" do
      actual = DA_HTML.to_html { head { author("Pierre Nelson") } }
      expect = %(<head><meta name="author" content="Pierre Nelson"></head>)
      assert actual == expect
    end # === it
  end # === desc

  describe "stylesheet(String)" do
    it "renders a LINK tag" do
      actual = DA_HTML.to_html { head { stylesheet("/file.css") } }
      expect = %(<head><link rel="stylesheet" href="/file.css"></head>)
      assert actual == expect
    end # === it
  end # === desc "stylesheet(String)"

end # === desc "Meta"
