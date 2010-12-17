#include "machine.h"
#include <stdio.h>
#include "UTIerrordef.h"

/*  SERVER ERROR CODES	*/
#define UTIR_S_SUCCESS		1000
#define UTIR_E_FAILURE		 999
#define UTIR_E_DELSCR		1010
#define UTIR_E_WRTSCR		1020
#define UTIR_E_SETPRM		1060
#define UTIR_E_OPEN		1070
#define UTIR_E_NOFILES		1080
#define UTIR_E_UPDSAV		1150
#define UTIR_E_UPDARCHIVES	1160
#define UTIR_E_UPDCATALOG	1162
#define UTIR_E_UPDFCATALOG	1164
#define UTIR_E_UPDNFMCATALOGS	1166
#define UTIR_E_CONNECT		1170
#define UTIR_E_SEND		1180
#define UTIR_E_RECEIVE		1190
#define UTIR_E_DISCONNECT	1200
#define UTIR_E_ILLLABEL		1210
#define UTIR_E_DEVICE		1250
#define UTIR_E_QUERYNODE 	1260
#define UTIR_E_QUERYLS		1270
#define UTIR_E_FSINFO		1310
#define	UTIR_E_QUERYSA		1440
#define UTIR_E_QUERYATTRTAB	1450
#define UTIR_E_QUERYLABELS	1460
#define UTIR_E_QUERYCATALOGS	1470
#define UTIR_E_QUERYARCHIVES	1475
#define UTIR_E_FORK		1500
#define UTIR_E_EXEC		1520
#define UTIR_I_NO_FLAGGED_FILES  1600

/*  CLIENT ERROR CODES */
#define UTIR_E_INVALIDUSER	2020
#define UTIR_E_BADSCRIPT		2040
#define UTIR_E_OPENSCRIPT	2050
#define UTIR_E_EXESCRIPT		2060
#define UTIR_E_SCONNECT		2070
#define UTIR_E_SLOGIN		2080
#define UTIR_E_MEMBUILD		2090
#define UTIR_E_MEMOPEN		2100
#define UTIR_E_MEMWRITEDATA	2110
#define UTIR_E_MEMWRITE		2114
#define UTIR_E_MEMWRITEFORMAT	2112
#define UTIR_E_MEMSPLIT		2116
#define UTIR_E_MEMRESET		2118
#define UTIR_E_SENDBUFFER	2120
#define UTIR_E_RECEIVEBUFFER	2130
#define UTIR_E_NOTUPDATED	2140
#define UTIR_E_XFER_IN		2170
#define UTIR_E_XFER_OUT		2180
#define UTIR_E_XFER_DEL		2182
#define UTIR_E_XFER_SCR_IN	2190
#define UTIR_E_XFER_SCR_OUT	2200
#define UTIR_E_RESTORE_GROUP	2210

struct errorsstruct
{
    int number;
    char *text;
};

struct errorsstruct
errors[] =
{
  { UTIR_E_DELSCR,"NFM:   Unable To Delete File '#'" },
  { UTIR_E_WRTSCR,"NFM:  Unable To Write File '#'" },
  { UTIR_E_SETPRM,"NFM:  Unable To Set Permissions For File '#'"},
  { UTIR_E_NOFILES,"NFM:  No Filenames Written To File '#'" },
  { UTIR_E_ILLLABEL,"NFM:  Illegal Label Definition '#' For Label" },
  { UTIR_E_DEVICE, "NFM:  Illegal Device Type '#'" },
  { UTIR_E_UPDSAV,"NFM:  Error Updating NFMSAVESET Table" },
  { UTIR_E_UPDARCHIVES, "NFM:  Error Updating NFMARCHIVES Table " },
  { UTIR_E_UPDFCATALOG, "NFM:  Error Updating File Catalog Table for Item '#'" },
  { UTIR_E_UPDCATALOG, "NFM:  Error Updating '#' Table " },
  { UTIR_E_UPDNFMCATALOGS, "NFM:  Error Updating NFMCATALOGS Table for catalog '#'" },
  { UTIR_E_CONNECT, "NFM:  Error Connecting To Node '#' " },
  { UTIR_E_SEND, "NFM:  Error Sending File '#' " },
  { UTIR_E_RECEIVE, "NFM:  Error Receiving File '#'"},
  { UTIR_E_DISCONNECT, "NFM:  Error Disconnecting From Node" },
  { UTIR_S_SUCCESS,"NFM:  Successful Completion Of # Process" },
  { UTIR_E_QUERYLS,"NFM:  No Database Information For Given Label And Saveset" },
  { UTIR_E_FSINFO, "NFM:  No File Storage Information For File '#' " },
  { UTIR_E_INVALIDUSER, "NFM:  Invalid User Login"},
  { UTIR_E_BADSCRIPT, "NFM:  Script '#' Does Not Exist"},
  { UTIR_E_OPENSCRIPT, "NFM:  Cannot Open '#'"},
  { UTIR_E_EXESCRIPT, "NFM:  Cannot Execute '#'"},
  { UTIR_E_SCONNECT, "NFM:  Cannot Connect To NFMserver"},
  { UTIR_E_SLOGIN, "NFM:  Cannot Login To NFMserver"},
  { UTIR_E_MEMBUILD, "NFM:  Unsuccessful <MEMBUILD> Function Call"},
  { UTIR_E_MEMOPEN, "NFM:  Unsuccessful <MEMOPEN> Function Call"},
  { UTIR_E_MEMWRITEDATA,"NFM:  Unsuccessful <MEMWRITEDATA> Function Call"},
  { UTIR_E_MEMWRITE,"NFM:  Unsuccessful <MEMWRITE> Function Call"},
  { UTIR_E_MEMWRITEFORMAT,"NFM:  Unsuccessful <MEMWRITEFORMAT> Function Call"},
  { UTIR_E_MEMRESET, "NFM:  Unsuccessful <MEMRESET> Function Call"},
  { UTIR_E_MEMSPLIT, "NFM:  Unsuccessful <MEMSPLIT> Function Call"},
  { UTIR_E_SENDBUFFER,"NFM:  Unsuccessful <SENDBUFFER> to NFMserver"},
  { UTIR_E_RECEIVEBUFFER	, "NFM:  Unsuccessful <RECEIVEBUFFER> from NFMserver"},
  { UTIR_E_NOTUPDATED, "NFM:  NFMserver Database Not Updated"},
  { UTIR_E_QUERYSA, "NFM:  Unsuccessful NFMSTORAGEAREA Table Query" },
  { UTIR_E_QUERYARCHIVES, "NFM:  Unsuccessful NFMARCHIVES Table Query" },
  { UTIR_E_QUERYATTRTAB, "NFM:  Unsuccessful NFMATTRIBUTES Table Query"},
  { UTIR_E_QUERYLABELS, "NFM:  Unsuccessful NFMARCHIVES Table Query for Labels" },
  { UTIR_E_QUERYCATALOGS, "NFM:  Unsuccessful NFMCATALOGS Table Query"},
  { UTIR_E_QUERYNODE, "NFM:  Unsuccessful NFMNODES Table Query"},
  { UTIR_E_FORK, "NFM:  Unsuccessful FORK For '#' Command"},
  { UTIR_E_EXEC, "NFM:  Unsuccessful EXEC For '#' Command"},
  { UTIR_E_XFER_IN, "NFM:  Unsuccessful File Transfer To Storage Node"},
  { UTIR_E_XFER_OUT,"NFM:  Unsuccessful File Transfer From Storage Node"},
  { UTIR_E_XFER_DEL,"NFM:  Unsuccessful File Deletion From Storage Node"},
  { UTIR_E_XFER_SCR_IN, "NFM:  Unsuccessful Script Transfer To Storage Node"},
  { UTIR_E_XFER_SCR_OUT, "NFM:  Unsuccessful Script Transfer From Storage Node"},
  { UTIR_E_RESTORE_GROUP, "NFM:  Unsuccessful Restore for Group '#'"},  
  { 0,	NULL }
};

UTIerror( errtype, ptr )
    int  errtype;
    char *ptr;
{
    int  i;
    int  j;
    int  errno;

    char ch;
    char *errmess;
    char UTIbig_msg[256];

    memset( UTIbig_msg, NULL, 256 );

    if( errtype < 0 )
    {
	strcpy( UTIbig_msg, ptr );
    	return;
    }	
    for( errno=0; errors[errno].number!=0; ++errno )
	if( errors[errno].number == errtype )
	    break;

    if( errors[errno].number == 0 )
    {
	SCdisplay_msg( "NFM:  Unknown Error." );
	sleep( 3 );
	return;
    }
    errmess = errors[errno].text;
    j = 0; 

    for( i=0; (ch = *(errmess+i))!=0; ++i )
    {
	if( ch != '#' )
	{
	    UTIbig_msg[j] = ch;
	    ++j;
 	}
	else
	{
	    strcat( UTIbig_msg, ptr );
	    j += strlen( ptr );
	} 	    
    }
    if( ptr != NULL )
        UTIbig_msg[i+strlen(ptr)] = 0;
    else
	UTIbig_msg[i] = 0;

    SCdisplay_msg( UTIbig_msg );
    sleep( 6 );
}

