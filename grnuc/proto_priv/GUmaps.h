#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/transgo/GUmaps.C */
extern IGRlong GUmapclass_to_igds __((IGRchar *classname, IGRint *ele_type));

#if defined(__cplusplus)
}
#endif


#undef __
