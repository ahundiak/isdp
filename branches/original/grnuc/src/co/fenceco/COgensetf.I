/*
Name
        COgensetf

Description
        This file contains functions used by the group generator commands.

History
        mrm     01/11/91    creation
        AIC     02/03/92    include alloca.h
        jjm     02/18/92    changed code to support ver. 2.0 linestyle form
        dhm     06/19/92    changed code to support layer form
        scw     07/10/92    ansi conversion
*/

class implementation COgenset;

#include <stdio.h>
#include <FI.h>
#include "OMminimum.h"
#include "igrtypedef.h"
#include "igr.h"
#include "exdef.h"
#include "ex.h"
#include "exmacros.h"
#include "gr.h"
#include "igrdp.h" 
#include "dp.h" 
#include "godef.h"
#include "go.h" 
#include "griodef.h"
#include "grio.h"
#include "lcdef.h"
#include "lc.h"
#include "lcmacros.h"
#include "madef.h"
#include "msdef.h"
#include "dpdef.h"
#include "msmacros.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "grdpbmacros.h"
#include "dpmacros.h"
#include "griomacros.h"
#include "grpgendef.h"
#include "grpgen.h"
#include "adpdef.h"
#include "grgsmacros.h"
#include "grmessage.h"
#include "dpdls.h"
#include <alloca.h>

from DPlvldir import translate_level_to_mask;

extern char *strrchr();
extern IGRint GRnumber_conversion(), GRcolor_conversion();

/*
Name
        COall

Description
        This function determines whether a given string indicates an
        "all" or "don't care" condition.  In order for the condition
        to be considered satisfied, the string must be empty, contain
        a single character '*', or contain the string returned by
        the message key GR_I_All.
*/

IGRint COall(string)
IGRchar *string;
{
    IGRint sts = FALSE;

    if (string[0] == NULL || string[0] == '*')
        sts = TRUE;
    else
    {
        IGRchar all[32];

        ex$message(msgnumb = GR_I_All, buff = all);
        sts = !strcmp(string, all);
    }
    return(sts);
}

/*
Name
        COlykytomask

Description
        This function converts a layer keyin to a layer mask.  A null
        pointer may be sent in if the caller merely wants to verify
        that the keyin is valid.

Synopsis
        IGRint *msg             O   return code
        struct GRmd_env *mod    I   module information
        IGRchar *keyin          I   string to examine
        IGRint *mask            O   layer mask
       ()                      O   TRUE/FALSE

History
        mrm     01/11/91    creation
*/

#define MASKSIZE   ((DP_NUM_OF_LEVELS - 1)/32 + 1)

IGRint COlykytomask(msg, mod, keyin, mask)
IGRint *msg;
struct GRmd_env *mod;
IGRchar *keyin;
IGRint *mask;
{
    IGRint     sts, i; 
    IGRlong    *p_mask;
    OM_S_OBJID lvdir_id;

    sts = *msg = MSSUCC;

    if (COall(keyin) && mask)
    {
        /* all layers */

        for (i = 0; i < MASKSIZE; i++) mask[i] = ~0;
    }
    else  /* convert keyin to appropriate layer mask */
    {
        *msg = ex$get_super(mod_id = mod->md_id.objid,
                            mod_osnum = mod->md_id.osnum,
                            super_name = "DPLVLDIR",
                            create = FALSE,
                            super_id = &lvdir_id);
        if (*msg & 1)
        {
            i = MASKSIZE * sizeof(IGRint);
            p_mask = (IGRlong *)((mask) ? mask : (IGRint *) alloca(i));

            sts = om$send(msg = message DPlvldir.translate_level_to_mask
                               (msg, keyin, p_mask),
                          senderid = NULL_OBJID,
                          targetid = lvdir_id,
                          targetos = mod->md_id.osnum);
        }
    }

    return(sts & *msg & 1);
}

/*
Name
        COgenset_init_form

Description
        This function is used to initialize the Generate Set form.
*/

IGRint COgenset_init_form(form)
Form form;
{
    IGRchar *c, buf[BUFSIZ];
    IGRint i, j, sel, count;
    IGRint sts, msg;
    struct GRid window, fence;
    struct GRmd_env mod;
    struct GRelclass_f *p;
    struct var_list vlist[2];
    struct COgenset_info *info;

    /* get the pointer to this form's data */

    FIf_get_user_pointer(form, &info);

    /*========== fill in the element type field ==========*/

    /* get the number of classes stored in the dpb */

    vlist[0].var = DPB_NUMBER_CLASSES;
    vlist[0].var_ptr =(IGRchar *)&count;
    vlist[1].var = END_PARAM;

    gr$set_inq(msg = &sts, var_list = vlist);

    /* allocate memory for the data */

    i = sizeof(struct GRelclass_f) * count;
    info->elclass_count = count;
    info->elclass =(struct GRelclass_f *)om$malloc(size = i);

    /* retrieve the data from the dpb */

    vlist[0].var = DPB_GET_CLASSES;
    vlist[0].var_ptr =(IGRchar *)info->elclass;

    gr$set_inq(msg = &sts, var_list = vlist);

    /* put the data on the form, indenting to show ownership depth */

    for (i = 0; i < count; i++)
    {
        p = &info->elclass[i];
        buf[0] = NULL;
        for (j = 0; j < p->depth; j++) strcat(buf, "  ");
#ifndef BELIEVE_RETURN_CODE
        c = &buf[j * 2];
        *c = NULL;
#endif
        sts = ex$message(msgname = p->ascii_key, buff = &buf[j * 2]);
#ifndef BELIEVE_RETURN_CODE
        if (*c == NULL)
#else
        if (!(sts & 1))
#endif
            strcat (buf, p->ascii_key);
        sel =(int)p->properties & DPB_LOCATABLE;
        FIfld_set_text(form, TYPE_FIELD, i, 0, buf, sel);
    }

    /*========== fill in proper volume check mark ==========*/

    FIg_set_state_on(form, IN_CHECK);

    /* use fence if one exists */

    gr$get_module_env(buffer = &mod);

    sts = gr$gsget_fence (msg = &msg, fence_id = &fence);

    if (sts & msg & 1)
    {
        FIg_set_state_on(form, FENCE_CHECK);
    }
    else
    {
        /* get a window */

        sts = COgetwin(&msg, &mod, &window, buf);

        if (sts & msg & 1)
         {
            FIfld_set_text(form, WINDOW_FIELD, 0, 0, buf, 0);
            FIg_set_state_on(form, WINDOW_CHECK);
        }
        else
        {
            /* no windows active; set volume to entire file */

            ex$filename(name = buf, len = BUFSIZ);
            c = (c = strrchr(buf, '/')) ? c + 1 : buf;
            FIfld_set_text(form, FILE_FIELD, 0, 0, c, 0);
            FIg_set_state_on(form, FILE_CHECK);
        }
    }        

    /*========== fill in color ==========*/

    ex$message(msgnumb = GR_I_All, buff = buf);
    FIfld_set_text(form, COLOR_FIELD, 0, 0, buf, 0);

    /*========== fill in weight ==========*/
    FIfld_set_text(form, WEIGHT_FIELD, 0, 0, buf, 0);

    /*========== fill in style ==========*/
    FIfld_set_text(form, STYLE_FIELD, 0, 0, buf, 0);

    /*========== fill in layer ==========*/
    FIfld_set_text(form, LAYER_FLD, 0, 0, buf, 0);

    return(TRUE);
}

/*
Name
        COpositionform

Description
        This function will move the a subform to the lower left of the 
        specified form.
*/

IGRint COpositionform(form, subform)
Form form, subform;
{
    int xpos, ypos, xsize, ysize;

    FIf_get_location(form, &xpos, &ypos);
    FIf_get_size(form, &xsize, &ysize);
    FIf_set_location(subform, xpos, ypos + ysize);
    return(TRUE);
}

/*
Name
        COactgad

Description
        This function activates selected gadgets on a form based upon
        the conversion of a string to a mask.  It is used to activate
        the "on" gadgets on the Color and Linestyle subforms. 
*/


#argsused
IGRint COactgad(buf, form, mask, mask_size, symb, lo, hi, osnum,
                 form_label, first_label, last_label)
IGRchar *buf;
Form form;
unsigned char *mask;
IGRint mask_size, symb, lo, hi, form_label, first_label, last_label;
OMuword osnum;
{
    IGRuchar u;
    IGRint sts, msg, i, j, k, (*func)(), alpha;
    struct GRmd_env   mod;

    u = (IGRuchar) 0;
    sts = !COall(buf);

    if (form_label == COLOR_FORM)
    {
        func = GRcolor_conversion;
        alpha = TRUE;
    }
    else
    {
        func = GRnumber_conversion;
        alpha = FALSE;
    }

    if (form_label == LAYER_FORM)
    {
       gr$get_module_env(buffer = &mod);
       sts = COlykytomask(&msg, &mod, buf, (IGRint *) mask);
    }
    else if (sts)
    {
       sts = GRparse_multiple_entry_keyin(buf, mask, func, alpha,
                                          lo, hi, osnum);
    }

    if (!(sts & 1))
    {
        for (i = 0; i < mask_size; i++) mask[i] = (IGRuchar)~0;
    }

    if (form_label == COLOR_FORM)
    {
        u = mask[0];
        mask[0] |= 1;   /* don't turn off the entire palette group! */
    }

    for (i = 0, j = first_label; i < mask_size && j < last_label; i++)
    {
          for (k = 0; k < 8; k++)
          {
              if (form_label == STYLE_FORM)
                  /* Forms code only accepts a 1 as true, so send one in */
                  FImcf_set_select(form, LINESTYLE_FIELD, j++,
                                         ((1 << k) & mask[i])?1:0);
              else if (form_label == LAYER_FORM)
                  FImcf_set_select(form, 16, j++, ((1 << k) &mask[i]) ? 1 : 0);
              else
                  FIg_set_state(form, j++,((1 << k) & mask[i]));
          }
    }

    if (form_label == COLOR_FORM)
    {
        /* Set the background button.  The loop above began with the
           group label so that the color-to-button mapping was
           one-to-one.  This caused the first entry in the mask to
           actually set the group rather than the background button.
           This was immediately corrected by the rest of the loop, but
           now the button needs to be set correctly */

        FIg_set_state(form, GRCOLOR_BACKGROUND_BUTTON, u & 1);
    }

    return(TRUE);
}

/*
Name
        COgadtostr

Description
        This function translates a sequence of gadgets into an ASCII
        string representing the on/off state of the sequence.  The
        function is used to map the settings on the Color and Style
        subforms to the strings displayed on the Generate Set form.
*/

IGRint COgadtostr(form, form_label, first_label, last_label, buf)
Form form;
IGRint form_label, first_label, last_label;
IGRchar *buf;
{
    IGRchar lbuf[32];
    IGRint i, j, state, start, prev_state = FALSE, in_seq = FALSE, off = 0;

    buf[0] = NULL;
    if (form_label == COLOR_FORM)
    {
        /* Gadget labels on this form are screwy.  They go from
           GRCOLOR_BACKGROUND_BUTTON(14, color 0), to the palette
           group label(label 15), to color 1(label 16),
           color 2(label 17), and so on. */

        start = 1;
        FIg_get_state(form, GRCOLOR_BACKGROUND_BUTTON, &prev_state);
        if (prev_state)
            sprintf(buf, "0");
        else
            off++;
    }
    else
    {
        start = 0;
    }
    for (i = first_label, j = start; i < last_label; i++, j++)
    {
        if (form_label==STYLE_FORM)
            FImcf_get_select(form, LINESTYLE_FIELD, i, &state);
        else if (form_label == LAYER_FORM)
            FImcf_get_select(form, 16, i, &state);
        else
            FIg_get_state(form, i, &state);

        if (state)
        {
            if (prev_state)
            {
                if (!in_seq)
                {
                    strcat(buf, "-");
                    in_seq = TRUE;
                }
            }
            else
            {
                sprintf(lbuf, "%d", j);
                strcat(buf, lbuf);
            }
        }
        else
        {
            if (prev_state)
            {
                if (in_seq)
                    sprintf(lbuf, "%d,", j - 1);
                else
                    sprintf(lbuf, ",");
                strcat(buf, lbuf);
            }
            in_seq = FALSE;
            off++;
        }
        prev_state = state;
    }
    i = strlen(buf) - 1;
    if (buf[i] == ',')
        buf[i] = NULL;
    else if (buf[i] == '-')
    {
        sprintf(&buf[i+1], "%d", j - 1);
    }
    if (off == 0)
    {
        ex$message(msgnumb = GR_I_All, buff = buf);
    }
    return(TRUE);
}

end implementation COgenset;

