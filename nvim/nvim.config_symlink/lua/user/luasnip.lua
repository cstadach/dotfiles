local status_ok, luasnip = pcall(require, "luasnip")
if not status_ok then
  return
end
luasnip.config.setup {}
require('luasnip.loaders.from_vscode').lazy_load()
require("luasnip.loaders.from_vscode").lazy_load({ paths = { "./luasnip" } })
