/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME:	GRlinear

     METHOD NAME:	GRdisyourself

     Abstract: 		This implementation file loads the data
			necessary to display a graphics object.

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
     *mode	  GRdpmode       the display mode 
     *alt_symb	  IGRaltdisplay	 structure containing alternate display
				     attributes.
     *sp_info	  DP_information special display information needed by 
				 the display routine
     key	  OM_p_KEY_DESC  pointer to structure for range; 
				     send null pointer if not known.

-----
%EX%
     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     *msg	  IGRlong	 completion code:
			    	     MSSUCC - successful completion
				     DPBADMODE - bad display mode
				     MSFAIL - failure of routine
-----
%MD%

     MODULES AND METHODS INVOKED:

     Modules:
	MAcubepy
	GRtransrange

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
	
	MAS     01/13/86 : Design date.
-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------

This method gathers all the information necessary to display an
object.

----*/
/*EH*/

class implementation GRlinear;

#include  "grimport.h"
#include  "igrdef.h"
#include  "msdef.h"
#include  "gocmacros.h"
#include  "godef.h"
#include  "madef.h"
#include  "dpmacros.h"
#include  "dperr.h"
#include  "dpdef.h"
#include  "OMmacros.h"
#include  "DPdlist.h"

method GRdisyourself(IGRlong *msg; IGRshort *type; IGRmatrix matrix;
		 enum GRdpmode *mode; struct IGRaltdisplay *alt_symb;
		 struct DP_information *sp_info; OM_p_KEY_DESC key)

{

    IGRchar    *ptr;			/* pointer			*/

    IGRshort   flags;

    IGRlong    OMmsg;			/* OM return value		*/
    int        sts;
    IGRlong    i;			/* loop index			*/
    IGRlong    msg2;			/* local return message		*/

    IGRint     action,
	       inf_line=0;

    IGRdouble  points[1500];

    GRrange    range;
    GRclassid  classid;
 
    struct     DPele_header ele_header;	/* pointer to the structure for
					   display function		*/
    struct     IGRpolyline  py;
    struct     IGRbsp_curve *curve;
    struct     IGRdisplay   dis_attr;
    struct     GRmdenv_info mdenv_info;
    int        dlist_flags;

    extern IGRboolean MApyextents();	/* extents of polyline		*/
    extern IGRboolean GRtransrange();	/* translate range		*/

    *msg = MSSUCC;			/* initialize return codes	*/
    OMmsg = OM_S_SUCCESS;

    /* Adding support for single element display in display lists */

    dlist_flags = sp_info->is_update ? 0 : DP_DLIST_DISPLAY_SINGLE_ELEMENT;
    sts = DPdlist_display_element( my_id, OM_Gw_current_OS, sp_info, matrix, 
                                   *type, *mode, alt_symb, key, dlist_flags );
    if ( 1 & sts )
    {
       goto wrapup;
    }
    if( ((me->properties & GRIS_DISPLAYABLE) ||(*mode == GRhdo) || 
	 (*mode == GRhhdo) || (*mode == GRheo) ||
         (*mode == GRbdheo) || (*mode == GRbeheo) )
	&& (DPlevel_on(me->level,sp_info)))
    {		
	if (DPis_fit(sp_info))
	{
	    om$get_classid(objid = my_id,
		p_classid = &classid);

	    OMmsg = om$is_ancestry_valid(
		subclassid = classid,
		superclassname = "GRinfline");

	    if (OMmsg == OM_S_SUCCESS)
	    {
		inf_line = 1;
	    }

	    OMmsg = GRprocessfit(msg,type,matrix,sp_info,key,
		inf_line,1,&my_id);

	    goto wrapup;
	}

        /* if the object has override, it has a special display */
        if ((me->properties & DEHAS_OVERRIDE) && (DPis_wireframe(sp_info)))
        {
          om$send ( msg = message GRvg.DEdisyourself( msg, type, matrix, mode,
                                                      alt_symb, sp_info, &key ),
                    targetid = my_id );
          if (*msg == MSSUCC)
            goto wrapup;
        }

	if (GRabsg_test(msg,type,matrix,&OM_Gw_current_OS,&my_id,
		&ptr))
	{
	    curve = (struct IGRbsp_curve *) ptr;

	    py.points = curve->poles;
	    py.num_points = curve->num_poles;
	}
	else
	{
	    py.points = points;
	    py.num_points = 500;

			/* flag to indicate array sent in	*/
	    action = 2;
	
	    OMmsg = om$send(msg = message GRlinear.GRgetpolyline(
			msg,type,matrix,&action,&py),
	    	targetid = my_id);

	    if (! (1 & OMmsg & *msg))
	    {		
		GRgetabsg(msg,type,matrix,&ptr,i);
		if (1 & *msg)
		{
		    OMmsg = OM_S_SUCCESS;
		    curve = (struct IGRbsp_curve *) ptr;
	    	    py.points = curve->poles;
	    	    py.num_points = curve->num_poles;
	  	}
		else
		{
		    OMmsg = OM_W_ABORT;
		}
	    }
	}
    	if ( (py.points) && (1 & OMmsg & *msg))
	{
	    if ( ( *type != MAIDMX) || (key == 0) )
	    {
      		MApyextents(&msg2,&py,range,&range[3]);
	    }
	    else
	    {
	        GRtransrange(&msg2,key,range);
	    }
	    if (! (1 & msg2))
	    {
		*msg = MSFAIL;
		OMmsg = OM_W_ABORT;
		goto wrapup;
	    }
	    if ( py.num_points < 2)
	    {
		for (i = 0; i < 3; ++i)
		{
		    points[i] = points[i+3] = py.points[i];
		}
		py.num_points = 2;
		py.points = points;
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

	    mdenv_info.matrix_type = *type;
	    OM_BLOCK_MOVE(matrix, mdenv_info.matrix, sizeof(IGRmatrix));

	    dp$build_dis_buffer(buffer = &ele_header,
		    tag  = my_id,
		    type = IGRPY,
		    range = range,		
		    level = NULL,	/* level already checked	*/
		    flags = flags,
		    display_att = &dis_attr, 
		    ele_spec_att = NULL,/* none for polyline stroker	*/
		    geometry = &py,
		    mdenv_info = &mdenv_info);

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

    if (! (1 & OMmsg))
    {
	OMmsg = OM_W_ABORT;
    }

    return (OMmsg);
}
end implementation GRlinear;
