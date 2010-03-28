/* -- Handles the `type' problems, viz.
   --	Computation of type size and aligment.
   --	Type matching in operations ( choice of the right instruction )
   --	Type matching in function calls.
   --	Type equivalence in case of typedefs.
   --
   -- Alain FALASSE, ISDC, Paris.
   -- */
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
/*----------------------------------------------------------------------------*/
extern unsigned STRalign() , TDFalign() , BSCalign() ,
		STRsizeof(), UNIsizeof(), TDFsizeof(), BSCsizeof() ;
extern PCItype	*TDFeq() ;

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

static int TYPptrcpt __((PCItype *p1, PCItype *p2));

#if defined(__cplusplus)
}
#endif
#undef __


/*----------------------------------------------------------------------------*/
unsigned TYPalign( t )	PCItype *t ; {

/* -- Computes the alignment of a type. This function returns the same alignment
      as the Green Hills C compiler.
   -- */

				unsigned a ;

#if DEBUG
  printf( "TYPalign : Ptr %d Def %d Num %d\n", t->Ptr, t->Def, t->Num ) ;
#endif

 if( t->Ptr ) a = sizeof( void * ) ;
 else switch( t->Def ) {
 	case BASIC : a = BSCalign( (int) t->Num )  ; break ;
     	case STRUC :
     	case UNION : a = STRalign( (int) t->Num )  ; break ;
     	case ENUMT : a = 4;			   ; break ;
     	case TYPDF : a = TDFalign( (int) t->Num )  ; break ;
     	default    : cibugchk( "TYPalign", "unknown type definition" ) ;
      }
#if DEBUG
  printf( "TYPalign : a = %d\n", a ) ;
#endif
   return a ;

} /* TYPalign */
/*----------------------------------------------------------------------------*/
unsigned TYPsizeof( t )	PCItype *t ; {

/* -- Gives the size of a elementary type or structure, NOT that of an array
      ( multiply by the dimension to get it ! ). Computes sizes as the Green
      Hill C compiler.
   -- */
   
				unsigned s ;

#if DEBUG
  printf( "TYPsizeof : Ptr %d Def %d Num %d\n", t->Ptr, t->Def, t->Num ) ;
#endif

 if( t->Ptr ) s = sizeof( void * ) ;
 else switch( t->Def ) {
 	case BASIC : s = BSCsizeof( (int) t->Num ) ; break ;
 	case STRUC : s = STRsizeof( (int) t->Num ) ; break ;
	case UNION : s = UNIsizeof( (int) t->Num ) ; break ;
     	case ENUMT : s =    sizeof( int )	   ; break ;
     	case TYPDF : s = TDFsizeof( (int) t->Num ) ; break ;
     	default    : cibugchk( "TYPsizeof", "unknown type definition" ) ;
   }

#if DEBUG
  printf( "TYPsizeof : size = %d\n", s ) ;
#endif
   return s ;

} /* TYPsizeof */
/*----------------------------------------------------------------------------*/
int TYPcompare( t1, t2 ) PCItype t1, t2; {
	return( t1.Def == t2.Def		&&
		t1.Rpt == t2.Rpt		&&
		t1.Ptr == t2.Ptr		&&
		t1.Fpt == t2.Fpt		&&
		t1.Dim == t2.Dim		&&
		t1.Num == t2.Num		&&
		t1.Spc == t2.Spc );
}
/*----------------------------------------------------------------------------*/
PCItype TYPbasic( basic ) int basic ; {

/* -- Fills type representation structure for a basic type ( char, short, int,
      GRobj, double ) non-array, non-pointer variable.
   -- */

				static PCItype t ;

  t.Dim = 0 ; t.Rpt = t.Ptr = t.Fpt = FALSE ; t.Def = BASIC ; t.Num = basic ;
  t.Spc = NULL ;
  return t ;

} /* TYPbasic */
/*----------------------------------------------------------------------------*/
PCItype *pTYPbasic( basic ) int basic ; {

/* -- Same as above but returns a pointer to a static buffer instead.
   -- */

				 static PCItype t ;

  t.Dim = 0 ; t.Rpt = t.Ptr = t.Fpt = FALSE ; t.Def = BASIC ; t.Num = basic ;
  t.Spc = NULL ;

	return &t ;

} /* pTYPbasic */
/*----------------------------------------------------------------------------*/
void TYPeq( t1, t2 )	PCItype **t1, **t2 ; {

/* -- Finds types equivalent to type which have been defined with `typedef'. Or
      transforms an enum type into int type.
      UPDATE: t1, t2, address of pointer to types
      	      ( replaced by pointer to static buffers of equivalent types ).
      NOTE : if only one type is needed, t2 can be null.
   -- */

			static PCItype eq1, eq2 ;

  if( (*t1)->Def == TYPDF ) {
    	eq1 = *TDFeq( (int) (*t1)->Num )	;
/* --	A pointer to array is equivalent to "**".
   -- */

  	if( eq1.Dim && (*t1)->Dim ) eq1.Dim = (*t1)->Dim	;
  	else if( !eq1.Dim && (*t1)->Dim ) eq1.Dim = (*t1)->Dim	;
/*  	else {	eq1.Ptr++		;
  		eq1.Dim	= (*t1)->Dim	;
  	}*/
  	eq1.Ptr += (*t1)->Ptr 			;
  	*t1 = &eq1				;
  }
  if( (*t1)->Def == ENUMT ) {
  	(*t1)->Def = BASIC	;
  	(*t1)->Num = CI_INT	;
  }

  if( t2 != NULL ) {
  	if( (*t2)->Def == TYPDF ) {
  		eq2 = *TDFeq( (int) (*t2)->Num )	;
  		if( eq2.Dim && (*t2)->Dim ) eq2.Dim = (*t2)->Dim	;
  		else if( !eq2.Dim && (*t2)->Dim ) eq2.Dim = (*t2)->Dim	;
/*  		else {	eq2.Ptr++		;
  			eq2.Dim = (*t2)->Dim 	;
  		}*/
  		eq2.Ptr += (*t2)->Ptr			;
  		*t2 = &eq2				;
  	}
  	if( (*t2)->Def == ENUMT ) {
  		(*t2)->Def = BASIC	;
  		(*t2)->Num = CI_INT	;
  	}
  }

} /* TYPeq */
/*----------------------------------------------------------------------------*/
int TYPareeq( T1, T2 ) PCItype *T1, *T2 ; {

  			short Num[2] ; int rc ;
#if DEBUG
  printf( "TYPareeq: B4 TYPeq\n" ) ;TYPdump( "T1 = ", T1 ) ; TYPdump( "T2 = ", T2 ) ;
#endif
  TYPeq( &T1, &T2 ) ;
#if DEBUG
  printf( "TYPareeq: AF TYPeq\n" ) ;TYPdump( "T1 = ", T1 ) ; TYPdump( "T2 = ", T2 ) ;
#endif
  Num[0] = T1->Num ; Num[1] = T2->Num ;
  if( T2->Def == BASIC && T1->Def == BASIC ) switch( T2->Num ) {
     case CI_INTEGER : if(    T1->Num >  CI_VOID
     			   && T1->Num <  CI_DOUBLE
		           || T1->Num == CI_INTEGER ) T2->Num = T1->Num ; break ;
     case CI_NUMERIC : if(    T1->Num >  CI_VOID
     			   && T1->Num <= CI_DOUBLE
                           || T1->Num == CI_INTEGER
                           || T1->Num == CI_NUMERIC ) T2->Num = T1->Num ; break ;
  }

  rc = TYPcompare( *T1, *T2 );
  T1->Num = Num[0] ; T2->Num = Num[1] ;
#if DEBUG
  printf( "TYPareeq: EXIT(%d)\n", rc ) ;
#endif
  return rc ;
}
/*----------------------------------------------------------------------------*/
/* -- Operand types/operator to instruction correspondance.
   -- */
typedef enum { II = 0, IX = 1, DX = 2, DD = 3, ERR = 5 } ARIOP ;

  static int   OPtoINS[][4] = {
  	    /*    II              IX              DX              DD         */
/* _PLUS   */ {   IADDI		, IADD	 	, DADD	 	, DADDD     },
/* _MINUS  */ {   IMINI		, IMIN		, DMIN		, DMIND	    },
/* _MUL    */ {   IMULI		, IMUL		, DMUL		, DMULD     },
/* _DIV    */ {   IDIVI		, IDIV 		, DDIV 		, DDIVD     },
/* _ASSIGN */ {   IASSIGNTI	, ASSIGNT	, ASSIGNT	, DASSIGNTD },
/* _EQUAL  */ {   IEQ		, EQ		, EQ		, DEQ       },
/* _DIFF   */ {   INE		, NE		, NE		, DNE       },
/* _STRSUP */ {   IGT		, GT		, GT		, DGT       },
/* _SUPEQU */ {   IGE		, GE		, GE		, DGE       },
/* _STRINF */ {   ILT		, LT		, LT		, DLT       },
/* _INFEQU */ {   ILE		, LE		, LE		, DLE       },
/* _NEGBOOL*/ {   INEGBOOL	, NEGBOOL	, NEGBOOL	, NEGBOOL   },
/* _ANDAND */ {   IAND		, AND		, AND		, AND       },
/* _OROR   */ {   IOR		, OR		, OR		, OR        },
/* _XOR    */ {   BITEOR	, BITEOR	, EMPTY 	, EMPTY     },
/* _MOD    */ {   IMODI		, IMOD		, EMPTY 	, EMPTY     }
} ;
/*----------------------------------------------------------------------------*/
int TYPari( t1, o, t2, tr )

PCItype *t1, *t2, *tr	;
PCIop   *o		;

/* -- Chooses the right arithmetical operation according to operand types.
      INPUT  : t1, t2, operand types.
      UPDATE : o, operator, the instruction field is filled here.
      OUTPUT : tr, type of result ( if pointer is not null ).
      RETURNS: TRUE if operands must be swapped else FALSE.
      NOTES  : types are supposed to be BASIC.
   -- */
 
{ ARIOP u ; short Num[2] ; int i ;

/* -- Operand equivalent types : int/int, int/double, double/int, double/double
   -- */
  static ARIOP TYPtoOP[CI_DOUBLE+1][CI_DOUBLE+1] = {
               /* 0:UNUSED  1:CI_CHAR  2:CI_SHORT  3:CI_INT  4:CI_DOUBLE */
/* UNUSED    */  {     ERR,       ERR,        ERR,      ERR,         ERR }, 
/* CI_CHAR   */  {     ERR,        IX,         IX,       IX,          DX },
/* CI_SHORT  */  {     ERR,        IX,         IX,       IX,          DX },
/* CI_INT    */  {     ERR,        IX,         IX,       II,          DX },
/* CI_DOUBLE */  {     ERR,        DX,         DX,       DX,          DD }
} ;

#if DEBUG
  printf( "TYPari : ENTER\n" ) ;
#endif
  Num[0] = t1->Num ; Num[1] = t2->Num ;
  for( i = 0 ; i < 2 ; i++ ) switch( Num[i] ) {
  	case CI_INTEGER	: Num[i] = CI_INT	; break ;
  	case CI_NUMERIC	: Num[i] = CI_DOUBLE	; break ;
  }
  o->instr = OPtoINS[o->code][(int)( u = TYPtoOP[Num[0]][Num[1]] )] ;
/* -- Type of the result for `+', `-', `*', `/'.
   -- */
  if( tr != NULL ) *tr = TYPbasic( u == II || u == IX ? CI_INT : CI_DOUBLE ) ;

#if DEBUG
  printf( "TYPari : EXIT(1)\n" ) ;
#endif
  return o->instr != EMPTY ;

} /* TYPari */
/*----------------------------------------------------------------------------*/
static int TYPptrcpt( p1, p2 )

PCItype *p1, *p2 ;

/* -- TRUE if p1 and p2 are two compatible pointer types.
      NOTE: p1 and p2 are here supposed to be pointer types.
   -- */
   
{  typedef enum { PTRPTR, FPTFPT, FPTFUN, FUNFUN, ERROR } PTRmatch ;
   static PTRmatch mixing[3][3] = {
/*		FALSE		FCNDCL		FCNPTR		*/
/* FALSE  */ {	PTRPTR,		ERROR ,		ERROR	},
/* FCNDCL */ {	ERROR ,		FUNFUN,		FPTFUN	},
/* FCNPTR */ {	ERROR ,		FPTFUN,		FPTFPT	}
} ;
   int rc ;  

   switch( mixing[p1->Fpt][p2->Fpt] ) {
   	case PTRPTR :
/* -- 			Ordinary pointers ( pointers to <type> ).
			NB : Fpt = 0 ==> Rpt = 0.
			A `void *' type is compatible with any other pointer
			type.
   -- */
   			rc = PCIopt.noptrchk ? TRUE
   					     :    p1->Def == p2->Def
   			     		       && p1->Num == p2->Num
   			     		       || (    p1->Def == BASIC
   			     		            && p1->Num == CI_VOID
   			     		            && p1->Ptr == 1 )
   			     		       || (    p2->Def == BASIC
   			     		            && p2->Num == CI_VOID
   			     		            && p2->Ptr == 1 ) ;
			break ;
   	case FUNFUN :
   	case FPTFPT :
/* -- 			Function pointer / function pointer
		or	Function	 / function.
   -- */
   			rc =    p1->Def == p2->Def
   		             && p1->Num == p2->Num
   	                     && p1->Ptr == p2->Ptr
   	                     && p1->Rpt == p2->Rpt ;
   	                break ;
   	case FPTFUN :
/* -- 			Function pointer / function.
   -- */
   	        	rc =    p1->Def == p2->Def
   		             && p1->Num == p2->Num
   	                     && p1->Ptr == 1
   	                     && p1->Rpt == p2->Ptr ;
   	                break ;
   	case ERROR  :	rc = FALSE ;
	}
  return rc ;

} /* TYPptrcpt */
/*----------------------------------------------------------------------------*/
int TYPptr( t1, o, t2, tr )

PCItype *t1, *t2, *tr	;
PCIop	*o		;

/* -- Handles operations between pointers and numerical values. No operations on
      pointers to functions.
      NOTE : the two types `t1' and `t2' are supposed to be :
   		array or pointer,	array or pointer
   		numeric		, 	array or pointer
   		array or pointer, 	numeric

      BEWARE! tr->Dim is used to flag whether the operands must be swapped.
   -- */
/* -- A word is an int or a GRobj.
   -- */
#define word( p ) ( (p)->Def == CI_INT || (p)->Def == CI_GROBJ	\
				       || (p)->Def == CI_INTEGER )

/* -- TRUE if types have same Def and same Num (used when their Ptr's are equal,
      since the Dim is taken into account by Ptr, this in fact tests if u == v ).
   -- */
#define eq( u, v ) TYPptrcpt( u, v ) 

{ int rc = TRUE, ary1, ary2 ; char savePtr[2] ; Ushort saveDim[2] ;

  savePtr[0] = t1->Ptr ; t1->Ptr += ( ary1 = t1->Dim != 0 ) ;
  savePtr[1] = t2->Ptr ; t2->Ptr += ( ary2 = t2->Dim != 0 ) ;
  saveDim[0] = t1->Dim ; t1->Dim = 0 ;
  saveDim[1] = t2->Dim ; t2->Dim = 0 ;
#if DEBUG
  TYPdump( "TYPptr : ENTER, 1 ", t1 ) ; TYPdump( "TYPptr : ENTER, 2 ", t2 ) ;
#endif
  
  switch( o->code ) {
/* --	ptr + num and num + ptr are OK, ptr + ptr is not.
   -- */
  	case _PLUS	: if( t1->Fpt || t2->Fpt ) rc = FALSE ;
  			  else if( t1->Ptr ) {
  			    if( t2->Ptr ) rc = FALSE ;
  			    else {
  				   *tr		= *t1	;
  				   o->instr 	= PPLUS ;
  			    }
  			  } else {
  			    *tr		= *t2	;
  			    o->instr	= PPLUS ;
  			    tr->Dim	= 1 	; /* SWAP! */ 
  			  }
			  break ;
/* --	ptr - num is OK, num - ptr is not. ptr - ptr is OK if the two types are
	the same.
   -- */
	case _MINUS	: if( t1->Fpt || t2->Fpt ) rc = FALSE ;
			  else if( t1->Ptr ) {
			    if( t2->Ptr ) {
				if( eq( t1, t2 ) ) {
				   *tr = TYPbasic( CI_INT )	;
				   o->instr = PDELTA		;
				} else rc = FALSE ;
			    } else {
				*tr		= *t1		;
				o->instr	= PMINUS	;
			    }
			 } else rc = FALSE ;
			 break ;
/* --	ptr <rel op> ptr is OK if the two types are the same.
   -- */
	case _EQUAL	:
	case _DIFF	:
	case _INFEQU	:
	case _SUPEQU	:
	case _STRSUP	:
	case _STRINF	: if( eq( t1, t2 ) ) {
				*tr = TYPbasic( CI_INT ) ;
				o->instr = OPtoINS[o->code][(int) ( ary1 || ary2 || t1->Fpt || t2->Fpt ? IX : II ) ] ;
			  } else rc = FALSE ;
			  break ;
	case _ANDAND	:
	case _OROR	: *tr = TYPbasic( CI_INT ) ;
			  if(     !ary1 && t1->Fpt != FCNDCL
			       && !ary2 && t2->Fpt != FCNDCL
			       && (    t1->Ptr && !t2->Ptr && word( t2 )
			            || t2->Ptr && !t1->Ptr && word( t1 )
			            || t2->Ptr && t1->Ptr
			          )
			     )
			  	o->instr = OPtoINS[o->code][(int) II] ;
			  else	o->instr = OPtoINS[o->code][(int) IX] ;
			  break ;
	case _ASSIGN	: if( eq( t1, t2 ) ) {
				*tr = *t1 ;
				o->instr = OPtoINS[o->code][(int) ( ary1 || ary2 || tr->Fpt ? IX : II )] ;
			  } else rc = FALSE ;
			  break ;
	default		: rc = FALSE ;
  }
  t1->Ptr = savePtr[0] ; t1->Dim = saveDim[0] ;
  t2->Ptr = savePtr[1] ; t2->Dim = saveDim[1] ;
#if DEBUG
  printf( "TYPptr : EXIT(%d)\n", rc ) ;
#endif
  return rc ;

} /*  TYPptr */			
/*----------------------------------------------------------------------------*/
int TYPmisc( t1, o, t2, tr )

PCItype *t1, *t2, *tr	;
PCIop	*o		;

/* -- Handles  what  is not  handled  by  `TYPptr'  and `TYPari'. From  previous
      selections `t1' is neither a pointer/array nor a  simple arithmetic  type.
      NB: CI_GROBJ compatible with CI_INT.
   -- */

{ int TwoObjs, TwoStrs, rc = TRUE ;

  TwoObjs =    t1->Def == BASIC && ( t1->Num == CI_GROBJ || t1->Num == CI_INT )
            && !t1->Dim && !t1->Ptr
            && t2->Def == BASIC && ( t2->Num == CI_GROBJ || t2->Num == CI_INT )
            && !t2->Dim && !t2->Ptr ;

  TwoStrs =    t1->Def == UNION || t1->Def == STRUC && TYPcompare (*t1, *t2) ;
#if DEBUG
  printf( "TYPmisc : ENTER TwoObjs(%d)\n", TwoObjs ) ;
#endif
  switch( o->code ) {
  	case _ASSIGN	: if( TwoObjs ) {
  				*tr = TYPbasic( CI_GROBJ )		;
  				o->instr = OPtoINS[o->code][(int) II]	;
  			  } else if( TwoStrs ) {
  			  	*tr = *t1		;
  			  	o->instr = MEMCPY	;
  			  } else rc = FALSE ;
  			  
  			  break ;
  	case _EQUAL	: if( TwoObjs ) goto objs ;
  	                  else if( TwoStrs ) {
  	                  	*tr = TYPbasic( CI_INT ) 	;
  	                  	o->instr = MEMEQU		;
  	                  } else rc = FALSE ;
  			  break ;
  	case _DIFF	: if( TwoObjs ) {
  				objs :
  				*tr = TYPbasic( CI_INT )		;
  				o->instr = OPtoINS[o->code][(int) II]	;
  	                  } else if( TwoStrs ) {
  	                  	*tr = TYPbasic( CI_INT ) 	;
  	                  	o->instr = MEMDIF		;
  			  } else rc = FALSE ;
  			  break ;
  	default		: rc = FALSE ;
  }
#if DEBUG
  printf( "TYPmisc : EXIT(%d)\n", rc ) ;
#endif
  return rc ;

} /* TYPmisc */
/*----------------------------------------------------------------------------*/
int TYPmatch( t1, o, t2, tr )

PCItype *t1, *t2, *tr	;
PCIop	*o		;

/* -- Given an operator and  its operands' types, checks that they are legal and
      finds the right instruction.
      INPUT  : t1, t2, operands' types.
      UPDATE : o, operator ( the instruction field of which is updated ).
      OUTPUT : tr, type of the result.
      RETURNS: FALSE if invalid type(s) for this operand else TRUE.
   -- */

{ int peq1, peq2, num1, num2, rc ; extern OPERATOR OPinfo[] ;
#if DEBUG
  printf( "TYPmatch : ENTER op `%s'(%d)\n", OPinfo[o->code].name, o->instr ) ;
#endif

 if( OPinfo[o->code].icode == BRANCHFUNC ) rc = FALSE ;
 else {
 tr->Dim = 0 ; tr->Ptr = 0 ; tr->Def = BASIC ; tr->Fpt = tr->Rpt = FALSE ;

/* -- 	Get equivalent types.
   -- */
#if DEBUG
  TYPdump( "TYPmatch : 1 ", t1 ) ;
  TYPdump( "TYPmatch : 2 ", t2 ) ;
#endif
   	TYPeq( &t1, &t2 ) ;
#if DEBUG
  TYPdump( "TYPmatch : eq1 ", t1 ) ;
  TYPdump( "TYPmatch : eq2 ", t2 ) ;
#endif

/* -- 	Are those types numeric or pointers ( to type or function ) or arrays ?
   -- */
   	peq1 = t1->Dim || t1->Ptr || t1->Fpt ;
   	peq2 = t2->Dim || t2->Ptr || t2->Fpt ;
   	num1 = !peq1 && t1->Def == BASIC && (    t1->Num >  CI_VOID
   					      && t1->Num <= CI_DOUBLE
   					      || t1->Num == CI_INTEGER
   					      || t1->Num == CI_NUMERIC ) ;
   	num2 = !peq2 && t2->Def == BASIC && (    t2->Num >  CI_VOID
   					      && t2->Num <= CI_DOUBLE
   					      || t2->Num == CI_INTEGER
   					      || t2->Num == CI_NUMERIC ) ;
#if DEBUG
  printf( "TYPmatch : peq1 %d peq2 %d num1 %d num2 %d\n", peq1,peq2,num1,num2 ) ;
#endif

  	if( peq1 ) {
  		if( peq2 || num2 )	rc = TYPptr( t1, o, t2, tr )	;
  		else 			rc = FALSE			;
  	} else if( num1 ) {
  		if( peq2 )		rc = TYPptr( t1, o, t2, tr )	;
  		else if( num2 )		rc = TYPari( t1, o, t2, tr )	;
  		else			rc = TYPmisc( t1, o, t2, tr )	;
  		/* RM if OK FALSE			; */
  	} else				rc = TYPmisc( t1, o, t2, tr )	;
  }
#if DEBUG
  printf( "TYPmatch : EXIT(%d)\n", rc ) ;
#endif
  return rc ;

} /* TYPmatch */
/*----------------------------------------------------------------------------*/
int TYPcast( cast, t, o, is_void )

PCItype *cast, *t	;
PCIop	*o		;
int	*is_void	;

/* -- Chooses the right assignment to simulate casting.
   -- INPUT : cast, wanted resulting type.
              t   , type of operand of cast.
      OUTPUT: asg , assignment operator.
      	      is_void, TRUE if casting to `void'.
   -- NOTE : `cast' and `t' are supposed to not be structures or unions.
   -- */

{ PCItype *T ; unsigned size1, size2 ; extern OPERATOR OPinfo[] ; int rc ;

  o->instr = OPinfo[o->code = _ASSIGN].icode ;

  T = cast ;
  TYPeq( &T, (PCItype **) NULL )  ;
#if DEBUG
	TYPdump( "TYPcast : cast ", cast ) ; TYPdump( "TYPcast : t ", t ) ;
	TYPdump( "TYPcast : T "   , T    ) ;
#endif
  rc = TRUE ;

  if( *is_void = TYPvoid( T ) ) return rc ;

  if( ( T->Def == STRUC || T->Def == UNION ) && !T->Ptr || T->Dim )
       rc = ERRsyn( "invalid cast type", NULL ) ;
  else {
  	T = t ;
  	TYPeq( &T, (PCItype **) NULL )  ;

	if( T->Dim ) {
  		o->instr = ASSIGNT ;
  		cast->Dim = T->Dim ;
  	} else {
  		size1 = TYPsizeof( cast ) ;
  		size2 = TYPsizeof( t    ) ;
  		if( size1 == size2 ) switch( size1 ) {
  			case sizeof( int    ) : o->instr = IASSIGNTI ; break ;
  			case sizeof( double ) : o->instr = DASSIGNTD ; break ;
  			default               : o->instr =  ASSIGNT  ; break ;
  		} else                          o->instr =  ASSIGNT  ;
  	}
  }
  return rc ;

} /* TYPcast */
/*----------------------------------------------------------------------------*/
/* -- Finds the type of the sum of two numeric variables.
      Authorized mixing :
      RESULT | char   | short  | int    | double | pointer
      char   | int    | int    | int    | double | pointer
      short  | int    | int    | int    | double | pointer
      int    | int    | int    | int    | double | pointer
      double | double | double | double | double | pointer
      pointer| pointer| pointer| pointer| pointer| int ( `-' only ) 
   -- */
/*----------------------------------------------------------------------------*/
int TYPisdim( d )

int d ;

/* -- Checks that `d' is a valid array  dimension, i.e. that it is positive, can
      fit in an unsigned short and is not infinite (as result of a zero divide).
   -- */

{ int rc = FALSE ;

#if DEBUG
  printf( "TYPisdim : dim <%d>\n", d ) ;
#endif
       if( d <=  0       ) ERRsyn( "array dimension must be > 0" , NULL ) ;
  else if( d >  MAXDIM   ) ERRsyn( "array dimension is too large", NULL ) ;
  else if( d == INFINITE ) ERRsyn( "array dimension is infinite" , NULL ) ;
  else                     rc = TRUE ;

  return rc ;

} /* TYPisdim */
/*----------------------------------------------------------------------------*/
int TYPfuncall( formal, actual, fundef )

PCItype *formal, *actual	;
char	 fundef			;

/* -- Checks validity between a formal and an actual argument of a function.
      A pointer is compatible with any other pointer ( simplistic, I know )
      A pointer to <type> is compatible with an array of <type>.
      A char, int or short is compatible with a char, int or short.
      A double is compatible with a char, int, short or double.
      A GRobj is compatible with a GRobj.
      NOTE : formal arguments are never arrays ( if declared as arrays, they
             are converted to pointers ), hence their Dim is always 0.
   -- */

#define in( elm, min, max ) ( (min) <= (elm) && (elm) <= (max) )

{ int rc, aDef, aNum, aPtr, aRpt, aFpt, aDim, 
          fDef, fNum, fPtr, fRpt, fFpt ; 

#if DEBUG
printf( "actual->num %d formal->num %d\n", actual->Num, formal->Num ) ;
  TYPdump( "TYPfuncall : formal ", formal ) ; fflush( stdout ) ;
  TYPdump( "TYPfuncall : actual ", actual ) ; fflush( stdout ) ;
#endif
  TYPeq( &formal, &actual ) ;
#if DEBUG
  TYPdump( "TYPfuncall : EQ formal ", formal ) ; fflush( stdout ) ;
  TYPdump( "TYPfuncall : EQ actual ", actual ) ; fflush( stdout ) ;
#endif
  aDef = actual->Def ; aNum = actual->Num ; aPtr = actual->Ptr ;
  aRpt = actual->Rpt ; aFpt = actual->Fpt ; aDim = actual->Dim ; 
  fDef = formal->Def ; fNum = formal->Num ; fPtr = formal->Ptr ;
  fRpt = formal->Rpt ; fFpt = formal->Fpt ;
/* RM if OK
  if( fPtr ) rc =    ( fundef == USRFUN || fDef != CI_STRUCT ? fPtr    == aPtr
                                                             : *formal == *actual )
                  ||    fNum == aNum && fDef == aDef
                     && fRpt == aRpt && fFpt == aFpt
                     && aDim != 0    && aPtr == fPtr - 1
                  ;
end RM if OK */
  if( fPtr ) rc =    ( fundef == SYSFUN
  			 && ( fDef != CI_STRUCT ? fPtr    == aPtr
                                                : TYPcompare (*formal, *actual) ) )
                  || TYPcompare (*formal, *actual)
                  ||    fNum == aNum && fDef == aDef
                     && fRpt == aRpt && fFpt == aFpt
                     && aDim != 0    && aPtr == fPtr - 1
		  || TYPvoidptr( formal ) && ( aPtr || aDim != 0 ) ;
  else switch( fDef ) {
    case BASIC : switch( fNum ) {
/* --	Cases CI_INTEGER and CI_NUMERIC only happen when a user functions
	implements a `typeinit'.
   -- */
  	case CI_CHAR	:
  	case CI_SHORT	:
  	case CI_INTEGER :
  	case CI_INT	: rc =     aDef == BASIC && !aPtr && !aDim
  		       		&& in( aNum, CI_CHAR, CI_INT ) ;
                    	  break ;
  	case CI_DOUBLE	: rc =     aDef == BASIC && !aPtr && !aDim
  		       		&& ( fundef == SYSFUN ? in( aNum, CI_CHAR, CI_DOUBLE )
  			  	                      : aNum == CI_DOUBLE  ) ;
                    	  break ;
        case CI_NUMERIC : rc =     aDef == BASIC && !aPtr && !aDim
        			&& in( aNum, CI_CHAR, CI_DOUBLE ) ;
			  break ;
  	case CI_GROBJ	: rc =	   aDef == BASIC && !aPtr && !aDim
				&& ( aNum == CI_GROBJ || aNum == CI_INT ) ;
		  	  break ;
/* -- The following case only happens if `formal' is the type of a library
      function ( otherwise structs are not BASIC! ).
   -- */
	case CI_STRUCT	: rc = aDef == STRUC && !aPtr && !aDim;
		  	  break ;
	default		: cibugchk( "TYPfuncall", "unknown basic type" ) ;
	}
	break ;
    case UNION :
    case STRUC : rc = TYPcompare( *formal, *actual ) ;
                 break ;
/* -- The case TYPDF has been eliminated by a call to `TYPeq' as well as enums.
   -- */
    default	   : cibugchk( "TYPfuncall", "unknown type definition" ) ;
  }
  	
#if DEBUG
  printf( "TYPfuncall : EXIT(%d)\n", rc ) ;
#endif
  return rc ;

} /* TYPfuncall */
/*----------------------------------------------------------------------------*/
char *BSCname( ib )	int ib ; {
					char *n ;
	switch( ib ) {
   	     	case CI_VOID	: n = "void"	; break ;
   	     	case CI_CHAR	: n = "char"	; break ;
   	     	case CI_SHORT	: n = "short"	; break ;
   	     	case CI_INT	: n = "int"	; break ;
		case CI_INTEGER	: n = "integer"	; break ;
   	     	case CI_GROBJ	: n = "GRobj"	; break ;
   	     	case CI_DOUBLE	: n = "double" 	; break ;
   	     	case CI_NUMERIC	: n = "numeric"	; break ;
   	     	default		: n = "unknown"	; break ;
   	}
	return n ;
}
/*----------------------------------------------------------------------------*/
void TYPname( T, def, nam )

PCItype	*T		;
char	**def, **nam	;

/* -- A utility : retrieves a type from it parameters.
   -- */

{ char *TDFname(), *STRname(), *ENMname() ;

   switch( T->Def ) {
   	case BASIC : *def = "basic"	; *nam = BSCname( (int) T->Num ) ;
   		     break ;
   	case UNION : *def = "union"	; *nam = STRname( (int) T->Num ) ;
   		     break ;
   	case STRUC : *def = "struct"	; *nam = STRname( (int) T->Num ) ;
   		     break ;
   	case ENUMT : *def = "enum"	; *nam = ENMname( (int) T->Num ) ;
   		     break ;
   	case TYPDF : *def = "typedef"	; *nam = TDFname( (int) T->Num ) ;
   		     break ;
   	default	   : *def = "unknown"	; break ;
   }

} /* TYPname */
/*----------------------------------------------------------------------------*/
void TYPind( arr, elt ) PCItype *arr, *elt ; {

/* -- Given the type of an array/pointer, finds the type of one of its elements.
      BEWARE in case of typedef and pointers to functions !
   -- */
   
  if( arr->Def == TYPDF ) {
  		elt->Ptr = arr->Ptr 			;
  		elt->Dim = arr->Dim			;
  		arr = TDFeq( (int) arr->Num )		;
  		if( !arr->Dim ) arr->Dim = elt->Dim	;
  } else	elt->Rpt = elt->Ptr = 0			;
  elt->Num  = arr->Num			;
  elt->Def  = arr->Def			;
  elt->Rpt  = arr->Rpt 			;
  elt->Fpt  = arr->Fpt 			;
  elt->Ptr += arr->Ptr - ( !arr->Dim )	;
  elt->Dim  = 0				;

} /* TYPind */
/*----------------------------------------------------------------------------*/
int TYPscalar( T ) PCItype *T ; {

/* -- A structure field's type is scalar if it is neither a structure nor a
      union.
   -- */

	if( T->Def == TYPDF ) TYPeq( &T, (PCItype **) NULL )	;
  	return T->Dim || T->Ptr || !( T->Def == STRUC || T->Def == UNION ) ;
}
/*----------------------------------------------------------------------------*/
void TYPdump( text, T )	char *text ;
			PCItype *T ; {

  printf( "%s.Def %d .Num %d .Ptr %d .Dim %d .Rpt %d .Fpt %d .Spc %u size %u\n",
  	  text, T->Def, T->Num, T->Ptr, T->Dim, T->Rpt, T->Fpt, T->Spc, TYPsizeof(T) ) ;
}
/*----------------------------------------------------------------------------*/
int TYPderived( modifier ) Uchar *modifier ; {

/* -- Parses a derived type (i.e. modified by *, () or []).
      INPUT  : modifier, array of modifier :
      		The size of the array is at index 0, and the elements from 1 to
      		modifier[0].
   -- */
	int i, rc = TRUE ; Uchar nmods, tmp ;

 if( nmods = modifier[0] ) {

	while( modifier[nmods] == _LPAR && modifier[nmods-1] == _LPAR ) {
		tmp = modifier[nmods] ;
		for( i = nmods ; i > 1 ; i-- ) {
			modifier[i] = modifier[i-1] ;
		}
		modifier[1] = tmp ;
	
		if( modifier[1] == _LPAR && modifier[2] == _LPAR ) {
			rc = ERRsyn( "invalide type modifier `()()'", NULL ) ;
			break ;
		}
#if DEBUG
 for( i = 1 ; i <= nmods ; i++ ) {
  switch( modifier[i] ) {
	case _MUL	: printf( "* "  ) ; break ;
	case _BRA	: printf( "[] " ) ; break ;
	case _LPAR	: printf( "() " ) ; break ;
  } printf( "\n" ) ;
 }
#endif
	}

#if DEBUG
	for( i = 1 ; i <= nmods ; i++ ) {
		switch( modifier[i] ) {
			case _MUL	: printf( "pointer to " ) ; break ;
			case _BRA	: printf( "array of " ) ; break ;
			case _LPAR	: printf( "function returning " ) ; break ;
		}
	}
	printf( "\n---------------------------\n" ) ;
#endif
 }
 return rc ;
}
/*----------------------------------------------------------------------------*/
int TYPvoid( T ) PCItype *T ; {

	return 		T->Def == BASIC
		&&	T->Num == CI_VOID
		&&	T->Fpt != FCNDCL
		&&	!T->Ptr ;
}
/*----------------------------------------------------------------------------*/
int TYPvoidptr( T ) PCItype *T ; {

	return 		T->Def == BASIC
		&&	T->Num == CI_VOID
		&&	!T->Fpt
		&&	T->Ptr == 1		;
}
/*----------------------------------------------------------------------------*/

