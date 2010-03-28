/* #######################    APOGEE COMPILED   ######################## */
command_string	"review element",0,GRRvE
class		COreviewele
product_name	"$GRNUC",2
command_path    "."
super_class	COtools
super_class	CEO_LOCATE
start_state	terminate
options		"t"

specification

#include "OMlimits.h"
#include "igrdp.h"
#include "grdpbdef.h"
#include "go.h"
#include "grio.h"
#include "igr.h"
#include "grcoordsys.h"
#include "FI.h"

instance
{
    /*  variables needed for main form  */

	IGRchar			file_name[OM_K_MAXOSNAME_LEN];  
	IGRchar			color_name[24];
        IGRchar			element_name[MAXNAMSIZE];
	IGRchar			layer_name[40];
	struct GRobj_info	info;
	struct GRsymbology	symbology;
	variable IGRchar	form_names[][132];
        IGRint			form_index;

    /*  variables needed for active readout  */

	IGRchar			cs_type[MAX_CS_TYPE]; /* coordinate sys type */
	GRIOalias_name		distance_units[3];    /*active distance units*/
	GRIOalias_name		angle_units[3];       /* active angular units*/
 	struct GRIOreadout_spec readout_distance;     /*readout specification*/
 	struct GRIOreadout_spec readout_angle;	      /*readout specification*/
	GRname		        cs_name;
	struct GRid		act_cs_id;	      /* coordinate sys mgr  */
	struct GRcsquery_info   *cs_info_ptr;	      /* active cs readout   */
    IGRint            main_form;
    /*  global variables used in most methods  */

    IGRint   sub_form;
    IGRint display;
	struct GRid		element;	/*  selected object's objid  */
	struct GRmd_env		element_env;    /*  selected object's env    */
	struct GRmd_env		active_env;	/*  master file environment  */

    /*  variables needed to fill in subforms  */

	IGRchar			coor1_label[10];
	IGRchar			coor2_label[10];
	IGRchar			coor3_label[10];

	IGRchar			units_field1[40];
	IGRchar			units_field2[40];
	IGRchar			units_field3[40];
	struct GRIOreadout_spec spec_array[3];

}


implementation

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


action inquire_data_main_form extern
action form_notification extern
action update_subform (IGRint *msg) extern
action construct_subform (IGRint *msg;
                          IGRchar *form_name;
                          IGRint *index) extern

action display_data_main_form
{
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
}

action sleep
{
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

}
action wakeup
{
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
}
