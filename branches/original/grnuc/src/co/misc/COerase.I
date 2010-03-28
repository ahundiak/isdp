/*
Name

IGRlong COEraseSendRedraw( msg,
                matrix_type,
                matrix,
                erase_mode,
                erase_grid,
                passon_message,
                draw_mode,
                draw_grid,
                co_objid,
                channel_struct,
                from_index,
                to_index,
                object_grid );
                                                                               
    IGRlong              *msg;
    IGRshort             *matrix_type;
    IGRmatrix            *matrix;
    enum GRdpmode        *erase_mode;
    struct GRid          *erase_grid;
    OM_S_MESSAGE         *passon_message;
    enum GRdpmode        *draw_mode;
    struct GRid          *draw_grid;
    GRobjid               co_objid;
    OM_S_CHANSELECT      *channel_struct;
    IGRint                from_index;
    IGRint                to_index;
    struct GRid          *object_grid;
                                                                               

Abstract
        This macro sends a display message, intended to be an erase message,
        then sends a message supplied by the command object, then
        sends another message, intended to redraw the element.
                                                                            
Arguments
        msg
                return codes

        matrix_type

        matrix
                                                                               
        erase_mode
                mode the object is displayed in ( if it is displayed ).
                defaults to GRbe.  intended to be used to erase the object.
                                                                            
        erase_grid
                object used in the first display message
                                                                               
        passon_message
                message to be sent to object.  must be specified.
                                                                            
        draw_mode
                mode the object is displayed in ( if it is displayed ).
                defaults to GRbe.  intended to be used to draw the object.
                                                                            
        draw_grid
                object used in the second display message
                                                                            
        co_objid
                object id of command calling this function

        channel_struct
                pointer to a channel structure in command object
                                                                               
        from_index
                from index on channel
                                                                               
        to_index
                to index on channel

        object_grid
                object to whom the message will be sent

Status returns
                                                                               
        OM_S_SUCCESS
        OM_E_ABORT
        OM_I_INVARG
                                                                            
Caveats
    GO must be on a channel. assuming that this function is being
    called from the co$erase_send_draw macro

History
    trc 03/05/87 : adapted to the new include file design
*/
                                                                               

class implementation super_cmd;
                                                                               
#include "coimport.h"
#include "codebug.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "msdef.h"
#include "igrmacros.h"

/*----------------------------------------
 *  imports
 *----------------------------------------
 */
from GRgraphics import GRdisplay;
                                                                               
#argsused
IGRlong COEraseSendRedraw(msg,
			  matrix_type,
			  matrix,
			  erase_mode,
			  erase_grid,
			  passon_message,
			  draw_mode,
			  draw_grid,
			  co_objid,
			  channel_struct,
			  from_index,
			  to_index,
			  object_grid )
     
     IGRlong              *msg;
     IGRshort             *matrix_type;
     IGRmatrix             matrix;
     enum GRdpmode         erase_mode;
     struct GRid          *erase_grid;
     OM_S_MESSAGE         *passon_message;
     enum GRdpmode         draw_mode;
     struct GRid          *draw_grid;
     GRobjid               co_objid;
     OM_S_CHANSELECT      *channel_struct;
     IGRint                from_index;
     IGRint                to_index;
     struct GRid          *object_grid;
     
{
  IGRlong                     status;
  
  
  /*
   *  erase object 
   */
  if ( erase_grid != NULL )
    {
      /*
       *  if the chanselect is used, then do channel send
       */
      if ( object_grid == NULL )
        {
	  status = om$send(msg = message GRgraphics.GRdisplay(msg,
							      matrix_type,
							      matrix,
							      &erase_mode,
							      erase_grid ),
			   senderid = co_objid,
			   p_chanselect = channel_struct );
	  _m_check2p( status, *msg, "COEraseSendRedraw - failed erase." );
	  _m_check2q( status, *msg );
        }
      else /* send directly to object */
        {
	  status = om$send(msg = message GRgraphics.GRdisplay(msg,
							      matrix_type,
							      matrix,
							      &erase_mode,
							      erase_grid ),
			   senderid = co_objid,
			   targetid = object_grid->objid,
			   targetos = object_grid->osnum );
	  _m_check2p( status, *msg, "COEraseSendRedraw - failed erase." );
	  _m_check2q( status, *msg );
        }
    }
  
  
  /*
   *  if the channel selector is used, then do a channel send
   */
  if ( object_grid == NULL )
    {
      /*
       *  send the message, pass the buck
       */
      status = om$send(msg = passon_message,
		       senderid = co_objid,
		       p_chanselect = channel_struct );
      _m_checkp( status, "COEraseSendRedraw - failed in message send." );
    }
  else /* do an object send */
    {
      /*
       *  send the message, pass the buck
       */
      status = om$send(msg = passon_message,
		       senderid = co_objid,
		       targetid = object_grid->objid,
		       targetos = object_grid->osnum );
      _m_checkp( status, "COEraseSendRedraw - failed in message send." );
    }
  
  
  /*
   *  draw object 
   */
  if ( draw_grid != NULL )
    {
      /*
       *  if the channel selector is used, then do a channel send
       */
      if ( object_grid == NULL )
        {
	  status = om$send(msg = message GRgraphics.GRdisplay(msg,
							      matrix_type,
							      matrix,
							      &draw_mode,
							      draw_grid ),
			   senderid = co_objid,
			   p_chanselect = channel_struct );
	  _m_check2p( status, *msg, "COEraseSendRedraw - failed redraw." );
        }
      else /* do an object send */
        {
	  status = om$send(msg = message GRgraphics.GRdisplay(msg,
							      matrix_type,
							      matrix,
							      &draw_mode,
							      draw_grid ),
			   senderid = co_objid,
			   targetid = object_grid->objid,
			   targetos = object_grid->osnum );
	  _m_check2p( status, *msg, "COEraseSendRedraw - failed redraw." );
        }
    }
  
  
 quit:
  _m_debug_str( "reached the end of the rope." );
  
  return( status );
}

end implementation super_cmd;

