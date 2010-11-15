#include <sys/types.h>
#include <string.h>
#include <stdio.h>
#include <stdarg.h>

#include <ums.h>
#include <umspriv.h>
#include <umsfile.h>
#include <pums_pub.h>
#include <pums_pri.h>

/**********************************************************************

Doc:	UMSGetKeyByNum

Abstract:
	The UMSGetKeyByNum function returns either or both the primary
	and secondary message keys for the given message number.

	The secondary message key will be returned ONLY if it is memory.

Return Status:
	UMS_S_SUCCESS	-	Success
	UMS_E_NOTFND	-	Message number not found
	other		-	Error reading primary key from file

  char	*msgKey;	 o - Buffer for primary message key	
			       0 if primary key not needed	
  char	*msgKey2;	 o - Buffer for secondary message key 
			       0 if secondary key not needed	
 sml:09-20-91		change to long for PC limitations
  long	msgNum;		 i - Message number			
**********************************************************************/

int UMSGetKeyByNum( char *msgKey, char *msgKey2, long msgNum )
{
  UMSHeader	*msgHdr;
  int		sts, idx, msgCount;
  long 		fileIdx_offset;


  sts = _UMSInterpretNum( &msgHdr, &msgCount, msgNum );
  if ( sts != UMS_S_SUCCESS )
	return( sts );

  idx = msgCount - 1;

  if ( msgKey )
    {
      if ( msgHdr->kidx )
	{
	  if ( msgHdr->nidx[idx].msgNum != msgNum )
		return( UMS_E_NOTFND );

	  sprintf( msgKey, "%s:%s", msgHdr->comp,
			 msgHdr->k1ext + msgHdr->kidx[idx] );
	}
      else
	{
	  UMSFileIndex	fileIdx;
	  char		extBuf[UMS_MEM_EXT_LEN];

	  sts = _UMSOpenFile( msgHdr );
	  if ( sts != UMS_S_SUCCESS )
		return( sts );
	  sts = _UMSGetFileIdx( fileIdx, idx );
	  if ( sts != UMS_S_SUCCESS )
		return( sts );

      /*****************************************************/
      /* sml:03-04-93                                      */
      /* Convert (swap bytes if necessary) on fileIdx's    */
      /* values.                                           */
      /*****************************************************/
      fileIdx_offset = fileIdx[UMS_FILEIDX_MSGNUM];
      sts = UMS_long_convert(&fileIdx_offset);
/***      if ( fileIdx[UMS_FILEIDX_MSGNUM] != msgNum )  ***/
      if ( fileIdx_offset != msgNum )
		return( UMS_E_NOTFND );

      fileIdx_offset = fileIdx[UMS_FILEIDX_EXTPTR];
      sts = UMS_long_convert(&fileIdx_offset);
      sts = _UMSGetFileExt( extBuf, msgHdr, fileIdx_offset );
/***                          fileIdx[UMS_FILEIDX_EXTPTR] ); ***/
	  if ( sts != UMS_S_SUCCESS )
		return( sts );

	  sprintf( msgKey, "%s:%s", msgHdr->comp, extBuf );
	}
    }

  if ( msgKey2 )
    {
      if ( msgHdr->k2lst )
	{
	  int	i;
	  char	*keyPtr;

	  keyPtr = msgHdr->k2lst;
	  for ( i = 0; i < idx; i++ )
		keyPtr += strlen( keyPtr ) + 1;

	  strcpy( msgKey2, keyPtr );
	}
      else
	msgKey2[0] = '\0';
    }

  return( UMS_S_SUCCESS );
}
