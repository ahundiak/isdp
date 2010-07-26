#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/co/displayco/COaxlocks1i.I */
extern IGRint DPprojview_cpl __((struct DPvwinfo *info, struct EX_button *pnt2, IGRdouble mtx[16 ], struct GRid **objects, IGRint *num_objects, struct DPele_header **buffers, IGRint *num_buffers, IGRchar *in_flags1, IGRchar *in_dum2, IGRchar *in_dum3, IGRint *out_flags1, IGRchar *out_dum2, struct DPele_header **out_dum3));
extern int project_evntgenpnt __((struct DPvwinfo *info, struct EX_button *pnt2));
extern int set_for_view __((IGRint os1, OM_S_OBJID win1, struct DPvwinfo *info, IGRdouble wrld_view[4 ][4 ], IGRdouble view_wrld[4 ][4 ]));
extern int set_for_cpl __((IGRint os1, OM_S_OBJID win1, struct DPvwinfo *info, IGRdouble cnstr_plane[4 ][4 ]));
extern int inq_gflags __((IGRint os1, OM_S_OBJID win1, IGRint *g_flags));
extern int build_lines __((struct DPvwinfo *info, IGRdouble proj_mat[4 ][4 ], IGRdouble *point11, IGRdouble *point12, IGRdouble *point21, IGRdouble *point22));
extern IGRint DPdbprojn __((struct DPprojs_info *info, struct EX_button *pnt2, IGRdouble mtx[16 ], struct GRid **objects, IGRint *num_objects, struct DPele_header **buffers, IGRint *num_buffers, IGRchar *in_flags1, IGRchar *in_dum2, IGRchar *in_dum3, IGRint *out_flags1, IGRchar *out_dum2, struct DPele_header **out_dum3));
extern int project_evntpnt __((struct DPprojs_info *info, struct EX_button *pnt2));

#if defined(__cplusplus)
}
#endif


#undef __
