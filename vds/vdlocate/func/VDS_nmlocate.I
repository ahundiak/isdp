/* $Id: VDS_nmlocate.I,v 1.1.1.1 2001/01/04 21:08:53 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdlocate/func / VDS_nmlocate.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDS_nmlocate.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:53  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

/* #######################    APOGEE COMPILED   ######################## */

/*
Name
        VDSnmlocate ( LCnmlocate, with modifications )

Description
        This routine provides an interface to the directory subsytem.
        It sets up the cvl structure and then does a pass on the directory
        looking to send the GRlocate message to the proper objects.

History
	adz	12/10/92	Creation date.
*/

class implementation Root;

#include "grimport.h"
#include "OMminimum.h"
#include "OMprimitives.h"
#include "OMindex.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "godef.h"
#include "go.h"
#include "dp.h"
#include "exdef.h"
#include "ex.h"
#include "griodef.h"
#include "grio.h"
#include "lcdef.h"
#include "lc.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DImacros.h"
#include "DIprims.h"
#include "dpstruct.h"
#include "lcpriv.h"
#include "msdef.h"
#include "ms.h"
#include "msmacros.h"

from GRgraphics	import GRgetname;

IGRint VDSnmlocate(rc, in_express, modenv, attr, act_handler,
                   locate_args, stack, regex, act_parms, classes)

IGRlong *rc;
IGRchar *in_express;
struct GRmd_env *modenv;
struct GRlc_locate *attr;
IGRint (*act_handler)();
struct LC_action_args *locate_args;
struct GRlc_stack *stack;
IGRint regex;
IGRchar *act_parms;
OM_p_CLASSLIST classes;
{
    IGRlong sts;
    IGRint  LCptlocact();
    struct GRlc_cvl cvl;
    IGRint levels[32];
    IGRint ii;
    OM_S_CLASSLIST class_list;
    OMuword        class_id;
    OM_S_MESSAGE   locate_message;
    IGRint         how_big;
    struct LClockludge locate_kludge;
    IGRchar        express[256];  /* maximum length of name counting path*/
    IGRchar        refexpress[256];

    extern int VDStranslate();

    /*
     *  Set up set information about regular expressions
     */

    locate_args->located = 0;
    *rc = LC_NO_OBJ_LOCATED;

    strcpy (express, in_express);
    di$cvt_name_from_input( u_path = express);

    /*
     *  Check to see if the string is a regular expression by the directory
     *  standards.
     */

    if (di$is_regexp (regexp = express))
    {
        /*
         *  If it is a regular expression initialize the graphics set
         *  properly.
         */

        if (regex)
        {
            locate_args->is_regex = 1;
            LCgsinit(modenv, & locate_args->gs_id, &locate_args->sv_id);
        }
        else
        {
            /*
             *  If regular expressions are not allowed by the command say so
             */

            sts = 1;
            ex$message (msgnumb = LC_NO_MSG,
                        in_buff = "Regular expression not allowed",
                        field = ERROR_FIELD);
            goto WRAP;
        }
    }
    else
    {
        /*
         *  Else for is (di$...).  Set this for later reference, in action
         *  handlers.
         */

        locate_args->is_regex = 0;
    }

    stack->module = modenv->md_id;

    /*
     *  Set up cvl structure from input arguments
     */

    cvl.msg = *rc;
    cvl.module = *modenv;
    cvl.attributes.obj_attr = *attr;
    cvl.attributes.type = GR_nam_loc;
    cvl.attributes.acc_tolerance = 100000;
    cvl.action_handler = act_handler;
    for (ii = 0; ii <32; ii++)
    {
        levels[ii] = 0xffffffff;
    }
    cvl.levels = levels;
    cvl.locate_args = locate_args;
    cvl.act_parms = act_parms;
    cvl.r_classes = NULL;
    cvl.classes = classes;

    /*
     *  Pass through the directory structure 
     */

    /*
     *  Call method instead of macro 
     */

    class_list.w_flags = OM_CLST_subclass;
    class_list.w_count = 1;
    class_list.p_classes = &class_id;

    /*
     *  The classlist is so that only objects of the class GRgraphics
     *  or their subclasses recieve the GRlocate message.  This would
     *  be equivalent to the rtree classes.  That is not done here
     *  because it would cause an inconsistent interface with the
     *  Rtree.
     */

    om$get_classid (classname = "GRgraphics", p_classid = &class_id);

    locate_kludge.cvl = &cvl;
    locate_kludge.range_key = NULL;

    how_big = sizeof (locate_kludge);

    om$make_message (classname = "GRgraphics", 
                     methodname = "GRlocate", 
                     size = how_big,
                     p_arglist = &locate_kludge, 
                     p_msg = &locate_message);

    sts = di$pass (msg = &locate_message,
                   regexp = express, 
                   p_classes = &class_list);

    if ((ERRO & sts) || (sts & SEVE)){
        goto WRAP;
    }

    if (!locate_args->located)
    {
        di$give_pathname (osnum = modenv->md_id.osnum, pathname = refexpress);
        di$strcat (to = refexpress, from = "ref");
        di$strcat (to = refexpress, from = "refnames");
        di$strcat (to = refexpress, from = express);

        sts = di$pass (msg = &locate_message,
                       regexp = refexpress, 
                       p_classes = &class_list);
    }

    /*
     *  If regular expression send proper termination codes to 
     *  graphics set.
     */

    if( ! locate_args->located )
    {

        /*
         * Try to find the object by the search path system.
         */

        sts = 
        VDStranslate( express,
                      &locate_args->gs_id.objid,
                      &locate_args->gs_id.osnum,
                      NULL );

        if( sts == DIR_S_SUCCESS )
        {
            IGRlong mes;
            IGRchar obj_name[DI_PATH_MAX*2];

            obj_name[0] ='\0';

            /*
             * get the total object name of the found object.
             */
            sts =
            om$send(msg = message GRgraphics.GRgetname( &mes, obj_name ),
                    targetid = locate_args->gs_id.objid,
                    targetos = locate_args->gs_id.osnum,
                    senderid = NULL_OBJID );
            if(sts&mes&1)
            {
                /*
                 * get the GRlocate message of the object name
                 */
                sts = di$pass (msg = &locate_message,
                             regexp = obj_name, 
                             p_classes = &class_list);

                if ((ERRO & sts) || (sts & SEVE))
                {
                    /* object not found !! */
                    goto WRAP;
                }
            }
        }
    }
                         
    if (locate_args->located)
    {
        *rc = LC_OBJS_IN_STACK;
        if (locate_args->is_regex)
        {
            LCgsend (&locate_args->gs_id, modenv, stack);
        }
    }
    else
    {
        *rc = LC_NO_OBJ_LOCATED;
        if (locate_args->is_regex)
        {
            LCgsclean(locate_args->gs_id);
        }
    }
    sts = 1;

WRAP:

    return (sts);
}

end implementation Root;
