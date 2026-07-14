local status_ok, treesitter = pcall(require, "nvim-treesitter")
if not status_ok then
  return
end

local ensure_installed = {
  'c',
  'cpp',
  'go',
  'lua',
  'python',
  'rust',
  'terraform',
  'tsx',
  'typescript',
  'vimdoc',
  'vim',
}

treesitter.setup {}

treesitter.install(ensure_installed)

local group = vim.api.nvim_create_augroup('UserTreesitter', { clear = true })

vim.api.nvim_create_autocmd('FileType', {
  group = group,
  callback = function(args)
    local ft = vim.bo[args.buf].filetype
    local lang = vim.treesitter.language.get_lang(ft)

    if not lang or not vim.tbl_contains(ensure_installed, lang) then
      return
    end

    local parser_ok = pcall(vim.treesitter.get_parser, args.buf, lang)
    if not parser_ok then
      return
    end

    vim.treesitter.start(args.buf, lang)
    vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
  end,
})
