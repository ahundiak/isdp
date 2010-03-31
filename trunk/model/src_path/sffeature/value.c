/*
  OVERVIEW
  APIs on the PWvalueinfo structure.

  NOTES

  HISTORY
  Aditya  03/19/96  Creation
*/

#include "OMminimum.h"
#include "PWminimum.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "ex.h"
#include "gr.h"
#include "dp.h"
#include "igr.h"
#include "igrdef.h"
#include "igrdp.h"
#include "godef.h"
#include "go.h"
#include "griodef.h"
#include "grio.h"

#include "EMSasnuc.h"
#include "PWerror.h"
#include "PWmodel.h"
#include "valinfo.h"

extern OMuword OPP_EMSparamvl_class_id;

PWresult PutValueInfo
(
  struct PWvalueinfo *invalinfo,
  struct EMSvalue_info *outvalinfo
)
{
  PWresult PWsts;

  PWsts = PW_K_Success;

  if(!outvalinfo)
    OnErrorState(TRUE, PWsts, PW_K_InvalidArg, wrapup);

  outvalinfo->type = EMSdatainfo_undefined;
  outvalinfo->val = 0.0;
  outvalinfo->valname[0] = '\0';
  outvalinfo->valobj.objid = NULL_OBJID;
  outvalinfo->valobj.osnum = 0;
  outvalinfo->valevent = NULL;

  if(!invalinfo || invalinfo->type == value_null)
  {
    OnErrorState(TRUE, PWsts, PW_K_Success, wrapup);
  }

  if(invalinfo->type == value_numeric)
  {
    outvalinfo->type = EMSdatainfo_numeric;
    outvalinfo->val = invalinfo->value;
  }
  else if(invalinfo->type == value_name)
  {
    outvalinfo->type = EMSdatainfo_name;
    strcpy(outvalinfo->valname, invalinfo->name);
  }

wrapup:
  return(PWsts);
}

PWresult GetValueInfo
(
  struct EMSvalue_info *invalinfo,
  struct PWvalueinfo *outvalinfo
)
{
  PWresult PWsts;

  PWsts = PW_K_Success;

  if(!outvalinfo)
    OnErrorState(TRUE, PWsts, PW_K_InvalidArg, wrapup);

  outvalinfo->type = value_null;
  outvalinfo->value = 0.0;
  outvalinfo->name[0] = '\0';

  if(!invalinfo || invalinfo->type == EMSdatainfo_undefined)
    OnErrorState(TRUE, PWsts, PW_K_Success, wrapup);

  if(invalinfo->type == EMSdatainfo_numeric)
  {
    outvalinfo->type = value_numeric;
    outvalinfo->value = invalinfo->val;
  }
  else if( outvalinfo->type == EMSdatainfo_name)
  {
    outvalinfo->type = value_name;
    strcpy(outvalinfo->name, invalinfo->valname);
  }
  else
  {
    OnErrorState(TRUE, PWsts, PW_K_NotImplemented, wrapup);
  }

wrapup:
  return(PWsts);
}


PWresult GetExpressionFromParamvlObject
(
  PWobjid objid,
  PWosnum os,
  struct PWvalueinfo *valinfo
)
{
  char expression[DI_PATH_MAX];
  PWresult PWsts = PW_K_Success;
  PWclassid classid;
  struct PWommsg message;
  struct { char *expression; } args;

  classid = omClassidFromObjid ( objid, os);
  if ( ! omIsAncestryValid ( classid , OPP_EMSparamvl_class_id ))
  {
    OnErrorState( TRUE, PWsts, PW_K_InvalidArg, wrapup);
  }

  args.expression = expression;
  PWsts = omMakeMessage("expression", "DIget_edit_string",
                        (void *)&args, sizeof(args), &message );
  OnErrorCode( PWsts, wrapup);

  PWsts = omSend (&message, objid, os, PW_K_NullObjid, FALSE);
  OnErrorCode( PWsts, wrapup);

  strcpy( &valinfo->name[0], expression);
  valinfo->type = value_name;

wrapup:
  return(PWsts);
}
