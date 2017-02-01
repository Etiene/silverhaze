local M = {
    pixels = 1,
    matrix = nil
}
local mt = {
  __call = function(_, pixels,matrix)
      M.pixels = pixels
      M.matrix = matrix
      return M
    end
}
setmetatable(M, mt)

local init = false
local canvas = {}
local OFF = string.char(0,0,0)

local function stop_timers()

end

local function init()
  if not init then
    ws2812.init()
    init = true
  end
end

function M.empty_canvas()
  for i = 1, M.pixels do
    canvas[i] = OFF
  end
  return
end

function M.write(cnv)
  init()
  ws2812.write(table.concat(cnv or canvas))
end

local function color_to_str(c)
  return string.char(c.g, c.r, c.b)
end

function M.color(i, c)
  if type(i) == 'table' then
    i = (i[1] - 1) * M.matrix[2] + i[2]
  end
  canvas[i] = color_to_str(c)
  return canvas
end

function M.strip_color(c, n)
  init()
  ws2812.write(color_to_str(c):rep(n or M.pixels))
end

function M.off()
  M.strip_color{r=0, g=0, b=0}
end

return M
