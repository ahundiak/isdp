/* $Id: VDCmdProjFn.I,v 1.1.1.1 2001/01/04 21:09:05 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdproject/cmd / VDCmdProjFn.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDCmdProjFn.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:09:05  cvs
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
# Revision 1.3  1995/09/25  22:56:14  pinnacle
# Replaced: vdproject/cmd/VDCmdProjFn.I for:  by sundar for vds.240
#
# Revision 1.2  1995/07/24  20:57:36  pinnacle
# Replaced: vdproject/cmd/VDCmdProjFn.I for:  by hverstee for vds.240
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

class implementation VDCmdProj;

#include  <stdio.h>

#include  "OMerrordef.h"
#include  "OMminimum.h"
#include  "OMprimitives.h"
#include  "igrtypedef.h"
#include  "igetypedef.h"
#include  "gr.h"
#include  "godef.h"
#include  "igr.h"
#include  "igrdp.h"
#include  "go.h"
#include  "grdpbdef.h"
#include  "grdpbmacros.h"
#include  "DItypedef.h"
#include  "exmacros.h"
#include  "vdbmacros.h"


#include  "DIprims.h"
#include  "DIdef.h"
#include  "expression.h"
#include  "expmacros.h"

#include  "PDUerror.h"
#include  "VDprojdef.h"
#include  "VDDbDef.h"
#include  "VDmsg.h"

%safe
#include  "VX_FIproto.h"
%endsafe

method save_all( long *sts )
{
  IGRlong   msgnumb=0;
  struct VDSproject  VDSproject;

  if(VdsSetProjectData( me->VDprj_num,me->VDprj_ver, &VDSproject, &msgnumb )
                     != 1)
  {
     *sts = MSFAIL;
     return OM_S_SUCCESS;
  }
  FIg_set_text( me->forms[0].form_ptr, G_TITLE, VDSproject.prj_name ); 
  FIg_set_text( me->forms[0].form_ptr, G_SHIPTYPE, VDSproject.prj_descr ); 
  FIg_set_text( me->forms[0].form_ptr, G_SHIPNUM, VDSproject.ship_number ); 
  FIg_set_text( me->forms[0].form_ptr, G_SHIPNAME, VDSproject.ship_name ); 
  FIg_set_text( me->forms[0].form_ptr, G_DEPT, VDSproject.dept_name ); 
  FIg_set_text( me->forms[0].form_ptr, G_SHIPYARD, VDSproject.prj_client ); 
  FIg_set_text( me->forms[0].form_ptr, G_USER, VDSproject.ship_user ); 
  me->VDprj_units_set = VDSproject.prj_units_set;
  me->VDprj_no = VDSproject.prj_no;
  sprintf(me->VDproject_num,"%s|%d|%d|%s", me->VDprj_num,
					   me->VDprj_units_set, 
					   me->VDprj_no,
					   me->VDprj_ver);

  *sts = MSSUCC;
  return OM_S_SUCCESS;

}

end implementation VDCmdProj;
