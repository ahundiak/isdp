
/* $Id: GRupdsetadp.C,v 1.1.1.1 2001/01/04 21:07:28 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:       
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: GRupdsetadp.C,v $
 *      Revision 1.1.1.1  2001/01/04 21:07:28  cvs
 *      Initial import to CVS
 *
 * Revision 1.1  1998/09/02  05:20:14  pinnacle
 * Created: emsfixes/grnuc/GRupdsetadp.C by smpathak for vds
 *
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *      12/09/87 	WBC	        Design date.
 *      12/09/87        WBC             Creation date.
 *      06/13/89        WBC             Updated to process cbased forms.
 *      07/13/92        dhm             ANSI conversion.
 *      02/11/93        elp             integrate WL
 *	08/31/98	Vinit		TR # 179801129
 ***************************************************************************/

/*
%GP% CODE CLASSIFICATION                           
----
%HD%

     FUNCTION NAME:             GRupdate_setadp
 
     Abstract:

        This function will update the specified gadget(s) on the Set Active
    Drawing Parameters form.  Any combination of gadgets may be updated.
    If a Set Active Drawing Parameters subform is being displayed that is
    affected by one of the gadgets being updated, it too will be updated to
    reflect the new value of that gadget if requested.
-----
%SC%

     VALUE =  GRupdate_setadp(msg,form_ptr,var_list,error_index)
-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE               DESCRIPTION
     ----------   ------------   -----------------------------------
     Form         form_ptr         pointer to the form to be updated
     var_list[]   struct EX_var_list array of structures indicating
                                     which gadgets to update and
                                     their new values; the following
                                     are the valid gadget types
                                     (defined in adpdef.h):
                                     ADP_LAYER_NUM, ADP_LAYER_NAME,
                                     ADP_COLOR_NUM, ADP_COLOR_NAME,
                                     ADP_COLOR_PALETTE, ADP_WEIGHT_NUM,
                                     ADP_STYLE_NUM, ADP_ANGLE_NUM,
                                     ADP_SCALE_NUM
-----
%EX%

     ON EXIT:

        NAME       DATA TYPE               DESCRIPTION
     ----------   ------------   -----------------------------------
     *msg         IGRlong        return code
                                     MSSUCC    - if successful
                                     MSINARG   - if invalid argument
                                     MSFAIL    - if failure
     *error_index IGRint         index of invalid array structure
-----
%MD%

     MODULES AND METHODS INVOKED:

     modules:

     methods:

-----
%RL%

      RELATIONS REFERENCED:

----- 
%NB%

     NOTES: - The valid types for the var_list structures are defined in
              adpdef.h.
            - ADP_END_LIST must be the type specified in the last structure
              in the array var_list; this implies the number of structures
              in the array will be one greater than the number of gadgets
              being changed.
            - The structure member num_bytes in struct EX_var_list is not
              used.
            - If one of the name fields is being updated the var_value
              structure member should be the corresponding DPB numeric
              value (e.g. if the color name field is to be updated, the
              var_value for this structure should be the address of the
              color number).
-----

%CH%
     CHANGE HISTORY:
        
        WBC  12/09/87 : Design date.
        WBC  12/09/87 : Creation date.
        WBC  06/13/89 : Updated to process cbased forms.
        dhm  07/13/92 : ANSI conversion.
        elp  02/11/93 : integrate WL
-----
%PD%
--------------------------------------------------------------------
               M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
    This function will update the specified gadget(s) on the Set
Active Drawing Parameters form.  Any combination of gadgets may be
updated.  If a Set Active Drawing Parameters subform is being
displayed that is affected by one of the gadgets being updated, it
too will be updated to reflect the new value of that gadget if
requested.
----*/
/*EH*/

#define  NEG_ONE     -1
#define  MAX_STRLEN  64

#include "coimport.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "msdef.h"
#include "msmacros.h"
#include "grmessage.h"
#include "igr.h"
#include "igrdp.h"
#include "godef.h"
#include "go.h"
#include "ex.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "exmacros.h"
#include "igrmacros.h"
#include "adpdef.h"
#include "grdpbmacros.h"
#include "wl.h"
#include "igecolor.h"
#include "igecolmacros.h"
#include "griodef.h"
#include "grio.h"
#include "griomacros.h"
#include "dpmacros.h"
#include "dperr.h"
#include "igewindef.h"
#include "igewindow.h"
#include "igewinmacros.h"
#include "FI.h"

IGRint GRupdate_setadp(msg,form_ptr,var_list,error_index)

IGRlong             *msg;
Form                form_ptr;
struct EX_var_list  var_list[];
IGRint              *error_index;

{
    struct GRid             module_grid;           /* module objid and osnum */
    struct GRdpb_scale      active_scale;
    struct GRIOreadout_spec readout_spec;          /* angle readout format   */
    IGRlong                 temp_msg;              /* return code of modules */
    IGRlong                 buffersize;
    IGRint                  i;
    IGRshort                num_alias = 3, num_levels;
    IGRchar                 text_string[MAX_STRLEN];
    IGRshort                field_size;

    *msg = MSSUCC;
    /** Changes for TR# 179801129 - Vinit  **/
    /* The text string has to assigned to NULL_CHAR 
       otherwise it gives junk values for the layer name
       when the  layer is changed (on Solaris only) */ 
      
    text_string[0] = NULL_CHAR;
    /*
     * update each specified gadget on the Set Active Drawing Parameters form
     * with the specified value
     */

    for (i = 0; (var_list[i].var != ADP_END_LIST) && (*msg & 1); i++)
    {
        switch (var_list[i].var)
        {
            case ADP_LAYER_NUM:    /* layer number */

                sprintf(text_string,"%d",(int)*((IGRshort *)var_list[i].var_value));
                FIfld_set_text(form_ptr,SET_ADP_LAYER_NUM,0,0,
                               text_string,FALSE);

                break;

            case ADP_LAYER_NAME:   /* layer name   */

                ex$get_cur_mod(id = &module_grid.objid,
                               osnum = &module_grid.osnum);

                buffersize = MAX_STRLEN;
                dp$levels_number_to_name(msg = &temp_msg,
                                         number = *(IGRshort *)var_list[i].var_value,
                                         ret_num_lev = &num_levels,
                                         size_name_buffer = &buffersize,
                                         name = text_string,
                                         osnum = module_grid.osnum,
                                         mod_objid = module_grid.objid);

                if ((temp_msg == DPAMBIGUOUS) && (num_levels == 1))
                {
                    IGRchar info_string[MAX_STRLEN];

                    /*
                     * display a message informing the user there are
                     * multiple layer names associated with this layer
                     * number
                     */

                    ex$message(msgnumb = GR_I_ActLyNo,
                               buff = info_string);
                    FIfld_set_text(form_ptr,SET_ADP_MSG_FIELD,0,0,
                                   info_string,FALSE);
                }
                else if (!(temp_msg & 1) || (num_levels > 1))
                {
                    /*
                     * Invalid layer name or the layer name has more than
                     * one layer associated with it, which is invalid;
                     * clear the layer name field
                     */

                    text_string[0] = NULL_CHAR;
                }
                FIfld_set_text(form_ptr,SET_ADP_LAYER_NAME,0,0,
                               text_string,FALSE);

                break;

            case ADP_COLOR_NUM:     /* color number  */

                /*
                 * if the active color is not background (color != 0),
                 * display the active color number; otherwise clear the
                 * color number field
                 */

                if (*((IGRushort *)var_list[i].var_value))
                {
                    sprintf(text_string,"%d",(int)*((IGRushort *)var_list[i].var_value));
                }
                else
                {
                    text_string[0] = NULL_CHAR;
                }
                FIfld_set_text(form_ptr,SET_ADP_COLOR_NUM,0,0,
                               text_string,FALSE);

                break;

            case ADP_COLOR_NAME:    /* color name    */
            case ADP_COLOR_PALETTE: /* color palette */

                /*
                 * if the color palette has changed this means the color
                 * table has changed, in which case the color name may
                 * have changed
                 */

                ex$get_cur_mod(id = &module_grid.objid,
                               osnum = &module_grid.osnum);

                text_string[0] = NULL_CHAR;

                ige$get_name_from_color(color = *((IGRushort *)var_list[i].var_value),
                                        name = text_string,
                                        mod_id = module_grid.objid,
                                        mod_osnum = module_grid.osnum);

                FIfld_set_text(form_ptr,SET_ADP_COLOR_NAME,0,0,
                               text_string,FALSE);

                break;

            case ADP_WEIGHT_NUM:    /* weight number */

                sprintf(text_string,"%d",(int)*((IGRuchar *)var_list[i].var_value));
                FIfld_set_text(form_ptr,SET_ADP_WEIGHT_NUM,0,0,
                               text_string,FALSE);

                break;

            case ADP_STYLE_NUM:    /* style number */

                sprintf(text_string,"%d",(int)*((IGRuchar *)var_list[i].var_value));
                FIfld_set_text(form_ptr,SET_ADP_STYLE_NUM,0,0,
                               text_string,FALSE);

                break;

            case ADP_ANGLE_NUM:    /* angle number */

                ex$get_cur_mod(osnum = &module_grid.osnum);

                readout_spec.justification = GRIO_LEFT_JUSTIFY;
                readout_spec.mode = GRIO_DECIMAL;
                readout_spec.precision = 4;
                readout_spec.case_type = GRIO_DEFAULT_CASE;
                readout_spec.leading_zeros = FALSE;
                readout_spec.trailing_zeros = FALSE;
                readout_spec.decimal_char = GRIO_PERIOD;
                readout_spec.thousands_char = GRIO_NONE;
                readout_spec.intermeas_spacing = 2;
                readout_spec.intrameas_spacing = 1;
                readout_spec.left_fill_char = ' ';
                readout_spec.alias_displayed = TRUE;

                field_size = sizeof(IGRchar) * MAX_STRLEN;
                co$cvt_imp_to_alias(msg = &temp_msg,
                                    unit_type = "UOM_ANGLE",
                                    osnum = module_grid.osnum,
                                    working_units = (IGRdouble *)var_list[i].var_value,
                                    num_alias = &num_alias,
                                    readout_spec = &readout_spec,
                                    field_size = &field_size,
                                    cvt_list = text_string);

                FIfld_set_text(form_ptr,SET_ADP_ANGLE_NUM,0,0,
                               text_string,FALSE);

                break;

            case ADP_SCALE_NUM:    /* scale numbers */

                active_scale = *((struct GRdpb_scale *)var_list[i].var_value);

                if ((active_scale.Active_xscale ==
                     active_scale.Active_yscale) &&
                    (active_scale.Active_xscale ==
                     active_scale.Active_zscale))
                {
                    sprintf(text_string,"%g",active_scale.Active_xscale);
                    FIfld_set_text(form_ptr,SET_ADP_SCALE_NUM,0,0,
                                   text_string,FALSE);

                    /*
                     * erase the x, y and z scale values from the form
                     */

                    FIg_reset(form_ptr,SET_ADP_X_SCALE_NUM);
                    FIg_reset(form_ptr,SET_ADP_Y_SCALE_NUM);
                    FIg_reset(form_ptr,SET_ADP_Z_SCALE_NUM);
                }
                else
                {
                    sprintf(text_string,"%g",active_scale.Active_xscale);
                    FIfld_set_text(form_ptr,SET_ADP_X_SCALE_NUM,0,0,
                                   text_string,FALSE);

                    sprintf(text_string,"%g",active_scale.Active_yscale);
                    FIfld_set_text(form_ptr,SET_ADP_Y_SCALE_NUM,0,0,
                                   text_string,FALSE);

                    sprintf(text_string,"%g",active_scale.Active_zscale);
                    FIfld_set_text(form_ptr,SET_ADP_Z_SCALE_NUM,0,0,
                                   text_string,FALSE);

                    FIg_reset(form_ptr,SET_ADP_SCALE_NUM);
                }

                break;

            default:   /* error: invalid type */

                *msg = MSINARG;
                *error_index = i;
                break;
        }   /* end switch */
    }     /* end for loop */

    return(TRUE);
}
