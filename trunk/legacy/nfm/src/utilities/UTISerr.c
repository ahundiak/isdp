#include "machine.h"
#include <stdio.h>
#include "MEMstruct.h"
#include "NFMerrordef.h"
#include "NFMSextern.h"
#include "UTIerrordef.h"
#include "UTIglobals.h"
#include "ERR.h"
#include "DEBUG.h"

#define BUFFER_SIZE 1000

/*  SERVER ERROR CODES	*/

#define UTIS_S_SUCCESS		1000
#define UTIS_E_FAILURE		 999
#define UTIS_E_DELSCR		1010
#define UTIS_E_WRTSCR		1020
#define UTIS_E_SETPRM		1060
#define UTIS_E_OPEN		1070
#define UTIS_E_NOFILES		1080
#define UTIS_E_UPDSAV		1150
#define UTIS_E_UPDARCHIVES	1160
#define UTIS_E_UPDCATALOG	1162
#define UTIS_E_UPDFCATALOG	1164
#define UTIS_E_UPDNFMCATALOGS	1166
#define UTIS_E_CONNECT		1170
#define UTIS_E_SEND		1180
#define UTIS_E_RECEIVE		1190
#define UTIS_E_DISCONNECT	1200
#define UTIS_E_ILLLABEL		1210
#define UTIS_E_DEVICE		1250
#define UTIS_E_QUERYNODE 	1260
#define UTIS_E_QUERYLS		1270
#define UTIS_E_FSINFO		1310
#define	UTIS_E_QUERYSA		1440
#define UTIS_E_QUERYATTRTAB	1450
#define UTIS_E_QUERYLABELS	1460
#define UTIS_E_QUERYCATALOGS	1470
#define UTIS_E_QUERYARCHIVES	1475
#define UTIS_E_FORK		1500
#define UTIS_E_EXEC		1520
#define UTIS_I_NO_FLAGGED_FILES  1600

/*  CLIENT ERROR CODES */
#define UTIS_E_INVALIDUSER	2020
#define UTIS_E_BADSCRIPT		2040
#define UTIS_E_OPENSCRIPT	2050
#define UTIS_E_EXESCRIPT		2060
#define UTIS_E_SCONNECT		2070
#define UTIS_E_SLOGIN		2080
#define UTIS_E_MEMBUILD		2090
#define UTIS_E_MEMOPEN		2100
#define UTIS_E_MEMWRITEDATA	2110
#define UTIS_E_MEMWRITE		2114
#define UTIS_E_MEMWRITEFORMAT	2112
#define UTIS_E_MEMSPLIT		2116
#define UTIS_E_MEMRESET		2118
#define UTIS_E_SENDBUFFER	2120
#define UTIS_E_RECEIVEBUFFER	2130
#define UTIS_E_NOTUPDATED	2140
#define UTIS_E_XFER_IN		2170
#define UTIS_E_XFER_OUT		2180
#define UTIS_E_XFER_DEL		2182
#define UTIS_E_XFER_SCR_IN	2190
#define UTIS_E_XFER_SCR_OUT	2200
#define UTIS_E_RESTORE_GROUP	2210

char     *strcpy();

struct errorsstruct
{
    int number;
    char *text;
};

struct errorsstruct
errors[] =
{
  { UTIS_E_DELSCR,"NFM:  Unable To Delete File '#'" },
  { UTIS_E_WRTSCR,"NFM:  Unable To Write File '#'" },
  { UTIS_E_SETPRM,"NFM:  Unable To Set Permissions For File '#'"},
  { UTIS_E_OPEN,"NFM:  Cannot Open File '#'" },
  { UTIS_E_NOFILES,"NFM:  No Filenames Written To File '#'" },
  { UTIS_E_ILLLABEL,"NFM:  Illegal Label Definition '#' For Label" },
  { UTIS_E_DEVICE, "NFM:  Illegal Device Type '#'" },
  { UTIS_E_UPDSAV,"NFM:  Error Updating NFMSAVESET Table" },
  { UTIS_E_UPDARCHIVES, "NFM:  Error Updating NFMARCHIVES Table " },
  { UTIS_E_UPDFCATALOG, "NFM:  Error Updating File Catalog Table for Item '#'" },
  { UTIS_E_UPDCATALOG, "NFM:  Error Updating '#' Table " },
  { UTIS_E_UPDNFMCATALOGS, "NFM:  Error Updating NFMCATALOGS Table for catalog '#'" },
  { UTIS_E_CONNECT, "NFM:  Error Connecting To Node '#' " },
  { UTIS_E_SEND, "NFM:  Error Sending File '#' " },
  { UTIS_E_RECEIVE, "NFM:  Error Receiving File '#'"},
  { UTIS_E_DISCONNECT, "NFM:  Error Disconnecting From Node" },
  { UTIS_S_SUCCESS,"NFM:  Successful Completion Of # Process" },
  { UTIS_E_QUERYLS,"NFM:  No Database Information For Given Label And Saveset" },
  { UTIS_E_FSINFO, "NFM:  No File Storage Information For File '#' " },
  { UTIS_E_INVALIDUSER, "NFM:  Invalid User Login"},
  { UTIS_E_BADSCRIPT, "NFM:  Script '#' Does Not Exist"},
  { UTIS_E_OPENSCRIPT, "NFM:  Cannot Open '#'"},
  { UTIS_E_EXESCRIPT, "NFM:  Cannot Execute '#'"},
  { UTIS_E_SCONNECT, "NFM:  Cannot Connect To NFMserver"},
  { UTIS_E_SLOGIN, "NFM:  Cannot Login To NFMserver"},
  { UTIS_E_MEMBUILD, "NFM:  Unsuccessful <MEMBUILD> Function Call"},
  { UTIS_E_MEMOPEN, "NFM:  Unsuccessful <MEMOPEN> Function Call"},
  { UTIS_E_MEMWRITEDATA,"NFM:  Unsuccessful <MEMWRITEDATA> Function Call"},
  { UTIS_E_MEMWRITE,"NFM:  Unsuccessful <MEMWRITE> Function Call"},
  { UTIS_E_MEMWRITEFORMAT,"NFM:  Unsuccessful <MEMWRITEFORMAT> Function Call"},
  { UTIS_E_MEMRESET, "NFM:  Unsuccessful <MEMRESET> Function Call"},
  { UTIS_E_MEMSPLIT, "NFM:  Unsuccessful <MEMSPLIT> Function Call"},
  { UTIS_E_SENDBUFFER,"NFM:  Unsuccessful <SENDBUFFER> to NFMserver"},
  { UTIS_E_RECEIVEBUFFER	, "NFM:  Unsuccessful <RECEIVEBUFFER> from NFMserver"},
  { UTIS_E_NOTUPDATED, "NFM:  NFMserver Database Not Updated"},
  { UTIS_E_QUERYSA, "NFM:  Unsuccessful NFMSTORAGEAREA Table Query" },
  { UTIS_E_QUERYARCHIVES, "NFM:  Unsuccessful NFMARCHIVES Table Query" },
  { UTIS_E_QUERYATTRTAB, "NFM:  Unsuccessful NFMATTRIBUTES Table Query"},
  { UTIS_E_QUERYLABELS, "NFM:  Unsuccessful NFMARCHIVES Table Query for Labels" },
  { UTIS_E_QUERYCATALOGS, "NFM:  Unsuccessful NFMCATALOGS Table Query"},
  { UTIS_E_QUERYNODE, "NFM:  Unsuccessful NFMNODES Table Query"},
  { UTIS_E_FORK, "NFM:  Unsuccessful FORK For '#' Command"},
  { UTIS_E_EXEC, "NFM:  Unsuccessful EXEC For '#' Command"},
  { UTIS_E_XFER_IN, "NFM:  Unsuccessful File Transfer To Storage Node"},
  { UTIS_E_XFER_OUT,"NFM:  Unsuccessful File Transfer From Storage Node"},
  { UTIS_E_XFER_DEL,"NFM:  Unsuccessful File Deletion From Storage Node"},
  { UTIS_E_XFER_SCR_IN, "NFM:  Unsuccessful Script Transfer To Storage Node"},
  { UTIS_E_XFER_SCR_OUT, "NFM:  Unsuccessful Script Transfer From Storage Node"},
  { UTIS_E_RESTORE_GROUP, "NFM:  Unsuccessful Restore for Group '#'"},  
  { 0,	NULL }
};

long NFMS_utilities_error( in_list, out_list )
    MEMptr	in_list;
    MEMptr	*out_list;
{
    long	status;
    long	uti_error;
    char	*msg_str;
    long	nfm_error;
    char	**data_ptr;
    static char *fname = "NFM_utilities_error";

    *out_list	= NULL;

    status = MEMbuild_array (in_list);
    if (status != MEM_S_SUCCESS)
    {
        _UTIdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
        return (status);
    }

    data_ptr = (char **) in_list->data_ptr;

    _UTIdebug(( fname, "user_id : <%s>\n", data_ptr[0]));
    _UTIdebug(( fname, "uti_error : <%s>\n", data_ptr[1]));
    _UTIdebug(( fname, "msg_str : <%s>\n", data_ptr[2]));
    _UTIdebug(( fname, "nfm_error : <%s>\n", data_ptr[3]));

    UTIuser_id = atol( data_ptr[0] );
    uti_error  = atol( data_ptr[1] );
    msg_str    = strcpy((char*)malloc(strlen(data_ptr[2])+1),data_ptr[2]);
    nfm_error  = atol( data_ptr[3] );

    return( NFM_S_SUCCESS );
}

/*  This routine takes the input status, maps it to an error message,
 *  and builds the return buffer( out_list ) that will be sent back
 *  to the requester.
 */
UTIreq_err( errtype, ptr )
    int		errtype;
    char	*ptr;
{
    int  i;
    int  j;
    int  errno;

    long status;

    char ch;
    char *errmess;
    char UTImsg[132];
    char err_num[10];

    static char *fname = "UTIreq_err";

    _UTIdebug(( fname, "err_no : <%d>\n", errtype ));

    memset( UTImsg, NULL, 132 );
    for( errno=0; errors[errno].number!=0; ++errno )
	if( errors[errno].number == errtype )
	    break;

    if( errors[errno].number == 0 )
    {
	strcpy( UTImsg, "NFM:  Unknown Error." );
    }
    errmess = errors[errno].text;
    j = 0; 

    for( i=0; (ch = *(errmess+i))!=0; ++i )
    {
	if( ch != '#' )
	{
	    UTImsg[j] = ch;
	    ++j;
 	}
	else
	{
	    strcat( UTImsg, ptr );
	    j += strlen( ptr );
	} 	    
    }

    strcat( UTImsg, "\1" );
    sprintf( err_num, "%d", errors[errno].number);
    strcat( UTImsg, err_num );    
    strcat( UTImsg, "\1" );

    status = MEMwrite( UTI_ERR_BUFFER, UTImsg );
    if( status != MEM_S_SUCCESS )
    {
	_UTIdebug(( fname, "MEMwrite <0x%.8x>\n", status ));
        return( status );
    }
    _UTIdebug(( fname, "msg : <%s>\n", UTImsg ));
    _UTIdebug(( fname, "num : <%d>\n", errno  ));

    return( UTI_S_SUCCESS );
}
