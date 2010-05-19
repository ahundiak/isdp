 /* $Id: VDnfmZip.c,v 1.6 2001/11/08 20:21:32 jdsauby Exp $  */
/***************************************************************************
 * I/VDS
 *
 * File:        emsfixes/nfm/VDnfmZip.c
 *
 * Description: VDS Zip functions for files in/out of NFM
 *
 * Dependencies:
 *
 * Revision History:
 * $Log: VDnfmZip.c,v $
 * Revision 1.6  2001/11/08 20:21:32  jdsauby
 * JTS CR MP 4079 - jds
 *
 * Revision 1.5  2001/10/03 15:12:17  jdsauby
 * Added debug stuff, and better error checking
 *
 * Revision 1.4  2001/09/14 16:41:40  jdsauby
 * Made it so that if one file fails to unzip, then it all fails -jds
 *
 * Revision 1.3  2001/09/13 20:17:00  jdsauby
 * sometimes unzip does not work.  Put a sts on rename to find it -jds
 *
 * Revision 1.2  2001/08/14 19:41:54  jdsauby
 * Added logging file, plus env variable to turn zip off  - jds
 *
 * 
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 12/11/00  js      Creation
 ***************************************************************************/
  
#include "time.h"
#include "zlib.h"
#include <MEMstruct.h>
#include "MEMerrordef.h"
#include "VDtypedefc.h"
#include "VDassert.h"
#include "VDsys.h"
#include "VDnfm.h"
#include "VDfrmc.h"
#include <sys/stat.h>



VDASSERT_FFN("vds/emsfixes/nfm/VDnfmZip.c");


/* ------------------------------------------
 * Routine to control the logfile.  Keep appending to the file
 * unless it has been 24 hours since its last access, or it is 
 * greater than 100000 bytes.
 * **/
FILE *VDnfmOpenXferLogFile()
{
  FILE        *file;
  struct stat  f_stat;
  IGRstat      sts;
  IGRchar      filename[80];
  IGRint       newLog = 0;
  time_t       curTime;

  // set the filename
  strcpy(filename,".vdnfmxfer.log");
  
  // get the current time
  time(&curTime);

  // does the file exist, what are it stats
  sts = stat(filename,&f_stat);
  if (sts < 0) {
      newLog = 1;
      goto openFile;
  }

  // has it been more than 24 hours since it was last changed
  if ( (curTime - f_stat.st_ctime) > 86400 ) {
      newLog = 1;
      goto openFile;
  }

  // is the file larger that 100000 bytes
  if ( f_stat.st_size > 100000 ) {
      newLog = 1;
      goto openFile;
  }

openFile:
  if (newLog) file = fopen(filename,"wb");
  else        file = fopen(filename,"a+b");

  if (file == NULL) file = stdout;

  return file;

}


/* ---------------------------------------
 * Use gzip to compress filename, and maintain original filename
 * after gzip.  By default, gzip adds a .gz extension to filename
 * **/
IGRstat VDnfmZipFile(IGRchar *filename)
{
    VDASSERT_FN("VDnfmZipFile");
    IGRstat retFlag = 0;

    IGRstat sts,r_sts;
    IGRchar cmd[1024];
    IGRchar cmd_path[1024];
    IGRchar fbuf[1024];

    VDASSERTW(filename);

    *cmd      = 0;
    *cmd_path = 0;
    *fbuf     = 0;
    r_sts     = 0;

    traceFlag = VDdbgGetTraceFlag(VDNFM_TRACE_ZIP);

    if (traceFlag) printf(">>> %s %s <%s>\n",ffn(),fn,filename);
    
    
    // find the executable
    VDsysFindExeFile("gzip",cmd_path);
    VDASSERTW(*cmd_path);
    
    sprintf(cmd,"%s -f -6 %s 2> /dev/null",cmd_path,filename);

    if (traceFlag) printf("### %s\n",cmd);

    sts = system( cmd );
    if (sts > 0) goto wrapup;

    sprintf(fbuf,"%s.gz",filename);

    r_sts = rename(fbuf,filename);
    if (r_sts != 0) {
	printf("## ERROR: rename of %s to %s failed\n",fbuf,filename);
	goto wrapup;
    }


    // done
    retFlag = 1;

wrapup:
    if (traceFlag) printf("<<< %s %s\n",ffn(),fn);
    return retFlag;
}

/* ---------------------------------------
 * Use gunzip to deCompress filename.  By design, the filename
 * will not have a .gz extension, therefore it must be added
 * before gunzip will work.  Also, it is possible that the file may have
 * been compressed on server from an outside source, therefore, it is 
 * necessary to gunzip the filename until it is no longer compressed.
 * **/
IGRstat VDnfmUnZipFile(IGRchar *filename)
{
    VDASSERT_FN("VDnfmUnZipFile");
    IGRstat retFlag = 0;

    IGRstat sts,r_sts;
    IGRchar cmd[1024];
    IGRchar cmd_path[1024];
    IGRchar fbuf[1024];

    VDASSERTW(filename);

    *cmd      = 0;
    *cmd_path = 0;
    *fbuf     = 0;
    r_sts     = 0;

    // find the executable
    VDsysFindExeFile("gunzip",cmd_path);
    VDASSERTW(*cmd_path);
    
    traceFlag = VDdbgGetTraceFlag(VDNFM_TRACE_ZIP);
    
    // say hi
    if (traceFlag) printf(">>> %s %s <%s>\n",ffn(),fn,filename);
    
    // keep uncompressing until it fails
    sprintf(fbuf,"%s.gz",filename);
    sts = 0;
    do {
	r_sts = rename(filename,fbuf);
	if (r_sts != 0) {
	    printf("## ERROR: rename of %s to %s failed\n",filename,fbuf);
	    goto wrapup;
	}

	sprintf(cmd,"%s %s 2> /dev/null",cmd_path,fbuf);
	if (traceFlag) printf("### %s\n",cmd);

	sts = system( cmd );

    }
    while (sts == 0); 

    r_sts = rename(fbuf,filename);
    if (r_sts != 0) {
	printf("## ERROR: rename of %s to %s failed\n",fbuf,filename);
	goto wrapup;
    }

    retFlag = 1;

wrapup:
    if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
    return retFlag;
}

/* ------------------------------------------------
 * Convert the MEMptr buffer into useful data.
 * Taken from the original function PDUsetup_buffer
 * **/
IGRstat VDnfm_setup_buffer(MEMptr     buffer,
                           IGRint     type,
			   IGRchar ***data)
{
    VDASSERT_FN("VDnfm_setup_buffer");

    IGRstat retFlag = 0;

    VDASSERTW(data);

    if ((buffer->rows > 0) && (buffer))
    {
	if (type == VDNFM_COL)
	    *data = (char **) buffer->column_ptr;
	else if (type == VDNFM_ROW)
	    *data = (char **) buffer->data_ptr;
	else if (type == VDNFM_FORMAT)
	    *data = (char **) buffer->format_ptr;

	retFlag = 1; 
    } 

wrapup:
    return retFlag;
} 

/* --------------------------------------------------
 * get the column number from the MEMptr bufr that contains
 * the column name.
 * Taken from the function PDUget_buffer_col
 * **/
IGRstat VDnfm_get_buffer_col(MEMptr   bufr,
                             IGRchar *col_name,
			     IGRint  *col_num)
{
    VDASSERT_FN("VDnfm_get_buffer_col");

    IGRint   i;
    IGRchar  **data_col;
    IGRstat  status;
    IGRstat  retFlag = 0;

    VDASSERTW(bufr);
    VDASSERTW(*col_name != 0);
    VDASSERTW(col_num);

    status = VDnfm_setup_buffer(bufr,VDNFM_COL,&data_col);
    if (!(status & 1)) goto wrapup;

    for (i = 0; i < bufr->columns; ++i)
    {
	if (strcmp(data_col[i],col_name) == 0)
	{
	    *col_num = i;
	    retFlag = 1;
	    goto wrapup;
	}
    }

wrapup:
    if (data_col) free(data_col);
    return retFlag;
}


/******************************************************************************
Abstract:
	Allocates memory and copies a string into it.

Algorithm:
		1.	If the address of the variable of which you are storing the variable is not NULL, Free the memory previously used by the variable.
		2.	If the string is not NULL, allocate the amount of memory need to store the string and copy it into the variable.

Return Status:
	1
*****************************************************************************/
IGRstat VDnfm_fill_in_string( IGRchar **variable,   // I/O string copied into
                              IGRchar  *string )    // I   string to copy
{
    VDASSERT_FN("VDnfm_fill_in_string");
    IGRstat retFlag = 0;

    if ( (*variable != NULL) && (strcmp(*variable, "")) )
    {
	free (*variable);
	*variable = "";		      
    }

    if ( string != NULL )                              
    {
	*variable = (char *) malloc ( strlen(string) + 1);
	strcpy (*variable, string);
	retFlag = 1;
    }

    return retFlag;
}

/* ------------------------------------------------
 * Process the input MEMptr bufr to get a list of filenames
 * then gunzip the file.
 * This function is called from NFMfile_tr.c
 * **/
IGRstat VDnfmUnzipBufr(MEMptr *bufr,
	               IGRint  logit)
{
    VDASSERT_FN("VDnfmUnzipBufr");
    IGRstat sts;
    IGRstat retFlag = 0;
    IGRchar **data;
    IGRchar *file = NULL;
    IGRint  row;
    IGRint  col;
    IGRchar msg[128];
    FILE    *logFile = NULL;
    struct stat f_stat;

    VDASSERTW(*bufr);
    traceFlag = VDdbgGetTraceFlag(VDNFM_TRACE_ZIP);

    // say hi
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

    if (logit) {
	// open the logfile
	logFile = VDnfmOpenXferLogFile();
    }

    // setup the buffer
    sts = VDnfm_setup_buffer(*bufr, VDNFM_ROW, &data);
    if (!(sts & 1)) goto wrapup;

    // get the buffer col
    sts = VDnfm_get_buffer_col(*bufr, "n_cofilename", &col);
    if (!(sts & 1)) goto wrapup;

    // get the file
    for (row = 0; row < (*bufr)->rows; row++) {

	VDnfm_fill_in_string(&file,
		data[((*bufr)->columns * row) + col] );

	if (*file) {

	    if (logit) {
		// get the stats of the file before uncompression
		sts = stat(file,&f_stat);
		if (sts > -1) {
		    fprintf(logFile,"%-8s %-20s %-13s %d   ",
			    "FILE:",file,"xfer_size:",f_stat.st_size);
		}
	    }

	    //printf("%s %d unzipFile: %s\n",__FILE__,__LINE__,file);
	    sprintf(msg,"Uncompressing File <%s>",file);
	    UI_status(msg);

	    sts = VDnfmUnZipFile(file);
	    if (!(sts & 1)) goto wrapup;

	    if (logit) {
		// get the stats of the file after uncompression
		sts = stat(file,&f_stat);
		if (sts > -1) {
		    fprintf(logFile,"%-12s %d\n",
			    "orig_size:",f_stat.st_size);
		}
	    }


	} // end of file
    }  // end of for

    // done
    retFlag = 1;

wrapup:
    if (file) free(file);
    if (data) free(data);
    if (logFile) fclose(logFile);
    if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
    return retFlag;
}

/* ------------------------------------------------
 * Process the input MEMptr bufr to get a list of filenames
 * then gzip the file.
 * This function is called from NFMfile_tr.c
 * **/
IGRstat VDnfmZipBufr(MEMptr *bufr)
{
    VDASSERT_FN("VDnfmZipBufr");
    IGRstat sts;
    IGRstat retFlag = 0;
    IGRchar **data;
    IGRchar *file = NULL;
    IGRint  row;
    IGRint  col;
    IGRchar msg[128];
    FILE    *logFile = NULL;
    struct stat f_stat;

    VDASSERTW(*bufr);
    traceFlag = VDdbgGetTraceFlag(VDNFM_TRACE_ZIP);

    // say hi
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

    // open the logfile
    logFile = VDnfmOpenXferLogFile();

    // setup the buffer
    sts = VDnfm_setup_buffer(*bufr, VDNFM_ROW, &data);
    if (!(sts & 1)) goto wrapup;

    // get the buffer col
    sts = VDnfm_get_buffer_col(*bufr, "n_cofilename", &col);
    if (!(sts & 1)) goto wrapup;

    // get the file
    for (row = 0; row < (*bufr)->rows; row++) {

	VDnfm_fill_in_string(&file,
		data[((*bufr)->columns * row) + col] );

	if (*file) {
	    // get the stats of the file before compression
	    sts = stat(file,&f_stat);
	    if (sts > -1) {
		fprintf(logFile,"%-8s %-20s %-13s %d   ",
			"FILE:",file,"orig_size:",f_stat.st_size);
	    }

	    //printf("%s %d zipFile: %s\n",__FILE__,__LINE__,file);
	    sprintf(msg,"Compressing File <%s>",file);
	    UI_status(msg);
	    VDnfmZipFile(file);

	    // get the stats of the file after compression
	    sts = stat(file,&f_stat);
	    if (sts > -1) {
		fprintf(logFile,"%-12s %d\n",
			"xfer_size:",f_stat.st_size);
	    }


	} // end of file
    } // end of for

    // done
    retFlag = 1;

wrapup:
    if (file) free(file);
    if (data) free(data);
    if (logFile) fclose(logFile);
    if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
    return retFlag;
}

/* ------------------------------------------------
 * Process the input MEMptr bufr to get a list of filenames
 * then determine if the file exists locally.
 * This function is called from NFMfile_tr.c
 * Added for JTSMP CR 4079, SAUBY
 * **/
IGRstat VDnfmCheckForLocalFiles(MEMptr *bufr)
{
    VDASSERT_FN("VDnfmCheckForLocalFiles");
    IGRstat sts;
    IGRstat retFlag = 0;
    IGRchar **data;
    IGRchar *file = NULL;
    IGRint  row;
    IGRint  col;
    IGRchar buf_msg[128],warn_msg[1024];
    IGRint  warn_user;
    FILE    *logFile = NULL;
    struct stat f_stat;

    VDASSERTW(*bufr);
    traceFlag = VDdbgGetTraceFlag(VDNFM_TRACE_ZIP);

    // say hi
    if (traceFlag) printf(">>> %s %s\n",ffn(),fn);

    // open the logfile
    logFile = VDnfmOpenXferLogFile();

    // setup the buffer
    sts = VDnfm_setup_buffer(*bufr, VDNFM_ROW, &data);
    if (!(sts & 1)) goto wrapup;

    // get the buffer col
    sts = VDnfm_get_buffer_col(*bufr, "n_cofilename", &col);
    if (!(sts & 1)) goto wrapup;

    // get the file
    retFlag = 1;
    warn_user = 0;
    strcpy(warn_msg,"The Following Files Exist Locally:\n");
    for (row = 0; row < (*bufr)->rows; row++) {

	VDnfm_fill_in_string(&file,
		data[((*bufr)->columns * row) + col] );

	if (*file) {
	    // get the stats of the file if it exists, then we have a problem
	    sts = stat(file,&f_stat);
	    if (sts > -1) {
		fprintf(logFile,"%s %s Exists Locally\n",
			"FILE:",file);
		sprintf(buf_msg,"%s\n",file);
		strcat(warn_msg,buf_msg);
		warn_user = 1;
		retFlag = 0;
	    }

	}


    } // end of for

    // finish the warn_msg
    strcat(warn_msg,"Use PDM Checkin or Delete Local Files to clean up");

    // done, display warning message if applicable
    if (warn_user) {
	EX_error_box(FI_CURRENT_SCREEN,warn_msg,"ERROR: PROCESS TERMINATED");
    }
    

wrapup:
    if (file) free(file);
    if (data) free(data);
    if (logFile) fclose(logFile);
    if (traceFlag) printf("<<< %s %s %d\n",ffn(),fn,retFlag);
    return retFlag;
}


#if 0
IGRstat VDpdmZipFileBufr()
{
    VDASSERT_FN("VDpdmZipFileBufr");
    IGRstat status;
    int  row;
    int  file_col;
    char **data_row;
    char *file = NULL;
    MEMptr  file_list = NULL;


    printf(">>> %s %s\n",ffn(),fn);

    status = PDMget_filenames(
                            refresh->rev_catalog,
                            refresh->rev_partid,
                            refresh->rev_revision,
                            &file_list
                           );
 
   if ( status != PDM_S_SUCCESS )
     {
     PDUmessage(status, 's');
     MEMclose(&file_list);
     file_list = NULL;
     return(status);
     }

    // setup the buffer
    PDUsetup_buffer(file_list, ROW, &data_row);

    // get the buffer col
    PDUget_buffer_col(file_list, "n_cofilename", &file_col);

    // get the file

    for (row = 0; row < file_list->rows; row++) {
	
	PDUfill_in_string(&file,
		          data_row[(file_list->columns * row) + file_col] );

	VDpdmZipFile(file);
    }
wrapup:
    //printf("<<< %s %s\n",ffn(),fn);
    return 1;
}

IGRstat VDpdmUnZipFileBufr()
{
    VDASSERT_FN("VDpdmUnZipFileBufr");
    IGRstat status,retFlag = 0;
    int  row;
    int  file_col,a_col;
    char **data_row,**assy_row;
    char *file = NULL;
    MEMptr  file_list = NULL;
    MEMptr  attach_list = NULL;


    printf(">>> %s %s\n",ffn(),fn);

    
    /* -------------------------------------
     * Do the main file list
     * **/
    status = PDMget_filenames(
                            refresh->rev_catalog,
                            refresh->rev_partid,
                            refresh->rev_revision,
                            &file_list
                           );
 
   if ( status != PDM_S_SUCCESS )
   {
       PDUmessage(status, 's');
       MEMclose(&file_list);
       file_list = NULL;
       retFlag = status;
       goto wrapup;
   }



    // setup the buffer
    PDUsetup_buffer(file_list, ROW, &data_row);

    // get the buffer col
    PDUget_buffer_col(file_list, "n_cofilename", &file_col);

    // get the file
    for (row = 0; row < file_list->rows; row++) {
	
	PDUfill_in_string(&file,
		          data_row[(file_list->columns * row) + file_col] );

	VDpdmUnZipFile(file);
    }
    
    /* ------------------------------------
     * Now, do the attached file list
     * **/
    if (!strncmp(PDMpart.n_setindicator, "Y", 1) ||
        !strncmp(PDMpart.n_setindicator, "y", 1) ||
        !strncmp(PDMpart.n_setindicator, "A", 1) ||
        !strncmp(PDMpart.n_setindicator, "a", 1)) {

	PDMexec->entity = PDMpart.p_maxlevel;
	status = PDMsget_assembly_structure(&attach_list, 0);
	if (status != PDM_S_SUCCESS) {
	    printf ("%s PDMsget_assembly_structure failed 0x%.8x\n", fn, status);
	    retFlag = status;
	    goto wrapup;
	}
	
	status = MEMbuild_array (attach_list);
	if (status != MEM_S_SUCCESS) {
	    printf ("%s MEMbuild_array failed status 0x.8x\n",fn, status);
	    MEMclose(attach_list);
	    retFlag = status;
	    goto wrapup;
	}


	// setup the buffer
	printf("%s %d setup buffer\n",__FILE__,__LINE__);
	PDUsetup_buffer(attach_list, ROW, &assy_row);

	// get the buffer col
	printf("%s %d get buffer column\n",__FILE__,__LINE__);
	PDUget_buffer_col(attach_list, "n_cofilename", &a_col);

	// get the file
	printf("%s %d get file\n",__FILE__,__LINE__);
	for (row = 0; row < attach_list->rows; row++) {

	    PDUfill_in_string(&file,
		    assy_row[(attach_list->columns * row) + a_col] );

	    printf("%s %d File: %s\n",__FILE__,__LINE__,file);
	    VDpdmUnZipFile(file);
	}
    }

    // done
    retFlag = 1;

wrapup:
    printf("<<< %s %s\n",ffn(),fn);
    return retFlag;
}

#endif


