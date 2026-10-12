local assets = require("assets")

local SCENE_OBJECTS = {}
local SCENE_ROOTS = {}

local function build_example_scene()
   local root = {}

   table.insert(SCENE_OBJECTS, {
      type = "text",
      -- 普通の高さ:
      -- * 男性: 1.70mぐらい
      -- * 女性: 1.60mぐらい
      -- 中に選んだらみんな様は一緒にコンプレできるね ^_-
      position = {x = 0.0, y = 1.65, z = -1.0},
      size = 0.1,
      text = "HogeVRへよ𰻞こそ！！！１　直",
   })
   table.insert(root, #SCENE_OBJECTS)

   table.insert(SCENE_OBJECTS, {
      type = "text",
      position = {x = 0.0, y = 1.65 - 0.1, z = -1.0},
      size = 0.1,
      text = "おなら禁止",
      color = {r = 1.0, g = 0.5, b = 0.5, a = 1.0},
   })
   table.insert(root, #SCENE_OBJECTS)

   table.insert(SCENE_OBJECTS, {
      type = "box",
      position = {x = 0.0, y = 0.0 - 1.0/2, z = -0.0},
      size = {x = 10.0*2.0, y = 1.0, z = 10.0*2.0},
      color = {r = 0.5, g = 1.0, b = 0.5, a = 1.0},
   })
   table.insert(root, #SCENE_OBJECTS)

   return root
end

function lovr.load()
   assets.load()

   print("世界のシーンを準備中")
   SCENE_ROOTS = {build_example_scene()}

   print("始めましょう〜")
end

local function set_drawing_defaults(pass)
   pass:setFont(assets.fonts.main)
end

local DRAW_HANDLERS = {}

function lovr.draw(pass)
   set_drawing_defaults(pass)

   do
      local _,root
      for _,root in ipairs(SCENE_ROOTS) do
         local _,id
         for _,id in ipairs(root) do
            local o = SCENE_OBJECTS[id]
            if o.color then pass:setColor(o.color.r, o.color.g, o.color.b, o.color.a) end
            DRAW_HANDLERS[o.type](o, pass)
            if o.color then pass:setColor(1,1,1,1) end
         end
      end
   end

   --
end

function DRAW_HANDLERS.text(o, pass)
   pass:setShader("font")
      pass:text(o.text, o.position.x, o.position.y, o.position.z, o.size)
   pass:setShader(nil)
end

function DRAW_HANDLERS.box(o, pass)
   pass:setShader(assets.shaders.diffuse)
      pass:box(o.position.x, o.position.y, o.position.z, o.size.x, o.size.y, o.size.z)
   pass:setShader(nil)
end
