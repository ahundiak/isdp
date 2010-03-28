#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/assoc/nmacro_co/COm_crdef2.I */
extern int COm_find_type_from_text __((char *atext, int *type));

#if defined(__cplusplus)
}
#endif


#undef __
