import { assert } from 'chai';
import { element as E, body, form_data, split_tag_name } from '../src/html.mts';
import { element as BE, html5 } from '../src/bsr.mts';
import { allow_tags, is_urlish, is_plain_object,  } from '../src/base.mts';
// import { describe } from 'node:test';

allow_tags('html', 'head', 'meta', 'body', 'link', 'img', 'title');

describe('helper functions', function () {
  describe('is_urlish', function () {
    it('should return true when string starts with http://', function () {
      assert.equal(is_urlish('http://k.com.com'), true);
    });
    it('should return true when string starts with https://', function () {
      assert.equal(is_urlish('https://k.com.com'), true);
    });
    it('should return false when string starts with javascript:', function () {
      assert.equal(is_urlish('javascript://alert'), false);
    });
  });

  describe('is_plain_object', function () {
    it('should return true when prototype is Object protoype', function () {
      assert.equal(is_plain_object({a: 'true'}), true);
    })
    it('should return false when passed an Array', function () {
      assert.equal(is_plain_object([1,2,3]), false);
    })
  });

  describe('split_tag_name', function () {
    it('should return an HTML Element: a', function () {
      const x = split_tag_name('a');
      assert.equal(x.tagName, 'A');
    });
    it('should add the class name to the element: a.hello', function () {
      const x = split_tag_name('a.hello');
      assert.equal(x.classList.toString(), 'hello');
    });
    it('should add the id to the element: a#the_link', function () {
      const x = split_tag_name('a#the_link');
      assert.equal(x.id, 'the_link');
    });
    it('should add the classes and id to the element: a#the_link.hello.world', function () {
      const x = split_tag_name('a#the_link.hello.world');
      assert.equal(x.id, 'the_link');
      assert.equal(x.classList.toString(), 'hello world');
    });
  });
});


describe('element', function () {
  it('returns an Element', function () {
    const x = E('a', {href: 'https://jaki.club/'}, 'Jaki.ClUb');
    assert.equal(x.tagName, 'A');
  });
  it('returns an Element with a class name', function () {
    const x = E('a', '.hello.world.2', {href: 'https://jaki.club/'}, 'Jaki.ClUb');
    assert.equal(x.classList.toString(), 'hello world 2');
  });
  it('returns an Element with an id', function () {
    const x = E('a', '#main', {href: 'https://jaki.club/'}, 'Jaki.ClUb');
    assert.equal(x.id, 'main');
  });
  it('sets an attributes on the element', function () {
    const href = 'https://jaki.club/';
    const x = E('a', '#main', {href: href}, 'Jaki.ClUb');
    assert.equal(x.href, href);
  });
  it('adds text nodes to the element', function () {
    const x = E('div', 'a', 'b', 'c');
    assert.equal(x.textContent, 'abc');
  });
  it('adds elements as children', function () {
    const x = E('div', E('p', 'hello'), E('p', 'world'));
    assert.equal(x.innerHTML, '<p>hello</p><p>world</p>');
  });
});

describe('attributes', function () {
  it('changes htmlFor to for', function () {
    const x = E('label', {htmlFor: 'hello'}, 'Hello');
    assert.equal(x.getAttribute('for'), 'hello')
  })
});

describe('body', function () {
  it('returns the body', function () {
    const b = body(E('p', 'hello world 1'));
    assert.equal(b, document.body);
  });

  it('appends the elements to the body', function () {
    const p = E('p', '#h2', 'hello world 2');
    body(p);
    assert.equal(p, document.body.children[document.body.children.length - 1]);
  });
});

describe('form_data', function () {
  it('returns an object', function () {
    const data = form_data(E('form', E('input', {name: 'msg', type: 'hidden', value: 'hello'})));
    assert.deepEqual(data, {msg: 'hello'});
  });
  it('returns an object with arrays for multiple values', function () {
    const data = form_data(
      E('form',
        E('input', {name: 'msg', type: 'hidden', value: 'hello1'}),
        E('input', {name: 'msg', type: 'hidden', value: 'hello2'})
      )
    );
    assert.deepEqual(data, {msg: ['hello1', 'hello2']});
  });
});

describe('Build Side Rendering', function () {
  describe('element', function () {
    it('throws if #id is not: a-z 0-9 _', function () {
      assert.throws(function () {
        BE('p', '#hel"lp', 'spacer');
      }, `Invalid characters in id/class: #hel"lp`)
    });

    it('throws if .class is not: a-z 0-9 _', function () {
      assert.throws(function () {
        BE('p', '.he"p', 'spacer');
      }, `Invalid characters in id/class: .he"p`)
    });

    it('.to_html returns an HTML string', function () {
      const html = BE('span', 'hello');
      assert.equal(html.to_html(), '<span>hello</span>');
    });

    it('.to_html escapes tags', function () {
      const html = BE('span', `<script>hello</script>`);
      assert.equal(html.to_html(), '<span>&lt;script&gt;hello&lt;/script&gt;</span>');
    });

    it('.to_html escapes quotation marks', function () {
      const html = BE('span', `"hello'`);
      assert.equal(html.to_html(), '<span>&quot;hello&#39;</span>');
    });

    it('.to_html renders attributes', function () {
      const html = BE('html', {lang: 'en'});
      assert.equal(html.to_html(), '<html lang="en"></html>');
    });

    it('.to_html does not render closing tags for void elements', function () {
      const html = BE('body', BE('meta'), BE('link'), BE('img'));
      assert.equal(html.to_html(), '<body><meta><link><img></body>');
    });

    // it('.to_html escapes quotes in the class attribute', function () {
    //   const html = BE('a.he"lo', 'hello');
    //   assert.equal(html.to_html(), '<a class="he&quot;lo">hello</a>');
    // });

    it('.to_html escapes quotes in any attribute', function () {
      const html = BE('p', {bob: "hel'lo"});
      assert.equal(html.to_html(), '<p bob="hel&#39;lo"></p>');
    });

  });

  describe('html5', function () {
    it('returns a string with a doctype', function () {
      const html = html5(
        BE('html',
          BE('head',
            BE('title', 'hello')
          ),
          BE('body')
        )
      );
      assert.equal(html, `<!DOCTYPE html>\n<html><head><title>hello</title></head><body></body></html>`)
    });
  });
});
