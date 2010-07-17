
/* $Id: VCRinfo.I,v 1.4 2002/05/08 15:48:25 anand Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:        vcroot / VCRinfo.I
 *
 * Description:
 *   This file contains the methods returning info on a generic
 *
 * Dependencies:
 *
 * Revision History:
 *        $Log: VCRinfo.I,v $
 *        Revision 1.4  2002/05/08 15:48:25  anand
 *        Files added/modified for sub-cable functionality.
 *
 *        Revision 1.3  2001/02/20 23:45:11  louis
 *        TR4617 crash on modify attributes cable and terminals
 *
 *        Revision 1.2  2001/02/20 01:11:11  build
 *        Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *        Revision 1.1.1.1  2001/01/04 21:12:37  cvs
 *        Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.3  1998/04/12  21:30:38  pinnacle
# Replaced: vcroot/VCRinfo.I for:  by kddinov for route
#
# Revision 1.2  1997/12/12  20:49:20  pinnacle
# Replaced: vcroot/VCRinfo.I for:  by kddinov for route
#
# Revision 1.14  1997/12/04  17:37:18  pinnacle
# Replaced: vcroot/VCRinfo.I for:  by apazhani for cabling
#
# Revision 1.13  1997/07/31  19:49:04  pinnacle
# Replaced: vcroot/VCRinfo.I for:  by hverstee for cabling
#
# Revision 1.12  1997/07/22  14:31:48  pinnacle
# Replaced: vcroot/VCRinfo.I for:  by hverstee for cabling
#
# Revision 1.11  1997/07/14  21:57:34  pinnacle
# Replaced: vcroot/VCRinfo.I for:  by hverstee for cabling
#
# Revision 1.10  1997/05/22  14:59:42  pinnacle
# Replaced: vcroot/VCRinfo.I for:  by hverstee for cabling
#
# Revision 1.9  1997/05/19  13:06:10  pinnacle
# Replaced: vcroot/VCRinfo.I for:  by hverstee for cabling
#
# Revision 1.8  1997/05/10  14:04:02  pinnacle
# Replaced: vcroot/VCRinfo.I for:  by hverstee for cabling
#
# Revision 1.7  1997/05/02  17:05:54  pinnacle
# Replaced: vcroot/VCRinfo.I for:  by hverstee for cabling
#
# Revision 1.6  1997/04/28  21:47:34  pinnacle
# Replaced: vcroot/VCRinfo.I for:  by hverstee for cabling
#
# Revision 1.5  1997/01/23  23:30:08  pinnacle
# Replaced: vcroot/VCRinfo.I for:  by hverstee for cabling
#
# Revision 1.4  1997/01/20  20:19:26  pinnacle
# Replaced: vcroot/VCRinfo.I for:  by hverstee for cabling
#
# Revision 1.3  1996/11/12  15:27:44  pinnacle
# Replaced: vcroot/VCRinfo.I for:  by hverstee for cabling
#
# Revision 1.2  1996/09/25  21:57:02  pinnacle
# Replaced: vcroot/VCRinfo.I for:  by hverstee for cabling
#
# Revision 1.1  1996/08/28  21:12:42  pinnacle
# Created: vcroot/VCRinfo.I by hverstee for cabling
#
 *
 * History:
 *        05/29/96        hv         Initial
 *	  4/98		KDD	     use limits when setting szTagNo and szCode
 *				     this will save us couple of crashes. 
 *	  02/20/01	law	     TR4617-crashing modify attributes
 *
 *************************************************************************/

class implementation VCRoot;

#include  "vc_mtoflags.h"

#include "bsvalues.h"
#include "bsnorvec.h"
#include "vrdbgmacros.h"

/*
#define  MY_DEBUG
*/

extern GRclassid OPP_ACpretend_class_id;
extern GRclassid OPP_ACpretendin_class_id;
extern GRclassid OPP_ASsource_class_id;

from    ACpretend       import ACfind_parent;

/***********************************************************************/

method VCGetMtoFlag (IGRboolean   *bMTO;
                     IGRchar      *szMTO)
{
  if (bMTO)
    *bMTO = me->bVCMtoFlg;

  if (szMTO)
  {
    if (me->bVCMtoFlg) strcpy (szMTO, VC_MTOFLAG_INCLUDE);
    else               strcpy (szMTO, VC_MTOFLAG_EXCLUDE);
  }

  return ( OM_S_SUCCESS );
}

/***********************************************************************/

method VCSetMtoFlag (IGRboolean    bMTO)
{
  me->bVCMtoFlg = bMTO;

  return ( OM_S_SUCCESS );
}

/***********************************************************************/

method VCSetCode (IGRchar *szCode)

{
  IGRint      status;

  status = om$vla_set_dimension (varray = me->szVCCode,
                                 size   = VC_MAX_CCODE);
  if (szCode != NULL)
    strncpy (me->szVCCode, szCode, VC_MAX_CCODE);
  else
    VC_INITSTR (me->szVCCode);

  return ( OM_S_SUCCESS );

}/* end VCSetCode */

/***********************************************************************/

method VCGetCode (IGRchar *szCode)

{

  if (szCode != NULL)
  {
    IGRint     isize;

    isize = om$dimension_of (varray = me->szVCCode);
    if (isize > 0)
      strcpy (szCode, me->szVCCode);
    else
      VC_INITSTR (szCode);
  }

  return ( OM_S_SUCCESS );

}/* end VCGetCode */

/***********************************************************************/

method VCSetTagNo (IGRchar *szTagNo)

{
  IGRint      status;

  status = om$vla_set_dimension (varray = me->szVCTagNo,
                                 size   = VC_MAX_TAGNO);
  if (szTagNo != NULL)
    strncpy (me->szVCTagNo, szTagNo, VC_MAX_TAGNO);
  else
    VC_INITSTR (me->szVCTagNo);

  return ( OM_S_SUCCESS );

}/* end VCSetTagNo */

/***********************************************************************/

method VCGetTagNo (IGRchar *szTag)

{

  if (szTag != NULL)
  {
    IGRint     isize;

    isize = om$dimension_of (varray = me->szVCTagNo);
    if (isize > 0)
      strcpy (szTag, me->szVCTagNo);
    else
      VC_INITSTR (szTag);
  }

  return ( OM_S_SUCCESS );

}/* end VCGetTagNo */

/***********************************************************************/

method VCGetStatus ( IGRshort *StatusValue)

{

  *StatusValue = me->nVCStat;

  return ( OM_S_SUCCESS );

}/* end VCGetStatus */

/***********************************************************************/

method VCSetStatus (IGRshort StatusMask;
                    IGRshort StatusValue)

{

  me->nVCStat = (me->nVCStat & ~StatusMask) | (StatusValue & StatusMask);

  return ( OM_S_SUCCESS );

}/* end VCSetStatus */

/***********************************************************************/

method VCGetType( IGRint *TypeValue )
{

  *TypeValue = me->nVCType;

  return ( OM_S_SUCCESS );

}/* end VCGetType */

/***********************************************************************/

method VCSetType (IGRshort TypeMask;
                  IGRshort TypeValue)

{

  me->nVCType = (me->nVCType & ~TypeMask) | (TypeValue & TypeMask);

  return ( OM_S_SUCCESS );

}/* end VCSetType */

/***********************************************************************/

method VCGetInstance  (IGRlong       *msg;
                struct VCGenInfo     *Instance)

{
  IGRint     status;

  *msg = MSSUCC;

  Instance->nStat     = me->nVCStat;      /*   inline    */
  Instance->nType     = me->nVCType;      /*   inline    */
  Instance->bNoMtoFlg = me->bVCMtoFlg;    /*   inline    */
  Instance->cRep      = me->xform_chan;
  Instance->nNbTopo   = me->nVCTopo;
  Instance->nNbAttr   = me->nVCAttr;

  status =
  om$send ( msg = message VCRoot.VCGetCode ( Instance->szCode),
       targetid = my_id);

  status =
  om$send ( msg = message VCRoot.VCGetTagNo (Instance->szTagno),
       targetid = my_id);

  return ( OM_S_SUCCESS );
}/* end VCGetInstance */

/***********************************************************************/

method VCSetInstance  (IGRlong      *msg;
                struct VCGenInfo    *Instance)

{
  IGRint     status;

  *msg = MSSUCC;

  me->nVCStat    = Instance->nStat;        /*   inline    */
  me->nVCType    = Instance->nType;        /*   inline    */
  me->bVCMtoFlg  = Instance->bNoMtoFlg;    /*   inline    */
  me->nVCTopo    = Instance->nNbTopo;
  me->nVCAttr    = Instance->nNbAttr;
  me->xform_chan = Instance->cRep;

  status =
  om$send ( msg = message VCRoot.VCSetCode ( Instance->szCode),
       targetid = my_id);

  status =
  om$send ( msg = message VCRoot.VCSetTagNo ( Instance->szTagno),
       targetid = my_id);

  return ( OM_S_SUCCESS );
}/* end VCSetInstance */


/***********************************************************************/

method VCGetProduct (IGRint   *Prodno;
                     IGRchar  *ProdNam)
{
   if (Prodno) *Prodno = VC_PROD_NONE;

   if (ProdNam) VC_INITSTR(ProdNam);

   return (OM_S_SUCCESS);
}

/***********************************************************************/

method VCGetModel ( IGRlong    *msg;
             struct GRid       *ModelId)
{

  *msg = MSSUCC;
  ModelId->objid = NULL_OBJID;

  return (OM_S_SUCCESS);
}

/***********************************************************************/

method VCGetRep  (IGRshort  *nRep;
                  IGRchar   *szRep)

{
  IGRshort     nMyrep;

  nMyrep = (me->xform_chan & AC_VDS_REP);

  if (nRep) *nRep = nMyrep;

  if (szRep)
  {
    switch (nMyrep)
    {
      case AC_2D_REP:  strcpy (szRep,VC_2D_REP_NAME);        break;
      case AC_3D_REP:  strcpy (szRep,VC_3D_REP_NAME);        break;
      case AC_ENV_REP: strcpy (szRep,VC_ENV_REP_NAME);       break;
      case VC_PID_REP: strcpy (szRep,VC_PID_REP_NAME);       break;
      default:                                               break;
    }
  }

  return (OM_S_SUCCESS);
}

/***********************************************************************/

method VCDUMP      (IGRlong   *msg)
{
  IGRint      iS;
  IGRint      i;
  IGRchar    *pC;
  IGRchar    *pT;

  *msg = MSSUCC;

  iS = om$dimension_of (varray = me->szVCCode);
  if (iS > 0)   pC = me->szVCCode;
  else          pC = " ";

  iS = om$dimension_of (varray = me->szVCTagNo);
  if (iS > 0)   pT = me->szVCTagNo;
  else          pT = " ";

  printf ("\n\n CABLING OBJECT DUMP of object <%d %d>\n\n",
                   my_id,OM_Gw_current_OS);

  printf (" code %s tag %s type %x status %x NbAttr %d NbTopo %d\n",
               pC, pT,
               me->nVCType, me->nVCStat,
               me->nVCAttr, me->nVCTopo);

  printf ("\n BASEFLAG ");

  if (me->nVCType & VC_GEN_TERM)  printf (" TERM");
  if (me->nVCType & VC_GEN_CABLE)  printf (" CABLE");
  if (me->nVCType & VC_GEN_GUIDE)  printf (" GUIDE");
  if (me->nVCType & VC_GEN_BKSHLL)  printf (" BACKSHELL");

  printf ("\n");

  iS = om$dimension_of (varray = me->EXPAND);

  for (i=0; i<iS; i++)
  {
    switch (me->EXPAND[i].type)
    {
      case VCEX_CHAR:
        printf ("EXPAND %d - %s\n",i,me->EXPAND[i].AT.EXc);
        break;

      case VCEX_DBL:
        printf ("EXPAND %d - %f\n",i,me->EXPAND[i].AT.EXd);
        break;

      case VCEX_INT:
        printf ("EXPAND %d - %d\n",i,me->EXPAND[i].AT.EXi);
        break;

      default:
        break;
    }
  }

  return (OM_S_SUCCESS);
}


/***********************************************************************/

method VCParent      (IGRlong   *msg;
                      IGRshort   iParno;    /*   parent number             */
               struct GRid      *Par;       /*   parent id                 */
               struct GRmd_env  *pr_env)    /*   parents environment       */

{
  IGRlong            retmsg;
  IGRint             status;
  GRclassid          Myclassid;
  IGRint             ParentI;

  struct GRid        LocId;
  struct GRmd_env    LocEnv;

  /*A initialization */
  SetProc( VCParent of VCRinfo ); Begin

  *msg    = MSFAIL;

  Par->objid = NULL_OBJID;

  ParentI    = iParno + me->nVCAttr;
  __DBGpr_int( " Parent Index ", ParentI );

  status =
  om$get_objid_at_index( object = me,
                   p_chanselect = &ND_father,
                   index        = ParentI,
                   objidaddr    = &LocId.objid,
                   osnumaddr    = &LocId.osnum );
  __DBGpr_obj( " Local Parent ", LocId );

  if (!(status & OM_S_SUCCESS)) 
  {
    __DBGpr_com( " om$get_objid_at_index failed, it didn't have any parent " );
    return (OM_S_SUCCESS);
  }

  *msg    = MSSUCC;

  om$get_classid (objid = LocId.objid,
                  osnum = LocId.osnum,
              p_classid = &Myclassid);

  if ((om$is_ancestry_valid (subclassid = Myclassid,
                           superclassid = OPP_ACpretend_class_id )
                                      == OM_S_SUCCESS))
  { 
    /* We will get ACpretend as parent only for the Terminal object, that to
    only when they're embedded in the Equipment. To get the actual parent,
    which may be either Route PID Equipment or VDS Equipment. Alwin */
 
    __DBGpr_com( " Get the Parent of the ACpretend object " );
 
    status = om$send (msg = message ACpretend.ACfind_parent( Par,
                     &LocEnv.md_env.matrix_type, LocEnv.md_env.matrix),
                senderid = NULL_OBJID,
                targetos = LocId.osnum,
                targetid = LocId.objid );
    as$status();

/*
    status =
    om$send (msg = message NDmacro.ACreturn_foot (&retmsg, "", Par,
                                                  &LocEnv.md_env.matrix_type,
                                                   LocEnv.md_env.matrix),
        targetid = LocId.objid,
        targetos = LocId.osnum);
    as$status();
*/

    LocEnv.md_id.osnum = Par->osnum;

    status =
    ex$get_modid (mod_osnum =  LocEnv.md_id.osnum,
                  mod_id    = &LocEnv.md_id.objid);

    if (pr_env) *pr_env = LocEnv;

   __DBGpr_obj( " Actual Parent of Terminal ", *Par );
  }
  else
  {
    Par->objid = LocId.objid;
    Par->osnum = LocId.osnum;
 
    __DBGpr_obj( " Real Parent Id ", *Par );
  }

  End
  return OM_S_SUCCESS;
}


method  VCChildren    (IGRlong   *msg;
                       IGRshort  *nTotchild; /*  total # of children        */
                       IGRshort  *nRefchild; /*  # of ref. children         */
                struct GRid      *Children)
{
  IGRint             status;
  IGRint             NumCH;
  OMuint             NumRF;
  IGRuint            cct;
  IGRshort           i;
  IGRint             jRef;
  IGRshort           iThisOS;
  GRclassid          ClId;

  struct GRid       *buffer;

  OM_S_OBJECT_LINKAGE       GRnots[10];

  *msg = MSSUCC;
  NumCH = NumRF = 0;
  cct = 0;

  *nTotchild = 0;
  *nRefchild = 0;

  status =
  om$send( msg = message NDnode.NDget_objects
                               (ND_CHILDREN | ND_IN_BUF, NULL, 0, &buffer,
                                    0, OM_K_MAXINT, &NumCH),
      targetid = my_id);

  iThisOS = OM_Gw_current_OS;

  for (i=0; i<NumCH; i++)
  {
    iThisOS = buffer[i].osnum;

    om$get_classid (objid = buffer[i].objid,
                    osnum = buffer[i].osnum,
                p_classid = &ClId);

    if (ClId == OPP_ACpretend_class_id) continue;

    if (Children)
    {
      /* modified for TR4617 crashing on cables */
      Children[*nTotchild].objid = buffer[i].objid;
      Children[*nTotchild].osnum = buffer[i].osnum;
#ifdef MY_DEBUG
      printf (" Real child %d %d\n", buffer[i].objid, buffer[i].osnum);
#endif
    }
    (*nTotchild)++;
  }

  status =
  om$get_channel_count (object       = me,
                        p_chanselect = &AS_notification,
                        count        = &NumRF);

#ifdef MY_DEBUG
  printf (" Refcount %d\n", NumRF);
#endif

  if (NumRF > 0)
  { /*  check for falsely non-empty channel    */
    status =
    om$get_channel_objects( object   = me,
                        p_chanselect = &AS_notification,
                                list = GRnots,
                              size   = 10,
                              count  = &cct);
     as$status();

    if (cct > 10)
    {
      printf (" MAX OBJECTS REACHED %d\n",cct);
      cct = 10;
    }

#ifdef MY_DEBUG
    for (i=0; i<cct; i++)
      printf (" Channel objects %d %d\n", GRnots[i].S_objid, GRnots[i].osnum);
#endif
  }

  NumRF = cct;

#if 0
  if (NumRF > 0)
  { /*  check for falsely non-empty channel    */
    struct GRid     xLIST;

    xLIST.objid = NULL_OBJID;

    status =
    om$get_objid_at_index( object = me,
                     p_chanselect = &AS_notification,
                     index        = 0,
                     objidaddr    = &xLIST.objid,
                     osnumaddr    = &xLIST.osnum );

#ifdef MY_DEBUG
    printf (" listener %d %d \n",xLIST.objid,xLIST.osnum );
#endif

    if (!(status & OM_S_SUCCESS))
    {
/*
      NumRF = 0;
*/
#ifdef MY_DEBUG
      printf (" Reset false listenercount......\n");
#endif
    }
  }
#endif

  for (jRef = 0; jRef < cct; jRef++)
  {
    NumCH = 0;

    status =
    om$send( msg = message NDnode.NDget_objects
                               (ND_CHILDREN | ND_IN_BUF, NULL, 0, &buffer,
                                    0, OM_K_MAXINT, &NumCH),
       targetid = GRnots[jRef].S_objid,
       targetos = GRnots[jRef].osnum);
    as$status();

#ifdef MY_DEBUG
    printf (" Listener %d children %d\n", jRef, NumCH);
#endif

    for (i=0; i<NumCH; i++)
    {
#ifdef MY_DEBUG
      printf (" Refchild %d %d\n", buffer[i].objid, buffer[i].osnum);
#endif
      if (buffer[i].osnum == iThisOS)
      {
#ifdef MY_DEBUG
        printf (" Bypass false ref......\n");
#endif
        continue;
      }

      if (Children)
      {
        Children[*nTotchild].objid = buffer[i].objid;
        Children[*nTotchild].osnum = buffer[i].osnum;
      }

      (*nTotchild)++;
      (*nRefchild)++;
    }
  }

  return OM_S_SUCCESS;
}

end implementation VCRoot;

