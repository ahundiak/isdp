/*
Name
        GRprocess_setadp
 
Description
        This method processes input from the Set Active Drawing Parameters
        form and its subforms.  If the input parameter is valid, the dpb will
        be updated.

Synopsis
        VALUE =  GRprocess_setadp(form_label,label,value,form_ptr)

        int     form_label      form label
        int     label           label of the gadget whose data has changed
        double  value           return value of the gadget
        Form    form_ptr        pointer to the form whose gadget was updated

History
        WBC     12/07/87    Design date.
        WBC     12/07/87    Creation date.
        WBC     06/14/89    Updated to process cbased forms.
        dhm     09/19/91    Updated to invoke the CO define linestyle instead
                            of the linestyle subform.
	AIC     07/10/91    Commented out FI error messages.
        dhm     10/11/91    Fixed define linestyle key.
        dhm     07/13/92    ANSI conversion.
        elp     02/11/93    integrate WL
        jdu     05/12/93    fixed for 2.4 color scheme color pallet only used
                            for generate set
        mrm     09/20/93    call GRupdate_adp with NULL form pointer to find
                            all bar menus
*/

#define  NEG_ONE           -1
#define  MAX_STRING_LENGTH 64

#include "coimport.h"
#include "OMprimitives.h"
#include "igrtypedef.h"
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
#include "grdpbmacros.h"
#include "wl.h"
#include "igecolor.h"
#include "igecolmacros.h"
#include "igewindef.h"
#include "igewindow.h"
#include "igewinmacros.h"
#include "griodef.h"
#include "grio.h"
#include "griomacros.h"
#include "dpmacros.h"
#include "dperr.h"
#include "ctype.h"
#include "adpdef.h"
#include "FI.h"
/*#include "FImsg.h"*/
#include "comiscmac.h"
#include "SSdef.h"
#include "SSmacros.h"

static Form            active_subform_ptr = 0;
static Form            color_form_ptr = 0;
static Form            weight_form_ptr = 0;
static IGRint          button_label = -1;   /* pushed subform button label   */
static IGRshort        num_colors = 0;      /* # of buttons on color palette */

#argsused
void GRprocess_setadp( form_label, label, value, form_ptr)

int form_label;  /* form label                                   */
int label;       /* label of the gadget whose data has changed   */
double value;    /* return value of the gadget                   */
Form form_ptr;   /* pointer to the form whose gadget was updated */
{
    extern  IGRboolean     COInvisibleColor;
    extern void            GRchg_adp_line_weight();
    extern double          atof();
    extern char            EX_runname[];

    struct GRid            module_grid;    /* module objid and osnum   */
    struct IGRdisplay      active_display;
    struct GRdpb_scale     active_scale;
    struct EX_var_list     var_list[9];
    struct GRevent         event;
    Form                   setadp_form_ptr;
    IGRlong                msg;
    IGRlong                buffersize;     /* buffersize for the dpb   */
    IGRlong                nobytes;
    IGRlong                form_mask;
    IGRdouble              temp_double;
    IGRdouble              active_angle;
    IGRshort               active_layer;
    IGRushort              ushortnum;
    IGRint                 index;
    IGRint                 status;
    IGRint                 sel_flag;
    IGRint                 r_pos;
    IGRint                 text_length;
    IGRint                 int_value;
    IGRuchar               text_string[MAX_STRING_LENGTH];
    IGRchar                error_string[MAX_STRING_LENGTH];

    GRcreate_setadp(&msg,FALSE,&setadp_form_ptr);

    switch (form_label)
    {
        case SET_ADP_FORM_LABEL:

            /*
             * clear the form message field
             */

            FIg_reset(setadp_form_ptr,SET_ADP_MSG_FIELD);

            switch (label)
            {
                case SET_ADP_ACCEPT_BUTTON:
                {
                    /*
                     * if a subform is being displayed, erase it and pop the
                     * corresponding button on the Set Active Drawing
                     * Parameters form
                     */

                    if (button_label > NEG_ONE)
                    {
                        FIf_erase(active_subform_ptr);
                        FIg_set_state_off(setadp_form_ptr,button_label);
                        button_label = NEG_ONE;
                    }

                    /*
                     * Erase the Set Active Drawing Parameters form
                     */

                    FIf_erase(setadp_form_ptr);

                    /*
                     * update the Drawing Parameters form in case one of its
                     * parameters was changed and it could not be updated
                     * because a save/restore window was active
                     */

                    gr$get_active_display(buffer = &active_display);
                    gr$get_active_level(buffer = &active_layer);
                    var_list[0].var = ADP_LAYER_NUM;
                    var_list[0].var_value = (IGRchar *) &active_layer;
                    var_list[1].var = ADP_COLOR_NUM;
                    var_list[1].var_value = (IGRchar *) &active_display.color;
                    var_list[2].var = ADP_WEIGHT_NUM;
                    var_list[2].var_value = (IGRchar *) &active_display.weight;
                    var_list[3].var = ADP_STYLE_NUM;
                    var_list[3].var_value = (IGRchar *) &active_display.style;
                    var_list[4].var = ADP_END_LIST;
                    GRupdate_adp(&msg, NULL, var_list, &index);

                    /*
                     * if the Set Active Drawing Parameters form is
                     * save/restore, terminate the controlling command;
                     * otherwise the command has already been terminated
                     */

                    FIf_get_attr(setadp_form_ptr,&form_mask);

                    if (form_mask & FI_SAVE_RESTORE)
                    {
                        event.response = EX_FORM_FINISHED;
                        buffersize = sizeof(struct GRevent) - (sizeof(IGRint) * 2);

                        ex$putque(msg = &msg,
                                  response = &event.response,
                                  byte = &buffersize,
                                  buffer = (IGRchar *) &event.event);
                    }
                    break;
                }
                
                case SET_ADP_PERM_WIN_BUTTON:
                {
                    /*
                     * forms interface software converts the save/restore
                     * window to a permanent window - checks for a certain
                     * gadget type (FIcbar) and label (5);  terminate the
                     * controlling command
                     */

                    event.response = EX_FORM_FINISHED;
                    buffersize = sizeof(struct GRevent) - (sizeof(IGRint) * 2);

                    ex$putque(msg = &msg,
                              response = &event.response,
                              byte = &buffersize,
                              buffer = (IGRchar *) &event.event);

                    break;
                }
                
                case SET_ADP_HELP_BUTTON:
                {
                    /*
                     * pop the help button and display help using the
                     * environ V function Help_topic
                     */

                    FIg_set_state_off(setadp_form_ptr,SET_ADP_HELP_BUTTON);
/*                    Help_topic("set_active_drawing_parameters"); */

                    break;
                }
                
                case SET_ADP_COLOR_BUTTON:
                {
                    /*
                     * If another subform is being displayed, erase it and
                     * pop the corresponding button on the Set Active Drawing
                     * Parameters form
                     */

                    if (button_label > NEG_ONE)
                    {
                        FIf_erase(active_subform_ptr);
                        FIg_set_state_off(active_subform_ptr,button_label);
                        button_label = NEG_ONE;
                    }

                    /*
                     * selecting the color button invokes the create color table
                     * form command object; pop the color button so the next
                     * time it's selected it will invoke the C.O. again
                     */

                    FIg_set_state_off(setadp_form_ptr,SET_ADP_COLOR_BUTTON);

                    event.response = EX_CMD_KEY;
                    buffersize = 9;

                    ex$putque(msg = &msg,
                              response = &event.response,
                              byte = &buffersize,
                              buffer = "GRCrClTb");

                    break;
                }
                
                case SET_ADP_LAYER_BUTTON:
                {
                    /*
                     * If another subform is being displayed, erase it and
                     * pop the corresponding button on the Set Active Drawing
                     * Parameters form
                     */

                    if (button_label > NEG_ONE)
                    {
                        FIf_erase(active_subform_ptr);
                        FIg_set_state_off(active_subform_ptr,button_label);
                        button_label = NEG_ONE;
                    }

                    /*
                     * selecting the layer button invokes the review/set layer
                     * form command object; pop the layer button so the next
                     * time it's selected it will invoke the C.O. again
                     */

                    FIg_set_state_off(setadp_form_ptr,SET_ADP_LAYER_BUTTON);

                    event.response = EX_CMD_KEY;
                    buffersize = 7;

                    ex$putque(msg = &msg,
                              response = &event.response,
                              byte = &buffersize,
                              buffer = "GRSALy");

                    break;
                }

                case SET_ADP_STYLE_BUTTON:
                {
                    /*
                     * If another subform is being displayed, erase it and
                     * pop the corresponding button on the Set Active Drawing
                     * Parameters form
                     */

                    if (button_label > NEG_ONE)
                    {
                        FIf_erase(active_subform_ptr);
                        FIg_set_state_off(active_subform_ptr,button_label);
                        button_label = NEG_ONE;
                    }

                    /*
                     * selecting the style button invokes the define linestyle
                     * form command object; pop the style button so the next
                     * time it's selected it will invoke the C.O. again
                     */

                    FIg_set_state_off(setadp_form_ptr,SET_ADP_STYLE_BUTTON);

                    event.response = EX_CMD_KEY;
                    buffersize = 9;

                    ex$putque(msg = &msg,
                              response = &event.response,
                              byte = &buffersize,
                              buffer = "GRDfLnSt");

                    break;
                }
                
                case SET_ADP_WEIGHT_BUTTON:
                {
                    if (value == GR_ON_STATE)
                    {
                        /*
                         * If another subform is being displayed, erase it
                         * and pop the corresponding button on the Set Active
                         * Drawing Parameters form
                         */

                        if (button_label > NEG_ONE)
                        {
                            FIf_erase(active_subform_ptr);
                            FIg_set_state_off(setadp_form_ptr,button_label);
                        }

                        /*
                         * save the label of the pushed button and find the
                         * active display attributes to be used in displaying
                         * the subforms
                         */

                        button_label = label;

                        buffersize = sizeof(active_display);
                        gr$get_active_display(msg = &msg,
                                              sizbuf = &buffersize,
                                              buffer = &active_display,
                                              nret = &nobytes);

                        /*
                         * determine which subform is to be displayed
                         */

                        active_subform_ptr = 0;

                        if (! weight_form_ptr)
                        {
                            if (FIf_new(GRWEIGHT_SUBFORM_LABEL,
                                        GRWEIGHT_FORM_FILENAME,
                                        GRprocess_setadp,
                                        &weight_form_ptr))
                            {
/*
                                ex$message(msgnumb = FI_E_NLDFM,
                                           buff = error_string);
*/
                                FIfld_set_text(setadp_form_ptr,
                                               SET_ADP_MSG_FIELD,0,0,
                                               error_string,
                                               FALSE);
                                break;
                            }

                            /*
                             * want to update the line gadget's weight
                             * as the slider is being moved
                             */
 
                            FIg_set_continuous_routine(weight_form_ptr,
                                                       GRWEIGHT_SLIDER,
                                                       GRchg_adp_line_weight);
                        }
                        active_subform_ptr = weight_form_ptr;
 
                        /*
                         * need to update the subform to reflect
                         * the current line weight value
                         */
 
                        GRupdweightform(&msg,
                                        active_display.weight,
                                        weight_form_ptr);
 

                        if (active_subform_ptr)
                        {
                            /*
                             * if the form has been converted to a permanent
                             * form, convert it back to a save/restore form
                             */

                            FIf_get_attr(active_subform_ptr,&form_mask);

                            if (! (form_mask & FI_SAVE_RESTORE))
                            {
                                form_mask |= FI_SAVE_RESTORE;
                                FIf_set_attr(active_subform_ptr,form_mask);
                            }

                            /*
                             * display the subform
                             */

                            FIf_display(active_subform_ptr);
                        }
                    }
                    else
                    {
                        /*
                         * the subform button was popped; erase the
                         * subform; set button_label to NEG_ONE
                         */

                        FIf_erase(active_subform_ptr);
                        button_label = NEG_ONE;
                    }
                    break;
                }

                case SET_ADP_LAYER_NUM:
                {
                    FIfld_get_text_length(setadp_form_ptr,SET_ADP_LAYER_NUM,
                                          0,0,&text_length);

                    /*
                     * if the user cleared out the field, restore the layer
                     * number field to its previous value
                     */

                    if (text_length > 1)
                    {
                        FIfld_get_text(setadp_form_ptr,SET_ADP_LAYER_NUM,
                                       0,0,text_length,text_string,
                                       &sel_flag,&r_pos);

                        active_layer = (IGRshort) atoi( (IGRchar *) text_string);

                        if ((active_layer >= GR_LO_LAYER) &&
                            (active_layer <= GR_HI_LAYER))
                        {
                            /*
                             * valid value; update the dpb and the active layer
                             * name
                             */

                            buffersize = sizeof(active_layer);
                            gr$put_active_level(msg = &msg,
                                                sizbuf = &buffersize,
                                                buffer = &active_layer);

                            var_list[0].var = ADP_LAYER_NAME;
                        }
                        else  /* invalid layer */
                        {
                            /*
                             * display appropriate error message in the
                             * message field
                             */

                            ex$message(msgnumb = GR_E_InvLy,
                                       buff = error_string);

                            FIfld_set_text(setadp_form_ptr,SET_ADP_MSG_FIELD,
                                           0,0,error_string,FALSE);
                            msg = MSFAIL;
                        }
                    }
                    else  /* no characters entered */
                    {
                        msg = GRw_no_value;
                    }

                    if (! (msg & 1))
                    {
                        /*
                         * either no input or invalid input; send a message to
                         * update the form with the current dpb value
                         */

                        buffersize = sizeof(active_layer);
                        gr$get_active_level(msg = &msg,
                                            sizbuf = &buffersize,
                                            buffer = &active_layer,
                                            nret = &nobytes);

                        var_list[0].var = ADP_LAYER_NUM;
                    }

                    /*
                     * update either the layer name or number on the form
                     */

                    var_list[0].var_value = (IGRchar *) &active_layer;
                    var_list[1].var = ADP_END_LIST;

                    GRupdate_setadp(&msg,setadp_form_ptr,var_list,&index);

                    break;
                }

                case SET_ADP_LAYER_NAME:
                {
                    FIfld_get_text_length(setadp_form_ptr,SET_ADP_LAYER_NAME,
                                          0,0,&text_length);

                    /*
                     * if the user cleared out the field, restore the layer
                     * name field to its previous value
                     */

                    if (text_length > 1)
                    {
                        FIfld_get_text(setadp_form_ptr,SET_ADP_LAYER_NAME,
                                       0,0,text_length,text_string,
                                       &sel_flag,&r_pos);

                        /*
                         * find the layer number corresponding to the
                         * layer name
                         */

                        ex$get_cur_mod(id = &module_grid.objid,
                                       osnum = &module_grid.osnum);

                        dp$levels_name_to_number(msg = &msg,
                                                 name = text_string,
                                                 number = &active_layer,
                                                 mod_objid = module_grid.objid,
                                                 osnum = module_grid.osnum);

                        if (msg & 1)
                        {
                            /*
                             * valid value; update the dpb and the active layer
                             * number
                             */

                            buffersize = sizeof(active_layer);
                            gr$put_active_level(msg = &msg,
                                                sizbuf = &buffersize,
                                                buffer = &active_layer);

                            var_list[0].var = ADP_LAYER_NUM;
                        }
                        else  /* invalid layer */
                        {
                            /*
                             * display appropriate error message in the
                             * message field
                             */

                            ex$message(msgnumb = GR_E_InvLy,
                                       buff = error_string);

                            FIfld_set_text(setadp_form_ptr,SET_ADP_MSG_FIELD,
                                           0,0,error_string,FALSE);
                            msg = MSFAIL;
                        }
                    }
                    else  /* null string or white spaces; restore name field */
                    {
                        msg = GRw_no_value;
                    }

                    if (!(msg & 1))
                    {
                        /*
                         * get the current DPB value for layer and update the
                         * layer name on the form
                         */

                        buffersize = sizeof(active_layer);
                        gr$get_active_level(msg = &msg,
                                            sizbuf = &buffersize,
                                            buffer = &active_layer,
                                            nret = &nobytes);

                        var_list[0].var = ADP_LAYER_NAME;
                    }

                    /*
                     * update either the layer name or number on the form
                     */

                    var_list[0].var_value = (IGRchar *) &active_layer;
                    var_list[1].var = ADP_END_LIST;

                    GRupdate_setadp(&msg,setadp_form_ptr,var_list,&index);

                    break;
                }

                case SET_ADP_COLOR_NUM:
                {
                    buffersize = sizeof(active_display);
                    gr$get_active_display(msg = &msg,
                                          sizbuf = &buffersize,
                                          buffer = &active_display,
                                          nret = &nobytes);

                    FIfld_get_text_length(setadp_form_ptr,SET_ADP_COLOR_NUM,
                                          0,0,&text_length);

                    /*
                     * if the user cleared out the field, restore the layer
                     * number field to its previous value
                     */

                    if (text_length > 1)
                    {
                        FIfld_get_text(setadp_form_ptr,SET_ADP_COLOR_NUM,
                                       0,0,text_length,text_string,
                                       &sel_flag,&r_pos);

                        ushortnum = (IGRushort) atoi( (IGRchar *) text_string);

                        if ((ushortnum >= GR_LO_COLOR) &&
                            (ushortnum <= GR_HI_COLOR))
                        {
                            active_display.color = ushortnum;

                            /*
                             * valid value; update the dpb and the color
                             * name field
                             */

                            gr$put_active_display(msg = &msg,
                                                  sizbuf = &buffersize,
                                                  buffer = &active_display);

                            COInvisibleColor = FALSE;
                            var_list[0].var = ADP_COLOR_NAME;
                        }
                        else  /* invalid color number */
                        {
                            /*
                             * update the color number field with the current
                             * dpb value and display the appropriate error
                             * message in the message field
                             */

                            ex$message(msgnumb = GR_E_InvCo,
                                       buff = error_string);

                            FIfld_set_text(setadp_form_ptr,SET_ADP_MSG_FIELD,
                                           0,0,error_string,FALSE);

                            var_list[0].var = ADP_COLOR_NUM;
                        }
                    }
                    else  /* no chars entered; restore color number field */
                    {
                        var_list[0].var = ADP_COLOR_NUM;
                    }

                    var_list[0].var_value = (IGRchar *) &active_display.color;
                    var_list[1].var = ADP_END_LIST;

                    GRupdate_setadp(&msg,setadp_form_ptr,var_list,&index);

                    break;
                }

                case SET_ADP_COLOR_NAME:
                {
                    buffersize = sizeof(active_display);
                    gr$get_active_display(msg = &msg,
                                          sizbuf = &buffersize,
                                          buffer = &active_display,
                                           nret = &nobytes);

                    FIfld_get_text_length(setadp_form_ptr,SET_ADP_COLOR_NAME,
                                          0,0,&text_length);

                    /*
                     * if the user cleared out the field, restore the color
                     * name field to its previous value
                     */

                    if (text_length > 1)
                    {
                        IGRshort the_color;

                        FIfld_get_text(setadp_form_ptr,SET_ADP_COLOR_NAME,
                                       0,0,text_length,text_string,
                                       &sel_flag,&r_pos);

                        if (ige$get_color_from_name(name = (IGRchar *) text_string,
                                                    color = &the_color))
                        {
                            active_display.color = (unsigned short) the_color;
                            /*
                             * valid color name; update the dpb and the color
                             * number field
                             */

                            gr$put_active_display(msg = &msg,
                                                  sizbuf = &buffersize,
                                                  buffer = &active_display);

                            COInvisibleColor = FALSE;
                            var_list[0].var = ADP_COLOR_NUM;
                        }
                        else   /* invlaid color name */
                        {
                            /*
                             * display appropriate error message in the
                             * message field
                             */

                            ex$message(msgnumb = GR_E_InvCo,
                                       buff = error_string);

                            FIfld_set_text(setadp_form_ptr,SET_ADP_MSG_FIELD,
                                           0,0,error_string,FALSE);

                            var_list[0].var = ADP_COLOR_NAME;
                        }
                    }
                    else  /* null string or white spaces; restore name field */
                    {
                        var_list[0].var = ADP_COLOR_NAME;
                    }

                    /*
                     * update either the color number field or the color name
                     * field
                     */

                    var_list[0].var_value = (IGRchar *) &active_display.color;
                    var_list[1].var = ADP_END_LIST;

                    GRupdate_setadp(&msg,setadp_form_ptr,var_list,&index);

                    break;
                }

                case SET_ADP_WEIGHT_NUM:
                {
                    buffersize = sizeof(active_display);
                    gr$get_active_display(msg = &msg,
                                          sizbuf = &buffersize,
                                          buffer = &active_display,
                                           nret = &nobytes);

                    FIfld_get_text_length(setadp_form_ptr,SET_ADP_WEIGHT_NUM,
                                          0,0,&text_length);

                    /*
                     * if the user cleared out the field, restore the weight
                     * number field to its previous value
                     */

                    if (text_length > 1)
                    {
                        FIfld_get_text(setadp_form_ptr,SET_ADP_WEIGHT_NUM,
                                       0,0,text_length,text_string,
                                       &sel_flag,&r_pos);

                        int_value = atoi( (IGRchar *) text_string);

                        if ((int_value >= GR_LO_WEIGHT) &&
                            (int_value <= GR_HI_WEIGHT))
                        {
                            active_display.weight = (IGRuchar) int_value;

                            /*
                             *  update the dpb and change the permanent
                             *  drawing parameters form
                             */

                            gr$put_active_display(msg = &msg,
                                                  sizbuf = &buffersize,
                                                  buffer = &active_display);
                        }
                        else  /* invalid weight */
                        {
                            /*
                             * display appropriate error message in the
                             * message field
                             */

                            ex$message(msgnumb = GR_E_InvWt,
                                       buff = error_string);

                            FIfld_set_text(setadp_form_ptr,SET_ADP_MSG_FIELD,
                                           0,0,error_string,FALSE);
                            msg = MSFAIL;
                        }
                    }
                    else  /* no chars entered; restore weight number field */
                    {
                        msg = GRw_no_value;
                    }

                    if (! (msg & 1))
                    {
                        /*
                         * update the weight number field
                         */

                        var_list[0].var = ADP_WEIGHT_NUM;
                        var_list[0].var_value = (IGRchar *) &active_display.weight;
                        var_list[1].var = ADP_END_LIST;

                        GRupdate_setadp(&msg,setadp_form_ptr,var_list,&index);
                    }

                    break;
                }

                case SET_ADP_WEIGHT_NAME:
                {
                    break;
                }

                case SET_ADP_STYLE_NUM:
                {
                    buffersize = sizeof(active_display);
                    gr$get_active_display(msg = &msg,
                                          sizbuf = &buffersize,
                                          buffer = &active_display,
                                           nret = &nobytes);

                    FIfld_get_text_length(setadp_form_ptr,SET_ADP_STYLE_NUM,
                                          0,0,&text_length);

                    /*
                     * if the user cleared out the field, restore the style
                     * number field to its previous value
                     */

                    if (text_length > 1)
                    {
                        FIfld_get_text(setadp_form_ptr,SET_ADP_STYLE_NUM,
                                       0,0,text_length,text_string,
                                       &sel_flag,&r_pos);

                        int_value = atoi( (IGRchar *) text_string);

                        if ((int_value >= GR_LO_STYLE) &&
                            (int_value <= GR_HI_STYLE))
                        {
                            active_display.style = (IGRuchar) int_value;

                            /*
                             *  update the dpb and change the permanent
                             *  drawing parameters form
                             */

                            gr$put_active_display(msg = &msg,
                                                  sizbuf = &buffersize,
                                                  buffer = &active_display);
                        }
                        else  /* invalid style */
                        {
                            /*
                             * display appropriate error message in the
                             * message field
                             */

                            ex$message(msgnumb = GR_E_InvSt,
                                       buff = error_string);

                            FIfld_set_text(setadp_form_ptr,SET_ADP_MSG_FIELD,
                                           0,0,error_string,FALSE);
                            msg = MSFAIL;
                        }
                    }
                    else  /* no chars entered; restore style number field */
                    {
                        msg = GRw_no_value;
                    }

                    if (! (msg & 1))
                    {
                        /*
                         * update the style number field
                         */

                        var_list[0].var = ADP_STYLE_NUM;
                        var_list[0].var_value = (IGRchar *) &active_display.style;
                        var_list[1].var = ADP_END_LIST;

                        GRupdate_setadp(&msg,setadp_form_ptr,var_list,&index);
                    }

                    break;
                }

                case SET_ADP_STYLE_NAME:
                {
                    break;
                }

                case SET_ADP_ANGLE_NUM:
                {
                    FIfld_get_text_length(setadp_form_ptr,SET_ADP_ANGLE_NUM,
                                          0,0,&text_length);

                    /*
                     * if the user cleared out the field, restore the angle
                     * field to its previous value
                     */

                    if (text_length > 1)
                    {
                        FIfld_get_text(setadp_form_ptr,SET_ADP_ANGLE_NUM,
                                       0,0,text_length,text_string,
                                       &sel_flag,&r_pos);

                        status = co$expreval(msg = &msg,
                                             expression = text_string,
                                             unit_type = GRIO_ANGLE,
                                             result = &temp_double);

                        if ((status & 1) && (msg & 1) &&
                            (temp_double >= -GR_MAXDOUBLE) &&
                            (temp_double <= GR_MAXDOUBLE))
                        {
                            active_angle = temp_double;

                            /*
                             * valid angle; update the dpb and the angle field
                             * so the angle will be displayed using the current
                             * angle units (user may have entered the angle
                             * using a different unit type)
                             */

                            buffersize = sizeof(active_angle);
                            gr$put_active_angle(msg = &msg,
                                                sizbuf = &buffersize,
                                                buffer = &active_angle);
                        }
                        else  /* invalid angle */
                        {
                            if (msg != GRw_no_value)
                            {
                                /*
                                 * display the appropriate error message
                                 */

                                ex$message(msgnumb = GR_E_InvAng,
                                           buff = error_string);

                                FIfld_set_text(setadp_form_ptr,
                                               SET_ADP_MSG_FIELD,
                                               0,0,error_string,FALSE);
                            }

                            /*
                             * get the active angle from the dpb
                             */

                            buffersize = sizeof(active_angle);
                            gr$get_active_angle(msg = &msg,
                                                sizbuf = &buffersize,
                                                buffer = &active_angle,
                                                nret = &nobytes);
                        }
                    }

                    /*
                     * update the active angle field
                     */

                    var_list[0].var = ADP_ANGLE_NUM;
                    var_list[0].var_value = (IGRchar *) &active_angle;
                    var_list[1].var = ADP_END_LIST;

                    GRupdate_setadp(&msg,setadp_form_ptr,var_list,&index);

                    break;
                }

                case SET_ADP_SCALE_NUM:
                {
                    FIfld_get_text_length(setadp_form_ptr,SET_ADP_SCALE_NUM,
                                          0,0,&text_length);

                    /*
                     * if the user cleared out the field, restore the scale
                     * field to its previous value
                     */

                    if (text_length > 1)
                    {
                        FIfld_get_text(setadp_form_ptr,SET_ADP_SCALE_NUM,
                                       0,0,text_length,text_string,
                                       &sel_flag,&r_pos);

                        temp_double = atof((IGRchar *)text_string);

                        if ((temp_double > GR_LO_SCALE) &&
                            (temp_double <= GR_MAXDOUBLE))
                        {
                            active_scale.Active_xscale =
                            active_scale.Active_yscale =
                            active_scale.Active_zscale = temp_double;

                            /*
                             * valid scale; update the dpb and all scale fields
                             */

                            buffersize = sizeof(active_scale);
                            gr$put_active_scale(msg = &msg,
                                                sizbuf = &buffersize,
                                                buffer = &active_scale);
                        }
                        else  /* invalid scale */
                        {
                            /*
                             * display the appropriate error message
                             */

                            ex$message(msgnumb = GR_E_InvScFac,
                                       buff = error_string);

                            FIfld_set_text(setadp_form_ptr,SET_ADP_MSG_FIELD,
                                           0,0,error_string,FALSE);
                            msg = MSFAIL;
                        }
                    }
                    else  /* no chars entered; restore scale field */
                    {
                        msg = GRw_no_value;
                    }

                    if (! (msg & 1))
                    {
                        /*
                         * get the active scale from the dpb
                         */

                        buffersize = sizeof(active_scale);
                        gr$get_active_scale(msg = &msg,
                                            sizbuf = &buffersize,
                                            buffer = &active_scale,
                                            nret = &nobytes);
                    }

                    /*
                     * udate the active scale fields
                     */

                    var_list[0].var = ADP_SCALE_NUM;
                    var_list[0].var_value = (IGRchar *) &active_scale;
                    var_list[1].var = ADP_END_LIST;

                    GRupdate_setadp(&msg,setadp_form_ptr,var_list,&index);

                    break;
                }
                
                case SET_ADP_X_SCALE_NUM:
                case SET_ADP_Y_SCALE_NUM:
                case SET_ADP_Z_SCALE_NUM:
                {
                    buffersize = sizeof(active_scale);
                    gr$get_active_scale(msg = &msg,
                                        sizbuf = &buffersize,
                                        buffer = &active_scale,
                                        nret = &nobytes);

                    FIfld_get_text_length(setadp_form_ptr,label,
                                          0,0,&text_length);

                    /*
                     * if the user cleared out the field, restore the scale
                     * field to its previous value
                     */

                    if (text_length > 1)
                    {
                        FIfld_get_text(setadp_form_ptr,label,
                                       0,0,text_length,text_string,
                                       &sel_flag,&r_pos);

                        temp_double = atof((IGRchar *)text_string);

                        if ((temp_double > GR_LO_SCALE) &&
                            (temp_double <= GR_MAXDOUBLE))
                        {
                            /*
                             * valid scale; update the dpb and the scale fields
                             */

                            switch (label)
                            {
                                case SET_ADP_X_SCALE_NUM:

                                    active_scale.Active_xscale = temp_double;
                                    break;

                                case SET_ADP_Y_SCALE_NUM:

                                    active_scale.Active_yscale = temp_double;
                                    break;

                                case SET_ADP_Z_SCALE_NUM:

                                    active_scale.Active_zscale = temp_double;
                                    break;
                            }

                            /*
                             *  update the dpb and change the permanent
                             *  drawing parameters form
                             */

                            gr$put_active_scale(msg = &msg,
                                                sizbuf = &buffersize,
                                                buffer = &active_scale);
                        }
                        else  /* invalid scale */
                        {
                            /*
                             * display the appropriate error message
                             */

                            switch (label)
                            {
                                case SET_ADP_X_SCALE_NUM:

                                    ex$message(msgnumb = GR_E_InvXsc,
                                               buff = error_string);
                                    break;

                                case SET_ADP_Y_SCALE_NUM:

                                    ex$message(msgnumb = GR_E_InvYsc,
                                               buff = error_string);
                                    break;

                                case SET_ADP_Z_SCALE_NUM:

                                    ex$message(msgnumb = GR_E_InvZsc,
                                               buff = error_string);
                                    break;
                            }
                            FIfld_set_text(setadp_form_ptr,SET_ADP_MSG_FIELD,
                                           0,0,error_string,FALSE);
                        }
                    }

                    /*
                     * update the scale fields
                     */

                    var_list[0].var = ADP_SCALE_NUM;
                    var_list[0].var_value = (IGRchar *) &active_scale;
                    var_list[1].var = ADP_END_LIST;

                    GRupdate_setadp(&msg,setadp_form_ptr,var_list,&index);

                    break;
                }
                   
                case SET_ADP_SMART_SKETCH:
                {
                  /*
                   * a save restore form for Smart Sketch Options is displayed
                   */
                  int        origin[2], xsize, ysize;
                  extern int FIf_get_location(), FIf_get_size();

                  /* calculate offset for Smart Sketch Options form */
                  FIf_get_location(setadp_form_ptr, &origin[0], &origin[1]);
                  FIf_get_size(setadp_form_ptr, &xsize, &ysize);
                  origin[1] += (ysize +2);

                  /* reset the button (10/6/93 : SRH) */
		  FIg_set_state_off ( setadp_form_ptr, SET_ADP_SMART_SKETCH );

                  ss$options ( origin = origin );
                }

                default:
                    break;

            }  /* end switch on form_data->label */
            break;    /* case SET_ADP_FORM_LABEL */

        case GRWEIGHT_SUBFORM_LABEL:

            switch (label)
            {
                 case SET_ADP_ACCEPT_BUTTON:

                    /*
                     * erase the subform
                     */

                    FIf_erase(active_subform_ptr);

                    /*
                     * Pop the subform button on the active drawing parameters
                     * form and set the button_label to NEG_ONE to indicate no
                     * subforms are currently active (displayed).
                     */

                    FIg_set_state_off(setadp_form_ptr,button_label);
                    button_label = NEG_ONE;

                    /*
                     * send a message to update the Set Active Drawings
                     * Parameters form with the current DPB values in case one
                     * or more were changed while the subform was save/restore,
                     * in which case the the SetADP form could not be updated
                     */

                    buffersize = sizeof(active_layer);
                    gr$get_active_level(msg = &msg,
                                        sizbuf = &buffersize,
                                        buffer = &active_layer,
                                        nret = &nobytes);

                    buffersize = sizeof(active_display);
                    gr$get_active_display(msg = &msg,
                                          sizbuf = &buffersize,
                                          buffer = &active_display,
                                          nret = &nobytes);

                    buffersize = sizeof(active_angle);
                    gr$get_active_angle(msg = &msg,
                                        sizbuf = &buffersize,
                                        buffer = &active_angle,
                                        nret = &nobytes);

                    buffersize = sizeof(active_scale);
                    gr$get_active_scale(msg = &msg,
                                        sizbuf = &buffersize,
                                        buffer = &active_scale,
                                        nret = &nobytes);

                    var_list[0].var = ADP_LAYER_NUM;
                    var_list[0].var_value = (IGRchar *) &active_layer;
                    var_list[1].var = ADP_COLOR_NUM;
                    var_list[1].var_value = (IGRchar *) &active_display.color;
                    var_list[2].var = ADP_WEIGHT_NUM;
                    var_list[2].var_value = (IGRchar *) &active_display.weight;
                    var_list[3].var = ADP_STYLE_NUM;
                    var_list[3].var_value = (IGRchar *) &active_display.style;
                    var_list[4].var = ADP_LAYER_NAME;
                    var_list[4].var_value = (IGRchar *) &active_layer;
                    var_list[5].var = ADP_COLOR_NAME;
                    var_list[5].var_value = (IGRchar *) &active_display.color;
                    var_list[6].var = ADP_ANGLE_NUM;
                    var_list[6].var_value = (IGRchar *) &active_angle;
                    var_list[7].var = ADP_SCALE_NUM;
                    var_list[7].var_value = (IGRchar *) &active_scale;
                    var_list[8].var = ADP_END_LIST;

                    GRupdate_setadp(&msg,setadp_form_ptr,var_list,&index);

                    /*
                     * if there are no active save/restore windows, update
                     * the Drawing Parameters form in case one of its
                     * parameters was changed and it could not be updated
                     * because a save/restore window was active
                     */

                    if (!(ige$SR_active()))
                    {
                        var_list[4].var = ADP_END_LIST;
                        GRupdate_adp(&msg, NULL, var_list, &index);
                    }
                    break;

                case SET_ADP_PERM_WIN_BUTTON:

                    /*
                     * forms interface software converts the save/restore
                     * window to a permanent window - checks for a certain
                     * gadget type (FIcbar) and label (5)
                     */

                    break;

                default:

                    /*
                     * get active display values from the DPB
                     */

                    buffersize = sizeof(active_display);
                    gr$get_active_display(msg = &msg,
                                          sizbuf = &buffersize,
                                          buffer = &active_display,
                                          nret = &nobytes);

                    switch (form_label)
                    {
                        case GRWEIGHT_SUBFORM_LABEL:

                            switch (label)
                            {
                                case GRWEIGHT_FIELD:

                                    FIfld_get_value(active_subform_ptr,label,
                                                    0,0,&temp_double,&sel_flag,
                                                    &r_pos);

                                    if ((temp_double >= GR_LO_WEIGHT) &&
                                        (temp_double <= GR_HI_WEIGHT))
                                    {
                                        /*
                                         * valid weight; update the dpb
                                         */

                                        active_display.weight = (IGRuchar)temp_double;

                                        gr$put_active_display(msg = &msg,
                                                              sizbuf = &buffersize,
                                                              buffer = &active_display);
                                    }
                                    break;

                                case GRWEIGHT_SLIDER:

                                    /*
                                     * value returned from the slider must
                                     * be valid
                                     */

                                    active_display.weight = (IGRuchar) value;

                                    gr$put_active_display(msg = &msg,
                                                          sizbuf = &buffersize,
                                                          buffer = &active_display);
                                    break;

                                default:  /* invalid type */

                                    break;
                            }

                            /*
                             * update the weight subform
                             */

                            GRupdweightform(&msg,
                                            active_display.weight,
                                            active_subform_ptr);
                            break;


                        default:  /* invlaid type */

                            break;
                    }  /* end switch */
            }  /* end switch on subform labels */
            break;

        default:  /* invalid type */

            break;
    }  /* end switch on form_label */
}


IGRint GRupdate_setadp_subforms(active_display)

struct IGRdisplay     *active_display;

{
    if (button_label > NEG_ONE)
    {
        IGRlong    msg;

        if (button_label == SET_ADP_WEIGHT_BUTTON)
        {
            GRupdweightform(&msg,active_display->weight,active_subform_ptr);
        }
    }

    return(TRUE);
}


IGRint GRdisplay_setadp_subforms(display)

IGRint display;

{
    if (button_label > NEG_ONE)
    {
        if (display)
        {
            FIf_display(active_subform_ptr);
        }
        else
        {
            IGRlong  msg;
            Form     setadp_form_ptr;

            /*
             * erase the subform and pop the corresponding button
             * on the Set Active Drawing Parameters form
             */

#ifdef X11
            FIf_delete(active_subform_ptr);
            active_subform_ptr = NULL;
            color_form_ptr = NULL;
            weight_form_ptr = NULL;
#else
            FIf_erase(active_subform_ptr);
#endif
            GRcreate_setadp(&msg,FALSE,&setadp_form_ptr);
            FIg_set_state_off(setadp_form_ptr,button_label);
            button_label = NEG_ONE;
        }
    }

    return(TRUE);
}

/*
Name
        GRdelete_adp_subforms

Description
        This function deletes the ADP subforms for color and weight.  It is
        called from the GRadp.sleep method to ensure that journaling tracks
        all form creation and deletion properly across saves.

History
        mrm     02/03/93    creation
*/

void GRdelete_adp_subforms()
{
    /* delete subforms */

    if (color_form_ptr)
    {
        FIf_delete(color_form_ptr);
        color_form_ptr = NULL;
    }
    if (weight_form_ptr)
    {
        FIf_delete(weight_form_ptr);
        weight_form_ptr = NULL;
    }

    /* reset static variables */
    button_label = -1;   /* pushed subform button label   */
    num_colors = 0;      /* # of buttons on color palette */
}
