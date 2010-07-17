
/* $Id: VCCmdPGins.I,v 1.1.1.1 2001/01/04 21:12:27 cvs Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:  vccmd/VCCmdPGins.I
 *
 * Description:
 *      Implementation file for place guide command object
 *
 * Dependencies:
 *
 * Revision History:
 *  $Log: VCCmdPGins.I,v $
 *  Revision 1.1.1.1  2001/01/04 21:12:27  cvs
 *  Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/10/30  04:15:40  pinnacle
# Integration of Cable into 02.04.03.04
#
# Revision 1.8  1997/07/14  22:52:12  pinnacle
# Replaced: vccmd/VCCmdPGins.I for:  by hverstee for cabling
#
# Revision 1.7  1997/03/12  21:57:28  pinnacle
# Replaced: vccmd/VCCmdPGins.I for:  by hverstee for cabling
#
# Revision 1.6  1997/01/03  18:15:38  pinnacle
# Replaced: vccmd/VCCmdPGins.I for:  by hverstee for cabling
#
# Revision 1.5  1996/12/18  17:47:38  pinnacle
# Replaced: vccmd/VCCmdPGins.I for:  by hverstee for cabling
#
# Revision 1.4  1996/10/09  22:02:34  pinnacle
# Replaced: vccmd/VCCmdPGins.I for:  by hverstee for cabling
#
# Revision 1.3  1996/10/08  21:59:10  pinnacle
# Replaced: vccmd/VCCmdPGins.I for:  by hverstee for cabling
#
# Revision 1.2  1996/09/26  21:19:40  pinnacle
# Replaced: vccmd/VCCmdPGins.I for:  by hverstee for cabling
#
# Revision 1.1  1996/08/28  22:15:30  pinnacle
# Created: vccmd/VCCmdPGins.I by hverstee for cabling
#
 *
 * History:
 *  06/18/96      hv      New
 *
 *************************************************************************/

class implementation VCCmdPG;

#include "VCCmdForm.h"

/*
#define MY_DEBUG
*/

from  ACncpx     import   NDplace;

from  GRgraphics import   GRdisplay;
from  GRgraphics import   GRdelete;

extern GRclassid        OPP_VCGuide_class_id; 


/*=======================================================================*/

method VCCmdInsert ( int * sts )
{
  IGRint                  status;
  IGRint                  i;
  IGRlong                 retmsg, lConstructionListMsg;
  struct GRvg_construct   ConstructionList;
  struct GRas             assoc_list;
  struct GRid             parId[4];
  enum GRdpmode           Mode;
  GRclassid               ConClassid = OPP_VCGuide_class_id;

  ConstructionList.msg        = &lConstructionListMsg;
  ConstructionList.env_info   = (struct GRmd_env *) &me->ModuleInfo;
  ConstructionList.newflag    = FALSE;
  ConstructionList.level      = me->ActiveLevel;
  ConstructionList.properties = GRIS_LOCATABLE | GRIS_DISPLAYABLE | GRIS_NEW;
  ConstructionList.geometry   = NULL;
  ConstructionList.display    = &me->ActiveDisplay;
  ConstructionList.class_attr = NULL;
  ConstructionList.name       = 0;

  /*  set all type flags   */

  if (me->bFixXS)
    me->GdType |= VCGD_FIXED_XS;
  else
    me->GdType |= VCGD_FREED_XS;

  if (me->sShape == 0)
    me->GdType |= VCGD_SHAPE_ROUND;
  else
    me->GdType |= VCGD_SHAPE_SQUARE;

  /*  define the parents   */

  for(i=0;i<4;i++)
  {
    parId[i].objid      = NULL_OBJID;
    parId[i].osnum      = me->ModuleInfo.md_id.osnum;
  }

  /*  attribute parents   */
  status =
  om$send (msg = message VCAT.VCAT_coll (&retmsg, &parId[0], &parId[1]),
      targetid = my_id);

  me->GenInfo.nNbAttr       = 2;

  parId[me->GenInfo.nNbAttr] = me->RefId;
  assoc_list.parents      = parId;
  assoc_list.num_parents  = me->GenInfo.nNbAttr + 1;

  me->GenInfo.nStat         = VC_STATUS_INIT;
  me->GenInfo.nType         = me->GdType;
  me->GenInfo.cRep          = me->nACTrep;
  me->GenInfo.nNbTopo       = 1;
  me->GenInfo.nProduct      = me->Product;
  me->GenInfo.bNoMtoFlg     = me->bMTO;

  strcpy (me->GenInfo.szCode, me->CompCode);
  strcpy (me->GenInfo.szTagno, me->TagNum);

#ifdef MY_DEBUG
  printf (" send gdtypes %d %d %d\n",me->GdType,me->sShape,me->bFixXS);
  printf (" result GdType %d %x\n",me->GenInfo.nType,
                                   me->GenInfo.nType);
#endif

  me->dSize1 = me->dSize2 = me->dDiameter;

  me->GenInfo.Attr.Guide.dSize1 = me->dSize1;
  me->GenInfo.Attr.Guide.dSize2 = me->dSize2;

  assoc_list.context          = NULL;
  assoc_list.as_attr          = (IGRchar *) &me->GenInfo;
  assoc_list.go_attr          = NULL;
  assoc_list.go_objid.objid   = NULL_OBJID;
  assoc_list.my_context.objid = NULL_OBJID;

  status =
  om$construct (classid = ConClassid,
                p_objid = &me->ConstrId.objid,
                osnum   = me->ConstrId.osnum,
                 msg    = message ACncpx.NDplace
                                   (&assoc_list, &me->ModuleInfo,
                                      (IGRchar *) &ConstructionList));
  as$status ();

  if (!(status & OM_S_SUCCESS))
  {
#ifdef MY_DEBUG
    printf (" error in construct guide, delete\n");
#endif
    status =
    om$send (msg   = message GRgraphics.GRdelete (&retmsg, &me->ModuleInfo),
          targetid = me->ConstrId.objid,
          targetos = me->ConstrId.osnum) ;
    as$status();
  }
  else
  {
#ifdef MY_DEBUG
    printf (" succesful construct guide\n");
#endif
    /*K Delete GRNUC buffer in order to display the right geometry */
    GRabsg_del_all();

    /*C Display my */
    Mode = GRbd;
    status =
    om$send( msg = message GRgraphics.GRdisplay( &retmsg,
                                        &me->ModuleInfo.md_env.matrix_type,
                                         me->ModuleInfo.md_env.matrix,
                                        &Mode, &me->ModuleInfo.md_id ),
        targetid = me->ConstrId.objid,
        targetos = me->ConstrId.osnum );
    as$status(action = RET_STATUS);

    me->TagNum[0] = '\0';

    me->nSysref++;
    me->nUsrref++;
#ifdef MY_DEBUG
    printf ("coll used %d %d \n",me->nSysref, me->nUsrref);
#endif
  }

  /*   Dehighlight reference    */

  dp$erase_hilite (msg = &retmsg,
                 osnum = me->RefId.osnum);

  /*   all done, reset ID's    */
  me->ConstrId.objid = NULL_OBJID;
  me->RefId.objid    = NULL_OBJID;

  if (me->bTERM)
    *sts = VC_RTC_DONE;
  else
    *sts = VC_RTC_ALLOK;

  return OM_S_SUCCESS;
}

end implementation VCCmdPG;

