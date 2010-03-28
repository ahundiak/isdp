#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/fontbuilder/flib/io.c */
extern int read_fot __((FILE *fcb, short *ft_first, short *ft_last, long *blk_fot, long *byt_fot, long fnt_off_tbl[], long *next_fot, short flib_buf[]));
extern void init_fot_tbl __((int fnt_off_tbl[], int ft_first, int ft_last));
extern int read_fh __((FILE *fcb, int ft_first, int num_font, long *blk_fh, long *byt_fh, long blk_fot, long byt_fot, long fnt_off_tbl[], short flib_buf[]));
extern int read_cdt __((FILE *fcb, long *blk_cdt, long *byt_cdt, long *next_cdt, long *next_ccot, int fnt_type, int num_dim, short flib_buf[]));
extern int readblk __((FILE *fcb, long vbn, long siz, short buf[4096 ]));
extern int writeblk __((FILE *fcb, long vbn, long siz, short buf[]));
extern int wrt_to_flib __((FILE *fcb, short inbuf[], long num_byt, bool flush_buf, long blk_num));
extern int fst_vec __((FILE *stroke_cb, short str_buf[], long *amt_used, long *str_vbn, unsigned long *str_ind, long str_siz));
extern int next_vec __((FILE *stroke_cb, short str_buf[], int chr_num, long *amt_used, long *str_vbn, unsigned long *str_ind, long str_siz));
extern int align_cdt __((short *buf_ptr));
extern int align_fh __((short *buf_ptr));
extern int align_fot __((short buf_ptr[]));
extern int align_lh __((short *buf_ptr));
extern int ualign_cdt __((short *buf_ptr, long numbytes));
extern int ualign_cdt_n __((short *buf_ptr, long numbytes));
extern int ualign_fh __((short *buf_ptr));
extern int ualign_fh_n __((short *buf_ptr));
extern int ualign_fot __((short buf_ptr[]));
extern int ualign_lh __((short *buf_ptr));

#if defined(__cplusplus)
}
#endif


#undef __
