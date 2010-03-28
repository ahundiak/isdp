#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/partgo/GRprtname.I */
extern IGRint GRis_part_name __((IGRchar *name));
extern IGRint GRget_part_name __((struct GRid *p_grid, IGRchar *name, IGRint synonym));

#if defined(__cplusplus)
}
#endif


#undef __
