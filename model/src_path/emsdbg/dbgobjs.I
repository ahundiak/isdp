class implementation GRgrgrp;

#include <memory.h>

#include "exdef.h"
#include "ex.h"
#include "exmacros.h"
#include "grownerdef.h"
#include "emsdef.h"
#include "bsgeom_cvsf.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"

#include "PWminimum.h"
#include "PWerror.h"
#include "PWgmdata.h"
#include "PWapi/dbgobjs.h"
#include "PWapi/cvcons.h"
#include "PWapi/sfcons.h"
/*
#include "PWapi/sfinit.h"
*/
#include "PWapi/objquery.h"
#include "PWapi/objcons.h"

%safe
static PWobjid _DbgGrpObject = PW_K_NullObjid;
static struct GRmd_env _DbgGrpMdenv;
%endsafe

%safe
static PWresult AddObjDbgObject
(
  PWobjid grobj
);
%endsafe

/*
  DESCRIPTION

  This function must be called before any objects can be added into 
  debug-object group. It creates the shell graphic group object. If one
  already exists, it is destroyed and recreated.
*/

void pwInitDbgObject
(
  PWosnum osnum
)
{
  short ActionFlag=0, Props=NULL;
  long msg=MSSUCC;
  PWresult result=PW_K_Success;

  /*
   * If any pre-existing objects exist, they need to be deleted
   */

  pwDeleteDbgObject();

  /*
   * Initialize the module-environment
   */

  gr$get_module_env (msg = &msg, buffer = &_DbgGrpMdenv);
  OnErrorState (IsError (msg), result, PW_K_Error, wrapup);

  /*
   * Create the OM object
   */

  _DbgGrpObject = omCreateObjFromClassid (osnum, OPP_GRgrgrp_class_id);
  if (_DbgGrpObject == PW_K_NullObjid)
  {
    result = PW_K_Error;
    goto wrapup;
  }
 
  /*
   * Make the graphics group displayable and locatable. Also, set the
   * property indicating it is new (Following the sequence in 
   * $GRNUC/src/go/grgrpgo/GRggconstr.I)
   */

  ActionFlag = 1;
  Props = GRIS_LOCATABLE | GRIS_DISPLAYABLE | GRIS_NEW;
  result = om$send (msg = message GRgraphics.GRchgprops (&msg, &ActionFlag, 
            &Props), targetid = _DbgGrpObject, targetos = osnum,
            senderid = PW_K_NullObjid);
  OnErrorCode (result & msg, wrapup);

  /*
   * Set the orphan properties bit in the owners properties (following 
   * the sequence in $GRNUC/src/go/grgrpgo/GRggconstr.I).
   */

  Props = GR_ORPHAN;
  result = om$send (msg = message GRowner.GRchg_owner_properties (&msg, 2, 
            &Props), targetid = _DbgGrpObject, targetos = osnum,
            senderid = PW_K_NullObjid);
  OnErrorCode (result & msg, wrapup);
  
wrapup:
  PW_Wrapup (result, "pwInitDbgObject");
  return;
}




/*
  DESCRIPTION
 
  This function destroys the contents of the debug-group object and the
  graphic group object itself. 
*/

void pwDeleteDbgObject
(
)
{
  long msg=MSSUCC;

  if (_DbgGrpObject != PW_K_NullObjid)
  {
    om$send (msg = message GRgraphics.GRdelete (&msg, &_DbgGrpMdenv),
     targetid = _DbgGrpObject, targetos = _DbgGrpMdenv.md_id.osnum,
     senderid = PW_K_NullObjid);

    _DbgGrpObject = PW_K_NullObjid;
  }

  return;
}



/*
  DESCRIPTION

  The following three functions are to be used to add objects, curves or
  surfaces, respectively, into the debug set. The functions will create
  persistent copies of the input geometry and add them to the debug-object
  group.
*/

void pwAddObjDbgObject
(
  PWobjid grobj,
  PWosnum os,
  short mattyp,
  PWmatrix mat
)
{
  long msg=MSSUCC;
  PWresult result=PW_K_Success;
  PWobjid copy_grobj;
  struct GRmd_env obj_md_env;

  OnErrorState (_DbgGrpObject == PW_K_NullObjid, result, PW_K_Error,
   wrapup);

  result = ex$get_modid (mod_osnum = os, mod_id = &obj_md_env.md_id.objid);
  OnErrorCode (result, wrapup);
  obj_md_env.md_id.osnum = os;
  obj_md_env.md_env.matrix_type = mattyp;
  memcpy (obj_md_env.md_env.matrix, mat, sizeof (PWmatrix));

  result = om$send (msg = message GRgraphics.GRcopy (&msg, &obj_md_env,
            &_DbgGrpMdenv, &copy_grobj), 
            targetid = grobj, targetos = os, senderid = PW_K_NullObjid);
  OnErrorCode (result & msg, wrapup);

  result = AddObjDbgObject (copy_grobj);
  OnErrorCode (result, wrapup);

wrapup:
  PW_Wrapup (result, "pwAddObjDbgObject");
  return;
}


void pwAddCvDbgObject
(
  struct PWcvdata *cvdata
)
{
  PWresult result=PW_K_Success;

  result = AddObjDbgObject (pwCreateCvObj (cvdata, _DbgGrpMdenv.md_id.osnum));
  OnErrorCode (result, wrapup);

wrapup:
  PW_Wrapup (result, "pwAddCvDbgObject");
  return;
}


void pwAddSfDbgObject
(
  struct PWsfdata *sfdata
)
{
  long msg=MSSUCC;
  PWresult result=PW_K_Success;
  PWobjid sfobj=PW_K_NullObjid;
  struct IGRdisplay display;
  struct GRvg_construct construct_list;
  struct IGRbsp_surface *p_sf;

  OnErrorState (sfdata->datatype != PWsfdata_bspsf && 
   sfdata->datatype != PWsfdata_gmbspsf, result, PW_K_Error, wrapup);

  if (sfdata->datatype == PWsfdata_bspsf)
    p_sf = sfdata->data.p_bspsf;
  else
    p_sf = sfdata->data.p_gmbspsf->bspsf;

  EMinitvgcnstr (&msg, &_DbgGrpMdenv, &display, NULL, &construct_list);
  result = EMgetvgcnstr (NULL, NULL, NULL, DEFAULT_GR_LEVEL, NULL, NULL, NULL,
            &construct_list);
  OnErrorCode (result, wrapup);

  sfobj = pwCreateSfObj (p_sf, BSGEN_BSP_SF, _DbgGrpMdenv.md_id.osnum);
  OnErrorState (sfobj == PW_K_NullObjid, result, PW_K_Error, wrapup);

  result = AddObjDbgObject (sfobj);
  OnErrorCode (result, wrapup);

wrapup:
  PW_Wrapup (result, "pwAddSfDbgObject");
  return;
}


/*---------------------- STATIC  FUNCTIONS ----------------------------------*/

static PWresult AddObjDbgObject
(
  PWobjid grobj
)
{
  int one=1;
  long msg=MSSUCC;
  PWresult result=PW_K_Success;
  struct GRobj_env objenv;

  OnErrorState (!omIsObjidValid (grobj, _DbgGrpMdenv.md_id.osnum), result,
   PW_K_Error, wrapup);

  objenv.obj_id.objid = grobj;
  objenv.obj_id.osnum = _DbgGrpMdenv.md_id.osnum;
  memcpy (&objenv.mod_env, &_DbgGrpMdenv, sizeof (struct GRmd_env));

  result = om$send (msg = message GRowner.GRadd_components (&msg, 
            &_DbgGrpMdenv, &one, &objenv, NULL, NULL),
            targetid = _DbgGrpObject, targetos = _DbgGrpMdenv.md_id.osnum,
            senderid = PW_K_NullObjid);
  OnErrorCode (result & msg, wrapup);

wrapup:
  return (result);
}

end implementation GRgrgrp;
