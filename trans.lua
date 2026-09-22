require "import"
import "java.net.URLEncoder"
import "org.json.JSONArray"

local from, to, text, ltr = ...

if not text or text == "" then
    if ltr then ltr.onTransResult("") end
    return
end

local encodedText = URLEncoder.encode(text, "UTF-8")
local url = string.format("https://translate.googleapis.com/translate_a/single?client=gtx&sl=%s&tl=%s&dt=t&q=%s", 
    from, to, encodedText)

local headers = {
    ["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64)"
}

Http.get(url, nil, "UTF-8", headers, function(code, res)
    if code == 200 and res then
        local success = pcall(function()
            local jsonArray = JSONArray(res)
            local sentences = jsonArray.getJSONArray(0)
            local translatedText = ""
            
            for i = 0, sentences.length() - 1 do
                local item = sentences.getJSONArray(i)
                if not item.isNull(0) then
                    translatedText = translatedText .. item.getString(0)
                end
            end
            
            if translatedText ~= "" then
                ltr.onTransResult(translatedText)
            else
                ltr.onTransResult("Gagal memproses hasil terjemahan")
            end
        end)

        if not success then
            ltr.onTransResult("Gagal memproses hasil terjemahan")
        end
    else
        ltr.onTransResult("Error Koneksi: " .. tostring(code))
    end
end)