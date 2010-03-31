class implementation NMfeaturelp;

extern OMuword OPP_EMSloopset_class_id, OPP_EMSloop_class_id, 
	       OPP_NMedflp_class_id, OPP_EMSedge_class_id;

method debug()
{
 IGRlong		sts = OM_S_SUCCESS, rc;
 GRobjid		parent;

 if(EFisAncestryValid(&rc, my_id, OM_Gw_current_OS, OPP_NMedflp_class_id, 
    FALSE))
  fprintf(stderr, "NMedflp Object:\n\tObjectid %d\n", my_id);
 else
  fprintf(stderr, "NMfeaturelp Object:\n\tObjectid %d\n", my_id);

 parent = ME.NMfeaturelp->nesting_parent;
 sts = om$is_objid_valid(objid = parent);
 if(1&sts)
  {
   fprintf(stderr, "\tNesting Parent %d ", parent);
   if(EFisAncestryValid(&rc, parent, OM_Gw_current_OS, OPP_EMSloopset_class_id,
      FALSE))
    fprintf(stderr, " (EMSloopset)\n");
   else if(EFisAncestryValid(&rc, parent, OM_Gw_current_OS, 
	OPP_EMSloop_class_id, FALSE))
    fprintf(stderr, " (EMSloop)\n");
   else if(EFisAncestryValid(&rc, parent, OM_Gw_current_OS, 
	OPP_EMSedge_class_id, FALSE))
    fprintf(stderr, " (EMSedge)\n");
   else fprintf(stderr, " (Unknown class)\n");
  }

 else fprintf(stderr, "\tNesting Parent Not Valid\n");
 fprintf(stderr, "\tHelper Props: 0x%x", ME.EMShelper->props);
 sts = om$send(mode = OM_e_wrt_message, msg = message EMSloop.debug(), 
       targetid = my_id);
return(sts);
}

end implementation NMfeaturelp;
