#include "stdafx.h"

struct iq_thing {
	int count;
};
dllg gml_ptr<iq_thing> iq_thing_create(int count) {
	auto thing = new iq_thing();
	thing->count = count;
	return thing;
}
dllg void iq_thing_destroy(gml_ptr_destroy<iq_thing> thing) {
	delete thing;
}
dllg int iq_thing_get_count(gml_ptr<iq_thing> thing) {
	return thing->count;
}
dllg void iq_thing_set_count(gml_ptr<iq_thing> thing, int count) {
	thing->count = count;
}
