
IGRlong EMreplace_with_new_surf (
                                 IGRlong *msg,
                                 struct GRmd_env *md_env,
                                 struct EMSpartolbasis *partolbasis,
                                 IGRint num_surfs,
                                 GRobjid *surfs,
                                 IGRint num_edinfo,
                                 struct EMmerge_info *edinfo,
                                 IGRint *numowners,
                                 struct EMSownercomp **ownercomps,
                                 GRobjid new_surf);

