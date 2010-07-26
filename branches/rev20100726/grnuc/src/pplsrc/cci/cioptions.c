/*-INCLUDES-------------------------------------------------------------------*/
#include <string.h>
#include "pci.h"
#include "pcidef.h"
#include "pcimacros.h"
/*----------------------------------------------------------------------------*/
void PCIsetopt( s ) char *s ; {

/* -- Interprets in-line compiler directives (same as command line options plus
      a message echoing facility) :

	-^e <msg>				-> prints <msg> to stdout
	-^o +<opt1> +<opt2> -<opt3>		-> en/dis-able (+/-) options

	Examples :

	-^e This file only works with EMS.
	-^o +m +Xexternfn
   -- */

#define NOSTATE 2
	char *p ; int state ;

  state = NOSTATE ;
  switch( *s ) {
	case 'e' : printf( "%s\n", s + 2 ) ; break ;
	case 'o' : s += 2 ;
		   while( *s ) {
			switch( *s ) {
				case ' ' :
				case '\t': s++ ; break ;
				case '-' : state = FALSE ; s++ ; break ;
				case '+' : state = TRUE  ; s++ ; break ;
				default  : if( state == NOSTATE ) {
					   	ERRusr( "INVOPT",
					   		"directive must begin with + or -",
					   		NULL ) ;
					   	return ;
					   }
					   p = strchr( s, ' ' ) ;
					   if( !p ) p = strchr( s, '\0' ) ;
					   *p++ = '\0' ;

					          if( !strcmp( s, "m" ) ) {
						PCIopt.nomsgdel = state ;
					   } else if( !strcmp( s, "q" ) ) {
					   	PCIopt.noexinfo = state ;
					   } else if( !strcmp( s, "k" ) ) {
					   	PCIopt.keepfile = state ;
					   } else if( !strcmp( s+1, NOPTRCHK ) ) {
						PCIopt.noptrchk = state ;
					   } else if( !strcmp( s+1, NOARGCHK ) ) {
				   		PCIopt.noargchk = state ;
					   } else if( !strcmp( s+1, UNUSEDFN ) ) {
				   		PCIopt.unusedfn = state ;
					   } else if( !strcmp( s+1, EXTERNFN ) ) {
					   	PCIopt.externfn = state ;
					   } else {
					   	ERRusr( "INVOPT",
					   		"invalid directive",
					   		s ) ;
					   }
					   s = p ;
							
			}
		}
	}

} /* PCIsetopt */
/*----------------------------------------------------------------------------*/
