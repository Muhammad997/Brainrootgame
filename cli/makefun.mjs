#!/usr/bin/env node
// Brainrot 3D METEOR CLI wrapper: core bundle lives in cli/vendor/makefun.mjs.
import { main } from "./vendor/makefun.mjs";
const argv = process.argv.slice(2);
const code = await main(argv, {
	out: (t) => process.stdout.write(t.endsWith("\n") ? t : `${t} `),
	err: (t) => process.stderr.write(t.endsWith("\n") ? t : `${t} `),
	env: process.env,
	streams: { stdout: process.stdout, stderr: process.stderr },
});
process.exitCode = code;
