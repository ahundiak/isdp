#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/displayco/DPvw_var.I */
extern IGRint DPassign_var __((struct DPbase_gg_t **base_pp, struct DPview_wrk_t **wrk_pp, struct DPpyramid_t **pyrmd_pp));
extern IGRint DPprepare_vw_form __((void));
extern int DPerase_vw_form __((void));
extern IGRint DPinit_vw_cmd __((struct DPview_wrk_t *wrk_p, struct DPpyramid_t *pyrmd_p));

#if defined(__cplusplus)
}
#endif


#undef __
