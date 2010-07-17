class implementation Root;

/**************************************************************************
 Doc : SFApiConvertPlateAndStfnrs

 Desrciption :  This function converts plate along with its stiffeners,
		if any.

 History :

 Date	   Who       Revision	Why
 -----     ---       --------   ---
 04-18-96  raju	     2.4.0.2	Creation

************************************************************************/

#include "OMminimum.h"
#include "OMprimitives.h"
#include "OMerrordef.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "godef.h"
#include "go.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "ACrg_collect.h"

#include "vderrmacros.h"

#include "SFdef.h"
#include "SFmsg.h"
#include "SFconvDef.h"
#include "SFconvStruct.h"


long	SFApiConvertPlateAndStfnrs (
  long			*msg,		/* O - return status */
  struct GRid		*VSplId,	/* I - objid of the plate */
  struct GRmd_env	*VSplEnv,	/* I - mod env of plate */
  char			PlateSurfOpt[], /* I - Plate surface option */ 
  double		offset,		/* I - offset from plate surface */
  char			BmExtractOpt[], /* I - beam extraction option */
  int			ElemType,	/* I - element type for meshing, when
					       meshing option is selected */
  int			NbFemElem	/* I - No. of FEM elements when meshing
					       option is selected */
)
{
long			sts;
struct SFConvOpt	ConvOpt;	/* I - conversion optins  */
struct IGRdisplay	disp;
int			numberOfBytes,
			BytesReceived;



  sts  = OM_S_SUCCESS;
  *msg = MSSUCC;

  __DBGpr_obj("Begin convert plate", *VSplId);

  numberOfBytes = sizeof ( struct GRmd_env );
  gr$get_module_env(    msg     = msg,
			sizbuf  = &numberOfBytes,
			buffer  = &ConvOpt.MasterEnv,
			nret    = &BytesReceived );
  ConvOpt.RefEnv = *VSplEnv;
  strcpy ( ConvOpt.PlateSurfOpt, PlateSurfOpt );
  ConvOpt.offset = offset ;
  ConvOpt.ExtractStiffs = TRUE;
  strcpy ( ConvOpt.BmExtractOpt, BmExtractOpt );
  ConvOpt.ElemType = ElemType;
  ConvOpt.NbFemElem = NbFemElem;
  ConvOpt.ConvAllEl = TRUE;

  /*
   * fill construction list
   */
  numberOfBytes = sizeof ( IGRshort );
  gr$get_active_layer( msg     = msg,
                       sizbuf  = &numberOfBytes,
                       buffer  = &(ConvOpt.cst.level),
                       nret    = &BytesReceived );

  numberOfBytes = sizeof ( struct IGRdisplay );
  gr$get_active_display(msg     = msg,
                        sizbuf  = &numberOfBytes,
                        buffer  = &disp,
                        nret    = &BytesReceived );

  ConvOpt.cst.msg        = msg;
  ConvOpt.cst.env_info   = &ConvOpt.MasterEnv;
  ConvOpt.cst.display    = &disp;
  ConvOpt.cst.newflag    = FALSE;
  ConvOpt.cst.geometry   = NULL;
  ConvOpt.cst.class_attr = NULL;
  ConvOpt.cst.properties = GRIS_LOCATABLE | GRIS_DISPLAYABLE;
  ConvOpt.cst.name       = NULL;

  /*
   * see if the reference file is attached updatable
   */
  sts = SFis_reffile_writable(  msg,
				VSplId->osnum,
				NULL,
				&ConvOpt.reffile_writable );
  VDS_ERR_HNDLR( "SFConvertPlateAndStfnrs", sts, *msg, VD_VERBOSE, wrapup );

  sts = SFConvertPlateAndStfnrs ( msg,
				  VSplId,
				  &ConvOpt);
  VDS_ERR_RPT( "SFConvertPlateAndStfnrs", sts, *msg, VD_VERBOSE );

wrapup:

  return sts;

}

end implementation Root;
