#ifndef MEM_PROTO_H
#define MEM_PROTO_H

#if defined(__STDC__) || defined(__cplusplus)
# define __MEM(s) s
#else
# define __MEM(s) ()
#endif


/* MEMappend.c */
extern long MEMappend __MEM((MEMptr list1, MEMptr list2));

/* MEMbuf_size.c */
extern long MEMbuffer_size __MEM((MEMptr list, int *buf_size));

/* MEMbuild.c */
extern long MEMbuild_array __MEM((MEMptr list));

/* MEMbuild_st.c */
extern long MEMbuild_struct __MEM((char *buffer, MEMptr *list));

/* MEMcheck.c */
extern long MEMcheck_free_space __MEM((MEMptr list, long delta));

/* MEMclose.c */
extern long MEMclose __MEM((MEMptr *list));

/* MEMcol_ptr.c */
extern long MEMcolumn_list __MEM((MEMptr list, long offset));

/* MEMcopy_row.c */
extern int MEMcopy_row __MEM((MEMptr list1, MEMptr *list2, long row_no));

/* MEMdata_ptr.c */
extern long MEMdata_list __MEM((MEMptr list, long offset));

/* MEMfor_ptr.c */
extern long MEMformat_list __MEM((MEMptr list, long offset));

/* MEMformat.c */
extern long MEMwrite_format __MEM((MEMptr list, char *column_name, char *format));

/* MEMload.c */
extern long MEMload_structure __MEM((MEMptr list, long offset));

/* MEMno_buf.c */
extern long MEMno_buffers __MEM((MEMptr list, int *no_buffers));

/* MEMno_cols.c */
extern long MEMno_columns __MEM((MEMptr list, long offset));

/* MEMno_rows.c */
extern long MEMno_rows __MEM((MEMptr list, long offset));

/* MEMopen.c */
extern long MEMopen __MEM((MEMptr *list, long size));

/* MEMprint.c */
extern int MEMprint_buffer __MEM((char *name, MEMptr list, char *file));
extern int MEMprint_buffers __MEM((char *name, MEMptr list, char *file));
extern int MEMprint_array __MEM((char *name, MEMptr list, char *file));
extern int MEMprint_buffer_ptr __MEM((char *name, char *buffer_ptr, char *file));

/* MEMqlu_bld.c */
extern long MEMqlu_build_array __MEM((MEMptr list));
extern long MEMqlu_load_structure __MEM((MEMptr list, long offset));

/* MEMreset.c */
extern long MEMreset_buffer __MEM((MEMptr list, int *current_mem_buf));

/* MEMreset_no.c */
extern long MEMreset_buffer_no __MEM((MEMptr list, long no));

/* MEMrow_size.c */
extern long MEMrow_size __MEM((MEMptr list, long offset));

/* MEMshmem.c */
extern int MEMread_shm_buffer __MEM((char *NFMshmid, MEMptr *bufr));

/* MEMsplit.c */
extern long MEMsplit_copy_buffer __MEM((MEMptr list, MEMptr *list1, long type));

/* MEMwr_data.c */
extern long MEMwrite_data __MEM((MEMptr list, char *buffer, long row_no, long col_no));

/* MEMwrite.c */
extern long MEMwrite __MEM((MEMptr list, char *buffer));

#undef __MEM

#endif
