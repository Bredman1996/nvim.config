return {
  'bredman1996/web-search.nvim',
  config = function()
    vim.keymap.set('n', '<leader>wS', '<cmd>WebSearch<CR>', { desc = 'WebSearch Prompt' })
    vim.keymap.set('v', '<leader>wS', '<cmd>WebSearchSelection<CR>', { desc = 'WebSearch Search Highlighted' })
    vim.keymap.set('v', '<leader>wt', '<cmd>WebSearchTerraform<CR>', { desc = 'WebSearch Search Terraform' })
  end,
  opts = {
    sourceMaps = {},
  },
}
