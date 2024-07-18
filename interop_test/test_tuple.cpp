#include "stdafx.h"

dllg std::tuple<int64_t, int64_t> iq_get_int64_pair() {
	return { 1i64, 2i64 };
}

dllg int64_t iq_int64_pair_sum(std::tuple<int64_t, int64_t> pair) {
	return std::get<0>(pair) + std::get<1>(pair);
}

dllg std::tuple<int64_t, int64_t> iq_int64_pair_swap(std::tuple<int64_t, int64_t> pair) {
	return { std::get<1>(pair), std::get<0>(pair) };
}

dllg std::tuple<int64_t, int64_t> iq_get_int64_pair_vec_sum(std::vector<std::tuple<int64_t, int64_t>> arr) {
	int64_t sum1 = 0, sum2 = 0;
	for each (auto val in arr) {
		sum1 += std::get<0>(val);
		sum2 += std::get<1>(val);
	}
	return { sum1, sum2 };
}

