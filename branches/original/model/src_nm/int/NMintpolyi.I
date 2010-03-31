class implementation NMintpoly;

method NMput_poly(IGRlong *EMmsg; struct IGRpolyline *poly;
		  unsigned char int_props)
{
 IGRlong 	sts = OM_S_SUCCESS;
 IGRboolean	is_2d = FALSE;

 *EMmsg = EMS_S_Success;
 is_2d = (int_props & NMintobject_Is2d) ? TRUE : FALSE;

 OM_SET_DIMENSION(ME.NMintpoly->points, poly->num_points * (is_2d ? 2 : 3));
 OM_BLOCK_MOVE(poly->points, ME.NMintpoly->points, 
	       poly->num_points * (is_2d ? 2 : 3) * sizeof(IGRdouble));
 ME.NMintpoly->num_points = (IGRushort) poly->num_points;
 ME.NMintpoly->int_props = int_props;

return(sts);
}

method NMget_poly(IGRlong *EMmsg; struct IGRpolyline *poly;
		  unsigned char *int_props)
{
 IGRlong 	sts = OM_S_SUCCESS;	
 IGRboolean	is_2d = FALSE;

 *EMmsg = EMS_S_Success;
 is_2d = (ME.NMintpoly->int_props & NMintobject_Is2d) ? TRUE : FALSE;

 poly->points = (IGRdouble *) om$malloc(size = ME.NMintpoly->num_points *
		(is_2d ? 2 : 3) * sizeof(IGRdouble));
 EMerr_hndlr(!poly->points, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
 OM_BLOCK_MOVE(ME.NMintpoly->points, poly->points, ME.NMintpoly->num_points 
		* (is_2d ? 2 : 3) * sizeof(IGRdouble));
 poly->num_points = (IGRlong) ME.NMintpoly->num_points;

 if(int_props) *int_props = ME.NMintpoly->int_props;

wrapup:
return(sts);
}

end implementation NMintpoly;
