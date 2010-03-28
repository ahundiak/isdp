/* -- CI/CCI common library
      Contains the register initailization function :
		- create_f_ent

      Etienne BEEKER, Dominique GARDELLA, Alain FALASSE. ISDC, Paris.
   -- */

#include <malloc.h>
#include <stdio.h>
#define	CCI	1
#include "cidef.h"
#include "citypedef.h"
#include "ciprivmacros.h"
/*----------------------------------------------------------------------------*/
int create_f_ent( code, name, no_instr )

struct instance_ci	*code	 	;
char			*name		;
short			no_instr	;

/* -- Creates a new entry in the table of functions.
      INPUT  : code, pointer to structure containing compiled code
      	       name, function's name
               no_instr, instruction number
      RETURNS: 1 if OK, 0 in case of memory allocation failure.
   -- */

{  register struct f_entry *f_e ; int rc ;

#ifdef DEBUG
	printf( "create_f_ent : entering <$s>\n", name ) ; fflush( stdout ) ;
#endif

   f_e = code->f_entries[code->nbf_entries] = 
   		(struct f_entry *) malloc( sizeof(struct f_entry) ) ;
   if( f_e != NULL ) {
   	f_e->name = (char *) malloc( strlen( name ) + 1 ) ;
	if( f_e->name != NULL ) {
   		strcpy( f_e->name, name ) ;
   		f_e->no_instr = no_instr  ;
   		code->nbf_entries++       ;
		rc = 1			  ;
	}
   } else rc = 0 ;

#ifdef DEBUG
	printf( "create_f_ent : exiting\n" ) ; fflush( stdout ) ;
#endif
    return rc ;

} /* create_f_ent */
/*----------------------------------------------------------------------------*/
