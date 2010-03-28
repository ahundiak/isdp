#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./src/fontbuilder/fconv/FS_src/FSio.c */
extern int FS_load_typeface __((Typepath typeface_name, FF_outl_str *comp_font));
extern int FS_get_name __((Typepath typeface_file, short *typeface_name));
extern int FS_get_names __((GGitem_list *typefaces, int num_typefaces, GGitem_list **typeface_names, Typepath typeface_path));
extern int FSgetCharDirs __((Typepath typeface_name, cft_chardir_rec **chdir_buff, unsigned short *num_chdirs, unsigned short *end_index, unsigned short *orus_em));
extern int FSputCharDirWidths __((Typepath typeface_name, cft_chardir_rec *chdir_buff, unsigned short *num_chdirs, unsigned int end_index));
extern int FSgetKernPairs __((Typepath typeface_name, cft_kern_pair_rec **knpr_dat, unsigned short *num_pairs, unsigned short *oru_em));
extern int FSputKernPairs __((Typepath typeface_name, cft_kern_pair_rec *knpr_dat1, unsigned int num_pairs, int merge));
extern void FSmergeKerns __((cft_kern_pair_rec *knpr_dat1, unsigned int num_pairs1, cft_kern_pair_rec *knpr_dat2, unsigned int num_pairs2, cft_kern_pair_rec *knpr_dat3, unsigned int num_pairs3, unsigned short *num_changes));
extern void FScompairChangeKerns __((cft_kern_pair_rec *knpr_dat1, unsigned int num_pairs1, cft_kern_pair_rec *knpr_dat2, unsigned int num_pairs2, unsigned short *num_match_change, int *comp_chg_flag));
extern void FS_match_pair __((cft_kern_pair_rec *knpr_ptr1, cft_kern_pair_rec *knpr_dat2, cft_kern_pair_rec **knpr_ptr2, cft_kern_pair_rec *endpr2));
extern int FSgetKernTracks __((Typepath typeface_name, cft_trk_kern_rec **kntrk_dat, unsigned short *num_recs, unsigned short *num_tracks, unsigned short *oru_em));
extern int FSputKernTracks __((Typepath typeface_name, cft_trk_kern_rec *kntrk_dat, unsigned int num_recs, unsigned int num_tracks));
extern int FS_write_block_header __((FILE *fd_font, int offset, cft_block_hdr *block_header));
extern int FS_print_block_header __((cft_block_hdr *block_header));
extern int FS_write_font_header __((FILE *fd_font, cft_block_hdr *finf_hd, cft_font_hdr *fonthead));
extern int FS_print_font_header __((cft_font_hdr *fonthead));
extern int FS_write_kern_prs __((FILE *fd_font, int offset, cft_block_hdr *knpr_hd, cft_kern_pair_rec *knpr_dat));
extern int FS_write_kern_trks __((FILE *fd_font, int offset, cft_block_hdr *kntrk_hd, cft_trk_kern_rec *kntrk_dat));
extern int FS_write_char_dirs __((FILE *fd_font, int offset, unsigned short *flag1, cft_block_hdr *chdir_hd, cft_chardir_rec *chdir_dat));
extern int FS_write_outl_data __((FILE *fd_font, int offset, cft_block_hdr *outl_hd, unsigned short *outl_dat, int num_bytes_outl));
extern int FS_read_block_header __((FILE *fd_font, int offset, cft_block_hdr *block_header));
extern int FS_read_font_header __((FILE *fd_font, cft_block_hdr *finf_hd, cft_font_hdr *fonthead));
extern int FS_read_kern_prs __((FILE *fd_font, int offset, cft_block_hdr *knpr_hd, cft_kern_pair_rec **knpr_dat));
extern int FS_read_kern_trks __((FILE *fd_font, int offset, cft_block_hdr *kntrk_hd, cft_trk_kern_rec **kntrk_dat));
extern int FS_read_char_dirs __((FILE *fd_font, int offset, unsigned short *layout_size, unsigned int flag1, cft_block_hdr *chdir_hd, cft_chardir_rec **chdir_dat));
extern int FS_read_outl_data __((FILE *fd_font, int offset, cft_block_hdr *outl_hd, unsigned short **outl_dat, int *num_bytes_outl));
extern int FS_check_Font __((Typepath typeface_name));
extern int FScheck_format __((char *string));

#if defined(__cplusplus)
}
#endif


#undef __
