/* -- This module handles the labels.
      See label types in "pcidef.h"
   -- */
#include "pci.h"
#include "pcidef.h"
#include "pcimacros.h"
#include "cidef.h"
#include "citypedef.h"
#include "cichardef.h"
#include <string.h>
#include <malloc.h>
#define DEBUG 0
/*----------------------------------------------------------------------------*/
/* -- NOTE: the index of the function where the user label (US_LAB) appears is
	    put with leading zeros in the four first characters of the label's
	    name.
	    E.g. "mylab" in function at index 12 will bear the name:
				0012mylab
   -- */
typedef struct {
		char 	*Nam 	;	/* Name of label		    */
		int   	Num	;	/* Number of label		    */
		Uchar	Typ	;	/* Type of label		    */
} label ;
static label		**lab__list	= NULL	;
static Ushort	lab__unik	= 0,
		lab__size	= 0	;
#define FCNINDEXLEN	4

/*
 *  ANSI static prototype
 */
#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif
#if defined(__cplusplus)
extern "C" {
#endif

static int LABenter __((PCIident lab, int typ, int fcn, int il));
static int LABfind __((PCIident lab, int typ, int fcn));
static int LABalloc __((label **L, unsigned l));

#if defined(__cplusplus)
}
#endif
#undef __


/*----------------------------------------------------------------------------*/
static int LABenter( lab, typ, fcn, il )	PCIident	lab	;
						int		fcn	;
						int		typ	;
						int		il	; {

	PCIident tmp ;

  if( typ == US_LAB ) {
 	sprintf( tmp, "%0*d%s", FCNINDEXLEN, fcn, lab ) ;
  	return STBenter( strcpy( lab__list[il]->Nam, tmp ), il, SYM_LABL_NAM ) ;
  } else {
  	return STBenter( strcpy( lab__list[il]->Nam, lab ), il, SYM_LABL_NAM ) ;
  }
} /* LABenter */
/*----------------------------------------------------------------------------*/
static int LABfind( lab, typ, fcn )	PCIident lab ; int typ, fcn ; {

/* -- Retrieves a label in the hash table.
      INPUT   : lab, label name.
      RETURNS : label index if found else EMPTY.
   -- */
		PCIident tmp ;

	if( typ == US_LAB ) {
		sprintf( tmp, "%0*d%s", FCNINDEXLEN, fcn, lab ) ;
		return STBfind( tmp , SYM_LABL_NAM ) ;
	} else return STBfind( lab, SYM_LABL_NAM ) ;
  
} /* LABfind */
/*----------------------------------------------------------------------------*/
static int LABalloc( L, l )	label		**L	;
				unsigned	l	; {

				int rc = TRUE ;

  l += 1 + FCNINDEXLEN ;
  if(    MALLOC( *L		, 1, label ) != NULL
      && MALLOC( (*L)->Nam	, l, char  ) != NULL )
      rc =  TRUE ;
  else rc = ERRmem( "label" ) ;

  return rc ;

} /* LABalloc */
/*----------------------------------------------------------------------------*/
void LABfree() {

/* -- Frees the label list. Re-initializes `PCInlab', `lab__unik', `lab__size',
      `lab__list'.
   -- */

			register label **L, **stop ;

  for( L = lab__list, stop = L + PCInlab ; L < stop ; L++ ) {
  	free( (*L)->Nam )	;
  	free( (char *) *L )	;
  }
  FREE( lab__list ) ; lab__list = NULL ; 
  
  PCInlab = lab__unik = lab__size = 0 ;

} /* LABfree */
/*----------------------------------------------------------------------------*/
int mkLAB( lab, typ, pos )	char *lab	;
				int  typ, pos	; {

/* -- Generates a label in the label table.
      INPUT  : lab, label name.
      	       typ, label type
               pos, label number.
      RETURNS: the label index.
      NOTE : nothing is done if the label already exists and pos = EMPTY.
   -- */

				int L_index = EMPTY, i ;

#if DEBUG
  printf( "mkLAB : lab = <%s>, pos = %d typ = %d\n", lab, pos, typ ) ;
#endif
  if( ( i = LABfind( lab, typ, PCIfcn ) ) == EMPTY ) {
  	if( PCInlab >= lab__size ) {
  		lab__size += LABQUANTUM ;
  		if( ALLOC( lab__list, lab__size, label * ) == NULL ) {
  			ERRmem( "label list" ) ;
  			return EMPTY ;
  		}
	}
	i = PCInlab++ ;
	if( LABalloc( &lab__list[i], (unsigned) strlen( lab ) ) ) {
		if( LABenter( lab, typ, PCIfcn, i ) ) {
				lab__list[i]->Num = pos	;
				lab__list[i]->Typ = typ	;
				L_index		 = i   	;
		}
	}
  } else {
	if(    lab__list[i]->Num != EMPTY && pos != EMPTY
	    && lab__list[i]->Typ != FN_LAB ) {
		ERRsyn( "label declared more than once", lab ) ;
	} else {
		if( pos != EMPTY ) {
			lab__list[i]->Num = pos ;
			lab__list[i]->Typ = typ ;
		}
		L_index	= i   ;
	}
  }

#if DEBUG
   printf( "mkLAB : EXIT( %d )\n", L_index ) ;
#endif
  return L_index ;

} /* mkLAB */
/*----------------------------------------------------------------------------*/
int LABresolve() {

  int i, rc ; register struct ci_instruction *I ; register label **L ;

#define PM (I->paramlist)

#if DEBUG
  printf( "LABresolve: ENTER PCInins %d nb labs %d\n", PCInins, PCInlab ) ; fflush( stdout ) ;
#endif
  rc = TRUE ;
  for( i = 0, I = PCIcode ; i < PCInins ; i++, I++ ) {
#if DEBUG
  printf( "LABresolve: instruction %d\n", i ) ; fflush( stdout ) ;
  printf( "LABresolve: itype %d line %d PM[0] %d\n", I->type, PM[I->nbparam], PM[0] ) ; fflush( stdout ) ;
#endif
    switch( I->type ) {
      case BRANCH	:
      case BRANCHSW	:
      case BRANCHFUNC	:
      case DBRANCHCOND	:
      case IBRANCHCOND	:
#if DEBUG
  printf( "LABresolve:  BRANCH(%d) %d <%s>#%d\n",
  	 I->type, PM[0], lab__list[PM[0]]->Nam, lab__list[PM[0]]->Num ) ; fflush( stdout ) ;
#endif
			  if( PM[0] >= PCInlab ) {
  				cibugchk( "LABresolve", "Label index out of range" ) ;
  				return FALSE ;
  			  }
      			  PM[0] = lab__list[PM[0]]->Num ;
			  break ;

      case BREAK	:
/* --     	Look for precedingly created label starting which is a
		WH_END, DO_END, FR_END or SW_END (i.e. the instruction of which
		is posterior to the current one. )
   -- */

#if DEBUG
  printf( "LABresolve: BREAK %d\n", PM[0] ) ; fflush( stdout ) ;
#endif
		L = &lab__list[PM[0] - 1] ;
		while( L >= lab__list ) {
			switch( (*L)->Typ ) {
				case WH_END : case DO_END :
				case FR_END : case SW_END :
					if( (*L)->Num > i ) goto endwhileB ;
			}
			L-- ;
		}
		endwhileB :
#if DEBUG
  printf( "LABresolve: BREAK endwhileB <%s>\n", (*L)->Nam ) ; fflush( stdout ) ;
#endif
            	I->type	= BRANCH;
            	I->nbparam = 1	;
            	if( L == lab__list - 1 ) {
		   rc = ERRsyn( "`break' not inside loop or switch", NULL ) ;
                   PM[0] = PCInins ;
                } else PM[0] = (*L)->Num ;
		break ;

	case CONTINUE	:
#if DEBUG
  printf( "LABresolve: CONTINUE %d <%s>\n", PM[0], lab__list[PM[0]]->Nam ) ; fflush( stdout ) ;
#endif
	    /*  The following is a bit confusing. The way labels are created 
		in "ciy.y" needs to be fully understood. ( DG ) */

		L = &lab__list[PM[0] - 1] ;
            	while( L >= lab__list ) {
            	   if( (*L)->Num > i )
            	   	switch( (*L)->Typ ) {
            	   		case DO_CNT :          goto endwhileC ;
            	   		case FR_END : L += 2 ; goto endwhileC ;
            	   		case WH_END : L--    ; goto endwhileC ;
            	   	}
                   L-- ;
            	}
            	endwhileC :
            	I->type	= BRANCH;
            	I->nbparam = 1	;
            	if( L == lab__list - 1 ) {
                   rc = ERRsyn( "continue statement out of a loop", NULL ) ;
                   PM[0] = 0 ;
            	} else PM[0] = (*L)->Num ;
            	break ;

	default      	: break ;
    } /* switch */

  } /* for */
#if DEBUG
 printf( "LABresolve: EXIT(%d)\n", rc ) ; fflush( stdout ) ;
#endif
  return rc ;

} /* LABresolve */
/*----------------------------------------------------------------------------*/
int LABcheck()	{

/* -- Looks for unresolved labels ( including functions ).
      RETURNS  : TRUE if all labels are OK, else FALSE.
   -- */

		int rc = TRUE ; register label **L, **last ;
#if DEBUG
  printf( "LABcheck: ENTER\n" ) ; fflush( stdout ) ;
#endif
  for( L = lab__list, last = L + PCInlab ; L < last ; L++ )
  	if( (*L)->Num == EMPTY ) {
	    if( (*L)->Typ == FN_LAB )
		rc = ERRsyn( "unimplemented function" , (*L)->Nam ) ;
	    else
	        rc = ERRsyn( "label not defined"      , (*L)->Nam + FCNINDEXLEN ) ;
	}

#if DEBUG
  printf( "LABcheck: EXIT(%d)\n", rc ) ; fflush( stdout ) ;
#endif
  return rc ;

} /* LABcheck */
/*----------------------------------------------------------------------------*/
char *LABname( name )	PCIident name	; {

/* -- Returns a unique label name for internal use.
   -- */

			static PCIident N ; char *itoa() ;

  if( name == NULL ) name = N ;
  itoa( name, (int) lab__unik ) ;
  lab__unik++	;
  return name	;
}
/*----------------------------------------------------------------------------*/
