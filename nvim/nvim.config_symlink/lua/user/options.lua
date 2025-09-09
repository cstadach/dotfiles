-- [[ Setting options ]]
-- See `:help vim.o`
local options = {
  swapfile = false,
  hidden = true,
  autoread = true,
  autowrite = true,
  wrap = false,
  hlsearch = true,
  mouse = 'a',
  clipboard = 'unnamed',
  -- Enable break indent
  breakindent = true,
  -- Save undo history
  undofile = true,
  -- Case insensitive searching UNLESS /C or capital in search
  ignorecase = true,
  smartcase = true,
  -- Decrease update time
  updatetime = 250,
  timeout = true,
  timeoutlen = 300,
  -- Set completeopt to have a better completion experience
  completeopt = 'menuone,noselect',
  -- NOTE: You should make sure your terminal supports this
  termguicolors = true,
}
for k, v in pairs(options) do
  vim.opt[k] = v
end

-- Make line numbers default
vim.wo.number = true

-- Keep signcolumn on by default
vim.wo.signcolumn = 'yes'

