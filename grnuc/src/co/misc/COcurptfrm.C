/*
Name
        CO_const_current_pt_form()

Abstract
        This function 
            - creates and initializes the "Current point" form if it does
              not already exist and puts its GRid in global memory for
              future reference
            - displays the "Current point" form.
            - updates the current point" form

Synopsis

        IGRlong      *msg
            return code - MSSUCC - successful display of form; anything else
            indicates a problem

        struct GRevent  *Events[]         
            contents are not currently examined;  this argument exists to
            conform to a function argument list standard inforced by the
            COB command object COnpt and its "use_events" action.

Return Values
        MSSUCC  always

History
        srh - 08/20/87   created
        srh - 05/15/89   converted to c-based forms

Caveates
        The arguments to this function are required so that the standard
        interface for functions called by the "use_events" action are adhered
        to.  The Events array may have some future use, but is not currently
        used.

Files
        COcurptfrm.C
 
*/

 /* EH - End of Header  */


#include    "coimport.h"
#include    "FI.h"
#include    "codebug.h"
#include    "msdef.h"
#include    "griomacros.h"
#include    "igrmacros.h"
#include    "coformpriv.h"

extern void CurrentPt_form_notification();

/*
 * ----------------------------------------------------------------------
 *  allocate memory to store the ptr to CurrentPt form's data
 * ----------------------------------------------------------------------
 */
extern Form p_CurrentPointForm;  /* points to CurrentPointForm data */

#argsused
IGRlong   CO_const_current_pt_form( msg, Events )
    
    IGRlong           *msg;
    struct GRevent    *Events[];    /* not used but conforms with standards */

{

    /*  BV - Begin Variables */ 

    IGRlong    status = MSSUCC;  /* return code of this method    */



    /*  EV - end of local variables   */

    _m_debug_str( ">  CO_const_current_pt_form:" );
  
    /*
     *  --------------------------------------------------------------------
     *  Step 1:  IF "CurrentPt" form does not exist
     *           THEN  create it
     *           ELSE  exit : status = MSSUCC
     *
     *  --------------------------------------------------------------------
     */
    
    if ( p_CurrentPointForm == NULL )
    {
       status = FIf_new( CURRENT_PT_LABEL,
                         CURRENT_PT_FILENAME, 
                         CurrentPt_form_notification,
                        &p_CurrentPointForm );

       if ( p_CurrentPointForm == NULL || ( ( status != 0 )) ) goto quit;
    }
    else 
    {
       status = MSSUCC;
       goto quit;
    }

    /* Update fields in the CurrentPt form BEFORE displaying the form */
    status = co$update_current_point_form( msg = msg );

    /*
     *  display the form 
     */
    status = FIf_display( p_CurrentPointForm );

quit:
    _m_debug_str( "<  CO_const_current_pt_form:  execute method" );

    return( status );

} /* end execute method */

#argsused
void CurrentPt_form_notification( form_label,
				  gadget_label,
				  value,
				  form_ptr )
 IGRint    form_label;
 IGRint    gadget_label;
 IGRdouble value;
 Form      form_ptr;
{

   /*
    *  IF the gadget == DISMISS
    *  THEN delete the form
    *  ELSE ignore
    */
   
   if ( gadget_label == DISMISS_FORM )
   {
      FIf_delete( form_ptr );
      p_CurrentPointForm = NULL;
   }
}

/*
Name
        GRdelete_current_point_form()

Description
        This function is used to delete the current point form.  It is called
        from GRdpb.sleep to make sure all forms get deleted during a save so
        that the journaling code can track all window creation/deletion.

History
        mrm     02/03/93    creation
*/

void GRdelete_current_point_form()
{
    if (p_CurrentPointForm)
    {
        int is_displayed = FALSE;

        FIf_is_displayed(p_CurrentPointForm, &is_displayed);
        if (is_displayed)
            FIf_erase(p_CurrentPointForm);
        
        FIf_delete(p_CurrentPointForm);
        p_CurrentPointForm = NULL;
    }
}
