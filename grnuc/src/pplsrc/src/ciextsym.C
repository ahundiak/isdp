/* --
	This module loads the table of external symbols from a disk file and
	resolves the external references of a PPL file loaded into memory.
	Alain Falasse, ISDC, August 27, 1988.
   -- */
#include "OMminimum.h"
#include "OMprimitives.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igr.h"
#include "ex.h"
#include "igrdp.h"
#include "gr.h"
#include "msdef.h"
#include "msmacros.h"
#include "cidef.h"
#include "citypedef.h"
#include "ciprivmacros.h"
#include "cimsg.h"
#include <malloc.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include "cisetup.h"

// #define DEBUG 1
/*----------------------------------------------------------------------------*/
extern char		*CIexmessage()	;
void			CIfreesyms()	;
/*----------------------------------------------------------------------------*/
/* -- Type of a symbol in table.
   -- */
typedef struct {
			void *addr ; /* Address of symbol	*/
			char *name ; /* Name of symbol		*/
} symbol ;

/* -- Table of symbols and size of table.
   -- */
static symbol	*CIsymtab = NULL;
static char 	*CIsymname= NULL;
static int	CItabsiz  = 0	;

#define SYMSIZE sizeof( symbol )
/*----------------------------------------------------------------------------*/
int CIloadsyms() {

dload (0);
return 1;
}


/*----------------------------------------------------------------------------*/
void CIfreesyms() {
} /* CIfreesyms */


/*----------------------------------------------------------------------------*/
/* SOL10 09 Nov 2010
 * Not sure if it is because I replaced the dload stuff with dirct calls to dlsym or not but
 * we no longer want to prepend an _ to symbol names
 */
void *CIfindsym( name )	char *name ; {

#if defined(SUNOSx) || defined(CLIX)
char buff[512];

strcpy (&buff[1], name);
buff[0] = '_';
return (void *)dload_address_lookup (buff);
#else
return (void *)dload_address_lookup (name);
#endif

} /* CIfindsym */


/*----------------------------------------------------------------------------*/
int CIdynlink( data, file, ciid )	struct instance_ci	*data	;
					char			*file	;
					OM_S_OBJID		ciid	; {
		

#define NOT_USED ( (char *) -1 )

	register char		**name, **addr	;
	register unsigned char	*flag		;
	int			nvar, v, rc, iln;
	char			*ln[FI_X_LINE_LEN];
	char			*msg		;
	extern char		CIeroutput	;
	char			path[CI_PATH_MAX+5];

	name = data->vartable		;
	addr = data->varvaltable	;
	flag = data->varflagtable	;
	nvar = data->nbvar		;


#ifdef DEBUG
  printf( "CIdynlink: ENTER(%s) nvar %d id %d\n", file, nvar, ciid ) ; fflush( stdout ) ;
#endif
	if( ( msg = strrchr( file, '/' ) ) == NULL )
		msg = file ;
	ln[0] = strcat( strcpy( path, "*** " ), file ) ;
	iln   = 1 ;

#ifdef DEBUG
  printf( "CIdynlink: ln[0](%s)\n", ln[0] ) ; fflush( stdout ) ;
#endif

	msg	= CIexmessage( CI_E_dlNOSYMB ) ;
	
	rc = TRUE ;
	for( v = 0 ; v < nvar ; v++ ) {

#ifdef DEBUG
  printf( "<%s> extern ? %d (addr %u)\n", name[v], flag[v] & CI_XTRN, addr[v] ) ; fflush( stdout ) ;
#endif
	  if( flag[v] & CI_XTRN ) {

	    if( addr[v] != NOT_USED ) {
		addr[v] = CIfindsym( name[v] ) ;

		if( addr[v] == NULL ) {
/* --		  Remembers symbols not found.
   -- */
		  if( iln < FI_X_LINE_LEN ) {
		  	if( ( ln[iln] = malloc(   strlen( msg )
					        + strlen( name[v] )
					        + 2 ) ) ) {
				sprintf( ln[iln], "%s %s", msg, name[v] ) ;
				iln++ ;
		  	}
		  }
		  rc = FALSE ;
		}
	    }
	  }
	} /* for */

	if( !rc ) {
/* --	    Log errors to selected output.
   -- */
	    switch( CIeroutput ) {

		case 1	: /* UNIX window */
			  fputs( CIexmessage( CI_I_dlFTITLE ), stderr ) ;
			  fputs( "\n", stderr ) ;
			  for( v = 0 ; v < iln ; v++ ) {
				fputs( ln[v], stderr ) ;
				fputs( "\n" , stderr ) ;
			  }
			  fputs( "---\n", stderr ) ;
			  break ;

		case 0 : /* Form */
			  CIcci_out_form(	CI_I_dlFTITLE	, ciid	,
			  			ln		, iln	,
			  			"CIer_dynlink"		) ;
			  break ;
	    }
	    for( v = 1 ; v < iln ; v++ ) free( ln[v] ) ;
	}

#ifdef DEBUG
  printf( "CIdynlink: EXIT(%d)\n", rc ) ; fflush( stdout ) ;
#endif
	return rc ;

} /* CIdynlink */
/*----------------------------------------------------------------------------*/
