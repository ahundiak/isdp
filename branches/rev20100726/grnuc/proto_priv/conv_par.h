#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/dim/dim_conv/conv_par.I */
extern IGRint DMconv_gpar __((IGRint *msg, struct DMdat_environ *dat_environ, struct DMdat_local *dat_local, struct DMenv_param *par_env, struct DMloc_param *par_loc, struct DMmisc_param *par_misc));
extern IGRint DMdim_stan __((char stan[], unsigned int unit));
extern IGRint DMdecacc __((unsigned int acc));
extern IGRint DMfraacc __((unsigned int acc));
extern IGRint DMconv_lpar __((IGRint *msg, struct DMdat_elem *dat_elem, struct DMdat_cmpx *dat_cmpx, struct IGRestx *text_attr, IGRint version, struct DMenv_param *par_env, struct DMloc_param *par_loc, struct DMmisc_param *par_misc));
extern IGRint DMsplit_cmpx __((IGRint version, struct DMdat_cmpx *p_dat_cmpx, struct DMdat_environ *p_env_para, struct DMdat_local *p_loc_para));
extern IGRint DMsplit_elem __((IGRint version, struct DMdat_elem *p_dat_elem, struct DMdat_environ *p_env_para, struct DMdat_local *p_loc_para));
extern IGRint DMconv_13 __((OM_S_OBJID super_id, OMuword super_os));
extern IGRint DMcreate_dim_param __((IGRint *msg, IGRboolean global, OM_S_OBJID super_id, OMuword super_os, struct GRmd_env *md_env, struct DMenv_param *par_env, struct DMloc_param *par_loc, struct DMmisc_param *par_misc, struct DMsenv_param *par_senv, struct GRid list[4 ]));
extern IGRint DMconv_tole __((IGRint type, IGRint leading, unsigned char *tole_old, unsigned char *tole_new));

#if defined(__cplusplus)
}
#endif


#undef __
