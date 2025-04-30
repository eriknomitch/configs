-- ===============================================
-- UTILITIES =====================================
-- ===============================================

-- function scandir(directory)
--     local i, t, popen = 0, {}, io.popen
--     local pfile = popen('ls -a "'..directory..'"')
--     for filename in pfile:lines() do
--         i = i + 1
--         t[i] = filename
--     end
--     pfile:close()
--     return t
-- end
vim.notify("Loaded: core/utilities.lua", vim.log.levels.INFO, { title = "Neovim" })
