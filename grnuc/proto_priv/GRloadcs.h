#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/go/gosup/GRloadcs.c */
extern IGRint GRloadcs __((IGRlong *msg, IGRchar *csname, IGRchar *field1, IGRchar *field2, IGRchar *field3, IGRchar *coor1, IGRchar *coor2, IGRchar *coor3, IGRint label1, IGRint label2, IGRint label3, IGRint label4, IGRint label5, IGRint label6, IGRint label7, struct FI_data_st *subform_list));

#if defined(__cplusplus)
}
#endif


#undef __
