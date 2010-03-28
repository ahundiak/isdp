#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/grio/units/GRaddals.I */
extern int alias_compare __((struct GRIOalias_entry *alias1, struct GRIOalias_entry *alias2));

#if defined(__cplusplus)
}
#endif


#undef __
