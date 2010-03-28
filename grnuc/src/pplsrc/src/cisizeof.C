#define CCI	1
#include "cidef.h"
#include "citypedef.h"
#include "ciprivmacros.h"


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

static int size __((int t));

#if defined(__cplusplus)
}
#endif
#undef __



/*----------------------------------------------------------------------------*/
static int size( t )

int t ;

{ int s ;

  switch( t ) {
  	case CI_CHAR	: s = sizeof( char	) ; break ;
	case CI_SHORT	: s = sizeof( short	) ; break ;
  	case CI_GROBJ	:
  	case CI_INT	: s = sizeof( int	) ; break ;
  	case CI_DOUBLE	: s = sizeof( double	) ; break ;
  	default		: if( t & PTR ) 
  				s = sizeof( NULL ) ;
  			  else
	  			  fprintf( stderr, "CI size: unknown function type %d\n", t ) ;
  }
  return s ;
}
/*----------------------------------------------------------------------------*/
int CIsizeof( v, vval, c )

int			v 	;
char			**vval	;
struct instance_ci 	*c 	;

/* -- Returns size of variable at index v.
      The size of v is the difference between its address and the of the next
      variable which is not a internal pointer variable ( their names begin
      with '@' ). If v is the last variable, vartable[v+1] contains the next
      available address.
   -- */

#define MEMVAR( i ) (    c->vartable[i][0] == '@'		\
                      || c->varflagtable[i] & CI_XTRN )

{ int s, w, t ;

  t = c->vartypetable[v] ;

  if( c->vartable[v][0] == '@')
	s = atol( c->vartable[v] + 1 ) ;
  else if( t != CI_STRUCT ){
  	int dim = c->vardimtable[v];
	s = size( t );
  	if( dim > 0 )
  		s *= dim;
  } else {
 		w = v + 1 ;
  		while( w < c->nbvar && MEMVAR( w ) ) w++ ;
  		s = vval[w] - vval[v] ;
  }
  return s ;
}
/*----------------------------------------------------------------------------*/
int CIalign( v, c )

struct instance_ci 	*c 	;
int			v 	;

/* -- Returns the aligment of variable at  index v. The aligment is contained in
      the four leftmost bits of varflagtable. For registers ( '^' ) and external
      functions ( all of basic types ) use size.
   -- */

{  return ( c->vartable[v][0] == '^' || c->varflagtable[v] & CI_XTRN ) ? 
			  size( c->vartypetable[v] ) 
			: ( c->varflagtable[v] >> 4 ) ;
}
/*----------------------------------------------------------------------------*/
	
