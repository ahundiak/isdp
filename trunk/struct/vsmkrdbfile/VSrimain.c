/*
	I/STRUCT
*/
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <ctype.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/lock.h>
#include <time.h>
#include <sys/stat.h>
#include "unistd.h"
#include "wl.h"
#if defined(X11)
#include <X11/X.h>
#endif
#if defined(ENV5)
#include <tools.h>
#endif
#include "FI.h"
#include "VX_FIproto.h"
#include "vsridef.h"
#include "vsri.h"
#define DECLARE_GLOBALS
#include "vsriglobals.h"
#include "vsriproto.h"
/*----------------------------------------------------------------------------*/
int main( int argc, char **argv ) {

	int		rc = 1,
			vs,
			slots,
			choice ;
	struct vlt_slot	*vlt ;
	char		language[100],
			file[1024] ;
	

	if( argc < 2 ) {
		fprintf( stderr, "Usage: %s <EXNUC directory>\n", exefile() ) ;
		return 1 ;
	}

#ifdef XWINDOWS
    {
    char *display_name;
    int  vsdisplay;
#define     DEFAULT_DISPLAY   ":0.0"

    /*  If 'display' was not on the command line, check the environment
     *  variable.
     */

      if ((display_name = (char *) getenv ("DISPLAY")) == NULL)
        {

	  /*  Default the display  */

	  if ((display_name =
	      (char *) malloc (strlen (DEFAULT_DISPLAY) + 1)) == NULL)
            {
		printf("Malloc for display_name failed \n");

	      return 1;
	    }

          strcpy (display_name, DEFAULT_DISPLAY);
        }


    if ((vsdisplay = XOpenDisplay (display_name))== None)
      {
	printf("Error opening X Display\n");
        return 1;
      }

    FSEnter (vsdisplay, 0);

    FI_enter(vsdisplay, XDefaultColormap(vsdisplay,XDefaultScreen(vsdisplay)),32);

   }
#else

	Enter_tools() ;

	Enable_events( FI_EVENT_MASK ) ;

	Inq_displayed_vs( &vs ) ;
	Get_fixed_vlt( &vlt, &slots ) ;
	Loadvlt( vs, vlt, slots ) ;

	FI_enter();
#endif
	/* FI_enter() ;  */

	/*
	 * Get pathname of form file. This executable is in $STRUCT/bin
	 * so look for it in $STRUCT/bin/../config/<language>/forms
	 */
	strcpy( file, exefile() ) ;
	if( !findLanguage( argv[1], language ) ) {
		goto wrapup ;
	}

	*strrchr( file, '/' ) = '\0' ;
	*strrchr( file, '/' ) = '\0' ;
	sprintf( _formdir, "%s/config/%s/forms", file, language ) ;

	while( getChoice( &choice ) ) {

		switch( choice ) {
			case PLT_CHOICE	 :
			case PRF_CHOICE	 : getFam() ; break ;
			case MAT_CHOICE  : getMat() ; break ;
			case EXIT_CHOICE : rc = 0 ; goto wrapup ;
		}
	}

	rc = 0 ;


	wrapup :
		/* Exit_tools() ; */
		WLexit() ; 
		return rc ;

} /* main */
/*----------------------------------------------------------------------------*/


