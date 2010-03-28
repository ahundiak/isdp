#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/dim/csrc_130/DMparam.I */
extern int DMget_dat_environ __((struct DMdat_environ *p_dat_environ));
extern int DMget_dat_local __((struct DMdat_local *p_dat_local));
extern int DMget_dat_fields __((struct DMdat_fields *p_dat_fields));

#if defined(__cplusplus)
}
#endif


#undef __
