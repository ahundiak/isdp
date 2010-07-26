#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/assoc/macro/ACsym_util.I */
extern int copy_graphics __((struct GRid macro, struct GRid dest_id, struct GRmd_env *cont1));

#if defined(__cplusplus)
}
#endif


#undef __
