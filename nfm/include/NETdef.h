
/* defined UNIX commented as we have OS_UNIX made available with the machine.h
	MVR 27 Dec 1993 */
/*
#define UNIX   1
*/
/*
#define VMS    1
*/

#define NFM_XNS_PORT           1500
#define NFM_TCP_PORT           1500
#define NFM_SERVER_PORT        1555

#define EXIT                   1001
#define REC_FAILED             1002
#define NET_FILE_SEND          1003
#define NET_FILE_RECEIVE       1004

#define NFM_SEND_FILES         1011
#define NFM_RECEIVE_FILES      1012
#define NFM_COPY_FILE          1013
#define NFM_DELETE_IN_FILES    1014
#define NFM_DELETE_OUT_FILES   1015
#define NFM_BULK_LOAD          1016
#define NFM_FILE_SEND          1017
#define NFM_FILE_RECEIVE       1018
#define NFM_FILE_COPY          1019

/* New cases */

#define NFM_DEST_RECEIVE_FILES 1020
#define NFM_SRC_SEND_FILES     1021
#define NFM_RM_CO_FILES        1022
#define NFM_RM_CI_FILES        1023
#define NFM_RENAME_FILES       1024
#define NFM_UNDO_RENAME_FILES  1025
#define NFM_GET_MICRO_FILES    1026
#define NFM_MOUNT_JUKEBOX      1027
#define NFM_UMOUNT_JUKEBOX     1028
#define NFM_DEST_PLOT_FILES    1029
#define NFM_NFS_CLEANUP	       1030
#define NFM_GET_ACAD_FILES     1031
#define NFM_DO_NOTHING         1032

/* New Cases for FTR Options file */
#define NFM_FTR_OPTIONS_FILE_SEND       1050
#define NFM_FTR_OPTIONS_FILE_RESET      1051
#define NFM_FTR_NO_OP_LOCK              1052


/* machine ID */

#define TLI_MC                 1
#define FMU_MC                 2
#define FTP_MC                 3
#define TLI_MC_CONN_LESS       4

