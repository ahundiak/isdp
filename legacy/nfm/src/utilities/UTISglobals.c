#include "machine.h"
#include <stdio.h>
#include "MEMstruct.h"
#include "NFMstruct.h"
#include "NFMerrordef.h"
#include "UTIerrordef.h"
#include "UTIglobals.h"
#include "UTIdef.h"
#include "ERR.h"
#include "DEBUG.h"

#define   BUFFER_SIZE 1000

extern struct NFMglobal_st NFMglobal;

UTIset_globals( flag )
    char *flag;
{
    char *fname="UTIset_globals";
    long status;

    UTIarchive   = 100;
    UTIarchive_p = 150;
    UTIbackup    = 200;
    UTIbackup_p  = 250;
    UTIrestore   = 300;
    UTIrestore_p = 350;
    UTIdelete    = 400;
    ON_LINE	 = FALSE;
    OFF_LINE 	 = FALSE;
 
    UTIuser_id    = NFMglobal.NFMuserid;

    if( strcmp( flag, "A" ) == 0 )
    {
	UTI_UTILITY = strcpy( (char*) malloc (10), "ARCHIVE" );
	strcpy( UTI_PENDING_FLAGS[0], "IA" );
	strcpy( UTI_PENDING_FLAGS[1], "MA" );
	strcpy( UTI_PENDING_FLAGS[2], "SA" );
	strcpy( UTI_PENDING_FLAGS[3], "PA" );
    }
    else if( strcmp( flag, "B" ) == 0 )
    {
	UTI_UTILITY = strcpy( (char*) malloc (10), "BACKUP" );
	strcpy( UTI_PENDING_FLAGS[0], "IB" );
	strcpy( UTI_PENDING_FLAGS[1], "MB" );
	strcpy( UTI_PENDING_FLAGS[2], "SB" );
	strcpy( UTI_PENDING_FLAGS[3], "PB" );
    }
    else if( strcmp( flag, "D" ) == 0 )
    {
	UTI_UTILITY = strcpy( (char*) malloc (10), "DELETE" );
	strcpy( UTI_PENDING_FLAGS[0], "ID" );
	strcpy( UTI_PENDING_FLAGS[1], "MD" );
	strcpy( UTI_PENDING_FLAGS[2], "SD" );
	strcpy( UTI_PENDING_FLAGS[3], "PD" );
    }
    else if( strcmp( flag, "R" ) == 0 )
    {
	UTI_UTILITY = strcpy( (char*) malloc (10), "RESTORE" );
	strcpy( UTI_PENDING_FLAGS[0], "IR" );
	strcpy( UTI_PENDING_FLAGS[1], "MR" );
	strcpy( UTI_PENDING_FLAGS[2], "SR" );
	strcpy( UTI_PENDING_FLAGS[3], "PR" );
    }

    UTI_MTAPE    = 0;		/* Magnetice tape media */
    UTI_CTAPE    = 0;		/* Cartridge tape media */
    UTI_UTAPE    = 0;		/* Unix tape drive media */
    UTI_HDISK    = 0;		/* Hard disk media */
    UTI_ODISK    = 0;		/* Optical disk media */
    UTI_FDISK    = 0;     	/* Floppy disk media */
    UTI_JBOX     = 0;		/* Juke Box in configuration */
    UTI_CACHE	 = 0;           /* Caching File system */
    UTI_SS_ALLOCATED = 0;	/* Saveset allocated in database */
    UTI_GROUP_NO = 0;		/* Group number ( archive_no or retrieve_no) */
    UTI_CLIENT_SA = 0;		/* Storage number for default node storage 
				 * on client 
				 */
    UTI_RES_SA   = 3; 	 	/* Default storage area number for UTILITIES */
				/** This will be changed to 1-UTIL in 
				    get_reserved_sano **/

/*  Set up local nodename */
    UTI_WRK_NODE = (char*) malloc (30);
#if (defined(OS_SUNOS) || defined(OS_SOLARIS) || \
     defined(OS_SCO_UNIX) || defined(OS_HPUX))
    /* clh_vbyop replaced for ncl_lkp_prop for SUN/SCO/HP port - IGI */
    clh_vbyop( "TEMPLATE", "NODENAME", UTI_WRK_NODE , 25);
#else 
    ncl_lkp_prop( "TEMPLATE", "NODENAME", UTI_WRK_NODE );    
#endif
    UTIlowcase( UTI_WRK_NODE );

#if OS_UNIX
    UTI_OP_SYS = strcpy( (char*) malloc(5), "UNIX" );
#else 
    UTI_OP_SYS = strcpy( (char*) malloc(4), "VMS" );
#endif

/*  Get reserved storage area number
 */
    status = UTIget_reserved_sano();    /** Need this only if no Deleting **/
    if((flag[0] != 'D') && (status != UTI_S_SUCCESS))
    {
	_UTIdebug((fname, "No #-UTIL storage area on %s !!!\n", UTI_WRK_NODE));
	return(status);
    }

    return( UTI_S_SUCCESS );
}
