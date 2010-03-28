/*-INCLUDES-------------------------------------------------------------------*/
#include <malloc.h>
#include <search.h>
#include <string.h>
#include "pcidef.h"
#include "pci.h"
#include "cichardef.h"
#include "pcimacros.h"
#include "cidef.h"
#include "citypedef.h"
#define DEBUG 0
#define MADE( x ) ( (x) != EMPTY )
/*----------------------------------------------------------------------------*/
typedef struct {
			int		indx ;
			PCIpointer	data ;
			char		type ;
} constant ;

/* -- Array  of  tree  nodes, root of  string  constants  tree, root  of  double
      constants tree .
   -- */
static constant		*cst__root_s = NULL,
		        *cst__root_d = NULL ;


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

#ifndef IRIX5
static int CSTcmp __((constant *cst1, constant *cst2));
#endif
static void CSTaction __((constant **node, VISIT order, int level));
static void CSTxreal __((double d, char *xr));
static void CSTprint __((constant **node, VISIT order, int level));

#if defined(__cplusplus)
}
#endif
#undef __


/*----------------------------------------------------------------------------*/
#ifdef IRIX5
static int CSTcmp(const void *dummy1, const void *dummy2)
{
	constant *cst1 = (constant *)dummy1;
	constant *cst2 = (constant *)dummy2;
#else
static int CSTcmp( cst1, cst2 )

constant *cst1, *cst2 ;

{
#endif

#define CMP( x, y ) ( (x) < (y) ? -1 : (x) == (y) ? 0 : 1 )
#if DEBUG
  printf( "CSTcmp : <%s> =? <%s>\n", cst1->data.Chr, cst2->data.Chr ) ;
#endif
  return cst1->type == CI_DOUBLE ? CMP( *cst1->data.Dbl, *cst2->data.Dbl )
				 : strcmp( cst1->data.Chr, cst2->data.Chr ) ;
}
/*----------------------------------------------------------------------------*/
int CSTfind( type, data )

char		type	;
PCIpointer	data	;


{ constant item, **found, **rootp ;
#if !defined(SUNOS5) && !defined(IRIX5)
 char *tfind() ;
#endif

#if DEBUG
  printf( "CSTfind : <%s>\n", data.Str->text ) ;
#endif
 switch( item.type = type ) {
 	case CI_DOUBLE : item.data	= data		;
 			 rootp		= &cst__root_d	;
 			 break ;
 	case CI_STRING : item.data.Chr	= data.Str->text	;
			 rootp		= &cst__root_s		;
			 break ;
	}
 found = (constant **) tfind( (char * ) &item, (void **) rootp, CSTcmp ) ;
#if DEBUG
  printf( "CSTfind : found %d *found->indx %d\n", found, found?(*found)->indx:-1 ) ;
#endif
 return found == NULL ? EMPTY : (*found)->indx ;
 
} /* CSTfind */
/*----------------------------------------------------------------------------*/
int CSTenter( type, data, indx )

/* -- Enters a constant of type string or double in the table. Returns EMPTY if
      the table is full or memory allocation failure.
   -- */
   
char		type	;
PCIpointer	data	;
int		indx	;

{ constant *node, **rootp ; int i = EMPTY ;
#if !defined(SUNOS5) && !defined(IRIX5)
 char *tsearch() ;
#endif

#if DEBUG
  printf( "CSTenter : string <%s>\n", data.Chr ) ;
#endif
  if( MALLOC( node, 1, constant ) != NULL ) {
	node->type	= type	;
	node->data	= data	;
	node->indx	= indx	;
	rootp = type == CI_DOUBLE ? &cst__root_d : &cst__root_s	;
	tsearch( (char *) node, (void **) rootp, CSTcmp )	;
	i = indx	;
  }

#if DEBUG
  printf( "CSTenter : node %d type %d indx <%d>\n", node, node->type, node->indx);
#endif
  return i ;

} /* CSTenter */
/*----------------------------------------------------------------------------*/
static constant **rootp ;
/*----------------------------------------------------------------------------*/
/* ARGSUSED */
static void CSTaction( node, order, level )

constant	**node	;
VISIT		order	;
int		level	;

{
#if !defined(SUNOS5) && !defined(IRIX5)
 char *tdelete() ;
#endif

	if( order == endorder || order == leaf ) {
   		tdelete( (char *) *node, (void **)rootp, CSTcmp ) ;
		free( (char *) *node ) ;
	}
}
/*----------------------------------------------------------------------------*/
void CSTfree()

{ void twalk() ;

  rootp = &cst__root_s ;
  twalk( (void *) cst__root_s, (void (*)()) CSTaction ) ;
  rootp = &cst__root_d ;
  twalk( (void *) cst__root_d, (void (*)()) CSTaction ) ;
  
  cst__root_s	= NULL	;
  cst__root_d	= NULL	;

} /* CSTfree */
/*----------------------------------------------------------------------------*/
static FILE *Dump ;
/*----------------------------------------------------------------------------*/
static void CSTxreal( d, xr ) double d ; char *xr ; {

	Uchar *byte, i ;
	xr[0] = '0' ; xr[1] = 'r' ;
	byte = (Uchar *) &d ;
	for( i = 0 ; i < sizeof d ; i++ ) {
		sprintf( xr + (i+1)*2, "%02x", *byte ) ;
		byte++ ;
	}
	xr[2 + sizeof( double )*2 + 1] = EOSTR ;
}
/*----------------------------------------------------------------------------*/
/* ARGSUSED */
static void CSTprint( node, order, level )

constant	**node	;
VISIT		order	;
int		level	;

{ register char *c ; char xr[2 + sizeof( double )*2 + 1] ;

  if( order == postorder || order == leaf )
  switch( (*node)->type ) {
    case CI_DOUBLE : CSTxreal( *(*node)->data.Dbl, xr ) ;
    		     fprintf( Dump, "double\t%lf (%s)\n", *(*node)->data.Dbl,
    		                                         xr ) ;
                     break ;
    case CI_STRING : c = (*node)->data.Chr ;
    		     fprintf( Dump, "string\t\"" ) ;
    		     while( *c ) {
    		       switch( *c ) {
			 case NEWLINE	: fprintf( Dump, "\\n"	) ; break ;
			 case HTAB	: fprintf( Dump, "\\t"	) ; break ;
			 case VTAB	: fprintf( Dump, "\\v"	) ; break ;
			 case CR	: fprintf( Dump, "\\r"	) ; break ;
			 case FORMFEED	: fprintf( Dump, "\\f"	) ; break ;
			 case BACKSPACE	: fprintf( Dump, "\\b"	) ; break ;
			 default   	: fprintf( Dump, "%c",*c) ; break ;
		       }
		       c++ ;
		     }
    		     fprintf( Dump, "\" (length: %d)\n",
    		                    strlen((*node)->data.Chr )  ) ;
                     break ;
    default	   : fprintf( Dump, "-unknown-\n" ) ;
  }

} /* CSTprint */
/*----------------------------------------------------------------------------*/
void CSTdump( dump )

FILE *dump ;

{ void twalk() ;

  if( cst__root_s != NULL || cst__root_d != NULL ) {
    fprintf( dump, "\n\t\t\t\tSTRING/DOUBLE CONSTANTS\n\t\t\t\t-----------------------\n\n" ) ;
    Dump = dump ;
    rootp = &cst__root_s; twalk( (void *) cst__root_s, (void (*)()) CSTprint );
    rootp = &cst__root_d; twalk( (void *) cst__root_d, (void (*)()) CSTprint );
  }
}
/*----------------------------------------------------------------------------*/
int mkCST( type, value )

PCItype		*type	;
PCIpointer	value	;

/* --  Construction of a variable of the same type as the constant, to which the
       the value of the constant is assigned.
       INPUT  : type, constant's type ; value, pointer to constant's value.
       RETURNS: the variable index if OK, EMPTY otherwise.
       NOTE   : GRobj constants do not exist.
   -- */

#define ABS( u ) ( (u) < 0 ? -(u) : (u) )

{  int      	vi	;
   PCIident	varname	;
   PCIcontext	ctx	;
   PCIpointer	info, Nul, Dummy;
   emsg		err	;
   void		MKname(), CTXdefault() ;

  Nul.Any = NULL;
  CTXdefault( type, &ctx ) ;

  switch( info.Val = type->Num ) {

    case CI_INT		: MKname( CST, varname, info, value, Nul ) ;
	 		  if( MADE( vi = MKdcl( &ctx, varname ) ) )
	     		  	PCIint( vi ) = *value.Int ;
        		  break ;

    case CI_CHAR	: MKname( CST, varname, info, value, Nul ) ;
	 		  if( MADE( vi = MKdcl( &ctx, varname ) ) )
	    		  	PCIchr( vi ) = *value.Chr ;
         		  break ;

    case CI_DOUBLE	: if( ( vi = CSTfind( CI_DOUBLE, value ) ) == EMPTY ) {
				Dummy.Int = &PCInvar;
  				MKname( CST, varname, info, Dummy, Nul ) ;
	 		  	if( MADE( vi = MKdcl( &ctx, varname ) ) ) {
	      		  	   PCIdbl( vi ) = *value.Dbl ;
				   CSTenter( CI_DOUBLE, PCIadr( vi ), vi ) ;
				}
			  }
         		  break ;

    case CI_STRING	:
	 if( ( vi = CSTfind( CI_STRING, value ) ) == EMPTY ) {
		Dummy.Int = &PCInvar;
	 	MKname( CST, varname, info, Dummy, Nul ) ;
	 	ctx.typ.Dim = ABS( value.Str->length ) + 1 ;
	 	if( MADE( vi = MKdcl( &ctx, varname ) ) ) {
			strcpy( PCIval( vi ), value.Str->text ) ;
			CSTenter( CI_STRING, PCIadr( vi ), vi )	;
	 	}	       
	 }
	 if( value.Str->length > 0 ) free( value.Str->text ) ;
         break ;
    default		:
			sprintf( err, "invalid constant type: %d", type->Num ) ;
	 		cibugchk( "mkCST", err ) ;
    }
   return vi ;

} /* mkCST */
/*----------------------------------------------------------------------------*/
int mkCSTint( u )

int u ;

/* -- Constructs an integer constant of value `u'.
   -- */

{ PCItype *pTYPbasic() ; PCIpointer p ;

  return mkCST( pTYPbasic( CI_INT ), ( p.Int = &u, p ) ) ;

} /* mkCSTint */
/*----------------------------------------------------------------------------*/
