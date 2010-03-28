/*
Name
	GRrfclose - closes a reference file.

Synopsis
	GRrfclose(msg,type)

	IGRlong *msg	 return message
			     MSSUCC - method succeeded
			     MSFAIL - method failed
			     GR_I_INV_REQUEST - type of close
				requested is invalid for
			  	this attachment.
			     GRNO_PROCESSING_NEEDED - no file is
				attached.
			     GRFILENOTFOUND - file is not found
	IGRlong *type	 indicator of how to close the file
				   0 - close file, do not write
				   1 - write the file
				   2 - send originated from delete
				       not from sleep

Description
	This routine closes a reference file.  How it is closed 
	depends on the type sent in by the user, the privileges 
	of the user and how the file was opened.  

Diagnostics
	The possible return codes values in the msg field are:

	MSSUCC - successful completion

     	GR_I_INV_REQUEST - the mode for closing is invalid.
		Either the user does not have privileges 
		for this request or the file was not opened 
		with the correct privilege.    

	MSFAIL - error

Notes
	None.
History

	MAS  	08/20/86 	Design date.
	jhw     01/03/90        Clear invis entry is osnum represents
                                the last self attached ref on that os.
        hgb     04/29/91	Writable reference files
        dhm     07/09/92        ANSI conversion.
        dkk     10/12/94        fix for TR#119421991 found on ISL
*/

class implementation GRreffile;

#include <limits.h>
#include <stdio.h>
#include "refpriv.h"
#include "exmacros.h"
#include "OMmacros.h"
#include "grerr.h"
#include "refdef.h"
#include "referr.h"
#include "msdef.h"
#include "msmacros.h"
#include "exdef.h"
#include "exmacros.h"
#include "execmsg.h"
#include "grmessage.h"
#include "DIdef.h"

from GRcontext   import GRcheckctx, GRgetflag;
from Super_rfmgr import remove_file_name;

#if defined ( SUNOS ) || defined ( SUNOS5 )
#define PATH_MAX 1023
#endif

#define DO_NOT_WRITE_FILE   0
#define WRITE_FILE          1
#define DELETE              2
#define CONSTRUCTION_FAILED 3
#define UNLOAD_FILE         4

method GRrfclose ( long *msg; long *type ) 
{
    IGRboolean      same;
    short           ctx_flag, new_type, env_type;
    long            OMmsg, msg1, master_file;
    int             index;          /* index into invisible table  */
    int             count;          /* dimension of object space  */
    int             flag;           /* flag for how to close space  */
    int             new_count, count_check_only;
    IGRmatrix       env_matrix, new_matrix;
    GRspacenum      osnum;          /* space number      */
    OM_S_CHANSELECT chan;
    struct GRid     context_id;

    OMmsg = OM_S_SUCCESS;
    *msg = MSSUCC;
    count_check_only = 1;

    count = om$dimension_of ( varray = me->osname );

    if (count)
    {
        /* 
         * Get the object space number from the object space name 
         */
        OMmsg = om$os_name_to_number (osname = me->osname, 
                                      p_osnum = &osnum );
        
        if (OMmsg & 1)
        {
            /* 
             * Get the index of this object space in the invisible table
             */
            Get_invisible_index ( osnum, index );

            /*
             * Get the numeber of opens on this space.
             */
            ex$get_invis_info_by_index ( num_open = &count, index = index);

            /*
             * If we have a reasonable index.
             */
            if (index >= 0)
            {
                switch (*type)
                {
                case DELETE:
                    /* 
                     * Call originated from delete (don't write space) 
                     */
                    flag = 0;

                    /* 
                     * If it is the last occurence of that file, make sure we
                     * don't need to clean up the list of writable files 
                     */
                    if (count == 1)
                    {
                        struct GRid list;
                        int         status;
                        long        msg;
                        
                        /* may be we need to clean the list of writable files */
/* Fix for TR#119421991 - found on ISL. The third arg to the func was not
   given - 10/12/94
*/
                        status = GRget_file_list ( &list, 0, 0 );

                        if (status == OM_S_SUCCESS)
                        {                   
                            /* 
                             * Ask the list 
                             */
                            om$send(msg = message Super_rfmgr.remove_file_name
                                                        (&msg, me->filename),
                                  senderid = NULL_OBJID,
                                  targetid = list.objid,
                                    targetos = list.osnum );
                        }
                    }
                    break;
                    
                case WRITE_FILE:
                    GRis_writable ( msg, me->osname, 1, OM_Gw_current_OS );

                    if (flag = (*msg == MSSUCC))
                    {
                        if (OM_GA_OSDs [osnum]->flags & OM_e_loados_ro)
                        {                      
                            flag = 0;
                        }
                    }
                    break;

                case UNLOAD_FILE:
                    flag = 0;
                    break;
                    
                default:
                    flag = 0;
                    break;
                }

                /* get the context object for this attachment */
                GRget_env ( &env_type, env_matrix );

                om$make_chanselect ( channame="GRreffile.to_context",
                                    p_chanselect = &chan );
                
                if ((*type == CONSTRUCTION_FAILED)  || 
                    (*type == UNLOAD_FILE)          ||
                    (env_type == -1))
                {
                    OMmsg = om$get_objid_at_index (objid = my_id,
                                                   p_chanselect = &chan,
                                                   index = 0,
                                                   objidaddr = &context_id.objid,
                                                   osnumaddr = &context_id.osnum );
                    same = TRUE;
                    new_type = -1;
                }
                else
                {
                    GRcomputectx (&msg1, 
                                  &env_type, 
                                  env_matrix, 
                                  me->ref_to_master_matrix, 
                                  &new_type, 
                                  new_matrix);

                    OMmsg = om$send (msg = message GRcontext.GRcheckctx 
                                                               (msg, 
                                                                &new_type,
                                                                new_matrix, 
                                                                &osnum,
                                                                &context_id,
                                                                &same),
                                     p_chanselect = &chan);
                }

                if (1 & OMmsg & *msg & same)
                {
                    OMmsg = om$send (msg = message GRcontext.GRgetflag 
                                                          (msg, &ctx_flag ),
                                     targetid = context_id.objid,
                                     targetos = context_id.osnum );

                    master_file = GRcheck_master_file ( me->osname );

                    if ((count <= 0) || 
                        ((ctx_flag & GRCYCLIC_ATTACHMENT) && (count > 1)))
                    {
                        /* 
                         * Flag indicate cycle has been encountered, exit. 
                         */
                        if (count > 0)
                        {
                            Decrement_num_opens ( osnum );
                            
                            /* 
                             * If there is only one open left for the 
                             * osnum and it is the master file's osnum 
                             * clear the entry. 
                             */
                            if ((count == 2) && master_file)
                            {
                                Clear_invisible_entry ( osnum );
                            }
                        }
                        
                        goto wrapup;
                    }
                }
                else  
                {
                    /* 
                     * If no context object is found exit. 
                     *
                     * NOTE:
                     * PDM Revise Assembly replaces an ref-file attachment 
                     * with a new one. But due to the behaviour of the
                     * GRupdcontext (GRcontext.GRupdatectx not being sent
                     * when OM_Gw_current_OS != EX_active_OS_num), the context
                     * object associated with this new ref-file attachement
                     * is left out-of-date. This causes the above 
                     * GRcontext.GRcheckctx call to fail. Which in turn brings
                     * control here, thus preventing the closure of the
                     * attached ref-file OS. This behaviour is too stringent.
                     * Processing must be allowed to proceed beyond this point
                     * in this case. The fix is put in specific for PDM
                     * Revise Assembly -- characterized by PDM_sleep being on
                     * and the Invis_check_override being on.
                     */

                    IGRboolean PDM_sleep;
                    extern OMuword EX_active_OS_num, EX_ACTINV_OS_num;
                    
                    PDM_sleep = EX_active_OS_num != EX_ACTINV_OS_num;

                    if (! (PDM_sleep && Invis_check_override()))
                      goto wrapup;
                }
                
                count -= 1;
                
                if ((count) && (!master_file))
                {
                    /* 
                     * Check to see if closing this space causes count to 
                     * be 0 due to cyclic attachments. 
                     */
                    new_count = count;

                    GRdecinvtable ( &msg1, &context_id, &count_check_only, &osnum, &new_count );

                    if (new_count <= 0)
                    { 
                        /* 
                         * Force exec to close file. 
                         */
                        Reset_num_opens (index);
                        count = 0;
                    }
                }
                
                GRpush_env ( &new_type, new_matrix );
                
                /* 
                 * Close object space.
                 */
                OMmsg = ex$close_module (ftype = EX_invisible,
                                         index = index,
                                         flag  = flag );
                if (!(1 & OMmsg))
                {
                    char buffer [DI_PATH_MAX + 30];
                    
                    ex$message (msgnumb = GR_E_FileOver,
                                type = "%s",  
                                buff = buffer,
                                var = `me->osname` );

                    UI_error (buffer);

                    ex$close_module (ftype = EX_invisible,
                                     index = index,
                                     flag  = 0 );
                }
        
                GRpush_env ( &env_type, env_matrix );

                if (count > 0)
                {
                    /* 
                     * If the number of opens is greater than 0, then 
                     * we must check for nested files and decrement the 
                     * invisible table for the files which are nested 
                     * in this reference file. 
                     */
                    if (!master_file || (count > 1))
                    {
                        /* 
                         * Decrement the count in the invisible table.
                         */
                        count_check_only = 0;

                        GRdecinvtable (&msg1, 
                                       &context_id, 
                                       &count_check_only, 
                                       NULL, NULL );
                    }
                }
            }
            else /* Matches if (index >= 0) */
            { 
                /* 
                 * Object space not found in inv. table. This means that
                 * this particular reference file's object space isn't 
                 * loaded.
                 */
                OMmsg = OM_W_ABORT;
                *msg = GRFILENOTFOUND;
            }
        }
        else 
        {
            /* 
             * Osnum does not exist 
             */
            OMmsg = OM_W_ABORT;
            *msg = GRFILENOTFOUND;
        }
    }
    else
    {
        /* 
         * File not yet attached.
         */
        *msg = GRNO_PROCESSING_NEEDED;
    }
    
    if ((OMmsg & *msg & 1) && (*type == UNLOAD_FILE))
    {
        /*
         * Set the osname to NULL to keep this file from    
         * being displayed or located if it's not completely
         * unloaded.
         */
        if (om$dimension_of(varray = me->osname))
        {
            me->osname[0] = '\0';
        }
    }
    
 wrapup:

    return OMmsg;
}

end implementation GRreffile;
