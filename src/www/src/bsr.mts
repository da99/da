
/*
  *
  * This version of html.js is for 'build-side rendering.'
  * It is meant for builds, not server or client side rendering.
  */

import lodash from 'lodash';
import type { Attributes } from './base.mts';
import SETTINGS from '/apps/jaki.club/settings.json';
import PUBLIC_FILES from '/apps/jaki.club/tmp/raw_files.json';
// import sanitizeHtml from 'sanitize-html';

import {
  split_id_class,
  is_plain_object,
  is_void_tagname
} from './base.mts';

type BChild = string | BElement

class BElement {
  tagname: string;
  class_list: string[] | null;
  attrs: Attributes;
  tagid: undefined | string;
  childs: BChild[];

  constructor(tag_name: keyof HTMLElementTagNameMap, raw_id_class: string, raw_attrs: Partial<HTMLElementTagNameMap[keyof HTMLElementTagNameMap]>, eles: BChild[]) {
    const { class_list, tag_id } = split_id_class(tag_name, raw_id_class);
    this.tagname = tag_name;
    this.class_list = class_list;
    this.attrs = raw_attrs;
    if (typeof tag_id == 'string')
      this.attrs['id'] = tag_id;
    this.childs = eles;
    if (this.childs.length > 0 && is_void_tagname(this.tagname)) {
      throw `elements of ${this.tagname} may not have child elements.`;
    }
  }

  to_html() {
    let html = `<${this.tagname}`;
    const class_list = this.class_list;

    if (class_list)
      if (class_list.length > 0) {
        html += ` class="${class_list.map(x => lodash.escape(x)).join(' ')}"`;
      }

    for (const k in this.attrs) {
      let new_k = k;
      switch (k.toLowerCase()) {
        case 'htmlfor':
          new_k = 'for';
        break;
      }
      html += ` ${new_k}="${lodash.escape(this.attrs[k as keyof Attributes])}"`
    } // for

    html += '>';

    if (is_void_tagname(this.tagname))
      return html;

    for (const c of this.childs) {
      if (typeof c === 'string')
        html += lodash.escape(c);
      else
        html += c.to_html();
    }

    html += `</${this.tagname}>`
    return html;
  }
} // BElement

/*
  * e('input', {name: "_something"}, "My Text")
  * e('a.red#ID', {href: "https://some.url"}, "My Text")
  * e('div', e('span', "My Text"))
  * e('div#main', e('span', "My Text"))
  * e('div#main',
  *   e('span', "My Text"),
  *   e('div', "My Text")
  * )
*/
export function element<T extends keyof HTMLElementTagNameMap>(tag_name: T, ...pieces : (BChild | Partial<HTMLElementTagNameMap[T]>)[]) {
  const eles: BChild[] = [];
  let attrs = undefined;
  let id_class: string = '';
  for (let i = 0; i < pieces.length; i++) {
    const x = pieces[i];
    if (typeof x === "string") {
      if (i == 0 && (x.at(0) == '#' || x.at(0) == '.')) {
        id_class = x;
        continue;
      }
      eles.push(x);
      continue;
    }

    if (is_plain_object(x)) {
      attrs = x as Partial<HTMLElementTagNameMap[T]>;
      continue;
    }

    eles.push(x as BElement);
  }
  return new BElement(tag_name, id_class, attrs || {}, eles );
} // export function

// export function fragment(...eles: (string | Element)[]) {
//   let dom_fragment = document.createDocumentFragment();
//   for (const x of eles) {
//     if (typeof x === 'string')
//       dom_fragment.appendChild(document.createTextNode(x));
//     else
//       dom_fragment.appendChild(x);
//   }
//
//   return dom_fragment;
// }
//
// export function body(...eles: (string | Element)[]) {
//   document.body.append(fragment(...eles));
//   return document.body;
// }


// html5(
//   e('html', {lang: 'en'},
//     e('head',
//       e('title')
//     ),
//     e('body', )
//   )
// )
export function html5(...eles: BChild[]) {
    return `<!DOCTYPE html><html lang="en">\n${eles.map(e => to_html(e)).join('')}</html>`;
} // func

export function to_html(x: BChild) {
  if (typeof x === 'string')
    return lodash.escape(x);
  else
    return x.to_html();
}

//
// function set_attrs(ele: Element, attrs: Attributes) {
//   for (const k in attrs) {
//     switch (k) {
//       case 'htmlFor':
//         ele.setAttribute('for', attrs[k]);
//         break;
//       case 'href':
//         try {
//           ele.setAttribute(k, (new URL(attrs['href'])).toString());
//         } catch (e) {
//           console.warn("Invalid url.")
//         }
//         break;
//       default:
//         ele.setAttribute(k, attrs[k]);
//
//     } // switch
//   }
//   return ele;
// }

export class Static {
  name: string;
  constructor(raw_name: string) {
    this.name = raw_name;
  }

  get index_mjs() { return  static_url(`/section/${this.name}/index.mjs`) ; }
  get index_html() { return  static_url(`/section/${this.name}/index.html`) ; }
  get index_css() { return  static_url(`/section/${this.name}/index.css`); }

  // static fetch(sPath: string) {
  //   const fin = static_url(c, sPath);
  //   console.log(`-- Fetching: ${fin}`)
  //   return fetch( fin );
  // }
} // class

export function static_url(sPath: string) {
  const public_file = PUBLIC_FILES[sPath as keyof typeof PUBLIC_FILES];
  if (!public_file)
    throw new Error(`!!! File not found: ${sPath}`);

  if (public_file == '')
    return `${SETTINGS.static_url}${sPath}`;

  return sPath;
}
