#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/fontbuilder/flib/list.c */
extern int list_flib __((void));
extern int list_header __((void));
extern void get_month __((int month_in, char month_out[4 ]));
extern void list_brief __((void));
extern bool list_full __((long blk_fh, long byt_fh));
extern void put_alphanum __((short alphanum_tbl[][2 ], short *num_alphanum, bool *new_alphanum, int chr_code));
extern void put_other __((short other_tbl[][2 ], short *num_other, bool *new_other, int chr_code));
extern void put_puntc __((short puntc_tbl[][2 ], short *num_puntc, bool *new_puntc, int chr_code));
extern void print_alphanum __((short alphanum_tbl[26 ][2 ], int num_alphanum));
extern void print_other __((short other_tbl[80 ][2 ], int num_other));
extern void print_puntc __((short puntc_tbl[17 ][2 ], int num_puntc));
extern bool init_name_tbl __((name_record name_tbl[], short *num_names));
extern bool get_name __((int font_num, int num_names, name_record name_tbl[], char name_font[]));

#if defined(__cplusplus)
}
#endif


#undef __
