local DATA = {
   fonts = {},
   shaders = {},
}

local SHADERS = {
   diffuse = {
      vertex = "shaders/diffuse.vert",
      fragment = "shaders/diffuse.frag",
   }
}

local SCENE_OBJECTS = {}
local SCENE_ROOTS = {}

local function buildExampleScene()
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
   print("フォントを読込み中")
   DATA.fonts.main = lovr.graphics.newFont("dat/NotoSansCJK-Regular.ttc", 32, 4.0)

   -- シェーダーのコンパイルが遅いのでキャッシュがちょっと必要ですね
   lovr.filesystem.createDirectory("cache/shaders/")
   local shader_count = 0   -- ちょっと危ない名wwwwwww
   do
      local k,v
      for k,v in pairs(SHADERS) do
         shader_count = shader_count + 1
      end
      print("シェーダー数: " .. shader_count)
      for k,v in pairs(SHADERS) do
         -- CRCっぽいことが欲しいですけどLOVRでないそうのでデータの全部を比べます
         local cache_src_vertex = lovr.filesystem.read("cache/" .. k .. ".vert.src")
         local cache_src_fragment = lovr.filesystem.read("cache/" .. k .. ".frag.src")
         local src_vertex = assert(lovr.filesystem.read(v.vertex))
         local src_fragment = assert(lovr.filesystem.read(v.fragment))
         local blob_vertex, blob_fragment
         if (cache_src_vertex or "") == src_vertex and (cache_src_fragment or "") == src_fragment then
            blob_vertex = assert(lovr.filesystem.newBlob("cache/" .. k .. ".vert.blob"))
            blob_fragment = assert(lovr.filesystem.newBlob("cache/" .. k .. ".frag.blob"))
         else
            -- LOVR BUG: https://lovr.org/docs/v0.19.0/lovr.graphics.compileShader:
            --   bytecode = lovr.graphics.compileShader(stage (∊ ["vertex", "fragment", "compute"]), source)
            -- しかし、v0.19.0でこれを使う:
            --   bytecode_vertex, bytecode_fragment = lovr.graphics.compileShader(vertex_source, fragment_source)
            --   bytecode_compute = lovr.graphics.compileShader(compute_source)
            print("シェーダーを読込み中: \"" .. k .. "\" vertex")
            print("シェーダーを読込み中: \"" .. k .. "\" fragment")
            blob_vertex, blob_fragment = lovr.graphics.compileShader(src_vertex, src_fragment)
            assert(lovr.filesystem.write("cache/" .. k .. ".vert.src", src_vertex))
            assert(lovr.filesystem.write("cache/" .. k .. ".frag.src", src_fragment))
            assert(lovr.filesystem.write("cache/" .. k .. ".vert.blob", blob_vertex))
            assert(lovr.filesystem.write("cache/" .. k .. ".frag.blob", blob_fragment))
         end

         print("シェーダーを読込み中: \"" .. k .. "\" リンク")
         DATA.shaders[k] = lovr.graphics.newShader(blob_vertex, blob_fragment, {
            label = k,
         })
      end
   end

   print("世界のシーンを準備中")
   SCENE_ROOTS = {buildExampleScene()}

   print("始めましょう〜")
end

local function setDefaults(pass)
   pass:setFont(DATA.fonts.main)
end

local DRAW_HANDLERS = {}

function lovr.draw(pass)
   setDefaults(pass)

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
   pass:setShader(DATA.shaders.diffuse)
      pass:box(o.position.x, o.position.y, o.position.z, o.size.x, o.size.y, o.size.z)
   pass:setShader(nil)
end
