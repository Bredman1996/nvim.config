return {
  {
    'xTacobaco/cursor-agent.nvim',
    config = function()
      vim.keymap.set('n', '<leader>cs', ':CursorAgent<CR>', { desc = 'Cursor Agent: Toggle terminal' })
      vim.keymap.set('v', '<leader>ca', ':CursorAgentSelection<CR>', { desc = 'Cursor Agent: Send Selection' })
      vim.keymap.set('n', '<leader>cA', ':CursorAgentBuffer<CR>', { desc = 'Cursor Agent: Send buffer' })
    end,
  },
}
