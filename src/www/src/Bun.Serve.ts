
import { $ } from 'bun';

import { normalize, join } from "node:path";

const SETTINGS = await Bun.file('settings.json').json()

const THE_PORT = parseInt(SETTINGS['STATIC_PORT'] || '4568')
const STATIC_DIR = normalize(`./${join(SETTINGS['BUILD_DIR'])}`)
const BUILD_CMD = SETTINGS['BUILD_CMD_DEV'] || SETTINGS['BUILD_CMD']
const WATCH_DIRS = ['public', 'src']

console.log(`Starting server at: ${THE_PORT}, DIR: ${STATIC_DIR}, CMD: ${BUILD_CMD}, WATCH Dirs: ${WATCH_DIRS.join(', ')}`)

function is_html(x: string) {
  return x.indexOf('.html') > 0;
}

Bun.serve({
  port: THE_PORT, // defaults to $BUN_PORT, $PORT, $NODE_PORT otherwise 3000
  async fetch(req: Request) {
    const u = new URL(req.url);
    const f = Bun.file(join(STATIC_DIR, u.pathname));
    const exists = await f.exists();
    if (!exists)
      return new Response(`Not found: ${u.pathname}`, { status: 404 });

    // if this a .html request,
    //   re-build static files:
    if (is_html(u.pathname)) {
      console.log(`-- Running: ${BUILD_CMD}`)
      console.log(await $`sh -c ${BUILD_CMD}`.text());
    }

    const r = new Response(await f.arrayBuffer(), {
      headers: {
        "Content-Type": f.type,
      },
    });

    if (f.type.toUpperCase().indexOf('JAVASCRIPT') > 0)
      r.headers.set('Access-Control-Allow-Origin', '*');

    console.log(`${u.pathname} -> ${r.headers.get('Content-Type')}`);
    return r;
  },
});
