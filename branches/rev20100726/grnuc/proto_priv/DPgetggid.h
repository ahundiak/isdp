#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/display/grdisplay/DPgetggid.I */
extern IGRint DPgetggid __((IGRlong *msg, struct GRid *mod_grid, IGRchar *name, IGRint array_size, IGRint *total_num, IGRint *numid, struct GRid *gg_id, IGRint type_gragad, IGRchar *search_priority));
extern int GRmatch __((char *str1, char *str2));

#if defined(__cplusplus)
}
#endif


#undef __
