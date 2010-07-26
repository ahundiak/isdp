#ifndef ALLOC_PROFILE
#include <malloc.h>
#else
#include "oppmalloc.h"
#endif
/*
#define malloc(A) dbg_malloc(A,__LINE__,__FILE__);
#define free(A) dbg_free(A,__LINE__,__FILE__) 
*/
