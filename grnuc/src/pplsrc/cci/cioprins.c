/* This file NOT YET READY */
#if 0
#include "pci.h"
#include "pcidef.h"
#include "pcimacros.h"
#include "cidef.h"
#include "citypedef.h"
#include <string.h>
#define DEBUG 0
/*----------------------------------------------------------------------------*/
extern unsigned VARsizeof()	;
extern void	TYPeq()		;
/*-TYPEDEFS-------------------------------------------------------------------*/
/* -- Register type double, int or address.
   -- */
typedef enum { ADR = 0, INT = 1, DBL = 2 } regtype ;

/* -- Register : type and number.
   -- */
typedef struct {
		Ushort type:2 ;
		Ushort num :6 ;
} regis ;		    
/*-STATIC-GLOBALS-------------------------------------------------------------*/
/* -- Register stack: increment counters for int, double and addr regs.
      index of top-of-stack ( curt ).
   -- */
static regis ins$stck[50] 		;
static char  ins$count[3], ins$curt	;
/*----------------------------------------------------------------------------*/
regtype __t ;
#define REG(U) ( ( __t = (regtype) ins$stck[U].type ) == INT ?\
						     'i' : __t == ADR ?\
						     'u' : \
						     'd' )
#define NUM(i) ins$stck[i].num
/* -- Swap top of stack and the one underneath.
   -- */
#define SWAP	{ regis top ;						\
		  top			= ins$stck[ins$curt  ]	;	\
		  ins$stck[ins$curt]	= ins$stck[ins$curt-1]	;	\
		  ins$stck[ins$curt-1]	= top			;	\
		}

/* -- Pop top of stack.
   -- */
#define POP	ins$count[ins$stck[ins$curt--].type]--
/*----------------------------------------------------------------------------*/
void INSinit() {
  ins$curt = ins$count[ADR] = ins$count[INT] = ins$count[DBL] = -1 ;
}
/*----------------------------------------------------------------------------*/
int INSloadR( size, sign ) unsigned size, sign ; {

/* -- Loads the value the address of which is contained in the top-of-stack
      register into another register chosen with `sign' & `size'.
   -- */
    char r, save ; int i ;
   
    switch( size ) {
    	case sizeof( char	) :
    	case sizeof( short	) :
    	case sizeof( long	) : if( sign ) { r = 'i' ; i = INT ; }
    	         		    else       { r = 'u' ; i = ADR ; } break ;
    	case sizeof( double	) : r = 'd' ; i = DBL ;
    }

    save = ins$stck[ins$curt].num ;
    if( i != ADR ) {
/* -- Pop address register, pull new register ( int or double )
   -- */
    	 ins$stck[ins$curt].num = ++ins$count[i] ; }
/* -- Address register : we already have one... ( pop + pull = do nothing )
   -- */
    
    printf( "LOADR\tu%d,\t%c%d\n", save, r, ins$stck[ins$curt].num ) ;

}
/*----------------------------------------------------------------------------*/
int INSloadV( var ) Ushort var ; {

/* -- Loads variable `var' into a register.
   -- */
    char r ; regtype i ; register regis *reg ; unsigned s ;

    switch( s = VARsizeof( (int) var ) ) {
    	case sizeof( char	) :
    	case sizeof( short	) :
    	case sizeof( long	) : if( isptreq( var ) ) { r = 'u' ; i = ADR ; }
    				    else		 { r = 'i' ; i = INT ; }
    				    break ;
    	case sizeof( double	) : r = 'd' ; i = DBL ;
    }
    ins$curt++ ;
    reg = ins$stck + ins$curt ;
    reg->num = ++ins$count[reg->type = i] ;

    printf( "%dLOADV\t%s,\t%c%d\n", s, PCIvar( var ), r, reg->num ) ;
}
/*----------------------------------------------------------------------------*/
int INSladrV( var ) Ushort var ; {

/* -- Loads variable address into register.
   -- */
  register regis *reg ;

  ins$curt++ ;
  reg = ins$stck + ins$curt ;
  reg->num = ++ins$count[reg->type = ADR] ;

  printf( "LADRV\t%s,\tu%d\n", PCIvar( var ), reg->num ) ;

}
/*----------------------------------------------------------------------------*/
int INSladrR() {

/* -- Loads the address of the top-of-stack register into an address register.
   -- */
  char			r, ireg ; 
  register regis	*reg	;

  ireg = ins$curt++ ;
  reg = ins$stck + ins$curt ;
  reg->num = ++ins$count[reg->type = ADR] ;

  switch( ins$stck[ireg].type ) {
  	case ADR : r = 'u' ; break ;
  	case INT : r = 'i' ; break ;
  	case DBL : r = 'd' ; break ;
  }  
  printf( "LADRR\t%c%d,\tu%d\n", r, ins$stck[ireg].num, reg->num ) ;
}
/*----------------------------------------------------------------------------*/
int INScadd( const ) unsigned const ; {

/* -- Adds a constant to the register on top of the stack.
   -- */

   char r ;

   printf( "CADD\t%u,\t%c%d\n", const, REG(ins$curt), NUM(ins$curt) ) ;
}
/*----------------------------------------------------------------------------*/
int INScopyVR( to ) Ushort to ; {

  printf( "COPYVR%u\t%c%d,\t%s\n", VARsizeof( to ), REG(ins$curt), NUM(ins$curt), PCIvar( to ) ) ;
}
/*----------------------------------------------------------------------------*/
int INScopyrA( to, size ) unsigned size ; {
	
/* -- Copies variable at index `to' into into memory pointed to by TOS register
   -- using `to''s address.
   -- */
  printf( "COPYrA\t%s,%c%d,\t%u\n", PCIvar( to ), REG(ins$curt),
                                    NUM(ins$curt), size ) ;
}
/*----------------------------------------------------------------------------*/
int INScopyrR( size ) unsigned size ; {

/* -- Copies content of TOS register into memory pointed to by TOS-1 register.
   -- */
  printf( "COPYrR%u\t%c%d,\t%c%d\t\n", size, REG(ins$curt), NUM(ins$curt),
          REG(ins$curt-1), NUM(ins$curt-1) ) ;
  SWAP ; POP ;
}
/*----------------------------------------------------------------------------*/
int INScopyrr( size ) unsigned size ; {

/* -- Copies memory pointed to by TOS register into memory pointed to by TOS-1
      register.
   -- */
  printf( "COPYrr\t%c%d,\t%c%d\t, %u\n", REG(ins$curt), NUM(ins$curt),
          REG(ins$curt-1), NUM(ins$curt-1), size ) ;
}
/*----------------------------------------------------------------------------*/
int INSbop( op ) char *op ; {

  char r1, r0, s ; regis *reg ;

/* -- OP r1, r0 ==> ri = r1 OP r0
      ri is r0 or r1 according to type conversions.
      if swap[r0][r1] is TRUE, ri = r1 and the top of the stack and top - 1 must
      be swapped, since the top is poped out.
   -- */
  static char swap[3][3] = {
	/* r0 \	r1	ADR	INT	DBL	*/
	/* ADR */ {	FALSE,	FALSE,	FALSE },
	/* INT */ {	TRUE ,	FALSE,  TRUE  },
	/* DBL */ {	TRUE ,  FALSE,	FALSE }
  } ;

  reg = ins$stck + ins$curt ;

  switch( reg->type ) {
  	case ADR : r1 = 'u' ; break ;
  	case INT : r1 = 'i' ; break ;
  	case DBL : r1 = 'd' ; break ;
  }  
  switch( (reg-1)->type ) {
  	case ADR : r0 = 'u' ; break ;
  	case INT : r0 = 'i' ; break ;
  	case DBL : r0 = 'd' ; break ;
  }
/* r0 int, r1 double | r0 int, r1 address | r0 : double, r1 address -> swap */ 
  s = swap[(reg-1)->type][reg->type] ;

  printf( "BOP%c%s\t%c%d,\t%c%d\n", s ? 'r' : 'l',
          op, r1, reg->num, r0, (reg-1)->num ) ;

  if( s ) { regis top ; top = *reg ; *reg = *(reg-1) ; *(reg-1) = top ; }

/* -- Pop.
   -- */
   ins$count[ins$stck[ins$curt--].type]-- ;

}
/*----------------------------------------------------------------------------*/
int INSuop( op ) char *op ; {

  char r0 ; regis *reg ;

  reg = ins$stck + ins$curt ;

  switch( reg->type ) {
  	case ADR : r0 = 'u' ; break ;
  	case INT : r0 = 'i' ; break ;
  	case DBL : r0 = 'd' ; break ;
  }  
  printf( "UOP%s\t%c%d\n", op, r0, reg->num ) ;

}
/*----------------------------------------------------------------------------*/

#endif
