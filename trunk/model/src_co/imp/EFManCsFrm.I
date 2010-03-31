class implementation ECplcskin;

#include <stdio.h>
#include <FI.h>
#include "GRtypedef.h"
#include "EC_P.h"
#include "SKnewdef.h"

#define SKN_MOD1_BTN         11
#define SKN_MOD2_BTN         12
#define SKN_MOD3_BTN         13
#define SKN_MOD4_BTN         14
#define SKN_MOD5_BTN         15

%safe
/* static variable and default values */
static int chk_mode_button = NULL;
static Form SkCs_form = NULL;
%endsafe


void SkCs_manag (IGRboolean SkCs_form_not_exists,int *myevent_resp,
                int *response, char *response_data, int *skin_case)

/*
NAME
        SkCs_manag

DESCRIPTION
        This function will handle the "Case Selection Form" of Skinning command

PARAMETERS
        SkCs_form_not_exists (IN) - if TRUE, form has to be created
        myevent_resp  (OUT)       - event.response for checking by method select_case
        response      (OUT)       - response, if unknown event should be handled outside the cmd
        response_data (OUT)       -            - " - 
        skin_case     (OUT)       - selected case of skinning command

NOTES
HISTORY
        11/22/93    Ralf Burkhart
*/

{
   struct GRevent     myevent;
   IGRlong            msg;
   IGRint             status;

/* display the case selection form */

   status = SkCs_display_form ( SkCs_form_not_exists ); 
   if (!(1&status ))
   {
      *myevent_resp = GR_UNKNOWN_TYPE;
      *response = TERMINATE;
      *skin_case = chk_mode_button;
      return;
   }

/* wait for the user to select one of the case form buttons */
   while (TRUE)
   {
      co$getevent ( msg = &msg, 
                    event_mask = EVENT_MASK,
                    msgnum = EMS_P_SelSkinCase,
                    response = response,
                    response_data = response_data,
                    event = &myevent );

      *myevent_resp = myevent.response;
      if ( myevent.response == EX_FORM_FINISHED )
      {
         ex$message (msgnumb = EMS_P_00000);
         break; 
      }
      /* give control back to handle this event outside the cmd */ 
      else if ( myevent.response == GR_UNKNOWN_TYPE ) 
      {
         SkCs_delete_form();
         ex$message (msgnumb = EMS_P_00000);
         return;
      }
      else
      {
         ex$message (msgnumb = EMS_I_InpDiscard);
      }
   }

   *skin_case = chk_mode_button;
}


void SkCs_delete_form (void)

/*
NAME
        SkCs_delete_form

DESCRIPTION
        This function will delete the Case Selection Form if it is
        created.

NOTES
HISTORY
        11/20/93    Ralf Burkhart
*/
{
    if ( SkCs_form )
    {
        FIf_delete( SkCs_form );
        SkCs_form = NULL;
    }
}

void SkCs_notif( int     f_label,
                 int     g_label,
                 double  value,
                 Form    fp)

/*
NAME
        SkCs_notif

DESCRIPTION
        Notification routine of Case Selection Form.

NOTES
HISTORY
        11/20/93    Ralf Burkhart
*/

{
  IGRint response = EX_FORM_FINISHED;
  IGRlong msg, size = sizeof( struct EX_button );
  struct EX_button set_case;
  int status;

  f_label = f_label;
  value = value;
  fp = fp;

  switch ( g_label )
  {
    case SKN_MOD1_BTN:
      chk_mode_button = 1;
      break;

    case SKN_MOD2_BTN:
      chk_mode_button = 2;
      break;

    case SKN_MOD3_BTN:
      chk_mode_button = 3;
      break;

    case SKN_MOD4_BTN:
      chk_mode_button = 4;
      break;

    case SKN_MOD5_BTN:
      chk_mode_button = 5;
      break;

    default:
      ex$message ( msgnumb = EMS_I_InpDiscard );
      break;

  } /* END switch ( g_label ) */

  if (chk_mode_button)
  {

        /* terminate "wait for input" */
        SkCs_delete_form();
        status = ex$putque( msg = &msg,
                       response = &response,
                       byte     = &size,
                       buffer   = (IGRchar *) &set_case );

        /* check if successful */
        if (status != 1)
        {
           return;
        }
  }
} 


int SkCs_display_form ( IGRboolean create )

/*
NAME
        SkCs_display_form

DESCRIPTION
        This function will create the Case Selection Form if it doesn't exit.
	Then display the form.
SYNOPSIS
        extern int SkCs_display_form(IGRboolean create)

PARAMETERS
   create (IN)  - if TRUE, create and display form; if FALSE, only
                  display if form already exists

RETURN VALUES
        TRUE -- Successful, 
        FALSE -- Failed in creating the form.
NOTES
HISTORY
	11/20/93    Ralf Burkhart (created from DPvd_display_status_form of T.Wang)
*/

{
    IGRint status;
    int display_status;
    
    /* Create if not exist */
    if ( SkCs_form == NULL )
    {
        if ( !create )
        {
            return( TRUE );
        }

	/* Create the form */
	status = FIf_new( CASE_FORM, "EMskincase", SkCs_notif, &SkCs_form );
	if ( status != FI_SUCCESS )
	{
	    return( FALSE );
	}
    }


    FIf_is_displayed( SkCs_form, &display_status );
    if ( ! display_status )
    {

    /* At this point someone could adjust the form dependend on the
    selected command icon, because position for surface and solid is
    different or user may have his own panel menu or may have switched
    the menu. But GRmonkey stuff doesn't work for tear off panels ..  
    */

        FIf_display( SkCs_form );
    }
    return(TRUE);
}
   
end implementation ECplcskin;
