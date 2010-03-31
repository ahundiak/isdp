class implementation NMnonmanigm;

method GRxform(IGRlong *EMmsg; struct GRmd_env *obj_mdenv;
               IGRshort *matrix_type; IGRmatrix matrix;
               GRobjid *newobjid)
{
 IGRlong	sts = OM_S_SUCCESS;
 struct NMgmSSI ssi;
 IGRint 	i;
 GRobjid	locnewobjid;

 *EMmsg = EMS_S_Success;
 NMinit_ssi(&ssi);

 sts = om$send(msg = message NMnonmanigm.NMget_SSI
       (EMmsg, &ssi, NMgetssi_cache), targetid = my_id);
 if(!(1&*EMmsg&sts)) goto wrapup;

 /* Send to all vertices.
 */
 for(i=0; i<ssi.num_vtx; i++)
  {
   sts = om$send(msg = message GRgraphics.GRxform(EMmsg, obj_mdenv, 
         matrix_type, matrix, &locnewobjid), targetid = ssi.vtx[i]);
   if(!(1&*EMmsg&sts)) goto wrapup;
  }

 /* Execute owner's implementation.
 */
 sts = om$send(msg = message GRowner.GRxform(EMmsg, obj_mdenv, 
       matrix_type, matrix, newobjid), mode = OM_e_wrt_message, 
       targetid = my_id);

wrapup:
EMWRAPUP(*EMmsg, sts, "NMnonmanigm.GRxform");
return(sts);
}

end implementation NMnonmanigm;
