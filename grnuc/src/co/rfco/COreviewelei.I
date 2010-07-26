class implementation COreviewele;



#include  "msdef.h"
#include  "godef.h"
#include  "griodef.h"
#include  "grdpbdef.h"
#include  "csdef.h"
#include  "wl.h"
#include  "igecolor.h"
#include  "igecolmacros.h"
#include  "OMmacros.h"
#include  "dpmacros.h"
#include  "revieweledef.h"
#include  "grmessage.h"
#include  "griomacros.h"
#include  "grdpbmacros.h"
#include  "exmacros.h"
#include  "msmacros.h"
/* #include  "FIchan.h" */
#include  "DIdef.h"
#include  "DItypedef.h"
#include  "DIprims.h"
#include  "DIglob.h"
#include  "DImacros.h"
#include  <stdio.h> 
#include  "FI.h"

from GRvg       import GRgetname,  GRgetsymb;
from GRcsmgr    import GRget_acs_info, GRget_query_info;
from GRcoords   import GRcvt_to_lcl_coords, GRget_query_info;
from GRgraphics import GRgetobjinfo;
/* from GRgraphics import GRgetsfsize, GRloadform; */




method display_data_main_form ( long * sts )
{
  int		  status = OM_S_SUCCESS;

    IGRdouble   level_num, color_num, wt, st;

    *sts = MSSUCC;
    me->display = 0;

    *sts = FIfld_set_type( me->forms[0].form_ptr, MAIN_LAYER_NUM, 0, FI_INT);
    *sts = FIfld_set_type( me->forms[0].form_ptr, MAIN_COLOR_NUM, 0, FI_INT);
    *sts = FIfld_set_type( me->forms[0].form_ptr, MAIN_WEIGHT,    0, FI_INT);
    *sts = FIfld_set_type( me->forms[0].form_ptr, MAIN_STYLE,     0, FI_INT);
    level_num = (double) me->symbology.level;
    color_num = (double) me->symbology.display_attr.color;
    wt = (double) me->symbology.display_attr.weight;
    st = (double) me->symbology.display_attr.style;

    *sts = FIfld_set_text( me->forms[0].form_ptr, MAIN_FILE_NAME, 0, 0,
               me->file_name, 0);

    *sts = FIfld_set_text( me->forms[0].form_ptr, MAIN_ELEMENT_NAME, 0, 0,
               me->element_name, 0);
    
    *sts = FIfld_set_text( me->forms[0].form_ptr, MAIN_ELEMENT_TYPE, 0, 0,
               me->info.type, 0);

    *sts = FIfld_set_value( me->forms[0].form_ptr, MAIN_LAYER_NUM, 0, 0,
                level_num, 0);

    *sts = FIfld_set_text( me->forms[0].form_ptr, MAIN_LAYER_NAME, 0, 0,
               me->layer_name, 0);

    *sts = FIfld_set_value( me->forms[0].form_ptr, MAIN_COLOR_NUM, 0, 0,
                color_num, 0);

    *sts = FIfld_set_text( me->forms[0].form_ptr, MAIN_COLOR_NAME, 0, 0,
               me->color_name, 0);

    *sts = FIfld_set_value( me->forms[0].form_ptr, MAIN_WEIGHT, 0, 0, 
               wt, 0);

    *sts = FIfld_set_value( me->forms[0].form_ptr, MAIN_STYLE, 0, 0,
                st, 0);

    *sts = FIg_set_state_off( me->forms[0].form_ptr, MAIN_MORE_INFO);

    *sts = FIg_set_state_off( me->forms[0].form_ptr, MAIN_DISMISS_BUTTON);

    /*
     *  force all fields to be review only
     *  therefore no editing will be accepted
     */


     /*  display the main form
     */

    status = om$send ( msg = message CEO.display_form_by_label
             ( me->forms[0].label, (IGRint *)sts ),
	targetid = my_id );
quit:
  return OM_S_SUCCESS;
}

method sleep ( int pos )
{
  int		  status = OM_S_SUCCESS;

    IGRlong	i;

    /*
     *  erase the main form and any
     *  subforms which may be displayed
     */

    for ( i = me->number_of_forms -1 ; i >= 0;  i-- )
    {
	/*
	 *  erase the displayed form
	 */

    if( me->forms[i].displayed ) {
        /* erase the form but do not disturb the
         * flag 'me->forms[i].displayed'  so that it can be
         * used to redisplay the forms at 'wakeup'.
                 */

            status = FIf_erase (me->forms[i].form_ptr);
    }

     }
     status = om$send ( msg = message CEO.sleep(i),
            mode = OM_e_wrt_message,
                    targetid = my_id );

quit:
  return OM_S_SUCCESS;
}

method wakeup ( int pos )
{
  int		  status = OM_S_SUCCESS;

    int i=0;

    status = om$send ( msg = message CEO.wakeup(i),
            mode = OM_e_wrt_message,
                    targetid = my_id );


    for ( i = 0; i < me->number_of_forms;  i++)
    {
    /*
     *  display the proper form
     */

    if( me->forms[i].displayed ) {
        /* had been erased during sleep.
                 */

            status = FIf_display (me->forms[i].form_ptr);
    }
  }
quit:
  return OM_S_SUCCESS;
}

end implementation COreviewele;
