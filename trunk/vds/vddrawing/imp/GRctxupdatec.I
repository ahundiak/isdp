/* $Id: GRctxupdatec.I,v 1.1.1.1 2001/01/04 21:08:41 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/emsfixes/grnuc/GRctxupdatec.I
 *
 * Description:
 *      This file is a enhancement to GRctxupdatec.I for "move drawing view"
 *      commands.
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: GRctxupdatec.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:08:41  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.2  1998/03/19  20:22:08  pinnacle
# Replaced: vddrawing/imp/GRctxupdatec.I for:  by yzhu for vds
#
# Revision 1.1  1997/12/10  16:53:44  pinnacle
# Created: vddrawing/imp/GRctxupdatec.I by impd for vds
#
# Revision 1.1  1997/08/29  15:42:24  pinnacle
# Created: emsfixes/grnuc/GRctxupdatec.I by yzhu for vds
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *      08/28/97        yzh             add VDS_K_RecomputeDrawingM for
 *                                      "move drawing view" commands.
 * -------------------------------------------------------------------*/


/*
Name
	GRupdatectx - updates context using matrix 

Synopsis
    	GRupdatectx(msg,type,matrix)
	
 	IGRlong	*msg		completion code
	IGRshort *type		matrix type
	IGRmatrix matrix	the environment matix

Description
	This method updates the context object.  The matrix input 
	represents the context matrix for the attachment represented
	by this context object. 

	The context objects representing reference files nested
	inside the reference file this context object represents 
	are also updated.

Diagnostics
	The possible return codes values in the msg 
	field are:

	MSSUCC - successful completion context matched
	MSFAIL - error; context different
Notes
	None.

History
	MAS  	05/27/87 Design date.
        HGB     07/08/91 Notification
        HGB     07/20/93 Check error codes with care
        YZHU    08/13/97 ADD VDS_K_RecomputeDrawingM
*/

class implementation GRcontext;

#include "OMminimum.h"
#include "OMprimitives.h"
#include "grimport.h"
#include "msdef.h"
#include "madef.h"
#include "ref.h"
#include "refdef.h"
#include "godef.h"
#include "v_dbgmacros.h"
// #define DEBUG 1

from GRreffile  import GRinquireref;
from GRgraphics import GRxform;
from GRlistener import GRnotifylis;

extern IGRboolean  VDS_K_RecomputeDrawingM; 

method GRupdatectx ( long *msg; short *type; IGRmatrix matrix )
{
  IGRboolean            pass_on;
  short                 id_type;
  int                   i;
  long                  OMmsg, msg1;
  IGRuint               count;
  IGRmatrix             id_mx;
  struct GRmd_env       env, new_env;
  GRobjid               dummy;
  struct GRinquire_list inquire_requests[2];
  OM_S_CHANSELECT       nested_files_chan, reffile_chan, chan, children_chan;
  OM_S_CHANSELECT       listeners_chan;

  SetProc( GRctxupdatec.I-- GRupdatectx ); Begin 
  __DBGpr_int(" VDS_K_RecomputeDrawingM", VDS_K_RecomputeDrawingM); 

  OMmsg = OM_S_SUCCESS;    /* initialize return values  */
  *msg = MSSUCC;

  OMmsg = om$make_chanselect ( channame = "GRcontext.to_reffile",
                               p_chanselect = &reffile_chan );
  if (1 & OMmsg)    /* get matrix for transformation  */
  {
    inquire_requests[0].var = ENVIRONMENT_INFO;
    inquire_requests[0].var_ptr = (IGRchar *) &new_env;
    inquire_requests[0].num_requested = sizeof(struct GRmd_env);
    inquire_requests[1].var = END_REPORT_REQUEST;
    for (i=0; i<16; ++i)
    {
      env.md_env.matrix[i] = matrix[i];
    }
    env.md_env.matrix_type = *type;
    env.md_id.objid = NULL_OBJID;
    pass_on = FALSE;

    /* NOTE: 
     * there is only one reference file attachment object on the channel 
    */

    msg1 = OM_E_ABORT;
    OMmsg = om$send ( msg = message GRreffile.GRinquireref ( &msg1, &env,
                            inquire_requests, &i, &pass_on, NULL ),
                            p_chanselect = &reffile_chan);

    /* A failure from GRinquireref should be ignored.  
     *	It means the  instance data of the reference file object has 
     *	not been filled in yet.  This occurs when a construct is in
     * 	progress.  The construct method will update the instance data of 
     *	the context objects when the instance data is filled in. 
    */

    if (1 & OMmsg & msg1)
    {

      /* we only send a notification if the matrix has changed */
      OMmsg = om$make_chanselect ( channame = "GRcontext.to_misc",
                                   p_chanselect = &chan );
      if (1 & OMmsg)
      {
        long mask = GR_GEOM_XFORMED;
        int  notify = 1, ii, jj;

        MAidmx ( msg,id_mx );
        id_type = MAIDMX;
    

        om$send(msg = message GRgraphics.GRxform ( msg, &new_env,
					&id_type, id_mx, &dummy ),
                  p_chanselect = &chan );

        notify = memcmp((char *)me->matrix, (char *)new_env.md_env.matrix,
                        16 * sizeof(double));
        memcpy((char *)me->matrix, (char *)new_env.md_env.matrix,
               16 * sizeof(double));
        me->mx_type = new_env.md_env.matrix_type;
        me->osnum = new_env.md_id.osnum;

        /*
	 * we copy the matrix into the instance data in case any body
         * that gets notified needs it
	 */
        if (notify && !VDS_K_RecomputeDrawingM ) {
          	om$send ( msg = message GRlistener.GRnotifylis ( 
				msg, &OMmsg, 
				&mask, NULL ),
                p_chanselect = &chan );
	} /* notify */
      }  /* to_misc */

      /* 
       * update nested context objects (even if the matrix hasn't change, 
       * because a nested file might change 
       */
      OMmsg = om$make_chanselect ( channame = "GRcontext.to_nested_files",
                                   p_chanselect = &nested_files_chan );
      if (1 & OMmsg)
      {
        OMmsg = om$get_channel_count ( objid = my_id, 
                                       p_chanselect = &nested_files_chan,
                                       count = &count);
        if (1 & OMmsg)
        {
          if (count > 1)
            /* 
             * update contexts of reference files nested inside this one.  
             * The contents of this context object represent the context 
             * for the nested files. 
            */
          {  
            OMmsg = om$send ( msg = message GRcontext.GRupdatectx ( msg, 
				&me->mx_type, me->matrix ),
                              p_chanselect = &nested_files_chan,
                              from = 1);
          }
        }
        else
          *msg = MSFAIL;
      } /* to_nested_files */
      else
        *msg = MSFAIL;
    } /* GRinquireref */
    else
      /* reset the OMmsg */
      OMmsg = OM_S_SUCCESS;
  } /* to_reffile */
  else
    *msg = MSFAIL;

  me->flags &= ~GREMPTY_CONTEXT;

  End 
  return OMmsg;
}

end implementation GRcontext;
