/* #######################    APOGEE COMPILED   ######################## */
#include "exsysdep.h"
#include "grimport.h"
#include "igrtypedef.h"
#include "igr.h"
#include "transdef.h"
#include "translate.h"
#include "transerr.h"
/*
#include "OMprimitives.h"
*/

extern struct GRid GUwindow_being_plotted;

/*
 *  This function will read an element from an IGDS 8.8 design
 *  file and return the entire element in tha calling procedure's
 *  buffer.
 */

IGRboolean GUget_next_ele (msg, cvt_bufs)

IGRlong	   		*msg;		/* return code			*/
struct GUcvt_bufs	*cvt_bufs;

{
    IGRlong	bytes_left;     /* number of bytes of a partial	*/
                                /* element which are needed to	*/
                                /* complete the element		*/
    IGRboolean 	element;        /* flag indicating a completed	*/
                                /* element in the element buffer*/
    IGRboolean 	status = TRUE;
    IGRlong	delsize;
    IGRshort	*ele_ptr;
#ifdef BIG_ENDIAN
    IGRshort	dummy_ptr;
#endif

    static IGRshort *dgn_ptr;   /* pointer to design file buffer*/
    static IGRlong bytes_remain = 0; /* number of unused bytes 	*/
                                /* remaining in the design	*/
                                /* buffer from the last read	*/


    if (cvt_bufs == NULL) 
    {

	if(GUwindow_being_plotted.objid == NULL_OBJID)	
			bytes_remain = 0;
	return(TRUE);
    }


    ele_ptr = (IGRshort *) cvt_bufs->ele_buf;
    element = FALSE;
    bytes_left = 0;

    /*
     *  Process until a complete element has been 
     *  placed in the element buffer.
     */

    while (!element)
    {
	/*
         *  If no data is left in the design buffer,
         *  read next buffer from design file.
         */
	if (bytes_remain <= 0)
	{

    	    if ((bytes_remain = read (cvt_bufs->file_des, 
                                      cvt_bufs->dgn_buf, GUDGN_BUF_SIZ)) == -1)
    	    {
		/*
                 *  Error in VAX design file read.
                 */

		status = FALSE;
		*msg = GUREAD_ERROR;
		element = TRUE;
		bytes_remain = 0;
		return(status);
  	    }
    	    else if (bytes_remain == 0)
    	    {
		/*
                 *  EOF.
                 */
		printf("Unexpected EOF while reading IGDS file\n");
		status = FALSE;
		element = TRUE;
		*msg = GUREAD_ERROR;
		return(status);
  	    }
    	    else
    	    {
		dgn_ptr = (IGRshort *) cvt_bufs->dgn_buf;
	    }
	}

	/*
         *  Check to see if the remainder of a partial
         *  element needs to be moved to the element buffer.
         */

	if ((bytes_left != 0) && (!element))
	{
	    if (bytes_left == -1)
	    {
	    	/*
                 *  We had the type/level word as the last word 
                 *  of the design buffer.  At this time we must
                 *  calculate the number of bytes of the element  
                 *  which need to be moved to the element buffer.
                 *  Bytes left is the number of wds to follow +
                 *  the wtf word , * 2 to get bytes.
                 */

#ifdef BIG_ENDIAN
		GRconv_short(dgn_ptr ,&dummy_ptr);
		bytes_left = (dummy_ptr +1) * 2;
#else
		bytes_left = (*dgn_ptr +1) * 2;
#endif
		cvt_bufs->ele_size = bytes_left +2;
	    }

	    /*
             *  Move the remainder of the partial element
             *  to the element buffer.
             */

	    memcpy((char *)ele_ptr, (char *)dgn_ptr, bytes_left);
	    dgn_ptr += bytes_left/2;

	    if(((IGRchar *)dgn_ptr < cvt_bufs->dgn_buf) ||
               ((IGRchar *)dgn_ptr > cvt_bufs->dgn_buf + GUDGN_BUF_SIZ)) 
            {
		printf("Bad element encountered while reading IGDS file\n");
		status = FALSE;
		element = TRUE;
		*msg = GUREAD_ERROR;
	        return(status);
	    }
	    ele_ptr += bytes_left/2;
	    bytes_remain -= bytes_left;
	    *msg = GUsuccess;
	    status = TRUE;
	    element = TRUE;
	
	}
	else
	{
            /*
             *  Check to see if this is the end
             *  of the design file.
             */

#ifdef BIG_ENDIAN
		
            GRconv_short(dgn_ptr,&dummy_ptr);
            if (dummy_ptr != EOF)
#else
            if (*dgn_ptr != -1)
#endif

            {
                /*
                 *  Check to see if this is a deleted element.
                 */

#ifdef BIG_ENDIAN
                GRconv_short(dgn_ptr,&dummy_ptr); 
                if (dummy_ptr >> 15)
#else
                if (*dgn_ptr >> 15)
#endif
                {
                    if (bytes_remain < 4)
                    {
                        /*
                         *  We have just the first word of the element
                         *  in the design buffer.
                         */

                        if ((bytes_remain = read(cvt_bufs->file_des, 
                                                 cvt_bufs->dgn_buf, 2)) == -1)
                        {
                            /*
                             *  Error in VAX design file read.
                             */

                            status = FALSE;
                            *msg = GUREAD_ERROR;
                            element = TRUE;
                            bytes_remain = 0;
                            return(status);
                        }
                        else if (bytes_remain == 0)
                        {
                            /*
                             *  EOF.
                             */

                            printf("Unexpected EOF while reading IGDS file\n");
                            status = FALSE;
                            element = TRUE;
                            *msg = GUREAD_ERROR;
                            return(status);
                        }
                        else
                        {
                            dgn_ptr = (IGRshort *) cvt_bufs->dgn_buf;
                        }
	
#ifdef BIG_ENDIAN
                        GRconv_short(dgn_ptr,&dummy_ptr);
                        delsize = dummy_ptr* 2;
#else
                        delsize = *dgn_ptr * 2;
#endif
                        lseek (cvt_bufs->file_des, delsize, 1);
                        bytes_remain = 0;
                        bytes_left = 0;
                    }
                    else
                    {
                        /*
                         *  We at least have the type/level and the wtf
                         *  word, so calculate the element size.
                         */

#ifdef BIG_ENDIAN
                        GRconv_short((dgn_ptr+1),&dummy_ptr) ;
                        delsize = (dummy_ptr + 2) * 2;
#else
                        delsize = (*(dgn_ptr+1) + 2) * 2;
#endif
                        bytes_left = delsize - bytes_remain;

                        if (bytes_left > 0)
                        {
                            /*
                             *  We have only a partial element.
                             */

                            lseek (cvt_bufs->file_des, bytes_left, 1);
                            bytes_remain = 0;
                            bytes_left = 0;
                        }
                        else
                        {
                            /*
                             *  We have the entire element, skip it.
                             */

                            dgn_ptr += (delsize)/2;
                            if (((IGRchar *)dgn_ptr < cvt_bufs->dgn_buf) ||
                                ((IGRchar *)dgn_ptr > cvt_bufs->dgn_buf + GUDGN_BUF_SIZ))
                            {
                                printf("Bad element encountered while ");
                                printf("reading IGDS file\n");
				status = FALSE;
				element = TRUE;
				*msg = GUREAD_ERROR;
	        		return(status);
                            }
                            bytes_remain -= delsize;
                            bytes_left = 0;
                        }
                    }
                }
                else
                {
                    if (bytes_remain < 4)
                    {
                        /*
                         *  We have just the first word of the element
                         *  in the design buffer, move it to the element
                         *  buffer and set bytes left = -1 to indicate
                         *  that the element size cannot be determined
                         *  at this time.
                         */

                        memcpy((char *)ele_ptr, (char *)dgn_ptr, bytes_remain);
                        ++ele_ptr;
                        ++dgn_ptr;
                        bytes_remain = 0;
                        bytes_left = -1;
                    }
                    else
                    {
                        /*
                         *  We at least have the type/level and the wtf
                         *  word, so calculate the element size.
                         */

#ifdef BIG_ENDIAN
                        GRconv_short((dgn_ptr+1),&dummy_ptr);
                        cvt_bufs->ele_size = (dummy_ptr + 2) * 2;
#else
                        cvt_bufs->ele_size = (*(dgn_ptr+1) + 2) * 2;
#endif
                        bytes_left = cvt_bufs->ele_size - bytes_remain;

                        if (bytes_left > 0)
                        {
                            /*
                             *  We have only a partial element, move
                             *  it to the element buffer and then 
                             *  read more of the design file.
                             */

                            memcpy((char *)ele_ptr, (char *)dgn_ptr, 
                                   bytes_remain);
                            ele_ptr += (bytes_remain)/2;
                            bytes_remain = 0;
                        }
                        else
                        {
                            /*
                             *  We have the entire element, move it to
                             *  the element buffer and return it to the
                             *  caller.
                             */

                            memcpy((char *)ele_ptr, (char *)dgn_ptr, 
                                   cvt_bufs->ele_size);
                            dgn_ptr += (cvt_bufs->ele_size)/2;
                            if (((IGRchar *)dgn_ptr < cvt_bufs->dgn_buf) ||
                                ((IGRchar *)dgn_ptr > cvt_bufs->dgn_buf + GUDGN_BUF_SIZ)) 
                            {
                                printf("Bad element encountered while ");
                                printf("reading IGDS file\n");
				status = FALSE;
				element = TRUE;
				*msg = GUREAD_ERROR;
	        		return(status);
                            }
                            ele_ptr += (cvt_bufs->ele_size)/2;
                            bytes_remain -= cvt_bufs->ele_size;
                            *msg = GUsuccess;
                            status = TRUE;
                            bytes_left = 0;
                            element = TRUE;

                        }
                    }
                }
            }
            else
            {
                /*
                 *  This was the end of the design file.
                 */

                status = FALSE;
                *msg = GULAST_ELEMENT;
                element = TRUE;
                bytes_remain = 0;
            }
	}
    }                           /* end while */

    return (status);
}



/*
 *  Changes made to this function on 04/22/87 will require that all
 *  routines calling this function add the arguments block_ptr and
 *  byte_ptr.
 */


IGRlong GUwrite_element(msg, dgn_buf, ele_buf, ele_type, ele_size, 
                        file_des, write_mode, block_ptr, byte_ptr)

IGRlong		*msg;
IGRchar		*dgn_buf;
IGRchar		*ele_buf;
IGRint		*ele_type;
IGRint		*ele_size;
IGRint		*file_des;
IGRshort	*write_mode;
IGRint		*block_ptr;
IGRint		*byte_ptr;

{
    static IGRchar		*dgn_ptr;
    static IGRchar		increase_buf[GUBLOCK_SIZE];
    static IGRint		bytes_used = 0;
    static IGRint		bytes_left = GUDGN_BUF_SIZ;
    static IGRint		current_block = 0;
    static IGRint		current_byte = 0;

    IGRint		i;
    IGRchar		*ele_ptr;
    IGRint		rewrite_offset;
    IGRint		bytes_written;
    IGRlong		status;
    IGRboolean		initial_write;


    /*
     *  Initializations.
     */

    status = TRUE;
    *msg = GUsuccess;

    ele_ptr = ele_buf;

    if (bytes_used <= 0)
    {
	dgn_ptr = dgn_buf;
    }


    /*
     *  If the mode is GUWRITE then check the dgn buffer to see
     *  if there is enough space for the element.  If there is not
     *  sufficient space, write the buffer out to the file and update
     *  the current block and byte pointers.  Then the element is copied
     *  into the dgn buffer.  If this element has the possibility of 
     *  being re-written, the block and byte pointers of where the 
     *  element will eventually fall in the file are saved on a
     *  linked list.
     */

    if (*write_mode == GUWRITE)
    {
	initial_write = TRUE;
	
 	while (*ele_size > bytes_left)
	{
	    /*
             *  Insufficient space in buffer for the next element,
             *  write the buffer out to the file.
             */

 	    if ((bytes_written = write(*file_des, dgn_buf, bytes_used))
		!= bytes_used)
	    {
		*msg = GUWRITE_ERROR;
		status = FALSE;
		goto wrap_up;
	    }

	    /*
             *  Reset the buffer pointer and the number
             *  of bytes left in the buffer.
             */

	    dgn_ptr = dgn_buf;
	    bytes_left = GUDGN_BUF_SIZ;
	    bytes_used = 0;

	    /*
             *  If this element will require a re-write, save the
             *  block and byte pointer of where it will fall in 
             *  the file on the linked list.
             */

	    if (initial_write)
	    {
		*block_ptr = current_block;
		*byte_ptr = current_byte;
		initial_write = FALSE;
	    }
	
	    if (*ele_size > bytes_left)
	    {
		memcpy (dgn_ptr, ele_ptr, bytes_left);
		dgn_ptr += bytes_left;
		ele_ptr += bytes_left;
		*ele_size -= bytes_left;
	
	    	/*
                 *  Update the current block and byte pointers.
                 */

	    	current_byte += bytes_left;
	    	if (current_byte >= GUBLOCK_SIZE)
	    	{
		    current_block += (current_byte / GUBLOCK_SIZE);
		    current_byte %= GUBLOCK_SIZE;
	    	}

		bytes_left = 0;
		bytes_used = GUDGN_BUF_SIZ;
	    }
	
	}


	/*
         *  If this element will require a re-write, save the
         *  block and byte pointer of where it will fall in 
         *  the file on the linked list.
         */

	if (initial_write)
	{
	    *block_ptr = current_block;
	    *byte_ptr = current_byte;
	}
	
	memcpy (dgn_ptr, ele_ptr, *ele_size);
	dgn_ptr += *ele_size;
	bytes_left -= *ele_size;
	
	/*
         *  Update the current block and byte pointers.
         */

	current_byte += *ele_size;
	if (current_byte >= GUBLOCK_SIZE)
	{
	    current_block += (current_byte / GUBLOCK_SIZE);
	    current_byte %= GUBLOCK_SIZE;
	}

	bytes_used = GUDGN_BUF_SIZ - bytes_left;

    }

    /*
     *  If the write mode is GUREWRITE, we use the linked list of
     *  file pointers to see if the element is still in the buffer.
     *  If the element is still in the buffer, we copy the bytes
     *  into the buffer.  If the element has already been written
     *  to the file, we rewind the file pointer to the specified 
     *  location and then write the bytes to the file.
     */

    else if (*write_mode == GUREWRITE)
    {
	*write_mode = GUFLUSH;
	status = GUwrite_element (msg, dgn_buf, ele_buf, ele_type, ele_size,
                                  file_des, write_mode, block_ptr,
                                  byte_ptr);
	*write_mode = GUREWRITE;
				
	/*
         *  The element has already been written to the file,
         *  rewind the file pointers and write the bytes to the file.
         */
				
	rewrite_offset = (*block_ptr * GUBLOCK_SIZE + *byte_ptr) -
            (current_block * GUBLOCK_SIZE + current_byte);

     	lseek (*file_des, rewrite_offset, 1);

	if ((bytes_written = write(*file_des, ele_buf, *ele_size)) 
            != *ele_size)
	{
	    *msg = GUWRITE_ERROR;
	    status = FALSE;
	    goto wrap_up;
	}

	/*
         *  Reset file pointer to original position.
         */
	
	lseek (*file_des, -(rewrite_offset + *ele_size), 1);

    }

    else if (*write_mode == GUFLUSH)
    {
	bytes_used = GUDGN_BUF_SIZ - bytes_left;
 	if ((bytes_written = write(*file_des, dgn_buf, bytes_used))
            != bytes_used)
	{
	    *msg = GUWRITE_ERROR;
	    status = FALSE;
	    goto wrap_up;
	}
	
	/*
         *  Reset the buffer pointer and the number
         *  of bytes left in the buffer.
         */

	dgn_ptr = dgn_buf;
	bytes_left = GUDGN_BUF_SIZ;

    }

    /*
     *  Check to see if file size is to be increased by
     *  appending a specified amount of 'garbage' space
     *  after the end of design file.
     */

    else if (*write_mode == GUINCREASE)
    {
	for (i = 0; i < *ele_size; i++)
	{
 	    write(*file_des, increase_buf, GUBLOCK_SIZE);	
	}
    }
    
    /*
     *  04/29/87 sjb. In some cases elements which have been written to
     *  the file may need to be completely overwritten (i.e. a complex
     *  header which was written to the file and its components did not
     *  translate properly needs to be thrown away.
     */

    else if (*write_mode == GURESET_POINTERS)
    {
	*write_mode = GUFLUSH;
	status = GUwrite_element (msg, dgn_buf, ele_buf, ele_type, ele_size,
                                  file_des, write_mode, block_ptr,
                                  byte_ptr);

	/*
         *  Rewind the file pointers and write the bytes to the file.
         */
				
	rewrite_offset = (*block_ptr * GUBLOCK_SIZE + *byte_ptr) -
            (current_block * GUBLOCK_SIZE + current_byte);

     	lseek (*file_des, rewrite_offset, 1);

    }

    /*
     *  10/29/86 gfs. need some way to facilitate multiple translations
     *  from 1 ige session. So we need to re-initialize all the pointers 
     *  to their original values.
     */

    else if (*write_mode == GUWRITE_INIT)
    {
    	bytes_used = 0;
    	bytes_left = GUDGN_BUF_SIZ;
    	current_block = 0;
    	current_byte  = 0;
    }

wrap_up:

    return (status);
}

