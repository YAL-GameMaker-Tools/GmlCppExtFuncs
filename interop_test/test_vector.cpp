#include "stdafx.h"

dllg std::vector<int64_t> iq_get_vec() {
	std::vector<int64_t> vec{};
	for (int i = 1; i <= 3; i++) vec.push_back(i);
	return vec;
}

dllg std::optional<std::vector<int64_t>> iq_get_opt_vec(bool ret) {
	std::vector<int64_t> vec{};
	for (int i = 1; i <= 3; i++) vec.push_back(i);
	if (!ret) return {};
	return vec;
}

dllg int64_t iq_get_int64_vec_sum(std::vector<int64_t> arr) {
	int64_t sum = 0;
	for each (auto val in arr) {
		sum += val;
	}
	return sum;
}

dllg int iq_get_length_of_strings(std::vector<const char*> strings) {
	int sum = 0;
	for each (auto str in strings) {
		sum += (int)strlen(str);
	}
	return sum;
}