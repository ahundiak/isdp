class implementation EMScompsurf;

/*
   Name:

         ASMtrans_comp_symb

   Abstract:

         This function copies the symbology of components of the
     solids and features from the original graph to the new graph
     in the partfile.
*/


IGRlong ASMtrans_comp_symb(frm_compid, to_compid, to_comps)
struct GRid *frm_compid, *to_compid;
OM_S_CHANSELECT *to_comps;
{
  struct GRid frm_id, to_id;
  IGRint frm_comp_count,to_comp_count;
  IGRlong sts,i;
  OMuword classid;

   frm_comp_count = 0;
   to_comp_count = 0;
   sts = 0;


    sts = om$get_channel_count(p_chanselect = to_comps,
			       objid = frm_compid->objid,
			       osnum = frm_compid->osnum,
			       count = (OMuint *) &frm_comp_count);
    sts = om$get_channel_count(p_chanselect = to_comps,
			       objid = to_compid->objid,
			       osnum = to_compid->osnum,
			       count = (OMuint *) &to_comp_count);

    if(frm_comp_count != to_comp_count)
      return(1);

    if(frm_comp_count == 0)
      {
        if((frm_compid->objid != NULL_OBJID) &&
           (to_compid->objid != NULL_OBJID))
          {
             ACtrans_symb(*frm_compid, *to_compid);
          }
          return(1);
      }

    for(i=0; i < frm_comp_count ; i = i +1)
     {
        frm_id.objid = NULL_OBJID;
        to_id.objid  = NULL_OBJID;
	sts = om$get_objid_at_index(objid = frm_compid->objid,
				    osnum = frm_compid->osnum,
				    p_chanselect = to_comps,
				    index = i,
				    objidaddr = &frm_id.objid,
				    osnumaddr = &frm_id.osnum);

	sts = om$get_objid_at_index(objid = to_compid->objid,
				    osnum = to_compid->osnum,
				    p_chanselect = to_comps,
				    index = i,
				    objidaddr = &to_id.objid,
				    osnumaddr = &to_id.osnum);

        om$get_classid(objid = frm_id.objid,
        osnum = frm_id.osnum,
        p_classid = &classid);

        if((om$is_ancestry_valid(subclassid = classid,
		 superclassname = "EMSfeature") != OM_S_SUCCESS) &&
	   (om$is_ancestry_valid(subclassid = classid,
		 superclassname = "EMSsfboolean") != OM_S_SUCCESS))
	 {
            ASMtrans_comp_symb(&frm_id, &to_id, to_comps);
	 }
     }

   return(1);

}

end implementation EMScompsurf;
