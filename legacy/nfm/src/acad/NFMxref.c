#include "machine.h"
#ifdef SUFF
#define SUFFIX [4]
#define SUBN [adct.dwgno]
#else
#define SUFFIX
#define SUBN
#endif

#define PROTOTYPES

#ifdef PROTOTYPES
#define _(a) a
#else
#define _(a) ()
#endif

#define MALLOC_INCR	10

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <malloc.h>
#include "autodir.h"
#include "adrproto.h"
#include "xref.h"
#include "NFMerrordef.h"
#include "ERR.h"
#include "DEBUG.h"

#define ACAD25 0  /* ac1002 */
#define ACAD26 1  /* ac1003 */
#define ACAD9  2  /* ac1004 */
#define ACAD10 3  /* ac1006 */
#define ACAD11 4  /* ac1009 */
#define NFM_E_INVALID_AUTOCAD 11 /* temporary */

short returnval;

long AddXref(long *num_xrefs, struct xref_st **xrefs );

long GetXrefs( infile, num_xrefs, xrefs )
char infile[];
long	*num_xrefs;
struct  xref_st	**xrefs;

{
  short i;
  char *fname="GetXrefs";


  *num_xrefs = 0;
  *xrefs = malloc ( sizeof ( struct xref_st ) * MALLOC_INCR );
  if ( ! *xrefs )
  {
        _NFMdebug ((fname, "Failed to malloc\n"));
        ERRload_struct (NFM, NFM_E_MALLOC, "%d", 
                        sizeof ( struct xref_st ) * MALLOC_INCR );
        return (NFM_E_MALLOC);
  }
   
  if (!initializeread(infile,4096,4096,4096)) {      /* initialize input */
    _NFMdebug ((fname, "failed to open the file %s\n",infile));
    ERRload_struct (NFM, NFM_E_OPEN_FILENAME, "%s", infile);
    return (NFM_E_OPEN_FILENAME);
  }

/* read header */
  if (!readheader()) {                               /* read header info */
    terminateread();

    _NFMdebug ((fname, "Not a valid AUTOCAD file [%s]\n", infile));
    ERRload_struct (NFM, NFM_E_INVALID_AUTOCAD, "%s", infile);
    return (NFM_E_INVALID_AUTOCAD);
  }

  startblockheaderread();


  for (i=0; i<(short)adct.numblocksr SUBN; i++) {
    readblockheader();   /* gives block name, which we need */
    /* if either not purged, or purged but the definition is still present */
    if (!adtb.blkh.purgedflag || adtb.blkh.defpresent) {
      startblockdefread();
      do {                          /* read block def ent, then rest of block */
        returnval=readentity1();    /* read next entity */

        if (returnval) {
          if (adenhd.xddatapresent) {
            startextendeddataread();
            while (readextendeddata()) {
            }
          }
          readentity2();
          if (!adenhd.erasedflag &&          /* if this entity is not erased */
              !adtb.blkh.purgedflag)            /* and the block has not been purged */
	  {
            AddXref( num_xrefs, xrefs );
	  }
        }
      }
      while (adenhd.enttype!=13);
      endblockdefread();
    }
  }
  terminateread();

  return ( 0 );
}

long AddXref( num_xrefs, xrefs )  
long	*num_xrefs;
struct	xref_st	**xrefs;
{
  char	buf[FILE_LEN+20];

  if (adenhd.enttype == 7 &&	 /* text */
      ! strncmp ( aden.text.textstr, "Xref", 4 ) )
  {
    if ( *num_xrefs > 0 && ( *num_xrefs % MALLOC_INCR ) == 0 )
    {
	*xrefs = realloc ( *xrefs, 
		sizeof(struct xref_st) * (*num_xrefs + MALLOC_INCR) );
	if ( ! *xrefs )
	{
		printf ( "realloc error\n" );
		return ( 4 );
	}
    }
    sprintf ( buf, "%s.dwg", aden.text.textstr + 4 );
/*
printf ( "buf = !%s!\n", buf );
fflush ( stdout );
*/
/* Remove leading blanks */
    while ( buf[0] == ' ' )
        strcpy ( buf, buf+1 );

    strcpy ( (*xrefs)[*num_xrefs].name, buf );
/*
printf ( "name  = !%s!\n",(*xrefs)[*num_xrefs].name  );
fflush ( stdout );
*/
    ++(*num_xrefs);
  } /* end of switch */
  return ( 0 );
}


