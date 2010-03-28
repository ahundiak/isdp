#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/transgo/GUcreatevw.I */
extern void GUcreate_views __((IGRchar *ele_buf, IGRint *db_type, IGRdouble *scale_factor));

#if defined(__cplusplus)
}
#endif


#undef __
