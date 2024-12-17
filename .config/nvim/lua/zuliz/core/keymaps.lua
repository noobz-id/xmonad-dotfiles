-- leader key
vim.g.mapleader = " " -- space as leader

-- consist
local keymap = vim.keymap

keymap.set("n", "<leader>nh", ":nohl<CR>", { desc = "clear highlight search"} )

-- window management
keymap.set("n", "<leader>sv", "<C-w>v", { desc = "split window vertical" } )
keymap.set("n", "<leader>sh", "<C-w>s", { desc = "split window horizontal" } )
keymap.set("n", "<leader>se", "<C-w>=", { desc = "make split equal size" } ) 
keymap.set("n", "<leader>sc", "<cmd>close<CR>", { desc = "close current split window" } )

-- tab
keymap.set("n", "<leader>to", "<cmd>tabnew<CR>", { desc = "open new tab" } )
keymap.set("n", "<leader>tc", "<cmd>tabclose<CR>", { desc = "close current tab" } )
keymap.set("n", "<leader>tn", "<cmd>tabn<CR>", { desc = "go to next tab" } )
keymap.set("n", "<leader>tp", "<cmd>tabp<CR>", { desc = "go to previous tab" } )
keymap.set("n", "<leader>tf", "<cmd>tabnew %<CR>", { desc = "open current buffer to new tab" } )

-- terminal split
keymap.set("n", "<leader>st", "<cmd>belowright split | terminal<CR>i", { noremap = true, silent = true, desc = "open terminal split bellow" } )


