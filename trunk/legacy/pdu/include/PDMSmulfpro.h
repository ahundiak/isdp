#ifndef PDM_PROTO_H
#define PDM_PROTO_H

#if defined(__STDC__) || defined(__cplusplus)
#ifndef __PDM
#define __PDM(args) args
#endif
#else
#ifndef __PDM
#define __PDM(args) ()
#endif
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./mulfile/PDMadd_del.c */
extern int PDMadd_files_to_part __PDM((PDMexec_ptr PDMexec));
extern int PDMdelete_files_from_part __PDM((MEMptr data_list));

/* ./mulfile/PDMnew_part.c */
extern int PDMprepare_file_info __PDM((MEMptr *fileattr_list));
extern int PDMadd_file_bufr __PDM((MEMptr *fileattr_list));
extern int PDMtranslate_item_flag __PDM((char *catalog, char *partnum, char *revision));

#if defined(__cplusplus)
}
#endif

#if defined(__STDC__) || defined(__cplusplus)
#ifndef __PDM
#define __PDM(args) args
#endif
#else
#ifndef __PDM
#define __PDM(args) ()
#endif
#endif

#endif
