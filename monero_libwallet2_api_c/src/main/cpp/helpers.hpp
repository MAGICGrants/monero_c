#include <vector>
#include <string>
#include <set>
#include <sstream>
#include <cstdlib>
#include <iostream>

// Debug macros
#define DEBUG_START()                                                             \
    try {

#define DEBUG_END()                                                               \
    } catch (const std::exception &e) {                                           \
        std::cerr << "Exception caught in function: " << __FUNCTION__             \
                  << " at " << __FILE__ << ":" << __LINE__ << std::endl           \
                  << "Message: " << e.what() << std::endl;                        \
        std::abort();                                                                    \
    } catch (...) {                                                               \
        std::cerr << "Unknown exception caught in function: " << __FUNCTION__     \
                  << " at " << __FILE__ << ":" << __LINE__ << std::endl;          \
        std::abort();                                                                    \
    }


const char* vectorToString(const std::vector<std::string>& vec, const std::string separator);
const char* vectorToString(const std::vector<uint32_t>& vec, const std::string separator);
const char* vectorToString(const std::vector<uint64_t>& vec, const std::string separator);
const char* vectorToString(const std::vector<std::set<uint32_t>>& vec, const std::string separator);
const char* vectorToString(const std::set<uint32_t>& intSet, const std::string separator);
std::set<std::string> splitString(const std::string& str, const std::string& delim);
std::vector<uint64_t> splitStringUint(const std::string& str, const std::string& delim);
std::vector<std::string> splitStringVector(const std::string& str, const std::string& delim);

// Overwrites [s], then empties it: std::string never clears the memory it
// frees, so a secret left in one stays in the heap after it is gone.
void wipeString(std::string& s);

// A secret crossing the C API (a wallet password, a seed, a spend key), as
// the std::string the wallet API takes. Wiped when it goes out of scope.
class Secret {
public:
    explicit Secret(const char* s) : value(s ? s : "") {}
    explicit Secret(std::string s) : value(std::move(s)) {}
    ~Secret() { wipeString(value); }
    Secret(const Secret&) = delete;
    Secret& operator=(const Secret&) = delete;
    std::string value;
};

// [s] in a new buffer for the caller, who wipes it before MONERO_free; [s]
// itself is wiped when it goes out of scope.
const char* secretToBuffer(const Secret& s);
