// Fixed fs.h: C++17 std::filesystem path alias + std::fstream streams via fsbridge
// Drop-in replacement for src/fs.h to resolve MSVC errors about std::filesystem::ifstream/ofstream.
// No Boost requirement on Windows if <filesystem> is available.

#ifndef VKAX_FS_H
#define VKAX_FS_H

#include <cstddef>
#include <string>
#include <vector>
#include <fstream>

#if __has_include(<filesystem>) && (__cplusplus >= 201703L)
  #include <filesystem>
  namespace fs = std::filesystem;
#else
  #include <boost/filesystem.hpp>
  #include <boost/filesystem/fstream.hpp>
  namespace fs = boost::filesystem;
#endif

// Streams live in std:: namespace for C++17; provide a neutral bridge
// so callers use fsbridge::{ifstream, ofstream}.
namespace fsbridge {
    using ifstream = std::ifstream;
    using ofstream = std::ofstream;
}

#endif // VKAX_FS_H
