
/* $Id: VDcrsum_fcn.I,v 1.1.1.1 2001/01/04 21:09:28 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdtbl/mgr/VDcrsum_fcn.I
 *
 * Description:
 *
 * Implementation file for sort criteria public function interface
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDcrsum_fcn.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:09:28  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.2  1997/12/29  04:59:42  pinnacle
# Replaced: vdtbl/mgr/VDcrsum_fcn.I for:  by ksundar for vds
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.3  1995/08/25  15:14:22  pinnacle
# Replaced: vdtbl/mgr/VDcrsum_fcn.I for:  by hverstee for vds.240
#
# Revision 1.2  1995/07/28  16:35:56  pinnacle
# Replaced: vdtbl/mgr/VDcrsum_fcn.I for:  by hverstee for vds.240
#
# Revision 1.1  1995/06/07  20:09:28  pinnacle
# Created: vdtbl/mgr/* by tdumbach for vds.240
#
# Revision 1.3  1995/05/15  13:30:42  pinnacle
# Replaced: vdtbl/mgr/VDcrsum_fcn.I by hverstee r#
#
# Revision 1.2  1995/04/29  14:12:20  pinnacle
# Replaced: vdtbl/mgr/VDcrsum_fcn.I by hverstee r#
#
# Revision 1.1  1995/04/25  22:21:58  pinnacle
# Created: vdtbl/mgr/VDcrsum_fcn.I by hverstee r#
# rno
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *
 *      04/18/95          HV            New
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

#include "DIdef.h"
#include "DItypedef.h"
#include "DIglob.h"
#include "DIprims.h"

#include "PDUerror.h"

#include "VDdrwlo.h"
#include "VDdrwlo_db.h"
#include "VDdrwlo_int.h"
#include "VDdrwlo_pr.h"

#include "v_miscmacros.h"
#include "vdtblmacros.h"

/*
#define   MY_DEBUG
*/



IGRint  VD_crsum_iopen (IGRlong      *msg)
{
  GRspacenum     cur_os;

  ex$get_cur_mod (osnum = &cur_os);

  return (VDtbl_suc_open (msg, cur_os));
}


IGRint  VD_crsum_inew  (IGRlong      *msg,
                        IGRchar      *Tabnam,
                 struct GRid         *DRWloid)
{
  GRspacenum     cur_os;
  IGRint         status;

  ex$get_cur_mod (osnum = &cur_os);

           vd$tblsuc_new (msg    = msg,
                          osnum  = cur_os,
                          tabnam = Tabnam,
                          GRid   = DRWloid);

  return (status);
}

IGRint  VD_crsum_iclose (IGRlong      *msg)

{
  return (VDtbl_suc_close (msg));
}


IGRint  VD_crsum_idelete (IGRlong      *msg,
                          IGRchar      *Tabnam)
{
  IGRint         status;
  GRspacenum     cur_os;

  status = OM_S_SUCCESS;

  ex$get_cur_mod (osnum = &cur_os);

           vd$tblsuc_del (msg    = msg,
                          osnum  = cur_os,
                          tabnam = Tabnam);

  return (status);
}





IGRint  VD_crsum_getid (IGRlong      *msg,
                        IGRchar      *Tabnam,
                 struct GRid         *DRWloid)
{
  IGRint         status;
  GRspacenum     cur_os;

  status = OM_S_SUCCESS;

  ex$get_cur_mod (osnum = &cur_os);

           vd$tblsuc_old (msg    = msg,
                          osnum  = cur_os,
                          tabnam = Tabnam,
                          GRid   = DRWloid);

  return (status);
}

IGRint  VD_crsum_getnm (IGRlong      *msg,
                        IGRboolean    bLocal,
                        IGRshort     *nCount,
                        IGRchar      *Tabnam)
{
  IGRint         status;
  IGRboolean     bDB;
  GRspacenum     cur_os;

  status = OM_S_SUCCESS;

  bDB = (!bLocal);

  ex$get_cur_mod (osnum = &cur_os);

           vd$tblsuc_idx (msg     = msg,
                          osnum   = cur_os,
                          dbget   = bDB,
                          p_count = nCount,
                          p_nams  = Tabnam);

  return (status);
}




IGRint  VD_crsum_gtab  (IGRlong         *msg,
                        IGRchar         *Tabnam,
                 struct VDdrwlo_sstab   *Tabrec)
{
  IGRint         status;
  GRspacenum     cur_os;

  status = OM_S_SUCCESS;

  ex$get_cur_mod (osnum = &cur_os);

           vd$tblsuc_gtab (msg    = msg,
                           osnum  = cur_os,
                           tabnam = Tabnam,
                           tabrec = Tabrec);

  return (status);
}

IGRint  VD_crsum_gsqty (IGRlong         *msg,
                        IGRchar         *Tabnam,
                        IGRchar         *Category,
                        IGRchar         *SubCategory,
                        IGRshort        *nCount,
                 struct VDdrwlo_sqty    *Qtyrec)

{
  IGRint         status;
  GRspacenum     cur_os;

  status = OM_S_SUCCESS;

  ex$get_cur_mod (osnum = &cur_os);

           vd$tblsuc_gsqty (msg     = msg,
                            osnum   = cur_os,
                            tabnam  = Tabnam,
                            cat     = Category,
                            subcat  = SubCategory,
                            count   = nCount,
                            recs    = Qtyrec);

  return (status);
}



IGRint  VD_crsum_gsmtc (IGRlong         *msg,
                        IGRchar         *Tabnam,
                        IGRchar         *Category,
                        IGRchar         *SubCategory,
                        IGRshort         nIndex,
                        IGRshort        *nCount,
                 struct VDdrwlo_smatch  *Mtcrec)

{
  IGRint         status;
  GRspacenum     cur_os;

  status = OM_S_SUCCESS;

  ex$get_cur_mod (osnum = &cur_os);

           vd$tblsuc_gsmtc (msg     = msg,
                            osnum   = cur_os,
                            tabnam  = Tabnam,
                            cat     = Category,
                            subcat  = SubCategory,
                            index   = nIndex,
                            count   = nCount,
                            recs    = Mtcrec);

  return (status);
}

end implementation VDcrsum;

