
/* $Id: VDcrsum_over.I,v 1.1.1.1 2001/01/04 21:09:28 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdtbl/mgr/VDcrsum_over.I
 *
 * Description:
 *
 * Implementation file for summarization criteria manager AC and ND overrides
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDcrsum_over.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:09:28  cvs
 *      Initial import to CVS
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
# Revision 1.1  1995/06/07  20:09:28  pinnacle
# Created: vdtbl/mgr/* by tdumbach for vds.240
#
# Revision 1.1  1995/04/25  22:23:14  pinnacle
# Created: vdtbl/mgr/VDcrsum_over.I by hverstee r#
# rno
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *
 *      04/14/95          HV            New
 *
 * -------------------------------------------------------------------*/

class implementation VDcrsum;

#include <ctype.h>
#include <string.h>
#include <stdio.h>

#include "OMerrordef.h"
#include "OMminimum.h"
#include "OMmacros.h"
#include "OMprimitives.h"

#include "igetypedef.h"
#include "igrtypedef.h"
#include "gr.h"
#include "ASmatrix.h"
#include "asdef.h"
#include "asmacros.h"
#include "acmacros.h"
#include "asbox.h"
#include "AS_status.h"
#include "macro.h"
#include "parametric.h"
#include "msdef.h"
#include "nddef.h"
#include "acrepdef.h"
#include "exdef.h"
#include "exmacros.h"
#include "msmacros.h"
#include "vdbmacros.h"



/*     make sure these methods do nothing untoward.... */

method NDupdate(          int      *msg;
                          int       cn_type, count;
                   struct GRid     *parents;
                          int      *parent_state;
                   struct GRid     *context,*new_objid;
                   struct GRmd_env *md_env)

{
  *msg = MSSUCC;

  return (OM_S_SUCCESS);
}

method ACconstruct_feet( IGRlong *msg; IGRint cn_type;
                           IGRint count; struct GRid list [];
                           struct GRmd_env *md_env;
                           int *fcount; struct GRid  *feet_list)
{
  *msg = MSSUCC;
  *fcount = 0;
  return (OM_S_SUCCESS);
}

/*    do nothing with macro's etc.    */

method  NDsleep(struct GRmd_env *md_env)
{
 return om$send(msg = message ASnode.NDsleep(md_env),
                targetid = my_id,
                mode = OM_e_wrt_message);
}
end implementation VDcrsum;

