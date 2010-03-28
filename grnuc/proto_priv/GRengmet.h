#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/grio/units/GRengmet.C */
extern int GRunit_database_type __((OMuword osnum, IGRint *eng_met));

#if defined(__cplusplus)
}
#endif


#undef __
