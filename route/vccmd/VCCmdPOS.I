
/* $Id: VCCmdPOS.I,v 1.2 2002/05/08 15:48:23 anand Exp $  */

/* --------------------------------------------------------------------
 * I/CABLE
 *
 * File:        vccmd/VCCmdPOS.I
 *
 * Description:
 *
 * Implementation file for VCCmd form position definition
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VCCmdPOS.I,v $
 *      Revision 1.2  2002/05/08 15:48:23  anand
 *      Files added/modified for sub-cable functionality.
 *
 *      Revision 1.1.1.1  2001/01/04 21:12:27  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/10/30  04:15:40  pinnacle
# Integration of Cable into 02.04.03.04
#
# Revision 1.6  1997/07/22  16:05:42  pinnacle
# Replaced: vccmd/VCCmdPOS.I for:  by hverstee for cabling
#
# Revision 1.5  1997/05/22  14:45:40  pinnacle
# Replaced: vccmd/VCCmdPOS.I for:  by hverstee for cabling
#
# Revision 1.4  1997/05/07  14:17:26  pinnacle
# Replaced: vccmd/VCCmdPOS.I for:  by hverstee for cabling
#
# Revision 1.3  1997/01/09  23:05:42  pinnacle
# Replaced: vccmd/VCCmdPOS.I for:  by hverstee for cabling
#
# Revision 1.2  1997/01/09  19:58:52  pinnacle
# Replaced: vccmd/VCCmdPOS.I for:  by hverstee for cabling
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *
 *      12/26/96          HV            New
 *
 * -------------------------------------------------------------------*/

class implementation Root;

#include <stdio.h>
#include <float.h>

#include "OMprimitives.h"
#include "OMmacros.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "gr.h"
#include "FI.h"
#include "FEI.h"
#include "ACattrib.h"
#include "ACrg_collect.h"
#include "AS_status.h"
#include "acrepdef.h"

#include "ex.h"
#include "exmacros.h"
#include "msdef.h"
#include "asdef.h"
#include "dpdef.h"
#include "dpstruct.h"
#include "dpmacros.h"
#include "asmacros.h"
#include "acrepmacros.h"
#include "nddef.h"
#include "ndmacros.h"
#include "coimport.h"
#include "COBmacros.h"

#include "VCdefine.h"
#include "VCstructs.h"
#include "VCCmdDef.h"
#include "VCparameters.h"
#include "VCproto.h"

%safe
#include "VX_FIproto.h"

static
IGRint       XP[VC_FPOS_MAX] =
 {-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,
  -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1};

static
IGRint       YP[VC_FPOS_MAX] =
 {-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,
  -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1};
%endsafe

/*
#define MY_DEBUG
*/


extern
IGRint     VC_Cmd_form_open  (IGRchar    *fptr,
                              IGRint      indic)
{

  VC_Cmd_form_pos (fptr, indic);

  FIf_display (fptr);

  return OM_S_SUCCESS;
}

extern
IGRint     VC_Cmd_form_pos   (IGRchar    *fptr,
                              IGRint      indic)
{
  if ((indic >= 0) && (indic < VC_FPOS_MAX))
  {
    if ((XP[indic] != -1) && (YP[indic] != -1))
      FIf_set_location (fptr, XP[indic], YP[indic]);
  }

  return OM_S_SUCCESS;
}

extern
IGRint     VC_Cmd_form_close  (IGRchar    *fptr,
                               IGRint      indic)
{
  if ((indic >= 0) && (indic < VC_FPOS_MAX))
  {
    FIf_get_location (fptr, &XP[indic], &YP[indic]);
#ifdef MY_DEBUG
    printf (" saved formpos %d %d %d\n",indic, XP[indic], YP[indic]);
#endif
    FIf_erase        (fptr);
  }

  return OM_S_SUCCESS;
}

end implementation Root;

