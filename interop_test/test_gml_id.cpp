#include "stdafx.h"

int _next_id = 0;
dllg gml_id<iq_id> iq_id_create() {
	return ++_next_id;
}
dllg int iq_id_value(gml_id<iq_id> id) {
	return id;
}
dllg void iq_id_destroy(gml_id_destroy<iq_id> id) {
	//
}