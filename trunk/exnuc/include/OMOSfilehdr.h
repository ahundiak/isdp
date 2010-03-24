/*
-------------------------------------------------------------------------------

	Name:			OMOSfilehdr.h
	Author:			Chuck Puckett
	Creation Date:		14-nov-1985
	Operating System(s):	Unix SYSV, v2
	Abstract:

	 OM Object Space File headers.

	Revision History:

cgp001	6-10-86	OM4.0	Massive changes, mainly moving stuff to OSO.

saw001	6-88	OM4.5	Storing more system data in header.
-------------------------------------------------------------------------------
*/

#ifndef	OM_D_OMOSFILEHDR
#define	OM_D_OMOSFILEHDR	1

#ifndef	OM_D_MINIMUM
#include 	"OMminimum.h"
#endif
#ifndef	OM_D_LIMITS
#include	"OMlimits.h"
#endif

#define OM_K_APPVER_LEN    32     /* Max len of application version stamp  */
                                  /* 8 bytes Appl id (blank filled)        */
                                  /* up to 24 bytes version id (null term) */
#define OM_K_APPVER_ID_LEN 8      /* length of appl id field (blank filled)*/
#define OM_K_APPVER_BOUND  512    /* blocking size for appvers in file     */

#define OM_K_MAGIC         0x4d4f /* Spells 'OM' in ascii  :) */

struct OM_sd_OS_filehdr_OM
{
   short       magic;
   OMuword     w_major_version;     /* version of OM that wrote the file */
   OMuword     w_minor_version;
   OMuword     w_num_clusters;
   OMuint      i_size;              /* Byte size of file */    /* 8 */
   OMuint      checksum;            /* File checksum (doesn't include hdr) */
   OMuint      i_num_objs;          /* Number of objs written */
   OMuint      fp_OSO;              /* File loc of OSO object */  /* 20 */
   OMuint      fp_Cluster_instance; /* File loc of OSO Cluster component */
   OMuint      fp_OSO_instance;     /* File loc of OSO FiledOS component */
   OMuint      fp_cluster0;         /* File loc of Cluster 0 */   /* 32 */
   OMuint      i_spacemap_size;     /* Entries in spacemap when file written */
   OMuint      fp_appver;           /* Application version stamps */
   OMuint      i_num_appver;
   OM_S_OBJID  S_OS_object;         /* OSO object id */
   char        s_OSO_classname[64]; /* OSO classname */              /* 52 */
   OMuword     OSOfiledClassid;     /* OSO filed class id */         /* 116 */
   char        unused[12];          /* Offset 118 */
   char        start_time[26];      /* Time last write began */      /* 130 */
   char        stop_time[26];       /* Time last write completed */  /* 156 */
   char        write_msgstr[64];    /* Write sts */                  /* 182 */
   union
   {
      char     A_utsname[100];      /* Uname data */
      struct
      {
         char  sysname[9];          /* "CLIX" */
         char  nodename[9];         /* Ethernet nodename */
         char  release[9];          /* Unix release number (3) */
         char  version[9];          /* Unix version number (2) */
         char  machine[9];          /* Processor type, e.g. "IP32C" */
         char  blank[55];
      } mach_name;
   } syst;
   char        A_unused[68];
   char        image_name[20];      /* EX_runname at write time */   /* 414 */
   char        dros_msgstr[70];     /* For use by dros editor */     /* 434 */
   int         os_flags;            /* Flags for use by applications */
   OMuint      hdr_checksum;        /* Excludes some fields */    /* 508 */
};
typedef	struct	OM_sd_OS_filehdr_OM	OM_S_OS_FILEHDR;
typedef	struct	OM_sd_OS_filehdr_OM	*OM_p_OS_FILEHDR;


struct OM_sd_fileObjHeader
{
   OMuint      tag;                 /* Tag id */
   OMuword     version;             /* Tag version */
   OMuword     classid;             /* Filed class id */
   OMuint      oid;                 /* Objid id */
   OMuint      i_size;              /* Object in-memory size + 3 flag bits */
};
typedef struct  OM_sd_fileObjHeader    OM_S_FILEOBJHDR;
typedef struct  OM_sd_fileObjHeader    *OM_p_FILEOBJHDR;


struct OM_sd_lockFileRec
{
   char        code;                /* 'R', 'F', 'r', 'M', 'W', or 'V' */
   char        osnum[6];
   char        pid[6];              /* 5-digit pid converted to ascii */
   char        node[9];             /* node name */
   char        timestamp[22];       /* from time() call.  Ends with \n */
};

struct OM_sd_lockFiles
{
   char                    *name;   /* Node of the linked list of lock */
   struct OM_sd_lockFiles  *next;   /* file names associated with an osnum */
};


/*--------------------------------------------------*
 *  define structure for system information
 *--------------------------------------------------*/

struct OM_sd_sysInfo {
   int   pageSize;      /* System page size in bytes */
#if defined (SYSV) || defined (BSD)
   char  nodename[64];
#elif defined (NT)
   char  nodename[15];
#else
#error OS does not support gethostname!!
#endif
   char  processor[9];  /* Processor type */
   char  sysname[9];    /* Operating system name */
   char  release[9];    /* O.S. release number */
   char  version[9];   /* O.S. revision number */
};

typedef struct OM_sd_sysInfo OM_S_SYSINFO;


#endif
