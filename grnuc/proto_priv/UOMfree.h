#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/grio/uom/UOMfree.C */
extern int UOM_free_type __((UOM_TYPE **type));
extern int UOM_free_variant __((UOM_VARIANT **variant));
extern int UOM_free_alias __((char ***alias));

#if defined(__cplusplus)
}
#endif


#undef __
