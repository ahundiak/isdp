#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/dim/dim_utils/glob.I */
static init_dm_sizes __((void));
extern int DMinit_glob __((void));
extern IGRint DMmap_font __((OMuword osnum, IGRshort font_index));
extern int DMretrieve_font __((IGRint *msg, OMuword osnum, IGRuchar *font_name, IGRshort *font_num));

#if defined(__cplusplus)
}
#endif


#undef __
