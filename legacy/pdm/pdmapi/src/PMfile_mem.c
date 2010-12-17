#include <stdio.h>
#include <sys/types.h>
#include <sys/ipc.h>
#include <sys/shm.h>
#include "MEMstruct.h"
#include "MEMerrordef.h"
#include "DEBUG.h"
#include "PDUerror.h"

#define		FILE_BUFR	2000
#define		CHILD_BUFR	2001
#define		ATTACH_BUFR	2002
#define		SV_BUFR	        2003
#define		PARM_BUFR       2004
#define		DATA_BUFRS      2005
#define		PARA_ASS        2006
#define		PARA_ASS_DYN    2007
#define		PARA_CATS       2008
#define		DELETE_LIST     2009
#define		MULTIPLE_FILES  2010

#define PDM_E_GET_SHM -2
#define PDM_E_ATTACH_SHM -3
#define PDM_E_DETACH_SHM -4

/* static structures and variables used in this file */

static  char	*shm_ptr ;
static int status ;

/*  IPC - between the ppl kicked by ems to get information from the
          Object space to the PDM code which does the file transfer
    - Kumar Narayanan

     Shared memory of eight segments [ID 2000  - 2010]  
*/


int PDMattach_file
        (
        MEMptr file_bufr,
        MEMptr child_bufr,
        MEMptr attach_bufr, 
        MEMptr sv_bufr,
        MEMptr parm_buffer,
        MEMptr data_buffers,
        MEMptr para_ass,
        MEMptr para_ass_dynamic
        )

{
	
char  caw_formatfile[50], caw_datafile[50];
char  *fname = "PDMattach_file";


   _PDMdebug(fname, "Enter\n");

    caw_formatfile[0] = '\0';
    caw_datafile[0] = '\0';
    sprintf(caw_formatfile, "/usr/tmp/%d.for", FILE_BUFR);
    sprintf(caw_datafile, "/usr/tmp/%d.dat", FILE_BUFR);

  /*  File Bufr attachment to shared memory */
     status = PDMbuffer_to_file(file_bufr, caw_formatfile, caw_datafile);
      if(status != PDM_S_SUCCESS)
       {
        _PDMdebug(fname, "PDMbuffer_to_file failed status %d\n", status);
       }

  /*  Child Bufr attachment to shared memory */
    caw_formatfile[0] = '\0';
    caw_datafile[0] = '\0';
    sprintf(caw_formatfile, "/usr/tmp/%d.for", CHILD_BUFR);
    sprintf(caw_datafile, "/usr/tmp/%d.dat", CHILD_BUFR);
     status = PDMbuffer_to_file(child_bufr, caw_formatfile, caw_datafile);
      if(status != PDM_S_SUCCESS)
       {
        _PDMdebug(fname, "PDMbuffer_to_file failed status %d\n", status);
       }
  
  /*  Attach bufr attachment to shared memory */
    caw_formatfile[0] = '\0';
    caw_datafile[0] = '\0';
    sprintf(caw_formatfile, "/usr/tmp/%d.for", ATTACH_BUFR);
    sprintf(caw_datafile, "/usr/tmp/%d.dat", ATTACH_BUFR);
     status = PDMbuffer_to_file(attach_bufr, caw_formatfile, caw_datafile);
      if(status != PDM_S_SUCCESS)
       {
        _PDMdebug(fname, "PDMbuffer_to_file failed status %d\n", status);
       }
  
  /*  Saved views bufr attachment to shared memory */
    caw_formatfile[0] = '\0';
    caw_datafile[0] = '\0';
    sprintf(caw_formatfile, "/usr/tmp/%d.for", SV_BUFR);
    sprintf(caw_datafile, "/usr/tmp/%d.dat", SV_BUFR);
     status = PDMbuffer_to_file(sv_bufr, caw_formatfile, caw_datafile);
      if(status != PDM_S_SUCCESS)
       {
        _PDMdebug(fname, "PDMbuffer_to_file failed status %d\n", status);
       }
  
  /*  parm  bufr attachment to shared memory */
    caw_formatfile[0] = '\0';
    caw_datafile[0] = '\0';
    sprintf(caw_formatfile, "/usr/tmp/%d.for", PARM_BUFR);
    sprintf(caw_datafile, "/usr/tmp/%d.dat", PARM_BUFR);
     status = PDMbuffer_to_file(parm_buffer, caw_formatfile, caw_datafile);
      if(status != PDM_S_SUCCESS)
       {
        _PDMdebug(fname, "PDMbuffer_to_file failed status %d\n", status);
       }
  
  
  /*  data buffers attachment to shared memory */
    caw_formatfile[0] = '\0';
    caw_datafile[0] = '\0';
    sprintf(caw_formatfile, "/usr/tmp/%d.for", DATA_BUFRS);
    sprintf(caw_datafile, "/usr/tmp/%d.dat", DATA_BUFRS);
     status = PDMbuffer_to_file(data_buffers, caw_formatfile, caw_datafile);
      if(status != PDM_S_SUCCESS)
       {
        _PDMdebug(fname, "PDMbuffer_to_file failed status %d\n", status);
       }
  
  /*  para  ass bufr attachment to shared memory */
    caw_formatfile[0] = '\0';
    caw_datafile[0] = '\0';
    sprintf(caw_formatfile, "/usr/tmp/%d.for", PARA_ASS);
    sprintf(caw_datafile, "/usr/tmp/%d.dat", PARA_ASS);
     status = PDMbuffer_to_file(parm_buffer, caw_formatfile, caw_datafile);
      if(status != PDM_S_SUCCESS)
       {
        _PDMdebug(fname, "PDMbuffer_to_file failed status %d\n", status);
       }
  
  /*  para  ass dynamic bufr attachment to shared memory */
    caw_formatfile[0] = '\0';
    caw_datafile[0] = '\0';
    sprintf(caw_formatfile, "/usr/tmp/%d.for", PARA_ASS_DYN);
    sprintf(caw_datafile, "/usr/tmp/%d.dat", PARA_ASS_DYN);
     status = PDMbuffer_to_file(para_ass_dynamic, caw_formatfile, caw_datafile);
      if(status != PDM_S_SUCCESS)
       {
        _PDMdebug(fname, "PDMbuffer_to_file failed status %d\n", status);
       }
  
  
  /*  Para cats structure attachment to shared memory */
  
   _PDMdebug(fname, "Exit\n");
	return(PDM_S_SUCCESS);
}
