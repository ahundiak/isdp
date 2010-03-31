/*
 *  HSpr_bundle_.h: The prototype file for the 
 *                  hsurf/src/bundle_imp directory
 */
 
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

/*---HSapp_newmac.I--------------------------------------------*/

extern IGRint HSappredefinesymb       __(( IGRlong *, IGRchar *, GRobjid, GRspacenum ));				    
extern IGRint HSapp_getentrysize_symb __(( IGRlong *, IGRint *, IGRint, GRobjid, GRspacenum));
extern IGRint HSapp_getnumfields_symb __(( IGRlong *, IGRint *, GRobjid, GRspacenum ));

/*---HSappmac.I------------------------------------------------*/

extern void   HSinit_appsymb_id  __(( void ));
extern void   HSset_appsymb_id   __(( GRobjid, GRspacenum ));
extern void   HSreset_appsymb_id __(( GRspacenum ));
extern IGRint HSappaddsymb       __(( IGRlong *, IGRchar *, IGRint *, GRobjid, GRspacenum ));
extern IGRint HSappcreasymb      __(( IGRlong *, IGRchar *, IGRint *, GRobjid, GRspacenum ));
extern IGRint HSappretsymb       __(( IGRlong *, IGRint, IGRchar *, GRobjid, GRspacenum ));
extern IGRint HSappdelsymb       __(( IGRlong *, IGRint, GRobjid, GRspacenum ));
extern IGRint HSappchgsymb       __(( IGRlong *, IGRint, IGRchar *, IGRint *, GRobjid, GRspacenum ));
extern IGRint HSget_appsymb_id   __(( GRobjid, GRspacenum, GRobjid *));
				       
/*---HSbundmac.I--------------------------------------------------------*/

extern int HSaddbundentry __(( IGRlong *, struct HSrender_bundle *, struct HSextra_render_bundle *, 
			       IGRint *, GRobjid, GRspacenum ));
				    
extern int HScrebundentry __(( IGRlong *, struct HSrender_bundle *, struct HSextra_render_bundle *, 
			       	IGRint *, GRobjid, GRspacenum ));
				    
extern int HSretbundentry __(( IGRlong *, IGRint, struct HSrender_bundle *, 
			       struct HSextra_render_bundle *, GRobjid, GRspacenum ));
				    
extern int HSdelbundentry __(( IGRlong *, IGRint, GRobjid, GRspacenum ));
extern int HSchgbundentry __(( IGRlong *, IGRint, IGRchar *, IGRchar *, IGRint *, GRobjid, GRspacenum ));
				    
/*---HSsymbmac.I--------------------------------------------------------*/

extern void HSinit_grsymb_id __(( void ));
extern void HSset_symb_id    __(( GRobjid, GRspacenum ));
extern void HSreset_symb_id  __(( GRspacenum osnum ));
extern IGRint HSaddsymbentry __(( IGRlong *, IGRchar *, IGRint *, GRobjid, GRspacenum ));
extern IGRint HScresymbentry __(( IGRlong *, IGRchar *, IGRint *, GRobjid, GRspacenum ));				    
extern IGRint HSretsymbentry __(( IGRlong *, IGRint, IGRchar *, GRobjid, GRspacenum ));
extern IGRint HSdelsymbentry __(( IGRlong *, IGRint, GRobjid, GRspacenum ));
extern IGRint HSchgsymbentry __(( IGRlong *, IGRint, IGRchar *, IGRint *, GRobjid, GRspacenum ));
extern IGRint HSget_grsymb_id __(( GRobjid, GRspacenum, GRobjid *));
				       
/*---HSsymbutil.C---------------------------------------------------------------*/

extern IGRint HSsymb_update_ptr __(( IGRlong *, GRspacenum, IGRchar *));
extern IGRint HSget_symb        __(( IGRlong *, GRspacenum, IGRint, struct HS_symb_and_app *));

/*---HStex_func.C---------------------------------------------------------------*/

extern void HSrm_tex_file __(( IGRchar *, struct offset_ref_ct *, unsigned short, IGRint *, unsigned short ));

/*---HStex_mac.I----------------------------------------------------------------*/

extern void   HSinit_texture_objid   __(( void ));
extern void   HSset_texture_objid    __(( GRspacenum, GRobjid ));
extern void   HSreset_texture_objid  __(( GRspacenum ));
extern IGRint HSadd_texture_filename __(( IGRchar *, IGRint, unsigned short *, GRobjid, GRspacenum ));
extern int    HSget_object_id        __(( GRobjid, GRspacenum, GRobjid *, GRspacenum *));
extern IGRint HSadd_texture_ref_ct   __(( unsigned short, GRobjid, GRspacenum ));
extern void   HSrev_texture_file     __(( IGRchar *, IGRint *, IGRint, GRobjid, GRspacenum ));
extern IGRint HSdel_texture_file     __(( unsigned short, GRobjid, GRspacenum ));
extern IGRint HSinq_texture_file     __(( IGRchar *, IGRint *, GRobjid, GRspacenum ));
extern IGRint HSret_texture_file     __(( unsigned short, IGRchar *, GRobjid, GRspacenum ));
extern void   HSchg_texture_entry    __(( unsigned short, unsigned short, GRobjid, GRspacenum ));
extern IGRint HStex_validate_index   __(( unsigned short, IGRint *, GRobjid, GRspacenum ));

#if defined(__cplusplus)
}
#endif


#undef __
