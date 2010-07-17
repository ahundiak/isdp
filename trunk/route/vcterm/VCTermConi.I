
/* $Id: VCTermConi.I,v 1.1.1.1 2001/01/04 21:12:38 cvs Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:        vcterm/VCTermConi.I
 *
 * Description:
 *
 *      Methods to implement crossfile connector
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VCTermConi.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:12:38  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.3  1998/03/14  19:48:02  pinnacle
# Replaced: vcterm/VCTermConi.I for:  by kddinov for route
#
# Revision 1.2  1998/02/21  18:55:36  pinnacle
# Replaced: vcterm/VCTermConi.I for:  by kddinov for route
#
# Revision 1.1  1997/10/30  05:23:34  pinnacle
# Integ into Route 02040304
#
# Revision 1.4  1997/07/14  22:08:48  pinnacle
# Replaced: vcterm/VCTermConi.I for:  by hverstee for cabling
#
# Revision 1.3  1997/05/19  13:49:56  pinnacle
# Replaced: vcterm/VCTermConi.I for:  by hverstee for cabling
#
# Revision 1.2  1997/04/28  22:04:50  pinnacle
# Replaced: vcterm/VCTermConi.I for:  by hverstee for cabling
#
# Revision 1.1  1997/03/12  16:33:44  pinnacle
# Created: vcterm/VCTermConi.I by hverstee for cabling
#
 *
 * History:
 *      MM/DD/YY   AUTHOR       DESCRIPTION
 *
 *      05/29/96    hv          Initial
 *
 *************************************************************************/

class implementation VCTermCon;

#include "VCproto.h"

/*
#define MY_DEBUG
*/

extern GRclassid  OPP_GR3dlinestr_class_id;



method VCGetMatrix (    IGRlong     *msg;
                        IGRshort     NbCpt;
                        IGRdouble   *dRefMatrix;
                 struct GRmd_env    *md_env)
{
  IGRlong            retmsg;
  IGRint             status;
  IGRboolean         bFree;
  IGRdouble          dCor[3];
  IGRdouble          dXVc[3];
  IGRshort           nCpt;

  struct GRid        RefId;
  struct GRmd_env    LocEnv;

  if (me->nVCType & VC_GEN_VIRTUAL)
  {  /*A   For a virtual connector revert to the real counterpart   */
    struct GRmd_env    OtherEnv;

    OtherEnv = *md_env;

    status =
    om$send(msg = message VCRoot.VCParent
                         (&retmsg, (IGRshort) 0, &RefId, &OtherEnv),
       targetid = my_id);

    status = om$send(msg = message NDmacro.ACreturn_foot
                           (&retmsg, "", &RefId,  &OtherEnv.md_env.matrix_type,
                                             OtherEnv.md_env.matrix),
                        targetid = RefId.objid,
                        targetos = RefId.osnum ) ;
    as$status( action = RET_STATUS )

    status = om$send( msg = message VCRoot.VCGetMatrix
                  (msg, NbCpt, dRefMatrix, &OtherEnv),
              targetid = RefId.objid,
              targetos = RefId.osnum);

    return status;
  }

  *msg = MSSUCC;

  RefId.objid = NULL_OBJID;

  /*A  get parent from the channel             */

  LocEnv = *md_env;
  status =
  om$send(msg = message VCRoot.VCParent
                         (&retmsg, (IGRshort) 0, &RefId, &LocEnv),
     targetid = my_id);

  if ( RefId.objid == NULL_OBJID )
  {  /*A If no parent can be found revert to VCRoot method  */
    status =
    om$send ( msg = message VCRoot.VCGetMatrix
                    ( msg, NbCpt, dRefMatrix, md_env),
        mode     = OM_e_wrt_message,
        targetid = my_id);

        return ( status );
  }/* end get matrix without topology */

  /*  For a cable terminal get the matrix from the cable (reversed) */

  nCpt   = me->nVCcabCpt;

  /* get coordinates of connectpoint */
  status=
  om$send( msg     = message VCRoot.VCGetCptCoord
                (&retmsg, nCpt, dCor, md_env),
           targetid = RefId.objid,
           targetos = RefId.osnum);
  as$status ( action = RET_STATUS );

  /* get connect vector from cable   */

  status=
  om$send( msg     = message VCRoot.VCGetCptVec
                (&retmsg, nCpt, dXVc, &bFree, md_env),
           targetid = RefId.objid,
           targetos = RefId.osnum);

  /*   reverse the vector   */

  dXVc[0] = -dXVc[0];
  dXVc[1] = -dXVc[1];
  dXVc[2] = -dXVc[2];

  /*  and construct matrix    */

  status = VC_mat_from_vector (dCor, dXVc, dRefMatrix);

  return (status);     /*   no offsets allowed    */
}/* end VCGetMatrix */

method  VCGetNumberOfCpts (IGRlong     *msg ;
                           IGRshort    *NbCpts)
{
  IGRint     status;

  status =
  om$send (msg = message VCP.VCP_num (msg, NbCpts),
      targetid = my_id);

  *NbCpts += 1;

  return ( OM_S_SUCCESS );
}


method  VCGetTopology (IGRlong   *msg;
                      IGRshort   nCpt;    /*I    my CPT or ALL               */
                      IGRshort  *nConn;   /*O    number output               */
               struct GRid      *ConId;   /*O    list of GRids               */
                      IGRshort  *nConCp;  /*O    list of cpts on GRids       */
                      IGRshort  *nMyCp;   /*O    list of cpts on me          */
                      IGRshort  *nPass)   /*O    list of passthru counters   */
{
  IGRint       status;
  IGRlong      retmsg;
  IGRshort     nTmCp;
  IGRshort     nCbCp;
  IGRshort     nLocp;
  IGRshort     nTC;
  IGRshort     nRC;
  IGRint       i;

  struct GRid  RefId;
  struct GRid  meself;
  struct GRid *Passon;

  meself.objid = my_id;
  meself.osnum = OM_Gw_current_OS;

  *msg = MSSUCC;

  *nConn = 0;

     /*   cable connector, may have to return the parent   */
     /*   always a real father..........                   */
  if ((nCpt == 0) || (nCpt == VC_REQ_ALL_CPT))

  status =
  om$get_objid_at_index ( object          = me,
                          p_chanselect    = &ND_father,
                          index           = (IGRint) me->nVCAttr,
                          objidaddr       = &RefId.objid,
                          osnumaddr       = &RefId.osnum);

  status =
  om$send (msg = message VCRoot.VCGetCpts
                             (&retmsg, &meself, &nTmCp, &nCbCp, &nLocp),
      targetid = RefId.objid,
      targetos = RefId.osnum);
 
  if (ConId)
  {
    ConId[*nConn].objid = RefId.objid;
    ConId[*nConn].osnum = RefId.osnum;
  }

  if (nConCp)
    nConCp[*nConn] = nCbCp;

  if (nMyCp)
    nMyCp[*nConn] = nTmCp;

  if (nPass)
    nPass[*nConn] = nLocp;

  (*nConn)++;

  if (ConId)  Passon = &(ConId[*nConn]);
  else        Passon = NULL;

  status =
  om$send( msg = message VCTerm.VCTcables
                                (&retmsg, &nTC, &nRC, Passon),
      targetid = my_id);

#ifdef MY_DEBUG
  printf (" Gettopo term %d %d children\n",nTC, nRC);
#endif

  if (Passon == NULL)
  {
    (*nConn) += nTC;
  }
  else
  for (i=0; i<nTC; i++)
  {
    status =
    om$send (msg = message VCRoot.VCGetCpts
                             (&retmsg, &meself, &nTmCp, &nCbCp, &nLocp),
      targetid = Passon[i].objid,
      targetos = Passon[i].osnum);
 
    if ((nCpt != nTmCp) && (nCpt != VC_REQ_ALL_CPT)) continue;

    if (nConCp)
      nConCp[*nConn] = nCbCp;

    if (nMyCp)
      nMyCp[*nConn] = nTmCp;

    if (nPass)
      nPass[*nConn] = nLocp;

    (*nConn)++;
  }
  
  return (OM_S_SUCCESS);
}

method ACgive_structure(int          *msg;
                        int          *direct_index;
                        char         *footname;
                 struct ret_struct   *p_rs;
                 struct GRmd_env     *md_env)

{

  /*  do not inherit the terminal give..... */

  return (

  om$send (msg = message VCRoot.ACgive_structure
                             (msg, direct_index, footname, p_rs, md_env),
          mode = OM_e_wrt_message,
      targetid = my_id)

         );
}



method ACconstruct_feet( IGRlong    *msg;
                         IGRint      cn_type;
                         IGRint      count;
                  struct GRid       *list; 
                  struct GRmd_env   *md_env;
                         int        *fcount;
                  struct GRid       *feet_list)
{
  IGRlong        retmsg;
  IGRint         status;
  IGRint         i;
  IGRboolean     bFree;
  IGRshort       nIndex;
  IGRshort       nMAP;
  IGRdouble      dCPT[3];
  IGRdouble      dVEC[3];
  IGRdouble      dCorn[6];
  IGRdouble      dDia;

  struct IGRpolyline     Disp;
  struct GRvg_construct  cnst_lis;
  struct GRsymbology     Symb;
  struct ret_struct      Rs;

  *msg = MSSUCC;
  nIndex = -1;
  nMAP   = -1;

  /* One graphic will be built */
  *fcount  =1;
  feet_list[0].objid = NULL_OBJID;
  feet_list[0].osnum = OM_Gw_current_OS;

  Disp.num_points = 2;
  Disp.points     = dCorn;

  status =
  om$send( msg = message GRvg.GRgetsymb (&retmsg,&Symb),
      targetid = my_id);

  Symb.display_attr.weight = 5;

  /*A Set up constructionlist   */
  cnst_lis.msg          = &retmsg;
  cnst_lis.env_info     = md_env;
  cnst_lis.newflag      = FALSE;
  cnst_lis.properties   = GRIS_NEW | GRIS_LOCATABLE | GRIS_DISPLAYABLE;
  cnst_lis.level        = Symb.level;
  cnst_lis.display      = &(Symb.display_attr);

  cnst_lis.class_attr   = NULL;
  cnst_lis.name         = NULL;

  status =
  om$send (msg = message VCDB.VCGpAttr
                        (&retmsg, nIndex, nMAP, VC_N_DIAMETER_DB, &Rs),
  p_chanselect = &ND_father,
     from      = me->nVCAttr,
       to      = me->nVCAttr);

  dDia = Rs.var.root_pm_st.value;

  status =
  om$send (msg = message VCRoot.VCGetCptGeom
                         (&retmsg, me->nVCcabCpt, dCPT, dVEC, NULL,
                          &bFree, md_env),
  p_chanselect = &ND_father,
     from      = me->nVCAttr,
       to      = me->nVCAttr);

  for (i=0; i<3; i++)
  {
    dCorn[i]   = dCPT[i] + dDia * dVEC[i];
    dCorn[i+3] = dCPT[i] - dDia * dVEC[i];
  }

  status =
  om$construct (classid = OPP_GR3dlinestr_class_id,
                p_objid = &feet_list[0].objid,
                msg     = message GRgraphics.GRaltconstruct(&cnst_lis));
  as$status();

  if (retmsg & status & OM_S_SUCCESS)
  {
    status=
    om$send ( msg = message NDnode.NDmove_to_root
                                   (&retmsg, feet_list, md_env),
         targetid = feet_list[0].objid,
         targetos = feet_list[0].osnum);
    as$status ( action = RET_STATUS );
  }

  /*" graphics id = %d, %d\n",feet_list[0].objid, feet_list[0].osnum */

  return OM_S_SUCCESS;

}/* end of ACconstruct_feet */

method ACcheckin_candidate ( IGRint     CheckinType;
                             IGRint    *p_CheckinCandidate)

{
  IGRint     ii;

  ii = CheckinType;    /*  compiler warning    */

   /*    force to FALSE    */
   *p_CheckinCandidate = FALSE;

  return (OM_S_SUCCESS);
}

method VCSetInstance  (IGRlong    *msg;
                struct VCGenInfo  *Instance)

{
  IGRint          status;

  status =
  om$send (msg = message VCTerm.VCSetInstance (msg, Instance),
          mode = OM_e_wrt_message,
      targetid = my_id);

  me->nVCcabCpt   = Instance->Attr.Term.nCpt;

  return (status);
}

method VCGetInstance (IGRlong    *msg;
               struct VCGenInfo  *Instance)

{
  IGRint                status;

  status =
  om$send (msg = message VCTerm.VCGetInstance (msg, Instance),
          mode = OM_e_wrt_message,
      targetid = my_id);

  Instance->Attr.Term.nCpt = me->nVCcabCpt;

  return (status);
}

method VCGetEquipId (IGRlong  *msg;
              struct GRid     *EquipId)
{
  EquipId->objid = NULL_OBJID;

  *msg = MSFAIL;

  return (OM_S_SUCCESS);
}

method VCGetEquipTag (IGRlong  *msg;
                      IGRchar  *EqTag;
               struct GRmd_env *md_env)
{
  *msg = MSSUCC;

  VC_INITSTR (EqTag);
  return (OM_S_SUCCESS);
}

method  VCTcut    (IGRlong    *msg;
            struct GRid       *CB1;
            struct VCpos      *Cutpos1;
            struct GRid       *CB2;
            struct VCpos      *Cutpos2)
{
  *msg = MSFAIL;

  return (OM_S_SUCCESS);
}

end implementation VCTermCon;

