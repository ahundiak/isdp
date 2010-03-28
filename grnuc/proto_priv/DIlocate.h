#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/IGRdir/src/DIlocate.I */
extern int DIlocate __((DIchar *regexp, DIint (*function )(), DIchar *arg));
extern int DImount_ref __((DIspacenum attach_os, DIchar *logical, DIspacenum osnum, DIgrid context));

#if defined(__cplusplus)
}
#endif


#undef __
