/*
Name
        COcsreview

Description
        This file contains the implementation for the review coordinate
        system command.

History
        03/08/88:mrm:creation
        06/14/91:mrm:convert to I/FORMS
        08/08/91:dhm:added type argument to get_cs_info
	02/10/93:Carlos M. Diaz:added COdelete_rev_coord_sys_form function
        03/01/93    mrm     Make sure all fields on the form are initialized.
*/

class implementation COcsreview;

#include <alloca.h>
#include <FI.h>
#include "msdef.h"
#include "msmacros.h"
#include "grmessage.h"
#include "godef.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "csdef.h"
#include "csmacros.h"
#include "griodef.h"
#include "griomacros.h"
#include "DItypedef.h"
#include "DImacros.h"

#define REVIEW_FORM                 1
#define ACTIVE_CS_FIELD             16
#define LIST_FIELD                  11
#define ACTIVATE_DELETE_TOGGLE      20

%safe
static Form review_form = NULL;
%endsafe

from GRgraphics import GRdelete, GRdisplay;
from GRgencs import GRget_cs_info;

/*
Name
 COdelete_rev_coord_sys_form  
Abstract
 This function is called from the super_object when 
 it gets the sleep message. It deletes the form so that it 
 won't interfere with journaling when doing a save.
Synopsis

Description
 
Return Value

Notes

Index

Keywords
  delete,form,journaling

History
  02/10/93 : Carlos M. Diaz : created
*/

void COdelete_rev_coord_sys_form()
{
  if (review_form)
  {
    FIf_delete(review_form);
    review_form = NULL;
  }
}

IGRint COupdate_cs_form ()
{
    IGRchar name[GRNAME_SIZE], desc[GRNAME_SIZE], *n, *d, no_name[64];
    IGRint sts, msg, i, size, descsize;
    OMuint count;
    OM_S_OBJID csmgr;
    struct GRmd_env mod;
    OM_S_CHANSELECT to_comp;
    OM_S_OBJECT_LINKAGE *objects;

    /* clear the form */

    FIf_reset(review_form);

    /* get the coordinate system manager id */

    size = sizeof(struct GRmd_env);
    gr$get_module_env(msg = &msg, sizbuf = &size, buffer = &mod, nret = &size);
    cs$get_mgr(msg = &msg,
               osnum = mod.md_id.osnum,
               module = mod.md_id.objid,
               csmgr = &csmgr);

    /* get a count of the coordinate systems in the current module */

    om$make_chanselect (channame = "GRcmpowner.to_components",
                              p_chanselect = &to_comp);

    sts = om$get_channel_count (osnum = mod.md_id.osnum,
                                objid = csmgr,
                                p_chanselect = &to_comp,
                                count = &count);

    if (!(sts & 1))
    {
#ifdef DEBUG
        printf("COupdate_cs_form: om$get_channel_count\n");
        om$report_error(sts = sts);
#endif
        goto finish;
    }

    /* get a string to display for unnamed coord systems */
    ex$message(msgnumb = GR_I_NotDefined, buff = no_name);

    /* get the object id's of the coordinate systems */

    if (count > 10000) count = 10000;
    objects = (OM_S_OBJECT_LINKAGE *)alloca(sizeof(OM_S_OBJECT_LINKAGE) * count);
    size = count;
    sts = om$get_channel_objects (osnum = mod.md_id.osnum,
                                  objid = csmgr,
                                  p_chanselect = &to_comp,
                                  list = objects,
                                  size = size,
                                  count = &count);
    for (i = 0; i < count; i++)
    {
        /* get the name and description from the coordinate system */

        sts = om$send(msg = message GRgencs.GRget_cs_info
                           ((IGRlong *)&msg, GRNAME_SIZE, name, &size,
                            GRNAME_SIZE, desc, &descsize, NULL, NULL),
                      senderid = NULL_OBJID,
                      targetid = objects[i].S_objid,
                      targetos = mod.md_id.osnum);

        if ((sts & msg & 1) && size)
        {
            di$cvt_name_for_output(s_path = name);
            n = name;
            d = desc;
        }
        else
        {
            n = no_name;
            d = "";
        }

        /* update the form */

        FIfld_set_text(review_form, LIST_FIELD, i, 0, n, 0);
        FIfld_set_text(review_form, LIST_FIELD, i, 1, d, 0);
        FIfld_set_value(review_form, LIST_FIELD, i, 2,
                        (double)objects[i].S_objid, 0);
        FIfld_set_value(review_form, LIST_FIELD, i, 3, 0.0, 0);
    }

    /* fill in the active cs name */

    cs$get_active_info(msg = &msg,
                       osnum = mod.md_id.osnum,
                       module = mod.md_id.objid,
                       csmgr = csmgr,
                       namebuf_size = GRNAME_SIZE,
                       name = name,
                       namebytes_ret = &size);

    if (msg & 1)
    {
        di$cvt_name_for_output(s_path = name);
        FIfld_set_text(review_form, ACTIVE_CS_FIELD, 0, 0, name, 0);
    }
finish:
    return (sts);
}


#argsused
IGRint COcsreview_notify (form_label, gadget_label, value, form)
int form_label;
int gadget_label;
double value;
Form form;
{
    IGRchar name[GRNAME_SIZE], desc[GRNAME_SIZE], *c;
    IGRint sts, msg, row, col, pos, sel, nrow, i, j, size;
    IGRdouble val;
    OM_S_OBJID cs;
    enum GRdpmode mode;
    struct GRmd_env mod;

    /* clear the message field */

    FIfld_set_text (form, FI_MSG_FIELD, 0, 0, "", 0);

    /* process the input */

    switch (gadget_label)
    {
        case FI_ACCEPT:
        case FI_EXECUTE:
            FIfld_get_num_rows(form,LIST_FIELD,&nrow);
            for (i = 0; i < nrow; i++)
            {
                FIfld_get_value(form,LIST_FIELD,i,3,&val,&sel,&pos);
                if (val == 1.0)
                {
                    /* delete all marked cs's */

                    FIfld_get_value(form,LIST_FIELD,i,2,&val,&sel,&pos);
                    cs = (OM_S_OBJID)val;
                    size = sizeof(struct GRmd_env);
                    gr$get_module_env(msg = &msg, sizbuf = &size, buffer = &mod, nret = &size);
                    sts = om$send (msg = message GRgraphics.GRdelete
                                        ((IGRlong *)&msg, &mod),
                                   senderid = NULL_OBJID,
                                   targetid = cs,
                                   targetos = mod.md_id.osnum);
#ifdef DEBUG
                    printf ("COcsreview_notify: GRgraphics.GRdelete: ");
                    printf ("(%d, %d): %#x, %#x\n", mod.md_id.osnum, cs, sts, msg);
#endif
                }
            }
            if (gadget_label == FI_EXECUTE)
            {
                COupdate_cs_form();
                break;
            }
            /* no break */

        case FI_CANCEL:
            FIf_erase(form);
            FIf_delete(form);
            review_form = NULL;
            break;

        case ACTIVE_CS_FIELD:
            break;

        case ACTIVATE_DELETE_TOGGLE:
            FIg_get_state (form, gadget_label, &sel);
            if (sel)
            {
                c = "Each selection will be deleted";
            }
            else
            {
                c = "Each selection will change the active coordinate system";
            }
            FIfld_set_text (form, FI_MSG_FIELD, 0, 0, c, 0);
            break;

        case LIST_FIELD:
            if (value == -1.0)
            {
                /* row gadget selected */

                FIfld_get_active_row(form, gadget_label, &row, &pos);
                FIfld_get_text(form,gadget_label,row,0,GRNAME_SIZE,name,&sel,&pos);
                FIfld_get_value(form,gadget_label,row,2,&val,&sel,&pos);
                cs = (OM_S_OBJID)val;
#ifdef DEBUG
                printf ("COcsreview_notify: %s %d\n",name,cs);
#endif
                size = sizeof(struct GRmd_env);
                gr$get_module_env(msg = &msg, sizbuf = &size, buffer = &mod, nret = &size);
                FIg_get_state(form, ACTIVATE_DELETE_TOGGLE, &sel);
                if (sel)
                {
                    if (name[0])
                    {
                        /* mark the specified cs for deletion */

                        FIfld_set_text(review_form, LIST_FIELD, row, 0, "", 0);
                        FIfld_set_text(review_form, LIST_FIELD, row, 1, "", 0);
                        FIfld_set_value(review_form, LIST_FIELD, row, 3, 1.0, 0);
                        mode = GRbe;
                    }
                    else
                    {
                        /* restore the cs name & desc, clear deletion mark */

                        sts = om$send(msg = message GRgencs.GRget_cs_info
                                           ((IGRlong *)&msg, GRNAME_SIZE, name, &i,
                                            GRNAME_SIZE, desc, &j, NULL, NULL),
                                      senderid = NULL_OBJID,
                                      targetid = cs,
                                      targetos = mod.md_id.osnum);

                        if ((sts & msg & 1) && i)
                        {
                            FIfld_set_text(review_form, LIST_FIELD, row, 0, name, 0);
                            FIfld_set_text(review_form, LIST_FIELD, row, 1, desc, 0);
                            FIfld_set_value(review_form, LIST_FIELD, row, 3, 0.0, 0);
                        }
                        mode = GRbd;
                    }

                    /* [erase display] the cs */

                    om$send (msg = message GRgraphics.GRdisplay
                                  ((IGRlong *)&msg, &mod.md_env.matrix_type,
                                   mod.md_env.matrix, &mode, &mod.md_id),
                             senderid = NULL_OBJID,
                             targetid = cs,
                             targetos = mod.md_id.osnum);
                }
                else
                {
                    /* change the active cs */

                    sts = cs$make_active(msg = &msg,
                                         objid = cs,
                                         module = &mod,
                                         display_old = TRUE,
                                         display_new = TRUE);

                    co$update_current_point_form (msg = &msg);

                    FIfld_set_text(form,ACTIVE_CS_FIELD,0,0,name,0);
                }
            }
            else
            {
                /* column (value) edited */

                row = (int)value;
                FImcf_get_active_col(form, gadget_label, &col, &pos);
                FIfld_get_text(form,gadget_label,row,col,GRNAME_SIZE,name,&sel, &row);
                FIfld_get_value(form,gadget_label,row,2,&val,&sel,&pos);
                cs = (OM_S_OBJID)val;
#ifdef DEBUG
                printf ("COcsreview_notify: %s %d\n",name,cs);
#endif
                size = sizeof(struct GRmd_env);
                gr$get_module_env(msg = &msg, sizbuf = &size, buffer = &mod, nret = &size);

                if (col == 0)
                {
                    /* change the cs name - not implemented yet */
                }
                else
                {
                    /* change the cs description */
#ifdef IMPLEMENTED
                    sts = om$send(msg = GRcoordsys$GRchangedesc(&msg,name),
                                  senderid = NULL_OBJID,
                                  targetid = cs,
                                  targetos = mod.md_id.osnum);
#endif
                }
            }
            break;

        default:
            break;
    }
    return (FI_SUCCESS);
}

method execute (int *response; char *response_data; int pos)
{
    IGRint sts = FI_SUCCESS;

    ex$message(msgnumb = GRC_M_RevCS);

    if (!review_form)
    {
        /* create a form */

        sts = FIf_new(REVIEW_FORM,"GRRevCoordSys",COcsreview_notify,&review_form);
    }

    if (sts == FI_SUCCESS)
    {
        COupdate_cs_form();
        FIf_display(review_form);
    }
    else
    {
#ifdef DEBUG
        printf("COcsreview_execute: FIf_new: %d\n", sts);
#endif
        ex$message(msgnumb = GR_E_ErrEncCmdTrm);
    }

    *response = TERMINATE;
    return(OM_S_SUCCESS);
}

end implementation COcsreview;
