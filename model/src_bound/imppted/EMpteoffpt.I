/* ###################   APOGEE COMPILED   ################## */
class implementation EMSptedge;

method EMoffpoint (IGRlong *EMmsg; struct EMSedgebound *edpar; 
                   IGRdouble *edpt, *tangent, offdist;
		   GRobjid *sfobjid;
		   struct IGRbsp_surface *sfgeom;
		   struct GRmdenv_info *env;
                   struct EMSpartolbasis *partolb;
		   IGRint *numedges_visited, *edbufsize;
		   GRobjid **edges_visited;
		   IGRushort options;
		   IGRdouble *off_edptuv, *off_edptxyz;
		   GRobjid *off_edptsf)
{
  IGRlong			sts;

  /* If a tangent is not supplied, there are infite solutions for the offset
     point around the point edge. Therefore we compute the point only if
     the tangent vector is passed in. Otherwise we return an informational
     message.
  */
  sts = OM_S_SUCCESS;
  if(tangent) sts = om$send(mode = OM_e_wrt_message, msg = message
		EMSedge.EMoffpoint(EMmsg, edpar, edpt, tangent, offdist, 
		sfobjid, sfgeom, env, partolb, numedges_visited, edbufsize, 
		edges_visited, options, off_edptuv, off_edptxyz, off_edptsf),
			targetid = my_id);
  else *EMmsg = EMS_I_Degenerate;

  return (sts);
}


end implementation EMSptedge;

