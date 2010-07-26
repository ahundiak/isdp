/*
Name
        GRlslmgr

Description
        These methods implement the global class for the cell manager.

History
        hgw     08/30/86    Design Date
        hgw     08/30/86    Creation Date
        mrm     01/31/89    check for temp_wakeup in wakeup method
        jhw     12/29/89    check file_nos before closing lib in GRput_asl
        mrm     06/12/92    ignore wake_up and sleep from reference files
                06/24/92    clear data indicating that the cell lib is attached
                            when it is not retrieved in reference files
        scw     07/22/92    ansi conversion
        scw     08/09/94    clarified sleep method
*/

class implementation GRlslmgr;

#include "msdef.h"
#include "madef.h"
#include "exdef.h"
#include "grsymdef.h"
#include "OMerrordef.h"
#include "exmacros.h"
#include "grsymmacros.h"
#include "vardef.h"
#include "grerr.h"
#include "referr.h"
#include "refpriv.h"

#define MAX_APP_STRING      15
#define FILE_NOT_ACTIVE     -1
#define ACTIVE_FILE(file)   ((file.file_name[0] != NULL) &&     \
                             (file.file_no != FILE_NOT_ACTIVE))

from GRsymbol import GRset_inq_symbol;


method super_construct ()
{
    IGRint   i;

    /* 
     *  initialize symbol library data
     */

    for (i = 0; i < MAX_ACTIVE_SYMBOLS; ++i)
    {
        me->symbol_info.active_symbols[i].name[0] = NULL;
        me->symbol_info.active_symbols[i].attachment_num = 0;
        me->symbol_info.active_symbols[i].time_stamp = 0;
    }

    for (i = 0; i < MAX_SYMBOL_LIBS; ++i)
    {
        me->symbol_info.symbol_lib_array[i].file_name[0] = NULL;
        me->symbol_info.symbol_lib_array[i].file_no = FILE_NOT_ACTIVE;
        me->symbol_info.symbol_lib_array[i].file_access = FALSE;
    }

    return (OM_S_SUCCESS);
}


method wake_up ()
{
    IGRint i,index;
    IGRlong sts;
    struct GRsymbol_lib_file *symlib;

    index = -1;
    if (!ex$is_temp_wakeup())
    {
        Get_invisible_index ( OM_Gw_current_OS, index );
        if(index >= 0)
        {
            /*
                This is a reference file, so don't retrieve cell lib.  Mark
                the file as not active, just in case it leaked through the
                previous close without being marked (which has happened at
                least once).
            */

            symlib = &me->symbol_info.symbol_lib_array[0];
            symlib->file_access = FALSE;
            symlib->file_no = FILE_NOT_ACTIVE;
            return(OM_S_SUCCESS);
        }

        for (i = 0; i < MAX_SYMBOL_LIBS; ++i)
        {
            symlib = &me->symbol_info.symbol_lib_array[i];

            if (symlib->file_name[0] != NULL)
            {
                /* 
                 *  attach cell library read write
                 */

                sts = gr$symretrieve_cell_library
                                       (filename = symlib->file_name,
                                        flag = EX_read_write | EX_read_only, 
                                        file_no = &symlib->file_no,
                                        file_access = &symlib->file_access,
                                        fstat = EX_old_module);
                if (!(sts & 1))
                {
                    symlib->file_access = FALSE;
                    symlib->file_no = FILE_NOT_ACTIVE;
                }
            }
        }
    }
    return (OM_S_SUCCESS);
}


method global_class.sleep (int type_sleep)
{
    IGRint i;
    IGRlong sts;
    struct GRsymbol_lib_file *symlib;

    /*
     *  if this is a permanent sleep then save all libraries
     */

    if (type_sleep == EX_REAL_SLEEP)
    {
        /*
         *  Save all symbol libraries
         */

        for (i = 0; i < MAX_SYMBOL_LIBS; ++i)
        {
            symlib = &me->symbol_info.symbol_lib_array[i];
            if (ACTIVE_FILE (symlib[0]))
            {
                /*
                 *  Close each of the symbol libraries.  The flag is
                 *  set so that the file will not be written out
                 */
                sts = gr$symclose_cell_library (file_no = symlib->file_no);

                symlib->file_no = FILE_NOT_ACTIVE;
                symlib->file_access = FALSE;
            }
        }
    }
    return (OM_S_SUCCESS);
}


method GRget_active_symbol (IGRlong *msg; 
                            struct GRactive_symbol_def *act_sym;
                            IGRint index)
{
    IGRlong           sts;
    IGRlong           ret_msg;
    IGRlong           tstamp;
    IGRlong           temp;
    struct GRid       sd_id;
    struct GRvar_list list[2];

    *msg = MSFAIL;
    sts = OM_E_ERROR;

    /*
     *  Is an active symbol defined?
     */

    if (me->symbol_info.active_symbols[index].name[0] != NULL)
    {
        strcpy (act_sym->name, me->symbol_info.active_symbols[index].name);

        sts = gr$symsd_locate_in_asl (msg = &ret_msg,
                                      sd_name = act_sym->name,
                                      sl_env = &act_sym->symbol_env,
                                      sd_id = &sd_id);
        if (sts & ret_msg & 1)
        {
            list[0].var = GR_TIME_STAMP;
            list[0].var_ptr = (IGRchar *)&tstamp;
            list[0].num_bytes = sizeof (IGRlong);
            list[0].bytes_returned = &temp;
            list[1].var = END_PARAM;
                  
            sts = om$send (msg = message GRsymbol.GRset_inq_symbol
                                (&ret_msg, 0, list),
                           targetos = sd_id.osnum,
                           targetid = sd_id.objid);

            if ((sts & ret_msg & 1) &&
                (tstamp == me->symbol_info.active_symbols[index].time_stamp))
            {
                *msg = MSSUCC;
                act_sym->objid = sd_id.objid;
            }
        }
    }
    return (sts);
}


method GRget_asl_env (IGRlong *msg; struct GRmd_env *asl_env)
{
    IGRlong  ret_msg;

    *msg = MSSUCC;
   
    if (ACTIVE_FILE (me->symbol_info.symbol_lib_array[0]))
    {
        MAidmx (&ret_msg, asl_env->md_env.matrix);
        asl_env->md_env.matrix_type = MAIDMX;
        ex$get_invis_info_by_index
                (index = me->symbol_info.symbol_lib_array[0].file_no,
                 mod_osnum = &asl_env->md_id.osnum,
                 mod_id = &asl_env->md_id.objid);

        /*
         *  is cell library read only?
         */

        if ((me->symbol_info.symbol_lib_array[0].file_access & 
             GR_SL_READ_WRITE_ACCESS) == GR_SL_READ_ACCESS)
        {
            *msg = GR_I_SL_READ_ONLY;
        }
    }
    else
    {
        *msg = MSFAIL;
        return (OM_E_ERROR);
    }
    return (OM_S_SUCCESS);
}


method GRput_active_symbol (IGRlong *msg; IGRchar *name;
                            struct GRid *act_sym; struct GRmd_env *sl_env;
                            IGRint  index)
{
    IGRlong              sts;
    IGRlong              ret_msg;
    IGRlong              temp;
    IGRint               i;
    GRspacenum           osnum;
    struct GRvar_list    list[2];
    struct GRsymbol_lib_file *symlib;

    *msg = MSSUCC;
    sts = OM_S_SUCCESS;

    /*
     *  if an active symbol was original defined then disconnect it
     */

    if (me->symbol_info.active_symbols[index].name[0] != NULL)
    {
        /*
         *  Clear out the existing active symbol
         */

        me->symbol_info.active_symbols[index].name[0] = NULL;
        me->symbol_info.active_symbols[index].time_stamp = 0;
        me->symbol_info.active_symbols[index].attachment_num = 0;
    }

    /*
     *  get the time stamp from the new active symbol definition
     */

    list[0].var = GR_TIME_STAMP;
    list[0].var_ptr = 
        (IGRchar *)&me->symbol_info.active_symbols[index].time_stamp;
    list[0].num_bytes = sizeof (IGRlong);
    list[0].bytes_returned = &temp;
    list[1].var = END_PARAM;
                  
    sts = om$send (msg = message GRsymbol.GRset_inq_symbol
                        (&ret_msg, 0, list),
                   targetos = act_sym->osnum,
                   targetid = act_sym->objid);
    if (sts & 1)
    {
        strcpy (me->symbol_info.active_symbols[index].name, name);

        /*
         *  find the attachment number of the library that the active
         *  cell was from
         */

        for (i = 0; i < MAX_SYMBOL_LIBS; ++i)
        {
            symlib = &me->symbol_info.symbol_lib_array[i];
            if (ACTIVE_FILE (symlib[0]))
            {
                ex$get_invis_info_by_index (index = symlib->file_no,
                                            mod_osnum = &osnum);

                if (osnum == act_sym->osnum);
                {
                    me->symbol_info.active_symbols[index].attachment_num = i;
                    return (OM_S_SUCCESS);
                }
            }
        }
    }
    *msg = MSFAIL;
    return (OM_E_ERROR);
}

method GRput_asl (IGRlong *msg; struct GRsymbol_lib_file *file)
{
    IGRint   i;
    IGRlong  sts;

    *msg = MSSUCC;
    sts = OM_S_SUCCESS;

    if (me->symbol_info.symbol_lib_array[0].file_name[0] != NULL)
    {
        /*
         *  clear all active symbols
         */

        for (i=0; i < MAX_ACTIVE_SYMBOLS; ++i)
        {
            if ((me->symbol_info.active_symbols[i].attachment_num == 0) && 
                (me->symbol_info.active_symbols[i].name[0] != NULL))
            {
                /*
                 *  if an active symbol is defined from the active symbol
                 *  library then disconnect the active symbol
                 */

                me->symbol_info.active_symbols[i].name[0] = NULL;
                me->symbol_info.active_symbols[i].attachment_num = 0;
                me->symbol_info.active_symbols[i].time_stamp = 0;
            }
        }

        /*
         * If there is an active file and it is different from the new
         * active file, close the old active file.
         */
        if (ACTIVE_FILE (me->symbol_info.symbol_lib_array[0]) &&
            (me->symbol_info.symbol_lib_array[0].file_no != file->file_no))
        {
            /*
             *  close the current active symbol library.  Flag is set
             *  so the library will not be written out
             */

            sts = gr$symclose_cell_library
                    (file_no = me->symbol_info.symbol_lib_array[0].file_no);
        }
    }
   
    if (sts & 1)
    {
        me->symbol_info.symbol_lib_array[0].file_access = file->file_access;
        me->symbol_info.symbol_lib_array[0].file_no = file->file_no;
        strcpy (me->symbol_info.symbol_lib_array[0].file_name, 
                file->file_name);
        return (OM_S_SUCCESS);
    }
    else
    {
        *msg = MSFAIL;
        return (OM_E_ABORT);
    }
}


method GRget_sl_OS_array (IGRlong *msg; GRspacenum *os_array; IGRint *os_num)
{
    IGRint   i,j;
    struct GRsymbol_lib_file *symlib;

    *msg = MSSUCC;

    /*
     *  search the array of symbol libraries and generate an array
     *  of OS numbers
     */

    for (i = 0, j = 0; i < MAX_SYMBOL_LIBS; ++i)
    {
        symlib = &me->symbol_info.symbol_lib_array[i];
        if (ACTIVE_FILE (symlib[0]))
        {
            ex$get_invis_info_by_index (index = symlib->file_no,
                                        mod_osnum = &os_array[j]);
            ++j;
        }
    }

    if (j)
    {
        *os_num = j;
        return (OM_S_SUCCESS);
    }
    else
    {
        *os_num = 0;
        *msg = MSFAIL;
        return (OM_S_SUCCESS);
    }   
}

method GRget_sl_env_from_OS (IGRlong *msg; GRspacenum *OS_num;
                             struct GRmd_env *sl_env)
{
    IGRint      i;
    IGRlong     ret_msg;
    GRspacenum  osnum;
    struct GRsymbol_lib_file *symlib;

    *msg = MSSUCC;

    for (i = 0; i < MAX_SYMBOL_LIBS; ++i)
    {
        symlib = &me->symbol_info.symbol_lib_array[i];
        if (ACTIVE_FILE (symlib[0]))
        {
            ex$get_invis_info_by_index (index = symlib->file_no,
                                        mod_osnum = &osnum);

            if (osnum == *OS_num)
            {
                MAidmx (&ret_msg, sl_env->md_env.matrix);
                sl_env->md_env.matrix_type = MAIDMX;
                ex$get_invis_info_by_index (index = symlib->file_no,
                                            mod_osnum = &sl_env->md_id.osnum,
                                            mod_id = &sl_env->md_id.objid);
                return (OM_S_SUCCESS);
            }
        }
    }
    *msg = MSFAIL;
    return (OM_S_SUCCESS);
}


method GRsave_asl (IGRlong *msg)
{
    *msg = MSSUCC;
    gr$symsave_cell_library
                       (file_no = me->symbol_info.symbol_lib_array[0].file_no);
    return (OM_S_SUCCESS);
}


method GRget_sl_type (IGRlong *msg; GRspacenum *osnum; IGRint *type)
{
    IGRchar app_string[MAX_APP_STRING];

    *msg = MSSUCC;

    ex$mod_info (mod_osnum = *osnum,
                 mode = EX_INQ,
                 app = app_string,
                 applen = MAX_APP_STRING);

    /*
     *  Return 
     *    TRUE  - single library type (GR_SYM_LIB_APP_STRING)
     *    FALSE - multiple library type
     */
            
    if (!strcmp (app_string, GR_SYM_LIB_APP_STRING))
    {
        *type = TRUE;
    }
    else
    {
        *type = FALSE;
    }
    return (OM_S_SUCCESS);
}


method GRget_asl_info (IGRlong *msg; struct GRsymbol_lib_file *file)
{
    IGRlong  sts;

    *msg = MSSUCC;
    sts = OM_S_SUCCESS;

    if (me->symbol_info.symbol_lib_array[0].file_name[0] != NULL)
    {
        file->file_no = me->symbol_info.symbol_lib_array[0].file_no;
        file->file_access = me->symbol_info.symbol_lib_array[0].file_access;
        strcpy (file->file_name, me->symbol_info.symbol_lib_array[0].file_name);
    }
    else
    {
        *msg = GR_I_NOSL;
    }
    return (OM_S_SUCCESS);
}

end implementation GRlslmgr;
