#ifndef _ALLOCA_H_ 
#define _ALLOCA_H_ 1

//  File <alloca.h> is not available in NT

#ifdef NT
#define alloca _alloca
#include <malloc.h>
#endif // NT

#endif // _ALLOCA_H_
