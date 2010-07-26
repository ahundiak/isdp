/* -- This module handles the C external function.
   -- XFN = eXternal FunctioN
   -- */
/*-INCLUDES-------------------------------------------------------------------*/
#include "pci.h"
#include "pcidef.h"
#include "pcimacros.h"
#include "cichardef.h"
#include "cidef.h"
#include "citypedef.h"
#include <stdio.h>
#include <search.h>
#include <string.h>
#include <malloc.h>
#define DEBUG 0
/*----------------------------------------------------------------------------*/
int XFNcall( call )	PCIlist *call ; {

/* -- Special call for external functions: variable sizes and alignments must
      be included in the parameter list.
   -- */

  int		a	, rc = TRUE	;
  emsg		tmp			;
  short		*e	, *list 	;
  unsigned	newsz	, oldsz		;
  PCItype	*pT			;
  unsigned	TYPsizeof(), TYPalign() ;
  void		TYPeq()			;

#if DEBUG
  printf( "XFNcall : ENTER\n" ) ;
#endif
  oldsz = call->num ;
  for( a = 1 , e = call->elt.Auto ; a < oldsz ; a++ )
    if( isfunction( e[a] ) && !isextern( e[a] ) ) {
       sprintf( tmp, "%.*s(%d)", MAXEMSG - 6, PCIvar( e[0] ), e[a] ) ;
       return ERRsyn( "CI functions cannot be args of extern functions", tmp ) ;
    }
/* -- Old format : func, arg1, ... argn
   -- New format : func, arg1, al1, size1 ... argn, aln, sizen
   -- NOTE: the register for the returned value and the source line number are
   --       appended later.
   -- */

/* -- 2 : 1 ( function name at index 0 ) + 1 ( index of returned value )
   -- */
 if( ( newsz = ( oldsz - 1 ) * 3 + 2 ) > MAXELTS )
   	rc = ERRsyn( "too many args for extern function", NULL ) ;
 else if( MALLOC( list, newsz, short ) != NULL ) {
   for( a = 1, e = list + 1 ; a < oldsz ; a++ ) {
   	pT = pPCIdef( call->elt.Auto[a] )			;
#if DEBUG
printf( "XFNcall: <%s> a=%u s=%u\n", PCIvar( call->elt.Auto[a] ),
	TYPalign(  pT ), TYPsizeof( pT ) ) ;
#endif
   	*e++ = call->elt.Auto[a]				;
   	TYPeq( &pT, (PCItype **) NULL )				;
   	*e++ = pT->Dim ? sizeof( void * ) : TYPalign(  pT )	;
   	*e++ = pT->Dim ? sizeof( void * ) : TYPsizeof( pT )	;
    }
    *list = *call->elt.Auto ;

    free( (char *) call->elt.Auto )	;
    call->elt.Auto	= list		;
    call->num		= newsz	- 1	;
 } else rc = ERRmem( "extern function call" ) ;

#if DEBUG
  printf( "XFNcall : EXIT( %d )\n", rc ) ;
#endif
  return rc ;

} /* XFNcall */
/*----------------------------------------------------------------------------*/
