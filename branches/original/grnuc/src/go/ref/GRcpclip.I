/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
        GRclip -- clip graphics object method

Synopsis

        GRclip(msg,cur_env,target_env,prism,in_id,out_id,
	       ovl_id,clip_flags)

	IGRint	*msg
	struct GRmd_env *cur_env
	struct GRmd_env *target_env
	IGRchar *prism; 
	struct GRid *in_id
	struct GRid *out_id
	struct GRid *ovl_id
	IGRlong *clip_flags

Description

	The clipping polygon of a reference file will be 
	clipped if it overlaps the prism only when the GR_CLIP_FORPLOT
        bit is set in the clip flags.  The return values for this 
        method are:
		GR_I_OBJINSIDE - the clipping polygon is 
		    totally inside the prism
		GR_I_OBJOUTSIDE - the clipping polygon is 
		    totally outside the prism
                MSSUCC - the clipping polygon is overlapping 
                    the prism
Diagnostics
	This method returns the following return codes:
	  GR_I_OBJINSIDE - if the object was totally inside the
  		           right prism
	  GR_I_OBJOUTSIDE - if the object was totally outside the
	  		    right prism
          MSSUCC - if the object is overlapping the prism
	  MSINARGS - if the input arguments for inside, outside,
		     and overlap conditions are not valid.
Notes
	None

History
	MAS	05/27/87	Design Date.
        jhw     07/25/89        Added support for polygon clipping if
                                the clip is for plotting.
        dhm     06/30/92        ANSI conversion.
\*/

class implementation GRclippoly;

#include "grimport.h"
#include "msdef.h"
#include "grerr.h"
#include "godef.h"
#include "gocmacros.h"

#define  OVERLAP  2
#define  INSIDE   1
#define  OUTSIDE  0

method GRclip(IGRlong *msg; struct GRmd_env *env,*target_env;
	      IGRchar *prism; struct GRid *in_id;
	      struct GRid *out_id; struct GRid *ovl_id;
	      IGRlong *clip_flags)
{
    IGRlong	in_out;
    IGRshort	type_prism;

    IGRlong	OMmsg;			/* OM return value		*/
    

    *msg = MSSUCC;			/* initialize return values	*/
    OMmsg = OM_S_SUCCESS;

    if (*clip_flags & GR_CLIP_NORGCK)
    {
	*msg = MSINARG;
	OMmsg = OM_E_ABORT;
    }
    else
    {
    	if (*clip_flags & GR_CLIP_RTPRISM)
    	{
	    type_prism = 0;
    	}
    	else
    	{
	    type_prism = 1;
    	}

	OMmsg = om$send(
		msg = message GRvg.GRprismrel
		    (msg,&env->md_env.matrix_type,
		     env->md_env.matrix,NULL,
		     &type_prism,prism,&in_out),
		targetid = my_id);

        if (!(OMmsg & 1 & *msg))
  	{
 	    *msg = MSFAIL;
	}
	else
	{
	    switch (in_out)	
	    {
	  	case OUTSIDE:	
		{
		    *msg = GR_I_OBJOUTSIDE;
		    break;
		}
	    	case INSIDE:
	    	{
		    *msg = GR_I_OBJINSIDE;
		    break;
		}
                case OVERLAP:
                {
                    /*
                     * If the clip is for a plot have the clippoly's
                     * face clip itself to the prism.
                     */
                    if (*clip_flags & GR_CLIP_FORPLOT)
                    {
                        struct GRmd_env local_env;
                        int n;

                        if (env->md_env.matrix_type == MAIDMX)
                        {
                            for (n=0; n<16; ++n)
                            {
                                local_env.md_env.matrix[n] = me->matrix[n];
                            }
                        }
                        else 
                        {
                            n = 4;
                            MAmulmx ( msg,
                                      &n, &n, &n,
                                      env->md_env.matrix,
                                      me->matrix,
                                      local_env.md_env.matrix );
                        }

                        MAtypemx ( msg,
                                   local_env.md_env.matrix,
                                   &local_env.md_env.matrix_type );

                        local_env.md_id = env->md_id;

                        /*
                         * Send the clip message to the clippoly's face.
                         */
                        OMmsg = om$send ( msg = message GRvg.GRclip
                                                        ( msg,
                                                          &local_env,
                                                          target_env,
                                                          prism,
                                                          in_id, out_id, ovl_id,
                                                          clip_flags ),
                                          targetid = me->cv_objid );

                        if ( OMmsg & *msg ) *msg = MSSUCC;

                    }
                    else 
                    {
                        OMmsg = OM_E_ABORT;
                        *msg = MSINARG;
                    }
                    break;
                }
	  	default:
		{
		    OMmsg = OM_E_ABORT;
		    *msg = MSINARG;
		}
	    }
	}
    }

    GR_NOTIFY_LISTENERS(msg,&OMmsg,GR_CLIPPED);

    return( OMmsg );
}

end implementation GRclippoly;
