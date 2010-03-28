#include <malloc.h>
#include <stdio.h>
#include "OMminimum.h"
#include "OMerrordef.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "ex.h"
#include "godef.h"
#include "codef.h"
#include "grerr.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "cidef.h"
#include "citypedef.h"
#include "ciprivmacros.h"
/*----------------------------------------------------------------------------*/
extern struct	instance_ci *ci_data	;
extern char	**ci_data_varvaltable	;
extern char	errmess[]		;
/*-ARGUMENT-STACK-------------------------------------------------------------*/
/* -- Pointer to bottom of stack
   -- */
static char	*STCbottom	= NULL	;
/* -- Current position on stack
   -- */
static char	*STCcurrent	= NULL	;
/* -- Current reading position
   -- */
static char	*STCreadptr	= NULL	;
/* -- Current size of stack in bytes.
     ( availabe space = STCsize - ( STCcurrent - STCbottom )
   -- */
static unsigned	STCsize		= 0	;
/*----------------------------------------------------------------------------*/
#define STCSIZE	1024
/*----------------------------------------------------------------------------*/
int STCalloc()

/* -- Increases stack space.
   -- */

{ char *oldbottom ;

  if( !STCsize ) {
  	 STCsize += STCSIZE ;
#ifdef DEBUG
  printf( "STCalloc: malloc %u bytes\n", STCsize ) ;
#endif
  	 STCcurrent = STCbottom = malloc( STCsize ) ;
  } else {
  	STCsize += STCSIZE ;
#ifdef DEBUG
  printf( "STCalloc: realloc %u bytes\n", STCsize ) ;
#endif
	oldbottom = STCbottom ;
  	STCbottom = realloc( STCbottom, STCsize ) ;
  	STCcurrent= STCbottom + ( STCcurrent - oldbottom ) ;
  }
  return STCbottom != NULL ;
}
/*----------------------------------------------------------------------------*/
int STCpushA( var ) 	int var ; {

/* -- Pushes the address of `var' onto the stack.
   -- */
   register char *p ; register int i ;

   if( ( STCcurrent - STCbottom ) + sizeof( void * ) >= STCsize )
  	if( !STCalloc() ) {
  		printf( "CI: cannot allocate %d bytes\n", STCsize ) ;
  		erreur( "cannot allocate function stack" ) ;
  		return IFAILED ;
  	}
/* RM
   *(long *) STCcurrent = (long) cival( var ) ;
   end RM */
   
   p = (char *)&cival( var ) ;
   for( i = 0 ; i < sizeof( void * ) ; i++ ) *STCcurrent++ = *p++ ;
   /* RM
   STCcurrent += sizeof( void * ) ;
   end RM */
   return ISUCCESS ;

} /* STCpushA */
/*----------------------------------------------------------------------------*/
int STCpushV( var, size, nbytes )

int var, size, nbytes ;

/* -- Pushes value of var at index `var' on the stack. `size' is the size of
      `var', `nbytes' ( nbytes >= size ) is the number by which the current
      position must be incremented.
   -- */

{ register char *p ; register int i ;

#ifdef DEBUG
  printf( "STCpush : size %d C %u pushing <%s>\n", STCsize,
  	STCcurrent - STCbottom, ci_data->vartable[var] ) ;
  fflush( stdout )  ;
#endif
   if( ( STCcurrent - STCbottom ) + nbytes >= STCsize )
  	if( !STCalloc() ) {
  		printf( "CI: cannot allocate %d bytes\n", STCsize ) ;
  		erreur( "cannot allocate function stack" ) ;
  		return IFAILED ;
  	}
  	
/* -- Push ...
   -- */
   /* RM if OK
   p = isarray( var ) ? &cival( var ) : cival( var ) ;
   end RM if OK */
   p = cival( var ) ;
   for( i = 0 ; i < size		; i++ ) *STCcurrent++ = *p++ ;
   for( i = 0 ; i < nbytes - size	; i++ ) *STCcurrent++ = '\0' ;

#ifdef DEBUG
  printf( "STCpush : EXIT C %u\n", STCcurrent - STCbottom ) ;
  fflush( stdout )  ;
#endif
  return ISUCCESS ;
}
/*----------------------------------------------------------------------------*/
int STCpullA( var )	int var ; {

/* -- Reads from the stack into the address of `var'.
   -- */
 		register char *from, *to ; register int i ;
 
	from	= STCcurrent - sizeof( void * ) ;
	to	= (char *)&cival( var ) ;
	for( i = 0 ; i < sizeof( void * ) ; i++ ) *to++ = *from++ ;
	STCcurrent -= sizeof( void * ) ;
/* RM
	cival( var )  = (char *) *(long *) STCcurrent ;
   end RM */
	return ISUCCESS ;
} /* STCpullA */
/*----------------------------------------------------------------------------*/
int STCpullV( var, size, nbytes )

/* -- Reads value of var at index `var' from the stack. `size' is the size of
      `var', `nbytes' ( nbytes >= size ) is the number by which the current
      position must be shifted to get the next value.
   -- */

{ register char *from, *to ; register int i ;
#ifdef DEBUG
  printf( "STCpull : size %d C %u reading <%s>\n", STCsize,
  	STCcurrent - STCbottom, ci_data->vartable[var] ) ;
  fflush( stdout )  ;
#endif
  from	= STCcurrent - nbytes ;
  to	= cival( var ) ;

  /* RM if OK
  to	= isarray( var ) ? &cival( var ) : cival( var ) ;
  end RM if OK */

  for( i = 0 ; i < size ; i++ ) *to++ = *from++ ;

  STCcurrent -= nbytes ;
#ifdef DEBUG
  printf( "STCpull : EXIT C %u\n", STCcurrent - STCbottom ) ;
  fflush( stdout )  ;
#endif
  return ISUCCESS ;
}
/*----------------------------------------------------------------------------*/
int STCpop( nbytes )

int nbytes ;

/* -- Pulls `nbytes' from the stack.
   -- */

{
#ifdef DEBUG
  printf( "STCpop : C %u R %u pulling <%d> bytes\n", STCcurrent - STCbottom,
           STCreadptr - STCbottom, nbytes ) ;
  fflush( stdout )  ;
#endif
  STCcurrent -= nbytes ;
  if( STCcurrent == STCreadptr ) STCreadptr = NULL ;
#ifdef DEBUG
  printf( "STCpop : C %u R %u\n", STCcurrent - STCbottom, STCreadptr - STCbottom ) ;
  fflush( stdout )  ;
#endif
  return ISUCCESS ;
}
/*----------------------------------------------------------------------------*/
int CIpushV( addr, size, nbytes )	void 	*addr	;
					int	size,
						nbytes	; {

	register char *p ; register int i ;

   if( ( STCcurrent - STCbottom ) + nbytes >= STCsize )
  	if( !STCalloc() ) {
  		printf( "CI: cannot allocate %d bytes\n", STCsize ) ;
  		erreur( "cannot allocate function stack" ) ;
  		return IFAILED ;
  	}

   p = addr ;

   for( i = 0 ; i < size		; i++ ) *STCcurrent++ = *p++ ;
   for( i = 0 ; i < nbytes - size	; i++ ) *STCcurrent++ = '\0' ;

  return ISUCCESS ;
}
/*----------------------------------------------------------------------------*/

