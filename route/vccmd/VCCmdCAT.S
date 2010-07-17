
/* $Id: VCCmdCAT.S,v 1.1.1.1 2001/01/04 21:12:27 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/CABLE
 *
 * File:        vccmd/VCCmdCAT.S
 *
 * Description:
 *
 *  Specification file for Attribute handling
 *
 * Dependencies:
 *
 * Revision History:
 *     $Log: VCCmdCAT.S,v $
 *     Revision 1.1.1.1  2001/01/04 21:12:27  cvs
 *     Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/10/30  04:15:40  pinnacle
# Integration of Cable into 02.04.03.04
#
# Revision 1.10  1997/07/14  22:50:54  pinnacle
# Replaced: vccmd/VCCmdCAT.S for:  by hverstee for cabling
#
# Revision 1.9  1997/05/07  14:12:02  pinnacle
# Replaced: vccmd/VCCmdCAT.S for:  by hverstee for cabling
#
# Revision 1.8  1997/01/03  18:01:02  pinnacle
# Replaced: vccmd/VCCmdCAT.S for:  by hverstee for cabling
#
# Revision 1.7  1996/11/06  17:47:36  pinnacle
# Replaced: vccmd/VCCmdCAT.S for:  by hverstee for cabling
#
# Revision 1.6  1996/10/25  14:26:36  pinnacle
# Replaced: vccmd/VCCmdCAT.S for:  by hverstee for cabling
#
# Revision 1.5  1996/10/11  21:50:10  pinnacle
# Replaced: vccmd/VCCmdCAT.S for:  by hverstee for cabling
#
# Revision 1.4  1996/10/03  18:27:52  pinnacle
# Replaced: vccmd/VCCmdCAT.S for:  by hverstee for cabling
#
# Revision 1.3  1996/09/26  21:08:28  pinnacle
# Replaced: vccmd/VCCmdCAT.S for:  by hverstee for cabling
#
# Revision 1.2  1996/09/20  21:31:06  pinnacle
# Replaced: vccmd/VCCmdCAT.S for:  by hverstee for cabling
#
# Revision 1.1  1996/08/28  22:11:34  pinnacle
# Created: vccmd/VCCmdCAT.S by hverstee for cabling
#
 *
 * History:
 *      MM/DD/YY        AUTHOR        DESCRIPTION
 *
 *      06/21/96          HV            New
 *
 * -------------------------------------------------------------------*/

class specification VCCmdCAT (1:0) of VCAT;

#include <stdio.h>
#include <float.h>

#include "OMprimitives.h"
#include "OMmacros.h"
#include "OMtypes.h"
#include "ODE.h"

#include "igrdef.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "gr.h"
#include "grio.h"

#include "FI.h"
#include "FEI.h"
#include "ACattrib.h"
#include "ACrg_collect.h"
#include "AS_status.h"
#include "acrepdef.h"
#include "acrepmacros.h"

#include "ex.h"
#include "exmacros.h"
#include "msdef.h"
#include "asdef.h"
#include "dpdef.h"
#include "dpstruct.h"
#include "dpmacros.h"
#include "asmacros.h"
#include "nddef.h"
#include "ndmacros.h"
#include "coimport.h"
#include "COBmacros.h"

#include "bsvalues.h"
#include "bserr.h"
#include "bstypes.h"
#include "bsparameters.h"

#include "parametric.h"

#include "VDSutil.h"
#include "VDDfEntCode.h"

/**************************************************************/
/*    Needed for collections handling -- ROUTING functions    */

#include "VRattr_def.h"
#include "VRutildef.h"
#include "VRact_params.h"
#include "VRutilmacros.h"

/**************************************************************/

#include "VCdefine.h"
#include "VCparameters.h"
#include "VCTagDef.h"
#include "VCstructs.h"
#include "VCmacros.h"

#include "VCCmdDef.h"
#include "VCCmdCAT.h"
#include "VCCmdStr.h"

instance VCCmdCAT
{
  /*C my return  */
  IGRint       MyRet;

  IGRboolean   bTagByp;      /*  Bypass tagcheck in case of merging cables  */

  IGRshort     nObjRep;
  IGRint       nObjType;
  IGRint       nTagCat;

  /*C Object Id we're working on   */
  struct GRid  CompId;

  /*C Attributes which are stored in Objects Instance data */
  IGRchar      CompCode[VC_MAX_CCODE];
  IGRchar      CompTag[VC_MAX_TAGNO];
  IGRchar      CompNoMtoFlag;

  IGRchar      CompDesc[VC_MAX_SDESC];

  /*C to distinguish the product */
  IGRint       Product;

  /*C flag to indicate the command type */
  IGRshort     CmdType;
  IGRshort     CmdProd;

  IGRshort      nFOstart;       /* cutover          */
  IGRshort      nCC;            /* number in list   */
  IGRchar      *CClist;         /* compcode list    */
  IGRchar      *CCdesc;         /* compdesc list    */

  /*  for attribute handling, which ones have been changed?  */

  IGRboolean    bCCch;
  IGRboolean    bTGch;
  IGRboolean    bSAch;
  IGRboolean    bUAch;
};

/*C  Initialize my instance data */
override init;

message  VCATExit (IGRlong    *msg);

/*C  gets the data stored with the link( Uses GetInstance) and
  stores it in my instance */
message VCATGetData (IGRlong      *msg;    /* I/O - return status */
                     struct GRid  *LnId);  /* I - Link Id         */

/*C  Fills up the the sys form */
message VCATSysForm (IGRlong      *msg;    /* I/O - return status */
                     IGRchar      *FormPtr);  /* I - Form to fill up */

/*C   Sys form notification ( operates on all active params ) */
message  VCATSysFormNot (
  int       gadget_label;   /* I : gadget label  */
  double    value;          /* I :          */
  char     *form_ptr;       /* I : sys form ptr  */
  char     *UsrFormPtr;     /* I : user form Ptr */
);

/*A form notification for user attributes form */
message  VCATUsrFormNot(
  int       gadget_label;   /* gadget label    */
  double    value;          /* I : value     */
  char     *form_ptr        /* I : search attr form ptr*/
);

/*C  */  
message  VCATChgLnAttr(
  IGRlong         *msg;      /* I/O - return status  */
  struct  GRid    *LnId;     /* I -  Link Id    */
  struct  GRid    *SysId;    /* I - System  Id  */
  struct  GRid    *UsrId;    /* I - User Id    */
);

/*C  Loads the identified cable's attributes in to the sys form
  this has to be called soon after the locate action */
message  VCATLoadLnAttr (IGRchar    *SysFormPtr;  /* I : sys form to update */
                 struct  GRid       *LnId);  /* I : Link to copy from */

/*C load compcode list     */
message  VCATlist (IGRlong      *msg);

/*C Check compcode/tagno validity   */
message  VCATcheck (IGRlong      *msg);

override  VCAT_sdsp;

end specification VCCmdCAT;
