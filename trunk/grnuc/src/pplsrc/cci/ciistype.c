/* -- The above functions test the type of the variable at index `v' in the
      variable table.
      They return TRUE if the type is matched else FALSE.
      NOTE: Those functions contains and ( `||' ) and or ( `&&' ) operators 
      and rely on the fact that in C :
      			a || b ---> b not evaluated if a is TRUE
      			a && b ---> b not evaluated if a is FALSE
      The macros `eqv' and `att' overwrite their argument.
   -- */
/*----------------------------------------------------------------------------*/
#include "pcidef.h"
#include "pci.h"
#include "pcimacros.h"
#include "cichardef.h"
#include "cidef.h"
#include "citypedef.h"
#include <ctype.h>
/*----------------------------------------------------------------------------*/
extern void TYPeq() ;
/*-MACROS---------------------------------------------------------------------*/
#define HEADER( F )		int F( v ) int v ;
#define GETTYPE( type )		PCItype *type ; type = pPCIdef( v ) ;
#define TYPEQ( type )		( TYPeq( &type, (PCItype **) NULL ), type )

/* -- Gets the equivalent type if any.
   -- */
#define eqv( t )  ( (t)->Def == TYPDF ? (t) = TYPEQ( t ) : (t) )

/* -- Tests if type or its equivalent satisfy value `V' for attribute `A'.
   -- */
#define att( t, A, V )	(    (t)->A   == (V)				     \
                          || (t)->Def == TYPDF				     \
                             && ( (t) = TYPEQ( t ) )->A == (V) )
 
/* -- TRUE if the type is basic of type `b' ( b = CI_CHAR, SHORT, INT, DOUBLE )
   -- */
#define basic( t, b )	(		(t)->Def == BASIC && (t)->Num == (b) \
				&&	!(t)->Ptr	  && !(t)->Dim	     \
			)
/* -- TRUE if the type is equivalent to the basic type `b'.
   -- */
#define baseq( t, b )	(     (t)->Def == TYPDF				\
			   && ( (t) = TYPEQ( t ), basic( t, b ) )	\
			)
/*----------------------------------------------------------------------------*/
HEADER( isschar )

{ GETTYPE( T )

  return basic( T, CI_CHAR ) || baseq( T, CI_CHAR ) ;

}
/*----------------------------------------------------------------------------*/
HEADER( isshort )

{ GETTYPE( T )

  return basic( T, CI_SHORT ) || baseq( T, CI_SHORT ) ;

}
/*----------------------------------------------------------------------------*/
HEADER( isint )

{ GETTYPE( T )

  return basic( T, CI_INT ) || baseq( T, CI_INT ) ;

}
/*----------------------------------------------------------------------------*/
HEADER( isdouble )

{ GETTYPE( T )

  return basic( T, CI_DOUBLE ) || baseq( T, CI_DOUBLE ) ;

}
/*----------------------------------------------------------------------------*/
HEADER( isGRobj )

{ GETTYPE( T )

  return basic( T, CI_GROBJ ) || baseq( T, CI_GROBJ ) || isint( v ) ;

}
/*----------------------------------------------------------------------------*/
HEADER( ispointer )

{ GETTYPE( T )

  return T->Ptr || eqv( T )->Ptr ;
}
/*----------------------------------------------------------------------------*/
HEADER( isword )

/* -- TRUE if var v has the same size as a word ( int, pointer or GRobj )
   -- */

{ GETTYPE( T )

  return    (    att( T, Def, BASIC ) && ( 	   T->Num == CI_INT
						|| T->Num == CI_GROBJ
           					|| T->Num == CI_INTEGER
					  )
              || T->Ptr
            )
         && !T->Dim ;
}
/*----------------------------------------------------------------------------*/
HEADER( isstring )

/* -- Array of chars or pointer to char.
   --  */

{ GETTYPE( T )

  return		att( T, Def, BASIC )
  		&&	T->Num == CI_CHAR
  		&&	( T->Dim ? !T->Ptr : T->Ptr == 1 )
  		&&	!T->Fpt ;

}
/*----------------------------------------------------------------------------*/
HEADER( isarray )

{ GETTYPE( T ) ;

    return T->Dim || eqv( T )->Dim ;
}
/*----------------------------------------------------------------------------*/
HEADER( isnumvalue )

{ GETTYPE( T )

    return   (    att( T, Def, BASIC ) && (	   T->Num == CI_INT
           					|| T->Num == CI_DOUBLE
						|| T->Num == CI_SHORT
                        			|| T->Num == CI_CHAR
           					|| T->Num == CI_INTEGER
           					|| T->Num == CI_NUMERIC
                        	     	  )
		|| T->Ptr
		|| T->Def == ENUMT
	      ) 
	   && !T->Dim ;

} /* isnumvalue */
/*----------------------------------------------------------------------------*/
HEADER( isptreq )

/* -- Pointer equivalent types : pointer or array.
   -- */

{ GETTYPE( T )

  return T->Ptr || T->Dim || eqv( T )->Ptr || T->Dim ;
}
/*----------------------------------------------------------------------------*/
HEADER( isinteq )

/* -- Integer equivalent types : char, short, int or enum;
      but neither pointer or GRobj.
   -- */

{ GETTYPE( T )

  return    (	   att( T, Def, BASIC ) && ( 
  		   ( T->Num > CI_VOID && T->Num < CI_DOUBLE )
  		|| T->Def == CI_INTEGER ) || T->Def == ENUMT  )
  	 && !T->Ptr && !T->Dim ;
}
/*----------------------------------------------------------------------------*/
HEADER( isbsari )

/* -- Basic arithmetic types : char, short, int, double, enum.
   -- */

{ GETTYPE( T )

  return    (	   att( T, Def, BASIC ) && (
  		   ( T->Num > CI_VOID && T->Num <= CI_DOUBLE )
  		|| T->Num == CI_INTEGER || T->Num == CI_NUMERIC )
  		|| T->Def == ENUMT	
  	    )
         && !T->Ptr && !T->Dim ;
}
/*----------------------------------------------------------------------------*/
HEADER( isintvalue )

{ GETTYPE( T )

    return   (     att( T, Def, BASIC ) && (	   T->Num == CI_INT
						|| T->Num == CI_SHORT
                        			|| T->Num == CI_CHAR
           					|| T->Num == CI_INTEGER
                        	     	   )
		|| T->Ptr
		|| T->Def == ENUMT
	      )
	   && !T->Dim ;
} /* isintvalue */
/*----------------------------------------------------------------------------*/
HEADER( isstruct )

{ GETTYPE( T )

   return    (    T->Def        == STRUC || T->Def == UNION
               || eqv( T )->Def == STRUC || T->Def == UNION
   	     )
   	  && !T->Ptr && !T->Dim ;
}
/*----------------------------------------------------------------------------*/
HEADER( isscalar )

{ GETTYPE( T )
	return           T->Def == BASIC || T->Ptr || T->Def == ENUMT
	       || eqv( T )->Def == BASIC || T->Ptr || T->Def == ENUMT ;
}
/*----------------------------------------------------------------------------*/
HEADER( isfcnptr )

/* -- A pointer to  function ( "<type> (*pf)()" ) susceptible of being used in a
      call has Ptr set to 1.
   -- */

{ GETTYPE( T )

  return           T->Fpt == FCNPTR && T->Ptr == 1 && !T->Dim
         || eqv( T )->Fpt == FCNPTR && T->Ptr == 1 && !T->Dim ;
}
/*----------------------------------------------------------------------------*/
HEADER( isvoidptr )

/* -- A pointer to void ( "void *" ). Arrays of void do not exist.
   -- */

{ GETTYPE( T )

  return		att( T, Def, BASIC )
  		&&	T->Num == CI_VOID
  		&&	T->Ptr == 1
  		&&	!T->Fpt ;

}
/*----------------------------------------------------------------------------*/
HEADER( isvoid )

/* -- A pointer to void ( "void *" ). Arrays of void do not exist.
   -- */

{ GETTYPE( T )

  return		att( T, Def, BASIC )
  		&&	T->Num == CI_VOID
  		&&	!T->Ptr
  		&&	!T->Fpt ;

}
/*----------------------------------------------------------------------------*/
HEADER( isvoidfcn )

/* -- A pointer to void ( "void *" ). Arrays of void do not exist.
   -- */

{ GETTYPE( T )

  return		att( T, Def, BASIC )
  		&&	T->Num == CI_VOID
  		&&	!T->Ptr
  		&&	T->Fpt ;

}
/*----------------------------------------------------------------------------*/
HEADER( isfunction )

{
    return PCIsts( v ) & CI_FUNC ;
}
/*----------------------------------------------------------------------------*/
HEADER( isextern )

{
    return PCIsts( v ) & CI_XTRN ;
}
/*----------------------------------------------------------------------------*/
HEADER( isuser )

{
   return PCIsts( v ) & CI_USER ;
}
/*----------------------------------------------------------------------------*/
HEADER( isvar )

{
	return isidchar( PCIvar( v )[0] ) ;
}
/*----------------------------------------------------------------------------*/
HEADER( isconst )

{
   return PCIvar( v )[0] == CSTVAR ;
}
/*----------------------------------------------------------------------------*/
HEADER( isnull )

/* -- The constant `0' is an integer variable of name "#I0".
   -- */

{ char *c = PCIvar( v ) ;

  return *c == CSTVAR && *++c == 'I' && *++c == '0' && *++c == EOSTR ;
}
/*----------------------------------------------------------------------------*/

