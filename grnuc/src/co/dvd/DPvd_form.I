class implementation DPvd;

#include <stdio.h>
#include <string.h>
#include <math.h>

#include "exdef.h"
#include "exmacros.h"

#include "dpdef.h"
#include "dp.h"
#include "dpcodef.h"
#include "dpstruct.h"

#include "igrdp.h"

#include "grmsg.h"

#include "DPdlist.h"

#define DPvd_SPEED_SLD         12
#define DPvd_ZOOM_TGL          13
#define DPvd_DISPLAY_LIST_TGL  15
#define DPvd_BOOST_TGL         19

%safe
/* static variable and default values */
static struct DPvd_wrk_t *DPvd_wrk_p = NULL;
static Form DPvd_status_form = NULL;
static IGRdouble DPvd_speed = 5.0;
static int DPvd_limited_zoom = TRUE;
%endsafe


void DPvd_attach_wrk_to_form(
   struct DPvd_wrk_t *wrk_p )

/*
NAME
        DPvd_attach_wrk_to_form

DESCRIPTION
        This function will pass a "struct DPvd_wrk_t" to the view dynamics
	command's form routines, so that some variables of this structure
	will kept same as the corresponding values on the form.

	A NULL parameter is needed to cancel last wrk_p pointer passed in.
	After this, any value changes on the form will not influence that
	structure.

SYNOPSIS
        void DPvd_attach_wrk_to_form(struct DPvd_wrk_t *wrk_p)

PARAMETERS
        wrk_p (IN) - pointer to a struct DPvd_wrk_t, in which some variables
	             will be modified by the form.
		     A NULL pointer will clear last wrk_p pointer.
GLOBALS USED
RETURN VALUES
NOTES
HISTORY
	06/29/93    T. Wang
*/

{
    DPvd_wrk_p = wrk_p;

    /* init wrk by form values */
    if (DPvd_wrk_p != NULL )
    {
	DPvd_wrk_p->speed = DPvd_speed;
	DPvd_wrk_p->limited_zoom = DPvd_limited_zoom;
    }
}



void DPvd_erase_status_form(
   void )

/*
NAME
        void DPvd_erase_status_form(void)

DESCRIPTION
        This function erase the view dynamics status form if it is created.

SYNOPSIS
        void DPvd_erase_status_form(void)

PARAMETERS
GLOBALS USED
RETURN VALUES
NOTES
HISTORY
	06/29/93    T. Wang
*/

{
    if ( DPvd_status_form )
    {
	FIf_erase( DPvd_status_form );
    }
}



void DPvd_delete_status_form(
   void )

/*
NAME
        DPvd_delete_status_form

DESCRIPTION
        This function delete the view dynamics status form if it is
	created.

SYNOPSIS
PARAMETERS
GLOBALS USED
RETURN VALUES
NOTES
HISTORY
	06/29/93    T. Wang
*/
{
    if ( DPvd_status_form )
    {
	FIf_delete( DPvd_status_form );
	DPvd_status_form = NULL;
    }
}

void DPvd_status_form_notif(
   int form_label, 
   int gadget_label, 
   double value, 
   Form form_ptr )

/*
NAME
        DPvd_status_form_notif

DESCRIPTION
        View dynamics status form's notif routine.

	Outside variables attached by DPvd_attach_wrk_to_form() will also
	be changed.

SYNOPSIS
PARAMETERS
GLOBALS USED
RETURN VALUES
NOTES
        Also see DPvd_attach_wrk_to_form().
HISTORY
	06/29/93    T. Wang
        09/20/93    H.S.Gandhi -- made changes to save the form parameters
                                  in the design file through the DPcodpb
                                  object messages.
*/

{
    IGRdouble tmp_double;
    IGRint response = EX_FORM_FINISHED;
    IGRlong msg, size = sizeof( struct EX_button );
    struct EX_button response_data;
    IGRushort dvd_flags=0x0000;

    switch( gadget_label )
    {
      case FI_CANCEL:
	DPvd_delete_status_form();
        ex$putque( msg = &msg,
                   response = &response,
                   byte = &size,
                   buffer = (char *) &response_data );
	break;

      case FI_ACCEPT:
        FIg_get_value( DPvd_status_form, DPvd_DISPLAY_LIST_TGL, &tmp_double );

        if (tmp_double==0.0)
        {
           dvd_flags |= DVD_DLIST_ON;
        }

        FIg_get_value( DPvd_status_form, DPvd_BOOST_TGL, &tmp_double );

        if (tmp_double==1.0)
        {
           dvd_flags |= DVD_PERF_BOOST;
        }

        FIg_get_value( form_ptr, DPvd_SPEED_SLD, &tmp_double);
        if ( DPvd_wrk_p )
        {
            DPvd_wrk_p->speed = tmp_double;
        }
        DPcodpb_set_dvd_speed( (IGRchar) tmp_double );

        FIg_get_value( DPvd_status_form, DPvd_ZOOM_TGL, &tmp_double );
        DPvd_limited_zoom = (int)tmp_double;
        if (tmp_double==0.0)
        {

           dvd_flags |= DVD_UNLIMITED_ZOOM;
        }

        /* set the dvd flags */
        DPcodpb_set_dvd_flags( (IGRushort) dvd_flags );

        DPvd_delete_status_form();

        ex$putque( msg = &msg,
                   response = &response,
                   byte = &size,
                   buffer = (char *) &response_data );
	break;
    }
}

int DPvd_status_form_displayed(
   void )

/*
NAME
   DPvd_status_form_displayed

DESCRIPTION
   This function determines in the status form for the View Dynamics
   command is displayed.

SYNOPSIS
   int DPvd_status_form_displayed(
      void )

PARAMETERS
   none

GLOBALS USED
   DPvd_status_form (static)

RETURN VALUES
   TRUE, if the status form is displayed
   FALSE, if the status form is not displayed

HISTORY
   09/09/93  S.P. Rogers
      Creation Date
*/

{
  int display_status;

   if ( DPvd_status_form == NULL )
   {
      return( FALSE );
   }
   else
   {
      FIf_is_displayed( DPvd_status_form, &display_status );
      return( display_status );
   }

} /* DPvd_status_form_displayed */


int DPvd_display_status_form(
   IGRboolean create )

/*
NAME
        DPvd_display_status_form

DESCRIPTION
        This function will create the DPvdViewDyn form if it doesn't exit.
	Then display the form.
SYNOPSIS
        DPvd_display_status_form(void)

PARAMETERS
   create (IN) - if TRUE, create and display form; if FALSE, only
                 display if form already exists

GLOBALS USED
RETURN VALUES
        TRUE -- Successful, 
        FALSE -- Failed in creating the form.
NOTES
HISTORY
	06/29/93    T. Wang

        09/20/93    H.S.Gandhi -- made changes to read the form parameters
                                  from the design file through the DPcodpb
                                  object messages.
*/

{
    IGRint sts;
    IGRboolean on_off;
    int display_status;
    IGRchar   dvd_speed;
    IGRushort dvd_flags;
    
    /* Create if not exist */
    if ( DPvd_status_form == NULL )
    {
        if ( !create )
        {
            return( TRUE );
        }

	/* Create the form */
	sts = FIf_new( 100, "GRDisViewDyn", DPvd_status_form_notif, &DPvd_status_form );
	if ( sts )
	{
	    return( FALSE );
	}
    }
    
    /* get the initial values saved in the DPcodpb object -- HSG */
    DPcodpb_get_dvd_speed( (IGRchar *) &dvd_speed );
    DPcodpb_get_dvd_flags( (IGRushort *) &dvd_flags );

    /* Assign initial values from the DPcodpb object -- HSG */
    FIg_set_value( DPvd_status_form, DPvd_SPEED_SLD, (IGRdouble) dvd_speed );
    FIg_set_value( DPvd_status_form, DPvd_BOOST_TGL, (dvd_flags&DVD_PERF_BOOST)
? 1.0 : 0.0 );
    FIg_set_value( DPvd_status_form, DPvd_DISPLAY_LIST_TGL, 
                   (dvd_flags&DVD_DLIST_ON) ? 0.0 : 1.0 );
    FIg_set_value( DPvd_status_form, DPvd_ZOOM_TGL,
                   (dvd_flags&DVD_UNLIMITED_ZOOM) ? 0.0:1.0 );

    FIf_is_displayed( DPvd_status_form, &display_status );
    if ( ! display_status )
    {
        FIf_display( DPvd_status_form );
    }

    return(TRUE);
}
   
end implementation DPvd;

