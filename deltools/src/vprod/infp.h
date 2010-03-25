#define	MAX(a,b)	(((a) > (b)) ? (a) : (b))
#define	MIN(a,b)	(((a) < (b)) ? (a) : (b))

typedef struct
{
    char *number;
    int size;
    int maxSize;
    int negative;
} infp;

