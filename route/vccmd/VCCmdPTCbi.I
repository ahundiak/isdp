
/* $Id: VCCmdPTCbi.I,v 1.1.1.1 2001/01/04 21:12:28 cvs Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:        vccmd/VCCmdPTCbi.I
 *
 * Description:
 *      Implementation of insert crossfile connector terminal
 *
 * Dependencies:
 *
 * Revision History:
 *        $Log: VCCmdPTCbi.I,v $
 *        Revision 1.1.1.1  2001/01/04 21:12:28  cvs
 *        Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.2  1998/04/20  04:05:48  pinnacle
# Replaced: vccmd/VCCmdPTCbi.I for:  by kddinov for route
#
# Revision 1.1  1997/10/30  04:15:40  pinnacle
# Integration of Cable into 02.04.03.04
#
# Revision 1.2  1997/07/14  22:52:40  pinnacle
# Replaced: vccmd/VCCmdPTCbi.I for:  by hverstee for cabling
#
# Revision 1.1  1997/03/12  21:55:04  pinnacle
# Created: vccmd/VCCmdPTCbi.I by hverstee for cabling
#
 *
 * History:
 *        05/29/96        hv        Initial
 *
 *************************************************************************/

class implementation VCCmdPT;

#include "VCCmdForm.h"
#include "vc_default.h"

/*
#define   MY_DEBUG
*/

from   GRgraphics      import   GRdelete, GRdisplay;
from   ACncpx          import   NDplace;

extern GRclassid   OPP_VCECbConn_class_id;
extern GRclassid   OPP_VCFCbConn_class_id;


extern IGRint   VCGetDefaultInfo( IGRint, IGRint, char *);



/****************************************************************************
   Create a terminal macro.  Place it under parent eqpt or coord sys
****************************************************************************/

method VCCmdCbInsert ( int * sts )
{
  int		          status;
  IGRlong                 msg, lConstructionListMsg;
  struct GRvg_construct   ConstructionList;
  struct GRas             assoc_list;
  enum GRdpmode           Mode;
  GRclassid               ConClassid;

  me->GenInfo.nNbAttr     = 0;
  assoc_list.parents      = &me->RefId;

  assoc_list.num_parents  = me->GenInfo.nNbAttr + 1;

/* 4-98 KDD use single point default selection function
*  if (me->Product == VC_PROD_ELEC)
*    ConClassid = OPP_VCECbConn_class_id;
*  else
*    ConClassid = OPP_VCFCbConn_class_id;
*/
 
  status = VCGetDefaultInfo( me->Product, 
				VC_GET_CAB_CON_CLASS_ID, (char *)&ConClassid);


#ifdef MY_DEBUG 
  printf("entering cbinsert, type %x\n", me->nVCConn_type);
#endif

  /*A ----- Fill in ConstructionList structure ----- */
  ConstructionList.msg        = &lConstructionListMsg;
  ConstructionList.env_info   = (struct GRmd_env *) &me->ModuleInfo;
  ConstructionList.newflag    = FALSE;
  ConstructionList.level      = me->ActiveLevel;
  ConstructionList.properties = GRIS_LOCATABLE | GRIS_DISPLAYABLE | GRIS_NEW;
  ConstructionList.geometry   = 0;
  ConstructionList.display    = &me->ActiveDisplay;
  ConstructionList.class_attr = NULL;
  ConstructionList.name       = 0;

  /*C Verify against database ... ?? */

  me->GenInfo.nStat        = VC_STATUS_INIT;
  me->GenInfo.nType        = me->nVCConn_type;
  me->GenInfo.cRep         = me->nACTrep;
  me->GenInfo.nProduct     = me->Product;
  me->GenInfo.nNbTopo      = 1; 
  me->GenInfo.bNoMtoFlg    = me->bMTO;

  strcpy (me->GenInfo.szCode,  VC_REF_CONNECTOR);
  strcpy (me->GenInfo.szTagno, me->TagNum);

  me->GenInfo.Attr.Term.nCpt           = me->nCpt;
  me->GenInfo.Attr.Term.nOff           = me->nVal;
  me->GenInfo.Attr.Term.dOffVal        = me->dValues;

  assoc_list.context          = NULL;
  assoc_list.as_attr          = (IGRchar *) &me->GenInfo;
  assoc_list.go_attr          = NULL;
  assoc_list.go_objid.objid   = NULL_OBJID;
  assoc_list.my_context.objid = NULL_OBJID;

  /*A ----- Create & Place Connector macro object ----- */
  
#ifdef MY_DEBUG
  printf("calling NDplace\n");
  printf("nVCCproduct value %d \n",me->Product);
  for(i=0;i<assoc_list.num_parents;i++) 
  {
    printf("Assoc root[%d]: <%d,%d> parent local vars <%d,%d> \n",
                          i, assoc_list.parents[i].objid,
                             assoc_list.parents[i].osnum,
                             parId[i].objid, parId[i].osnum);
  }
#endif

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
    status = 
    om$send (msg   = message GRgraphics.GRdelete (&msg, &me->ModuleInfo),
          targetid = me->ConstrId.objid,
          targetos = me->ConstrId.osnum) ;
    as$status();
  }
  else 
  {
    GRabsg_del_all();      /*    ??????   */

    Mode = GRbd;
    status = 
    om$send (msg = message GRgraphics.GRdisplay (&msg, 
                                 &me->ModuleInfo.md_env.matrix_type,
                                  me->ModuleInfo.md_env.matrix, 
                                 &Mode, 
                                 &me->ModuleInfo.md_id),
        targetid = me->ConstrId.objid,
        targetos = me->ConstrId.osnum);
     as$status(action = RET_STATUS);
  }

  /*   Dehighlight refid    */

  dp$erase_hilite (msg = &msg,
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

end implementation VCCmdPT;
