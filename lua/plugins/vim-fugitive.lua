return {
  {
    'tpope/vim-fugitive',
    config = function()
      vim.keymap.set('n', '<leader>gc', '<cmd>:Git commit -a<CR>', { desc = 'Git commit' })
      vim.keymap.set('n', '<leader>gp', '<cmd>:Git push<CR>', { desc = 'Git push' })
      vim.keymap.set('n', '<leader>gnb', '<cmd>:Git checkout -b<CR>', { desc = 'Git new branch' })
      vim.keymap.set('n', '<leader>gs', '<cmd>:Git status<CR>', { desc = 'Git status' })
      vim.keymap.set('n', '<leader>gaa', '<cmd>:Git add .<CR>', { desc = 'Git add all' })
    end,
  },
}
