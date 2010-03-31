class implementation NMinters;

method EMinit_associative  (IGRlong *EMmsg;
                            IGRushort options;
                            IGRint num_parents;
                            struct EMSobject_info *parent_info;
                            IGRint type;
                            unsigned int size;
                            IGRchar *recomp_info;
                            struct GRvg_construct *construct_list)

{
 IGRlong sts;

 options |= (EMS_no_const_assoc | EMSinit_dont_store_recomp_info);
 sts = om$send(mode = OM_e_wrt_message, msg =message NMassoc.EMinit_associative
        (EMmsg, options, num_parents, parent_info, type, size, recomp_info, 
         construct_list), targetid = my_id);
 return(sts);
}

end implementation NMinters;
