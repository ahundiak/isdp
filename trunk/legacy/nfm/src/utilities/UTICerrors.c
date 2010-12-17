#include "machine.h"
#include <stdio.h>
#include "MEMstruct.h"
#include "MSGstruct.h"
#include "UTICinclude.h"

char	 *strcpy();
char	 *strchr();

struct errorsstruct
{
    int number;
    char *text;
};

struct errorsstruct
errors[] =
{
  { UTI_E_INVALIDUSER, "Nfmutil :  Error. Invalid User Login '#'"},
  { UTI_E_BADSCRIPT, "Nfmutil :  Error. Script '#' Does Not Exist"},
  { UTI_E_OPENSCRIPT, "Nfmutil :  Error. Cannot Open '#'"},
  { UTI_E_EXESCRIPT, "Nfmutil :  Error. Cannot Execute '#'"},
  { UTI_E_SCONNECT, "Nfmutil :  Error. Cannot Connect To NFMserver"},
  { UTI_E_SLOGIN, "Nfmutil :  Error. Cannot Login To NFMserver"},
  { UTI_E_MEMBUILD, "Nfmutil :  Error. Unsuccessful <MEMBUILD> Function Call"},
  { UTI_E_MEMOPEN, "Nfmutil :  Error. Unsuccessful <MEMOPEN> Function Call"},
  { UTI_E_MEMWRITEDATA,"Nfmutil :  Error. Unsuccessful <MEMWRITEDATA> Function Call"},
  { UTI_E_MEMWRITE,"Nfmutil :  Error. Unsuccessful <MEMWRITE> Function Call"},
  { UTI_E_MEMWRITEFORMAT,"Nfmutil :  Error. Unsuccessful <MEMWRITEFORMAT> Function Call"},
  { UTI_E_SENDBUFFER,"Nfmutil :  Error. Unsuccessful <SENDBUFFER>"},
  { UTI_E_RECEIVEBUFFER	, "Nfmutil :  Error. Unsuccessful <RECEIVEBUFFER>"},
  { UTI_E_NOTUPDATED, "Nfmutil :  Error. NFMserver Database Not Updated"},
  { UTI_E_MERGE_SCRIPT, "Nfmutil :  Error. Could Not Merge Configurable FIle"},
  { UTI_E_FAILURE, "Nfmutil :  Unsuccessful Completion of '#'" },
  { UTI_S_SUCCESS, "Nfmutil :  Successful Completion of '#'" },
  { 0,	NULL }
};

UTICerror( errtype, ptr )
    int		errtype;
    char	*ptr;
{
    int  i;
    int  j;
    int  errno;

    char ch;
    char big_msg[132];
    char *errmess;

    memset( big_msg, NULL, 132 );

    for( errno=0; errors[errno].number!=0; ++errno )
	if( errors[errno].number == errtype )
	    break;

    if( errors[errno].number == 0 )
    {
	fprintf( stdout,"Nfmutil :  Unknown Error" );
	return( UTI_E_FAILURE );
    }
    errmess = errors[errno].text;
    j = 0; 

    for( i=0; (ch = *(errmess+i))!=0; ++i )
    {
	if( ch != '#' )
	{
	    big_msg[j] = ch;
	    ++j;
 	}
	else
	{
	    strcat( big_msg, ptr );
	    j += strlen( ptr );
	} 	    
    }
    if( ptr != NULL )
        big_msg[i+strlen(ptr)] = 0;
    else
	big_msg[i] = 0;

    fprintf( stdout, "%s\n", big_msg );
    return( UTI_S_SUCCESS );
}

