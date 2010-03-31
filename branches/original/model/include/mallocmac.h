#ifndef MALLOCMAC
#define MALLOCMAC

#define MALLOC(x)            (x *)malloc( sizeof(x) )
#define MALLOCn(x,n)         (x *)malloc( sizeof(x) * n )
#define MALLOCs(x)    (struct x *)malloc( sizeof(struct x) )
#define MALLOCsn(x,n) (struct x *)malloc( sizeof(struct x) * n )

#define REALLOC(p,x)            (x *)realloc( p, sizeof(x) )
#define REALLOCn(p,x,n)         (x *)realloc( p, sizeof(x) * n )
#define REALLOCs(p,x)    (struct x *)realloc( p, sizeof(struct x) )
#define REALLOCsn(p,x,n) (struct x *)realloc( p, sizeof(struct x) * n )

#endif
