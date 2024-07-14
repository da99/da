
/* This is also used for CSRF protection. */
export const X_SENT_FROM = "X_SENT_FROM";

export type Attributes = Partial<HTMLElementTagNameMap[keyof HTMLElementTagNameMap]>;
// export type Attributes = Partial<HTMLAttributes>
// export interface Attributes {
//   htmlFor: string,
//   href: string
// }
export const VALID_PROTO = /^(http|https|ssh|ftp|sftp|gopher):\/\//i;
export const ObjectPrototype = Object.getPrototypeOf({});

export const SPLIT_TAG_NAME_VALID_PATTERN = /^([a-z0-9]+)([\.\#][a-z0-9\_]+)*$/
export const SPLIT_TAG_NAME_PATTERN = /([\.\#])/g

export const SPLIT_ID_CLASS_VALID_PATTERN = /^([\.\#][a-z0-9\_\-]+)+$/
export const SPLIT_ID_CLASS_PATTERN = /([\.\#])/g

export const EMAIL_PATTERN = /^[^@\.][^@]+@[^@\.]+\.[^@]+[^\.]$/;

export function is_email_valid(x: string) { return !!x.match(EMAIL_PATTERN); }

export function is_func(x: unknown) { return typeof x === "function"; }

export function is_plain_object(x: unknown) { return typeof x === 'object' && Object.getPrototypeOf(x) === ObjectPrototype; }

export function is_urlish(x: unknown) {
  if (typeof x !== 'string')
    return false;

  return VALID_PROTO.test(x.toLowerCase());
} // func

export function is_void_tagname(x: string) {
    switch (x) {
      case 'area':
      case 'base':
      case 'br':
      case 'col':
      case 'embed':
      case 'hr':
      case 'img':
      case 'input':
      case 'link':
      case 'meta':
      case 'param':
      case 'source':
      case 'track':
      case 'wbr':
        return true;
    }
    return false;
} // func

export function split_id_class<T extends keyof HTMLElementTagNameMap>(tag_name: T, new_class: string) {
  if (new_class == '')
    return {tag_name, tag_id: null, class_list: []};

  if (!new_class.match(SPLIT_ID_CLASS_VALID_PATTERN)) {
    throw new Error(`Invalid characters in id/class: ${new_class}`);
  }

  let curr = '';
  const class_list: string[] = [];
  let tag_id = undefined;
  for (const s of new_class.split(SPLIT_ID_CLASS_PATTERN) ) {
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
          class_list.push(s);
          break;
        case '#':
          tag_id = s;
          break;
      }
    }
  }

  return {tag_name, tag_id, class_list};
} // func

