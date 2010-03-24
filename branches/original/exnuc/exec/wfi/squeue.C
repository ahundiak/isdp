
#include <OMminimum.h>
#include <OMprimitives.h>
#include <igrtypedef.h>
#include <igetypedef.h>
#include <exdef.h>
#include <expriv.h>
#include <ex.h>
#include <string.h>
#include <exproto.h>
#include <stdio.h>
#include <memory.h>


extern struct EXevent_queue *event_queue_front;
extern struct EXevent_queue *event_queue_back;

/*----
%PR%
----
%HD%

    Abstract:   This function is used to copy an event from the front of
                the event queue to a user buffer.
                The total number of bytes in the event will be returned
                if the operation is successful.
                If the buffer is not large enough to accomodate the event, 
                the truncated event will be returned and return
                code set to truncation error.           .
----
%SC%
 Value = EXgetq ( &return_code, response, &bytes_returned, &buffer );

----
%EN%
 ON ENTRY:

    NAME          DATA TYPE               DESCRIPTION
 -------------   ------------    --------------------------------------
 *buffer         IGRchar        User buffer to receive the event.

*bytes_returned IGRlong         On entry, this is the size of the 
                                user's buffer. On exit, it is the 
                                # bytes transferred. If the user's
                                buffer is not large enough, data
                                truncation error will be returned,
                                and the #bytes transferred will be
                                the size of the buffer.
----
%EX%
 ON EXIT:

    NAME          DATA TYPE               DESCRIPTION
 -------------   ------------    --------------------------------------
 *return_code   IGRlong         EXs_success    - operation succeeded
                                EXw_ev_trunc   - event truncated

 *bytes_returned IGRlong        actual number of bytes returned
 *response       IGRlong       response event will generate                             

 VALUE = TRUE if operation succeeded
         FALSE if nothing on queue

----
%MD%
 MODULES INVOKED:
        memcpy () - memory copy function
----
%NB%
 NOTES:
----
%CH%
 CHANGE HISTORY:
        pth/4/15/86   : creation
----
%PD%
----------------------------------------------------------------------
                 P R O G R A M   D E S C R I P T I O N
----------------------------------------------------------------------

---- */

/*EH*/

extern struct EX_button     EX_recallpnt[EX_RCL_MAX_ENTRY];
extern int EX_pnt_entry;
extern int EX_pnt_entry_full;




IGRint EXgetq ( return_code, response, bytes_returned, buffer )

IGRlong         *return_code;
int             *response;
IGRint          *bytes_returned;
IGRchar         *buffer;

{
    IGRlong     num;
    IGRint  status;
    struct EXevent_queue *next;
    status = FALSE;

   
    if ( event_queue_front != NULL )
    {
     /* we have something in the queue,see if it will fit in buffer*/
        if ( *bytes_returned < event_queue_front->byte_count )
        {
             *return_code = EXw_ev_trunc;
             num = *bytes_returned;  /*return #bytes size of buffer*/
        }
        else
        {
             *return_code = EXs_success;
             num = event_queue_front->byte_count;
        }

        memcpy ( buffer,        /*copy event to user's buffer*/
                event_queue_front->buffer,
                num );

        *bytes_returned = num;
        *response = event_queue_front->response;
        status = TRUE;

     /* if data point store in arrar */
      
	if( *response == DATA )
	{
            /* copy EX_button to array */

           memcpy ( (char *) &EX_recallpnt[EX_pnt_entry],
                    event_queue_front->buffer,
	            sizeof( struct EX_button) );
           EX_pnt_entry++;
	   if( EX_pnt_entry >= EX_RCL_MAX_ENTRY)
	   {
	      EX_pnt_entry = 0;
	      EX_pnt_entry_full = 1;
           }

	}        
     /* set up for next event and free memory */

        next = event_queue_front->next;
        om$dealloc(ptr = (char *)event_queue_front);
        event_queue_front = next;

        if ( event_queue_front != NULL )
        {
            event_queue_front->prev = NULL;
        }
        else
        {
            event_queue_back = NULL;
        }

    }
    
    return ( status );
}




/*----
%GP% CODE CLASSIFICATION                           
----
%HD%
     MODULE NAME - EXputq
 
     Abstract:  This function gets dynamic memory, and copies the 
                users event into the memory. It then adds the event
                node to the front or the back of the software queue.
-----
%SC%

     VALUE = EXputq( &msg, posititon, &response, &byte_cnt, &buffer )

-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE                         DESCRIPTION
     ----------   ------------            -----------------------------------
     posititon    IGRlong                 flag to put event at front
                                                or back of queue
     byte_count   IGRlong                 OPsizeof event in bytes
     response     IGRlong                 response generated by event
     buffer       event dependent         buffer containing event data
-----
%EX%
     ON EXIT:

        NAME       DATA TYPE                         DESCRIPTION
     ----------   ------------            -----------------------------------
        *msg       IGRlong              EXs_success - operation succeeded
                                        EXe_no_mem  - no memory
                                        EXe_inv_nbytes - bad byte count

        *node     struct EXevent_queue  pointer to the event in memory

     VALUE (IGRint) = TRUE if operation completed
                          FALSE if otherwise

-----
%MD%
     MODULES INVOKED:

-----
%NB%
     NOTES:
-----
%CH%
     CHANGE HISTORY:

        PTH  4/15/86  : Creation date

-----
%PD%
--------------------------------------------------------------------
              P R O G R A M    D E S C R I P T I O N
--------------------------------------------------------------------

----*/
/*EH*/


IGRint EXputq ( msg, position, response, byte_count, buffer )

IGRlong                 *msg;
IGRlong                 position;
IGRlong                 *byte_count;
int                     *response;
IGRchar                 *buffer;
{
     return( EXputq2( msg, position, response,byte_count, buffer, 0 ) );
}





IGRint EXputq2 ( msg, position, response, byte_count, buffer, mode )

IGRlong                 *msg;
IGRlong                 position;
int                     *response;
IGRlong                 *byte_count;
IGRchar                 *buffer;
IGRint                  mode;
{
    IGRint                  status;
    IGRlong                     size;
    struct EXevent_queue        *node;
    struct EX_cmd_mode_resp_data  mode_resp_data;
    IGRint count;
    status = FALSE;

    if ( ( byte_count != 0 ) && ( *byte_count < 0 ) )
    {
        *msg = EXe_inv_nbytes;
    }
    else
    {
        if( byte_count )  /* user specified byte_count */
	{
            count = *byte_count;
	}
	else  /* user did not specify byte_count */
	{
	    count = 0;
	}
        /* node -> next event on  queue
                -> previous event on queue
                -> response
                -> byte_cnt
                -> event                        */
        if(mode)
        {
 	    mode_resp_data.mode = mode;
	    if( (*response == CMD_STRING) || (*response == EX_STRING) 
	         || ( *response == EX_CMD_KEY ) )
	    {
		count = sizeof( struct EX_cmd_mode_resp_data);
	    }
        }
        size =  sizeof ( struct EXevent_queue ) -1 + count;

        node = ( struct EXevent_queue * ) om$malloc(size = size);

        
        *msg = EXe_no_mem;

        if ( node != NULL )
        {
           if(mode)
	   {
 		mode_resp_data.mode = mode;
		if( (*response == CMD_STRING) || (*response == EX_STRING) )
                {
	            node->response = EX_CMD_M_STR;
		    node->byte_count = sizeof( struct EX_cmd_mode_resp_data);
 		    strcpy( mode_resp_data.string, buffer);
		    memcpy ( (char *) node->buffer, (char *) &mode_resp_data,
                             node->byte_count );
		}   
	        else if( *response == EX_CMD_KEY )
		{
  		    node->response = EX_CMD_M_KEY;
		    node->byte_count = sizeof( struct EX_cmd_mode_resp_data);
 		    strcpy( mode_resp_data.string, buffer);
		    memcpy ( (char *) node->buffer, (char *) &mode_resp_data,
                              node->byte_count );
		}
		else
		{
		    node->response = *response;
		    node->byte_count = count;
		    memcpy ( node->buffer, buffer, count );
             	}
	   }
	   else
	   {
                node->response = *response;
                node->byte_count = count;
                memcpy ( node->buffer, buffer, count );
	   }
           switch ( position )
           {
            case BACK:

                /*no error put node onto linklist */

                if ( event_queue_back == NULL ) 
                {
                    event_queue_front = node;
                }
                else
                {
                    event_queue_back->next = node;
                }
                node->next = NULL;
                node->prev = event_queue_back;
                event_queue_back = node;

              break;

            case FRONT:

                /*no error put node onto link list*/

                if ( event_queue_front == NULL )
                {
                    node->next = NULL;
                    event_queue_back = node;
                }
                else
                {
                    node->next = event_queue_front;
                    event_queue_front->prev = node;
                }
                node->prev = NULL;
                event_queue_front = node;

              break;
            }
            *msg = EXs_success;
            status = TRUE;
        }
    }
    return ( status );
}

/***************************************************************/
/*                                                             */
/*     following 2 routines EX_putq_back and EXputq_front      */
/*     will be deleted from the system  after we use           */
/*     EX macro primitives.                                    */
/*                                                             */
/***************************************************************/
         
IGRint EXputq_back ( msg, response, byte_count, buffer )

IGRlong                 *msg;
IGRlong                 *byte_count;
int                     *response;
IGRchar                 *buffer;
{
    IGRlong                     position; /* =0,back =1,front of queue*/
    IGRint                  status;

        position = BACK;
        status = EXputq ( msg, position, response, byte_count, buffer);
        return ( status );
}


IGRint EXputq_front ( msg, response, byte_count, buffer )

IGRlong                 *msg;
int                     *response;
IGRlong                 *byte_count;
IGRchar                 *buffer;
{
    IGRlong             position;/* front = 1*/
    IGRint                  status;

        position = FRONT;
        status = EXputq ( msg, position, response, byte_count, buffer);
        return ( status );
}


/**********************************************/
/*                                            */
/*  utility routine to print software queue   */
/*                                            */
/**********************************************/

int print_queue()
{
    struct EXevent_queue *que;
    struct EX_button  button;    
     if (event_queue_front)
     {
         que = event_queue_front;
         while( que != NULL)
         {
            printf("\n print que response = %d byte_count = %d\n\n",que->response,que->byte_count);
            switch (que->response)
            {
               case DATA: 
               case (DATA | EX_HARDWARE_GENERATED): 
    memcpy( (char *) &button, &que->buffer[0],sizeof(struct EX_button));
    printf( "\n            x = %lf\n",  button.x );
    printf( "            y = %lf\n",  button.y );
    printf( "            z = %lf\n",  button.z );
    printf( "       window = %d\n",   button.window );
    printf( "         numb = %d\n",   button.numb );
    printf( "       clicks = %d\n",   button.clicks );
    printf( " button_down  = %d\n",   button.button_down );

                   break;
               case STRING:
               case ( STRING | EX_HARDWARE_GENERATED):
               case CMD_STRING:
               case ( CMD_STRING | EX_HARDWARE_GENERATED):
               case COMMAND:
               case ( COMMAND | EX_HARDWARE_GENERATED):
	       case EX_CMD_KEY:
               case ( EX_CMD_KEY | EX_HARDWARE_GENERATED):
                      printf("buffer = %s\n",&que->buffer[0]);
                    break;
               default:
                     printf("response = %d\n",que->response);

                    break;
            }
         que = que->next;
       }
     }
     else
     {
          printf("\n software event queue empty\n");
     }
     printf("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n");
     return(1);
}
/**********************************************/
/*                                            */
/*  utility routine to flush software queue   */
/*                                            */
/**********************************************/

EX_flush_event_queue()
{
    struct EXevent_queue *que;

    while( event_queue_front != NULL)
    {
       que = event_queue_front;
       event_queue_front = event_queue_front->next;
       om$dealloc(ptr = (char *)que);
    }
    event_queue_back = NULL;
    return(1);
}

/**********************************************/
/*                                            */
/*  utility routine to peek software queue    */
/*                                            */
/**********************************************/

EX_peek_event_queue( resp)
 int  *resp;
{

     if (event_queue_front)
     {
          if( resp != NULL ) *resp =event_queue_front->response;
          return(1);
     }
     else
     {
         return(0);
     }
}

