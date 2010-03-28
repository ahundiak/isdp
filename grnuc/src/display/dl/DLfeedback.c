#include <stdlib.h>
#include <stdio.h>

#include "wl.h"
#include "igrtypedef.h"
#include "igr.h"
#include "dl.h"
#include "dl_internal.h"

extern int DLIfb_tags_flag;
extern int DLIreport_errors;

static int DLIfb_start_stack[5] = {0, 0, 0, 0, 0};
static int stack = -1;
static WLint32 DLIfb_tag1 = 0;
static WLint32 DLIfb_tag2 = 0;

/*--- DLIfb_start --------------------------------------------------*/

int DLIfb_start(
   struct DLpipeline *pipe,
   WLuint16 tag1,
   WLint16 flag1 )

/*
NAME
	DLIfb_start

DESCRIPTION
	Save the location in the molecule header where quad words
	to follow is being stored.  The count will be filled in
	when DLIfb_end() is called.

SYNOPSIS
	int DLIfb_start(
	   struct DLpipeline *pipe,
	   WLint16 tag1,
	   WLint16 flag1 )

PARAMETERS
	pipe (IN) - the pipeline structure that is getting feedback
	tag1 (IN) - the tag to put in the feedback buffer
	flag1 (IN) - the flag to put in the feedback buffer

GLOBALS USED
	none

RETURN VALUES
	DL_SUCCESS
		Success
	DL_FEEDBACK_OVERFLOW
		If the feedback buffer overflowed

HISTORY
	11/19/92    S.P. Rogers
	    Documented
*/

{
   int i;
   union DLIfb_union ptr;

   i = pipe->fb_index;
   if ( i >= pipe->fb_size )
   {
      DL_REPORT_ERROR( DL_FEEDBACK_OVERFLOW );
      return( DL_FEEDBACK_OVERFLOW );
   }
   ptr.d = &pipe->fb_buf[i];
   *ptr.s++ = tag1;
   *ptr.s++ = flag1;
   pipe->fb_index++;
   DLIfb_start_stack[++stack] = pipe->fb_index;
   return( DL_SUCCESS );

}  /* DLIfb_start */

/*--- DLIfb_end ----------------------------------------------------*/

int DLIfb_end(
   struct DLpipeline *pipe,
   WLint16 flag )

/*
NAME
	DLIfb_end

DESCRIPTION
	Compute the total quad word count for this molecule
	and put it in the appropriate location in the molecule header.
        
SYNOPSIS
	int DLIfb_end(
	   struct DLpipeline *pipe,
	   WLint16 flag )

PARAMETERS
	pipe (IN) - the pipeline structure that is getting feedback
	flag (IN) - the flag to place in the feedback buffer header

GLOBALS USED
	none

RETURN VALUES
	DL_SUCCESS
		Success

HISTORY
	11/19/92    S.P. Rogers
	   Documented
*/

{
   int count;
   union DLIfb_union ptr;

   if ( stack < 0 )
   {
      DL_REPORT_ERROR( DL_ERROR );
      return( DL_ERROR );
   }
   count = pipe->fb_index - DLIfb_start_stack[stack];
   ptr.d = &pipe->fb_buf[DLIfb_start_stack[stack] - 1];
   ptr.s++;
   *ptr.s++ = flag;
   *ptr.i = count;
   if ( ( flag == 0 ) && ( count <= 1 ) )
   {
      pipe->fb_index = DLIfb_start_stack[stack] - 1;
   }
   stack--;
   return( DL_SUCCESS );

}  /* DLIfb_end */

/*--- DLIfb_tags --------------------------------------------------*/

int DLIfb_tags(
   WLint32 tag1,
   WLint32 tag2 )

/*
NAME
	DLIfb_tags

DESCRIPTION
	Set up a global variable that contains additional
	information to be inserted into the feedback buffer later.

SYNOPSIS
	int DLIfb_tags(
	   WLint32 tag1,
	   WLint32 tag2 )

PARAMETERS
	tag1 (IN) - the first tag
	tag2 (IN) - the second tag

GLOBALS USED
	none

RETURN VALUES
	DL_SUCCESS
		Success

HISTORY
	11/19/92    S.P. Rogers
	   Documented
*/

{
   if ( ( tag1 == 0 ) && ( tag2 == 0 ) )
   {
      DLIfb_tags_flag = 0;
   }
   else
   {
      DLIfb_tags_flag = 1;
   }

   DLIfb_tag1 = tag1;
   DLIfb_tag2 = tag2;
   return( DL_SUCCESS );

}  /* DLIfb_tags */


/*--- DLIfb_insert ---------------------------------------------*/

int DLIfb_insert(
   struct DLpipeline *pipe )

/*
NAME
	DLIfb_insert

DESCRIPTION
	Insert two tags that are specific to the current element
	into the feedback buffer.
        
SYNOPSIS
	int DLIfb_insert(
	   struct DLpipeline *pipe )

PARAMETERS
	pipe (IN) - the pipe structure that is to have the tags
	            put into its feedback buffer

GLOBALS USED
	none

RETURN VALUES
	DL_SUCCESS
		Success
	DL_FEEDBACK_OVERFLOW
		The feedback buffer overflowed

HISTORY
	11/19/92    S.P. Rogers
	    Documented
*/

{
   int i;
   union DLIfb_union ptr;

   i = pipe->fb_index;
   if ( i > pipe->fb_size )
   {
      DL_REPORT_ERROR( DL_FEEDBACK_OVERFLOW );
      return( DL_FEEDBACK_OVERFLOW );
   }

   ptr.d = &pipe->fb_buf[i];
   *ptr.i++ = DLIfb_tag1;
   *ptr.i++ = DLIfb_tag2;
   pipe->fb_index++;
   return( DL_SUCCESS );

}  /* DLIfb_insert */


/*--- DLIfb_flag ---------------------------------------------*/

int DLIfb_flag(
   struct DLpipeline *pipe,
   WLint16 flag )

/*
NAME
	DLIfb_flag

DESCRIPTION
	Put the specified flag in each atom element in the feedback
	buffer.

SYNOPSIS
	int DLIfb_flag(
	   struct DLpipeline *pipe,
	   WLint16 flag )

PARAMETERS
	pipe (IN) - the pipe structure whose feedback buffer is to
	            receive the flag
	flag IN) - the flag to put in the buffer

GLOBALS USED
	none

RETURN VALUES
	DL_SUCCESS
		Success

HISTORY
	11/19/92    S.P. Rogers
	    Documented
*/

{
   pipe->fb_flag = flag;
   return( DL_SUCCESS );

}  /* DLIfb_flag */


/*--- DLpass_to_feedback -------------------------------------------------*/

int DLpass_to_feedback(
   int pipe_id,
   WLint16 tag,
   WLint16 flag,
   WLint32 data )

/*
NAME
	DLpass_to_feedback

DESCRIPTION
	This function passes user data into the feedback buffer for a
	drawing pipeline.

SYNOPSIS
	int DLpass_to_feedback(
	   int pipe_id,
	   WLint16 tag,
	   WLint16 flag,
	   WLint32 data )

PARAMETERS
	pipe_id (IN) - the drawing pipeline id
	tag (IN) - the tag that is placed in the 'type' field of the feedback
	           record
	flag (IN) - the flags that are placed in the 'state' field of
	            the feedback record
	data (IN) - the data that is placed in the 'quad-words-to-follow'
	            field of the feedback record

GLOBALS USED
	none

RETURN VALUES
	DL_SUCCESS
		Success
	DL_BAD_PIPELINE_ID
		The drawing pipeline id is invalid.
	DL_FEEDBACK_OVERFLOW
		There was not enough room in the feedback buffer.

RELATED INFORMATION
	Functions: DLcreate_feedback_pipeline()

HISTORY
	08/17/92    S.P. Rogers
	   Initial definition
*/

{
   int sts;
   int i;
   struct DLpipeline *pipe;
   union DLIfb_union ptr;

   sts = DLIvalidate_pipe( pipe_id, &pipe );
   if ( sts != DL_SUCCESS )
   {
      DL_REPORT_ERROR( sts );
      return( sts );
   }

   i = pipe->fb_index;
   if ( i > pipe->fb_size )
   {
      return( DL_FEEDBACK_OVERFLOW );
   }
   ptr.d = &pipe->fb_buf[i];
   *ptr.s++ = tag;
   *ptr.s++ = flag;
   *ptr.i = data;
   pipe->fb_index++;
   return( DL_SUCCESS );

}  /* DLpass_to_feedback */


/*--- DLreset_feedback ------------------------------------------------------*/

int DLreset_feedback( 
   int pipe_id )

/*
NAME
	DLreset_feedback

DESCRIPTION
	This function resets the feedback buffer associated with a drawing
	pipeline.

SYNOPSIS
	int DLreset_feedback( 
	   int pipe_id )

PARAMETERS
	pipe_id (IN) - the drawing pipeline id

GLOBALS USED
	none

RETURN VALUES
	DL_SUCCESS
		Success
	DL_BAD_PIPELINE_ID
		The drawing pipeline id is invalid.

RELATED INFORMATION
	Functions: DLcreate_feedback_pipeline()

HISTORY
	08/17/92    S.P. Rogers
	   Initial definition
*/

{
   int sts;
   struct DLpipeline *pipe;

   sts = DLIvalidate_pipe( pipe_id, &pipe );
   if ( sts != DL_SUCCESS )
   {
      DL_REPORT_ERROR( sts );
      return( sts );
   }

   pipe->fb_index = 0;
   return( DL_SUCCESS );

}  /* DLreset_feedback */

/*--- DLresize_feedback -----------------------------------------------*/

int DLresize_feedback(
   int pipe_id,
   double *buffer,
   int buf_size )

/*
NAME
	DLresize_feedback

DESCRIPTION
	This function resizes the feedback buffer associated with a drawing
	pipeline.

SYNOPSIS
	int DLresize_feedback(
	   int pipe_id,
	   double *buffer,
	   int buf_size )

PARAMETERS
	pipe_id (IN) - the drawing pipeline id
	buffer (IN) - the new feedback buffer
	buf_size (IN) - the new feedback buffer size

GLOBALS USED
	none

RETURN VALUES
	DL_SUCCESS
		Success
	DL_BAD_PIPELINE_ID
		The drawing pipeline id is invalid or the pipeline id
		is for a non-feedback pipeline.
	DL_BAD_PARAMETER
		The 'buffer' parameter is NULL or 'buf_size' is <= 0.

RELATED INFORMATION
	Functions: DLcreate_feedback_pipeline()

HISTORY
	08/17/92    S.P. Rogers
	   Initial definition
*/

{
   int sts;
   struct DLpipeline *pipe;

   sts = DLIvalidate_pipe( pipe_id, &pipe );
   if ( sts != DL_SUCCESS )
   {
      DL_REPORT_ERROR( sts );
      return( sts );
   }

   if ( pipe->fb_size <= 0 )
   {
      /* not a feedback pipeline */
      DL_REPORT_ERROR( DL_BAD_PIPELINE_ID );
      return( DL_BAD_PIPELINE_ID );
   }

   if ( ! buffer )
   {
      DL_REPORT_ERROR( DL_BAD_PARAMETER );
      return( DL_BAD_PARAMETER );
   }

   if ( buf_size <= 0 )
   {
      DL_REPORT_ERROR( DL_BAD_PARAMETER );
      return( DL_BAD_PARAMETER );
   }

   pipe->fb_size = buf_size;
   pipe->fb_index = 0;
   pipe->fb_buf = buffer;

   stack = -1;
   DLIfb_tags_flag = 0;

   return( DL_SUCCESS );

}  /* DLresize_feedback */
