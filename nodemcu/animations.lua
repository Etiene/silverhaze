local M = {
    speed = 100,
    color = {r=255,b=255},
    save_buffer = nil
}

function M.rotate(s)
  s = s or M.speed
  tmr.stop(0)
  tmr.alarm(0, s, 1, function()
      npx.rotate(1)
  end)
end

function M.fade(s)
  s = s or M.speed
  tmr.stop(1)
  local f = npx.fade_routine()
  tmr.alarm(1, s, 1, function()
      f()
  end)
end

function M.blink(s)
  s = s or M.speed
  M.save_buffer = npx.buffer:dump()
  local co = coroutine.create(function()
    while true do
      npx.empty_buffer(true)
      coroutine.yield()
      npx.buffer:replace(M.save_buffer)
      npx.write()
      coroutine.yield()
    end
  end)
  tmr.stop(1)
  tmr.alarm(1, s, 1, function()
    coroutine.resume(co)
  end)
end


function M.set_defaults(t)
  for k,v in pairs(t) do
    M[k]=v
  end
end

function M.stop()
  tmr.stop(0)
  tmr.stop(1)
  npx.empty_buffer(true)
end

return M
