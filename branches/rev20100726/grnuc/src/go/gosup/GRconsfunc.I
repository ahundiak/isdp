/* #######################    APOGEE COMPILED   ######################## */
class implementation GRvg;

#include "grimport.h"
#include "msdef.h"
#include "OMmacros.h"
#include "grownmacros.h"

from GRmodule import GRmdaddwrng;
from GRconic import GRputarc;
from GRlinear import GRputpolyline;

IGRlong  GRconsfunction(arglist,objid,properties,hidden_line,type)

struct GRvg_construct *arglist;
GRobjid		*objid;
IGRshort	*properties;
IGRint		*hidden_line;
IGRshort	*type;
{
  struct IGRpolyline *polyline;	   	/* polyline geometry pointer	*/
  struct IGRarc *arc;		   	/* arc geometry pointer		*/

  struct GRpost_info info;		/* information for post routine */

  GRobjid new_id;			/* for post method 		*/
  GRrange range;

  IGRlong msg;
  IGRlong OMmsg;

  IGRboolean world;

    
  
	OMmsg = OM_S_SUCCESS;
  	*(arglist->msg) = MSSUCC;

      	*properties =  arglist->properties | GRIS_NEW ;
	
      	if( arglist->name )
      	{
            OMmsg = om$send(mode = OM_e_wrt_object,
                      msg = message GRvg.GRputname(&msg,arglist->name),
                      senderid = *objid,
                      targetid = *objid);
	    if ( ! ( 1 & OMmsg ))
	    {
		*(arglist->msg) = MSFAIL;
	    }
      	}
      	if( 1 & OMmsg )
	{
	    info.construct_flag = TRUE;

	    switch (*type)
	    {
		case GRCURVE:	/* B-spline construction	*/
		{
  		    om$send(mode = OM_e_wrt_object,
                      	    msg = message GRvg.GRputattr(&msg,
				arglist->class_attr),
                      	    senderid = *objid,
                      	    targetid = *objid);
			
        			 /* post the instance data       */
            	    OMmsg = om$send(mode = OM_e_wrt_object,
                    	    msg = message  GRvg.GRpostabsg
				(arglist->msg,arglist->env_info,
			 	 &info,arglist->geometry,&new_id),
                    	    senderid = *objid,
                            targetid = *objid);

			break;
		}
		case GRCN:		/* arc construction		*/
		{
              	    arc = (struct IGRarc *)arglist->geometry;
           			 /* post the instance data       */
            	    OMmsg = om$send(mode = OM_e_wrt_object,
                    	    msg = message  GRconic.GRputarc
				(arglist->msg,arglist->env_info,&info,arc,
			 	&new_id),
                    	    senderid = *objid,
                     	    targetid = *objid);
			break;
		}
		case GRLN:
		{
           	    polyline = (struct IGRpolyline *)arglist->geometry;
           			 /* post the instance data       */
            	    OMmsg = om$send(mode = OM_e_wrt_object,
                    	    msg = message  GRlinear.GRputpolyline
				(arglist->msg,arglist->env_info,
				 &info,polyline,&new_id),
                    	    senderid = *objid,
                    	    targetid = *objid);
		    break;
		}
		default:
		{
		    OMmsg = OM_E_ABORT;	
		    *(arglist->msg) = MSFAIL;
		    break;
		}
	    }
            if( 1 & OMmsg & *arglist->msg ) 
	    {			/* is R-tree insertion needed	*/
		if ( ! ( (*properties & GRNOT_IN_RTREE) ||
		       (IF_NULL_OBJID(arglist->env_info->md_id.objid))))
	    	{	
		    world = FALSE;
					/* get the range of the object	*/
		    OMmsg =om$send(
		     	    msg = message GRvg.GRgetrang
				(arglist->msg,
				 &arglist->env_info->md_env.matrix_type,
				 arglist->env_info->md_env.matrix,
				 &world,range),
			    senderid = *objid,
			    targetid = *objid);
					/* add the object to the R-tree	*/
	      	    if (1 & OMmsg)
	      	    {
      			OMmsg = om$send(mode = OM_e_wrt_object,
                                msg = message GRmodule.GRmdaddwrng(
					arglist->msg,range,objid),
                                senderid = *objid,
                                targetid = arglist->env_info->md_id.objid,
                                targetos = arglist->env_info->md_id.osnum);
	      	    }		  
		}
            }
	}
        if ( 1 & OMmsg)
	{
	    gr$add_to_active_owner(
		msg = &msg,
		mod_env = arglist->env_info,
		objid = *objid);
		
	}
    return (OMmsg);
}

end implementation GRvg;
