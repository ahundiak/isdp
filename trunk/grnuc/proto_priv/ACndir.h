#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/assoc/nmacro/ACndir.I */
extern int DIadd_dir __((DIspacenum osnum, DIobjid objid, DIchar *name, DIint add));
extern int DIunlink_dir __((DIchar *name, DIint remove));

#if defined(__cplusplus)
}
#endif


#undef __
