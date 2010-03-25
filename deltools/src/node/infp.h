#define	IMAX(a,b)	(((a) > (b)) ? (a) : (b))
#define	IMIN(a,b)	(((a) < (b)) ? (a) : (b))

#define MAXLINE	500

typedef struct
{
    char *number;
    int size;
    int maxSize;
    int negative;
} infp;

