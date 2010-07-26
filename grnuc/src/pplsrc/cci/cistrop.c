/* -- This modules handles the access to structure fields ( via `.' and `->' ).
      The tricky bit is to memorize where one is as a structure field is being
      parsed :
      		s1.f1.f2.f3. ...
      Thus once the final field is reached its address may be computed. The aim
      is to take care of situations as :
      		- "&s1.f1.f2. ... fn"
      		- "<func>( ..., s1.f1.f2. ... fn, ... )"
      		- "s1.f1.f2. ... fn ;"
      		- "s1.f1.f2. ... fn = S1.F1.F2. ... Fm"
      		- "s1.f1.f2. ... fn == S1.F1.F2. ... Fm"
      when the last fields (fn or Fm) also are structures.
      ( FAO = Field Access Operators )
   -- */
/*----------------------------------------------------------------------------*/
#include "pcidef.h"
#include "pci.h"
#include "pcimacros.h"
#include "cichardef.h"
#include "cidef.h"
#include "citypedef.h"
#include "ciy.h"
#include <string.h>
#define DEBUG 0
/*-GLOBALS-------------------------------------------------------------------*/
/* -- Counter ( 2 struct variables can be active at the same time at most when
      they are operands of a binary operator ).
   -- */
static char	fao__cnt ;

/* -- Names for auxiliary variables
   -- */
static PCIident	fao__auxnm[2] = { "{", "{" } ;

/* -- Current structure variable index ( EMPTY if no struct ) ( field `type' not
      initialized ).
   -- */
static PCIstrv	fao__fld[2] = { { EMPTY, 0, fao__auxnm[0] },
			       { EMPTY, 0, fao__auxnm[1] } } ;
/*-MACROS---------------------------------------------------------------------*/
#define MADE( var )	( (var) != EMPTY )

/* -- Appends new field name to already memorized field for current structure.
   -- */
#define APPEND( F )	( strcat( strcat( fao__fld[fao__cnt].name, "." ), (F) ) )

#define PTR_TO_STRUCT( C ) (     ( C.typ.Dim != 0     || C.typ.Ptr          )\
                             &&  ( C.typ.Def == STRUC || C.typ.Def == UNION )\
                             &&  !C.typ.Fpt )
/*----------------------------------------------------------------------------*/
void		MKname(), CTXdefault()	;
unsigned 	TYPsizeof()		;

PCIpointer Dummy1, Dummy2, Nul;
/*----------------------------------------------------------------------------*/
void FAOreset()

/* -- Resets all data to begin exploring a new structure field. Must be called
      after an expression has been parsed.
   -- */
{
	 fao__fld[0].indx	= fao__fld[1].indx	= EMPTY	;
	 fao__fld[0].offs	= fao__fld[1].offs	= 0 	;
	 fao__fld[0].name[0]	= fao__fld[1].name[0]	= EOSTR	;
	 fao__cnt = EMPTY ;

} /* FAOreset */
/*----------------------------------------------------------------------------*/
int FAOflush( e )	int *e ; {

/* -- Handles case when a structure variable is argument of a function or is an
      instruction all by itself.
      OUTPUT : e, pointer to newly created variable.
      RETURNS: FALSE if variable construction failed else TRUE.
      NOTE   : `e' can be NULL if the index  of the var is not desired, if there
               was no structure variable to construct, `e' is left unchanged.
   -- */

			int v, rc ; PCIstrv *s ; PCIcontext C ;

   switch( fao__cnt ) {
   	case EMPTY: rc = TRUE ; break ;
   	case  0   : s = fao__fld ;
    		  CTXdefault( &s->type, &C ) ;
        	  rc =    MADE( v = MKdcl( &C, s->name ) )
        	       && gen( s->oper.instr, 3, v, s->indx, (int) s->offs ) ;
	   	  FAOreset() ;
  		  if( e != NULL ) *e = v ;
      		  break ;
      	default   : rc = cibugchk( "FAOflush", "unexpected structure count" ) ;
  }

  return rc ;

} /* FAOflush */
/*----------------------------------------------------------------------------*/
int FAOdot( exp, Struct, o, Field )

int		*exp, Struct	;
PCIident	Field		;
PCIop		*o		;

/* -- Handles the `.' operator : if `Field' is  a field which is not a  union or
      structure, performs an  indirection, else  memorizes the field  offset for
      the next time.
      INPUT : Struct, var index (1st time) or struct index (following times).
      	      o     , operator.
      	      Field , field name.
      OUTPUT: exp, index  of  created  variable  accessing  field (last time) or
                   index of struct (preceeding times).
      NOTE  : this function is called as "s.f1.f2. ... fn" is being parsed :
        1) Struct=index( s ), Field="f1", *exp=s's struct type index
        2) Struct=s's struct type index, Field="f2", *exp=s's struct type index
					...
        j) Struct=s's struct type index, Field="fj", *exp=s's struct type index
      As this goes on, the offset are accumulated :
      		 	rel_o = offset(f1) + ... + offset(fj)
      and memorized. If  a field  fn is  reached which  is scalar, an  auxiliary
      address variable is created with the instruction to assign it :
      			address( s ) + rel_o
      and *exp is assigned the index of that variable.
   -- */

{ int			rc	= TRUE, is	;
  unsigned		f_dim			;
  PCIcontext		fctx			;
  PCIstrv		*str			;
  PCItype		*stype	, *eq		;
  PCInode		fld	, dot		;
  void			TYPeq()			;

#if DEBUG
  { char *STRname() ;
  if( (int) fao__cnt == EMPTY ) printf( "FAOdot : ENTER Struct=%s", PCIvar( Struct ) ) ;
  else 	printf( "FAOdot : ENTER Struct=%d <%s>", Struct, STRname( Struct ) ) ; 
  printf( ", Field=<%s>\n", Field ) ; fflush( stdout ) ;
  printf( "FAOdot : fao__cnt = %d\n", fao__cnt ) ; fflush( stdout ) ;
  printf( "FAOdot : fao__off0 = %d\n", fao__fld[0].offs ) ; fflush( stdout ) ;
  printf( "FAOdot : fao__off1 = %d\n", fao__fld[1].offs ) ; fflush( stdout ) ;
  }
#endif
  if( (int) fao__cnt == EMPTY ) {
/* -- `Struct' is the index of a variable for no struct variable is in store.
   -- */
  	if( !isstruct( Struct ) )
	       rc = ERRsyn( "not a structure or union", PCIvar( Struct ) ) ;
	else {
		fao__fld[++fao__cnt].oper = *o				;
		stype = pPCIdef( fao__fld[fao__cnt].indx = Struct )	;
		TYPeq( &stype, (PCItype **) NULL )			;
		is = stype->Num						;
		Dummy1.Any = PCIvar( Struct );
		Dummy2.Any = Field;
		Nul.Any = NULL;
		MKname( VAR | STF, strchr( fao__fld[fao__cnt].name, EOSTR ),
		        Dummy1, Dummy2, Nul ) ;
	}
  } else {
/* --	It is the index of a struct in the struct table.
   -- */
	is = Struct ; APPEND( Field ) ;
  }

  if( rc = rc && STRgetfield( is, Field, &fctx.typ, &fld.info.field ) ) {
    str = &fao__fld[fao__cnt]	;
    str->offs += fld.info.field.offset	;
    str->type  = fctx.typ	;
#if DEBUG
  printf( "FAOdot : 1 .Def %d .Dim %d .Ptr %d .Num %d scal ? %d\n", fctx.typ.Def,
  	fctx.typ.Dim, fctx.typ.Ptr, fctx.typ.Num, TYPscalar( &fctx.typ ) ) ;
#endif
/* NEW */
	f_dim = fctx.typ.Dim ;
/* --	Get equivalent type.
   -- */
    	eq = &fctx.typ ;
    	TYPeq( &eq, (PCItype **) NULL ) ;
    	fctx.typ = *eq ;
/* end NEW */
    if( TYPscalar( &fctx.typ ) ) {
    	CTXdefault( (PCItype *) NULL, &fctx ) ;
	if( f_dim == 0 ) f_dim = eq->Dim ;
   	fctx.typ.Dim = 0 ;
        rc =    MADE( *exp = MKdcl( &fctx.typ, str->name ) )
             && gen( str->oper.instr, 3, *exp, str->indx, (int) str->offs ) ;
/* --   Force type again in case of ARR !	
   -- */
	PCIdef( *exp ).Dim = PCIdim( *exp ) = f_dim ;
#if DEBUG
  printf( "FAOdot : 2 .Def %d .Dim %d .Ptr %d .Num %d \n", PCIdef( *exp ).Def,
  	PCIdef( *exp ).Dim, PCIdef( *exp ).Ptr, PCIdef( *exp ).Num ) ;
#endif
	FAOreset() ;
    } else *exp = fctx.typ.Num ;
  } else rc = ERRsyn( "not a structure field", Field ) ;

/* -- Build node for parse tree.
   -- */
  fld.type			= OFFSET 	;
  dot.type			= BINARY 	;
  dot.info.operator.symbol	= *o	 	;
  dot.info.operator.result	= fctx.typ	;
  rc = rc && mkNOD( &fld ) && mkNOD( &dot ) ;
#if DEBUG
  printf( "FAOdot : EXIT( %d )\n", rc ) ; fflush( stdout ) ;
#endif
  return rc ;

} /* FAOdot */
/*----------------------------------------------------------------------------*/
int FAOarw( exp, Struct, o, Field )

int		*exp, Struct	;
PCIident	Field		;
PCIop		*o		;  

/* -- Handles the `->' operator : if `Field' is a field which is not a  union or
      structure, performs  an indirection, else   memorizes the field offset for
      the next time.
      INPUT : Struct, variable index ( must be a pointer to union or struct )
      	      o, operator
      	      Field, field name
      OUTPUT: exp, index of  created  variable accessing  field  (if  scalar) or
                   index of struct (field not scalar).
   -- */

{ int		rc 		;
  PCIcontext    fctx		;
  unsigned	f_dim		;
  PCIident	name		;
  PCItype	*ftyp, *eq	;
  PCInode	fld	, arw	;
  void		TYPeq()		;

#if DEBUG
  printf( "FAOarw : Field <%s>\n", Field ) ; VARdebug( Struct ) ;
#endif
  fctx.typ = PCIdef( Struct )		; ftyp		= &fctx.typ	;
  TYPeq( &ftyp, (PCItype **) NULL )	; fctx.typ	= *ftyp		;

  if( !PTR_TO_STRUCT( fctx ) )
    rc = ERRsyn( "pointer to union/struct required", NULL ) ;
  else if( !STRgetfield( (int) fctx.typ.Num, Field, &fctx.typ, &fld.info.field ) )
    rc = ERRsyn( "not a structure field", Field ) ;
  else {
/* NEW */
      	f_dim	= fctx.typ.Dim	;
/* --	Get equivalent type.
   -- */
      	eq	= &fctx.typ	;
    	TYPeq( &eq, (PCItype **) NULL ) ;
    	fctx.typ = *eq ;
/* end NEW */
    if( TYPscalar( &fctx.typ ) ) {
#if DEBUG
    printf("FAOarw : fld.info.field.offset %u\n", fld.info.field.offset ) ;
    TYPdump( "FAOarw : fctx 1", &fctx ) ;
#endif
	Dummy1.Any = PCIvar( Struct );
	Dummy2.Any = Field;
	Nul.Any = NULL;
      	MKname( VAR | STP, name, Dummy1, Dummy2, Nul);
    	CTXdefault( (PCItype *) NULL, &fctx ) ;
	if( f_dim == 0 ) f_dim = eq->Dim ;
      	fctx.typ.Dim = 0 ;

        rc =    MADE( *exp = MKdcl( &fctx, name ) )
             && gen( o->instr, 3, *exp, Struct, (int) fld.info.field.offset ) ;
/* --	Force type again in case of ARR !
   -- */
	PCIdef( *exp ).Dim = PCIdim( *exp ) = f_dim ;

	FAOreset() ;
  } else {	
		fao__fld[++fao__cnt].oper = *o			;
		fao__fld[fao__cnt].indx = Struct  		;
		fao__fld[fao__cnt].type = fctx.typ		;
		fao__fld[fao__cnt].offs = fld.info.field.offset	;
		Dummy1.Any = PCIvar( Struct );
		Dummy2.Any = Field;
		Nul.Any = NULL;
		MKname( VAR | STP, strchr( fao__fld[fao__cnt].name, EOSTR ),
		        Dummy1, Dummy2, Nul);
		*exp = fctx.typ.Num ;
      		/* -- MUST PUT OPs in TREE
      		rc = mkNOD( OPERAND, *exp ) && mkNOD( BINARY, _ARROW ) ;
      		   -- */
      		rc = TRUE ;
  }
  }
  
  fld.type			= OFFSET 	;
  arw.type			= BINARY 	;
  arw.info.operator.symbol	= *o	 	;
  arw.info.operator.result	= fctx.typ	;

  rc = rc && mkNOD( &fld ) && mkNOD( &arw ) ;

#if DEBUG
  printf( "FAOarw : EXIT oper %d rc %d\n", o->instr, rc ) ;
#endif
  return rc ;
	
} /* FAOarw */
/*----------------------------------------------------------------------------*/
