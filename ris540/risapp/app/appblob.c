/* Do not alter this SPC information: $Revision: 1.3.31.1 $ */
/*
**	NAME:							appblob.c
**	AUTHORS:					 	James Chang	
**	CREATION DATE:					12/93
**	ABSTRACT:
**	
**	REVISION HISTORY:
**
**
**				This part of code was in intexec.c intfetch.c
**				originally.
**
**
*/
 
/*
**	INCLUDES
*/
#include "app.h"
#include "riscom.h"
#include "ristypes.h"
#include "rismem.h"
#include <fcntl.h> 
#include <errno.h> 
#if defined (DOS)
#include <io.h>
#endif

/*
**	DEFINES
*/
#if defined(WIN32)
#define ODBC_MAX_SQLLEN_SIZE 255 
#endif

/*
**	TYPES
*/

/*
**	FUNCTION PROTOTYPES
*/
#define appblob_c
#if defined(WIN32)
#include "appdtype.prt"
#endif
#include "comalloc.prt"
#include "comdebug.prt"
#include "appblob.prt"
#include "appcnv.prt"
#include "comjmp.prt"
#include "sys.prt"
#include "appparms.prt"
#include "appsndrc.prt"
#include "apptobuf.prt"
#include "wrap.prt"
#include "arcgnerc.prt"

/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/

/******************************************************************************/

extern int RISapp_locate_blob_column(
	sqlda *blob_parm_sqlda,
	sqlda *ris_stmt_sqlda,
	int input,
	unsigned char **blob_infos)
{
	short    sqld=0, i=0, offset=0;
	char *blob_file_name_list[RIS_MAX_TABLE_COLUMNS];
	sqlvar *blob_parm_sqlvar=0;
	sqlvar *stmt_sqlvar=0;
	ris_blob * blob_parm=0;
	char *fetch_data=0;
	int total_num_of_blob_files=0, total_blob_filename_length=0, 
	blob_count=0;

    if (ris_stmt_sqlda)
  	{
		sqld=ris_stmt_sqlda->sqln;
		stmt_sqlvar=ris_stmt_sqlda->sqlvar;

		/* OBDC does not provid user parameters at this point */
		
#if defined(WIN32)
		if (ODBCDLL)
		{
      		blob_parm_sqlda=(sqlda *)ALLOCB(sizeof(sqlda));
      		blob_parm_sqlda->sqld = sqld;
			blob_parm_sqlda->sqlvar = blob_parm_sqlvar=
					(sqlvar *)ALLOCB(sizeof(sqlvar)* sqld);
			for (i=0; i++; i < sqld)
			{ 
         		(blob_parm_sqlvar+i)->sqltype=RIS_BLOB;
			}
        }
#endif
	}
	else
	{
		return(0);
	}

   	/*
          locate the blob column
   	*/

   	*blob_infos = (unsigned char *) ALLOCB(sqld);

	blob_parm_sqlvar=blob_parm_sqlda->sqlvar;

	if (!input )	
	{
   		RIS_write->buf.fetch.blob_count = 0 ;
   		RIS_write->buf.fetch.out_data=offset;
	}

   	for (i=0; i<sqld;
                stmt_sqlvar++,blob_parm_sqlvar++,i++ )
    {

		if(stmt_sqlvar->sqltype == RIS_BLOB ||
                      stmt_sqlvar->sqltype == RIS_TEXT)
        {
       		if (blob_parm_sqlvar->sqltype != RIS_BLOB &&
                     blob_parm_sqlvar->sqltype != RIS_TEXT)
               LONGJMP(RIS_E_INCOMPATIBLE_TYPE);
			
#if defined(WIN32)
			if (ODBCDLL)
			{
				/* We assume blob uses mem only */
      			blob_parm_sqlvar->sqldata=(char *)ALLOCT(ris_blob);
      			((ris_blob *)blob_parm_sqlvar->sqldata)->file_used=0;
			}
#endif


	        if (blob_parm_sqlvar->sqldata == 0)
				LONGJMP(RIS_E_NO_BLOB_STRUC);

            blob_parm = (ris_blob *)blob_parm_sqlvar->sqldata;
            blob_count++;


            /* If neither mem nor file is used */
            if ( !blob_parm->filename &&  ! blob_parm->array )
              LONGJMP(RIS_E_BAD_BLOB_STRUC);

             /* If file is used, file name should have been given */

            if (blob_parm->file_used)
            {
           		char *temp_name = 0;

               	if (! blob_parm->filename)
                {
               		APP_DBG(("RISint_exec: file_used flag is not set\n"));
                    LONGJMP(RIS_E_BAD_BLOB_STRUC);

                }

                temp_name = blob_parm->filename;

                APP_DBG(("RISint_fetch: output blobfile name: %s\n",temp_name));


		if (input)
		{
		    if (access(temp_name, 04) != 0)
                    {
                	APP_DBG(("RISint_exec: blobfile access errno: %d\n", errno));
                        LONGJMP(RIS_E_ACCESS_BLOB_FILE_ERROR);
                    }

		    /*
		    ** Set the file_used flag, so the server
		    ** will know it is a remote file or not
		    */

                    if (RIS_net->protocol == SHMEM)
                        blob_parm->file_used = 1;
                    else
                        blob_parm->file_used = 2;

                    *(*blob_infos+i)=0x10 ;
		}	
		else  /* output */	
		{	
			/* In the case of output, file names are only
			   useful if they are local */
 
                	*(*blob_infos+i)=0x50 ;

                	if (RIS_net->protocol == SHMEM)
                	{
                 		blob_parm->file_used = 0x01;
                  	}
                  	else
				blob_parm->file_used = 0x02;

                	if ( access(temp_name, 00) == -1)
                   	{
                   		int fd=0, st=0;

				/*
				** file does not exist, create it;
				** so it will not be created by
				** super user in the server.
				*/
#if defined(WIN32)
                      		if((fd=open(temp_name, O_CREAT | O_RDWR | O_BINARY,
							S_IREAD | S_IWRITE  ))< 0)
#else
                      		if((fd=open(temp_name, O_CREAT | O_RDWR,
							S_IREAD | S_IWRITE  ))< 0)
#endif
                           			LONGJMP(RIS_E_OPEN_BLOB_FILE_ERROR);

                       		if ((st = close(fd))< 0)
                           		LONGJMP(RIS_E_CLOSE_BLOB_FILE_ERROR);

            			blob_parm->file_used |= 0x10;
             		}

                      	/*
			** Set the file_used flag, so the server
			** will know it is a remote file or not
			*/

                 	/* get the length of file  name into array_size */
                	blob_parm->array_size= strlen(blob_parm->filename) + 1;

			blob_file_name_list[total_num_of_blob_files]=
        		             (char *) ALLOCB(strlen(blob_parm->filename)+1);

                	/* array_size here has the file name length */
                	total_blob_filename_length += blob_parm->array_size;

                	strcpy(blob_file_name_list[total_num_of_blob_files],
                         					  blob_parm->filename);

                	total_num_of_blob_files ++;
              } /* output */
			}
            else  /*   MEM used */ 
            {
				if (input)
                	*(*blob_infos+i)=0x20 ;
				else			
                	*(*blob_infos+i)=0x60 ;

                APP_DBG(("RISint_fetch: array blob_sqllen: %d\n",
                                                    blob_parm->array_size));
                if ( !blob_parm->array ) 
                {
#if defined (WIN32)	
                	if (ODBCDLL ) 
					{
							/* skip */
					}
					else
#endif
					{
                		APP_DBG(("RISint_exec: No array set\n"));
                    	LONGJMP(RIS_E_BAD_BLOB_STRUC );
					}
                }
			/*
				We can not check the array size by doing a strlen 
				else
				{
					if( strlen(blob_parm->array) < blob_parm->array_size )
					LONGJMP(RIS_E_BAD_BLOB_ARRAY_SIZE);

				}
			*/
           }

		if(!input)
		{
			/* Put the blob  info on network buffer */

			memcpy(RIS_write->buf.fetch.data+offset,blob_parm,
						   sizeof(ris_blob));
							
           	APP_DBG(("RISint_exec: file_used flag 0x<%x>\n", 
			((ris_blob *)(RIS_write->buf.fetch.data+offset))->file_used));
			/* Take the creating table flag out before sent to client  */
			((ris_blob *)(RIS_write->buf.fetch.data+offset))->file_used &= 0x0f;

			BLOB_STRUCT_TO_NET(RIS_arc, 
						(ris_blob *)(RIS_write->buf.fetch.data+offset));

			offset+=sizeof(ris_blob);	
			RIS_write->buf.fetch.blob_count ++;
		}	

	}
	} /* for */
	
	if(!input)
	{
		RIS_write->buf.fetch.out_data= offset; 
		/* we will put the file names after blob struc info */
		fetch_data=(char *)((int)RIS_write->buf.fetch.data+offset);

		for (i=0; i < total_num_of_blob_files; ++i)
		{
			memcpy(fetch_data,
			/* We want the null at the end of each file name */
			blob_file_name_list[i], strlen(blob_file_name_list[i])+1 );

	     	fetch_data +=strlen(blob_file_name_list[i]) +1 ;	
		}

		RIS_write->buf.fetch.file_names = total_blob_filename_length;

		APP_DBG(("RISint_fetch: RIS_write->buf.fetch.file_names %d\n",
                                    RIS_write->buf.fetch.file_names));

        APP_DBG(("RISint_fetch: (int)&(((ris_appcli_buf *)0)->buf.fetch.data) %d\n", (int)&(((ris_appcli_buf *)0)->buf.fetch.data) ));

        APP_DBG(("RISint_fetch: RIS_write_len (FETCH_BUF with blob) %d\n ", 
		RIS_write_len ));

	}

	return(blob_count);
}

extern void RISapp_fetch_one_blob_chunk( 
   	sqlvar *blob_parm_sqlvar,
	unsigned char blob_info,
	int blob_col_pos,
	int text_type,
	int *array_full)
{
	static int end_blob_chunk=0;
	int status=0;
#if defined (WIN32)
	static unsigned int odbc_binary_data_xfercount=0;
#endif
	
#if defined (WIN32)
	if (ODBCDLL && !end_blob_chunk)
	{
		/* Do not fetch more chunk from server, if
		   ODBC has not got entire chunk to user variables  */		
	}
	else
#endif
	{		
		RISapp_fetch_blob_to_buf(); 					
		RIS_write->buf.fetch_blob.blob_col_pos = blob_col_pos;	
		RIS_write->buf.fetch_blob.file_used = (blob_info &0x10)? 1:0;	

		FETCH_BLOB_TO_NET(RIS_arc,&RIS_write->buf.fetch_blob); 

		status = SETJMP();

		if(!status)
			RISapp_send_rec();
		
		RESETJMP();

		if(status)
			LONGJMP(status);

		NET_TO_FETCH_BLOB(RIS_arc, &RIS_read->buf.fetch_blob);

		end_blob_chunk=0;
	}

	/*  reconstruct the file or the mem. array */
#if defined (WIN32)
	if (ODBCDLL) 
	{
	    int len=0;	
		int difference = RIS_read->buf.fetch_blob.xfercount - 
				  			 odbc_binary_data_xfercount ;

		len =  difference > blob_parm_sqlvar->sqllen ?
			  blob_parm_sqlvar->sqllen : difference; 			

       	memcpy((char *) blob_parm_sqlvar->sqldata, 
						RIS_read->buf.fetch_blob.data+
						odbc_binary_data_xfercount,
						len); 

		odbc_binary_data_xfercount += blob_parm_sqlvar->sqllen; 

		if (odbc_binary_data_xfercount >= 
			RIS_read->buf.fetch_blob.xfercount)
		{
			odbc_binary_data_xfercount = 0;		
			end_blob_chunk=1;
			/* Telling ODBC there are no more blob data for 
				this column */
			if (RIS_read->buf.fetch_blob.more_to_follow == 0)	
       			blob_parm_sqlvar->sqlind = 0; 
			else
       			*blob_parm_sqlvar->sqlind = len; 
				
		}
		else
		{
       		*blob_parm_sqlvar->sqlind = len; 
       	}

	}
	else
#endif
	{
		status= SETJMP();

		if(!status)
			RISapp_fill_blob_parms(blob_parm_sqlvar, text_type, array_full);

		RESETJMP();

		if (status)
			LONGJMP(status);

	}

	APP_DBG(("more_to_follow %d \n", 
		RIS_read->buf.fetch_blob.more_to_follow));
}

extern void fetch_one_blob_column( 
   	sqlvar *blob_parm_sqlvar,
	unsigned char   blob_info,
	int   blob_col_pos,
	int text_type)
{
	int status=0;
	int array_full=0;

	/* if a local file is used it should have been
	    fetched by FETCH_BUF_CODE  */
	do
	{
		status= SETJMP();

		if(!status)
		{	
			RISapp_fetch_one_blob_chunk( blob_parm_sqlvar, blob_info, blob_col_pos,
								text_type, &array_full);
		}

		RESETJMP();

		if (status)
			LONGJMP(status);

		APP_DBG(("more_to_follow %d, array_full %d \n", 
			RIS_read->buf.fetch_blob.more_to_follow, array_full));
	}
	while (RIS_read->buf.fetch_blob.more_to_follow && array_full != 1);	

}


extern void RISapp_fetch_all_blob_columns( 
   	sqlda *blob_parm_sqlda,
	sqlda *stmt_sqlda,
	unsigned char *blob_infos)
{
	int i, sqld=stmt_sqlda->sqln;
	int status=0;	
	sqlvar *blob_parm_sqlvar=blob_parm_sqlda->sqlvar;
	sqlvar *stmt_sqlvar=stmt_sqlda->sqlvar;

	APP_DBG(("fetch: fetching all <%d> blob columns\n",sqld));

  	for (i=0; i<sqld; 
			stmt_sqlvar++,blob_parm_sqlvar++,i++ )
   	{
   		if( (stmt_sqlvar->sqltype==RIS_BLOB 
				 || stmt_sqlvar->sqltype==RIS_TEXT ) 
				&&   
		    /* we dont fetch the blob column unless it is non null */
           	    (!blob_parm_sqlvar->sqlind || 
					*blob_parm_sqlvar->sqlind >= 0) )
		{
			ris_blob * blob_parm = 0;

			blob_parm = (ris_blob *)blob_parm_sqlvar->sqldata;
				    
			if (blob_parm_sqlvar->sqltype != RIS_BLOB &&
					blob_parm_sqlvar->sqltype != RIS_TEXT)
			                    	LONGJMP(RIS_E_INCOMPATIBLE_TYPE);	
							
			/* We dont fetch text data to blob column */

			if (blob_parm_sqlvar->sqltype == RIS_BLOB
				&&	stmt_sqlvar->sqltype == RIS_TEXT)
			                    	LONGJMP(RIS_E_INCOMPATIBLE_TYPE);	

			/* Initialize the ouput_len */ 
			blob_parm ->output_len = (unsigned int) 0;
	
			if (blob_parm->file_used) 
			{
				char *temp_name=blob_parm->filename;
				if ( access(temp_name, 00) == -1)
				{
					int fd=0, st=0;

					/*
					** file does not exist, create it;
					** so it will not be created by
					** super user in the server.
					*/
#if defined(WIN32)
					if((fd=open(temp_name, O_CREAT | O_RDWR | O_BINARY,
							S_IREAD | S_IWRITE   ))< 0)
#else
					if((fd=open(temp_name, O_CREAT | O_RDWR,
							S_IREAD | S_IWRITE   ))< 0)
#endif
						LONGJMP(RIS_E_OPEN_BLOB_FILE_ERROR);

					/*
					** We need to change the mode
					** of the file for later access
					*/
					if ((st = chmod(temp_name, 600)) <0)
						LONGJMP(RIS_E_ACCESS_FILE_ERROR);

					if ((st = close(fd))< 0)
						LONGJMP(RIS_E_CLOSE_BLOB_FILE_ERROR);

					blob_parm->file_used |= 0x10;
				}
			}

			status= SETJMP();

			if(!status)
				fetch_one_blob_column(blob_parm_sqlvar, 
						*(blob_infos+i), 
						i,
						stmt_sqlvar->sqltype==RIS_TEXT); 
											
			RESETJMP();
			
			if (status )
				LONGJMP(status);
		}
	} /* for */
}

extern void RISapp_load_all_blob_columns(
   		sqlda *blob_parm_sqlda,
		sqlda *stmt_sqlda,
		unsigned char *blob_infos,
		int blob_count,
		unsigned char execute_mode)
{
	sqlvar *stmt_sqlvar=stmt_sqlda->sqlvar;		
	sqlvar *blob_parm_sqlvar=blob_parm_sqlda->sqlvar;		
	int sqld=stmt_sqlda->sqld, i, status;

	/* 	Sending the blob sqlvar(s) */ 
	
	for (i=0; i < sqld; stmt_sqlvar++, blob_parm_sqlvar++,i++) 
	{
	   	if( 
			(stmt_sqlvar->sqltype == RIS_BLOB || 
				blob_parm_sqlvar->sqltype == RIS_TEXT ) 
			&& blob_count
			)
		{		

			if (blob_parm_sqlvar->sqltype != RIS_BLOB &&
					blob_parm_sqlvar->sqltype != RIS_TEXT)
				LONGJMP(RIS_E_INCOMPATIBLE_TYPE);	
							
			/* We dont allow blob data insert to text type */
			if (blob_parm_sqlvar->sqltype == RIS_BLOB
				&&	stmt_sqlvar->sqltype == RIS_TEXT)


			/* set more_to_follow to 0 */
			*(blob_infos+i)=*(blob_infos+i) & 0xf0; 

			blob_count --;

			/* set more_blob_col flag */

			if (blob_count > 0)			
				*(blob_infos+i)=*(blob_infos+i) | 0x02; 
			else
			{
				*(blob_infos+i)=*(blob_infos+i) & 0xfd; 
			}

			status= SETJMP();

			if(!status)
			RISapp_load_one_blob_column( 
				blob_parm_sqlvar , 
				(blob_infos+i), 
				stmt_sqlvar->sqltype == RIS_TEXT,
				i,
				execute_mode);

			RESETJMP();

			if(status)
				LONGJMP(status);

		} 
	}
}

extern void RISapp_load_one_blob_column(
   		sqlvar *blob_parm_sqlvar,
		unsigned char *blob_info_ptr,
		int text_type,	
		int blob_col_pos,
		unsigned char execute_mode)
{
	int status=0;

	/* set input_len to 0 */
	((ris_blob *)(blob_parm_sqlvar->sqldata))->input_len = (unsigned int)0;

	do
	{
		RIS_write-> buf.exec_blob.blob_col_pos=blob_col_pos;
    	RIS_write->opcode = RISCLI_EXEC_BLOB_CODE;
    	RIS_write->stmt_id = RIS_current_stmt_id;
    	RIS_write->opcode = RISCLI_EXEC_BLOB_CODE;
    	RIS_write->execute_mode = execute_mode ;
		
		status= SETJMP();

		if(!status)
		RISapp_load_one_blob_chunk(
   			blob_parm_sqlvar,
			blob_info_ptr,
			text_type,
			0
			);

		RESETJMP();

		if(status)
			LONGJMP(status);

	} 
	while ( *blob_info_ptr & 0x01 );
		
} /* if */


extern void RISapp_load_one_blob_chunk(
   	sqlvar *blob_parm_sqlvar,
	unsigned char *	blob_info_ptr,
	int text_type,
	int odbc_end_of_column)
{
	int status=0;

#if defined(WIN32)
	static int odbc_binary_data_xfercount=0;

   	int available_write_len= RIS_write_size -
                    (int)&(((ris_appcli_buf *)0)->buf.exec_blob.data);

	if(ODBCDLL)
	{
		if(!odbc_end_of_column)  	
		/* NO data to be inserted if this is end of column */ 
		{
			memcpy(RIS_write->buf.exec_blob.data+odbc_binary_data_xfercount,
	    		blob_parm_sqlvar->sqldata,
				blob_parm_sqlvar->sqllen);     	

  			odbc_binary_data_xfercount += blob_parm_sqlvar->sqllen;
		}

		/* end of a chunk  or a column */	
		if( (available_write_len - odbc_binary_data_xfercount < 
			ODBC_MAX_SQLLEN_SIZE ) ||
			odbc_end_of_column  	
       	)
		{
    		RIS_write->buf.exec_blob.xfcount = odbc_binary_data_xfercount;

    		RIS_write_len = RIS_write->buf.exec_blob.xfcount
                    + (int)&(((ris_appcli_buf *)0)->buf.exec_blob.data);

			/* Server always assumes there are more  blob colulmns in 
				the case of ODBC, so it will not execute the insert 
				automatically */

    		RIS_write->buf.exec_blob.more_to_follow =(odbc_end_of_column)?0x02: 
													0x03;
		if(RIS_arc->remote_arch != LOCAL_ARCH)
		{
			ARC_CONVERT_SHORT(RIS_arc, TO_NET, &RIS_write->stmt_id);
		}
    		EXECUTE_BLOB_TO_NET(RIS_arc, &RIS_write->buf.exec_blob);

			
			status = SETJMP();

			if(!status)
				RISapp_send_rec();

			RESETJMP();

			if(status)
				LONGJMP(status);
		}	
	}
	else
#endif
	{

		/* To shut up compiler NON-NT */
		odbc_end_of_column=odbc_end_of_column;  	

    	RISapp_process_blob_parms(blob_parm_sqlvar, text_type,
                            (char *)(RIS_write-> buf.exec_blob.data ),
                            	blob_info_ptr);
    	APP_DBG(("RIS_write_len :%d\n", RIS_write_len));

    	RIS_write->buf.exec_blob.more_to_follow = (*blob_info_ptr & 0x01)? 0x01:0;

    	if (*blob_info_ptr & 0x02)
    	{
        	/* More blob columns ?  */
        	RIS_write->buf.exec_blob.more_to_follow |= 0x02;
    	}

    	RIS_write_len = RIS_write->buf.exec_blob.xfcount
                    + (int)&(((ris_appcli_buf *)0)->buf.exec_blob.data);

	if(RIS_arc->remote_arch != LOCAL_ARCH)
	{
		ARC_CONVERT_SHORT(RIS_arc, TO_NET, &RIS_write->stmt_id);
	}
    	EXECUTE_BLOB_TO_NET(RIS_arc, &RIS_write->buf.exec_blob);

    	APP_DBG(("RIS_write->buf.exec_blob.more_to_follow: %x\n", 
				RIS_write->buf.exec_blob.more_to_follow));

		status= SETJMP();
	
		if(!status)
			RISapp_send_rec();

		RESETJMP();

		if(status)
			LONGJMP(status);

    	APP_DBG(("exec_blob x_fercount: %d\n", 
				RIS_read->buf.exec_blob.x_fercount));

   		((ris_blob *)blob_parm_sqlvar->sqldata)->input_len +=
		RIS_read->buf.exec_blob.x_fercount;

	}
}
