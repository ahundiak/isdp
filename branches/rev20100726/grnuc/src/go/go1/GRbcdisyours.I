/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME:	GRbspline

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
	GRtransrange

     Methods:
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

class implementation GRbspline;

#include "grimport.h"
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


extern    IGRboolean    GRtransrange();

method GRdisyourself(IGRlong *msg; IGRshort *type; IGRmatrix matrix;
		 enum GRdpmode *mode; struct IGRaltdisplay *alt_symb;
		 struct DP_information *sp_info;
		 OM_p_KEY_DESC key)

{
    IGRboolean world;
    int        sts;

    IGRchar    *ptr;			/* pointer			*/
    IGRchar    *attr;			/* element specfic pointer	*/

    IGRshort   flags;

    IGRlong    OMmsg;		/* OM return value		*/

    IGRlong    msg2;			/* local return message		*/

    GRrange    range;

    struct     DPele_header ele_header;	/* pointer to the structure for
					   display function		*/
    struct     IGResbc	    bc_attr;	/* B-spline element specific 
    					   attributes			*/
    struct     IGRdisplay   dis_attr;

    struct     GRmdenv_info mdenv_info;
    int        dlist_flags;

extern    IGRboolean    GRtransrange();

    *msg = MSSUCC;			/* initialize return codes	*/
    OMmsg = OM_S_SUCCESS;

    /* Adding support for single element display in display lists */

    dlist_flags = sp_info->is_update ? 0 : DP_DLIST_DISPLAY_SINGLE_ELEMENT;
    sts = DPdlist_display_element( my_id, OM_Gw_current_OS, sp_info, matrix, 
                                   *type, *mode, alt_symb, key, dlist_flags );
    if (1 & sts )
    {
       goto wrapup;
    }

    if( ((me->properties & GRIS_DISPLAYABLE) ||(*mode == GRhdo) || 
	 (*mode == GRhhdo) || (*mode == GRheo) || 
         (*mode == GRbdheo) || (*mode == GRbeheo) )
	&& (DPlevel_on(me->level,sp_info)))
    {		
					/* get range in proper format	*/
	if (DPis_fit(sp_info))
	{
	    OMmsg = GRprocessfit(msg,type,matrix,sp_info,key,0,0,&my_id);
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

	if ( ( *type != MAIDMX) || (key == 0) )
	{
	    world = TRUE;

	    OMmsg = om$send
		    (msg = message GRvg.GRgetrang
			(msg,type,matrix,&world,range),
		targetid = my_id);
	}
	else
	{
	    OMmsg = GRtransrange(msg,key,range);
	}

	if ( ! (1 & OMmsg & *msg))
	{
	    goto wrapup;
	}
  			 		/* get abstract geometry	*/
	GRgetabsg(&msg2,type,matrix,&ptr,i);

        if (1 & msg2)
	{
					/* assign element specific attr*/
	    attr = (IGRchar *)&bc_attr;	

	    OMmsg = om$send(
		msg = message GRvg.GRgetattr(msg,attr),
		targetid = my_id);

	    if (!(1 & OMmsg))
	    {
		*msg = MSFAIL;
	  	goto wrapup;
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
		type = IGRBC,
		range = range,
		level = NULL,
		flags = flags,
		display_att = &dis_attr,
		ele_spec_att = &bc_attr,
		geometry = ptr,
		mdenv_info = &mdenv_info);
					/* display object		*/
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
	else				/* get geometry failed		*/
	{
	    *msg = MSFAIL;
	    OMmsg = OM_W_ABORT;
	}
    }

wrapup:

    if (! (1 & OMmsg))
    {
	OMmsg = OM_W_ABORT;
    }

    return (OMmsg);
}
end implementation GRbspline;
