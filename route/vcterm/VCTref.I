
/* $Id: VCTref.I,v 1.1.1.1 2001/01/04 21:12:39 cvs Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:        vcterm/VCTref.I
 *
 * Description:
 *
 *      methods for virtual terminal access
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VCTref.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:12:39  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/10/30  05:23:34  pinnacle
# Integ into Route 02040304
#
# Revision 1.8  1997/07/14  22:10:06  pinnacle
# Replaced: vcterm/VCTref.I for:  by hverstee for cabling
#
# Revision 1.7  1997/05/22  15:21:56  pinnacle
# Replaced: vcterm/VCTref.I for:  by hverstee for cabling
#
# Revision 1.6  1997/05/02  20:30:22  pinnacle
# Replaced: vcterm/VCTref.I for:  by hverstee for cabling
#
# Revision 1.5  1997/04/28  22:04:32  pinnacle
# Replaced: vcterm/VCTref.I for:  by hverstee for cabling
#
# Revision 1.4  1997/01/20  20:39:40  pinnacle
# Replaced: vcterm/VCTref.I for:  by hverstee for cabling
#
# Revision 1.3  1997/01/09  18:11:52  pinnacle
# Replaced: vcterm/VCTref.I for:  by hverstee for cabling
#
# Revision 1.2  1996/08/29  22:38:56  pinnacle
# Replaced: vcterm/VCTref.I for:  by hverstee for cabling
#
# Revision 1.1  1996/08/28  21:34:14  pinnacle
# Created: vcterm/VCTref.I by hverstee for cabling
#
 *
 * History:
 *      MM/DD/YY   AUTHOR       DESCRIPTION
 *
 *      05/29/96    hv          Initial
 *
 *************************************************************************/

class implementation VCTerm;

/*
#define MY_DEBUG
*/



/****************************************************************************/
/*                                                                          */
/*D    METHOD NAME   -  VCTRealCon                                          */
/*D                                                                         */
/*D    Abstract:                                                            */
/*D     This method will return the Id of the real connector (if virtual)   */
/*D      or itself if not.                                                  */
/*D                                                                         */
/*D     method VCTRealCon( IGRlong    *msg;                                 */
/*D                 struct GRid       *RealCon;                             */
/*D                 struct GRmd_env   *md_env)                              */
/*D                                                                         */
/*D    Parameters:                                                          */
/*D                                                                         */
/*D    Name          I/O        Description                                 */
/*D    -------------------------------------------------------------------  */
/*D                                                                         */
/*D    *msg           O         Error indicator                             */
/*D    *RealCon       O         Real connector Id                           */
/*D    *md_env        I         environment                                 */
/*                                                                          */
/****************************************************************************/

method VCTRealCon( IGRlong    *msg;
            struct GRid       *RealCon;
            struct GRmd_env   *md_env)

{
  IGRlong            retmsg;
  IGRint             status = OM_S_SUCCESS;

  if (me->nVCType & VC_GEN_VIRTUAL)
  {
    IGRshort           iParno;
    struct GRmd_env    OtherEnv;
    struct GRid        LocRefId;

    if (md_env)
      OtherEnv = *md_env;

    iParno = 0;

    status =
    om$send(msg = message VCRoot.VCParent
                     (&retmsg, iParno, &LocRefId, md_env),
       targetid = my_id);

    status =
    om$send(msg = message NDmacro.ACreturn_foot
                         (&retmsg, "", RealCon,  &OtherEnv.md_env.matrix_type,
                                             OtherEnv.md_env.matrix),
       targetid = LocRefId.objid,
       targetos = LocRefId.osnum ) ;
    as$status( action = RET_STATUS );

    *msg = MSSUCC;
  }
  else
  {
    RealCon->objid = my_id;
    RealCon->osnum = OM_Gw_current_OS;
    *msg = MSSUCC;
  }

  return (status);
}

/****************************************************************************/
/*                                                                          */
/*D    METHOD NAME   -  VCGetEquipId                                        */
/*D                                                                         */
/*D    Abstract:                                                            */
/*D     This method will return the parent equipment ID                     */
/*D                                                                         */
/*D     method VCGetEquipId (     IGRlong  *msg;                            */
/*D                        struct GRid     *EquipId);                       */
/*D                                                                         */
/*D    Parameters:                                                          */
/*D                                                                         */
/*D    Name          I/O        Description                                 */
/*D    -------------------------------------------------------------------  */
/*D                                                                         */
/*D    *msg            O         Error indicator/message                    */
/*D    *EquipId        O         Equipment GRid                             */
/*                                                                          */
/****************************************************************************/

method VCGetEquipId (IGRlong  *msg;
              struct GRid     *EquipId)

{
  IGRint          status;
  IGRlong         retmsg;

  struct GRid     Loc_Id;
  struct GRid     Eqp_Id;

  Loc_Id.objid = NULL_OBJID;
  Loc_Id.osnum = OM_Gw_current_OS;
  Eqp_Id.objid = NULL_OBJID;
  Eqp_Id.osnum = OM_Gw_current_OS;

  if (me->nVCType & VC_GEN_VIRTUAL)
  { /*A     find parent id      */
    int    count;

#ifdef MY_DEBUG
    printf (" EQ of virtcon  \n");
#endif

    status =
    om$get_objid_at_index ( object          = me,
                            p_chanselect    = &ND_father,
                            index           = (IGRint) me->nVCAttr,
                            objidaddr       = &Loc_Id.objid,
                            osnumaddr       = &Loc_Id.osnum);

    status =
    om$send(msg = message NDnode.NDget_objects
                               (ND_ROOT, &Eqp_Id, 1, NULL,0, 0, &count),
       targetid = Loc_Id.objid,
       targetos = Loc_Id.osnum);
    as$status( action = RET_STATUS );

  }
  else
  if ((me->nVCType & VC_TERM_EQ) || (me->nVCType & VC_TERM_RE))
  { /*A     find parent id , which is the eq id     */
    struct GRmd_env     LocEnv;

#ifdef MY_DEBUG
    printf (" EQ of equipcon  \n");
#endif

    status =
    om$send(msg = message VCRoot.VCParent
                         (&retmsg, (IGRshort) 0, &Eqp_Id, &LocEnv),
       targetid = my_id);
  }
  else
  {    /*A  on builtin connector, not virtualized (yet) traverse
                                           component - owner channels    */
    struct GRid     P1_Id;
    struct GRid     P2_Id;
    struct GRid     P3_Id;

#ifdef MY_DEBUG
    printf (" EQ of regcon  \n");
#endif

    P1_Id.objid = my_id;
    P1_Id.osnum = OM_Gw_current_OS;
    P2_Id.objid = P3_Id.objid = Eqp_Id.objid = NULL_OBJID;
    P2_Id.osnum = P3_Id.osnum = Eqp_Id.osnum = OM_Gw_current_OS;

    ASget_as_owner (&P1_Id, &P2_Id);   /*   find first owner    */
    if (P2_Id.objid == NULL_OBJID) goto DEFAULT;

    ASget_as_owner (&P2_Id, &P3_Id);   /*   find second owner    */
    if (P3_Id.objid == NULL_OBJID) goto DEFAULT;

    ASget_as_owner (&P3_Id, &Eqp_Id);   /*   find VREQuipment    */

    /*    if there are only two levels (NO MODEL??)      */
    if (Eqp_Id.objid == NULL_OBJID)
    {
      Eqp_Id.objid = P3_Id.objid;
      Eqp_Id.osnum = P3_Id.osnum;
    }
  }

  DEFAULT:
  *msg = MSSUCC;
  EquipId->objid = Eqp_Id.objid;
  EquipId->osnum = Eqp_Id.osnum;

#ifdef MY_DEBUG
  printf (" EQ ID out <%d %d>\n",EquipId->objid,EquipId->osnum);
#endif

  return (OM_S_SUCCESS);
}

method VCGetEquipTag (IGRlong  *msg;
                      IGRchar  *EqTag;
               struct GRmd_env *md_env)
{

  return (
  om$send (msg = message VCMac.VCGetEquipTag (msg, EqTag, md_env),
          mode = OM_e_wrt_message,
      targetid = my_id)
         );
}

end implementation VCTerm;

