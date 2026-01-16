package("tegraexplorer")
    set_homepage("https://github.com/exploitz86/TegraExplorer")
    set_description("Payload for Switch exploit RCM mode")
    set_license("MIT")

    add_urls("https://github.com/exploitz86/TegraExplorer/archive/refs/heads/master.tar.gz", {alias = "github"})
    add_versions("master", "0000000000000000000000000000000000000000")

    on_fetch("github", function (package)
        return {repo = "exploitz86/TegraExplorer"}
    end)

    on_install("cross@aarch64", function (package)
        -- Set up devkitARM environment
        local devkitarm = os.getenv("DEVKITARM") or "/opt/devkitpro/devkitARM"
        os.setenv("DEVKITARM", devkitarm)
        
        -- Build TegraExplorer
        os.exec("make", {cwd = package:source_dir()})
        
        -- Install the binary to package bin directory
        os.mkdir(package:installdir("bin"))
        os.cp(path.join(package:source_dir(), "output", "TegraExplorer.bin"), package:installdir("bin"))
    end)

    on_test(function (package)
        os.isfile(package:installdir("bin") .. "/TegraExplorer.bin")
    end)

