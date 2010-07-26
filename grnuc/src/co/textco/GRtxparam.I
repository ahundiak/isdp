/*
Name
        GRtxparam

Description
        This file contains the functions used to drive the Text Parameters 
        form.

        The Text Parameters form is persistent, and therefore not tied to a
        command object.  A snapshot of the active text parameters is taken
        when the form is initialized, and stored with the form.  That data is
        manipulated as long as the form remains active, and is copied to the
        dpb each time something is changed (Paul said so).

History
        mrm     09/22/93    My birthday.  The big 3-0.  Whatta way to spend it.
	jjm     11/01/93    Switched around the filled font parameters. Added
			    a message to be displayed when retrieving fonts.
	jjm     12/22/93    Moved free(t) to the end of the callback function.
        satish  06/19/95    Changed FIfld_set_value to FIfld_set_text for
			    the cases where the height is not equal to width
		            of the active font.
*/

class implementation Root;

#include <alloca.h>
#include <FI.h>
#include "OMminimum.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "exmacros.h"
#include "griodef.h"
#include "griomacros.h"
#include "grdpb.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "gotextdef.h"
#include "dpbco.h"
#include "grmsg.h"
#include "fontdef.h"
#include "font.h"
#include "exlocaledef.h"
#include "exlocale.h"
#include "grmessage.h"
#include "msmacros.h"

from GRfm import GRmake_entry;

// form labels
#define F_MAIN          0
#define F_JUST          1

// parameter form gadget labels
#define L_MESSAGE_FIELD 10
#define L_HEIGHT        18
#define L_WIDTH         19
#define L_SIZE          22
#define L_CHAR_SPACING  20
#define L_LINE_SPACING  21
#define L_JUSTIFICATION 23
#define L_FILL_MODE     24
#define L_FONT          32
#define L_FRAC_FONT     34
#define L_PLACE_TEXT    28

// justification form gadget labels
#define L_JUST_0      13

#define SIZE 64

// structure to maintain information in the form
typedef struct
{
    Form main_form, just_form;
    struct GRdpb_text_symb sym;
}   tpinfo;

/*
Name
        GRget_text_size_string

Description
        This helper function accepts a scalar value and converts it to a
        distance string.
*/

static void GRget_text_size_string(double text_size, char *size_string)
{
    int msg;
    short num_alias = 1, field_size = SIZE;
    OMuword mod_osnum;

    ex$get_cur_mod(osnum = &mod_osnum);
    co$cvt_imp_to_alias(msg = &msg,
                        osnum = mod_osnum,
                        unit_type = "UOM_DISTANCE",
                        working_units = &text_size, 
                        num_alias = &num_alias,
                        num_conversions = 1,
                        field_size = &field_size,
                        cvt_list = size_string);
}

/*
Name
        GReval_keyin

Description
        This function evaluates a keyin as a distance value.
*/

static void GReval_keyin(char *keyin, double *value)
{
    int msg;
    char buf[SIZE];

    co$epp(msg = &msg, string = keyin, sizebuf = SIZE, buffer = buf);
    co$expreval(msg = &msg,
                expression = buf,
                unit_type = "UOM_DISTANCE",
                result = value);
}

/*
Name
        GRnotify_text_command

Description
        This function checks a global variable to see whether the Place Text
        command is in dynamics, and if so issues a FORM_FINISHED event.  This
        event is interpreted by the command to pick up the new text parameters
        from the dpb.
*/

extern int GRtext_dynamics_in_progress;

static void GRnotify_text_command()
{
    if (GRtext_dynamics_in_progress)
    {
        long msg;
        int response = EX_FORM_FINISHED;
        ex$putque(msg = &msg, response = &response);
    }
}

/*
Name
        GRtext_param_callback

Description
        This is the form notification function for the Text Parameters form. */

int GRtext_param_callback(int f_label, int g_label, double value, Form form)
{
    char buf[SIZE];
    int sts, sel, pos, n;
    unsigned int mask,Free_t=0;
    short font_num, *p_font;
    double d;
    tpinfo *t;

    FIf_get_user_pointer(form, (char *)&t);
    FIfld_set_text(form, FI_MSG_FIELD, 0, 0, "", 0);

    switch (f_label)
    {
      case F_MAIN:

        switch (g_label)
        {
          case FI_ACCEPT:
	    

            gr$put_text_symb(buffer = &t->sym); // overkill, but what the heck
            GRnotify_text_command();
            FIf_erase(t->just_form);
            FIf_delete(t->just_form);
            FIf_erase(form);
            FIf_delete(form);
	    Free_t = 1;
            break;

          case L_PLACE_TEXT:
            FIf_cvrt_to_perm_win(form);
            break;
                
          case L_FONT:
          case L_FRAC_FONT:
            if (g_label == L_FONT)
                mask = CO_font, p_font = &t->sym.Active_font;
            else
                mask = CO_frac, p_font = &t->sym.Active_fraction_font;
            FIfld_get_text(form, g_label, 0, 0, SIZE, buf, &sel, &pos);
            sts = COdpb_get_font(buf, &font_num, mask, CO_name_to_attr);
            if (sts & 1)
                *p_font = font_num;
            else
            {
                // try to retrieve the font

                long msg;
                short font_flags = 0, vfont_num = -1;
                OMuword mod_os;
                OM_S_OBJID mod_id, fontmgr_id;
                struct EX_locale_var var_list;
                struct EX_fonts font_parameters;
		char fontmsg[256];

                // make sure this is a valid text/fraction font
                var_list.var = EX_font_parameters;
                var_list.var_ptr = (IGRchar *) &font_parameters;
                ex$inq_locale(msg = &msg,
                              var = &var_list,
                              flags = EX_Text | EX_Logical_Name,
                              identifier = buf);
                if (((g_label == L_FONT) && 
                     (font_parameters.properties & EX_Text_Font)) ||
                    ((g_label == L_FRAC_FONT) &&
                     (font_parameters.properties & EX_Frac_Font)))
                {
                    ex$message(msgnumb = GR_I_TxParamLdFnt,
                               buff = fontmsg,
                               buffer_size = 256,
			       type = "%s",
			       var = buf );
                    FIg_set_text(form,L_MESSAGE_FIELD,fontmsg);

                    // retrieve the font
                    if (font_parameters.properties & EX_Sixteen_Bit)
                        font_flags |= SIXTEEN_BIT;
                    else if (font_parameters.properties & EX_Eight_Bit)
                        font_flags |= EIGHT_BIT;
                    if (font_parameters.properties & EX_Text_Font)
                        font_flags |= TEXT_FONT;
                    else if (font_parameters.properties & EX_Frac_Font)
                        font_flags |= FRACTION_FONT;
                    ex$get_cur_mod(id = &mod_id, osnum = &mod_os);
                    ex$get_super(mod_id = mod_id,
                                 mod_osnum = mod_os,
                                 super_name = FONTMGR_NO_NAME,
                                 create = TRUE,
                                 super_class = "GRfm",
                                 super_id = &fontmgr_id);
                    sts = om$send(msg = message GRfm.GRmake_entry
                                  (&msg, (IGRuchar *)buf, (IGRuchar *)buf,
                                   font_flags, &vfont_num),
                                  senderid = NULL_OBJID,
                                  targetid = fontmgr_id,
                                  targetos = mod_os);

                    if (sts & msg & 1)
                        *p_font = vfont_num;

                    fontmsg[0]='\0';
                    FIg_set_text(form,L_MESSAGE_FIELD,fontmsg);
                }
                else
                    sts = 0;
                if (!(sts & 1))
                {
                    COtool_fi_message(form, FI_MSG_FIELD, GR_E_FtNotFnd, 40);
                    COdpb_get_font(buf, p_font, mask, CO_attr_to_name);
                    FIfld_set_text(form, g_label, 0, 0, buf, 0);
                }
            }
            break;

          case L_CHAR_SPACING:
            FIfld_get_text(form, g_label, 0, 0, SIZE, buf, &sel, &pos);
            GReval_keyin(buf, &d);
            if (d > 0)
                t->sym.Active_charspac = d;
            FIfld_set_value(form, g_label, 0, 0, t->sym.Active_charspac, 0);
            break;

          case L_LINE_SPACING:
            FIfld_get_text(form, g_label, 0, 0, SIZE, buf, &sel, &pos);
            GReval_keyin(buf, &d);
            if (d > 0)
                t->sym.Active_linespac = d;
            FIfld_set_value(form, g_label, 0, 0, t->sym.Active_linespac, 0);
            break;

          case L_HEIGHT:
          case L_WIDTH:
          case L_SIZE:
            FIfld_get_text(form, g_label, 0, 0, SIZE, buf, &sel, &pos);
            GReval_keyin(buf, &d);
            if (d <= 0)
                d = (g_label == L_WIDTH) ? 
                    t->sym.Active_width : t->sym.Active_height;
            GRget_text_size_string(d, buf);

            FIfld_set_text(form, g_label, 0, 0, buf, 0);
            if (g_label == L_SIZE)
            {
                t->sym.Active_height = d;
                t->sym.Active_width = d;
                FIfld_set_text(form, L_HEIGHT, 0, 0, "", 0);
                FIfld_set_text(form, L_WIDTH, 0, 0, "", 0);
            }
            else
            {
                FIfld_set_text(form, L_SIZE, 0, 0, "", 0);
                if (g_label == L_HEIGHT)
                {
                    t->sym.Active_height = d;
                    GRget_text_size_string(t->sym.Active_width, buf);
                    FIfld_set_text(form, L_WIDTH, 0, 0, buf, 0);
                }
                else
                {
                    t->sym.Active_width = d;
                    GRget_text_size_string(t->sym.Active_height, buf);
                    FIfld_set_text(form, L_HEIGHT, 0, 0, buf, 0);
                }
            }
            break;

          case L_JUSTIFICATION:
            FIf_display(t->just_form);
            break;

          case L_FILL_MODE:
            if (value)
                t->sym.Active_flags &= ~GRFILLED_TEXT;
            else
                t->sym.Active_flags |= GRFILLED_TEXT;
            break;
        }

        break;

      case F_JUST:

        t->sym.Active_just = g_label - L_JUST_0;
        FIg_get_off_symbol_index(form, g_label, &n);
        FIf_erase(form);
        FIg_set_off_symbol_index(t->main_form, L_JUSTIFICATION, n);
        FIg_set_state_off(t->main_form, L_JUSTIFICATION);
        FIg_display(t->main_form, L_JUSTIFICATION);
        break;
    }

    // store the data in the dpb for immediate use
    gr$put_text_symb(buffer = &t->sym);
    GRnotify_text_command();
    if (Free_t) free(t);

    return(1);
}

/*
Name
        GRtext_param_init

Description
        This function creates, initializes, and displays the Text Parameters
        form.  It is invoked through the driveform ppl command.
*/

int GRtext_param_init(char *form_name)
{
    int sts, n, ii, num_entries, num_chars, t_index, f_index;
    IGRlong msg;
    tpinfo *t;
    char buf[SIZE];
    struct EX_locale_var var_list;
    struct EX_fonts *fonts;

    // allocate some memory
    t = (tpinfo *)calloc(1, sizeof(tpinfo));

    // create the main form
    t->main_form = NULL;
    sts = FIf_new(F_MAIN, form_name, GRtext_param_callback, &t->main_form);
    if ((sts != FI_SUCCESS) || (t->main_form == NULL))
    {
        printf("GRtext_param_init: FIf_new(%s): %d\n", form_name, sts);
        return(0);
    }

    // get the active text info & initialize the form
    gr$get_text_symb(buffer = &t->sym);
    FIfld_set_value(t->main_form, L_CHAR_SPACING, 0, 0,
                    t->sym.Active_charspac, 0);
    FIfld_set_value(t->main_form, L_LINE_SPACING, 0, 0,
                    t->sym.Active_linespac, 0);
    FIg_set_state(t->main_form, L_FILL_MODE,
                  (t->sym.Active_flags & GRFILLED_TEXT) ? FALSE : TRUE);

    if (t->sym.Active_height == t->sym.Active_width)
    {
        GRget_text_size_string(t->sym.Active_width, buf);
        FIfld_set_text(t->main_form, L_SIZE, 0, 0, buf, 0);
        FIfld_set_text(t->main_form, L_HEIGHT, 0, 0, "", 0);
        FIfld_set_text(t->main_form, L_WIDTH, 0, 0, "", 0);
    }
    else
    {
        GRget_text_size_string(t->sym.Active_height, buf);
        FIfld_set_text(t->main_form, L_HEIGHT, 0, 0, buf, 0);

        GRget_text_size_string(t->sym.Active_width, buf);
        FIfld_set_text(t->main_form, L_WIDTH, 0, 0, buf, 0);

        FIfld_set_text(t->main_form, L_SIZE, 0, 0, "", 0);
    }
    COdpb_get_font(buf, &t->sym.Active_font, CO_font, CO_attr_to_name);
    FIfld_set_text(t->main_form, L_FONT, 0, 0, buf, 0);
    COdpb_get_font(buf, &t->sym.Active_fraction_font, CO_frac,
                   CO_attr_to_name);
    FIfld_set_text(t->main_form, L_FRAC_FONT, 0, 0, buf, 0);

    // get a list of fonts in the current file - first, get the number of
    // entries in the locale font table
    var_list.var = EX_number_fonts;
    var_list.var_ptr = (IGRchar *) &num_entries;
    ex$inq_locale(msg = &msg, var = &var_list, flags = EX_Text);

    // get the logical name of each entry in the locale font table
    fonts = (struct EX_fonts *)alloca(num_entries * sizeof(struct EX_fonts));
    var_list.var = EX_all_fonts;
    var_list.var_ptr = (IGRchar *)fonts;
    ex$inq_locale(msg = &msg, var = &var_list, flags = EX_Text);

    // place each logical name on the proper associated list
    for (ii = num_entries - 1, t_index = f_index = 0; ii >= 0; --ii)
    {
        if ((fonts[ii].properties & EX_Text_Font) ||
            (fonts[ii].properties & EX_Frac_Font))
        {
            num_chars = strlen(fonts[ii].name);
            if (GRisitfnt(&msg, fonts[ii].name, &num_chars, NULL))
            {
                if (fonts[ii].properties & EX_Text_Font)
                    FIfld_set_list_text(t->main_form, L_FONT, t_index++,
                                        0, fonts[ii].name, 0);
                else
                    FIfld_set_list_text(t->main_form, L_FRAC_FONT, f_index++,
                                        0, fonts[ii].name, 0);
            }
        }
    }

    // create the subform & use it to get the proper justification symbol for
    // the main form
    t->just_form = NULL;
    sts = FIf_new(F_JUST, "GRTextJust", GRtext_param_callback, &t->just_form);
    if ((sts != FI_SUCCESS) || (t->main_form == NULL))
    {
        printf("GRtext_param_init: FIf_new(%s): %d\n", form_name, sts);
        return(0);
    }
    FIg_set_state_on(t->just_form, L_JUST_0 + t->sym.Active_just);
    FIg_get_off_symbol_index(t->just_form, L_JUST_0 + t->sym.Active_just, &n);
    FIg_set_off_symbol_index(t->main_form, L_JUSTIFICATION, n);

    // store the form data
    FIf_set_user_pointer(t->main_form, (char *)t);
    FIf_set_user_pointer(t->just_form, (char *)t);

    // display the form
    FIf_display(t->main_form);
    return(1);
}

end implementation Root;
