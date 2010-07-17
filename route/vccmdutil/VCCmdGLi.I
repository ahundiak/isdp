
/* $Id: VCCmdGLi.I,v 1.1.1.1 2001/01/04 21:12:30 cvs Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:        vccmdutil/VCCmdGLi.I
 *
 * Description:
 *      Command object for set cabling globals
 *
 * Dependencies:
 *
 * Revision History:
 *        $Log: VCCmdGLi.I,v $
 *        Revision 1.1.1.1  2001/01/04 21:12:30  cvs
 *        Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/10/30  04:17:36  pinnacle
# Integration of Cable into 02.04.03.04
#
# Revision 1.3  1997/07/31  20:27:54  pinnacle
# Replaced: vccmdutil/VCCmdGLi.I for:  by hverstee for cabling
#
# Revision 1.2  1997/07/26  14:00:26  pinnacle
# Replaced: vccmdutil/VCCmdGLi.I for:  by hverstee for cabling
#
# Revision 1.1  1997/07/22  15:23:14  pinnacle
# Created: vccmdutil/VCCmdGLi.I by hverstee for cabling
#
 *
 * History:
 *        01/20/97        hv        Initial
 *
 *************************************************************************/

class implementation VCCmdGL;

#include <stdio.h>
#include <float.h>

#include "FI.h"
#include "OMmacros.h"
#include "OMprimitives.h"
#include "OMtypes.h"
#include "ODE.h"

#include "igetypedef.h"
#include "igrdef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "grio.h"

#include "ex.h"
#include "exmacros.h"
#include "msdef.h"
#include "dpdef.h"
#include "dpstruct.h"
#include "dpmacros.h"
#include "coimport.h"
#include "COBmacros.h"

#include "asmacros.h"
#include "asbox.h"
#include "AS_status.h"
#include "ACrg_collect.h"
#include "acrepdef.h"
#include "acrepmacros.h"

%safe
#include "VX_FIproto.h"
%endsafe

#include "VCdefine.h"
#include "VCstructs.h"
#include "VCproto.h"
#include "VCsys.h"
#include "VCchansel.h"
#include "VCCmdDef.h"
#include "VCCmdSYS.h"

method VCGLstart ( int * sts )
{
  IGRchar    *fptr;
  IGRdouble   dd;

  me->bPres   = VCSYSGLB_preserve;
  me->bDynOff = VCSYSGLB_offset;
  me->bDynCp  = VCSYSGLB_dyncpt;

  strcpy (me->szBrk, VCSYSGLB_brkchr);

  fptr = me->forms[0].form_ptr;

  VC_Cmd_form_open (fptr , VC_FPOS_GLOB);

  dd = me->bPres;
  FIg_set_value (fptr, VC_GDG_PRESERVE, dd);
  dd = me->bDynCp;
  FIg_set_value (fptr, VC_GDG_DYNCPT  , dd);
  dd = me->bDynOff;
  FIg_set_value (fptr, VC_GDG_OFFSET  , dd);

  FIg_set_text  (fptr, VC_GDG_BRKCHR  , me->szBrk);

  return OM_S_SUCCESS;
}

method VCGLcleanup ( int * sts )
{
  IGRint      status;

  VC_Cmd_form_close (me->forms[0].form_ptr, VC_FPOS_GLOB);

  status =
  om$send(  msg = message VDS_LOCATE.delete ( 0 ) ,
           mode = OM_e_wrt_message,
       targetid = my_id);

  return OM_S_SUCCESS;
}

method form_notification ( int       form_label ;
                           int       gadget_label ;
                           double    value ;
                           char    * form_ptr )
{
  IGRint            status;
  IGRlong           retmsg;
  IGRdouble         dtmp;

  switch( gadget_label )
  {
    case FI_CANCEL:
      _put_response( resp = EX_FORM_FINISHED );
      break;

    case FI_ACCEPT: /*    move to globals     */
      VCSYSGLB_preserve = me->bPres;
      VCSYSGLB_dyncpt   = me->bDynCp;
      VCSYSGLB_offset   = me->bDynOff;

      strcpy (VCSYSGLB_brkchr, me->szBrk);

      _put_response( resp = EX_FORM_FINISHED );
      break;

    case VC_GDG_PRESERVE:
      FIg_get_value( form_ptr, gadget_label, &dtmp);
    
      me->bPres = (dtmp) ? TRUE : FALSE;
      break;

    case VC_GDG_DYNCPT:
      FIg_get_value( form_ptr, gadget_label, &dtmp);
    
      me->bDynCp = (dtmp) ? TRUE : FALSE;
      break;

    case VC_GDG_OFFSET:
      FIg_get_value( form_ptr, gadget_label, &dtmp);
    
      me->bDynOff = (dtmp) ? TRUE : FALSE;
      break;

    case VC_GDG_BRKCHR:
      FIg_get_text (form_ptr, gadget_label, me->szBrk);
      break;

    case VC_GDG_CLEARBTN:
      status = VCDB_clear (&retmsg, VC_GLB_writable_os);

      UI_status (" Database Cache cleared");
      break;

    default:
      break;
  }

  quit:
  return OM_S_SUCCESS;
}

end implementation VCCmdGL;

