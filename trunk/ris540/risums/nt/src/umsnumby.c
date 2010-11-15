#include <sys/types.h>
#include <string.h>
#include <stdarg.h>

#include "UMS.h"
#include "UMSpriv.h"
#include "UMSfile.h"
#include "pums_all.h"

/**********************************************************************

Doc:	UMSGetNumByKey

Abstract:
	The UMSGetNumByKey function returns the message number for the
	given message key (either primary or secondary).

Return Status:
	UMS_S_SUCCESS	-	Success
	UMS_E_NOTFND	-	Message key not found
	other		-	Error reading file index or key list

**********************************************************************/

int	UMSGetNumByKey( msgNum, msgKey )
/* sml:09-20-91		changed to long for PC limitations
  int	*msgNum;	 o - Returned message number		*/
  long	*msgNum;	/* o - Returned message number		*/
  char	*msgKey;	/* i - Primary or secondary message key	*/
{
  UMSFileIndex	fileIdx;
  UMSHeader	*msgHdr;
  int		sts, idx;

  sts = _UMSInterpretKey( &msgHdr, &idx, msgKey );
  if ( sts != UMS_S_SUCCESS )
	return( sts );

  if ( msgHdr->nidx )
    {
	*msgNum = msgHdr->nidx[idx].msgNum;
    }
  else
    {
	sts = _UMSOpenFile( msgHdr );
	if ( sts != UMS_S_SUCCESS )
		return( sts );

	sts = _UMSGetFileIdx( fileIdx, idx );
	if ( sts != UMS_S_SUCCESS )
		return( sts );

	*msgNum = fileIdx[UMS_FILEIDX_MSGNUM];
    }

  return( UMS_S_SUCCESS );
}
