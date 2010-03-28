#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/assoc/macro/ACfunct.I */
extern int ACmagic_read __((OM_S_OBJID my_id, OM_S_CHANSELECT *xchan, struct GRid *list, int cnt));
extern int ACread __((struct GRid mygrid, OM_S_CHANSELECT *xchan, struct GRid *list, int cnt));

#if defined(__cplusplus)
}
#endif


#undef __
