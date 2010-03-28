/* -- CI compiler ( PCI )
      Contains the register management functions :
		- mkREG
		- REGreset
*/

#include "cichardef.h"
#include "pcidef.h"
#include "pci.h"
#include "pcimacros.h"
#include "cidef.h"
#include "citypedef.h"
#define DEBUG 0
/*----------------------------------------------------------------------------*/
/* -- Register counters CHaRacter, SHoRt, INTeger, OBJect, DouBLe, STRucture.
      The leading `p' is for pointer registers.
   -- */
static Uchar CHRreg,  SHRreg,  INTreg,  OBJreg,  DBLreg,  STRreg,
            pCHRreg, pSHRreg, pINTreg, pOBJreg, pDBLreg, pSTRreg, pVOIreg ;
/*----------------------------------------------------------------------------*/
void REGreset() {

   CHRreg =  SHRreg =  INTreg =  OBJreg =  DBLreg =  STRreg =
  pCHRreg = pSHRreg = pINTreg = pOBJreg = pDBLreg = pSTRreg = pVOIreg = 0 ;
}
/*----------------------------------------------------------------------------*/
int mkREG( T ) PCItype *T ; {

/* -- Allocates a temporary buffer ( `register' ).
      WARNING: if T is not a basic type or equivalent to a basic type, but is
      a structured or dimensioned variable, a buffer the size of the variable
      will be allocated...
   -- */

  PCIident	n			;
  int		u			;
  char 		*s	, *itoa()	;
  PCIcontext	c			;
  PCItype	*eq			;
  void		TYPeq()			;
  char		*STRname(), *BSCname()	;
  void		CTXdefault()		;

/* -- Get equivalent type.
   -- */
  eq = T ; TYPeq( &eq, (PCItype **) NULL ) ;
  s = n ;
  *s++ = REGVAR ;
  if( eq->Ptr ) {
     *s++ = 'p' ;
     switch( eq->Def ) {
  	case BASIC :
 		switch( eq->Num ) {
 		  case CI_VOID	 : *s++ = 'V' ; u = pVOIreg++ ; break ;
  		  case CI_CHAR	 : *s++ = 'C' ; u = pCHRreg++ ; break ;
  		  case CI_SHORT	 : *s++ = 'S' ; u = pSHRreg++ ; break ;
  		  case CI_INTEGER:
  		  case CI_INT	 : *s++ = 'I' ; u = pINTreg++ ; break ;
  		  case CI_GROBJ	 : *s++ = 'O' ; u = pOBJreg++ ; break ;
  		  case CI_NUMERIC:
  		  case CI_DOUBLE : *s++ = 'D' ; u = pDBLreg++ ; break ;
  		  default	 : cibugchk( "mkREG", "unknown basic type" ) ;
  		                   printf( "TYPE %d *\n", eq->Num ) ;
  		}
  		break ;
	case STRUC :
	case UNION : *s++ = '{' ; u = pSTRreg++ ; break ;
	default	   : cibugchk( "mkREG", "unknown type" ) ;
     }
		
  } else { 
     switch( eq->Def ) {
  	case BASIC :
  		if( eq->Dim ) {
  		  *s++ = '[' ; u = STRreg++ ;
  		  sprintf( s, "%d%s%d", u, BSCname( (int) eq->Num ), eq->Dim ) ;
  		  goto Label ;
  		} else
  		switch( eq->Num ) {
  		  case CI_CHAR	 : *s++ = 'C' ; u = CHRreg++ ; break ;
  		  case CI_SHORT	 : *s++ = 'S' ; u = SHRreg++ ; break ;
		  case CI_INTEGER:
  		  case CI_INT	 : *s++ = 'I' ; u = INTreg++ ; break ;
  		  case CI_GROBJ	 : *s++ = 'O' ; u = OBJreg++ ; break ;
		  case CI_NUMERIC:
  		  case CI_DOUBLE : *s++ = 'D' ; u = DBLreg++ ; break ;
  		  default	 : cibugchk( "mkREG", "unknown basic type" ) ;
  		                   printf( "TYPE %d\n", eq->Num ) ;
  		}
  		break ;
	case STRUC :
	case UNION : *s++ = '{' ; u = STRreg++ ;
/* --		     Including the struct's number in the name will allow to
		     separate the untagged structures.
   -- */
		 sprintf( s, "%s%d.%d", STRname( (int) eq->Num ), eq->Num, u ) ;
  		 goto Label ;
	default	   : cibugchk( "mkREG", "unknown type" ) ;
	}
  }
  itoa( s, u ) ;
  Label:
	CTXdefault( T, &c ) ;

  return MKdcl( &c, n ) ;

} /* mkREG */
/*----------------------------------------------------------------------------*/
