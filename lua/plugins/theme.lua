return {
    { -- You can easily change to a different colorscheme.
        -- Change the name of the colorscheme plugin below, and then
        -- change the command in the config to whatever the name of that colorscheme is.
        --
        -- If you want to see what colorschemes are already installed, you can use `:Telescope colorscheme`.
        'rose-pine/neovim',
        name = 'rose-pine',
        priority = 1000, -- Make sure to load this before all the other start plugins.
        init = function()
            vim.g.rose_pine_disable_background = true
            vim.cmd.colorscheme 'rose-pine'
            vim.cmd.hi 'Comment gui=none'
            vim.api.nvim_set_hl(0, 'Normal', { background = 'NONE' })
        end,
    },
}
