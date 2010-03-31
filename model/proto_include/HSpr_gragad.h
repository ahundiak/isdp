#if defined (__) 
#undef __
#endif


#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/*---HSsave_rest.I--------------------------------------------*/

extern IGRlong HSconnect_instance_to_gragad __(( IGRlong *, OM_S_OBJID, OM_S_OBJID, OMuword )); 
extern IGRlong HSget_saved_instance_id      __(( IGRlong *, OM_S_OBJID, OMuword, OM_S_OBJID *));

/*---HSsetinq.I------------------------------------------------*/

extern IGRlong HSget_default_instance     __(( IGRlong *, IGRlong *, struct var_list *));
extern IGRlong HSget_window_instance_data __(( IGRlong *, OM_S_OBJID, OMuword, IGRlong *, struct var_list *));
extern IGRlong HSset_window_instance_data __(( IGRlong *, OM_S_OBJID, OMuword, IGRlong *, struct var_list *));

/*---HSgenupdate.I---------------------------------------------*/

void	HSredraw_coordinate_system( GRobjid my_id, enum GRdpmode mode, struct GRid *buffer, IGRlong *no_oids );

#if defined(__cplusplus)
}
#endif


#undef __
