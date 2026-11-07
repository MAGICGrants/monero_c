import { type MoneroSymbols, moneroSymbols, type SymbolName } from "./symbols.ts";

export type MoneroDylib = Deno.DynamicLibrary<MoneroSymbols>;
export type Dylib = MoneroDylib;

export let dylib: Dylib;

export const fns = new Proxy({} as { [K in SymbolName]: MoneroDylib["symbols"][`MONERO_${K}`] }, {
  get(_, symbolName: SymbolName) {
    return dylib.symbols[`MONERO_${symbolName}` as keyof Dylib["symbols"]];
  },
});

export function loadMoneroDylib(newDylib?: MoneroDylib) {
  if (newDylib) {
    dylib = newDylib;
    return;
  }

  let libPath: string;
  switch (Deno.build.os) {
    case "darwin":
      libPath = "./lib/monero_libwallet2_api_c.dylib";
      break;
    case "android":
      libPath = "./lib/libmonero_libwallet2_api_c.so";
      break;
    case "windows":
      libPath = "./lib/monero_libwallet2_api_c.dll";
      break;
    default:
      libPath = "./lib/monero_libwallet2_api_c.so";
      break;
  }

  dylib = Deno.dlopen(libPath, moneroSymbols);
}
