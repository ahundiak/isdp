#ifndef MEMORY_H
#define MEMORY_H

#define MALLOC(x) (x *)malloc( sizeof(x) )
#define MALLOCn(x,n) (x *)malloc( sizeof(x) * n )

#endif
