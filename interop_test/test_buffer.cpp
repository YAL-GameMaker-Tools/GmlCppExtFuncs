#include "stdafx.h"

dllg int iq_get_buffer_sum(gml_buffer buf) {
	int sum = 0;
	int till = buf.tell();
	auto data = buf.data();
	for (int i = 0; i < till; i++) {
		sum += data[i];
	}
	return sum;
}

dllg int iq_get_buffer_rest(gml_buffer buf, int start = -1) {
	if (start < 0) start = buf.tell();
	return buf.size() - start;
}