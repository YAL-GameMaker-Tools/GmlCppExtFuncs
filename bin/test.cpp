
struct Test {
	int a0;
	int a1[2];
	int a2[3][2];
}

struct Inner {
	int a;
}
struct Outer {
	Inner a;
	int b;
}

dllw Test getTest(Test q) {
	Test t;
	t.a = q.a + 1;
	t.b = 1;
	return t;
}

dllw void testLayered(Outer a) {
	
}

/*
dllw void no_ret(int64 i, int k) {
	
}

dllw int int64_to_int(int64 i) {
	return (int)i;
}

dllw int64 int64_to_int64(int64 i) {
	return i;
}

dllw int64 test(int64 i) {
	return i + 1;
}

dllw int64 test2(int64 i, int64 k = 0) {
	return i + k;
}

dllw int64 test2(int64 i, int64 k = 0, int64 j = 1) {
	return i + k;
}

dllw Test getTest() {
	Test t;
	t.a = 4;
	t.b = "hi!";
	return t;
}