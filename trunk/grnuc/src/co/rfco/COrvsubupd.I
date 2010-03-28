class implementation COreviewele;

#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include <coimport.h>
#include <revieweledef.h>
#include <report.h>
#include "grmsg.h"

#if defined( NT )
#if 0  /* because opp can not handle it */
#  include <windows.h>
#endif
#endif

#ifdef X11
#  include <X11/Xlib.h>
#  include <X11/Xutil.h>
#endif

#if defined(__STDC__) || defined(__cplusplus)
#if 0  /* because opp can not handle it */
#  if defined( X11 )
#    include <XFIproto_pub.h>
#  elif defined( ENV5 )
#    include <FIproto_pub.h>
#  elif defined( NT )
#    include <shampub.h>
#  endif
#else
#  include <FI.h>
#endif
#else
#  include <FI.h>
#endif

/*
  History
    elp              01/11/93        rearrange code so the actual display
                                     of the subform is the last thing in
                                     update_subform
*/
extern void COB_FI_form_notification();

from GRgraphics import GRreport_defaults, GRreport, GRupdate_gadgets;

method construct_subform ( IGRint *msg; IGRchar *form_name; 
                    IGRint *index)
{
    IGRint  ii, status, old_form_index, old_number_of_forms, reset = 1;
    IGRint  xpos, ypos, xsize, ysize;

    status = OM_S_SUCCESS;
    *msg = MSSUCC;

    old_form_index = me->form_index;
    old_number_of_forms = me->number_of_forms;

    /*
     * Look for this form in all constructed subforms.
     * The main form is the first form on the list.
     */
    for ( ii=1; ii < me->number_of_forms; ++ii)
    {
 	if (!strcmp(me->forms[ii].name, form_name))
	{
            break;
	}
    }

    /*
     * If the index is different from the old index
     * erase the old form.
     */
    if ( ((me->form_index = ii) != old_form_index ) && (old_form_index != 0))
    {
        if ( old_form_index != -1 )    
        {
            om$send ( msg =  message CEO.erase_form_by_label
                            ( old_form_index, reset, msg ),
                      targetid = my_id );
        }
    }
/*    else
    {
        FIf_reset (me->forms[old_form_index].form_ptr);	
    }*/
    
    /*
     * Set the form index.
     */
    *index = ii;
    me->sub_form = ii;

    /*
     * If form name was not found, create a new form.
     */
    if (ii == me->number_of_forms)
    {
        /*
         * Add the new form name to the form_name array.
         */
    	status = om$vla_set_dimension ( varray = me->form_names, 
                                        size = me->number_of_forms++);

        strcpy(&(me->form_names[ii-1][0]), form_name);
        
        /*
         * Update the CEO form array.
         */
    	status = om$vla_set_dimension ( varray = me->forms, 
                                        size = me->number_of_forms);

        /*
         * Fill in the CEO form array.
         */
        me->forms[ii].form_ptr = NULL;
        me->forms[ii].name = &(me->form_names[ii-1][0]);
    	me->forms[ii].label = ii;
    	me->forms[ii].display_type = 0;
    	me->forms[ii].displayed = 0;

        /*
        * Create the new form.
         */
        status = FIf_new ( me->forms[ii].label,
                           me->forms[ii].name,
                           (int (*)()) COB_FI_form_notification,
                           &(me->forms[ii].form_ptr));
	if (status)				
          goto quit;
	else status = 1;		/* KLUDGE because FIf_new returns 0  */
					/*  if form was created successfully */

        /*
         * Set the location for the new subform.
         */
        FIf_get_location (me->forms[0].form_ptr, & xpos, & ypos);
        FIf_get_size (me->forms[0].form_ptr, & xsize, & ysize);
        me->forms[ii].x = xpos; 
        me->forms[ii].y = ypos + ysize + 2;
        FIf_set_location (me->forms[ii].form_ptr, 
                          me->forms[ii].x, 
                          me->forms[ii].y);
            
        /*
         * Set the cmd id for the new subform.
         */
        FIf_set_cmd_oid_os ( me->forms[ii].form_ptr,
                             my_id,
                             OM_Gw_current_OS );
    }

   /*
    * If a form didn't exist and could not be constructed.
    */
    if ( !me->forms[ii].form_ptr )
    {
        *msg = MSFAIL;

        /* 
         * Issue an error message.
         */

        /*
         * Set back the number of forms active.
         */
        me->number_of_forms = old_number_of_forms;
        me->form_index = old_form_index;

        /*
         * No need to reset the vla since OM will take care
         * of this when the command object is deleted. This 
         * may also help minimize memory fragmentation.
         */
    }

quit:

    if (!(status & *msg & 1)) 
    {
        me->form_index = -1;
        *msg = MSFAIL;
    }
    else 
    {

        /*
         * If the previous subform was a window convert 
         * this subform to a window.
         */
        if ( old_form_index != -1 )
        {
            long attr;

            FIf_get_attr(me->forms[old_form_index].form_ptr, &attr);
            if ( !(attr & FI_SAVE_RESTORE) )
            {
#if 0
                FIf_cvrt_to_perm_win(me->forms[ii].form_ptr);
#else
                 /* this does everthing FIf_cvrt_to_perm_win does except
                    display the form.  Doing this we reduce the number of
                    form displays to one.  elp 01/11/93 */

                FIf_erase( me->forms[ii].form_ptr );
                FIf_get_attr(me->forms[ii].form_ptr, &attr);
                attr &= ~( FI_SAVE_RESTORE ) ;
                FIf_set_attr(me->forms[ii].form_ptr, attr);
                FIg_disable( me->forms[ii].form_ptr, FI_CVT_TO_PERM_WIN );
                FIf_uncollapse( me->forms[ii].form_ptr );
#endif
            }
        }
    }

    return(status);
}

method update_subform( IGRint *msg)
{
    IGRlong             status;
    IGRchar             form_name[132];
    IGRint		symbol_id;   		/* Symbol to display */
    IGRint		index;			/* Index of form */
    IGRint		list_size;		/* Number of fillable gadgets */
    struct GRreport_processor processor;	/* report info */

    *msg = MSSUCC;
    status = OM_S_SUCCESS;

    /* fix for UMR */
    processor.report_file = NULL;

    /* 
     * Get the defaults for the subform.
     */
    status = om$send( msg =  message GRgraphics.GRreport_defaults
                                            ( (IGRlong *) msg,
					      form_name,
					     &symbol_id,
					     &list_size,
					     &processor),
                      targetid = me->element.objid,
                      targetos = me->element.osnum );

    if (!(status & *msg & 1))
    {
      IGRchar   error_msg[44];

      ex$message( msgnumb = GR_I_NoMoreInfo,
                  buff = error_msg );

      status = FIfld_set_text( me->forms[0].form_ptr,
                               10,          /* message field */
                               0,           /* row           */
                               0,           /* column        */
                               error_msg,
                               FALSE );     /* sel_flag      */
      goto quit;
    }

      /* 
       * Construct the subform using the filename 
       * sent back from the graphic object the label
       * will be SUB_FORM.
       */
      status = om$send ( msg =  message COreviewele.construct_subform 
                                           ( msg,
                                             form_name,
                                             &index),
                         targetid = my_id );
    

						/* See if there is a symbol  */
						/*  to display		     */
      if (symbol_id != SYM_ON_FORM)				
      {
                     /* Display new geometry sym */
        FIg_erase(me->forms[index].form_ptr, GEOM_SYMBOL);	
        FIg_set_symbol_index(me->forms[index].form_ptr, GEOM_SYMBOL, 
                            symbol_id); 
        FIg_display(me->forms[index].form_ptr, GEOM_SYMBOL);
      }

      status = om$send ( msg = message GRgraphics.GRupdate_gadgets (
                         (IGRlong *) msg, 
                         me->forms[index].form_ptr),
                         targetid = me->element.objid,
                      targetos = me->element.osnum );
      if (!(status & *msg & 1))
        goto quit;
    /*
     * Fill in the report info.
     */
#if 0
    if (me->forms[index].displayed)				
      processor.report_info = me->forms[index].form_ptr;	
                               /* Fill in subform ptr */
    else processor.report_info = NULL;		/* Don't use subform */

/*    processor.report_file = ->save_file;*/	/* Fill in save file */
#else
    /*
     *  I know the form is not displayed, but so what.  At this point
     *  we're just filling in what needs to be displayed.  After we
     *  we fill it in, then we'll display it.  elp 01/11/93
     */
    processor.report_info = me->forms[index].form_ptr;	
#endif

      /*
       *  Fill in the form
       */
    status = om$send ( msg =  message GRgraphics.GRreport 
                                         ( (IGRlong *) msg,
					   &me->ModuleInfo,
					   &list_size,
					   NULL,
                                           &processor ),
                      targetid = me->element.objid,
                      targetos = me->element.osnum );
      /*
       * Display the subform.
       */
    status = om$send ( msg =  message CEO.display_form_by_label
                                      ( index, msg ),
                       targetid = my_id );

quit:

    return (status);
}
end implementation COreviewele;
