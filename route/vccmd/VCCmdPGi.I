
/* $Id: VCCmdPGi.I,v 1.1.1.1 2001/01/04 21:12:27 cvs Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:  vccmd/VCCmdPGi.I
 *
 * Description:
 *      Implementation file for place guide command object
 *
 * Dependencies:
 *
 * Revision History:
 *  $Log: VCCmdPGi.I,v $
 *  Revision 1.1.1.1  2001/01/04 21:12:27  cvs
 *  Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/10/30  04:15:40  pinnacle
# Integration of Cable into 02.04.03.04
#
# Revision 1.6  1997/07/14  22:52:08  pinnacle
# Replaced: vccmd/VCCmdPGi.I for:  by hverstee for cabling
#
# Revision 1.5  1997/01/03  18:15:26  pinnacle
# Replaced: vccmd/VCCmdPGi.I for:  by hverstee for cabling
#
# Revision 1.4  1996/11/25  17:44:40  pinnacle
# Replaced: vccmd/VCCmdPGi.I for:  by hverstee for cabling
#
# Revision 1.3  1996/10/09  22:01:46  pinnacle
# Replaced: vccmd/VCCmdPGi.I for:  by hverstee for cabling
#
# Revision 1.2  1996/09/26  21:19:14  pinnacle
# Replaced: vccmd/VCCmdPGi.I for:  by hverstee for cabling
#
# Revision 1.1  1996/08/28  22:15:12  pinnacle
# Created: vccmd/VCCmdPGi.I by hverstee for cabling
#
 *
 * History:
 *  06/18/96      hv      New
 *
 *************************************************************************/

class implementation VCCmdPG;

#include "VCCmdForm.h"
#include "VCmacros.h"
#include "VCproto.h"
#include "VCTagDef.h"

#include "VDmem.h"

/*
#define MY_DEBUG
*/

from   GRgraphics  import    GRaltconstruct;

extern GRclassid        OPP_GRbcsubbc_class_id;
extern GRclassid        OPP_GR3dlinestr_class_id;

%safe
#include "VX_FIproto.h"
%endsafe



/*=======================================================================*/

method VCCmdStart ( int * sts )
{
  IGRshort   nCount;
  IGRlong    retmsg;
  IGRint     status;

  status = OM_S_SUCCESS;

  *sts = VC_RTC_ALLOK;

  me->Product    = VC_PROD_NONE;
  me->CommGadget = VC_GDG_CMD_GUIDE;
  me->nTagCat    = VCTAG_CAT_GUIDE;

  me->FCmain     = VC_FPOS_PG_MAIN;
  me->FCsub      = VC_FPOS_PG_SUB;
  me->FCcontrol  = -1;

  me->pSysAtt    = me->forms[VC_FRM_MAIN].form_ptr;
  me->pUsrAtt    = me->forms[VC_FRM_SUB].form_ptr;
  me->pCtlAtt    = NULL;

  me->nVert      = 0;
  me->nCurSiz    = 0;

  vc$guide_idx (p_count = &nCount,
                osnum   = me->My_OS);

  if (nCount > 0)
  {
     me->CClist = _MALLOC (nCount * VC_MAX_CCODE, IGRchar);
     me->CCdesc = _MALLOC (nCount * VC_MAX_SDESC, IGRchar);
     if (me->CClist == NULL) return (OM_E_NODYNMEM);

     vc$guide_idx (p_count = &me->nCC,
                   osnum   = me->My_OS,
                   p_desc  = me->CCdesc,
                   p_codes = me->CClist);
  }

  return (OM_S_SUCCESS);
}

/**********************************************************/

method VCCmdInit ( int * sts )
{

  *sts = VC_RTC_ALLOK;

  me->GdType       = VC_GEN_GUIDE;
  me->bFromDB      = TRUE;
  me->bFixXS       = TRUE;

  me->dSize1       = 0.0;
  me->dSize2       = 0.0;

  me->sShape       = 0;
  me->nVert        = 0;

  me->ConstrId.objid = NULL_OBJID;
  me->ConstrId.osnum = me->ModuleInfo.md_id.osnum;
  me->RefId.objid    = NULL_OBJID;
  me->RefId.osnum    = me->ModuleInfo.md_id.osnum;

  return (OM_S_SUCCESS);
}

/**********************************************************/

method VCCmdGetRef ( int * sts )
{
  int          status = OM_S_SUCCESS;
  GRclassid    MyClassId;

  me->My_localret = VC_RTC_ALLOK;

 *sts = VC_RTC_ALLOK;

  /*A get the located object */
  me->RefId = me->event1.located_object[0].located_obj;
 
#ifdef MY_DEBUG
  printf (" Refid guide <%d %d>\n",me->RefId.objid, me->RefId.osnum);
#endif

  /*A get located element class id   */
  status = 
  om$get_classid (
      objid      = me->RefId.objid,
      osnum      = me->RefId.osnum,
      p_classid  = &MyClassId   );

  status =
  as$make_source( go_grid  = me->RefId,
                  mod_env  = &me->event1.located_object[0].module_info,
                  as_os    = me->ModuleInfo.md_id.osnum,
                  as_grid  = &me->RefId);
  as$status();

#ifdef MY_DEBUG
  printf (" Assid guide <%d %d>\n",me->RefId.objid, me->RefId.osnum);
#endif

  if (MyClassId == OPP_GRbcsubbc_class_id)
    me->GdType |= VCGD_SPLINE;
  else
  if (MyClassId == OPP_GR3dlinestr_class_id)
    me->GdType |= VCGD_STRING;
  else
   *sts = VC_RTC_ERROR;

#ifdef MY_DEBUG
  {
    IGRchar     c200ClassName[200];

    printf (" Refid = <%d %d>\n", me->RefId.objid,me->RefId.osnum);

    om$get_classname(classid = MyClassId, classname = c200ClassName);
    printf("Parent class id %d, name %s \n",MyClassId, c200ClassName);

    printf (" GdType %d\n", me->GdType);
  }
#endif

  return OM_S_SUCCESS;
}

method  VCCmdPGvt (long *sts)
{
  int          status;
  IGRshort     idsp, i;
  IGRdouble    d3pt[3];

 *sts = VC_RTC_ALLOK;

  if ((me->event1.response == EX_DATA ) || 
      (me->event1.response == EX_OBJID))
  {
    d3pt[0] = me->event1.event.button.x;
    d3pt[1] = me->event1.event.button.y;
    d3pt[2] = me->event1.event.button.z;

    idsp = me->nVert * 3;

    if (me->nCurSiz <= idsp)
    {
      me->nCurSiz += 30;

      status =
      om$vla_set_dimension (varray = me->dVert,
                            size   = me->nCurSiz);
    }

    for (i=0; i<3; i++)
      me->dVert[idsp+i] = d3pt[i];

    (me->nVert)++;
  }
  else
  {  /*   error return   */
    me->nVert = 0;
    *sts = VC_RTC_ERROR;
    _put_response( resp = VC_RTC_ERROR);
  }

  quit:
  return (OM_S_SUCCESS);
}

method  VCCmdPGpl (long *sts)
{
  int                     status;
  IGRlong                 retmsg;
  GRclassid               loc_classid = OPP_GR3dlinestr_class_id;

  struct GRvg_construct   ConstructionList;
  struct GRid             TmpId;
  struct IGRpolyline      line1;

  if (me->nVert <= 1)
  {
    *sts = VC_RTC_ERROR;
    goto quit;
  }

  TmpId.objid = NULL_OBJID;
  TmpId.osnum = me->ModuleInfo.md_id.osnum;

  /*A ----- Fill in ConstructionList structure ----- */
  ConstructionList.msg         = &retmsg;
  ConstructionList.env_info    = (struct GRmd_env *) &me->ModuleInfo;
  ConstructionList.newflag     = FALSE;
  ConstructionList.level       = me->ActiveLevel;
  ConstructionList.properties  = GRIS_LOCATABLE | GRIS_DISPLAYABLE | GRIS_NEW;
  ConstructionList.geometry    = (IGRchar *) &line1;
  ConstructionList.display     = &me->ActiveDisplay;
  ConstructionList.class_attr  = NULL;
  ConstructionList.name        = 0;

  line1.num_points    = me->nVert;
  line1.points        = me->dVert;

#ifdef MY_DEBUG
  printf (" Construct guide lineseg\n");
#endif

  status =
  om$construct( classid = loc_classid,
                p_objid = &TmpId.objid,
                osnum   = TmpId.osnum,
                  msg   = message GRgraphics.GRaltconstruct
                                ( &ConstructionList));
  as$status ();

  /*A get the located object */
  me->RefId = TmpId;

  status =
  as$make_source( go_grid  = me->RefId,
                  mod_env  = &me->event1.located_object[0].module_info,
                  as_os    = me->ModuleInfo.md_id.osnum,
                  as_grid  = &me->RefId);
  as$status();

  me->GdType |= VCGD_STRING;

#ifdef MY_DEBUG
  printf (" Continue, force pick %d %d\n",me->RefId.objid,me->RefId.osnum);
#endif

  quit:
  return (OM_S_SUCCESS);
}

end implementation VCCmdPG;

