#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/detailco/COdtlfunc.I */
extern IGRint _ds_err_msg __((Form form, IGRint label, IGRchar *mess, IGRlong key));
extern IGRint _ds_upd_standards __((Form form));
extern IGRint _ds_upd_sheets __((Form form, struct ds_sheet *sht));
extern IGRint _ds_set_toggle __((Form form));
extern IGRint _ds_upd_toggle __((Form form, struct ds_standard *std, IGRint label));
extern IGRint _ds_upd_std_subform __((Form form, struct ds_standard *std, IGRint mode));
extern IGRint _ds_upd_sht_subform __((Form form, struct ds_sheet *sht, IGRint mode));
extern IGRint _ds_upd_button __((Form form, IGRint auto_fit, IGRint auto_active));

#if defined(__cplusplus)
}
#endif


#undef __
