#ifndef NFMfto_buf_H_
#define NFMfto_buf_H_

#ifndef   NFM_SCHEMA_H
#include "NFMschema.h"
#endif

/* INDEXES into File Transfer Operation Buffer */
#define FTO_SANO	0
#define FTO_NODENAME	1
#define FTO_USERNAME	2
#define FTO_PASSWD	3
#define FTO_PATHNAME	4
#define FTO_DEVICETYPE	5
#define FTO_PLATTERNAME	6
#define FTO_PARTITION	7
#define FTO_NFS		8
#define FTO_MOUNTPOINT	9
#define FTO_COMPRESS	10
#define FTO_MACHID	11
#define FTO_OPSYS	12
#define FTO_TCPIP	13
#define FTO_XNS		14
#define FTO_DECNET	15
#define FTO_NETWARE	16
#define FTO_FILENO	17
#define FTO_FILEOLD	18
#define FTO_CIFILENAME	19
#define FTO_COFILENAME	20
#define FTO_FILETYPE	21
#define FTO_CIFILESIZE	22
#define FTO_STATUS1	23
#define FTO_STATUS2	24
#define FTO_STATUS3	25
#define FTO_MAX_BUF	26   
#define FTO_CAT	        26   /*8/19/93 -mfb- added FTO_CAT, FTO_ITEMNO, and*/
#define FTO_ITEMNO      27   /*FTO_REV and FTO_ITEMNAME for DMM view services*/
#define FTO_REV         28
#define FTO_ITEMNAME    29
#define FTO_ITEMDESC    30
#define FTO_CATNO       31
#define DM_FTO_MAX_BUF	31   /*8/19/93 -mfb- DDE communication  for view
                               Services*/
#define DM_FTR_MAX_BUF	32   
#define FTO_MAX_LEN	128

typedef struct fto_buf {
			int  n_sano;
			char n_nodename[NFM_NODENAME+1];
			char n_username[NFM_USERNAME+1];
			char n_passwd[NFM_PASSWD+1];
			char n_pathname[NFM_PATHNAME+1];
			char n_devicetype[NFM_DEVICETYPE+1];
                        char n_plattername[NFM_PLATTERNAME+1];
			char n_partition[NFM_PARTITION+1];
			char n_nfs[NFM_NFS+1];
			char n_mountpoint[NFM_MOUNTPOINT+1];
			char n_compress[NFM_COMPRESS+1];
			char n_machid[NFM_MACHID+1];
			char n_opsys[NFM_OPSYS+1];
			char n_tcpip[NFM_TCPIP+1];
			char n_xns[NFM_XNS+1];
			char n_decnet[NFM_DECNET+1];
			char n_netware[NFM_NETWARE+1];
			int n_fileno;
			char n_fileold[NFM_CIFILENAME+1];
			char n_cifilename[NFM_CIFILENAME+1];
			char n_cofilename[NFM_COFILENAME+1];
			char n_filetype[NFM_FILETYPE+1];
			int  n_cifilesize;
			int  n_status1;
			int  n_status2;
			int  n_status3;
		} fto_buf;


/****************************************************************************/

		
#define NFM_MOVE                2030    /* Transfer file */
#define NFM_LFM_MOVE            2031    /* Transfer file after checking
                                          local non-existence */
#define NFM_MOVE_MOVE           2032    /* Move the previous CIFILENAME to
                                           n_fileold and then transfer file
                                           (checkin operation only) */
#define NFM_NFS_MOVE            2033    /* Provide file access using NFS
                                           Read only access */
#define NFM_LFM_NFS_MOVE        2034    /* Provide file access using NFS
                                           after checking local non-existence */

#define NFM_TRANSFERED          2035    /* File transfered */
#define NFM_NFSED               2036    /* File access facilitated thru nfs */
#define NFM_MOVE_TRANSFERED     2037    /* CIFILENAME moved to n_fileold and
                                           FILE Transfered */
#define NFM_MOVE_MOVE_WARNING   2038    /* Failed to move CIFILENAME to
                                           n_fileold , but File transfered */
#define NFM_READ_ONLY           2039    /* Change mode to READ ONLY */
#define NFM_UNDONE              2040    /* File transfer undone */
#define NFM_NFS_UNDONE          2041    /* NFS mount/link undone */
#define NFM_READ_DONE           2042    /* Change mode to READ ONLY DONE */
#define NFM_MOVE_MOVE_UNDONE    2043    /* Delete CIFILENAME and move n_fileold
                                          to CIFILENAME */
#define NFM_DELETE_FILE         2044    /* Delete files CO/CI */
#define NFM_RENAME              2045    /* Rename CIFILENAME to COFILENAME */
#define NFM_DESTINATION         2046    /* MOVE CIFILENAME from NFM_MOVE buffer
                                          to COFILENAME in NFM_DESTINATION */
#define NFM_PURGE_FILE          2047    /* Delete CIFILENAME */
#define NFM_REMOVED             2048    /* Files deleted */
#define NFM_PURGED              2049    /* Files purged */
#define NFM_RENAMED             2050    /* Files renamed */
#define NFM_NO_DELETE_FILE	2051    /* Do not delete files */
#define NFM_MOVE_FIRST_TIME	2052    /* Do not delete files */
#define NFM_COPY_LOCAL          2053    /* Copy CIFILENAME to COFILENAME */
#define NFM_COPIED              2054    /* Copied CIFILENAME to COFILENAME */
#define NFM_LFM_NFS_MOVE_NO_REMOVE 2055 /* Copy & Plot files using NFS after 
					   checking for local existance **/ 
#define NFM_LFM_NFS_NOT_REMOVED 2056	/* Files are plotted but not removed*/
#define NFM_NFS_MOVE_NO_REMOVE	2057	/* Copy & Plot files using NFS */
#define NFM_NFS_NOT_REMOVED	2058	/* Files are plotted but not removed*/ 
#define NFM_LFM_NFS_MOVE_REMOVE 2059 	/* Copy & Plot files, after checking for					   local existance and remove 	*/ 
#define NFM_LFM_NFS_REMOVED 	2060	/* Files are plotted and removed */
#define NFM_FTR_MT_PT_REMOVE	2061	/* Remove mountpoint after FTR indexing
					*/
#endif
