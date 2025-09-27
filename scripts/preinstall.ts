import { rmSync, unlinkSync } from 'fs';

// A strange bug introduced by NPM. When it comes to lifecycle events, installing the dependencies before running the preinstall script is utterly incorrect.
// Because of an odd NPM problem, we must check the other package manager to remove the files it produced.
// https://github.com/npm/cli/issues/2660

const isUsingPnpm = process.env.npm_execpath?.includes('pnpm');
const isUsingNpm = process.env.npm_execpath?.includes('npm');
const isUsingYarn = process.env.npm_execpath?.includes('yarn'); // yarn is weird and doesn't run preinstall scripts

if (!isUsingPnpm) {
  console.error(
    '\x1b[31m',
    `Dependencies must be installed via PNPM:
    $ pnpm install
  `,
  );
  rmSync('node_modules', { recursive: true, force: true });
  if (isUsingNpm) unlinkSync('package-lock.json');
  if (isUsingYarn) unlinkSync('yarn.lock');
  process.exit(1);
}