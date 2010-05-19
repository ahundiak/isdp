
/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdcheckin/cmd/ VDbatchPost.I
 *
 * Description:
 *        This function calls the BatchPostPMEData to prepare the ASCII 
 *   transaction file, it sends the post code VDP_SUBMIT_BATC_POST to notify
 *   that the job is submitted and also it submit the batch request to queue.
 *
 * Dependencies:
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *      10/28/96	 Ravi		 Creation
 *      05/01/98	 Durga		 Modification
 * ------------------------------------------------------------------------*/
class  implementation VDCmdChkIn;

#include "v_dbgmacros.h"

#include <stdio.h>
#include <unistd.h>
#include <sys/utsname.h>
#include "ex.h"
#include "exdef.h"
#include "exmacros.h"
#include "VDPdef.h"
#include "VDPdm2.h"

#include "DIdef.h"
#include "DItypedef.h"
#include "DIglob.h"
#include "DIprims.h"


from VDPtrTbl	import	VDPBatchpostPMEdata;


IGRint batch_post_file ( long 		*msg, 
			 struct GRid 	*Trlist,
			 char 		*qname, 
			 char 		*email_path  )
{

  
    int         inlen,code,index=0,
                outlen=0,dstat,mfail,i;
    char        inbuf[80];
    char        *outbuf, *errmsg=0;
    char        FileId[VDPOBID_LEN];
    OMuword 	curOs;
    char 	FileName[OM_K_MAXOSNAME_LEN];
    char 	LogFile[OM_K_MAXOSNAME_LEN];
    char	tmpstr[DI_PATH_MAX];
    char        sysAction[DI_PATH_MAX];
    char	*fName = "/usr/tmp/vdspost.cmd";
    long	status;
    int		sts;
    FILE	*fPntr=NULL;
    char	DesFile[DI_PATH_MAX],DesLogFile[DI_PATH_MAX],
		AsciFile[DI_PATH_MAX];
    char	*tok=NULL;
    struct utsname	utsName;
    char 	DirName[OM_K_MAXOSNAME_LEN];
    int		len=OM_K_MAXOSNAME_LEN;

    

  /* prepare asci file  */
  status = ex$filename ( name = FileName,
			 len  = OM_K_MAXOSNAME_LEN );

  tok = (char *)strrchr(FileName,(int) '/' );
  tok++;
  strcpy(DesFile,tok );
  tok=NULL;
  tok = (char *)strtok( DesFile, "." );
  sprintf( AsciFile, "%s.pst", tok?tok:DesFile );
  sprintf( DesLogFile, "%s.log",tok?tok:DesFile );

  __DBGpr_str ( "Ascifile name", AsciFile );
  __DBGpr_obj ( "Trlist", *Trlist );

  /* Prepare Ascii file */

  if ( Trlist->objid != NULL_OBJID )
  {
       status = om$send (msg = message VDPtrTbl.VDPBatchpostPMEdata(
						   msg, AsciFile ),
					senderid = NULL_OBJID,
					targetid = Trlist->objid,
					targetos = Trlist->osnum ); 
       __CheckRC( status, *msg, "VDPBatchpostPMEdata", wrapup );
  } else {

       UI_status( "Transaction list does not exist" );
       return 0;
  }
  
  if( access( AsciFile, F_OK ))
  {
       sprintf( tmpstr, "Can't find file %s", AsciFile );
       UI_status( tmpstr );
       goto wrapup ;
  }
  if( (fPntr = (FILE *) fopen( fName, "w+x" )) == NULL )
  {
       sprintf( tmpstr, "Can't open file: %s\n", fName );
       UI_status( tmpstr);
       goto wrapup ;
  }
   

  if( uname( &utsName ) == -1 ){
      /*
       * Could not find system name.
       */
       UI_status(" Can't find system name ");
       printf("%s[%d] : uname error\n",__FILE__,__LINE__ );
       return 0;
  }
  /* Send the code VDP_SUBMIT_BATCH_POST to notify that the job is submitted */
  UI_status("Submitting the job to Queue" );

  for ( i=0; i<80; i++ )
       inbuf[i]='\0';
  code = VDP_SUBMIT_BATCH_POST;
  ex$get_cur_mod( osnum = &curOs );
  dstat = VDPGetFileId ( msg,curOs,FileId );
  if( ! dstat & 1 )
  {
       __DBGpr_int( "VDPGetFileId failed ", __LINE__ );        
       UI_status ( "Failed to get the FileId" );
  }
   
  __DBGpr_str ( "FileId", FileId );
  inlen = 0;
  memcpy( &inbuf[index], &code, sizeof(int));

  inlen += sizeof(int);
  strcpy( &inbuf[inlen], FileId );
  inlen = inlen + strlen( FileId )+1;

  dstat = POSTMAN_REQUEST_ON_CLIX (   inlen,
                                      inbuf,
                                      &outlen,
                                      &outbuf,
                                      &mfail,
                                      &errmsg );

  if(dstat || mfail)
  {
      if(!errmsg || (errmsg && !errmsg[0]))
          errmsg="No error msg but should be";
      if ( strlen(errmsg ) > 63 )
          errmsg[63] = '\0';
      UI_status( errmsg );
      return 0;
  }
  status = ex$get_working_dir( name = DirName, len = &len );
  sprintf( FileName, "%s%s",DirName,AsciFile );
  sprintf(LogFile, "%s%s",DirName,DesLogFile ); 
  
  /* Prepare the script file and submit it to queue */ 
  
  if( email_path[0] != '\0'  )
  {
     fprintf( fPntr, "perl %%PERL_DIR%%\\reg.pl  %s  %s",
							AsciFile, email_path ); 
     fclose( fPntr );
     sprintf(sysAction,"qsub -si %s=%s:%s  -q %s  %s", 
			AsciFile, utsName.nodename, FileName, 
			qname, fName );
  }else {
     fprintf( fPntr, " perl %%PERL_DIR%%\\reg.pl %s", AsciFile); 
     fclose( fPntr );
     sprintf(sysAction,"qsub -si %s=%s:%s  -so %s:%s=%s  -q %s  %s", 
			AsciFile, utsName.nodename,FileName, 
			utsName.nodename,LogFile, DesLogFile, qname, fName );
  }
  __DBGpr_str( "sysAction:",sysAction );
  sts = system( sysAction );
  if( sts != 0 )
  {
     sprintf( tmpstr, "Could not  submit request: %s", sysAction );
     UI_status( tmpstr );
  }
wrapup:

  return 1;

}

end implementation VDCmdChkIn;
