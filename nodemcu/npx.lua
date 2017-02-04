local M = {
    n_leds = 1,
    matrix = nil,
    buffer = nil,
    zig_zag = false
}
local mt = {
  __call = function(_, pixels, zig_zag)
      if type(pixels) == 'table' then
        M.matrix = pixels
        M.n_leds = pixels[1] * pixels[2]
        M.zig_zag = zig_zag
      else
        M.n_leds = pixels
      end
      M.buffer = ws2812.newBuffer(M.n_leds, 3)
      return M
    end
}
setmetatable(M, mt)

local INIT = false

local function init()
  if not INIT then
    ws2812.init()
    INIT = true
  end
end

local function color_to_str(c)
  return string.char(c.g or 0, c.r or 0, c.b or 0)
end

local function coords_to_i(coords)
  local n = coords[2]
  if M.zig_zag and coords[1] % 2 == 0 then
    n = M.matrix[2] + 1 - n
  end
  return (coords[1] - 1) * M.matrix[2] + n
end

local function i_to_coords(i)
  local m = math.ceil((i-1) / M.matrix[2]) + 1
  local n = ((i-1) % M.matrix[2]) + 1
  if M.zig_zag and m % 2 == 0 then
    n = M.matrix[2] + 1 - n
  end
  return m,n
end

function M.write()
  init()
  ws2812.write(M.buffer)
end

function M.color_pixel(i, c, write, empty)
  if empty then M.empty_buffer() end
  if type(i) == 'table' then
    i = coords_to_i(i)
  end
  M.buffer:set(i, color_to_str(c))
  if write ~= false then M.write() end -- write by default
  return M.buffer
end

function M.color_buffer(colors, empty)
  if empty then M.empty_buffer() end
  for i=1,M.n_leds do
    local c
    if M.matrix then
      local m,n = i_to_coords(i)
      c = colors[m] and colors[m][n] or nil
    else
      c = colors[i]
    end
    if c then
        M.buffer:set(i, string.char(c.g or 0, c.r or 0, c.b or 0))
    end
  end
  M.write()
  return M.buffer
end

function M.fill_color(c,write)
  M.buffer:fill(c.g or 0, c.r or 0, c.b or 0)
  if write ~= false then M.write() end  -- write by default
  return M.buffer
end

function M.empty_buffer(write)
  M.fill_color({},write)
end

function M.fade_routine()
  local function fade()
    local direction = ws2812.FADE_OUT
    while true do
      for i=1,6 do
        M.buffer:fade(2,direction)
        M.write()
        coroutine.yield()
      end
      direction = direction == ws2812.FADE_OUT and ws2812.FADE_IN or ws2812.FADE_OUT
    end
  end
  local co = coroutine.create(fade)
  return function()
    coroutine.resume(co)
  end
end

function M.rotate(n)
  M.buffer:shift(n, ws2812.SHIFT_CIRCULAR)
  M.write()
end

return M
