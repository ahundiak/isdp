
/* make sure __sparc__ and __clipper__ are defined */
#ifdef sparc
#ifndef __sparc__
#define __sparc__
#endif
#endif
#ifdef clipper
#ifndef __clipper__
#define __clipper__
#endif
#endif


/* define hardware dependencies */
#ifdef __sparc__
#define BIG_ENDIAN
#endif


/* try to determine operating system from hardware */
#ifdef __clipper__
#define SYSV
#endif
#ifdef __sparc__
#define BSD
#endif


#define FALSE	0
#define TRUE	1


/* number to idenify Environ V fonts */
#define MAGIC_NUMBER 0x544E4F46

/* maximum charaters found in EV font file */
#define MAX_CHARS 255

#define MAX(i1,i2) ((i1 > i2) ? i1 : i2)
#define MIN(i1,i2) ((i1 < i2) ? i1 : i2)


/* function prototypes */

#ifdef __STDC__
unsigned char	*read_symfile	(char *name);
unsigned long	get_ulong	(unsigned char *buf);
unsigned short	get_ushort	(unsigned char *buf);
void		flipbyte	(unsigned char *bptr);
void		maskbyte	(unsigned char *bptr, int bits_wide);
#ifdef BIG_ENDIAN
    unsigned long	swap_ulong	(unsigned long ldata);
#endif
char *         strdup		(char *s); /* Why isn't this in string.h? */

#else
unsigned char	*read_symfile	();
unsigned long	get_ulong	();
unsigned short	get_ushort	();
void		flipbyte	();
void		maskbyte	();
#ifdef BIG_ENDIAN
    unsigned long	swap_ulong	();
#endif
#endif
