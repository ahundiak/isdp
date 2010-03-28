/*-INCLUDES-------------------------------------------------------------------*/
#include "pci.h"
#include "pcidef.h"
#include "pcimacros.h"
#include "ciy.h"
#include "cichardef.h"
#include "cidef.h"
#include "citypedef.h"
#include <malloc.h>
#define DEBUG 0
/* -- Shorter names.
   -- */
#define	C	CI_CHAR
#define	D	CI_DOUBLE
#define F	CI_FLOAT
#define G	CI_GROBJ
#define I	CI_INT
#define	J	CI_INTEGER
#define L	CI_LONG
#define N	CI_NUMERIC
#define S	CI_SHORT
#define U	CI_UNSIGNED
#define V	CI_VOID
#define E	EMPTY
/*-EXTERNALS------------------------------------------------------------------*/
extern PCItype	TYPbasic() ;
extern	void	TYPeq()	;
/*----------------------------------------------------------------------------*/
int BSCreduce( t1, t2, t3, reduced )	PCItype *t1, *t2, *t3, *reduced ; {

/* -- Reduces basic types with qualifiers ( unsigned, long, short ) to one type.
      Note: unsigned char, unsigned short, unsigned int, and float are for the
      moment respectively converted to char, short, int and int.
   -- */

/* -- Conversion array.
   -- */
	static char convert[][4] = {
/*	{	type1,	type2,	type3,	equivalent }			*/
/*	Equivalent of circular combinations of unsigned, long and int	*/
	{	U,	L,	I,	I	},
	{	U,	I,	L,	I	},
	{	L,	U,	I,	I	},
	{	L,	I,	U,	I	},
	{	I,	L,	U,	I	},
	{	I,	U,	L,	I	},
/*	Equivalent of circular combinations of unsigned, short and int	*/
	{	U,	S,	I,	S	},
	{	U,	I,	S,	S	},
	{	S,	U,	I,	S	},
	{	S,	I,	U,	S	},
	{	I,	S,	U,	S	},
	{	I,	U,	S,	S	},
/*	Equivalent of circular combinations of unsigned and int		*/
	{	U,	I,	E,	I	},
	{	I,	U,	E,	I	},
/*	Equivalent of circular combinations of unsigned and long	*/
	{	U,	L,	E,	I	},
	{	L,	U,	E,	I	},
/*	Equivalent of circular combinations of unsigned and short	*/
	{	U,	S,	E,	S	},
	{	S,	U,	E,	S	},
/*	Equivalent of circular combinations of unsigned and char	*/
	{	U,	C,	E,	C	},
	{	C,	U,	E,	C	},
/*	Equivalent of circular combinations of long and int		*/
	{	L,	I,	E,	I	},
	{	I,	L,	E,	I	},
/*	Equivalent of circular combinations of short and int		*/
	{	S,	I,	E,	S	},
	{	I,	S,	E,	S	},
/*	Equivalent of circular combinations of float and long		*/
	{	F,	L,	E,	D	},
	{	L,	F,	E,	D	},
/*	Equivalent of char 						*/
	{	C,	E,	E,	C	},
/*	Equivalent of short 						*/
	{	S,	E,	E,	S	},
/*	Equivalent of int 						*/
	{	I,	E,	E,	I	},
/*	Equivalent of integer 						*/
	{	J,	E,	E,	J	},
/*	Equivalent of numeric 						*/
	{	N,	E,	E,	N	},
/*	Equivalent of double 						*/
	{	D,	E,	E,	D	},
/*	Equivalent of GRobj 						*/
	{	G,	E,	E,	G	},
/*	Equivalent of unsigned 						*/
	{	U,	E,	E,	I	},
/*	Equivalent of long						*/
	{	L,	E,	E,	I	},
/*	Equivalent of float						*/
	{	F,	E,	E,	I	},
/*	Equivalent of void						*/
	{	V,	E,	E,	V	},
/*	End of list							*/
	{	E,	E,	E,	E	}
} ;
	
	char	comb[3] 	; /* Input combination */
	char	*p, found	;
	int	rc, i		;
	PCItype *typ[3], *eq, *pTYPbasic()	;

	typ[0] = t1 ; typ[1] = t2 ; typ[2] = t3 ;

/* --	Types this far are only basic or typedefs.
   -- */
	for( i = 0 ; i < 3 ; i++ ) {
		if( typ[i] != NULL ) {
			if( typ[i]->Def == TYPDF ) {
				eq = typ[i] ;
				TYPeq( &eq, (PCItype **) NULL ) ;
				if(    eq->Def == BASIC
				    && TYPcompare (*eq, TYPbasic( (int) eq->Num ) ) ) {
					comb[i] = eq->Num ;
				} else goto ERROR ;
			} else {
				comb[i] = typ[i]->Num ;
			}
		} else comb[i] = E ;
	}
/* RM
	comb[0] = t1 != NULL ? t1->Num : E ;
	comb[1] = t2 != NULL ? t2->Num : E ;
	comb[2] = t3 != NULL ? t3->Num : E ;
end RM */
	found = E ;

	i = 0 ;
	while( *( p = convert[i] ) != E ) {
		if(	comb[0] == p[0]
		    &&	comb[1] == p[1]
		    &&	comb[2] == p[2] ) {
			found = p[3]	;
			break		;
		}
		i++ ;
	}

	if( found == E ) {
		ERROR :
		rc = ERRsyn( "incompatible type-specifiers", NULL ) ;
	} else {
		rc = TRUE ; eq = NULL ;
		for( i = 0 ; i < 3 ; i++ ) {
			if( typ[i] != NULL && typ[i]->Def == TYPDF ) {
				eq = typ[i]	;
				break		;
			}
		}
		if( eq != NULL )	*reduced = *eq ;
		else			*reduced = TYPbasic( (int) found ) ;
	}

	return rc ;
} /* BSCreduce */
/*----------------------------------------------------------------------------*/
int BSCsizeof( ib )	int ib ; {

int s = 0 ;

   switch( ib ) {
   	case CI_VOID   : s = 0;			    break ;
     	case CI_CHAR   : s = sizeof( char	) ; break ;
     	case CI_SHORT  : s = sizeof( short	) ; break ;
     	case CI_INTEGER:
     	case CI_INT    : s = sizeof( int 	) ; break ;
	case CI_NUMERIC:
     	case CI_DOUBLE : s = sizeof( double	) ; break ;
     	case CI_GROBJ  : s = sizeof( OM_S_OBJID	) ; break ;

/* -- Catch Def = BASIC, Num = CI_STRUCT ( this is the type borne by formal
      arguments of system lib functions when they are structs )
   -- */
     	case CI_STRUCT : s = -1			  ; break ;
     	default	       : cibugchk( "BSCsizeof", "unknown basic type" ) ;
     			printf( "TYPE %d\n", ib ) ;
   }
#if DEBUG
  printf( "BSCsizeof : size = %d\n", s ) ;
#endif
   return s ;

} /* BSCsizeof */
/*----------------------------------------------------------------------------*/
#define  TYPalign(typ)  (sizeof (struct { char a; typ b; }) - sizeof (typ))

int BSCalign( ib )	int ib ; {

int s = 0 ;

   switch( ib ) {
   	case CI_VOID   : s = 1;				    break ;
     	case CI_CHAR   : s = TYPalign( char		) ; break ;
     	case CI_SHORT  : s = TYPalign( short		) ; break ;
     	case CI_INTEGER:
     	case CI_INT    : s = TYPalign( int 		) ; break ;
	case CI_NUMERIC:
     	case CI_DOUBLE : s = TYPalign( double		) ; break ;
     	case CI_GROBJ  : s = TYPalign( OM_S_OBJID	) ; break ;

/* -- Catch Def = BASIC, Num = CI_STRUCT ( this is the type borne by formal
      arguments of system lib functions when they are structs )
   -- */
     	case CI_STRUCT : s = -1			  ; break ;
     	default	       : cibugchk( "BSCalign", "unknown basic type" ) ;
     			printf( "TYPE %d\n", ib ) ;
   }
   return s ;

} /* BSCalign */
/*----------------------------------------------------------------------------*/

