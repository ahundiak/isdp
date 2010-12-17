#include <stdio.h>
#include <ctype.h>
#include "util.h"

#ifdef __STDC__
#ifdef SYSV
int	file_read  (char *ptr, size_t size, int nitems, FILE *fp);
#else
int	file_read  (char *ptr, int    size, int nitems, FILE *fp);
#endif

#else
int	file_read  ();
#endif


/****************************************************************************/
unsigned char *read_symfile (name)
char *name;
{
    FILE *ifp;
    unsigned long magicnum, tablesize;
    unsigned char *ibuf;
    
    /* open input file */
    if ((ifp=fopen(name, "r")) == NULL) {
	fprintf(stderr,"Unable to open EV symbol file \"%s\"\n", name);
	return NULL;
	}

    /* check for magic number in first 4 bytes - abort if not found */
    if (!file_read ((char *)&magicnum, 4, 1, ifp)) {
	fprintf (stderr, "Bad input file \"%s\"\n", name);
	fclose (ifp);
	return NULL;
	}
#ifdef BIG_ENDIAN
    magicnum = swap_ulong (magicnum);
#endif
    if (magicnum != MAGIC_NUMBER) {
	fprintf(stderr,"File %s is NOT an Environ V symbol file - aborting\n", name);
	fclose (ifp);
	return NULL;
	}
    
    /* obtain data file size and read rest of EV symbol file into ibuf */
    if (!file_read ((char *)&tablesize, 4, 1, ifp)) {
	fprintf (stderr, "Bad input file \"%s\"\n", name);
	fclose (ifp);
	return NULL;
	}
#ifdef BIG_ENDIAN
    tablesize = swap_ulong (tablesize);
#endif
    ibuf = (unsigned char *) malloc(tablesize);	
#ifdef SYSV
    if (!file_read ((char *)ibuf, (size_t)tablesize, 1, ifp))
#else
    if (!file_read ((char *)ibuf, tablesize, 1, ifp))
#endif
	{
	fprintf (stderr, "Bad input file \"%s\"\n", name);
	fclose (ifp);
	return NULL;
	}

    /* everything went well */
    fclose (ifp);
    return ibuf;

} /* read_symfile */


/****************************************************************************/
file_read (ptr, size, nitems, fp)
char *ptr;
#ifdef SYSV
size_t size;
#else
int size;
#endif
int nitems;
FILE *fp;
{
    if (fread(ptr,size,nitems,fp) != nitems) {
	fprintf(stderr, "Early EOF in source font file\n");
	return 0;
	}
    return 1;

} /* file_read */


/****************************************************************************/
unsigned long get_ulong (buf)
unsigned char *buf;
{
    unsigned long result = 0;
    unsigned long base = 1;
    int i;
    
    for (i=0; i<4; i++)
	{
	result += base * buf[i];
	base *= 256;
	}

    return result;

} /* get_ulong */


/****************************************************************************/
unsigned short  get_ushort (buf)
unsigned char *buf;
{
    unsigned short result;
    unsigned char lobyte, hibyte;

    lobyte = buf[0];
    hibyte = buf[1];

    result = (hibyte * 256) + lobyte;

    return result;

} /* get_ushort */


/****************************************************************************/
void flipbyte (bptr)
unsigned char *bptr;
{
    unsigned char inbyte  = *bptr;
    unsigned char outbyte = 0x00;
    unsigned int i;

    for (i=0; i<4; i++)	outbyte |= ((unsigned)(inbyte & (1L<<i)) << (7-2*i));
    for (i=4; i<8; i++) outbyte |= ((unsigned)(inbyte & (1L<<i)) >> (2*i-7));

    *bptr = outbyte;

} /* flipbyte */


/****************************************************************************/
void maskbyte (bptr, bits_wide)
unsigned char *bptr;
int bits_wide;
{
    unsigned char inbyte = *bptr;
    unsigned char outbyte;
    unsigned char mask = 0x00;
    int goodbits;

    if ((goodbits=bits_wide%8) == 0) goodbits = 8;

    switch (goodbits) {
	case 1: mask = 0x80; break;
	case 2: mask = 0xc0; break;
	case 3: mask = 0xe0; break;
	case 4: mask = 0xf0; break;
	case 5: mask = 0xf8; break;
	case 6: mask = 0xfc; break;
	case 7: mask = 0xfe; break;
	case 8: mask = 0xff; break;
	}
    outbyte = inbyte & mask;

    *bptr = outbyte;

} /* maskbyte */


#ifdef BIG_ENDIAN
/****************************************************************************/
unsigned long swap_ulong (ldata)
unsigned long ldata;
{
    unsigned long sdata;

    sdata  = ((ldata & 0x000000ffL) << 24);
    sdata |= ((ldata & 0x0000ff00L) <<  8);
    sdata |= ((ldata & 0x00ff0000L) >>  8);
    sdata |= ((ldata & 0xff000000L) >> 24);

    return sdata;

} /* swap_long */
#endif
