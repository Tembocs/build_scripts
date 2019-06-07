# build.ps1
# General purpose build script for CMake based C/C++ projects.
# It should be placed at the root of the project where CMakeLists.txt is located.
Param([string]$clean="true")

# This will be used to reset the working directory after building.
$original_dir = Get-Location

function call-cmake() {
    "--> Calling CMake ...`n"
    if ($isLinux) {
        cmake -G "Unix Makefiles" ..
    } else {
        cmake -G "Visual Studio 16 2019" -A x64
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
    cmake --build .

} elseif ((Test-Path ./build) -And ($clean -eq "true")) {
    "--> Cleaning build directory ..."
    Remove-Item -Recurse -Force ./build

    "--> Create new build directory ..."
    New-Item -ItemType Directory ./build > $null

    Set-Location ./build
    call-cmake
    cmake --build .

} else {
    # We have previous build directory.
    # Just run Make.
    Set-Location ./build
    "--> Calling CMake ...`n"
    cmake --build .
}

# Run the built binary.
"`n--> done building, calling the built binary ...`n"
./learn

# We are done.
# Reseting the working directory back where we started.
"`n"
Set-Location $original_dir
