#define FIO_NORMAL		0x00000000
#define FIO_NO_FILE_OPEN	0x00000100
#define FIO_NO_FILE_TO_OPEN	0x00000101
#define FIO_FOPEN_ERROR		0x00000102
#define FIO_ABORT		0x00000103

#if defined(__STDC__) || defined(__cplusplus)
#ifndef __
#define __(args) args
#endif
#else
#ifndef __
#define __(args) ()
#endif
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./om/opp/cpp/fio.c */
void file_traceback __((void));
void fio_push_rec __((int *item));
void fio_get_rec __((int **item));
void fio_getc __((struct char_data *c));
void fio_ungetc __((struct char_data c));
void fio_open_string __((char *s));
void fio_open __((char *filename));
void fio_set_line_no __((int line, char *filename));
void fio_close __((void));
int fio_activate __((void));
int fio_deactivate __((void));

#if defined(__cplusplus)
}
#endif
