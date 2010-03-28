#ifndef dmgraph_include

#define dmgraph_include

#define ROOT			0x0001
#define CHILDREN		0x0002

#define IMMEDIATE_ONLY		0x0100
#define COMPONENTS_ONLY		0x0200
#define DIMENSIONS_ONLY		0x0400

#define REMWRNG			0x0001
#define ERASE			0x0002
#define ADDWRNG			0x0004
#define DISPLAY			0x0008

#define GET_MODE		1
#define SET_MODE		2

#define BOTTOM_UP		0
#define TOP_DOWN		1

#define DIMS_IN_CUROS		0
#define DIMS_IN_REFOS		1

#define PASS_BY_OSNUM		0
#define PASS_TO_CUROS		1
#define PASS_TO_REFOS		2
#define PASS_TO_ALLOS		3

#endif
