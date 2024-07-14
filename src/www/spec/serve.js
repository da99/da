
import path from 'node:path';

const server = Bun.serve({
  port: 4567,
  async fetch(request) {
    const r_path = path.normalize(new URL(request.url).pathname);
    switch (r_path) {
      case "/":
        await Bun.spawn(['bin/__', 'build', 'test']).exited
        return new Response(Bun.file("spec/index.html"));
      case "/index.html":
      case "/favicon.ico":
        return new Response(Bun.file(path.join("spec", r_path)));
      default:
        return new Response(Bun.file(path.join("build", r_path)));
    }

  },
});

console.log(`Listening on ${server.url}`);

