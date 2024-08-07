
export const Response_States = ['ok', 'invalid', 'try_again', 'not_yet', 'expired'] as const;
export const Event_States = ['request', 'network_error', 'server_error', 'response', 'loading'] as const;
export const CSS_States = [...Response_States, ...Event_States] as const;

export type Response_Handler = (resp: Response_Origin, req: Request_Origin) => void;

export interface Fields_State {
  [index: string]: string
}

export interface Custom_Event_Detail<T> extends Event {
  detail: T
}

export interface Network_Error_Origin {
  error: any,
  request: Request_Origin
}

export interface Request_Origin {
  readonly request: FetchRequestInit,
  readonly dom_id: string,
  do_request: boolean
}

export interface Response_Origin {
  readonly status: typeof Response_States[number],
  readonly data: {
    [index: string]: string
  }
}

export interface Response_Detail {
  request: Request_Origin,
  response: Response_Origin,
}

const THE_BODY = document.body;
export const IS_DEV = window.location.href.indexOf('://localhost:') > 0 || window.location.href.indexOf('://the-stage.') > 0;

import { is_plain_object, SPLIT_TAG_NAME_PATTERN } from './base.mts';

export function log(...args: any[]) {
  if (!IS_DEV)
    return false;

  return console.log(...args);
}

export function warn(...args: any[]) {
  if (!IS_DEV)
    return false;

  return console.warn(...args);
}

export function fragment(...eles: (string | Element)[]) {
  let dom_fragment = document.createDocumentFragment();
  for (const x of eles) {
    if (typeof x === 'string')
      dom_fragment.appendChild(document.createTextNode(x));
    else
      dom_fragment.appendChild(x);
  }

  return dom_fragment;
}

export function body(...eles: (string | Element)[]) {
  THE_BODY.append(fragment(...eles));
  return THE_BODY;
}

export function split_id_class(e: Element, id_class: string): Element {
  let curr = '';
  for (const s of id_class.split(SPLIT_TAG_NAME_PATTERN) ) {
    switch (s) {
      case '.':
      case '#':
        curr = s;
        break;
      case '':
        // ignore
        break;
      default:
        switch (curr) {
        case '.':
          e?.classList.add(s);
        break;
        case '#':
          e?.setAttribute('id', s);
        break;
      }
    }
  }
  return e;
} // func

/*
  * e('input', {name: "_something"}, "My Text")
  * e('a', '.red#ID', {href: "https://some.url"}, "My Text")
  * e('div', e('span', "My Text"))
  * e('div', '#main', e('span', "My Text"))
  * e('div', '#main',
  *   e('span', "My Text"),
  *   e('div', "My Text")
  * )
*/
export function element<T extends keyof HTMLElementTagNameMap>(tag_name: T, ...body: (string | Partial<HTMLElementTagNameMap[T]> | Element)[]) {
  const e = document.createElement(tag_name)
  for (let i = 0; i < body.length; i++ ){
    const v = body[i];
    if (typeof v === 'string') {
      if (i === 0 && v.at(0) === '#' || v.at(0) === '.') {
        split_id_class(e, v);
        continue;
      }
      e.appendChild(document.createTextNode(v));
      continue;
    }

    if (is_plain_object(v)) {
      set_attrs(e, v);
      continue;
    }

    e.appendChild(v as Element);
  }

  return e;
} // export function

function set_attrs(ele: Element, attrs: any) {
  for (const k in attrs) {
    switch (k) {
      case 'htmlFor':
      case 'htmlfor':
        ele.setAttribute('for', attrs[k]);
        break;
      case 'href':
        try {
          ele.setAttribute(k, (new URL((attrs as HTMLElementTagNameMap['a'])[k])).toString());
        } catch (e) {
          warn("Invalid url.")
        }
        break;
      default:
        ele.setAttribute(k, attrs[k]);

    } // switch
  }
  return ele;
}


export const dom = {

  id: {
    __plus_one(): number {
      let current_id_count =  THE_BODY.getAttribute('data-id-count') || "-1";
      const new_id = parseInt(current_id_count) + 1;
      THE_BODY.setAttribute('data-id-count', new_id.toString());
      return new_id;
    },

    // Gets id attribute of element.
    // Creates an id if it is missing.
    upsert(e: Element): string {
      const id = e.getAttribute('id');
      if (id)
        return id;
      const new_id = `${e.tagName}_${dom.id.__plus_one()}`
      e.setAttribute('id', new_id);
      return new_id;
    }
  },

  do(f: (e: Element) => void, ...args: Array<string | Element>) {
    const a_max = args.length;
    for (let a_i = 0; a_i < a_max; a_i++) {
      const x = args[a_i];

      if (typeof x === 'string') {
        document.querySelectorAll(x).forEach(f);
        continue;
      }

      f(x);
    }
  },

  to_element(x: string | HTMLElement) {
    if (typeof x === 'string') {
      const ele = document.getElementById(x);
      if (ele)
        return ele;
      return false;
    }
    return x;
  },

  fetch(x: string | HTMLElement, data?: { [index: string]: any }) {
    const e = dom.to_element(x);
    if (!e)
      return false;

    const dom_id = dom.id.upsert(e);

    const action = (e.dataset['action'] || '').trim();
    if (action.length < 2)
      throw new Error(`No action/url found on ${dom_id}`);

    const full_action = page.full_url(action);
    const method = (e.dataset['method'] || 'POST').toUpperCase();

    http.fetch(dom_id, full_action, method as 'GET' | 'POST', data)
  },

}; // export dom


export const template = {
  MATCH: /^\{([a-zA-Z0-9\.\-\_]+)\}$/ ,

  update: {
    _dataset_key(e: HTMLElement, data: { [index: string]: string | number }) {
      const key = e.dataset['key'];
      if (!key)
        return false;
      const value = data[key];
      if (!value) {
        log(`--- Data value for, ${key}, in template, ${e.id}, not found: ${key} in ..`)
        log(data);
        return e;
      }
      e.textContent = value.toLocaleString();
      return e;
    },

    by_keys(dom_id: string, data: { [index: string]: string | number }) {
      return document.querySelectorAll(`#${dom_id} [data-key]`).forEach(x => template.update._dataset_key(x as HTMLElement, data));
    },
  },

  compile(df : HTMLTemplateElement, values: { [key: string]: any}) {
    const doc = df.content.cloneNode(true);
    const nodes = document.createNodeIterator(doc, NodeFilter.SHOW_ELEMENT);

    let n;
    while (n = nodes.nextNode()) {
      const e = n as HTMLElement;
      if (e.hasAttributes()) {
        for (const a of e.attributes) {
          const m = a.value.match(template.MATCH);
          if (!m)
            continue;
          a.value = values[m[1]].toLocaleString();
        }
      }

      if (e.childNodes.length == 1 && e.childNodes[0].nodeType === Node.TEXT_NODE) {
        const match = e.innerHTML.match(template.MATCH)
        if (!match)
          continue;
        const val = values[match[1]];
        if (!val)
          continue;
        e.textContent = val.toLocaleString();
      }

      const e_parent = e.parentNode;
      if (e.tagName.toUpperCase() === 'TEMPLATE') {
        const e_id = e.dataset['id'];
        const target = ((e_id) ? (document.getElementById(e_id) || e) : e) as HTMLTemplateElement;
        const loop = e.dataset['loop'];
        if (loop) {
          const vals = values[loop];

          if (!vals)
            continue;
          for (const x of vals) {
            const sub_tmpl = template.compile(target, x);
            if (sub_tmpl && e_parent) {
              e_parent.insertBefore(sub_tmpl, e);
            }
          }
        } // if loop

          const key = e.dataset['key'];
          if (key) {
            const val = values[key];
            if (!val)
              continue;

            const sub_tmpl = template.compile(target, val);
            if (sub_tmpl && e_parent) {
              e_parent.insertBefore(sub_tmpl, e);
            }
          }

          e.remove();
      } // if TEMPLATE
    } // while
      return doc;
  } // compile
}; // const template

export const css = {
  by_selector: {
    do(f: (e: Element) => void, selector: string) {
      document.querySelectorAll(selector).forEach(f)
      return selector;
    },

    hide(s: string) { css.by_selector.do(css.by_element.hide, s); },
    unhide(s: string) { css.by_selector.do(css.by_element.unhide, s); },

    reset_to(new_class: typeof CSS_States[number], selector: string) {
      css.by_selector.reset(selector);
      css.by_selector.do((e) => e.classList.add(new_class), selector);
    },

    reset(selector: string) {
      css.by_selector.do(css.by_element.reset, selector);
    }
  },

  by_id: {
    do(f: (e: Element) => void, id: string) {
      const e = document.getElementById(id);
      if (e)
        f(e);
      return id;
    },
    hide(id: string) { css.by_id.do(css.by_element.hide, id); },
    unhide(id: string) { css.by_id.do(css.by_element.unhide, id); },
    reset(id: string) { css.by_id.do(css.by_element.reset, id); },
    reset_to(new_class: typeof CSS_States[number], id: string) {
      css.by_id.reset(id);
      css.by_id.do((e) => e.classList.add(new_class), id);
    }
  },

  by_element: {
    hide(e: Element) { e.classList.add('hide'); },
    unhide(e: Element) { e.classList.remove('hide'); },
    reset(e: Element) {
      for (const s of CSS_States)
        e.classList.remove(s);
    },
    reset_to(new_class: typeof CSS_States[number], e: Element) {
      css.by_element.reset(e);
      e.classList.add(new_class);
    }
  }

}; // export const

export const use = {
  default_forms() {
    return THE_BODY.addEventListener('click', form.on_click_submit);
  } // export function
};

export const form = {

  invalid_fields(form: HTMLFormElement, fields: { [index: string]: string }) {
    for (const k in fields) {
      const target = form.querySelector(`label[for='${k}'], input[name='${k}']`);
      const fieldset = (target && target.closest('fieldset')) || form.querySelector(`fieldset.${k}`);
      if (fieldset)
        fieldset.classList.add('invalid');
    }
    return form;
  },

  data(f: HTMLFormElement) {
    const raw_data = new FormData(f);
    const data: any = {};
    for (let [k,v] of raw_data.entries()) {
      if (data.hasOwnProperty(k)) {
        if(!Array.isArray(data[k]))
          data[k] = [data[k]];
        data[k].push(v);
      } else
        data[k] = v;
    }
    return data;
  }, // export function

  on_click_submit(ev: MouseEvent) {
    const ele =  ev.target && (ev.target as Element).tagName && (ev.target as Element);

    if (!ele)
      return false;

    if (ele.tagName !== 'BUTTON')
      return false;

    const button = ele as HTMLButtonElement;

    const e_form = button.closest('form');
    if (!e_form) {
      warn('Form not found for: ' + button.tagName);
      return false;
    }

    ev.preventDefault();
    ev.stopPropagation();

    dom.id.upsert(e_form);
    if (button.classList.contains('submit'))
      return dispatch.form_submit(e_form);
    if (button.classList.contains('cancel'))
      return dispatch.form_cancel(e_form);

    warn(`Unknown action for form: ${e_form.id}`);
    return false;
  }, // === function

  event_allow_only_numbers(event: Event) {
        const ev = event as KeyboardEvent;
        switch (ev.key) {
          case '0':
            case '1': case '2': case '3': case '4': case '5':
            case '6': case '7': case '8': case '9':
            true;
          break;
          default:
            ev.stopPropagation();
          ev.preventDefault();
        }
        // do something
  },

  input_only_numbers(selector: string) {
    return document.querySelectorAll(selector).forEach(
      e => e.addEventListener('keydown', form.event_allow_only_numbers)
    );
  } // === function
}; // export const


export const page = {
  full_url(x: string): string {
    const url = new URL(location.toString());
    url.pathname = x;
    return url.toString();
  },

  go_to(raw: string) {
    window.location.href = page.full_url(raw);
  },

  reload(seconds?: number) {
    if (typeof seconds !== 'number')
      return window.location.reload();

    if (seconds < 0)
      throw new Error(`!!! Invalid value for reload_in: ${seconds}`);

    setTimeout(page.reload, seconds * 1000);
    return;
  }
};


export const dispatch = {

  form_submit(e: HTMLFormElement) {
    const action_url = e.getAttribute('action') || '';
    const form_id = dom.id.upsert(e);

    if (action_url.indexOf('local') === 0) {
      const data = form.data(e);
      THE_BODY.dispatchEvent(new CustomEvent('* submit', {detail: data}));
      THE_BODY.dispatchEvent(new CustomEvent(`${e.id} submit`, {detail: data}));
      return true;
    }

    http.fetch(form_id, e.getAttribute('action'), 'POST', form.data(e))
    return true;
  },

  form_cancel(e: HTMLFormElement) {
    const data = form.data(e);
    THE_BODY.dispatchEvent(new CustomEvent('* cancel', {detail: data}));
    THE_BODY.dispatchEvent(new CustomEvent(`${e.id} cancel`, {detail: data}));
    return true;
  },

  request(req: Request_Origin) {
    THE_BODY.dispatchEvent(new CustomEvent('* request', {detail: req}));
    THE_BODY.dispatchEvent(new CustomEvent(`${req.dom_id} request`, {detail: req}));
  },

  async response(req: Request_Origin, raw_resp: Response) {
    if (!raw_resp.ok)
      return dispatch.server_error(req, raw_resp);

    const resp: Response_Origin = (await raw_resp.json()) as Response_Origin;

    const x_sent_from = raw_resp.headers.get('X_SENT_FROM');

    if (!x_sent_from) {
      warn(`X_SENT_FROM key not found in headers: ${Array.from(raw_resp.headers.keys()).join(', ')}`);
      return resp;
    }

    if(x_sent_from !== req.dom_id) {
      warn(`X_SENT_FROM and dom id origin do not match: ${x_sent_from} !== ${req.dom_id}`);
      return resp;
    }

    const e = document.getElementById(req.dom_id);

    const detail = {detail: {response: resp, request: req}};

    THE_BODY.dispatchEvent(new CustomEvent('* response', detail));
    THE_BODY.dispatchEvent(new CustomEvent(`${req.dom_id} response`, detail));

    if (e)
      css.by_id.reset(req.dom_id);

    return dispatch.status(resp, req);
  },

  status(resp: Response_Origin, req: Request_Origin) {
    const status = resp.status;
    const detail = {detail: {response: resp, request: req}};
    css.by_id.reset_to(status, req.dom_id);
    THE_BODY.dispatchEvent(new CustomEvent(`* ${status}`, detail));
    THE_BODY.dispatchEvent(new CustomEvent(`${req.dom_id} ${status}`, detail));
  },

  server_error(req: Request_Origin, raw_resp: Response) {
    warn(`!!! Server Error: ${raw_resp.status} - ${raw_resp.statusText}`);

    const e = document.getElementById(req.dom_id);
    if (e) {
      css.by_element.reset_to('server_error', e);
      const detail = {detail: {request: req, response: raw_resp}};
      THE_BODY.dispatchEvent(new CustomEvent('* server_error', detail));
      THE_BODY.dispatchEvent(new CustomEvent(`${e.id} server_error`, detail));
      return true;
    }
    return false;
  },

  network_error(error: any, request: Request_Origin) {
    warn(error);
    warn(`!!! Network error: ${error.message}`);
    const detail = {detail: {error, request}};
    THE_BODY.dispatchEvent(new CustomEvent('* network_error', detail));
    THE_BODY.dispatchEvent(new CustomEvent(`${request.dom_id} network_error`, detail));

    const e = document.getElementById(request.dom_id);
    if (e) {
      css.by_element.reset_to('network_error', e);
      return true;
    }

    return false;
  } // === function
}; // export dispatch

export const http = {
  fetch(dom_id: string, raw_action: | null | string, method: 'POST' | 'GET', data?: { [index:string]: any}) {

    const action = (raw_action || '').trim();

    if (action.length < 2)
      throw new Error(`action attribute not set for ${dom_id}`);

    const fetch_data: FetchRequestInit = {
      method,
      referrerPolicy: "no-referrer",
      cache: "no-cache",
      headers: {
        "Content-Type": "application/json",
        X_SENT_FROM: dom_id
      },
      body: JSON.stringify(data || {})
    };

    const request: Request_Origin = {
      request: fetch_data,
      dom_id: dom_id,
      do_request: true
    };

    dispatch.request(request);

    if (!request.do_request)
      return false;

    const full_action = page.full_url(action);

    css.by_id.reset_to('loading', dom_id);

    setTimeout(async () => {
      fetch(full_action, fetch_data)
      .then((resp: Response) => dispatch.response(request, resp))
      .catch((err: any) => dispatch.network_error(err, request));
    }, 450);

    return true;
  }
}; // export const

export const on = {

  submit(selector: string, f: (data: any) => void)  {
    THE_BODY.addEventListener(`${selector} submit`, function (ev: Event) {
      const cev = ev as Custom_Event_Detail<Request_Origin>;
      f(cev.detail);
    });
  },

  request(selector: string, f: (req: Request_Origin) => void) {
    THE_BODY.addEventListener(`${selector} request`, function (ev: Event) {
      const cev = ev as Custom_Event_Detail<Request_Origin>;
      const req = cev.detail;
      f(req);
    });
  },

  network_error(selector: string, f: (req: Request_Origin, err: any) => void) {
    THE_BODY.addEventListener(`${selector} network_error`, (ev: Event) => {
      const cev = ev as Custom_Event_Detail<Network_Error_Origin>;
      f(cev.detail.error, cev.detail.request);
    });
  },

  server_error(selector: string, f: Response_Handler) {
    THE_BODY.addEventListener(`${selector} server_error`, (ev: Event) => {
      const cev = ev as Custom_Event_Detail<Response_Detail>;
      f(cev.detail.response, cev.detail.request);
    });
  },

  response(selector: string, f: Response_Handler) {
    THE_BODY.addEventListener(`${selector} response`, function (ev: Event) {
      const cev = ev as Custom_Event_Detail<Response_Detail>
      const resp = cev.detail.response;
      const req = cev.detail.request;
      f(resp, req);
    });
  },

  ok(selector: string, f: Response_Handler) { return on.status('ok', selector, f); },
  invalid(selector: string, f: Response_Handler) { return on.status('invalid', selector, f); },
  try_again(selector: string, f: Response_Handler) { return on.status('try_again', selector, f); },
  not_yet(selector: string, f: Response_Handler) { return on.status('not_yet', selector, f); },
  expired(selector: string, f: Response_Handler) { return on.status('expired', selector, f); },

  status(s: typeof CSS_States[number], selector: string, f: Response_Handler) {
    return THE_BODY.addEventListener(`${selector} ${s}`, (ev: Event) => {
      const cev = ev as Custom_Event_Detail<Response_Detail>;
      f(cev.detail.response, cev.detail.request);
    });
  },

  by_id: {
    click(id: string, f: (ev: Event) => void) {
      THE_BODY.addEventListener('click', function (ev: Event) {
        const target = ev.target;
        if (target) {
          const e = target as Element;
          if (e.id === id)
            f(ev);
        }
      });
    }
  }

}; // export on

