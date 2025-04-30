-- ===============================================
-- UTILITIES =====================================
-- ===============================================
-- Function to send a notification asynchronously
function notify_async(...)
  -- Capture the arguments passed to this function (message, level, opts)
  local args = { ... }

  -- Schedule a function to run on the next event loop iteration
  vim.schedule(function()
    -- Call vim.notify with the captured arguments
    vim.notify(unpack(args))
  end)
end

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
