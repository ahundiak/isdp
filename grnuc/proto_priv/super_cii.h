#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/pplsrc/src/super_cii.I */
extern int SCIinit __((void));
extern void SCIdelete_object __((GRobjid objid));
extern void SCIconstruct __((void));
extern unsigned short SCIhash __((char *file_name));
extern unsigned short SCIsearch_file __((char *file_name));
extern unsigned short SCIstore_file __((char *file_name, unsigned int object));
extern void SCIclear_file __((char *file_name));
extern int SCIstore_object __((unsigned int file_entry, char *file_name, GRobjid objid, time_t mtime));
extern void SCIclear_object __((unsigned short *head, GRobjid objid));
extern int SCIload __((char *file_name, OM_S_OBJID *objid, int mode, OM_S_OBJID sender_id, OMuword sender_os));
extern int SCIdelete __((char *file_name, GRobjid objid));
extern int SCIinq_files __((int *count, char **names));
extern int SCIinq_objects __((char *f_name, int *count, OM_S_OBJID *objects));
extern int SCIbroadcast __((char *entry, int argc, CIpushlist *argv));

#if defined(__cplusplus)
}
#endif


#undef __
