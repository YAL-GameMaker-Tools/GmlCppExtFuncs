#pragma once
#include <vector>
#if ((defined(_MSVC_LANG) && _MSVC_LANG >= 201703L) || __cplusplus >= 201703L)
#include <optional>
#endif
#include <stdint.h>
#include <cstring>
#include <tuple>

#define dllg /* tag */
#define dllgm /* tag;mangled */

#if defined(_WINDOWS)
#define dllx extern "C" __declspec(dllexport)
#define dllm __declspec(dllexport)
#elif defined(GNUC)
#define dllx extern "C" __attribute__ ((visibility("default"))) 
#define dllm __attribute__ ((visibility("default"))) 
#else
#define dllx extern "C"
#define dllm /* */
#endif

#ifdef _WINDOWS
#include <windows.h>
/// auto-generates a window_handle() on GML side
typedef HWND GAME_HWND;
#endif

/// auto-generates an asset_get_index("argument_name") on GML side
typedef int gml_asset_index_of;
/// Wraps a C++ pointer for GML.
template <typename T> using gml_ptr = T*;
/// Passes a modified struct back to GML
template <typename T> using gml_inout = T&;
/// Modifies an array of values that GML passed in
template <typename T> using gml_inout_vector = std::vector<T>&;

/// Same as gml_ptr, but replaces the GML-side pointer by a nullptr after passing it to C++
template <typename T> using gml_ptr_destroy = T*;
/// Wraps any ID (or anything that casts to int64, really) for GML.
template <typename T> using gml_id = T;
/// Same as gml_id, but replaces the GML-side ID by a 0 after passing it to C++
template <typename T> using gml_id_destroy = T;

class gml_buffer {
private:
	uint8_t* _data;
	int32_t _size;
	int32_t _tell;
public:
	gml_buffer() : _data(nullptr), _tell(0), _size(0) {}
	gml_buffer(uint8_t* data, int32_t size, int32_t tell) : _data(data), _size(size), _tell(tell) {}

	inline uint8_t* data() { return _data; }
	inline int32_t tell() { return _tell; }
	inline int32_t size() { return _size; }
};

class gml_istream {
	uint8_t* pos;
	uint8_t* start;
public:
	gml_istream(void* origin) : pos((uint8_t*)origin), start((uint8_t*)origin) {}

	template<class T> T read() {
		static_assert(std::is_trivially_copyable_v<T>, "T must be trivially copyable to be read");
		T result{};
		std::memcpy(&result, pos, sizeof(T));
		pos += sizeof(T);
		return result;
	}

	char* read_string() {
		char* r = (char*)pos;
		while (*pos != 0) pos++;
		pos++;
		return r;
	}

	gml_buffer read_gml_buffer() {
		auto _data = (uint8_t*)read<int64_t>();
		auto _size = read<int32_t>();
		auto _tell = read<int32_t>();
		return gml_buffer(_data, _size, _tell);
	}
};

class gml_ostream {
	uint8_t* pos;
	uint8_t* start;
public:
	gml_ostream(void* origin) : pos((uint8_t*)origin), start((uint8_t*)origin) {}

	template<class T> void write(T val) {
		static_assert(std::is_trivially_copyable_v<T>, "T must be trivially copyable to be write");
		memcpy(pos, &val, sizeof(T));
		pos += sizeof(T);
	}

	void write_string(const char* s) {
		for (int i = 0; s[i] != 0; i++) write<char>(s[i]);
		write<char>(0);
	}
};

class gmk_buffer {
	uint8_t* buf = 0;
	int pos = 0;
	int len = 0;
public:
	gmk_buffer() {}
	uint8_t* prepare(int size) {
		if (len < size) {
			auto nb = (uint8_t*)realloc(buf, size);
			if (nb == nullptr) {
				printf("Failed to reallocate %u bytes in gmk_buffer::prepare\n", size);
				fflush(stdout);
				return nullptr;
			}
			len = size;
			buf = nb;
		}
		pos = 0;
		return buf;
	}
	void init() {
		buf = 0;
		pos = 0;
		len = 0;
	}
	void rewind() { pos = 0; }
	inline uint8_t* data() { return buf; }
	//
	template<class T> void write(T val) {
		static_assert(std::is_trivially_copyable_v<T>, "T must be trivially copyable to be write");
		int next = pos + sizeof(T);
		if (next > len) {
			auto nl = len;
			while (nl < next) nl *= 2;
			auto nb = (uint8_t*)realloc(buf, nl);
			if (nb == nullptr) {
				printf("Failed to reallocate %u bytes in gmk_buffer::write", nl);
				fflush(stdout);
				return;
			}
			len = nl;
			buf = nb;
		}
		memcpy(buf + pos, &val, sizeof(T));
		pos = next;
	}
	template<class T> T read() {
		static_assert(std::is_trivially_copyable_v<T>, "T must be trivially copyable to be read");
		int next = pos + sizeof(T);
		T result{};
		if (next > len) return result;
		memcpy(&result, buf + pos, sizeof(T));
		pos = next;
		return result;
	}
};
