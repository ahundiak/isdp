
/* $Id: VCDBgeni.I,v 1.2 2001/02/14 17:43:02 louis Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:        vcdbattr / VCDBgeni.I
 *
 * Description:
 *   This file contains the methods and functions used in the basic
 *   VCDBgen class
 *
 * Dependencies:
 *
 * Revision History:
 *        $Log: VCDBgeni.I,v $
 *        Revision 1.2  2001/02/14 17:43:02  louis
 *        TR4617-found memory overwrite when processing more than 80 characters
 *
 *        Revision 1.1.1.1  2001/01/04 21:12:32  cvs
 *        Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/10/30  04:25:18  pinnacle
# Integration of Cable into 02.04.03.04
#
# Revision 1.5  1997/07/21  22:50:54  pinnacle
# Replaced: vcdbattr/VCDBgeni.I for:  by hverstee for cabling
#
# Revision 1.4  1997/07/14  21:44:32  pinnacle
# Replaced: vcdbattr/VCDBgeni.I for:  by hverstee for cabling
#
# Revision 1.3  1997/03/19  15:19:12  pinnacle
# Replaced: vcdbattr/VCDBgeni.I for:  by hverstee for cabling
#
# Revision 1.2  1996/10/29  22:13:08  pinnacle
# Replaced: vcdbattr/VCDBgeni.I for:  by hverstee for cabling
#
# Revision 1.1  1996/08/28  20:53:48  pinnacle
# Created: vcdbattr/VCDBgeni.I by hverstee for cabling
#
 *
 * History:
 *        05/29/96        hv         Initial
 *        02/14/01	  law	     TR4617 fixed strcpy overwrite of more than
 *					80 characters.
 *
 *************************************************************************/

class implementation VCDBgen;


method  VCGpAnum  (IGRlong         *msg;
                   IGRshort         nIndex;
                   IGRshort         nMAP;
                   IGRint           nAttnum;
            struct ret_struct      *res)
{
   *msg = MSSUCC;

   switch (nAttnum)
   {
     case VC_X_SHORT_DESC_AN:
       res->type = text_type;
       strcpy (res->var.text_st.text_string, me->DBMain.Short_desc);
       break;
     case VC_X_OWNER_ID_AN:
       res->type = text_type;
       strcpy (res->var.text_st.text_string, me->DBMain.OwnerId);
       break;
     case VC_X_STANDARD_AN:
       res->type = text_type;
       strcpy (res->var.text_st.text_string, me->DBMain.Standard);
       break;
     case VC_X_DIAMETER_DB:
       res->type = double_type;
       res->var.root_pm_st.value = me->DBMain.Diameter;
       break;
     case VC_X_BEND_RAD_DB:
       res->type = double_type;
       res->var.root_pm_st.value = me->DBMain.Bendrad;
       break;
     case VC_X_ENVIRON_AN:
       res->type = text_type;
       strcpy (res->var.text_st.text_string, me->DBMain.Environment);
       break;
     case VC_X_FIRE_RESIST_AN:
       res->type = text_type;
       strcpy (res->var.text_st.text_string, me->DBMain.Fire_resist);
       break;
     case VC_X_SECURITY_AN:
       res->type = text_type;
       strcpy (res->var.text_st.text_string, me->DBMain.Security);
       break;
     case VC_X_INSUL_TYPE_AN:
       res->type = text_type;
       strcpy (res->var.text_st.text_string, me->DBMain.Insul_type);
       break;
     case VC_X_INSUL_THK_DB:
       res->type = double_type;
       res->var.root_pm_st.value = me->DBMain.Insul_thk;
       break;
     case VC_X_WEIGHT_DB:
       res->type = double_type;
       res->var.root_pm_st.value = me->DBMain.Weight;
       break;
     case VC_X_COST_DB:
       res->type = double_type;
       res->var.root_pm_st.value = me->DBMain.Unit_Cost;
       break;
     case VC_X_GN_DATA1_DB:
       res->type = double_type;
       res->var.root_pm_st.value = me->DBMain.Gn_data_1;
       break;
     case VC_X_GN_DATA2_DB:
       res->type = double_type;
       res->var.root_pm_st.value = me->DBMain.Gn_data_2;
       break;
     case VC_X_DESC_AN:
       res->type = text_type;
       /***** TR4617 limit to 80 characters ******/
       strncpy (res->var.text_st.text_string, me->DBMain.Desc,79);
       res->var.text_st.text_string[79] = '\0';
       break;
     case VC_X_VENDOR_AN:
       res->type = text_type;
       strcpy (res->var.text_st.text_string, me->DBMain.Vendor);
       break;
     case VC_X_CATALOG_NUM_AN:
       res->type = text_type;
       strcpy (res->var.text_st.text_string, me->DBMain.Catalog);
       break;
     case VC_X_STOCK_NUM_AN:
       res->type = text_type;
       strcpy (res->var.text_st.text_string, me->DBMain.Stockno);
       break;

     default:
       *msg = MSFAIL;
       break;
  }

  return (OM_S_SUCCESS);
}

method VCDB_init (IGRlong         *msg;
           struct VCdbmain        *Tabrec)
{
  IGRint     status;

  *msg = MSSUCC;

  status = VD_DLO_SetIndx (me->DBMain.OwnerId,
                           me->DBMain.Timest,
                          &me->DBMain.Local,
                          &me->DBMain.LcUnit);

  strcpy (me->DBMain.Compcode,    Tabrec->Compcode);
  strcpy (me->DBMain.Short_desc,  Tabrec->Short_desc);
  strcpy (me->DBMain.Standard,    Tabrec->Standard);
  strcpy (me->DBMain.Environment, Tabrec->Environment);
  strcpy (me->DBMain.Fire_resist, Tabrec->Fire_resist);
  strcpy (me->DBMain.Security,    Tabrec->Security);
  strcpy (me->DBMain.Insul_type,  Tabrec->Insul_type);
  strcpy (me->DBMain.Desc,        Tabrec->Desc);
  strcpy (me->DBMain.Vendor,      Tabrec->Vendor);
  strcpy (me->DBMain.Catalog,     Tabrec->Catalog);
  strcpy (me->DBMain.Stockno,     Tabrec->Stockno);
  strcpy (me->DBMain.Insertblk,   Tabrec->Insertblk);

  me->DBMain.Diameter  = Tabrec->Diameter;
  me->DBMain.Bendrad   = Tabrec->Bendrad;
  me->DBMain.Insul_thk = Tabrec->Insul_thk;
  me->DBMain.Weight    = Tabrec->Weight;
  me->DBMain.Unit_Cost = Tabrec->Unit_Cost;
  me->DBMain.Gn_data_1 = Tabrec->Gn_data_1;
  me->DBMain.Gn_data_2 = Tabrec->Gn_data_2;

  return (OM_S_SUCCESS);
}

method VCDB_ghdr (IGRlong         *msg;
           struct VCdbmain        *Tabrec)
{
  *msg = MSSUCC;

  strcpy (Tabrec->Compcode,    me->DBMain.Compcode);
  strcpy (Tabrec->OwnerId,     me->DBMain.OwnerId);
  strcpy (Tabrec->Timest,      me->DBMain.Timest);
  strcpy (Tabrec->Short_desc,  me->DBMain.Short_desc);
  strcpy (Tabrec->Standard,    me->DBMain.Standard);
  strcpy (Tabrec->Environment, me->DBMain.Environment);
  strcpy (Tabrec->Fire_resist, me->DBMain.Fire_resist);
  strcpy (Tabrec->Security,    me->DBMain.Security);
  strcpy (Tabrec->Desc,        me->DBMain.Desc);
  strcpy (Tabrec->Vendor,      me->DBMain.Vendor);
  strcpy (Tabrec->Catalog,     me->DBMain.Catalog);
  strcpy (Tabrec->Stockno,     me->DBMain.Stockno);
  strcpy (Tabrec->Insertblk,   me->DBMain.Insertblk);

  Tabrec->Weight      = me->DBMain.Weight;
  Tabrec->Unit_Cost   = me->DBMain.Unit_Cost;
  Tabrec->Gn_data_1   = me->DBMain.Gn_data_1;
  Tabrec->Gn_data_2   = me->DBMain.Gn_data_2;

  Tabrec->LcUnit      = me->DBMain.LcUnit;
  Tabrec->Local       = me->DBMain.Local;

  return (OM_S_SUCCESS);
}


/*     make sure the following messages do nothing untoward    */


method NDupdate(          int      *msg;
                          int       cn_type, count;
                   struct GRid     *parents;
                          int      *parent_state;
                   struct GRid     *context,*new_objid;
                   struct GRmd_env *md_env)

{
  *msg = MSSUCC;

  return (OM_S_SUCCESS);
}

method ACconstruct_feet( IGRlong *msg; IGRint cn_type;
                           IGRint count; struct GRid list [];
                           struct GRmd_env *md_env;
                           int *fcount; struct GRid  *feet_list)
{
  *msg = MSSUCC;
  *fcount = 0;
  return (OM_S_SUCCESS);
}

/*    do nothing with macro's etc.    */

method  NDsleep(struct GRmd_env *md_env)
{
 return om$send(msg = message ASnode.NDsleep(md_env),
           targetid = my_id,
               mode = OM_e_wrt_message);
}


end implementation VCDBgen;

