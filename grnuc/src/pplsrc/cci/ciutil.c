#include <search.h>
#include <stdio.h>
#include <string.h>
#include <malloc.h>
#include "cidef.h"
#include "pci.h"
#include "pcidef.h"
#include "pcimacros.h"
#include "cichardef.h"
#include "cidef.h"
#include "citypedef.h"
#include "ciy.h"
/*----------------------------------------------------------------------------*/
int CVTtoint( val ) int val ; {

/* -- Assigns variable at index `val' to an integer register.
      RETURNS: register index in case of sucess or EMPTY.
   -- */
  		extern OPERATOR	OPinfo[]	;
  		PCIop		asg		;
  		int		reg		;
  		PCItype		*pTYPbasic()	;

	asg.instr = OPinfo[asg.code = _ASSIGN].icode ;
	if( ( reg = mkREG( pTYPbasic( CI_INT ) ) ) != EMPTY )
		if( !OPasg( &val, reg, &asg, val ) ) reg = EMPTY ;

	return reg ;
} /* CVTtoint */
/*----------------------------------------------------------------------------*/
int CVTtodbl( val ) int val ; {

/* -- Assigns variable at index `val' to an double precision register.
      RETURNS: register index in case of sucess or EMPTY.
   -- */
  		extern OPERATOR	OPinfo[]	;
  		PCIop		asg		;
  		int		reg		;
  		PCItype		*pTYPbasic()	;

	asg.instr = OPinfo[asg.code = _ASSIGN].icode ;
	if( ( reg = mkREG( pTYPbasic( CI_DOUBLE ) ) ) != EMPTY )
		if( !OPasg( &val, reg, &asg, val ) ) reg = EMPTY ;

	return reg ;
} /* CVTtodbl */
/*----------------------------------------------------------------------------*/
int IDfind( id )	PCIident id ; {

  return    STBfind( id, SYM_GVAR_NAM ) != EMPTY
         || TDFfind( id, (PCItype *) NULL )
         || ENMfindV( id, NULL ) != EMPTY ;
}
/*----------------------------------------------------------------------------*/
void civersion() {
  printf( "CI/PPL parser, Version %s.%d.\n", CI_VERSION_NUMBER, PCI_VERSION ) ;
}
/*----------------------------------------------------------------------------*/
char *itoa( string, integer )	char *string ;
				int  integer ; {

		char buf[10], *b, *save ; int remainder ;

  b = buf ; save = string ;
  if( integer == 0 ) *b++ = '0' ;
  else {
  	if( integer < 0 ) { *b++ = '-' ; integer *= -1 ; }
  	do {
  		remainder =  integer % 10   ;
  		integer   /= 10             ;
  		*b++      = '0' + remainder ;
  	} while( integer ) ;
  }

  while( b > buf ) *string++ = *--b ;
  *string = EOSTR ;
  return save ;

} /* itoa */
/*----------------------------------------------------------------------------*/
void MKname( type, name, data1, data2, data3 )

int		type			;
PCIpointer	data1, data2, data3	;
PCIident	name			;

{ int l1, l2 ;

  if( type & VAR ) { 
  	*name++ = AUXVAR ;
	l1 = strlen( data1.Chr ) ;
  	       if( type & PTR ) {
  	     	*name++ = '&' ;
  	     	strncpy( name, data1.Chr, MAXIDLEN - 3 ) ;
  	     	name += l1 ;
  	} else if( type & IND ) {
  	     	*name++ = '*' ;
  	     	strncpy( name, data1.Chr, MAXIDLEN - 3 ) ;
  	     	name += l1 ;
  	} else if( type & ARR ) {
		l2 = strlen( data2.Chr ) ;
		while( l1 + l2 >= MAXIDLEN - 4 ) { l1-- ; l2-- ; }
		strncpy( name, data1.Chr, l1 ) ; name += l1 ; *name++ = '[' ;
		strncpy( name, data2.Chr, l2 ) ; name += l2 ; *name++ = ']' ;
	} else if( type & STP ) {
		l2 = strlen( data2.Chr ) ;
		while( l1 + l2 >= MAXIDLEN - 4 ) { l1-- ; l2-- ; }
		strncpy( name, data1.Chr, l1 ) ; name += l1 ; *name++ = '-' ; *name++ = '>' ;
		strncpy( name, data2.Chr, l2 ) ; name += l2 ; 
	} else if( type & STF ) {
		l2 = strlen( data2.Chr ) ;
		while( l1 + l2 >= MAXIDLEN - 4 ) { l1-- ; l2-- ; }
		strncpy( name, data1.Chr, l1 ) ; name += l1 ; *name++ = DOT ;
		strncpy( name, data2.Chr, l2 ) ; name += l2 ;
	} else cibugchk( "MKname", "unknown naming code" ) ;
  	*name = EOSTR ;
  } else if( type & CST ) {
  	*name++ = CSTVAR ;
  	switch( (int) data1.Val ) {
  		case CI_INT	: *name++ = 'I' ;
  		                  itoa( name, *data2.Int ) ; break ;
  		case CI_DOUBLE	: *name++ = 'D' ;
  		                  itoa( name, *data2.Int ) ; break ;
  		case CI_STRING  : *name++ = 'S' ;
  		                  itoa( name, *data2.Int ) ; break ;
  		case CI_CHAR	: *name++ = 'C' ; *name++ = *data2.Chr ; 
  		                  *name = EOSTR ; break ;
  	}

  } else if( type & OPR ) {
/* -- Name generator : ><number><operator><name> e.g. ">12&&arg1".
   -- */
   	l1 =  1 + strlen( itoa( name, data1.Val ) )
   		+ strlen( data2.Chr ) + strlen( data3.Chr ) ;
   	if( l1 < MAXIDLEN )
   		sprintf( name, "%c%d%s%s"  	, OPRVAR, data1.Val,
   		               data2.Chr	, data3.Chr ) ;
	else	sprintf( name, "%c%d%s%.*s"	, OPRVAR, data1.Val,
			       data2.Chr	, MAXIDLEN - l1 - 1,
			       data3.Chr ) ;
  } else if( type & ARG ) {
/* -- Name generator : ?<number><name> e.g. "?133arg1".
   -- */
	l1 =   1 + strlen( itoa( name, data1.Val ) ) + strlen( data2.Chr ) ;
   	if( l1 < MAXIDLEN )
   		sprintf( name, "%c%d%s"  , ARGVAR, data1.Val, data2.Chr ) ;
   	else	sprintf( name, "%c%d%.*s", ARGVAR, data1.Val,
   			 MAXIDLEN - l1 - 1, data2.Chr ) ;
  } else if( type & INI ) {
/* -- Name generator : =<number>.<number>.<name> e.g. "=12.1.arg1".
   -- */
   	l1 = 3 + strlen( itoa( name, data1.Val ) )
   	       + strlen( itoa( name, data2.Val ) ) + strlen( data3.Chr ) ;
   	if( l1 < MAXIDLEN )
   		sprintf( name, "%c%d.%d.%s", INIVAR, data1.Val, data2.Val,
   		               data3.Chr ) ;
   	else	sprintf( name, "%c%d.%d.%.*s", INIVAR, data1.Val, data2.Val,
   		               MAXIDLEN - l1 - 1, data3.Chr ) ;
  } else cibugchk( "MKname", "unknown naming code" ) ;

} /* MKname */
/*----------------------------------------------------------------------------*/
void GRobjinit( v ) int v ; {

				register int i ;

  if( ( i = PCIdim( v ) ) == 0 ) PCIobj( v ) = NULL_OBJID ;
  else while( i-- ) ( (OM_S_OBJID *) PCIval( v ) )[i] = NULL_OBJID ;
}
/*----------------------------------------------------------------------------*/
int mkLST( list, elt )	int	elt	;
			PCIlist	**list	; {

/* -- Allocates a dynamic list, initializes the SECOND element ( those lists are
      used for function arguments : the first element is the function index ).
   -- */

			int rc = TRUE ;

  if(    MALLOC( *list            , 1        , PCIlist ) != NULL
      && MALLOC( (*list)->elt.Auto, LISTBUNCH, short   ) != NULL ) {
      	(*list)->free = TRUE ;
  	if( elt == -1 )
  		(*list)->num = 1 ;
  	else {
#if DEBUG
  printf( "mkLST : elt = <%s> (%d)\n", PCIvar( elt ), elt ) ;
#endif
  		(*list)->num		= 2	;
  		(*list)->elt.Auto[1]	= elt	;
  	}
  } else rc = ERRmem( "list" ) ;

  return rc ;
   
} /* mkLST */
/*----------------------------------------------------------------------------*/
PCIlist *LSTcat( l1, l2 )	PCIlist *l1, *l2 ; {

/* -- Concatenates l1 and l2 into l1, returns l1 and FREES l2.
      NOTE : arguments start at index 1 ( 0 is reserved for function ).
   -- */

		short *p1, *p2, *stop ; Ushort size ;

  size = ( l1->num / LISTBUNCH + ( l1->num % LISTBUNCH != 0 ) ) * LISTBUNCH ;
  if( l1->num + l2->num - 1 > size ) {
#if DEBUG
  printf( "LSTcat : l1->num %d l2->num %d size %d\n", l1->num, l2->num, size ) ;
#endif
  	while( size <= l1->num + l2->num - 1 ) size += LISTBUNCH	;
  	if( size > MAXELTS ) l1 = NULL ;
  	else if( REALLOC( l1->elt.Auto, size, short ) == NULL )
  		ERRmem( "parameter list" ) ;
  }
  	
  if( l1 != NULL ) {
  	p1	= &l1->elt.Auto[l1->num]	;
  	stop	= &l2->elt.Auto[l2->num]	;
  	p2	= &l2->elt.Auto[1]		;
  	while( p2 < stop ) *p1++ = *p2++ ;
  	l1->num += l2->num - 1   ;
  	if( l2->free && l2->num ) free( (char *) l2->elt.Auto ) ;
  	free( (char *) l2 ) ;
  }
  
  return l1 ;

} /* LSTcat */
/*----------------------------------------------------------------------------*/
void CTXdefault( T, C )	PCItype *T	; PCIcontext *C ; {

/* -- Generates a default context for a declaration: static, global, normal use
      and not a reference.
   -- */
     C->loc = cxGLOBL 	;
     C->sto = cxSTATC 	;
     C->use = cxNORML 	;
     C->ref = FALSE   	;
     if( T != NULL ) C->typ = *T ;
}
/*----------------------------------------------------------------------------*/
