#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/assoc/macro/ACcpx_loc.I */
extern int ACSget_cmp_leave __((IGRshort w_os, IGRint ind_cmp, IGRint *list_len, OM_S_OBJID **cmp_list, IGRint *nb_cmp));

#if defined(__cplusplus)
}
#endif


#undef __
