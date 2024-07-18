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