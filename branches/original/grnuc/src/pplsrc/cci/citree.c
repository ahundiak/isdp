/* -- This module creates a syntactic tree for an expression, this tree is then
      explored in  search of illegal operations ( addresses  of constants,  bad
      lvalues, etc. )
   -- */
#include "pci.h"
#include "pcidef.h"
#include "pcimacros.h"
#include "cidef.h"
#include "citypedef.h"
#include "ciy.h"
/*-DEFINES--------------------------------------------------------------------*/
/* -- Null tree branch.
   -- */
#define NIL	BYTEMASK
#define DEBUG	0
#define OPNAME(o) ((o) < _CONTINUE ? OPinfo[o].name : (o) == '@' ? "()" : "?")
/*-EXTERNS--------------------------------------------------------------------*/
extern OPERATOR OPinfo[] ;
/*-TYPEDEFS-------------------------------------------------------------------*/
/* -- Node index.
   -- */
typedef Uchar inode ;

/* -- Binary tree : node, right and left branches:
      `next' is the ancestor of a node, its main use will, when the current node
      is an operator to acceed to the next operator, hence the name.
				       next
					/
					o
				      /   \
				   left  right

   -- */
typedef struct {	
         PCInode	node			;
	 inode		next, left, right	;
	 char		visit			;
} tree ;

/*-STATIC-GLOBALS-------------------------------------------------------------*/
/* -- Syntactic tree for expression and current node index.
   -- */
static tree	tr__syn[MAXNODE]	;
static inode	tr__node		;

/* -- Flags whether tree was initialized.
   -- */
static char tr__init = FALSE ;

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

static void NODtree __((void));
static int islvalue __((tree *T));

#if defined(__cplusplus)
}
#endif
#undef __


/*-MACROS---------------------------------------------------------------------*/
/* -- Shorter forms.
   -- */
#define TYPE		node.type
#define CODE		node.info.operator.symbol.code
#define INST		node.info.operator.symbol.instr
#define RSLT		node.info.operator.result
#define IVAR		node.info.operand
#define OFFS		node.info.field.offset
#define SIZE		node.info.field.size
#define ALGN		node.info.field.align
#define SIGN		node.info.field.signed
#define LTOR( n )	( OPinfo[(n)->CODE].assoc == LtoR )
/*----------------------------------------------------------------------------*/
void NODreset() { tr__init = FALSE ; }
/*----------------------------------------------------------------------------*/
void NODinit() {

/* -- Must be called before any invocation to `mkNOD' to start a new tree.
   -- */

#if DEBUG
  printf( "NODinit %d\n", tr__init ) ; fflush( stdout ) ;
#endif
  if( !tr__init ) { tr__node = 0 ; tr__init = TRUE ; }

} /* NODinit */
/*----------------------------------------------------------------------------*/
int mkNOD( N ) PCInode *N ; {

/* -- Builds a tree node : fills array cell, increments node counter.
   -- */
  tree *new ; int rc = TRUE ;

  new		= tr__syn + tr__node	;
  new->node	= *N			;
  new->left	= NIL			;
  new->right	= NIL			;
  new->visit	= 0			;

#if DEBUG
  printf( "mkNOD :" ) ;
  printf( " <%s>(%d)\n", new->TYPE == OPERAND ? PCIvar( new->IVAR ) 
                                              : OPNAME( new->CODE ), tr__node ) ;
#endif
  if( ++tr__node >= MAXNODE ) rc = ERRsyn( "expression too big", NULL ) ;

  return rc ;

} /* mkNOD */
/*----------------------------------------------------------------------------*/
static void NODtree() {

/* -- Actually builds the tree. Reads node array and links nodes with ancestors
      using a stack.
   -- */

#define INIT				top = 0
#define PUSH( n )			stack[top++] = (n)
#define PULL()				stack[--top]

	tree	*stack[MAXNODE], *T ;
  	inode	top, root, *curbranch ;

#if DEBUG
  printf( "NODtree : tree is " ) ;
  {  int i ;
  for( i = 0 ; i < tr__node ; i++ )
    switch( tr__syn[i].TYPE ) {
    	case OPERAND	:  printf( "%s ", PCIvar( tr__syn[i].IVAR ) ) ; break ;
    	case UNARY   	:
    	case BINARY	:  printf( "%s ", OPNAME( tr__syn[i].CODE ) ) ; break ;
    	case OFFSET	:  printf( "%d ", tr__syn[i].OFFS )	     ; break ;
     }
  }
  printf( "\n" ) ; fflush( stdout ) ;
#endif

  INIT ; root = --tr__node ; curbranch = NULL ; tr__syn[root].next = NIL ;

  do {  if( curbranch != NULL ) {
  		*curbranch		= tr__node	;
  		tr__syn[tr__node].next	= T - tr__syn	; /* T assigned below */
  	}
#if DEBUG
	printf( "NODtree, curnode = %d TYPE %d ", tr__node, tr__syn[tr__node].TYPE ) ;
    switch( tr__syn[tr__node].TYPE ) {
    	case OPERAND	:  printf( "%s\n", PCIvar( tr__syn[tr__node].IVAR ) ) ; break ;
    	case UNARY   	:
    	case BINARY	:  printf( "%s\n", OPNAME( tr__syn[tr__node].CODE ) ) ; break ;
    	case OFFSET	:  printf( "%d\n", tr__syn[tr__node].OFFS )	   ; break ;
     }
#endif
  	switch( ( T = &tr__syn[tr__node] )->TYPE ) {
  		case BINARY	: curbranch = &T->right ;
				  PUSH( T )		;
  				  break ;
  		case UNARY	: curbranch = &T->right ;
  				  T->left   = NIL 	;
  				  break ;
  		case OFFSET	:
  		case OPERAND	: T->right  = NIL	;
  				  T->left   = NIL	;
  				  T         = PULL()	;
  				  curbranch = &T->left	;
  				  break ;
  		default		: cibugchk( "NODtree", "unknown node type" ) ;
  	}
  } while( tr__node-- ) ;

  tr__node = root ;

#if DEBUG
	printf( "NODtree EXIT, curnode = %d\n", tr__node ) ;
#endif

} /* NODtree */
/*----------------------------------------------------------------------------*/
static int islvalue( T ) tree *T ; {

/* -- Decides if node at address `T' is a left value.
   -- */

 int rc ;

#if DEBUG
    switch( T->TYPE ) {
    	case OPERAND	:  printf( "-- %s\n", PCIvar( T->IVAR ) ) ; break ;
    	case UNARY   	:
    	case BINARY	:  printf( "-- %s\n", OPNAME( T->CODE ) ) ; break ;
    	case OFFSET	:  printf( "-- %d\n", T->OFFS )	     ; break ;
     }
#endif

  switch( T->TYPE ) {
  	case OPERAND : rc = !(    isconst   ( T->IVAR )
  	                       || isarray   ( T->IVAR )
  	                       || isfunction( T->IVAR ) )	; break ;
  	case BINARY  : rc =    T->CODE == _BRA
  	                    || T->CODE == _DOT
  	                    || T->CODE == _ARROW		; break ;
  	case UNARY   : rc = T->CODE == _IND			; break ;
  }
  return rc ;
}
/*----------------------------------------------------------------------------*/
int NODwalk( i_root ) inode i_root ; {

/* -- Walks down the tree checking that the expression's semantic is correct.
      Sees that left hand-sides be left values.
      INPUT  : i_root, index of root of tree.
      RETURNS: TRUE if walking successful else FALSE.
   -- */
  int rc ; register tree *R ;

#if DEBUG
   if( i_root != NIL ) {  R = &tr__syn[i_root] ;
   	printf( "NODwalk: i_root %d TYPE %d ", i_root, R->TYPE ) ;
    switch( R->TYPE ) {
    	case OPERAND	:  printf( "-- %s\n", PCIvar( R->IVAR ) ) ; break ;
    	case UNARY   	:
    	case BINARY	:  printf( "-- %d, %s\n", R->CODE, OPNAME( R->CODE ) ) ; break ;
    	case OFFSET	:  printf( "-- %d\n", R->OFFS )	     ; break ;
     }
  }
#endif
  if( i_root != NIL )
    switch( ( R = &tr__syn[i_root] )->TYPE ) {
       case BINARY  : rc = R->CODE == _ASSIGN ? islvalue( &tr__syn[R->left] )
                                              : TRUE ;
  		      if( rc ) rc = NODwalk( R->left ) && NODwalk( R->right );
  		      else ERRsyn( "not an lvalue", NULL ) ;
  		      break ;

       case UNARY   : rc = R->CODE == _ADDR   ? islvalue( &tr__syn[R->right] )
                                              : TRUE ;
  		      if( rc ) rc = NODwalk( R->right ) ;
  		      else ERRsyn( "cannot take the address of this object",
  		                     NULL ) ;
  		      break ;

       case OFFSET  :
       case OPERAND : rc = TRUE ;
  		      break ;

       default	    : rc = cibugchk( "NODwalk", "unknown node type" ) ;

    }
  else rc = TRUE ;

  return rc ;

} /* NODwalk */
/*----------------------------------------------------------------------------*/
int NODcheck() {

/* -- Builds syntactic tree then walks it.
   -- */
	int rc ;

	tr__init = FALSE ;
	if( tr__node != 0 ) {
		NODtree() ;
/* FUTURE BIG ENHANCEMENT : THE CODE RELATED TO THIS PART IS NOT YET READY
		NODinstr() ;
*/ 
#if DEBUG
	 { void NODprint(); NODprint( tr__node )	; }
	 printf( "NODcheck : start walking tree\n" ) ;
#endif
	 	rc = NODwalk( tr__node )	;
#if DEBUG
	 printf( "NODcheck : end walking tree, rc = %d\n", rc ) ;
#endif
	} else rc = TRUE ;
	return rc ;

} /* NODcheck */
/*----------------------------------------------------------------------------*/
void NODprint( n ) inode n ; {

/* -- Prints the tree. Debugging purposes only !
   -- */
  register tree *T ;

  if( n != NIL ) {
    T = tr__syn + n ;
    switch( T->TYPE ) {
       case OPERAND : printf( "node %d:\t%s\n", n, PCIvar( T->IVAR ) ) ; break ;
       case UNARY   :
       case BINARY  : printf( "node %d:\t%s\n", n, OPNAME( T->CODE ) ) ; break ;
       case OFFSET  : printf( "node %d:\t%d\n", n, T->OFFS           ) ; break ;
    }
    if( T->left != NIL ) {
		printf( "\tLeft  of #%d\n", n ) ;
		NODprint( T->left  )  ;
    }
    if( T->right != NIL ) {
		printf( "\tRight of #%d\n", n ) ;
		NODprint( T->right )  ;
    }
  }

} /* NODprint */
/*----------------------------------------------------------------------------*/
/* -- The assignment operator accepts all types of operands
      Its LHS may be an Lvalue, a variable, its RHS a variable, an expression.
      In the  case  of  arrays or  structure, their  addresses  are stored in
      register as well as  those of  structure/array Lvalues even if they are
      scalar:
      
      <struct>. ... .<field> = <exp> : the address of <field> is stored
      <tab>[ ... ]           = <exp> : the address of <tab>[ ... ] is  stored
      Of course their sizes must be known to perform the assignment, which is
      easily done with some tree walking, down from `=' :
      
     		 Left then Right		 Left then Left
			=				=
		      /   \			      /   \
		     .   <exp>                       []  <exp>
		    / \				    /  \
		  ...  <field>			 <tab> ...
      The case for copying the RHS into the LHS are :

      	var	= scalar variable,
      	reg	= register,
      	lvalue	= memory accessed through references ( *, ., ->, [] )
      	struct	= union or struct var

      	LHS		RHS	COPY	example
      	var		reg	VR	a = b + c ;
      	lvalue		reg	rR	*S1.f1[i].f2->f3 = b ;
      	lvalue		struct	rA	*S1.f1[i].f2->f3 = S2 ;
      	struct		struct	rA	S1 = S2 ; ( S1, S2 have same type )
      	struct		struct	rr	S1 = S2.S3 ; ( S1, S2.S3 have same type )
      	
VR = copy RHS into LHS using register to variable affectation
rR = copy RHS into LHS using LHS's address ( in a reg ), RHS reg ( "*reg = reg" )
rA = copy RHS into LHS using LHS's address ( in a reg ), RHS adr ( "*reg = *A" )
rr = copy RHS into LHS using LHS's and RHS's addresses ( "*reg = *reg" )

 -- */
#if 0
int NODassign( asg ) register tree *asg ; {

  char flag ; PCItype *T ; unsigned size ;

#define LVAR tr__syn[asg->left ].IVAR
#define RVAR tr__syn[asg->right].IVAR


  switch( tr__syn[asg->right].TYPE ) {
/* --	Load it into a register if it is scalar.
   -- */
  	case OPERAND	: if( isnumvalue( RVAR ) || isarray( RVAR ) ) {
  			 	INSloadV( RVAR ) ; flag = 'R' ;
  			  } else {/* INSladrV( RVAR ) ; */ flag = 'A' ; }
  			  break ;

/* -- 	All unary operators yield a scalar result which is in the TOS.
   -- */
   	case UNARY	: flag = 'R' ; break ;

/* --	If the  result of the binary  operator is scalar, then the value MUST be
	contained  in  a register  on the TOS, otherwise  it is a  structure the
	address of which is in the TOS register.
   -- */

  	case BINARY	: T = &tr__syn[asg->right].RSLT ;
  			  TYPeq( &T, (PCItype **) NULL ) ;
  			  flag = !( T->Def == BASIC || T->Ptr ) ? 'r' : 'R' ;
  			  break ; 

  	default		: cibugchk( "NODassign", "unknown right node type" ) ;

  } /* switch */

  switch( tr__syn[asg->left].TYPE ) {
/* -- If is is a non-scalar variable, load its address into a register.
   -- */
  	case OPERAND	: if( isnumvalue( LVAR ) || isarray( LVAR ) ) {
  				/* VR       */ INScopyVR( LVAR ) ;
  			  } else {
  				/* rr or rA */ INSladrV( LVAR  ) ;
  				               goto label	 ;
  			  }
	  		  break ;

/* -- 	A unary operator on the left of '=' can only be '*'.
   -- */
  	case UNARY	:

/* -- 	A binary operator on the left of '=' can only be '.', '->', '.', '[]'.
        The address of the reference memory region is in a register.
   -- */
  	case BINARY	: /* case r */
  		label :
  		size = TYPsizeof( &tr__syn[asg->left].RSLT ) ;
  		switch( flag ) {
  			case 'A' : /* rA */ INScopyrA( RVAR, size ) ; break ;
  			case 'R' : /* rR */ INScopyrR( size )	    ; break ;
  			case 'r' : /* rr */ INScopyrr( size )	    ; break ;
  		}
  		break ;

  	default		: cibugchk( "NODassign", "unknown left node type" ) ;
  }

/* -- In such cases as a = ( b = c ) + d, b needs to be loaded in a register for
      subsequent use by '+' ; this happens when '+' has an ancestor.
   -- */
  if( asg->next != NIL ) switch( flag ) {
  	case 'A' : INSladrV( LVAR ) ; break ;
	case 'V' : INSloadV( LVAR ) ; break ;
  }

}
/*----------------------------------------------------------------------------*/
int _NODinstr() {

/* -- Must be called after `NODtree'.
   -- */

  int		i		;
  unsigned	o = 0		;
  register tree *T, *last    	;
  void		INSinit()	;

/* -- Sugar macros : left and right nodes of node `T',
                     test if node is an operand ( arg ).
   -- */
#define LN		tr__syn[T->left ]
#define RN		tr__syn[T->right]
#define NX		tr__syn[T->next ]
#define ISARG( N )	( (N).TYPE == OPERAND )
#define ISNXT( O )	( T->next != NIL && NX.TYPE == BINARY \
				         && NX.CODE == (O)    )

  for( i = 0 ; i <= tr__node ; i++ ) {
    switch( tr__syn[i].TYPE ) {
      case OPERAND : printf( "%s ", PCIvar( tr__syn[i].IVAR ) ) ; break ;
      case UNARY   :
      case BINARY  : printf( "%s ", OPNAME( tr__syn[i].CODE ) ) ; break ;
      case OFFSET  : printf( "%d ",         tr__syn[i].OFFS   ) ; break ;
    }
  } printf( "\n" ) ;

  last = ( T = tr__syn ) + tr__node ; INSinit() ;

  for( ; T <= last ; T++ ) {
    switch( T->TYPE ) {
    case OPERAND	: break ;

    case UNARY	: INSloadV( RN.IVAR ) ;
    		  INSuop( OPNAME( T->CODE ) ) ;
    		  break ;

    case BINARY	:
    	switch( T->CODE ) {
    	    case _ARROW	: if( ISARG( LN ) ) INSloadV( LN.IVAR ) ;
    	    		  goto field ;

      	    case _DOT	: if( ISARG( LN ) ) INSladrV( LN.IVAR ) ;
    	    		  field :
			  o += RN.OFFS ;
    	        	  if(    T+2 > last
    	            	      || (T+2)->TYPE != BINARY 
    	            	      || (T+2)->CODE != _DOT   ) {
    	            	  INScadd( o ) ;
	    	          o = 0 ;
/* --			  If field is scalar and not LHS of '=' load it into
			  register else its address ii already in register
   -- */
			  	if(    RN.SIZE <= sizeof( double ) 
			      	    && RN.SIZE % 2 == 0
			      	    && !ISNXT( _ASSIGN )   )         
    	    	      			INSloadR( RN.SIZE, RN.SIGN ) ;
	  	          }
	        	  break ;

	    case _ASSIGN: NODassign( T ) ;
			  break ;

	    default	: if( ISARG( LN ) ) INSloadV( LN.IVAR ) ;
			  if( ISARG( RN ) ) INSloadV( RN.IVAR ) ;
	    		  INSbop  ( OPNAME( T->CODE ) ) ;
			  break ;
	 }
	 break ;

    case OFFSET	: break ;
    }

  }
  	
} /* NODinstr */
/*----------------------------------------------------------------------------*/
int NODinstr() {

/* -- Must be called after `NODtree'. WILL HAVE TO TREAT OVERLOADING...
   -- */

  int		i		;
  unsigned	o = 0		;
  register tree *T, *last    	;
  inode		t		;
  void		INSinit()	;

/* -- Sugar macros : left and right nodes of node `T',
                     test if node is an operand ( arg ).
   -- */
#define LN		tr__syn[T->left ]
#define RN		tr__syn[T->right]
#define NX		tr__syn[T->next ]
#define ISARG( N )	( (N).TYPE == OPERAND )
#define ISNXT( O )	( T->next != NIL && NX.TYPE == BINARY \
				         && NX.CODE == (O)    )

  for( i = 0 ; i <= tr__node ; i++ ) {
    switch( tr__syn[i].TYPE ) {
      case OPERAND : printf( "%s ", PCIvar( tr__syn[i].IVAR ) ) ; break ;
      case UNARY   :
      case BINARY  : printf( "%s ", OPNAME( tr__syn[i].CODE ) ) ; break ;
      case OFFSET  : printf( "%d ",         tr__syn[i].OFFS   ) ; break ;
    }
  } printf( "\n" ) ;

  last = tr__syn + ( t = tr__node ) ; INSinit() ;

  do {
    T = tr__syn + t ;

    switch( T->TYPE ) {
    case UNARY	: switch( ++T->visit ) {
    			case 1 : t = LTOR( T ) ? T->left : T->right ; break ;
    			case 2 :
    			case 3 : INSloadV( RN.IVAR )		;
    		  		 INSuop( OPNAME( T->CODE ) )	;
    		  		 t = T->next			; break ;
		  }
    		  break ;

    case BINARY	: switch( ++T->visit ) {
    			case 1 : t = LTOR( T ) ? T->left  : T->right ; break ;
    			case 2 : t = LTOR( T ) ? T->right : T->left  ; break ;
    			case 3 :
    	switch( T->CODE ) {
    	    case _ARROW	: if( ISARG( LN ) ) INSloadV( LN.IVAR ) ;
    	    		  goto field ;

      	    case _DOT	: if( ISARG( LN ) ) INSladrV( LN.IVAR ) ;
    	    		  field :
			  o += RN.OFFS ;
    	        	  if(    T+2 > last
    	            	      || (T+2)->TYPE != BINARY 
    	            	      || (T+2)->CODE != _DOT   ) {
    	            	  INScadd( o ) ;
	    	          o = 0 ;
/* --			  If field is scalar and not LHS of '=' load it into
			  register else its address is already in register
   -- */
			  	if(    RN.SIZE <= sizeof( double ) 
			      	    && RN.SIZE % 2 == 0
			      	    && !ISNXT( _ASSIGN )   )         
    	    	      			INSloadR( RN.SIZE, RN.SIGN ) ;
	  	          }
	        	  break ;

	    case _ASSIGN: NODassign( T ) ;
			  break ;

	    default	: if( ISARG( LN ) ) INSloadV( LN.IVAR ) ;
			  if( ISARG( RN ) ) INSloadV( RN.IVAR ) ;
	    		  INSbop  ( OPNAME( T->CODE ) ) ;
			  break ;
	 }
	 t = T->next ; break ;
	 }
	 break ;

    case OPERAND:
    case OFFSET	: t = T->next ; break ;
    defautl	: cibugchk( "NODinstr", "unknown node type" ) ;
    }

  } while( t != NIL ) ;
  	
} /* NODinstr */
/*----------------------------------------------------------------------------*/
#endif
