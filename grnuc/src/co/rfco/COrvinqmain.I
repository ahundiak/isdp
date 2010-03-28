/* #######################    APOGEE COMPILED   ######################## */
class implementation COreviewele;

#include  "coimport.h"
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
#include  "griomacros.h"
#include  "grdpbmacros.h"
#include  "exmacros.h"
#include  "DIdef.h"
#include  "DItypedef.h"
#include  "DIprims.h"
#include  "DIglob.h"
#include  "DImacros.h"
#include  "OMerrordef.h" 

from GRvg       import GRgetname,  GRgetsymb;
from GRgraphics import  GRgetobjinfo;

method inquire_data_main_form(int *sts)
{
    IGRlong		msg,
			status;
    IGRint   size=40;    
    IGRchar             error_msg[40];
    *sts = MSSUCC;

    me->element = me->event1.located_object[0].located_obj;
    me->element_env = me->event1.located_object[0].module_info;

    ex$get_cur_mod ( 
	id = &me->active_env.md_id.objid,
	osnum = &me->active_env.md_id.osnum );

    /*
     *  get the file name 
     */

    om$os_number_to_name ( 
	osnum = me->element.osnum,
	osname = me->file_name );

    /*
     *  inquire the element name and element type
     */

    status = om$send ( 
	msg = message GRvg.GRgetname ( &msg, me->element_name ),
       	targetid = me->element.objid,
	targetos = me->element.osnum );

    if ( 1 & status)
    {    
        di$cvt_name_for_output(s_path = me->element_name);
    }
			
    om$send ( 
	msg = message GRgraphics.GRgetobjinfo ( &msg, &me->info ),
	targetid = me->element.objid,
	targetos = me->element.osnum );

    /*
     *  inquire the layer #, color, weight, style
     */

    om$send ( 
	msg = message GRvg.GRgetsymb  ( &msg, &me->symbology ),
        targetid = me->element.objid,
        targetos = me->element.osnum );

    dp$levels_number_to_name ( 
	msg = &msg,
	number =  me->symbology.level,
	size_name_buffer = &size,
	name = me->layer_name,
	osnum = me->element.osnum );

    ige$get_name_from_color (
	color = me->symbology.display_attr.color,
	name = me->color_name,
	mod_osnum = me->element.osnum );


    strcpy( error_msg, " " );
    status = FIfld_set_text( me->forms[0].form_ptr,
                             10,          /* message field */
                             0,           /* row           */
                             0,           /* column        */
                             error_msg,
                             FALSE );     /* sel_flag      */


    return(OM_S_SUCCESS);

}
end implementation COreviewele;
