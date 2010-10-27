
/* $Id: VDdrwlo_fcn.I,v 1.1.1.1 2001/01/04 21:09:28 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdtbl/mgr/VDdrwlo_fcn.I
 *
 * Description:
 *
 * Implementation file for table manager public function interface
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDdrwlo_fcn.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:09:28  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.2  1997/12/29  05:00:44  pinnacle
# Replaced: vdtbl/mgr/VDdrwlo_fcn.I for:  by ksundar for vds
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.4  1995/08/25  15:15:10  pinnacle
# Replaced: vdtbl/mgr/VDdrwlo_fcn.I for:  by hverstee for vds.240
#
# Revision 1.3  1995/08/16  19:59:06  pinnacle
# Replaced: vdtbl/mgr/VDdrwlo_fcn.I for:  by hverstee for vds.240
#
# Revision 1.2  1995/07/28  16:35:30  pinnacle
# Replaced: vdtbl/mgr/VDdrwlo_fcn.I for:  by hverstee for vds.240
#
# Revision 1.1  1995/06/07  20:09:28  pinnacle
# Created: vdtbl/mgr/* by tdumbach for vds.240
#
# Revision 1.3  1995/05/15  13:30:08  pinnacle
# Replaced: vdtbl/mgr/VDdrwlo_fcn.I by hverstee r#
#
# Revision 1.2  1995/04/29  14:13:00  pinnacle
# Replaced: vdtbl/mgr/VDdrwlo_fcn.I by hverstee r#
#
# Revision 1.1  1995/04/13  14:34:38  pinnacle
# Created: vdtbl/mgr/* by tdumbach r#
# rno
#
# Revision 1.9  1995/04/11  14:55:36  pinnacle
# Replaced: vdtbl/mgr/VDdrwlo_fcn.I by hverstee r#
#
# Revision 1.8  1995/03/29  22:28:02  pinnacle
# Replaced: vdtbl/mgr/VDdrwlo_fcn.I by hverstee r#
#
# Revision 1.7  1995/03/29  22:24:54  pinnacle
# Replaced: vdtbl/mgr/VDdrwlo_fcn.I by hverstee r#
#
# Revision 1.6  1995/03/25  15:38:06  pinnacle
# Replaced: vdtbl/mgr/VDdrwlo_fcn.I by hverstee r#
#
# Revision 1.5  1995/03/20  17:18:18  pinnacle
# Replaced: vdtbl/mgr/VDdrwlo_fcn.I by hverstee r#
#
# Revision 1.3  1995/03/10  00:28:10  pinnacle
# Replaced: vdtbl/mgr/VDdrwlo_fcn.I by hverstee r#
#
# Revision 1.2  1995/03/08  15:10:48  pinnacle
# Replaced: vdtbl/mgr/VDdrwlo_fcn.I by hverstee r#
#
# Revision 1.1  1995/03/06  16:39:34  pinnacle
# Created: vdtbl/mgr/VDdrwlo_fcn.I by hverstee r#
# rno
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *
 *      03/03/95          HV            New
 *
 * -------------------------------------------------------------------*/

class implementation VDdrwlo_occ;

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



IGRint  VD_drwlo_iopen (IGRlong      *msg)
{
  GRspacenum     cur_os;

  ex$get_cur_mod (osnum = &cur_os);

  return (VDtbl_dlo_open (msg, cur_os));
}

IGRint  VD_drwlo_iclose (IGRlong      *msg)

{
  return (VDtbl_dlo_close (msg));
}



IGRint  VD_drwlo_inew  (IGRlong      *msg,
                        IGRchar      *Tabnam,
                        IGRchar      *Tabtyp,
                 struct GRid         *DRWloid)
{
  IGRint         status;
  GRspacenum     cur_os;

  status = OM_S_SUCCESS;

  ex$get_cur_mod (osnum = &cur_os);

           vd$tbldlo_new (msg    = msg,
                          osnum  = cur_os,
                          tabnam = Tabnam,
                          tabtyp = Tabtyp,
                          GRid   = DRWloid);

  return (status);
}

IGRint  VD_drwlo_idelete (IGRlong      *msg,
                          IGRchar      *Tabnam,
                          IGRchar      *Tabtyp)
{
  IGRint         status;
  GRspacenum     cur_os;

  status = OM_S_SUCCESS;

  ex$get_cur_mod (osnum = &cur_os);

           vd$tbldlo_del (msg    = msg,
                          osnum  = cur_os,
                          tabnam = Tabnam,
                          tabtyp = Tabtyp);

  return (status);
}


IGRint  VD_drwlo_getid (IGRlong      *msg,
                        IGRchar      *Tabnam,
                        IGRchar      *Tabtyp,
                 struct GRid         *DRWloid)
{
  IGRint         status;
  GRspacenum     cur_os;

  status = OM_S_SUCCESS;

  ex$get_cur_mod (osnum = &cur_os);

           vd$tbldlo_old (msg    = msg,
                          osnum  = cur_os,
                          tabnam = Tabnam,
                          tabtyp = Tabtyp,
                          GRid   = DRWloid);

  return (status);
}




IGRint  VD_drwlo_getnm (IGRlong      *msg,
                        IGRchar      *Tabtype,
                        IGRshort     *nCount,
                        IGRchar      *Tabnam)
{
  IGRint         status;
  GRspacenum     cur_os;

  status = OM_S_SUCCESS;

  ex$get_cur_mod (osnum = &cur_os);

           vd$tbldlo_idx (msg     = msg,
                          osnum   = cur_os,
                          typin   = Tabtype,
                          p_count = nCount,
                          p_nams  = Tabnam);

  return (status);
}

IGRint  VD_drwlo_getnl (IGRlong      *msg,
                        IGRchar      *Tabtype,
                        IGRshort     *nCount,
                        IGRchar      *Tabnam)
{
  IGRint         status;
  GRspacenum     cur_os;

  status = OM_S_SUCCESS;

  ex$get_cur_mod (osnum = &cur_os);

           vd$tbldlo_idx (msg     = msg,
                          osnum   = cur_os,
                          dbget   = FALSE,
                          typin   = Tabtype,
                          p_count = nCount,
                          p_nams  = Tabnam);

  return (status);
}




IGRint  VD_drwlo_gettp (IGRlong      *msg,
                        IGRshort     *nCount,
                        IGRchar      *Tabtyp)
{
  IGRint         status;
  GRspacenum     cur_os;

  status = OM_S_SUCCESS;

  ex$get_cur_mod (osnum = &cur_os);

           vd$tbldlo_idt (msg     = msg,
                          osnum   = cur_os,
                          p_count = nCount,
                          p_typs  = Tabtyp);

  return (status);
}

IGRint  VD_drwlo_gettl (IGRlong      *msg,
                        IGRshort     *nCount,
                        IGRchar      *Tabtyp)
{
  IGRint         status;
  GRspacenum     cur_os;

  status = OM_S_SUCCESS;

  ex$get_cur_mod (osnum = &cur_os);

           vd$tbldlo_idt (msg     = msg,
                          osnum   = cur_os,
                          dbget   = FALSE,
                          p_count = nCount,
                          p_typs  = Tabtyp);

  return (status);
}





IGRint  VD_drwlo_grect (IGRlong         *msg,
                        IGRchar         *Tabnam,
                        IGRshort         nGrptyp,
                        IGRshort         nColno,
                        IGRchar         *pFieldid,
                        IGRshort         nExt,
                 struct VDdrwlo_extrec  *Exrec,
                        IGRdouble       *xLow,
                        IGRdouble       *yLow,
                        IGRdouble       *xHig,
                        IGRdouble       *yHig)
{
  IGRint         status;
  GRspacenum     cur_os;

  status = OM_S_SUCCESS;

  ex$get_cur_mod (osnum = &cur_os);

           vd$tbldlo_grect (msg     = msg,
                            osnum   = cur_os,
                            tabnam  = Tabnam,
                            ngrp    = nGrptyp,
                            ncol    = nColno,
                            pfield  = pFieldid,
                            nExt    = nExt,
                            Exrec   = Exrec,
                            xlow    = xLow,
                            ylow    = yLow,
                            xhig    = xHig,
                            yhig    = yHig);

  return (status);
}




IGRint  VD_drwlo_gfix  (IGRlong         *msg,
                        IGRchar         *Tabnam,
                        IGRshort         nGrptyp,
                        IGRdouble        xLode,
                        IGRdouble        yLode,
                        IGRshort         nExt,
                 struct VDdrwlo_extrec  *Exrec,
                        IGRdouble       *dHgt,
                        IGRshort        *nCount,
                 struct VDdrwlo_apifix  *Fldrec)
{
  IGRint         status;
  GRspacenum     cur_os;

  status = OM_S_SUCCESS;

  ex$get_cur_mod (osnum = &cur_os);

           vd$tbldlo_gfix  (msg     = msg,
                            osnum   = cur_os,
                            tabnam  = Tabnam,
                            ngrp    = nGrptyp,
                            xlode   = xLode,
                            ylode   = yLode,
                            nExt    = nExt,
                            Exrec   = Exrec,
                            height  = dHgt,
                            count   = nCount,
                            recs    = Fldrec);

  return (status);
}

IGRint  VD_drwlo_gdata (IGRlong         *msg,
                        IGRchar         *Tabnam,
                        IGRshort         nGrptyp,
                        IGRdouble        xLode,
                        IGRdouble        yLode,
                        IGRshort         nExt,
                 struct VDdrwlo_extrec  *Exrec,
                        IGRdouble       *dHgt,
                        IGRshort        *nCount,
                 struct VDdrwlo_data    *Fldrec)
{
  IGRint         status;
  GRspacenum     cur_os;

  status = OM_S_SUCCESS;

  ex$get_cur_mod (osnum = &cur_os);

           vd$tbldlo_gdata (msg     = msg,
                            osnum   = cur_os,
                            tabnam  = Tabnam,
                            ngrp    = nGrptyp,
                            xlode   = xLode,
                            ylode   = yLode,
                            nExt    = nExt,
                            Exrec   = Exrec,
                            height  = dHgt,
                            count   = nCount,
                            recs    = Fldrec);

  return (status);
}

IGRint  VD_drwlo_gtab  (IGRlong         *msg,
                        IGRchar         *Tabnam,
                 struct VDdrwlo_tab     *Tabrec)
{
  IGRint         status;
  GRspacenum     cur_os;

  status = OM_S_SUCCESS;

  ex$get_cur_mod (osnum = &cur_os);

           vd$tbldlo_gtab (msg    = msg,
                           osnum  = cur_os,
                           tabnam = Tabnam,
                           tabrec = Tabrec);

  return (status);
}


end implementation VDdrwlo_occ;

