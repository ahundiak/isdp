class implementation SKhorizvert;

from SKvariable import SKgetvar;

method SKorder_points(IGRlong *msg; 
                       IGRushort options;
                       IGRint num_pts; GRobjid *pt_ids;
                       IGRchar *moreinfo)
{
 IGRdouble   pts[6];
 IGRlong     OM_stat, mthd_stat;
 IGRint      i;
 GRobjid     dum_id;

 /* **************************************************************** */
 
 OM_stat = OM_S_SUCCESS;
 *msg = EMS_S_Success;

 if (num_pts != 2) 
   EMerr_hndlr (TRUE, *msg, EMS_E_InvalidArg, wrapup);

 for (i = 0; i < 2; i++)
 {
  OM_stat = om$send (msg = message SKvariable.SKgetvar (&mthd_stat,
                      NULL, NULL, NULL, &pts[3*i]),
                     targetid = pt_ids[i]);
  EMerr_hndlr (!(1&OM_stat&mthd_stat),*msg,EMS_E_Fail,wrapup);

 } /* for (i = 0; i < 2; i++) */

 if (ME.SKconstraint->props & SK_HORIZONTAL)
   i = X;
 else
   i = Y;

 if (pts[3+i] < pts[i])
   {
   dum_id = pt_ids[0];
   pt_ids[0] = pt_ids[1];
   pt_ids[1] = dum_id;
   }

 wrapup:
  EMWRAPUP(*msg, OM_stat, "SKhorizvert.SKorder_points");
 return (OM_stat);

}

end implementation SKhorizvert;
