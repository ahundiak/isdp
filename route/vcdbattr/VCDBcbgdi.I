
/* $Id: VCDBcbgdi.I,v 1.1.1.1 2001/01/04 21:12:32 cvs Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:        vcdbattr / VCDBcbgdi.I
 *
 * Description:
 *   This file contains the methods and functions used in the basic
 *   VCDBcbgd class
 *
 * Dependencies:
 *
 * Revision History:
 *        $Log: VCDBcbgdi.I,v $
 *        Revision 1.1.1.1  2001/01/04 21:12:32  cvs
 *        Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/10/30  04:25:18  pinnacle
# Integration of Cable into 02.04.03.04
#
# Revision 1.4  1997/07/14  21:44:20  pinnacle
# Replaced: vcdbattr/VCDBcbgdi.I for:  by hverstee for cabling
#
# Revision 1.3  1997/03/19  15:18:52  pinnacle
# Replaced: vcdbattr/VCDBcbgdi.I for:  by hverstee for cabling
#
# Revision 1.2  1996/08/30  21:17:02  pinnacle
# Replaced: vcdbattr/VCDBcbgdi.I for:  by hverstee for cabling
#
# Revision 1.1  1996/08/28  20:53:20  pinnacle
# Created: vcdbattr/VCDBcbgdi.I by hverstee for cabling
#
 *
 * History:
 *        05/29/96        hv         Initial
 *
 *************************************************************************/

class implementation VCDBcbgd;


method  VCGpAnum  (IGRlong         *msg;
                   IGRshort         nIndex;
                   IGRshort         nMAP;
                   IGRint           nAttnum;
            struct ret_struct      *res)
{
   IGRint     status;

   *msg = MSSUCC;

   switch (nAttnum)
   {
     case VC_X_DIAMETER_DB:
       res->type = double_type;
       res->var.root_pm_st.value = me->DBMain.Diameter;
       break;
     case VC_X_BEND_RAD_DB:
       res->type = double_type;
       res->var.root_pm_st.value = me->DBMain.Bendrad;
       break;
     case VC_X_INSUL_TYPE_AN:
       res->type = text_type;
       strcpy (res->var.text_st.text_string, me->DBMain.Insul_type);
       break;
     case VC_X_INSUL_THK_DB:
       res->type = double_type;
       res->var.root_pm_st.value = me->DBMain.Insul_thk;
       break;
     default:
       status =
       om$send (msg = message VCDBgen.VCGpAnum
                                         (msg, nIndex, nMAP, nAttnum, res),
               mode = OM_e_wrt_message,
           targetid = my_id);
       break;
  }

  return (OM_S_SUCCESS);
}

method VCDB_init (IGRlong         *msg;
           struct VCdbmain        *Tabrec)
{
  IGRint     status;

  status =
  om$send (msg = message VCDBgen.VCDB_init (msg, Tabrec),
          mode = OM_e_wrt_message,
      targetid = my_id);

  strcpy (me->DBMain.Insul_type,  Tabrec->Insul_type);

  me->DBMain.Diameter  = Tabrec->Diameter;
  me->DBMain.Bendrad   = Tabrec->Bendrad;
  me->DBMain.Insul_thk = Tabrec->Insul_thk;

  return (OM_S_SUCCESS);
}

method VCDB_ghdr (IGRlong         *msg;
           struct VCdbmain        *Tabrec)
{
  IGRint     status;

  status =
  om$send (msg = message VCDBgen.VCDB_ghdr (msg, Tabrec),
          mode = OM_e_wrt_message,
      targetid = my_id);

  strcpy (Tabrec->Insul_type, me->DBMain.Insul_type);

  Tabrec->Insul_thk  = me->DBMain.Insul_thk;
  Tabrec->Diameter   = me->DBMain.Diameter;
  Tabrec->Bendrad    = me->DBMain.Bendrad;

  return (OM_S_SUCCESS);
}

end implementation VCDBcbgd;

