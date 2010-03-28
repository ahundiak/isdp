#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/fontbuilder/fconv/FS_src/FSaccess.c */
extern void FSinitRecState __((int chan));
extern int FSsaveRecState __((int chan));
extern int FSrestoreRecState __((int chan));
extern int FSget_rec __((int n, unsigned short **pprec, unsigned short *pdata_origin, short *ptype, int *px, int *py, int *pbeta, int *num_recs));
extern int FSput_rec __((unsigned int n, unsigned short **pprec, unsigned short *pdata_origin, FF_outl_recs **outl_rec, int *num_recs));
extern int FSis_c_zone __((unsigned short **pprec, unsigned short *pfrom, unsigned short *pto, unsigned short *pplc, unsigned short *pmin, unsigned short *pfsize, int *num_recs));
extern int FSis_c_p_item __((unsigned short **pprec, unsigned short *pchar_no, unsigned short *pdim, unsigned short *pzone_no, int *num_recs));
extern int FSis_c_f_item __((unsigned short **pprec, unsigned short *pchar_no, unsigned short *pdim, unsigned short *pzone_no, int *num_recs));
extern int FSis_c_t_item __((unsigned short **pprec, unsigned short *pchar_no, unsigned short *pdim, unsigned short *pzone_no, int *num_recs));
extern int FSis_c_const_item __((unsigned short **pprec, int *pmantissa, int *pexponent, int *num_recs));
extern int FSis_c_op_item __((unsigned short **pprec, unsigned short *pop_code, unsigned short *plast_item, int *num_recs));
extern int FSinit_acc __((void));
extern int FSacc_digit __((unsigned int digit));
extern int FSnext_step __((unsigned short **pprec, unsigned short *pdata_origin, int n, int word_count));

#if defined(__cplusplus)
}
#endif


#undef __
