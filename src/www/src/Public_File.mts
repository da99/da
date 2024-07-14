
import { Database } from 'bun:sqlite';
import { $ } from "bun";
import path from 'node:path';

const NOT_UPLOADED = 0
const UPLOADED = 1
const PRUNED = 2

type JSON_FILE = {
  local_path: string,
  public_path: string,
  etag: string,
  created_at: string
}

type FILE_MANIFEST = {
  [index: string]: JSON_FILE
}

type SITE_SETTINGS = {
  BUILD_DIR: string,
  BUCKET_NAME: string
}

const THE_SITE_SETTINGS = await (Bun.file('settings.json').json() as Promise<SITE_SETTINGS>);
const PUBLIC_FILES = await (Bun.file('tmp/public_files.json').json() as Promise<FILE_MANIFEST>)

type FILE_ROW = {
  local_path: string,
  public_path: string,
  etag: string,
  created_at: string,
  status: typeof NOT_UPLOADED | typeof UPLOADED | typeof PRUNED
}

const THE_CMD = Bun.argv.slice(2).join(' ');
const DB_FILE = 'public_files.sqlite';


// ==========================================================================
class DB {
  static FILE = 'public_files.sqlite';
  static BUCKET_PATH = path.join(THE_SITE_SETTINGS.BUCKET_NAME, THE_SITE_SETTINGS.BUILD_DIR)
  static base_sql = '/apps/www/sql/public_file.sql';

  static async is_file_exists() {
    return Bun.file(DB.FILE).exists();
  }

  db: Database;

  constructor() {
    this.db = new Database(DB_FILE, { create: true });
    this.db.exec('PRAGMA journal_mode = WAL;');
  }

  async setup() {
    const raw_meta_sql = await Bun.file(DB.base_sql).text();
    const meta_sql = raw_meta_sql.split(/-+\ +SPLIT\ +-+/);
    for (const q of meta_sql) {
      console.warn(`-- Running: ${q.slice(0,15).trim()}...`)
      console.warn(this.db.query(q).all());
    }
    return true;
  }

  new_files() {
    const this_db = this;
    const files = Object.values(PUBLIC_FILES);
    const f_paths: string[] = files.map((f) => f.public_path);
    const q = this_db.db.query(`
        SELECT public_path
        FROM files
        WHERE public_path in ( ${Array(files.length).fill('?').map((_x,i) => `?${i+1}`)} )
        ORDER BY public_path;
    `);
    const old_files = q
    .all(...f_paths)
    .map((x) => (x as Partial<JSON_FILE>)['public_path']);
    return files.filter((f) => !old_files.includes(f.public_path));
  }

  old_files() {
    const this_db = this;
    const current_files = Object.values(PUBLIC_FILES);
    const current_public_paths: string[] = current_files.map((f) => f.public_path);
    const q = this_db.db.query(`
        SELECT *
        FROM files
        WHERE status = '${UPLOADED}'
          AND public_path NOT IN ( ${Array(current_public_paths.length).fill('?').map((_x,i) => `?${i+1}`)} )
        ORDER BY public_path;
    `);
    const old_files = q.all(...current_public_paths);
    return old_files as FILE_ROW[];
  }

  async upload() {
    const this_db = this;
    return Promise.allSettled(
      this.new_files()
      .map(async function (f: JSON_FILE) {
        return this_db.upload_file(f);
      })
    );
    // return Promise.allSettled(proms);
  }

  async prune() {
    const this_db = this;
    const old_files = this.old_files();
    if (old_files.length === 0)
      return old_files;

    const q = this_db.db.query(`
        UPDATE files
        SET status = ?1
        WHERE public_path = ?2;
    `);
    return Promise.allSettled(old_files.map(async function (f) {
      const r2_object = path.join(DB.BUCKET_PATH, f.public_path);
      // console.warn(`--- Deleting: ${cmd}`);
      const prom = $`bun x wrangler r2 object delete ${r2_object}`;
      return prom.then(function (so) {
        if (so.exitCode !== 0)
          return false;
        console.warn('--- updating db')
        return q.values(PRUNED, f.public_path);
      }).then(function (x) {
        if (x)
          return f;
        else
          return false;
      });
    }));
  }

  // === method
  //
  // async is_uploaded(f: JSON_FILE) {
  //   const q = this.db.query(`SELECT local_path FROM files WHERE local_path = $lp;`);
  //   const row = await q.get({ $lp: f.local_path, $stat: NOT_UPLOADED}) as | FILE_ROW;
  //   if (!row)
  //     return false;
  //   return row.status === UPLOADED;
  // } // === method

  async upload_file(f: JSON_FILE) {
    const this_db = this;
    const bucket_path = path.join(DB.BUCKET_PATH, f.public_path)
    const local_path  = path.join(THE_SITE_SETTINGS.BUILD_DIR, f.local_path);
    const prom = $`bun x wrangler r2 object put "${bucket_path}" --file="${local_path}"`;
    return prom.then(async function (x) {
      if (x.exitCode !== 0) {
        console.warn(`!!! Failed to upload: ${f.local_path}`);
        return false;
      }
      console.warn(`--- Uploaded file: ${bucket_path} (${local_path})`);
      const q = this_db.db.query(`INSERT INTO files(public_path, local_path, etag, created_at, status)
                    VALUES($pp, $lp, $etag, $created_at, $status)
                    ON CONFLICT(public_path) DO UPDATE SET status=$status;`);
      return q.get({
        $pp: f.public_path, $lp: f.local_path,
        $etag: f.etag, $created_at: f.created_at, $status: UPLOADED
      })
    });
  } // === method

  close() {
    this.db.close();
  }
}
// === class
// ==========================================================================

const THE_DB = new DB();

switch (THE_CMD) {
  case "setup bucket":
    await THE_DB.setup();
    THE_DB.close();
    break;

  case 'prune files':
    const old_files = await THE_DB.prune();
    if (old_files.length === 0) {
      console.warn(`--- No old files to prune.`)
    }
    THE_DB.close();
    break;

  case "upload to bucket":
    const results = await THE_DB.upload();
    if (results.length === 0)
      console.warn('--- No files uploaded.');
    THE_DB.close();
    break;

  case 'list new files':
    THE_DB.new_files().forEach(x => console.log(`${x.local_path} -> ${x.public_path}`));
    THE_DB.close()
    break;

  case 'list old files':
    THE_DB.old_files().forEach(x => console.log(`${x.public_path} -> ${x.local_path}`));
    THE_DB.close()
    break;

  default:
    console.warn(`!!! Unknown command: ${THE_CMD}`)
    THE_DB.close();
    process.exit(1);
} // switch


// async function cmd(...raw: string[]) {
//   let cmd_args = raw;
//   if (cmd_args.length === 1)
//     cmd_args = cmd_args[0].trim().split(/\s+/);
//   console.warn(`=== ${cmd_args.join(' ')}`);
//   return Bun.spawn(cmd_args).exited
// }
//
