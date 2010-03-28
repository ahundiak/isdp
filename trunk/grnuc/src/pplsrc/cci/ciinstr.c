#include "pci.h"
#include "pcidef.h"
#include "pcimacros.h"
#include "cidef.h"
#include "citypedef.h"
#include "ciy.h"
#include <string.h>
#include <malloc.h>
#define DEBUG 0
/*----------------------------------------------------------------------------*/
static unsigned ins__size = INSQUANTUM,
		ins__text = TXTQUANTUM ;

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

static int INStextalloc __((void));
static int INSalloc __((void));

#if defined(__cplusplus)
}
#endif
#undef __


/*----------------------------------------------------------------------------*/
void INSreset() { ins__size = INSQUANTUM ; ins__text = TXTQUANTUM ; }
/*----------------------------------------------------------------------------*/
static int INStextalloc() {
	int rc = TRUE ; short *oldtext, *newtext ; int i ;

 ins__text += TXTQUANTUM ;
 oldtext = newtext = PCIcode[0].paramlist ;
#if DEBUG
  printf( "INStextalloc: new text size %u oldtext %u\n", ins__text, oldtext ) ;
#endif
 if( REALLOC( newtext, ins__text, short ) == NULL ) 
	rc = ERRmem( "text segment" ) ;
 else {
 	PCIseg.text = newtext + ( PCIseg.text - oldtext ) ;
 	for( i = 0 ; i < PCInins ; i++ ) {
 		PCIcode[i].paramlist = newtext +
 					( PCIcode[i].paramlist - oldtext ) ;
 	}
 }
#if DEBUG
  printf( "INStextalloc: PCIcode[0].paramlist %u\n", PCIcode[0].paramlist ) ;
#endif
 return rc ;
}
/*----------------------------------------------------------------------------*/
static int INSalloc() {
	int rc = TRUE ;

 ins__size += INSQUANTUM ;
#if DEBUG
  printf( "INSalloc: new instruction size %u\n", ins__size ) ;
#endif
 if( REALLOC( PCIcode, ins__size, struct ci_instruction ) == NULL ) 
	rc = ERRmem( "instruction" ) ;
 return rc ;
}
/*----------------------------------------------------------------------------*/
int genins( type, args )	int	type	;	/* Input */
				PCIlist	*args	;	/* Input */ {

/* --
   NOTE : the last parameter contains the line number in the source file and is
   not taken into account in `num'.
   The number of instructions is incremented.
   -- */

    register int          i		;
    struct ci_instruction *ins		;
    int			  rc = TRUE	;
    short	  	  *list		;

 if( !PCIgen ) return TRUE ;
 
#if DEBUG
   printf( "genins : ENTER instr no %d type %d PCIseg.text %u\n", PCInins,
   		type, PCIseg.text ) ;
#endif
 if( PCInins >= ins__size ) rc = INSalloc() ;
 if( rc ) {
   if( ( PCIseg.text + ( args->num + 1 ) ) - PCIcode[0].paramlist >= ins__text )
	rc = INStextalloc() ;
   if( rc ) {
    		ins		= PCIcode + PCInins	;
		ins->type	= type			;
		ins->nbparam	= args->num		;
		ins->paramlist	= PCIseg.text		;
		list = args->free ? args->elt.Auto : args->elt.Stat ;
		for( i = 0 ; i < args->num ; i++ )
			ins->paramlist[i] = list[i] ;
		ins->paramlist[ins->nbparam] = PCI_Get_current_line() ;
		PCIseg.text += ( args->num + 1 ) ;
		PCInins++ ;
   }
 }
#if DEBUG
   printf( "genins : EXIT( %d ) PCIseg.text %u\n", rc, PCIseg.text ) ;
#endif
    return rc ;

} /* genins */
/*----------------------------------------------------------------------------*/
int gen( type, npm, pm0, pm1, pm2, pm3 )

/* VARARGS */
int   type,  pm0, pm1, pm2, pm3 ;
short npm ;

{ PCIlist args ; int rc ;

  args.free = FALSE ;
  switch( args.num = npm ) {
  	default: cibugchk( "gen", "Too many parameters" ) ; break ;
  	case 4 : args.elt.Stat[3] = (short) pm3 ;
  	case 3 : args.elt.Stat[2] = (short) pm2 ;
  	case 2 : args.elt.Stat[1] = (short) pm1 ;
  	case 1 : args.elt.Stat[0] = (short) pm0 ;
  	case 0 : break ;
  }
  rc = genins( type, &args ) ;
#if DEBUG
   printf( "gen : EXIT( %d )\n", rc ) ;
#endif

  return rc ;

} /* gen */
/*----------------------------------------------------------------------------*/
int INSjmp( lab, typ, val )	char	*lab	;
				int	typ,
					val	; {

/* -- Generates a branch instruction.
      INPUT  : lab, typ, name and type of label to branch to.
               val, type of branch:
               		- jmpGOTO inconditional jump to a label.
               		- jmpFUNC jump to a function.
               		- >= 0    conditional branch tested on the variable
               		          at index val.
      RETURNS: TRUE or FALSE.
   -- */

	  	int		type, rc = TRUE	;
		PCIlist		args	 	;
  		extern OPERATOR	OPinfo[]	;
  		PCItype		*pTYPbasic()	;
#if DEBUG
	printf( "INSjmp : lab <%s>\n", lab ) ;
#endif
    args.free = FALSE ;
    switch( val ) {
    	case jmpGOTO	: type			= BRANCH	;
        	  	  args.num		= 1		; break ;
        case jmpFUNC	: type			= BRANCHFUNC	;
        	  	  args.num		= 1		; break ;
        default		: type			= IBRANCHCOND	;
       			  args.num		= 2		;
       			  if( isdouble( val ) ) {
       			  	type = DBRANCHCOND ;
       			  } if( !isword( val ) ) {
       			  	rc = ( val = CVTtoint( val ) ) != EMPTY ;
       			  }
        		  args.elt.Stat[1]	= val		;
    }
    
     rc = rc && ( args.elt.Stat[0] = (short) mkLAB( lab, typ, EMPTY ) ) != EMPTY
    	     && genins( type, &args ) ;
 
#if DEBUG
   printf( "INSjmp : EXIT( %d )\n", rc ) ;
#endif
    return rc ;

} /* INSjmp */
/*----------------------------------------------------------------------------*/
int ARRcpy( to, from ) int to, from ; {

	unsigned	TYPsizeof() 	;
	void		TYPeq()		;
	PCItype		*eq		;

	eq = pPCIdef( from )		;
	TYPeq( &eq, (PCItype **) NULL ) ;
	return gen( MEMCPY, 3, to, from, eq->Dim * TYPsizeof( eq ) ) ;
}
/*----------------------------------------------------------------------------*/
int INSpush( args )	PCIlist *args ; {

/* -- Pushes the argument list onto the stack in REVERSE order.
      NOTE: arguments are at positions 1 through args->num - 1.
   -- */
      	short *list ; int u, val, rc, size ; unsigned VARsizeof() ;

	list = args->elt.Auto ;
	rc = TRUE ;

#if DEBUG
  printf( "INSpush: num %d args %u\n", args->num - 1, args ) ;
#endif
	if( args->num <= 1 ) {
  		ERRsyn( "no value(s) specified for push", NULL ) ;
	} else {
		for( u = args->num - 1 ; u > 0 ; u-- ) {
			val = list[u] ;
			if( isarray( val ) ) {
#if DEBUG
  printf( "INSpush: array <%s>\n", PCIvar( val ) ) ;
#endif
	   			if( !( rc = gen( PUSHADR, 1, val ) ) ) break ;
			} else {
#if DEBUG
  printf( "INSpush: variable <%s>\n", PCIvar( val ) ) ;
#endif
	   			size = VARsizeof( val ) ;
	   			if( !( rc = gen( PUSHVAL, 3, val,
	   		                         size, GAP( size ) ) ) ) break ;
			}
		}
	}
  	free( (char *) args->elt.Auto ) ;
  	free( (char *) args ) ;
#if DEBUG
  printf( "INSpush: EXIT(%d)\n", rc ) ;
#endif
  	return rc ;
}
/*----------------------------------------------------------------------------*/
		
