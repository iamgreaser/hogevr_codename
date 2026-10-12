local assets = {
   fonts = {},
   shaders = {},
}

local SHADERS = {
   diffuse = {
      vertex = "shaders/diffuse.vert",
      fragment = "shaders/diffuse.frag",
   }
}

function assets.load()
   print("フォントを読込み中")
   assets.fonts.main = lovr.graphics.newFont("dat/NotoSansCJK-Regular.ttc", 32, 4.0)

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
         assets.shaders[k] = lovr.graphics.newShader(blob_vertex, blob_fragment, {
            label = k,
         })
      end
   end
end

return assets
