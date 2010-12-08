#ifndef PDMS_MULF_RO_H
#define PDMS_MULF_RO_H

#if defined(__STDC__) || defined(__cplusplus)
#ifndef __PDMS
#define __PDMS(args) args
#endif
#else
#ifndef __PDMS
#define __PDMS(args) ()
#endif
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./mulfile/PDMadd_del.c */
extern int PDMdelete_files_from_part __PDMS((MEMptr data_list));

/* ./mulfile/PDMnew_part.c */
extern int  PDMprepare_file_info     __PDMS((MEMptr *fileattr_list));
extern int  PDMadd_file_bufr         __PDMS((MEMptr *fileattr_list));
extern long PDMtranslate_item_flag   __PDMS((char *catalog, char *partnum, char *revision));
extern long PDM20modify_part         __PDMS((MEMptr attr_list, MEMptr data_list, MEMptr filedata_list, MEMptr filelist_list));

#if defined(__cplusplus)
}
#endif

#endif
