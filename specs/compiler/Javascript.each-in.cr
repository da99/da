
describe "Javascript.to_javascript each-in" do
  it "sets key" do
    html = <<-HTML
    <html><head></head><body>
      <template id="my_template">
        <each-in coll as k,x> <=k>: <=x> </each-in>
      </template>
    </body></html>
    HTML
    expected = <<-JS
      function my_template(data) {
          let io = "";
          for (let _coll__i = 0, _coll__keys = Object.keys(coll), _coll__length = _coll__keys.length; _coll__i < _coll__length; ++_coll__i) {
            let k = _coll__keys[_coll__i];
            let x = coll[k];
            io += k.toString();
            io += ": ";
            io += x.toString();
          }
          return io;
      } // function
    JS

    doc = DA_HTML.to_tags(html)
    actual = DA_HTML::Javascript.to_javascript(doc)

    assert DA.strip_each_line(actual) == DA.strip_each_line(expected)
  end # === it
end # === desc "Javascript.to_javascript each-in"
