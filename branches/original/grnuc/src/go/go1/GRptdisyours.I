/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME:	GRpoint

     METHOD NAME:	GRdisyourself

     Abstract: 		This implementation file accumulates the
			information necessary to display an 
			object.

-----
%SC%    

    VALUE = GRdisyourself(msg,type,matrix,mode,alt_symb,
			  sp_info,key)

-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   ------------------------------------
     *type        IGRshort	 type of matrix 
     matrix	  IGRmatrix	 environment transformation matrix
     *mode	  GRdpmode       the display mode attributes 
     *alt_symb    IGRaltdisplay	 alternate display symbology
     *sp_info	  DP_information special information needed by the 
				     display routines
     key	  OM_p_KEY_DESC	 pointer to structure for range
				     info; send null pointer if
				     not known.
-----
%EX%
     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     *msg	  IGRlong	 completion code:
			    	     MSSUCC - successful completion
				     MSFAIL - failure of routine
				     DPBADMODE - invalid display mode
				     DPBADELETYP - display routine
					does not recognize this 
				 	element type
-----
%MD%

     MODULES AND METHODS INVOKED:

     Modules:

     Methods:
 	GRgetsymb
-----
%RL%

     RELATIONS REFERENCED:
	none.
-----
%NB%

     NOTES:

	none.
-----
%CH%

     CHANGE HISTORY:
	
	MAS     03/04/86 : Design date.
-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
This method loads the display buffer with the information needed
to display the point object.
----*/
/*EH*/

class implementation GRpoint;

#include "grimport.h"
#include  "igrdef.h"
#include  "madef.h"
#include  "msdef.h"
#include  "godef.h"
#include  "dpmacros.h"
#include  "gocmacros.h"
#include  "dperr.h"
#include  "dpdef.h"
#include  "DPdlist.h"

method GRdisyourself(IGRlong *msg; IGRshort *type; IGRmatrix matrix;
		 enum GRdpmode *mode; struct IGRaltdisplay *alt_symb;
		 struct DP_information *sp_info; OM_p_KEY_DESC key)

{
    int        sts;
    IGRlong    OMmsg;			/* OM return value		*/
    IGRlong    i;			/* loop index			*/
    IGRlong    msg2;			/* local return message		*/

    IGRint     action,
	       flags;

    IGRdouble  point[3];

    GRrange    range;			/* range of element		*/

    struct     IGRpolyline py;		/* pointset structure		*/
    struct     DPele_header ele_header;	/* display structure		*/
    struct     IGRdisplay  dis_attr;
    int        dlist_flags;

    *msg = MSSUCC;			/* initialize return code	*/
    OMmsg = OM_S_SUCCESS;
    


    
    /* Added support for single element display using display lists */
    dlist_flags = sp_info->is_update ? 0 : DP_DLIST_DISPLAY_SINGLE_ELEMENT;
    sts = DPdlist_display_element( my_id, OM_Gw_current_OS, sp_info, matrix,
                                   *type, *mode, alt_symb, key, dlist_flags );
    if  (1 & sts )
    {
       goto wrapup;
    }

    if ( ((me->properties & GRIS_DISPLAYABLE)  || (*mode == GRhdo) || 
	  (*mode == GRhhdo) || (*mode == GRheo) ||
         (*mode == GRbdheo) || (*mode == GRbeheo) )
	&& (DPlevel_on(me->level,sp_info)))
    {
	if ( (key ) && (*type == MAIDMX))
 	{
	    if (! GRtransrange(&msg2,key,range))
	    {
		*msg = MSFAIL;
		OMmsg = OM_W_ABORT;
		goto wrapup;
	    }
	    if ( DPis_fit(sp_info))
	    {
	    	dp$build_dis_buffer(buffer = &ele_header,
		    tag  = my_id,
		    type = IGRPS,
		    range = range,		
		    level = NULL,	/* level already checked	*/
		    display_att = NULL,
		    ele_spec_att = NULL,/* none for polyline stroker	*/
		    geometry = NULL);

	        dp$dispelem(msg = msg, 
			buffer = &ele_header, 
			mode = *mode, 
			dp_info = sp_info);
		if ( ! (1 & *msg))
		{
		    OMmsg = OM_W_ABORT;
		}

		goto wrapup;
	    }
        }
	py.points = point;
	py.num_points = 1;
	
    	action = 2;
	
	OMmsg = om$send(msg = message GRlinear.GRgetpolyline
		(msg,type,matrix,&action,&py),
	    targetid = my_id);

        if (1 & OMmsg & *msg)
	{	
      	    for (i = 0; i<3; ++i)	/* assign range of point	*/
      	    {
	    	range[i] = range[i+3] = py.points[i];
	    }

	    flags = ((me->properties & GRFILLED_DISPLAY) ? 
		DPPOLY_FILL : 0);

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

	    dp$build_dis_buffer(buffer = &ele_header,
		tag  = my_id,
		type = IGRPS,
		range = range,		
		flags = flags,
		level = NULL,		/* level already checked	*/
		display_att = &dis_attr,
		ele_spec_att = NULL,	/* none for polyline stroker	*/
		geometry = &py);

	    dp$dispelem(msg = msg, 
			buffer = &ele_header, 
			mode = *mode, 
			dp_info = sp_info);

	    if (!(1 & *msg))
	    {
		OMmsg = OM_W_ABORT;
            }
	    else
	    {
		if (*msg == DPSTOPDRAW)
		{
		    *msg = MSSUCC;
		    OMmsg =  OM_I_STOP_SENDING;
		}

    		GR_NOTIFY_LISTENERS(msg,&OMmsg,GR_DISPLAYED);
            }
	}
    }

wrapup:

    if ( !(1 & OMmsg))
    {
	OMmsg = OM_W_ABORT;
    }

    return (OMmsg);

}
end implementation GRpoint;

