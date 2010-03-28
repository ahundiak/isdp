/*
Name
	GRfctthruref

Synopsis

	GRfctthruref ( msg, ref_id, osnum, fct, arg )

	long 		*msg		completion code				OUT
	struct GRid 	*ref_id		the attachment to extract the file 	 IN
     	                                  if ref_id is NULL, then osnum will be
     	                                  used.
     	OMuword         osnum           the osnum of the space			 IN
     	                                  this argument is ignored if ref_id is
     	                                  not NULL
	int             (*fct) ()	the function to be called for each 	 IN
	                                attachment;
					the arguments of the function are:
					
					  f ( mtx_type, matrix, arg )
                                              long   *msg	completion code	 OUT
                                              short  *mtx_type	the matrix type	 IN
					      double *matrix	the matrix	 IN
					      char   *arg	user's argument	 IN
     	char        	*arg		extra arguments passed to the function

Description
	This function calls a function for each attachement starting in the 
	master) of a given file.

Diagnostics
	The possible return codes values in the msg 
	field are:

	MSSUCC - successful completion 
	MSFAIL - error occurred
Notes
	None.

History
	HGB  	12/20/91 	Design date.
*/

class implementation GRreffile;

#include "grimport.h"
#include "msdef.h"
#include "referr.h"
#include "refdef.h"
#include "refpriv.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "OMmacros.h"
#include <alloca.h>


from GRcontext import GRgetinstance;


GRfctthruref ( msg, ref_id, osnum, fct, arg )
long 	    *msg	/* completion code				OUT */;
struct GRid *ref_id	/* the attachment to extract the file 		IN  */; 
OMuword     osnum	/* the osnum of the reference file (ignored if
                           ref_id is not NULL)				IN  */;
int         (*fct) ()	/* the function to be called 	 	 	IN  */;
char        *arg	/* extra arguments passed to the function	IN  */;
{
  short           objects_mx_type, orig_flag, num_opens, num_opens_processed;
  long            OMmsg, msg1;
  int             i, count;
  IGRmatrix       objects_context_matrix;
  OM_S_CHANSELECT super_chan;
  OMuword         osnum1, ref_osnum;
  struct GRid     Super, previous_context;

  OMmsg = GRgetctxsuper ( msg, &Super );
  if (1 & OMmsg & *msg)
  { 
    om$make_chanselect ( p_chanselect = &super_chan,
        channame = "Super_rfmgr.to_context" );

    num_opens = 0;
    num_opens_processed = 0;

    if (ref_id)
    {
      /* we need the OS of the reference file */
      msg1 = MSFAIL;
      om$send ( msg = message GRreffile.GRgetosnum ( &msg1, &ref_osnum ),
                senderid = NULL_OBJID,
                targetos = ref_id->osnum,
                targetid = ref_id->objid );
      if (!( 1 & msg1))
      {
        OMmsg = OM_E_ABORT;
        *msg = MSFAIL;
        goto wrapup;
      }
    }
    else
      ref_osnum = osnum;

    GRget_num_opens ( msg1, ref_osnum, num_opens );
    if (!( 1 & msg1))
    {
      OMmsg = OM_E_ABORT;
      *msg = MSFAIL;
      goto wrapup;
    }

    OMmsg = om$get_channel_count (
        p_chanselect = &super_chan,
        osnum = Super.osnum,
        objid = Super.objid,
        count = (OMuint *)&count );

    if (1 & OMmsg)
    {
      OM_S_OBJECT_LINKAGE *list;
      
      list = (OM_S_OBJECT_LINKAGE *)alloca ( count * sizeof ( OM_S_OBJECT_LINKAGE ) );
      if (list)
      {
        OMmsg = om$get_channel_objects ( osnum = Super.osnum, 
                                         objid = Super.objid,
                                         p_chanselect = &super_chan,
                                         list = list,
                                         size = count,
                                         count = (OMuint *)&count );
        if (OMmsg & 1)
        {
          for (i = 0; (i < count) && (num_opens_processed < num_opens); i++)
          {
            OMmsg = om$send ( msg = message GRcontext.GRgetinstance ( msg, &objects_mx_type,
                                                       objects_context_matrix,
                                                       &osnum1, &orig_flag,
                                                       &previous_context ),
                              senderid = NULL_OBJID,
                              targetos = list [i].osnum,
                              targetid = list [i].S_objid );
            if ((1 & OMmsg) && ((orig_flag & GRACTIVATED_CONTEXT) || (orig_flag & GRMASTER_CONTEXT)))
              if (ref_osnum == osnum1)
              {
                num_opens_processed++;
                fct ( msg, &objects_mx_type, objects_context_matrix, arg );
                if (*msg != MSSUCC)
                {
                  OMmsg = OM_E_ABORT;
                  *msg = MSFAIL;
                  goto wrapup;
                }
              }
          }
        }
        else
        {
          OMmsg = OM_E_ABORT;
          *msg = MSFAIL;
          goto wrapup;
        }
      }
      else
      {
        OMmsg = OM_E_ABORT;
        *msg = MSFAIL;
        goto wrapup;
      }
    }
  }

wrapup:

  return OMmsg;
}

end implementation GRreffile;
