#if 0
/* -- This modules handles the  dimensions of the multi-dimensional arrays.
      NOTE: the index of the dimension  sequence list begins at 1, this is
      because this index  will be kept in the `Dim'  field of PCItype  and
      this  field must  be non-zero to  satisfy the "if( Dim )"  condition
      which flags that the the type is that of an array.
   -- */
/*-INCLUDES-------------------------------------------------------------------*/
#include "pci.h"
#include "pcidef.h"
#include "pcimacros.h"
#include "cidef.h"
#include "citypedef.h"
#include <malloc.h>
#include <string.h>
/*-TYPEDEFS-------------------------------------------------------------------*/
/* -- Dimension representation.
   -- dims : array of dimensions
   -- mult : number of dimensions ( multiplicity )
   -- */
typedef struct {
			Ushort *dims ;
			Uchar   mult ;
} Dseq ;
/*-STATIC GLOBALS-------------------------------------------------------------*/
static Dseq	**D$list	= NULL	;
static Ushort	D$size		= 1	;
/*-MACROS---------------------------------------------------------------------*/
/* -- Loop on dimension sequences.
   -- */
#define DIMbegin(d) { register Dseq **__end = ( (d) = D$list ) + D$size ;\
		      d++ ; while( (d) < __end ) {
#define DIMend(d)   (d)++ ; } }
/*----------------------------------------------------------------------------*/
int DIMfind( seq ) PCIlist *seq ; {

/* -- Looks for a dimension sequence.
      RETURNS: the sequence index or EMPTY if not found.
   -- */
   
  register Dseq **D ; register int u ; int D_index = EMPTY ;

  DIMbegin( D )
  	if( ( u = (*D)->mult ) == seq->num ) {
  		while( u-- ) if( (*D)->dims[u] != seq->elt.Auto[u] ) break ;
		if( u == EMPTY ) {
			D_index = D - D$list ;
			break ;
		}
	}
  DIMend( D )
  
  return D_index ;

} /* DIMfind */
/*----------------------------------------------------------------------------*/
int mkDIM( seq ) PCIlist *seq ; {

/* -- Creates a new dimension sequence or return its index if it already exists.
      RETURNS: sequence index or EMPTY if memory problems.
   -- */
   
  register Dseq *d ; register int u ; int D_index ;

  if( ( D_index = DIMfind( seq ) ) == EMPTY ) {
     if(    ALLOC( D$list, D$size + 1, Dseq * )		!= NULL
         && ( d = MALLOC( D$list[D$size], 1, Dseq ) )	!= NULL
         && ( MALLOC( d->dims, seq->num, Ushort ) )	!= NULL ) {
       	  d->mult = seq->num ;
          for( u = d->mult - 1 ; u >= 0 ; u-- ) d->dims[u] = seq->elt.Auto[u] ;
	  D_index = D$size++ ;
     } else ERRmem( "dimensions" ) ;
  }     

  return D_index ;

} /* mkDIM */
/*----------------------------------------------------------------------------*/
void DIMfree() {

/* -- Frees dimension list. Resets globals variables.
   -- */
	register Dseq **D ;
	
	if( D$list != NULL ) {
		DIMbegin( D )
			free( (char *) (*D)->dims	) ;
			free( (char *)  *D		) ;
		DIMend( D )
		free( (char *) D$list )	;
		D$list = NULL		;
		D$size = 1		;
	}
} /* DIMfree */
/*----------------------------------------------------------------------------*/
int DIMall( id ) int id ; {

/* -- Returns the total dimension of the dimension sequence at index `id'.
   -- */

  register int total = 1, u ;

  for( u = D$list[id]->mult - 1 ; u >= 0 ; u-- ) total *= D$list[id]->dims[u] ;

  return total ;

} /* DIMall */
/*----------------------------------------------------------------------------*/

#endif
