/*
**	NAME:							appparms.c
**	AUTHORS:						Terry McIntyre
**	CREATION DATE:					12/91
**	ABSTRACT:
**	
**	REVISION HISTORY:
*/
#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <errno.h>
#include <unistd.h>

#include "risapp.h"
#include "riscom.h"
#include "ristypes.h"

#define DATA_NUMERIC_LITERAL     0
#define DATA_DECIMAL_FOUND       1
#define DATA_NOT_NUMERIC_LITERAL 2

static void int_to_dest    (int     i, sqlvar *dest);
static void short_to_dest  (short   s, sqlvar *dest);
static void double_to_dest (double  d, sqlvar *dest);
static void float_to_dest  (float	  f, sqlvar *dest);
static void char_to_dest   (char    c, sqlvar *dest);
static void string_to_dest (char   *s, short s_len, sqlvar *dest, int input);
static void decimal_to_dest(char *dec, short dec_len, short dec_scale, sqlvar *dest, int input);
static void dtime_to_dest  (dtime  *d, sqlvar *dest);
static void zero_to_dest   (           sqlvar *dest);

/******************************************************************************/

extern void RISapp_move_to_next_row()
{
	/* This function is called by RISXint_fetch() after successfull copy of
	   data from internal buffer to user variables and by SQLGetData() after
	   successfull copy of data.
	*/
	RIS_stmt->row += RIS_stmt->output_len;
	RIS_stmt->row_count--;
	APP_DBG(("RISapp_move_to_next_row:new row_count:%d\n", 
		RIS_stmt->row_count));
}

/******************************************************************************/

extern void RISapp_adjust_parms(sqlda *parms, char *buf)
{
	int	i;
	int	delta;

	APP_DBG(("RISapp_adjust_parms(parms:0x%x buf:0x%x)\n", parms, buf));

	if (parms)
	{
		delta = (int)buf - (int)parms->sqlvar[0].sqlind;

		APP_DBG(("RISapp_adjust_parms:delta:%d\n", delta));

		for (i=0;i < parms->sqld;i++)
		{

		APP_DBG(("RIS_app_adjust_parms: old sqlind: 0x%x old sqldata: 0x%x\n",
		 parms->sqlvar[i]. sqlind,parms->sqlvar[i].sqldata));

			parms->sqlvar[i].sqlind =
				(long *)((int)parms->sqlvar[i].sqlind + delta);
			parms->sqlvar[i].sqldata =
				(char *)((int)parms->sqlvar[i].sqldata + delta);

		APP_DBG(("RIS_app_adjust_parms: new sqlind: 0x%x new sqldata: 0x%x\n",
		 parms->sqlvar[i].sqlind, parms->sqlvar[i].sqldata));
		}
	}

	APP_DBG(("RISapp_adjust_parms:complete\n"));
}

/******************************************************************************/

extern void RISapp_fill_blob_parms(sqlvar *output_sqlvar, int text_type, int *array_full)
{
	static  		int fd=0;
	static  		unsigned total_len=0;

	int         len=0;   
	unsigned char  	*buffer=0;

	/* ret_status is checked for value <= 0 from a write() system call.
	   so it has to be defined int, not unsigned ( __hpux__ ) */
	/* unsigned int         ret_status=0; */
	int         ret_status=0;

	struct 		ris_cliapp_fetch_blob *cl_ap_fetch_blob=0;
	ris_blob        *output_blob=0;

	cl_ap_fetch_blob=&RIS_read->buf.fetch_blob;	
	output_blob=(ris_blob *) output_sqlvar->sqldata;

#if defined (__hpux__)
	ARC_NET_TO_INTEGER(RIS_arc,&RIS_read->buf.fetch_blob.xfercount);
#endif

	len=(int)RIS_read->buf.fetch_blob.xfercount;

   	APP_DBG(("RISapp_fill_blob_parms : data len %d\n", len));
   	APP_DBG(("RIS_read->buf.fetch_blob.xfercount %d\n",
               RIS_read->buf.fetch_blob.xfercount));
	APP_DBG(("RISapp_fill_blob_parms : RIS_read_len %d\n", RIS_read_len));

	buffer=RIS_read->buf.fetch_blob.data;

	/* Do data conversion is TEXT type is used */
	if ( len > 0 && text_type )
	{
		ARC_CONVERT_DATA(RIS_arc, FROM_NET, buffer, len);
	}

	if (output_blob->filename && output_blob->file_used > 0)
	{
		/*
		** Do not try to recreate the file if nothing has been retrieved 
		** if len is set to -1, it means the client already put data
		** in the file. If it is set to 0, it indicates it is a local
		** file,  server should have put the data in the file
		*/
		if ( len > 0 )
		{	
			if (!fd)
			{
				/* 1st time here open the file */
				int st;	

				st = access(output_blob->filename, 00);
				if (st  < 0)
				{  /* file does not exist */
#if defined(WIN32)
					fd=open(output_blob->filename,  
					O_CREAT | O_RDWR | O_APPEND | O_BINARY,
								S_IREAD | S_IWRITE );
#else
					fd=open(output_blob->filename,  
						O_CREAT | O_RDWR | O_APPEND,
								S_IREAD | S_IWRITE );
#endif
					if (fd< 0)
						LONGJMP(RIS_E_OPEN_BLOB_FILE_ERROR);

					output_blob->file_used |= 0x10;  
				} 
				else
				{
					if (output_blob->file_offset <= 0)
					{
						/* No file offset, start from beginning of file */
#if defined(WIN32)
						fd=open(output_blob->filename,  
							O_TRUNC | O_RDWR | O_APPEND | O_BINARY);
#else
						fd=open(output_blob->filename,  
							O_TRUNC | O_RDWR | O_APPEND );
#endif
						if (fd < 0)
							LONGJMP(RIS_E_OPEN_BLOB_FILE_ERROR);
					}
					else
					{
						struct stat file_st;
						long int seek_size=0;
#if defined(WIN32)
						fd=open(output_blob->filename, O_RDWR | O_BINARY );
#else
						fd=open(output_blob->filename, O_RDWR );
#endif
						if (fd < 0)
							LONGJMP(RIS_E_OPEN_BLOB_FILE_ERROR);

						st = stat (output_blob->filename, &file_st);
						if (st == -1 )
						    LONGJMP(RIS_E_ACCESS_BLOB_FILE_ERROR);

						/* If offset spcified is biger than
						       size of the file, we will append the
						       data to the end of file.   */

						seek_size= ((unsigned)file_st.st_size <
							    output_blob->file_offset) ?
							    file_st.st_size : output_blob->file_offset;

						st=lseek(fd, seek_size , 0);
						if(st< 0)
							LONGJMP(RIS_E_ACCESS_BLOB_FILE_ERROR);
					}
				}	
		
			}
 		
                        /*
                        ** Cast buffer to (char *) to shut up 'acc' on SunOS
                        ** No other compiler should complain.      -Surjit-
                        */
        	ret_status=write(fd, (char *)buffer,len);
        	if (ret_status <= 0)
        	{
				APP_DBG(("Errno %d, fd %d, len %d: \n", errno, fd, len));
    			APP_DBG(("output_blob->filename: %s\n",
							output_blob->filename ))  
              		LONGJMP(RIS_E_WRITE_BLOB_FILE_ERROR);
        	}
			output_blob->output_len+=len;
		}
		else if ( len == -1 )
		{
			/* The output file has been filled  by client,
			all we need to do here is to return the output_len  */ 
			output_blob->output_len = *(int *)RIS_read->buf.fetch_blob.data;
		}

	}
	else if (output_blob->array && output_blob->file_used  == 0)
	{ /* Mem is used */
		int len_to_copy=0;

		if ((int )(output_blob->array_size - total_len) > len)
        	{
			len_to_copy=len;
			*array_full=0;
        	}
		else
        	{
			len_to_copy = output_blob->array_size - total_len;
			*array_full = 1;
        	}

		memcpy((char *)(output_blob->array+total_len),buffer,len_to_copy);	
		total_len += len_to_copy;	
		output_blob->output_len+=len_to_copy;
	}
	else
	{
		LONGJMP(RIS_E_BAD_BLOB_STRUC);
		APP_DBG(("RISapp_process_parms: blob structure values are not valid\n"));
	}

	if (! RIS_read->buf.fetch_blob.more_to_follow) 
	/* reinitialize fd for next blob column */
	{
	 	if(fd && (close(fd) < 0) ) 
       		LONGJMP(RIS_E_CLOSE_BLOB_FILE_ERROR);
		fd=0;
		total_len = 0 ;
	}
}
/******************************************************************************/

extern void RISapp_process_parms(sqlda *source, sqlda *dest, int input)
{
	int		i;
	int		num_parms;

	APP_DBG(("RISapp_process_parms(source:0x%x dest:0x%x input:%d)\n",
		source, dest, input));

	if (input)
	{
		if (source->sqln < dest->sqld)
		{
			LONGJMP(RIS_E_NOT_ENOUGH_SQLVARS);
		}
		num_parms = dest->sqld;
	}
	else
	{
#if defined(WIN32)
		if (ODBCDLL)
		{
			/*	ODBC allows some unbound columns
				Similar change can be made for input params
				-Hitesh 12/2/93
			*/
			num_parms = dest->sqld;
		}
		else
#endif
		{
			if (source->sqld > dest->sqln)
			{
				LONGJMP(RIS_E_NOT_ENOUGH_SQLVARS);
			}
			num_parms = source->sqld;
		}
	}
	APP_DBG(("RISapp_process_parms: num_parms:%d\n",num_parms));

	/*	For SQLGetData() i can be just the column number needed. Previous 
		columns are already done. This improvement can be done later by 
		passing start and end values for following 'for' loops
		-Hitesh 12/2/93
	*/
	for (i = 0;i < num_parms;i++)
	{
		RISapp_process_one_parm(source, dest, input, i);
	}
}

/******************************************************************************/

extern void RISapp_process_one_parm(sqlda *source, sqlda *dest, int input, int iparam)
{
	int i = iparam;

	APP_DBG(("RISapp_process_one_parm: parameter #%d\n", i));

	if (input)
	{
		if (!&source->sqlvar[i] ||
			!source->sqlvar[i].sqldata ||
			!source->sqlvar[i].sqltype)
		{
			LONGJMP(RIS_E_COL_NOT_BOUND);
		}
	}
	else
	{
		if (!&dest->sqlvar[i] ||
			!dest->sqlvar[i].sqldata ||
			!dest->sqlvar[i].sqltype)
		{
			LONGJMP(RIS_E_COL_NOT_BOUND);
		}
	}

	APP_DBG(("RISapp_process_parms:source:sqlnull:%d sqlind addr:0x%x\n"
			 "RISapp_process_parms:dest: sqlnull:%d sqlind addr:0x%x\n",
		source->sqlvar[i].sqlnull, source->sqlvar[i].sqlind,
		dest->sqlvar[i].sqlnull, dest->sqlvar[i].sqlind));

	if (source->sqlvar[i].sqlnull)
	{
		if (!source->sqlvar[i].sqlind)
		{
			LONGJMP(RIS_E_MISSING_IND);
		}

		APP_DBG(("RISapp_process_parms: source sqlind value:%d\n",
			*source->sqlvar[i].sqlind));

		if (dest->sqlvar[i].sqlnull)
		{
			if (!dest->sqlvar[i].sqlind)
			{
				LONGJMP(RIS_E_MISSING_IND);
			}
			*dest->sqlvar[i].sqlind = *source->sqlvar[i].sqlind;

		}
		else if (*source->sqlvar[i].sqlind < 0)
		{
			LONGJMP(RIS_E_INV_IND);
		}
	}
	else
	{
		APP_DBG(("RISapp_process_parms: source sqlind value: Undefined\n"));
		if (dest->sqlvar[i].sqlnull)
		{
			if (!dest->sqlvar[i].sqlind)
			{
				LONGJMP(RIS_E_MISSING_IND);
			}
			*dest->sqlvar[i].sqlind = 0;
			APP_DBG(("RISapp_process_parms: dest sqlind value:%d\n",
				*dest->sqlvar[i].sqlind));
		}
		else
		{
			if (dest->sqlvar[i].sqlind)
			{
				*dest->sqlvar[i].sqlind = 0;
				APP_DBG(("RISapp_process_parms: dest sqlind value:%d\n",
					*dest->sqlvar[i].sqlind));
			}
		}
	}

	APP_DBG(("RISapp_process_parms:source:sqldata addr:0x%x sqltype:<%s> "
		"sqllen:%d\n", source->sqlvar[i].sqldata,
		RIS_types[source->sqlvar[i].sqltype].string,
		source->sqlvar[i].sqllen));

	APP_DBG(("RISapp_process_parms:dest:  sqldata addr:0x%x sqltype:<%s> "
		"sqllen:%d\n", dest->sqlvar[i].sqldata,
		RIS_types[dest->sqlvar[i].sqltype].string,
		dest->sqlvar[i].sqllen));

	if (!source->sqlvar[i].sqlind || *source->sqlvar[i].sqlind >= 0)
	{
		switch(source->sqlvar[i].sqltype)
		{
			case RIS_INTEGER:
				int_to_dest(*(int*)source->sqlvar[i].sqldata,
					&dest->sqlvar[i]);
				break;

			case RIS_SMALLINT:
				short_to_dest(*(short*)source->sqlvar[i].sqldata,
					&dest->sqlvar[i]);
				break;

			case RIS_DOUBLE:
				double_to_dest(*(double*)source->sqlvar[i].sqldata,
					&dest->sqlvar[i]);
				break;

			case RIS_REAL:
				float_to_dest(*(float*)source->sqlvar[i].sqldata,
					&dest->sqlvar[i]);
				break;

			case RIS_CHARACTER:
				if (source->sqlvar[i].sqllen == -1)
				{
					char_to_dest(*source->sqlvar[i].sqldata,
						&dest->sqlvar[i]);
				}
				else
				{
					string_to_dest(source->sqlvar[i].sqldata,
						source->sqlvar[i].sqllen,
						&dest->sqlvar[i], input);
				}
				break;

			case RIS_DECIMAL:
				decimal_to_dest(source->sqlvar[i].sqldata,
					source->sqlvar[i].sqllen, source->sqlvar[i].sqlscale,
					&dest->sqlvar[i], input);
				break;

			case RIS_DATETIME:
				dtime_to_dest((dtime *)source->sqlvar[i].sqldata,
					&dest->sqlvar[i]);
				break;
			
			case RIS_BLOB:
			case RIS_TEXT:
				/*  
					Due to the posibility of multiple blob columns
					in one table, we will pack each blob strucrure 
					into sqldata
				*/
				if (dest->sqlvar[i].sqltype != RIS_BLOB && 
						dest->sqlvar[i].sqltype != RIS_TEXT)
				{
					APP_DBG(("RISapp_process_parms: INCOMPATIBLE_TYPE\n"));
						LONGJMP(RIS_E_INCOMPATIBLE_TYPE);
				}

				if(input) 
				memcpy(dest->sqlvar[i].sqldata, source->sqlvar[i].sqldata, 
						sizeof(ris_blob));
				else /* output */
				{
					/*
						During select, we need to leave the sqlvar->sqldata 
						intact, it has the blob information  we need.
						except the output_len which is returned by server
					*/
					((ris_blob *) dest->sqlvar[i].sqldata) -> output_len =	
					((ris_blob *) source->sqlvar[i].sqldata) -> output_len;	
				}	
				break;

			default:
				APP_DBG(("RISapp_process_parms: INV_TYPE\n"));
				LONGJMP(RIS_E_INV_TYPE);
				break;
		}
	}
	else
	{
		zero_to_dest(&dest->sqlvar[i]);
	}

	APP_DBG(("RISapp_process_one_parm: complete\n"));
}

/******************************************************************************/

static void int_to_dest(int i, sqlvar *dest)
{
	APP_DBG(("RISapp_process_parms: source sqldata value:%d\n",i));

	switch(dest->sqltype)
	{
		case RIS_INTEGER:
			*(int*)dest->sqldata = i;

			APP_DBG(("RISapp_process_parms:dest sqldata value:%d\n",
				*(int*)dest->sqldata));

			break;

		case RIS_SMALLINT:
#if defined(WIN32)
			if (ODBCDLL)
			{
				if (i > SHRT_MAX || i < SHRT_MIN)
				{
					APP_DBG(("RISapp_process_parms:Out of Range(short)\n"));
					/* SqlState "22003" */
					LONGJMP(RIS_E_NUM_OUT_OF_RANGE);
				}
			}
#endif
			*(short*)dest->sqldata = (short)i;

			APP_DBG(("RISapp_process_parms: dest sqldata value: %d\n",
				*(short*)dest->sqldata));

			break;
			
		case RIS_DOUBLE:
			*(double*)dest->sqldata = (double)i;

			APP_DBG(("RISapp_process_parms: dest sqldata value: %.15lg\n",
				*(double*)dest->sqldata));
			break;

		case RIS_REAL:
			*(float*)dest->sqldata = (float)i;

			APP_DBG(("RISapp_process_parms: dest sqldata value: %.7g\n",
				*(float*)dest->sqldata));
			break;

		case RIS_DECIMAL:
			RISapp_int_to_decimal(i, dest->sqldata, dest->sqllen,
				dest->sqlscale);
			APP_DBG(("RISapp_process_parms: dest sqldata value: <%s>\n",
				dest->sqldata));
			break;

        /*  BLOB */
        case RIS_BLOB:
        case RIS_TEXT:
            APP_DBG(("RISapp_process_parms: INCOMPATIBLE_TYPE\n"));
            LONGJMP(RIS_E_INCOMPATIBLE_TYPE);
            break;

		case RIS_CHARACTER:
#if defined(WIN32)
			if (ODBCDLL)
			{
				RISapp_int_to_string(&i, RIS_INTEGER, dest->sqldata, 
					dest->sqllen);
			}
			else
#endif
			{
				APP_DBG(("RISapp_process_parms: INCOMPATIBLE_TYPE\n"));
				LONGJMP(RIS_E_INCOMPATIBLE_TYPE);
			}
			break;

		case RIS_DATETIME:
			APP_DBG(("RISapp_process_parms: INCOMPATIBLE_TYPE\n"));
			LONGJMP(RIS_E_INCOMPATIBLE_TYPE);
			break;

		default:
			APP_DBG(("RISapp_process_parms: INV_TYPE\n"));
			LONGJMP(RIS_E_INV_TYPE);
			break;
	}
}

/******************************************************************************/

static void short_to_dest(short s, sqlvar *dest)
{
	APP_DBG(("RISapp_process_parms: source sqldata value: %d\n", s));

	switch(dest->sqltype)
	{
		case RIS_INTEGER:
			*(int*)dest->sqldata = (int)s;
			APP_DBG(("RISapp_process_parms: dest sqldata value: %d\n",
				*(int*)dest->sqldata));
			break;

		case RIS_SMALLINT:
			*(short*)dest->sqldata = s;
			APP_DBG(("RISapp_process_parms: dest sqldata value: %d\n",
				*(short*)dest->sqldata));
			break;

		case RIS_DOUBLE:
			*(double*)dest->sqldata = (double)s;
			APP_DBG(("RISapp_process_parms: dest sqldata value: %.15lg\n",
				*(double*)dest->sqldata));
			break;

		case RIS_REAL:
			*(float*)dest->sqldata = (float)s;
			APP_DBG(("RISapp_process_parms: dest sqldata value: %.7g\n",
				*(float*)dest->sqldata));
			break;

		case RIS_DECIMAL:
			RISapp_int_to_decimal((int)s, dest->sqldata, dest->sqllen,
				dest->sqlscale);
			APP_DBG(("RISapp_process_parms: dest sqldata value: <%s>\n",
				dest->sqldata));
			break;

		case RIS_CHARACTER:
#if defined(WIN32)
			if (ODBCDLL)
			{
				RISapp_int_to_string(&s, RIS_SMALLINT, dest->sqldata, 
					dest->sqllen);
			}
			else
#endif
			{
				APP_DBG(("RISapp_process_parms: INCOMPATIBLE_TYPE\n"));
				LONGJMP(RIS_E_INCOMPATIBLE_TYPE);
			}
			break;

		case RIS_DATETIME:
			APP_DBG(("RISapp_process_parms: INCOMPATIBLE_TYPE\n"));
			LONGJMP(RIS_E_INCOMPATIBLE_TYPE);
			break;

        /*  BLOB */
        case RIS_BLOB:
        case RIS_TEXT:
            APP_DBG(("RISapp_process_parms: INCOMPATIBLE_TYPE\n"));
            LONGJMP(RIS_E_INCOMPATIBLE_TYPE);
            break;

		default:
			APP_DBG(("RISapp_process_parms: INV_TYPE\n"));
			LONGJMP(RIS_E_INV_TYPE);
			break;
	}
}

/******************************************************************************/

static void double_to_dest(double d, sqlvar *dest)
{
	APP_DBG(("RISapp_process_parms: source sqldata value: %.15lg\n", d));

	switch(dest->sqltype)
	{
		case RIS_INTEGER:
#if defined(WIN32)
			if (ODBCDLL)
			{
				if (d > (double)INT_MAX || d < (double)INT_MIN)
				{
					APP_DBG(("RISapp_process_parms:Out of Range(int)\n"));
					/* SqlState "22003" */
					LONGJMP(RIS_E_NUM_OUT_OF_RANGE);
				}
				check_double_to_int_truncation(&d, RIS_DOUBLE, dest->sqltype, 
					dest->sqlind);
			}
#endif
			*(int*)dest->sqldata = (int)d;
			APP_DBG(("RISapp_process_parms: dest sqldata value: %d\n",
				*(int*)dest->sqldata));
			break;

		case RIS_SMALLINT:
#if defined(WIN32)
			if (ODBCDLL)
			{
				if (d > (double)SHRT_MAX || d < (double)SHRT_MIN)
				{
					APP_DBG(("RISapp_process_parms:Out of Range(short)\n"));
					/* SqlState "22003" */
					LONGJMP(RIS_E_NUM_OUT_OF_RANGE);
				}
				check_double_to_int_truncation(&d, RIS_DOUBLE, dest->sqltype, 
					dest->sqlind);
			}
#endif
			*(short*)dest->sqldata = (short)d;
			APP_DBG(("RISapp_process_parms: dest sqldata value: %d\n",
				*(short*)dest->sqldata));
			break;

		case RIS_DOUBLE:
			*(double*)dest->sqldata = d;
			APP_DBG(("RISapp_process_parms: dest sqldata value: %.15lg\n",
				*(double*)dest->sqldata));
			break;

		case RIS_REAL:
#if defined(WIN32)
			if (ODBCDLL)
			{
				if (d > (double)FLT_MAX || d < -(double)FLT_MAX)
				{
					APP_DBG(("RISapp_process_parms:Out of Range(float)\n"));
					/* SqlState "22003" */
					LONGJMP(RIS_E_NUM_OUT_OF_RANGE);
				}
				/* This would always fail 'cuz value will be rounded.
				   Actually, check not required as it is with float's range.
				check_double_to_float_truncation(&d, RIS_DOUBLE, dest->sqltype, 
					dest->sqlind);
				*/
			}
#endif
			*(float*)dest->sqldata = (float)d;
			APP_DBG(("RISapp_process_parms: dest sqldata value: %.7g\n",
				*(float*)dest->sqldata));
			break;

		case RIS_DECIMAL:
			RISapp_double_to_decimal(d, dest->sqldata, dest->sqllen,
				dest->sqlscale);
			APP_DBG(("RISapp_process_parms: dest sqldata value: <%s>\n",
				dest->sqldata));
			break;

		case RIS_CHARACTER:
#if defined(WIN32)
			if (ODBCDLL)
			{
				RISapp_double_to_string(&d, RIS_DOUBLE, dest->sqldata, 
					dest->sqllen);
				APP_DBG(("RISapp_process_parms: dest sqldata value: <%s>\n",
					dest->sqldata));
			}
			else
#endif
			{
				APP_DBG(("RISapp_process_parms: INCOMPATIBLE_TYPE\n"));
				LONGJMP(RIS_E_INCOMPATIBLE_TYPE);
			}
			break;

		case RIS_DATETIME:
			APP_DBG(("RISapp_process_parms: INCOMPATIBLE_TYPE\n"));
			LONGJMP(RIS_E_INCOMPATIBLE_TYPE);
			break;

        /*  BLOB */
        case RIS_BLOB:
        case RIS_TEXT:
            APP_DBG(("RISapp_process_parms: INCOMPATIBLE_TYPE\n"));
            LONGJMP(RIS_E_INCOMPATIBLE_TYPE);
            break;


		default:
			APP_DBG(("RISapp_process_parms: INV_TYPE\n"));
			LONGJMP(RIS_E_INV_TYPE);
			break;
	}
}

/******************************************************************************/

static void float_to_dest(float	f, sqlvar *dest)
{
	APP_DBG(("RISapp_process_parms: source sqldata value: %.7g\n", f));

	switch(dest->sqltype)
	{
		case RIS_INTEGER:
#if defined(WIN32)
			if (ODBCDLL)
			{
				if (f > (float)INT_MAX || f < (float)INT_MIN)
				{
					APP_DBG(("RISapp_process_parms:Out of Range(int)\n"));
					/* SqlState "22003" */
					LONGJMP(RIS_E_NUM_OUT_OF_RANGE);
				}
				check_double_to_int_truncation(&f, RIS_REAL, dest->sqltype, 
					dest->sqlind);
			}
#endif
			*(int*)dest->sqldata = (int)f;
			APP_DBG(("RISapp_process_parms: dest sqldata value: %d\n",
				*(int*)dest->sqldata));
			break;

		case RIS_SMALLINT:
#if defined(WIN32)
			if (ODBCDLL)
			{
				if (f > (float)SHRT_MAX || f < (float)SHRT_MIN)
				{
					APP_DBG(("RISapp_process_parms:Out of Range(short)\n"));
					/* SqlState "22003" */
					LONGJMP(RIS_E_NUM_OUT_OF_RANGE);
				}
				check_double_to_int_truncation(&f, RIS_REAL, dest->sqltype, 
					dest->sqlind);
			}
#endif
			*(short*)dest->sqldata = (short)f;
			APP_DBG(("RISapp_process_parms: dest sqldata value: %d\n",
				*(short*)dest->sqldata));
			break;

		case RIS_DOUBLE:
			*(double*)dest->sqldata = (double)f;
			APP_DBG(("RISapp_process_parms: dest sqldata value: %.15lg\n",
				*(double*)dest->sqldata));
			break;

		case RIS_REAL:
			*(float*)dest->sqldata = f;
			APP_DBG(("RISapp_process_parms: dest sqldata value: %.7g\n",
				*(float*)dest->sqldata));
			break;

		case RIS_DECIMAL:
			RISapp_double_to_decimal((double)f, dest->sqldata,
				dest->sqllen, dest->sqlscale);
			APP_DBG(("RISapp_process_parms: dest sqldata value: <%s>\n",
				dest->sqldata));
			break;

		case RIS_CHARACTER:
#if defined(WIN32)
			if (ODBCDLL)
			{
				RISapp_double_to_string(&f, RIS_REAL, dest->sqldata, 
					dest->sqllen);
				APP_DBG(("RISapp_process_parms: dest sqldata value: <%s>\n",
					dest->sqldata));
			}
			else
#endif
			{
				APP_DBG(("RISapp_process_parms: INCOMPATIBLE_TYPE\n"));
				LONGJMP(RIS_E_INCOMPATIBLE_TYPE);
			}
			break;

		case RIS_DATETIME:
			LONGJMP(RIS_E_INCOMPATIBLE_TYPE);
			APP_DBG(("RISapp_process_parms: INCOMPATIBLE_TYPE\n"));
			break;

        /*  BLOB */
        case RIS_BLOB:
        case RIS_TEXT:
            APP_DBG(("RISapp_process_parms: INCOMPATIBLE_TYPE\n"));
            LONGJMP(RIS_E_INCOMPATIBLE_TYPE);
            break;

		default:
			LONGJMP(RIS_E_INV_TYPE);
			APP_DBG(("RISapp_process_parms: INV_TYPE\n"));
			break;
	}
}

/******************************************************************************/

static void char_to_dest(char c, sqlvar *dest)
{
	APP_DBG(("RISapp_process_parms: source sqldata value: %c\n", c));

	switch(dest->sqltype)
	{
		case RIS_CHARACTER:
			dest->sqldata[0] = c;
			dest->sqldata[1] = '\0';
			APP_DBG(("RISapp_process_parms: dest sqldata value: <%s>\n",
				dest->sqldata));
			break;

		case RIS_INTEGER:
		case RIS_SMALLINT:
		case RIS_DOUBLE:
		case RIS_REAL:
		case RIS_DATETIME:
		case RIS_DECIMAL:
        /*  BLOB */
        case RIS_BLOB:
        case RIS_TEXT:
			APP_DBG(("RISapp_process_parms: INCOMPATIBLE_TYPE\n"));
			LONGJMP(RIS_E_INCOMPATIBLE_TYPE);
			break;

		default:
			LONGJMP(RIS_E_INV_TYPE);
			APP_DBG(("RISapp_process_parms: INV_TYPE\n"));
			break;
	}
}

/******************************************************************************/

static void string_to_dest(char *s, short s_len, sqlvar *dest, int input)
{
	APP_DBG(("RISapp_process_parms: source sqldata value: <%s>\n", s));

	switch(dest->sqltype)
	{
		case RIS_CHARACTER:
			if (dest->sqllen == -1)
			{
				dest->sqldata[0] = s[0];
				APP_DBG(("RISapp_process_parms: dest sqldata value: %c\n",
					*dest->sqldata));
			}
			else
			{
				strncpy(dest->sqldata, s, dest->sqllen); /*itbokic */

				if (input)
				{
					dest->sqldata[dest->sqllen] = '\0';
				}

#if defined(WIN32)
				if (ODBCDLL)
				{
					/* s should be null-terminated string */
					if (dest->sqllen <= (short)strlen(s))
					{
						*dest->sqlind = strlen(s);
					}
				}
				else
#endif
				{
					if (dest->sqllen < s_len &&
						dest->sqlind)
					{
						*dest->sqlind = s_len;
					}
				}

				APP_DBG(("RISapp_process_parms: dest sqldata value: <%s>\n",
					dest->sqldata));
			}
		break;

		case RIS_DECIMAL:
			if (!input)
			{
				APP_DBG(("RISapp_process_parms: INCOMPATIBLE_TYPE\n"));
				LONGJMP(RIS_E_INCOMPATIBLE_TYPE);
			}

			APP_DBG(("RISapp_process_parms: dest sqlscale: %d\n",
				dest->sqlscale));

			RISapp_char_to_decimal(s, s_len,
				dest->sqldata,
				dest->sqllen,
				dest->sqlscale);

			APP_DBG(("RISapp_process_parms: dest sqldata value: <%s>\n",
				dest->sqldata));
			break;

		case RIS_INTEGER:
		case RIS_SMALLINT:
#if defined(WIN32)
			if (ODBCDLL)
			{
				RISapp_string_to_int(s, (short)strlen(s), dest->sqldata, 
					dest->sqltype, dest->sqlind);
			}
			else
#endif
			{
				APP_DBG(("RISapp_process_parms: INCOMPATIBLE_TYPE\n"));
				LONGJMP(RIS_E_INCOMPATIBLE_TYPE);
			}
			break;

		case RIS_DOUBLE:
		case RIS_REAL:
#if defined(WIN32)
			if (ODBCDLL)
			{
				RISapp_string_to_double(s, (short)strlen(s), dest->sqldata, 
					dest->sqltype, dest->sqlind);
			}
			else
#endif
			{
				APP_DBG(("RISapp_process_parms: INCOMPATIBLE_TYPE\n"));
				LONGJMP(RIS_E_INCOMPATIBLE_TYPE);
			}
			break;


		case RIS_DATETIME:
		case RIS_BLOB:
		case RIS_TEXT:
			APP_DBG(("RISapp_process_parms: INCOMPATIBLE_TYPE\n"));
			LONGJMP(RIS_E_INCOMPATIBLE_TYPE);
			break;

		default:
			LONGJMP(RIS_E_INV_TYPE);
			APP_DBG(("RISapp_process_parms: INV_TYPE\n"));
			break;
	}
}

/******************************************************************************/

static void decimal_to_dest(char *dec, short dec_len, short dec_scale, sqlvar *dest, int input)
{
	double	temp;

	APP_DBG(("RISapp_process_parms: source sqldata value:<%s> sqlscale:%d\n",
		dec, dec_scale));

	switch(dest->sqltype)
	{
		case RIS_INTEGER:
#if defined(WIN32)
			if (ODBCDLL)
			{
				RISapp_string_to_int(dec, (short)strlen(dec), dest->sqldata, 
					dest->sqltype, dest->sqlind);
			}
			else
#endif
			{
				temp = atof(dec);
				temp += (temp >= 0.0) ? 0.5 : -0.5;
				*(int*)dest->sqldata = (int)temp;
				APP_DBG(("RISapp_process_parms: dest sqldata value: %d\n",
					*(int*)dest->sqldata));
			}
			break;

		case RIS_SMALLINT:
#if defined(WIN32)
			if (ODBCDLL)
			{
				RISapp_string_to_int(dec, (short)strlen(dec), dest->sqldata, 
					dest->sqltype, dest->sqlind);
			}
			else
#endif
			{
				temp = atof(dec);
				temp += (temp >= 0.0) ? 0.5 : -0.5;
				*(short*)dest->sqldata = (short)temp;
				APP_DBG(("RISapp_process_parms: dest sqldata value: %d\n",
					*(short*)dest->sqldata));
			}
			break;

		case RIS_DOUBLE:
#if defined(WIN32)
			if (ODBCDLL)
			{
				RISapp_string_to_double(dec, (short)strlen(dec), dest->sqldata, 
					dest->sqltype, dest->sqlind);
			}
			else
#endif
			{
				*(double*)dest->sqldata = atof(dec);
				APP_DBG(("RISapp_process_parms: dest sqldata value: %0.15e\n",
					*(double*)dest->sqldata));
			}
			break;

		case RIS_REAL:
#if defined(WIN32)
			if (ODBCDLL)
			{
				RISapp_string_to_double(dec, (short)strlen(dec), dest->sqldata, 
					dest->sqltype, dest->sqlind);
			}
			else
#endif
			{
				*(float*)dest->sqldata = (float)atof(dec);
				APP_DBG(("RISapp_process_parms: dest sqldata value: %0.6e\n",
					*(float*)dest->sqldata));
			}
			break;

		case RIS_CHARACTER:
			if (input)
			{
				APP_DBG(("RISapp_process_parms: INCOMPATIBLE_TYPE\n"));
				LONGJMP(RIS_E_INCOMPATIBLE_TYPE);
			}
			if (dest->sqllen == -1)
			{
				APP_DBG(("RISapp_process_parms: INCOMPATIBLE_TYPE\n"));
				LONGJMP(RIS_E_INCOMPATIBLE_TYPE);
			}
			/* NO BREAK */

		case RIS_DECIMAL:
			APP_DBG(("RISapp_process_parms: dest sqlscale: %d\n",
				dest->sqlscale));

			if (input)
			{
				RISapp_char_to_decimal(dec, dec_len,
					dest->sqldata,
					dest->sqllen,
					dest->sqlscale);
			}
			else
			{
				if(RIScom_set_prec_scale(dec, dec_len, dest->sqldata, 
						dest->sqllen, dec_len - 3, dec_scale))
					            LONGJMP(RIS_E_DECIMAL_EXCEEDS_PREC);
			}
			APP_DBG(("RISapp_process_parms: dest sqldata value: <%s>\n",
				dest->sqldata));

			break;
		case RIS_DATETIME:
		case RIS_BLOB:
		case RIS_TEXT:
			LONGJMP(RIS_E_INCOMPATIBLE_TYPE);
			break;
		default:
			LONGJMP(RIS_E_INV_TYPE);
		break;
	}
}

/******************************************************************************/

static void dtime_to_dest(dtime *d, sqlvar *dest)
{
	if (RISapp_debug)
	{
		RIScom_output_debug("RISapp_process_parms: source sqldata value:");
		RIScom_output_datetime(RIScom_output_debug, d);
		RIScom_output_debug("\n");
	}
	switch(dest->sqltype)
	{
		case RIS_DATETIME:
			memcpy(dest->sqldata, d, sizeof(dtime));
			if (RISapp_debug)
			{
				RIScom_output_debug("RISapp_process_parms: dest sqldata value:");
				RIScom_output_datetime(RIScom_output_debug,
					(dtime *)dest->sqldata);
				RIScom_output_debug("\n");
			}
			break;

		case RIS_INTEGER:
		case RIS_SMALLINT:
		case RIS_DOUBLE:
		case RIS_REAL:
		case RIS_CHARACTER:
		case RIS_DECIMAL:
		case RIS_BLOB:
		case RIS_TEXT:
			APP_DBG(("RISapp_process_parms: INCOMPATIBLE_TYPE\n"));
			LONGJMP(RIS_E_INCOMPATIBLE_TYPE);
			break;

		default:
			APP_DBG(("RISapp_process_parms: INV_TYPE\n"));
			LONGJMP(RIS_E_INV_TYPE);
			break;
	}
}

static void zero_to_dest(sqlvar *dest)
{
	switch(dest->sqltype)
	{
		case RIS_BLOB:
		case RIS_TEXT:
		{
			ris_blob *blob_info = (ris_blob *)dest->sqldata;
			if ( (blob_info -> file_used & 0x10) == 0x10)
			{
				/* The output file is created by ris, delete it */ 
				RIScom_remove(blob_info -> filename);
			}	
			blob_info -> output_len = 0;	
			blob_info -> input_len = 0;	

			if (RISapp_debug)
			{
				RIScom_output_debug("RISapp_process_parms: dest sqldata value:");
				RIScom_output_blob(RIScom_output_debug, (ris_blob *)dest->sqldata);
				RIScom_output_debug("\n");
			}
		}
		break;
 
		case RIS_INTEGER:
			*(int*)dest->sqldata = 0;
			APP_DBG(("RISapp_process_parms: dest sqldata value: %d\n",
				*(int*)dest->sqldata));
			break;

		case RIS_SMALLINT:
			*(short*)dest->sqldata = 0;
			APP_DBG(("RISapp_process_parms: dest sqldata value: %d\n",
				*(short*)dest->sqldata));
			break;

		case RIS_DOUBLE:
			*(double*)dest->sqldata = (double)0.0;
			APP_DBG(("RISapp_process_parms: dest sqldata value: %.15lg\n",
				*(double*)dest->sqldata));
			break;

		case RIS_REAL:
			*(float*)dest->sqldata = (float)0.0;
			APP_DBG(("RISapp_process_parms: dest sqldata value: %.7g\n",
				*(float*)dest->sqldata));
			break;
		
		case RIS_CHARACTER:
		case RIS_DECIMAL:
			*dest->sqldata = '\0';
			APP_DBG(("RISapp_process_parms: dest sqldata value: <%s>\n",
				dest->sqldata));
			break;

		case RIS_DATETIME:
			memset(dest->sqldata, 0, sizeof(dtime));
			if (RISapp_debug)
			{
				RIScom_output_debug("RISapp_process_parms: dest sqldata value:");
				RIScom_output_datetime(RIScom_output_debug, 
						(dtime *)dest->sqldata);
				RIScom_output_debug("\n");
			}
			break;

		default:
			APP_DBG(("RISapp_process_parms: INV_TYPE\n"));
			LONGJMP(RIS_E_INV_TYPE);
			break;
	}
}

/******************************************************************************/


extern void RISapp_process_blob_parms(sqlvar *input_blob_sqlvar, int text_type, char *dest, unsigned char *blobinfo)
{
/*
 The appcli buffer should look this 	
  -----------------------------------------------------------------------
  | ris_appcli_buf_exec_blob | blob file name / blob data  | 
  -----------------------------------------------------------------------
*/
	/* ret_status is checked for <= 0, cannot be unsigned; ( __hpux__ ) */
	/*unsigned int ret_status=0;*/
	int ret_status=0;

#if defined (WIN32) || defined(DOS)
	static  	FILE *fd = 0; /* make it static, so it will not be reopened */
#else
	static  	int fd = 0; /* make it static, so it will not be reopened */
#endif
	static		int sqllen=0;
	static		unsigned int read_length=0;
	static		int sqldata_ptr=0;
	ris_blob	*input_blob=(ris_blob *) input_blob_sqlvar->sqldata;

	APP_DBG(("RISapp_process_blob_parms: RISapp_process_blob_parms blob struc:0x<%x>\n", input_blob));
	APP_DBG(("RISapp_process_blob_parms: RISapp_process_blob_parms dest:0x<%x>\n", dest));
	APP_DBG(("RISapp_process_blob_parms: input_blob->file_used:<%d>\n",input_blob->file_used));
	APP_DBG(("RISapp_process_blob_parms: input_blob->filename:<%s>\n",input_blob->filename));
	APP_DBG(("RISapp_process_blob_parms: input_blob->array_size:<%d>\n",input_blob->array_size));

	if(input_blob->filename && input_blob->file_used > 0)
	{
		APP_DBG(("RISapp_process_blob_parms file used: \n"));

		if (RIS_net->protocol==SHMEM)
		{
			APP_DBG(("Client is local: \n"));
			/* Put the length of file name in xfcount */
			/* remember to count the ending null in the length */

		   RIS_write->buf.exec_blob.xfcount= 
					strlen(input_blob->filename)+1;

	       /* It is a local file (app, cli) */	
		   RIS_write->buf.exec_blob.file_used= 1;

			/* Put the name of the  file onto buffer */
		    memcpy (dest, input_blob->filename, 
					strlen(input_blob->filename)+1);
				
			*blobinfo = *blobinfo & 0xfe; /* that's it */

		}
		else /* Client is remote we need to read in the file  */
		{
			if (!fd)	/* 1st time here, open the file */
			{
#if defined (WIN32) || defined(DOS)
				/* open in TEXT mode for RIS_TEXT TR# 439601350 - surjit */
				if (text_type)
					fd = fopen(input_blob->filename, "rt");
				else
					fd = fopen(input_blob->filename, "rb");
				if (fd == 0)
#else
				fd = open(input_blob->filename,O_RDONLY);
				if (fd < 0)
#endif
					LONGJMP(RIS_E_OPEN_BLOB_FILE_ERROR);
				read_length=RIS_write_size- 
						(int)&(((ris_appcli_buf *)0)->buf.exec_blob.data);
				
		   		RIS_write->buf.exec_blob.file_used= 2;
			}

			APP_DBG(("fd after open %d: \n", fd));

			/* use the full length of the buffer */

#if defined (WIN32) || defined(DOS)
            ret_status=RIScom_fread(dest,sizeof(char), read_length, fd);

#else
       		ret_status=RIScom_read(fd,dest,read_length);
#endif
       		if (ret_status < 0)
			{
				APP_DBG(("Errno %d: \n", errno));
			 	LONGJMP(RIS_E_READ_BLOB_FILE_ERROR);	
			}
				
			RIS_write->buf.exec_blob.xfcount = ret_status;
		
			APP_DBG(("RISapp_process_blob_parms ret_status %d, read_length %u : \n", ret_status, read_length));

			/* Save the total length in the sqlvar */
			/* ? input_blob->sqllen += ret_status;	wrong */ 

#if defined(WIN32)
			*blobinfo = ((unsigned int)ret_status < read_length)?
                        		*blobinfo & 0xfe : *blobinfo | 0x01;
#else
			*blobinfo = (ret_status < read_length)?
                        		*blobinfo & 0xfe : *blobinfo | 0x01;
#endif

	  	}  	
   	} 
	else if (input_blob->array && input_blob->file_used == 0)
	{
	/* Mem. used */
		static  int available_write_len = 0;
		APP_DBG(("mem. used: \n"));
		if (sqllen==0)	
		{	
			sqllen=input_blob->array_size;		
			sqldata_ptr=(int)input_blob->array;
		}

		APP_DBG(("mem. length : %d\n", sqllen));

	    available_write_len= RIS_write_size - 
					(int)&(((ris_appcli_buf *)0)->buf.exec_blob.data);

		APP_DBG(("mem. available buf length : %d\n", available_write_len));

		APP_DBG(("buffer header size : %d\n",
					 (int)&(((ris_appcli_buf *)0)->buf.exec_blob.data)));

		APP_DBG(("RIS_write_size : %d\n", RIS_write_size));

		/* use the entire availabe space on the buffer */
			
		/* put the length of this transfer on the buffer */
		RIS_write->buf.exec_blob.xfcount =
							(sqllen > available_write_len)?
						   	available_write_len: sqllen;	

				/* set the more to follow byte */
		*blobinfo=( sqllen>available_write_len)? (*blobinfo | 0x01): 
							(*blobinfo & 0xfe);

		RIS_write->buf.exec_blob.file_used= 0;

		memcpy (dest, (char *) sqldata_ptr,RIS_write->buf.exec_blob.xfcount);
				
		if (RISapp_debug)
		{
			static int app_fd=0;
			/* ret_status should be signed ( __hpux__ ) */
			/*unsigned int ret_status =0;*/
			int ret_status =0;

			RIScom_output_debug("RIS_write_len in appparms.c :%d\n", RIS_write_len);

			if (app_fd==0)
#if defined(WIN32)
			 app_fd=open("\\temp\\appbuf.out", 
					O_CREAT|O_RDWR|O_APPEND|O_BINARY,
								S_IREAD | S_IWRITE );						
#else
			 app_fd=open("/usr/tmp/appbuf.out", 
					O_CREAT|O_RDWR|O_APPEND,
								S_IREAD | S_IWRITE );						
#endif
			ret_status=write(app_fd, dest, RIS_write->buf.exec_blob.xfcount);	
		}

		/* update the  sqllen */
		sqllen -= available_write_len; 


		APP_DBG(("sqllen after this transfer : %d\n", sqllen));

		/* update the  sqldata_ptr */
		if(sqllen >=0)
		{	
			sqldata_ptr+=available_write_len;
			APP_DBG(("sqldata_ptr after transfer : 0x%x\n", sqldata_ptr));
		}
	} 
	else
	{
		LONGJMP(RIS_E_BAD_BLOB_STRUC);
		APP_DBG(("RISapp_process_parms: blob structure values are not valid\n"));
	}

	/* Do data conversion if it is of text type */ 

   	if(text_type)
       	ARC_CONVERT_DATA(RIS_arc, TO_NET,dest,
               	RIS_write->buf.exec_blob.xfcount);


	/* No more data, reinitialize some static variables */
  	if (! (*blobinfo  & 0x01) )
	{
		fd = 0;
		sqllen=0;
	 	sqldata_ptr=0;
		read_length=0;		
	}
}

/******************************************************************************/
