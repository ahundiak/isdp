
/* $Id: VCRDBover.I,v 1.1.1.1 2001/01/04 21:12:36 cvs Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:        vcroot / VCRDBover.I
 *
 * Description:
 *   This file contains the overrides to access the DB cache
 *
 * Dependencies:
 *
 * Revision History:
 *        $Log: VCRDBover.I,v $
 *        Revision 1.1.1.1  2001/01/04 21:12:36  cvs
 *        Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/10/30  05:23:10  pinnacle
# Integ into Route 02040304
#
# Revision 1.4  1997/08/11  21:40:34  pinnacle
# Replaced: vcroot/VCRDBover.I for:  by hverstee for cabling
#
# Revision 1.3  1997/07/14  21:57:00  pinnacle
# Replaced: vcroot/VCRDBover.I for:  by hverstee for cabling
#
# Revision 1.2  1997/03/19  15:52:10  pinnacle
# Replaced: vcroot/VCRDBover.I for:  by hverstee for cabling
#
# Revision 1.1  1996/08/28  21:11:34  pinnacle
# Created: vcroot/VCRDBover.I by hverstee for cabling
#
 *
 * History:
 *        05/29/96        hv         Initial
 *
 *************************************************************************/

class implementation VCRoot;

/*   overridden and redirected to DB model cache   */

/*
#define MY_DEBUG
*/

method   VCGetPos  (IGRlong         *msg;
             struct VCpos           *Posdef;
                    IGRshort        *nIndex;
                    IGRshort        *nMAP;
                    IGRshort        *nSig)
{
  struct GRid     Modelid;
  IGRint          status;
  IGRlong         retmsg;

  status = 
  om$send( msg = message VCRoot.VCGetModel (&retmsg, &Modelid),
      targetid = my_id);

  if (Modelid.objid != NULL_OBJID)
  {
    status =
    om$send( msg = message VCDB.VCGetPos
                              (msg, Posdef, nIndex, nMAP, nSig),
        targetid = Modelid.objid,
        targetos = Modelid.osnum);
  }
  else
    *msg = MSFAIL;

  return (OM_S_SUCCESS);

}/* end VCGetPos */


method   VCGpAnum  (IGRlong         *msg;
                    IGRshort         nIndex;
                    IGRshort         nMAP;
                    IGRint           nAttnum;
             struct ret_struct      *res)
{
  struct GRid     Modelid;
  IGRint          status;
  IGRlong         retmsg;

  status =  
  om$send( msg = message VCRoot.VCGetModel (&retmsg, &Modelid),
      targetid = my_id);

  if (Modelid.objid != NULL_OBJID)
  {
    status =
    om$send( msg = message VCDB.VCGpAnum (msg, nIndex, nMAP, nAttnum, res),
        targetid = Modelid.objid,
        targetos = Modelid.osnum);
  }
  else
    *msg = MSFAIL;

  return (OM_S_SUCCESS);

}/* end method VCGpAnum */

method  VCGetLayout (IGRlong         *msg;
                     IGRchar         *Modnam;
                     IGRshort        *nEnt;
                     IGRshort        *nTab;
              struct VClayout        *Layout)
{
  struct GRid     Modelid;
  IGRint          status;
  IGRlong         retmsg;

  status =
  om$send( msg = message VCRoot.VCGetModel (&retmsg, &Modelid),
      targetid = my_id);

  if (Modelid.objid != NULL_OBJID)
  {
    status =
    om$send( msg = message VCDB.VCGetLayout (msg, Modnam, nEnt, nTab, Layout),
        targetid = Modelid.objid,
        targetos = Modelid.osnum);
  }
  else
    *msg = MSFAIL;

  return (OM_S_SUCCESS);

}/* end method VCGetLayout */

method  VCGetModules (IGRlong         *msg;
                      IGRshort        *nEnt;
                      IGRshort        *nTopoTyp;
                      IGRchar         *Modlist)
{
  struct GRid     Modelid;
  IGRint          status;
  IGRlong         retmsg;

  status =
  om$send( msg = message VCRoot.VCGetModel (&retmsg, &Modelid),
      targetid = my_id);

  if (Modelid.objid != NULL_OBJID)
  {
    status =
    om$send( msg = message VCDB.VCGetModules (msg, nEnt, nTopoTyp, Modlist),
        targetid = Modelid.objid,
        targetos = Modelid.osnum);
  }
  else
    *msg = MSFAIL;

  return (OM_S_SUCCESS);

}/* end method VCGetModules  */

end implementation VCRoot;

