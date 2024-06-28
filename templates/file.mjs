
const MANIFEST = $JSON ;

export default {

  files: MANIFEST,

  path(key) {
    const file = MANIFEST[key];

    if (typeof IS_DEV === 'boolean')
      return key;

    if (file)
      return MANIFEST[key]["public_path"];

    throw new Error(`File not found: ${key}`);
  },

};
