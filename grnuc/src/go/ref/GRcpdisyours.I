/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
	GRdisyourself - sends to the appropriate methods to
		    display a graphics object.

Synopsis
	
     	GRdisyourself(msg, type, matrix, mode, alt_symb,
		   dp_info,key)

	IGRlong *msg		Completion code

	IGRshort *type  	type of the matrix
	IGRmatrix *matrix       environment transformation matrix
	GRdpmode  *mode		the display mode
	struct IGRaltdisplay *alt_symb
				an overriding symbology
       	struct DP_information *dp_info	
				special display information
    	OM_p_KEY_DESC  key	range key information

Description

	This method gathers the pertinent information to display
	a graphics object.  The range information is computed to
	do a pass through the R-tree of the reference file 
	object space to display the objects in the reference
	file space.  If there is a clipping polygon it is also
	displayed.  If the attachment object is to be displayed,
	only the box defining its boundaries is displayed.

Diagnostics
	The possible return codes values in the msg field are:

	MSSUCC - successful completion
	MSFAIL - error
Notes
	None.
History
	MAS     03/27/86 	Design date.
        dhm     07/01/92        ANSI conversion.
\*/

class implementation GRclippoly;

#include "grimport.h"
#include "madef.h"
#include "godef.h"
#include "msdef.h"
#include "dpdef.h"
#include "refdef.h"
#include "dpmacros.h"
#include "gocmacros.h"
#include "refpriv.h"

from GRcontext import GRgetflag;

extern    IGRboolean    GRexpansion_valid();

method  GRdisyourself(IGRlong *msg; IGRshort *mx_type; IGRmatrix
	     	matrix; enum GRdpmode *mode; struct IGRaltdisplay
	  	*alt_symb; struct DP_information *dp_info;
		OM_p_KEY_DESC key)
{
    IGRboolean	mode_override,
		display_polygon;

    enum GRdpmode local_mode;		/* local mode for clip poly	*/

    IGRchar  	*ptr;

    IGRshort 	flag;

    IGRlong  	OMmsg,			/* OM return code		*/
		msg1;			/* local message		*/

    IGRuint   	i,j,
		count;

    IGRdouble 	poles[606],
		poles2[303],
		poles3[303],
		knots[307],
		bdrys[404];

/*    IGRmatrix 	env_matrix;  working matrices    (Never referenced)  */

    GRrange   	range;

    struct DPele_header ele_header;
    struct IGResbc bc_attr;
    struct IGRbsp_curve curve,
		bot_curve,
		top_curve;
    struct IGRcv_prism  *cp;
    struct IGRdisplay   dis_attr;
    struct GRid ref;			/* reference file objid		*/

    OM_S_CHANSELECT chan,		/* channel structures		*/
		    context_chan;

    OM_S_OBJECT_LINKAGE list;		/* channel ofjects list		*/


    *msg = MSSUCC;			/* initialize return values	*/
    OMmsg = OM_S_SUCCESS;	    

    mode_override = (  ((*mode == GRhd) || (*mode == GRhe) || 
		       	(*mode == GRhhd) || (*mode == GRhdo) ||
	        	(*mode == GRbehe) || (*mode == GRbdhe) || 
	        	(*mode == GRbehd) || (*mode == GRhhdo) || 
			(*mode == GRheo) || (*mode == GRbdheo) || 
			(*mode == GRbeheo) ) ? 1 : 0);

    display_polygon = FALSE;

    if (GRexpansion_valid())
    {
	if (DPlevel_on(me->level,dp_info))
	{
	    if (me->properties & GRIS_DISPLAYABLE)
	    {
	   	display_polygon = TRUE;
	    }
	    else if (! DPis_fit(dp_info))
	    {
		if (mode_override)
		{
		    display_polygon = TRUE;
		}
	    }
	}
    }
	
    if ( display_polygon )
    {
	local_mode =   *mode;

	if ( ! (me->properties & GRIS_DISPLAYABLE))
	{
	    if (*mode == GRbdhe)
	    {
		local_mode = GRhe;
	    }
	    else if (*mode== GRbdheo)
	    {		
	    	local_mode = GRheo;
	    }
	}
	    
	GRgetprism(msg,mx_type,matrix,&ptr,i);
	if ( 1 & *msg)
	{			
	    cp = (struct IGRcv_prism *) ptr;

	    if ( ( *mx_type != MAIDMX) || (key == 0) )
	    {
	        MAcpextents(&msg1,cp,range,&range[3]);
	    }
	    else
	    {
		GRtransrange(&msg1,key,range);
	    }		


	    dp$build_dis_buffer(buffer = &ele_header,
		type = IGRBC,
		range = range,
		level = NULL,
		display_att = &dis_attr,
		ele_spec_att = &bc_attr,
		geometry = ptr);

	    if ( DPis_fit(dp_info))
	    {
	        dp$dispelem(msg = msg, 
			buffer = &ele_header, 
			mode = *mode, 
			dp_info = dp_info);
	    }
	    else
	    {
	    	if (alt_symb)
	    	{
		    dis_attr.color = (alt_symb->color ?
		    	*alt_symb->color : me->display_attr.color);
		    dis_attr.weight = (alt_symb->weight ?
		    	*alt_symb->weight : me->display_attr.weight);
		    dis_attr.style = (alt_symb->style ?
		    	*alt_symb->style : me->display_attr.style);
	    	}
	    	else 
	    	{
		    dis_attr = me->display_attr;
	    	}

	    	bc_attr.is_polydis = FALSE;
	        bc_attr.is_curvedis = TRUE;

	        MArptsxform(&msg1,&cp->curve.num_poles,&cp->curve.rational,
		    cp->curve.weights,cp->matrix,cp->curve.poles,poles2);

	        for (i=0,j=0; i<cp->curve.num_poles; ++i,j+=3)
	        {
		    poles3[j] = cp->curve.poles[j];
		    poles3[j+1] = cp->curve.poles[j+1];

		    if (cp->curve.rational)
		    {
		        poles3[j+2] = (cp->curve.poles[j+2] + cp->height)/
				cp->curve.weights[i];
		    }
		    else
		    {
		        poles3[j+2] = cp->curve.poles[j+2] + cp->height;
		    }
	        }
	    	MArptsxform(&msg1,&cp->curve.num_poles,&cp->curve.rational,
		    cp->curve.weights,cp->matrix,poles3,poles3);

	      	top_curve = bot_curve = cp->curve;
	    	top_curve.poles = poles2;	    
	    	bot_curve.poles = poles3;	    

      	    	ele_header.geometry.bspcurve = &top_curve;
					/* display object		*/
	    	dp$dispelem(msg = msg, 
			buffer = &ele_header, 
			mode = local_mode, 
			dp_info = dp_info);

		if (*msg == DPSTOPDRAW)
		{
		    *msg = MSSUCC;
		    OMmsg = OM_I_STOP_SENDING;
		    goto wrapup;
		}
      	    	ele_header.geometry.bspcurve = &bot_curve;
					/* display object		*/
	    	dp$dispelem(msg = msg, 
			buffer = &ele_header, 
			mode = local_mode, 
			dp_info = dp_info);
		if (*msg == DPSTOPDRAW)
		{
		    *msg = MSSUCC;
		    OMmsg = OM_I_STOP_SENDING;
		    goto wrapup;
		}

	    	om$make_chanselect ( channame = "GRclippoly.to_attachment",
			p_chanselect = &chan);

	    	msg1 = om$get_channel_objects(
			objid = my_id,
			p_chanselect = &chan,
			list = &list,
			size = 1,
			count = &i);
		
	    	if ( 1 & msg1)
	    	{
		    /* if a failure occurs due to the sides of the curve
		     * prism not being stroked, don't let the method
		     * fail, just continue.
		     */

		    ref.objid = list.S_objid;
		    ref.osnum = list.osnum;	    

	            om$make_chanselect ( channame = "GRreffile.to_context",
		    	p_chanselect = &context_chan);

		    /* send to each context object for this reference 
		     * file attachment.  If one is cyclic, do not display
		     * the prism sides.
		     */
		
		    msg1 = om$get_channel_count(
			objid = ref.objid,
			p_chanselect = &context_chan,
			count = &count);

		    if ((1 & msg1) && count)
		    {
		    	flag = 0;
		    	for (i = 0; 
			    ((i<count)&&(!(flag & GRCYCLIC_ATTACHMENT)));
		 	     ++i)
		    	{
		  	    om$send (msg = 
				  message GRcontext.GRgetflag(&msg1,&flag),
			    	p_chanselect = &context_chan,
			    	senderid = ref.objid,
			    	targetos = ref.osnum,
			    	from = i,
			    	to = i);
		    	}
		    	if (!(flag & GRCYCLIC_ATTACHMENT))
		    	{
			    curve.poles = poles;
	    		    curve.knots = knots;
	    		    curve.bdrys = bdrys;

	    		    GRstrokcp(&msg1,&top_curve,&bot_curve,cp,
				&curve);
			    if ( 1 & msg1)
			    {
      	    		        ele_header.geometry.bspcurve = &curve;
				dis_attr.style = 6;
					/* display object		*/
	    		    	dp$dispelem(msg = &msg1,
				    buffer = &ele_header, 
				    mode = local_mode, 
				    dp_info = dp_info);
				if (*msg == DPSTOPDRAW)
				{
		    		    *msg = MSSUCC;
		    		    OMmsg = OM_I_STOP_SENDING;
		    		    goto wrapup;
				}
			    }
		        }
		    }
	    	}
	    }
	}
	else				/* get geometry failed		*/
	{
	    *msg = MSFAIL;
	}

	if (!(1 & *msg))
	{
	    OMmsg = OM_E_ABORT;
       	}

	if ( (1 & OMmsg) && (! dp_info->is_update) &&
	     (! DPis_fit(dp_info)) &&
	     (!( (*mode == GRhdo) ||(*mode == GRhhdo) || 
		 (*mode == GRheo) || (*mode == GRbdheo) || 
		 (*mode == GRbeheo) ) ) )
	{		

	    /* check to see if the message came from the reference
	     * file attachment object.  If not, send to it also.
	     */

    	    OMmsg = om$is_objid_on_channel(
		objid_c = my_id,
		p_chanselect = &chan,
		objid = sender_id);

    	    if (OMmsg == OM_W_NOTONCHAN)
    	    {
		/* the sender is not the reference file object.  Therefore
	 	 * send the message to the reference file object also
	 	 */

	    	OMmsg = om$send(
		   msg = message GRgraphics.GRdisyourself
			(msg, mx_type, matrix, mode, alt_symb,dp_info,key),
		   p_chanselect = &chan);
	    }
	}
    }

    GR_NOTIFY_LISTENERS(msg,&OMmsg,GR_DISPLAYED);

wrapup:

    return (OMmsg);
}
end implementation GRclippoly;
