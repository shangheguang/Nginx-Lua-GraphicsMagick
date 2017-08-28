--[[
 * 用Lua脚本实现自定义图片尺寸,动态生成缩略图。
 * 本脚本依赖于 GraphicsMagick，请预先安装，并且在_Conf中更改其路径。
 * 图片地址：http://img.website.com/article/a/b2/ab2238796d5711eedea6911d6da617c5.jpg_100_100
]]

-- 默认配置
local _Conf = {
    -- 版本信息
    _VERSION = "1.0.1",

    -- GraphicsMagick executable file path
    GraphicsMagickPath = "/usr/bin/gm",

    -- 过滤规则匹配路径
    FileLocalPath = "/data/img/img.website.com",

    -- 默认图片质量
    ImageDefaultQuality = 90,
}

-- 基础函数
local _Func = {
    _VERSION = _Conf._VERSION,
    RegMatch = ngx.re.find,
}

function _Func.FileExists(FileName)
    local FileHandler = io.open(FileName,"r")
    local result = false
    if FileHandler ~= nil then
        result = true
        io.close(FileHandler)
    end
    return result
end

-- 获取裁剪方式
local mode = tonumber(ngx.var.arg_mode)
-- 获取图片的品质
local image_quality  = tonumber(ngx.var.arg_quality)

-- 组装成额外的参数

-- 扩展名
local ext_info = ""
-- 参考点
local gravity = ""
-- 图片质量，默认为90
local quality = _Conf.ImageDefaultQuality

-- 图片裁剪模式。
if mode then
    ext_info = "_m_" .. mode
    local dp = "center"
    if mode == 1 then
        dp = "northwest"
    end
    if mode == 2 then
        dp = "west"
    end
    gravity = "-gravity ".. dp .." -extent " .. ngx.var.width .. "x" .. ngx.var.height
end

-- 是否传入了图片质量参数。
if image_quality then
    ext_info = ext_info .. "_q_" .. image_quality
    quality = image_quality
end

-- 本地原始文件
local origin_local_file = _Conf.FileLocalPath .."/" .. ngx.var.file_path .. "/" .. ngx.var.file_name .. "." .. ngx.var.file_ext

-- 目标文件名
local target_file_name = ngx.var.file_name .. "-" .. ngx.var.width .. "x" .. ngx.var.height .. ext_info .. "." .. ngx.var.file_ext

-- 目标文件返回路径
local target_file_uri = ngx.var.file_path .. "/" .. target_file_name

-- 目标文件本地路径
local target_local_file = _Conf.FileLocalPath .."/" .. ngx.var.file_path .. "/" .. target_file_name

-- 判断文件是否存在,如果存在,并且需要重定向,则跳转,否则访问地址则图片地址
if not _Func.FileExists(target_local_file) then
    local command = _Conf.GraphicsMagickPath .. " convert " .. origin_local_file .. " -thumbnail \"" .. ngx.var.width .. "x" .. ngx.var.height .. "^\" -quality " .. quality .. " +profile \"*\" " .. gravity .. " " .. target_local_file
    os.execute(command)
end

-- /usr/local/bin/gm convert /Users/shang/img.website.com/upload_files/a.jpg -thumbnail "20x30^" -quality 80 +profile "*" -gravity center -extent 20x30 /Users/shang/img.website.com/upload_files/a-20x30_m_0_q_80.jpg

ngx.exec("/" .. target_file_uri)


