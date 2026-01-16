package("tegraexplorer")
    set_homepage("https://github.com/exploitz86/TegraExplorer")
    set_description("Payload for Switch exploit RCM mode")
    set_license("MIT")

    add_urls("https://github.com/exploitz86/TegraExplorer.git")
    add_versions("latest", "master")

    on_install("cross@aarch64", function (package)
        import("lib.detect.find_tool")
        
        -- Set up devkitARM environment
        local devkitarm = os.getenv("DEVKITARM") or "/opt/devkitpro/devkitARM"
        os.setenv("DEVKITARM", devkitarm)
        
        -- Build TegraExplorer
        os.exec("make -C " .. package:source_dir(), {shell = true})
        
        -- Install the binary to package bin directory
        os.mkdir(package:installdir("bin"))
        os.cp(package:source_dir() .. "/output/TegraExplorer.bin", package:installdir("bin"))
    end)

    on_test(function (package)
        os.isfile(package:installdir("bin") .. "/TegraExplorer.bin")
    end)
