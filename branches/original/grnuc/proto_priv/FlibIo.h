#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/fontbuilder/fconv/Flib_src/FlibIo.c */
extern int Flib_read_lib_header __((struct library_header *flib_header, int rec_size, int num_recs, FILE *f_ptr, int offset));
extern int Flib_print_lib_header __((struct library_header *flib_header));
extern int Flib_read_font_header __((struct font_header *fontheader, int rec_size, int num_recs, FILE *f_ptr, int offset));
extern int Flib_print_font_header __((struct font_header *fontheader));
extern int Flib_open_lib __((Typepath flib_file));
extern int Flib_load_font __((Typepath flib_file, int flib_font_num));
extern int Flib_check_font_num __((Typepath flib_file, int font_num));
extern int Flib_read_nxt_blk __((char *char_buff, int *next_offset, int blk_size, int wrd_size, int num_blks, FILE *f_ptr));
extern int Flib_realloc_outlrecs __((FF_outl_recs **vect_elements, FF_outl_recs **buff_ptr, FF_outl_recs **vect_head, FF_outl_recs **vect_ptr, FF_outl_recs **end_rec, int blk_size, int num_blks));

#if defined(__cplusplus)
}
#endif


#undef __
