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
  { UTI_E_INVALIDUSER, "NFMutil :  Error. Invalid User Login '#'"},
  { UTI_E_BADSCRIPT, "NFMutil :  Error. Script '#' Does Not Exist"},
  { UTI_E_OPENSCRIPT, "NFMutil :  Error. Cannot Open '#'"},
  { UTI_E_EXESCRIPT, "NFMutil :  Error. Cannot Execute '#'"},
  { UTI_E_SCONNECT, "NFMutil :  Error. Cannot Connect To NFMserver"},
  { UTI_E_SLOGIN, "NFMutil :  Error. Cannot Login To NFMserver"},
  { UTI_E_MEMBUILD, "NFMutil :  Error. Unsuccessful <MEMBUILD> Function Call"},
  { UTI_E_MEMOPEN, "NFMutil :  Error. Unsuccessful <MEMOPEN> Function Call"},
  { UTI_E_MEMWRITEDATA,"NFMutil :  Error. Unsuccessful <MEMWRITEDATA> Function Call"},
  { UTI_E_MEMWRITE,"NFMutil :  Error. Unsuccessful <MEMWRITE> Function Call"},
  { UTI_E_MEMWRITEFORMAT,"NFMutil :  Error. Unsuccessful <MEMWRITEFORMAT> Function Call"},
  { UTI_E_SENDBUFFER,"NFMutil :  Error. Unsuccessful <SENDBUFFER>"},
  { UTI_E_RECEIVEBUFFER	, "NFMutil :  Error. Unsuccessful <RECEIVEBUFFER>"},
  { UTI_E_NOTUPDATED, "NFMutil :  Error. NFMserver Database Not Updated"},
  { UTI_E_FAILURE, "NFMutil :  Unsuccessful Completion of '#'" },
  { UTI_S_SUCCESS, "NFMutil :  Successful Completion of '#'" },
  { 0,	NULL }
};

UTIVerror( errtype, ptr )
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
	fprintf( stdout,"NFMutil :  Unknown Error" );
	return;
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

