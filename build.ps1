# build.ps1
# General purpose build script for CMake based C/C++ projects.
# It should be placed at the root of the project where CMakeLists.txt is located.
Param([string]$clean="true")

# This will be used to reset the working directory after building.
$original_dir = Get-Location

# TODO How to specify project file on Windows since cmake --build does not seem
# TODO to work.
function call-cmake() {
    "--> Calling CMake ...`n"
    if ($isLinux) {
        cmake -G "Unix Makefiles" ..
        cmake --build .
    } else {
        cmake -G "Visual Studio 16 2019" -A x64 ..
        MSBuild.exe learn.vcxproj
    }
}

# Lets start.
Clear-Host

# In an unlikely event.
if (!(Test-Path ./CMakeLists.txt)) {
    "`n--> No CMakeLists.txt file found."
    "--> Build terminated."
    Exit
}

# Starting from scratch
if (!(Test-Path ./build)) {
    "--> Creating build directory ..."

    # The '> $null' silence the verbosity.
    New-Item -ItemType Directory ./build > $null

    Set-Location ./build
    call-cmake

} elseif ((Test-Path ./build) -And ($clean -eq "true")) {
    "--> Cleaning build directory ..."
    Remove-Item -Recurse -Force ./build

    "--> Create new build directory ..."
    New-Item -ItemType Directory ./build > $null

    Set-Location ./build
    call-cmake

} else {
    # We have previous build directory.
    # Just run Make.
    Set-Location ./build
    "--> Calling CMake ...`n"

    if ($IsLinux) {
        cmake --build .
    } elseif ($IsWindows) {
        MSBuild.exe learn.vcxproj
    }
}

# Run the built binary.
"`n--> done building, calling the built binary ...`n"
if ($IsWindows) {
    Debug/learn.exe
} else {
    ./learn
}

# We are done.
# Reseting the working directory back where we started.
"`n"
Set-Location $original_dir
