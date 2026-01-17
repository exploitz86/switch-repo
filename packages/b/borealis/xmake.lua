local function getVersion(version)
    local versions ={
        ["2024.04.23-alpha"] = "archive/ae9b053ce527faaef5356d1acfd4f7a392604451.tar.gz",
        ["2024.07.03"] = "archive/5abaa17b01709656a8a03ce5f041094e2dfb32ad.tar.gz",
        ["2024.07.06"] = "archive/009fe776a29510202d73d576708c41ec9d5b461b.tar.gz",
        ["2025.04.13"] = "archive/83a0681d20caa95fdfb3f50b913a52406246b60a.tar.gz",
        ["2025.07.12"] = "archive/8a23ed0ceb821769912278f1640a1d9306fe6791.tar.gz",
        ["2025.08.02"] = "archive/8027b02b16cb52f115c6a772efd1e770c61f87a4.tar.gz",
        ["2025.12.07"] = "archive/77c2051eeb58dbe3e5ecac15b8392dd226574133.tar.gz",
    }
    return versions[tostring(version)]
end

package("borealis")
    set_homepage("https://github.com/exploitz86/borealis")
    set_description("Hardware accelerated, Nintendo Switch inspired UI library for PC, Android, iOS, PSV, PS4 and Nintendo Switch")
    set_license("Apache-2.0")

    set_urls("https://github.com/exploitz86/borealis/$(version)", {
        version = getVersion
    })
    add_versions("2024.04.23-alpha", "f1dde726c122af4a40941ce8e0b27655eda9b0bc6e80d4e9034f5c7978b3e288")
    add_versions("2024.07.03", "16a8e6c7369fc2a002a81bd70ee517cfd3b2e7dc221d8d7ba7f67519ca7697d8")
    add_versions("2024.07.06", "c82fae079082d64e92f45d158dc27b44f69ea5c93527f0bf51adc756fd73d389")
    add_versions("2025.04.13", "1bc975eb4e7852bd9877f66b5af504c3a01f7bd066c698bcb1c4423682637333")
    add_versions("2025.07.12", "0681a6e83343b673e0baa551121db40a0c99c4715005ef1c07c4b36f5c272bd2")
    add_versions("2025.08.02", "e9868c490a4e2299c26bfdc3d1eb9392b31bcad7af528742f8f7ab3abff91305")
    add_versions("2025.12.07", "c187f7974e9fbf0271a518514f50d85214ab0638c83230a762d75446853c9106")

    add_configs("window", {description = "use window lib", default = "glfw", type = "string"})
    add_configs("driver", {description = "use driver lib", default = "opengl", type = "string"})
    add_configs("winrt", {description = "use winrt api", default = false, type = "boolean"})
    add_deps(
        "nanovg",
        "yoga =2.0.1",
        "nlohmann_json",
        "fmt",
        "tweeny",
        "stb",
        "tinyxml2"
    )
    add_includedirs("include")
    if is_plat("windows") then
        add_includedirs("include/compat")
        add_syslinks("wlanapi", "iphlpapi", "ws2_32")
    elseif is_plat("cross") then 
        add_deps("libnx", "glm")
    elseif is_plat("linux") then
        add_deps("dbus")
    end
    
    on_load(function (package)
        local window = package:config("window")
        local driver = package:config("driver")
        local winrt = package:config("winrt")
        if window == "glfw" then
            package:add("deps", "glfw")
        elseif window == "sdl" then
            package:add("deps", "sdl2")
        elseif window == "nanovg" then
            if is_plat("cross") then
                package:add("deps", "deko3d")
            end
        end
        if driver == "opengl" then
            --package:add("deps", "glad =0.1.36")
        elseif driver == "d3d11" then
            package:add("syslinks", "d3d11")
        end
        if winrt then
            package:add("syslinks", "windowsapp")
        end
    end)
    on_install(function (package)
        os.cp(path.join(os.scriptdir(), "port", "xmake.lua"), "xmake.lua")
        local configs = {}
        configs["window"] = package:config("window")
        configs["driver"] = package:config("driver")
        configs["winrt"] = package:config("winrt") and "y" or "n"
        import("package.tools.xmake").install(package, configs)
        os.cp("library/include/*", package:installdir("include").."/")
        os.rm(package:installdir("include/borealis/extern"))
        os.cp("library/include/borealis/extern/libretro-common", package:installdir("include").."/")
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <borealis.hpp>

            static void test() {
                volatile void* i = (void*)&brls::Application::init;
                if (i) {};
            }
        ]]}, {
            configs = {languages = "c++20", defines = { "BRLS_RESOURCES=\".\"" }},
        }))
    end)
