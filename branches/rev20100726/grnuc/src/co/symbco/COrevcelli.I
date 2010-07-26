class implementation COrevcell;



#include "coimport.h"
#include "FI.h"
#include "OMmacros.h"
#include "grerr.h"
#include "grsymdef.h"
#include "grsym.h"
#include "grsymmacros.h"
#include "var.h"
#include "vardef.h"
#include "grmessage.h"
#include "execmsg.h"

#define NAME_FIELD_LENGTH           25          /* field lengths */
#define DESCRIPTION_FIELD_LENGTH    25
#define DATE_FIELD_LENGTH           25

#define REVIEW_CELL_LIB             0           /* form labels */

#define LIBRARY_FIELD               15          /* Review gadget labels */
#define ACTIVE_CELL_FIELD           16
#define LIST_FIELD                  11
#define ACTIVE_DELETE_TOGGLE        20
#define TOTAL_CELLS_FIELD           22

#define ACTIVATE                    0           /* states */
#define DELETE                      1

from GRgraphics import GRdelete;
from GRsymbol import GRset_inq_symbol;
from GRsmdfhdr import GRrename_sd;

extern int strcmp();
extern int GRbtreecount(), GRbtreelocate_all();
extern int FIg_reset (), FIfld_set_text (), FIfld_get_text (), FIg_erase (),
           FIg_get_state (), FIfld_get_active_row (), FImcf_get_active_col (),
           FIg_enable (), FIg_disable ();


#define _wait_for_input 0

method init_instance ()
{
  int		  status = OM_S_SUCCESS;

    me->changes = 0;
    me->delete_count = 0;
    me->form_state = ACTIVATE;
quit:
  return OM_S_SUCCESS;
}

method fill_in_form ()
{
  int		  status = OM_S_SUCCESS;

    IGRint  i;
    IGRlong bytes;
    time_t  time_stamp;
    IGRchar name[MAX_SYMBOL_DEF_NAME + 1];
    IGRchar desc[MAX_SYMBOL_DEF_DESC + 1];
    IGRchar date[DATE_FIELD_LENGTH + 1];
    struct GRvar_list list[4];
    struct GRactive_symbol_def active_sym;
    struct GRsymbol_lib_file file;
    
    FIg_reset (me->forms[0].form_ptr, LIST_FIELD);

    status = gr$symget_asl_env (msg = &me->ret, asl_env = &me->asl_env);
    
    if (!(status & me->ret & 1))
    {
        ex$message (msgnumb = GR_F_NoActCelLibDfn, buff = name);
        FIfld_set_text (me->forms[0].form_ptr, LIBRARY_FIELD, 0, 0, name, 0);
        FIg_disable (me->forms[0].form_ptr, ACTIVE_CELL_FIELD);
        FIg_disable (me->forms[0].form_ptr, LIST_FIELD);
        FIg_disable (me->forms[0].form_ptr, ACTIVE_DELETE_TOGGLE);
    }
    else
    {
        if (me->ret == GR_I_SL_READ_ONLY)
        {
            /* file is read-only, so disable the "delete" gadget */

            ex$message (msgnumb = EX_F_ReadOnly, buff = name);
            ex$message (in_buff = name, field = ERROR_FIELD);
            FIfld_set_text(me->forms[0].form_ptr, FI_MSG_FIELD, 0, 0, name, 0);
            FIg_set_state(me->forms[0].form_ptr, ACTIVE_DELETE_TOGGLE, FALSE);
            FIg_disable(me->forms[0].form_ptr, ACTIVE_DELETE_TOGGLE);
            FIfld_set_mode(me->forms[0].form_ptr, LIST_FIELD, 0, FI_REVIEW);
            FIfld_set_mode(me->forms[0].form_ptr, LIST_FIELD, 1, FI_REVIEW);
            me->form_state = ACTIVATE;
        }
        else
        {
            /* file is writable, so make sure the toggle is active */

            FIg_enable(me->forms[0].form_ptr, ACTIVE_DELETE_TOGGLE);
            FIg_get_state(me->forms[0].form_ptr, ACTIVE_DELETE_TOGGLE, 
                          &me->form_state);
            FIfld_set_mode(me->forms[0].form_ptr, LIST_FIELD, 0, FI_INSERT);
            FIfld_set_mode(me->forms[0].form_ptr, LIST_FIELD, 1, FI_INSERT);
            ex$message (in_buff = "", field = ERROR_FIELD);
        }

        /* display the active cell library filename */

        gr$symget_asl_info (msg = &me->ret, file = &file);

        if (me->ret & 1)
        {
            FIfld_set_text (me->forms[0].form_ptr, LIBRARY_FIELD,
                            0, 0, file.file_name, 0);
        }

        /* display the active cell name */

        gr$symget_active_symbol (msg = &me->ret, act_symbol_def = &active_sym);

        if (!(me->ret & 1))
        {
            ex$message (msgnumb = GR_F_NoActCelDfn, buff = active_sym.name);
        }

        FIfld_set_text (me->forms[0].form_ptr, ACTIVE_CELL_FIELD,
                        0, 0, active_sym.name, 0);

        /* gather a list of all symbol definitions */

        status = GRbtreecount (&me->ret, me->asl_env.md_id.osnum,
                               GR_SD_BTREE_NAME, &me->count);

        /* check to see if there are any cells in the library */
        /* if there aren't any disable the fields, otherwise  */
        /* retrieve the cell information - scw 03/22/92       */

        if (me->count == 0)
        {
           FIg_reset (me->forms[0].form_ptr, TOTAL_CELLS_FIELD);
           FIg_disable (me->forms[0].form_ptr, ACTIVE_CELL_FIELD);
           FIg_disable (me->forms[0].form_ptr, LIST_FIELD);
           FIg_disable (me->forms[0].form_ptr, ACTIVE_DELETE_TOGGLE);
        }
        else
        {
           om$vla_set_dimension (varray = me->symlibobjs, size = me->count);

           status = GRbtreelocate_all (&me->ret, me->asl_env.md_id.osnum,
                                       GR_SD_BTREE_NAME, me->symlibobjs,
                                       0, me->count, &me->count);

           if (status & 1)
           {
               list[0].var = GR_SYMBOL_NAME;
               list[0].var_ptr = name;
               list[0].num_bytes = MAX_SYMBOL_DEF_NAME;
               list[0].bytes_returned = &bytes;

               list[1].var = GR_SYMBOL_DESC;
               list[1].var_ptr = desc;
               list[1].num_bytes = MAX_SYMBOL_DEF_DESC;
               list[1].bytes_returned = &bytes;

               list[2].var = GR_TIME_STAMP;
               list[2].var_ptr = (IGRchar *) &time_stamp;
               list[2].num_bytes = sizeof (IGRlong);
               list[2].bytes_returned = &bytes;
   
               list[3].var = END_PARAM;
 
               for (i = 0; i < me->count; i++)
               {
                   name[0] = NULL;
                   desc[0] = NULL;
                   status = om$send (msg = message GRsymbol.GRset_inq_symbol
                                          (&me->ret, 0, list),
                                     targetos = me->asl_env.md_id.osnum,
                                     targetid = me->symlibobjs[i].objid);

                   if (status & me->ret & 1)
                   {
                       /* convert the time stamp to an ascii string */

                       GRcvt_time_to_ascii (&me->ret, &time_stamp, date);

                       /* update the form */

                       FIfld_set_text (me->forms[0].form_ptr, LIST_FIELD,
                                       i, 0, name, 0);
                       FIfld_set_text (me->forms[0].form_ptr, LIST_FIELD,
                                       i, 1, desc, 0);
                       FIfld_set_text (me->forms[0].form_ptr, LIST_FIELD,
                                       i, 2, date, 0);
                   }
               }

               /* display the total number of cells */

               sprintf (name, "%d", me->count);
               FIfld_set_text (me->forms[0].form_ptr, TOTAL_CELLS_FIELD,
                               0, 0, name, 0);
           }
        }
    }
quit:
  return OM_S_SUCCESS;
}

method form_notification ( int form_label ; int gadget_label ; double value ; char * form_ptr )
{
  int		  status = OM_S_SUCCESS;

    IGRint i, row, sel, pos, error, col;
    IGRlong size;
    IGRchar buf[128], buf1[128], *c1, *c2;
    IGRboolean bad_library = FALSE;
    struct GRid symbol;
    struct GRvar_list list[2];
    struct GRsymbol_lib_file file;

    switch (form_label)
    {
        case REVIEW_CELL_LIB:

            /* clear the message field */

            FIfld_get_text (form_ptr, FI_MSG_FIELD, 0, 0, 128, buf, &sel, &row);
            if (strlen (buf))
            {
                FIfld_set_text (form_ptr, FI_MSG_FIELD, 0, 0, "", 0);
            }

            /* process the input */

            switch (gadget_label)
            {
                case FI_ACCEPT:

                    /* make any deletions necessary */

                    error = FALSE;

                    for (i = 0; i < me->delete_count; i++)
                    {
                        status = om$send (msg = message GRgraphics.GRdelete
                                               (&me->ret, &me->asl_env),
                                          targetid = me->delete_object[i],
                                          targetos = me->asl_env.md_id.osnum);

                        if (!(status & me->ret & 1))
                        {
                            error = TRUE;
                        }
                        me->changes += 1;
                    }

                    if (!error && me->changes)
                    {
                        gr$symsave_asl (msg = &me->ret);
                    }

                    me->delete_count = 0;
                    me->changes = 0;

                    om$vla_set_dimension (varray = me->delete_object, size = 0);

                    /* no break */

                case FI_CANCEL:

                    /* terminate the command */

                    *(me->response) = EX_FORM_FINISHED;
                    size = sizeof (struct EX_button);

                    ex$putque (msg = &me->ret,
                               response = me->response,
                               byte = &size,
                               buffer = me->response_data);
                    break;

                case FI_HELP:
                case FI_CVT_TO_PERM_WIN:
                    break;

                case LIBRARY_FIELD:
                    FIg_erase (form_ptr, FI_PROMPT_FIELD);

                    /* make any deletions necessary */

                    error = FALSE;

                    for (i = 0; i < me->delete_count; i++)
                    {
                        status = om$send (msg = message GRgraphics.GRdelete
                                               (&me->ret, &me->asl_env),
                                          targetid = me->delete_object[i],
                                          targetos = me->asl_env.md_id.osnum);

                        if (!(status & me->ret & 1))
                        {
                            error = TRUE;
                        }
                        me->changes += 1;
                    }

                    if (!error && me->changes)
                    {
                        gr$symsave_asl (msg = &me->ret);
                    }

                    me->delete_count = 0;
                    me->changes = 0;

                    om$vla_set_dimension (varray = me->delete_object, size = 0);

                    /* get the text from the form */

                    FIfld_get_text (form_ptr, gadget_label, 0, 0, 128, buf,
                                    &sel, &row);
                    strncpy (file.file_name, buf, MAX_SYMBOL_LIB_NAME);
                    file.file_name[MAX_SYMBOL_LIB_NAME - 1] = NULL;

                    /* let the user know the image hasn't croaked */

                    ex$message (msgnumb = GR_I_Working, buff = buf);
                    FIfld_set_text (form_ptr, FI_MSG_FIELD, 0, 0, buf, 0);

                    /* retrieve the cell library with the given file name */

                    me->ret = gr$symretrieve_cell_library
                                       (filename = file.file_name,
                                        file_no = &file.file_no,
                                        flag = EX_read_write | EX_read_only,
                                        file_access = &file.file_access,
                                        fstat = EX_old_module);

                    if (me->ret & 1)
                    {
                        FIg_enable (form_ptr, ACTIVE_CELL_FIELD);
                        FIg_enable (form_ptr, LIST_FIELD);
                        FIg_enable (form_ptr, ACTIVE_DELETE_TOGGLE);
                        /*  define the symbol library as the active symbol */

                        gr$symput_asl (msg = &me->ret, file = &file);

                        /* update the list field */

                        om$send (msg = message COrevcell.fill_in_form (),
                                 targetid = my_id);

                        ex$message (msgnumb = GR_I_CelLib,
                                    type = "%s",
                                    var = `file.file_name`,
                                    buff = buf);
                    }
                    else if (me->ret == GR_E_NO_FILE)
                    {
				/** FIX 90N1630 **/
/*
                        ex$message (msgnumb = GR_P_FlNotExst, buff = buf);
*/
                        ex$message (msgnumb = GR_E_FlNotFnd, buff = buf);
                        bad_library = TRUE;
                    }
                    else if (me->ret == GR_E_NOT_CELL_LIB)
                    {                     
                        ex$message (msgnumb = GR_E_PlsEntCelLib, buff = buf);
                        bad_library = TRUE;
                    }
                    else if (me->ret == GR_E_NO_PREMISSION)
                    {
                        ex$message (msgnumb = GR_E_ErrFlProt, buff = buf);
                        bad_library = TRUE;
                    }
                    else
                    {
                        ex$message (msgnumb = GR_E_ErrFlAtch, buff = buf);
                        bad_library = TRUE;
                    }

                    if (bad_library)
                    {
                        ex$message (in_buff = "", field = ERROR_FIELD);
                        FIg_reset (form_ptr, LIST_FIELD);
                        FIg_reset (form_ptr, TOTAL_CELLS_FIELD);
                        FIg_disable (form_ptr, ACTIVE_CELL_FIELD);
                        FIg_disable (form_ptr, LIST_FIELD);
                        FIg_disable (form_ptr, ACTIVE_DELETE_TOGGLE);
                        bad_library = FALSE;
                    }

                    FIfld_set_text (form_ptr, FI_MSG_FIELD, 0, 0, buf, 0);
                    break;

                case ACTIVE_CELL_FIELD:
                    FIg_erase (form_ptr, FI_PROMPT_FIELD);

                    FIfld_get_text (form_ptr, gadget_label, 0, 0, 128, buf,
                                    &sel, &row);

                    /* look for the specified symbol */

                    status = gr$symsd_locate_in_all_sl (msg = &me->ret,
                                                        sd_name = buf,
                                                        sl_env = &me->asl_env, 
                                                        sd_id = &symbol);
                    if (!(status & 1))
                    {
                        ex$message (msgnumb = GR_E_ErrEnc, buff = buf);
                    }
                    else if (me->ret == GR_I_NOSL)
                    {
                        ex$message (msgnumb = GR_F_NoActCelLibDfn, buff = buf);
                    }
                    else if (!(me->ret & 1))
                    {
                        ex$message (msgnumb = GR_E_CelNotFnd, buff = buf);
                    }
                    else
                    {
                        /* make the specified symbol active */

                        gr$symput_active_symbol (msg = &me->ret,
                                                 symbol_name = buf,
                                                 symbol_id = &symbol,
                                                 asl_env = &me->asl_env);
                        buf[0] = NULL;
                    }
                    FIfld_set_text (form_ptr, FI_MSG_FIELD, 0, 0, buf, 0);
                    break;

                case ACTIVE_DELETE_TOGGLE:
                    FIg_get_state (form_ptr, gadget_label, &me->form_state);
                    i = (me->form_state) ? GR_I_EachSelDel : GR_I_SelChActCel;
                    ex$message (msgnumb = i, buff = buf);
                    FIfld_set_text (form_ptr, FI_MSG_FIELD, 0, 0, buf, 0);
                    break;

                case LIST_FIELD:
                    if (value == -1)
                    {
                        /* row gadget selected */

                        FIfld_get_active_row (form_ptr, gadget_label,
                                              &me->row, &pos);

                        FIfld_get_text (form_ptr, gadget_label, me->row,
                                        0, 128, buf, &sel, &row);

                        if (me->form_state == ACTIVATE)
                        {
                            /* look for the specified symbol */

                            status = gr$symsd_locate_in_all_sl
                                                       (msg = &me->ret,
                                                        sd_name = buf,
                                                        sl_env = &me->asl_env, 
                                                        sd_id = &symbol);

                            if (!(status & me->ret & 1))
                            {
                                ex$message (msgnumb = GR_E_CelNotFnd,
                                            buff = buf1);
                            }
                            else if (me->ret == GR_I_NOSL)
                            {
                                ex$message (msgnumb = GR_F_NoActCelLibDfn,
                                            buff = buf1);
                            }
                            else
                            {
                                /* make the specified symbol active */

                                status = gr$symput_active_symbol
                                                   (msg = &me->ret,
                                                    symbol_name = buf,
                                                    symbol_id = &symbol,
                                                    asl_env = &me->asl_env);

                                buf1[0] = NULL;

                                FIfld_set_text (form_ptr, ACTIVE_CELL_FIELD,
                                                0, 0, buf, 0);
                            }
                            FIfld_set_text (form_ptr, FI_MSG_FIELD, 0, 0,
                                            buf1, 0);
                        }
                        else if (me->form_state == DELETE)
                        {
                            if (me->row > me->count || buf[0] == NULL)
                            {
                                break;
                            }

                            /* store the object to delete */

                            me->delete_count++;

                            om$vla_set_dimension (varray = me->delete_object,
                                                  size = me->delete_count);

                            i = me->delete_count - 1;
                            me->delete_object[i] =
                                                me->symlibobjs[me->row].objid;

                            /* lie to the user (just a little) */

                            ex$message (msgnumb = GR_I_CelDel,
                                        type = "%s",
                                        var = buf,
                                        buff = buf1);

                            FIfld_set_text (form_ptr, FI_MSG_FIELD, 0, 0,
                                            buf1, 0);

                            /* clear the list field entry */

                            FIfld_set_text (form_ptr, gadget_label, me->row,
                                            0, "", 0);
                            FIfld_set_text (form_ptr, gadget_label, me->row,
                                            1, "", 0);
                            FIfld_set_text (form_ptr, gadget_label, me->row,
                                            2, "", 0);

                            /* check whether the deleted cell was active */

                            FIfld_get_text (form_ptr, ACTIVE_CELL_FIELD, 0, 0,
                                            128, buf1, &sel, &row);

                            if (!(strcmp (buf, buf1)))
                            {
                                FIfld_set_text (form_ptr, ACTIVE_CELL_FIELD,
                                                0, 0, "", 0);
                            }

                            /* adjust the cell count */

                            FIfld_get_text (form_ptr, TOTAL_CELLS_FIELD, 0, 0,
                                            128, buf1, &sel, &row);
                            i = atoi (buf1);
                            sprintf (buf1, "%d", i - 1);
                            FIfld_set_text (form_ptr, TOTAL_CELLS_FIELD, 0, 0,
                                            buf1, 0);
                        }
                    }
                    else
                    {
                        /* column (value) edited */

                        me->row = value;

                        FImcf_get_active_col (form_ptr, gadget_label,
                                              &col, &pos);

                        FIfld_get_text (form_ptr, gadget_label, me->row,
                                        col, 128, buf, &sel, &row);

                        c1 = c2 = NULL;

                        if (col == 0) /* name */
                        {
                            /* check whether name was changed */

                            list[0].var = GR_SYMBOL_NAME;
                            list[0].var_ptr = buf1;
                            list[0].num_bytes = MAX_SYMBOL_DEF_NAME;
                            list[0].bytes_returned = &size;

                            list[1].var = END_PARAM;
 
                            buf1[0] = NULL;

                            status = om$send (
                                    msg = message GRsymbol.GRset_inq_symbol
                                         (&me->ret, 0, list),
                                    targetos = me->asl_env.md_id.osnum,
                                    targetid = me->symlibobjs[me->row].objid);

                            if (!(strcmp (buf, buf1)))
                            {
                                break;
                            }

                            /* check for duplicate name */

                            status = gr$symsd_locate_in_all_sl
                                                       (msg = &me->ret,
                                                        sd_name = buf,
                                                        sl_env = &me->asl_env, 
                                                        sd_id = &symbol);
                            if (status & me->ret & 1)
                            {
                                ex$message (msgnumb = GR_E_DupNmeIs,
                                            type = "%s",
                                            var = buf,
                                            buff = buf1);

                                FIfld_set_text (form_ptr, FI_MSG_FIELD, 0, 0,
                                                buf1, 0);
                            }
                            else
                            {
                                c1 = buf;
                            }
                        }
                        else if (col == 1) /* description */
                        {
                            c2 = buf;
                        }

                        if (c1 || c2)
                        {
                            status = om$send
                                    (msg = message GRsmdfhdr.GRrename_sd
                                          (&me->ret, c1, c2),
                                     targetid = me->symlibobjs[me->row].objid,
                                     targetos = me->asl_env.md_id.osnum);

                            if (status & me->ret & 1)
                            {
                                me->changes++;
                                FIfld_set_text (form_ptr, gadget_label,
                                                me->row, col, buf, 0);
                            }
                            else
                            {
                                ex$message (msgnumb = GR_E_CantRenCel,
                                            buff = buf1);

                                FIfld_set_text (form_ptr, FI_MSG_FIELD, 0, 0,
                                                buf, 0);
                            }
                        }
                        FIfld_set_select (form_ptr, gadget_label,
                                          me->row, col, FALSE);
                    }
                    break;
            }
            break;
    }
quit:
  return OM_S_SUCCESS;
}

end implementation COrevcell;
