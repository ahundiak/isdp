#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/locate/locate/LCgsadd.C */
extern int LCadd_sav __((struct GRid gs_id, struct GRid sv_id, struct GRlc_info *new_entry));

#if defined(__cplusplus)
}
#endif


#undef __
