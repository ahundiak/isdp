/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME:   GRconic
     METHOD NAME:   GRlocaldp

     Abstract: 	    This method displays a local area defined on a 
		    conic geometry object.

-----
%SC%    

     GRlocaldp(msg, type, matrix, parm, mode, display_info,
	       display_location,display_flag)

-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   ------------------------------------
      *type       IGRshort	 type of the matrix
      *matrix     IGRmatrix      environment transformation matrix
      *parm	  GRparms	 parametric description of local area
				 of object to be displayed
      *mode	  GRdpmode	 array of display modes:
				   mode[0] : mode for element
				   mode[1] : mode for extension
				 NOTE:
				   This applies only if 
				   display_flag == 0 (display object
				   and extensions), otherwise only
				   one mode is needed.
      *display_info GRid	 window/view information denoting 
				 where to display the object
      *display_location	  
		  IGRshort	 obsolete variable left for compatibility
      *display_flag	  
		  IGRshort	 flag to indicate what to display
				   0 : display both object and
				       extensions
				   1 : display extension only
				   2 : display element only
-----
%EX%
     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     *msg	  IGRlong	 completion code
				    - MSSUCC if successful
				    - MSFAIL (severe) if failure

-----
%MD%

     MODULES AND METHODS INVOKED:
     Modules:
		MAcubepy
		MAartobc
		MAbctoar
     Methods:
		GRdisbybuf
		GRgetsymb
-----
%RL%

     RELATIONS REFERENCED:
	        None.
-----
%NB%

     NOTES:	None.

-----
%CH%

     CHANGE HISTORY:
	
	MAS	06/09/86 : Creation date.
-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
	TBD.
----*/
/*EH*/

class implementation GRconic;

#include "grimport.h"
#include  "igrdef.h"
#include  "msdef.h"
#include  "madef.h"
#include  "dpmacros.h"
#include  "godef.h"
#include  "gocmacros.h"
#include  "dpdef.h"

extern    IGRboolean    MAcubepy();
extern    IGRboolean    MAartobc();
extern    IGRboolean    MAbctoar();

#define DISPLAY_BOTH 0
#define EXTENSION_ONLY 1
#define ELEMENT_ONLY 2

#define ELEMENT_MODE 0
#define EXTENSION_MODE 1


method  GRlocaldp(IGRlong *msg; IGRshort *mx_type; IGRmatrix
     		  matrix; struct GRparms *parm; enum GRdpmode *mode; 
		  struct GRid *display_info; IGRshort 
		  *display_location; IGRshort *display_flag)
{

    IGRchar    *ptr;			/* pointer			*/

    IGRlong    OMmsg;			/* OM return value		*/
    IGRlong    msg2;			/* local return message		*/
    IGRlong    num_elem = 1;		/* number to display		*/

    GRrange    range,range2;		/* range of element		*/

    struct     DPele_header 		/* element headers for dp	*/
	       ele_header[2],*hdr_ptr;
    struct     IGRbsp_curve *curve;	/* structure for B-spline curve */
    struct     IGRbsp_curve curve1;	/* curves to display		*/
    struct     IGResbc bc_attr;		/* element spec. attributes	*/
    struct     IGRdisplay local_dp;	/* for extensions		*/
    struct     IGRarc arc;		/* arc structure		*/
    struct     GRsymbology  symb;

    enum GRdpmode int_mode;		/* internal mode		*/

    IGRdouble  poles[MAELPOLE_SIZE*3],	/* storage for curves		*/
	       knots[MAELKNOT_SIZE],
	       weights[MAELPOLE_SIZE];


    *msg = MSSUCC;
    OMmsg = OM_S_SUCCESS;

    curve1.poles = poles;
    curve1.knots = knots;
    curve1.weights = weights;

    /* generate the abstract geometry
     */

    GRgetabsg(&msg2,mx_type,matrix,&ptr,i);

    if (! (1 & msg2))
    {
	*msg = MSFAIL;
	OMmsg = OM_E_ABORT;
	goto wrapup;
    }

    curve = (struct IGRbsp_curve *) ptr;

    if (*display_flag !=ELEMENT_ONLY)/* display element only		*/
    {
	num_elem = 2;
					/* convert bsp-arc to IGRarc	*/
	OMmsg = om$send(
	    msg = message GRconic.GRgetarc(msg,mx_type,matrix,&arc),
	    targetid = my_id);

        if ( 1 & OMmsg & *msg)
        {
 	    if (arc.sweep_angle == 0)	/* degenerate arc		*/
    	    {
	        num_elem = 0;
	    }				/* full ellipse			*/
	    if (arc.sweep_angle != 2 * PI)
	    {				/* sweep for extension		*/
                arc.sweep_angle -= 2 * PI;
					/* get extension		*/
                if ( ! MAartobc(&msg2,&arc,&curve1))
	        {
	            *msg = MSFAIL;
	            OMmsg = OM_E_ABORT;
	        }
	    }
	    else			/* no extension for full ellipse*/
	    {
	        num_elem = 1;
	    }
	}
	else
	{
	    *msg = MSFAIL;
	    OMmsg = OM_E_ABORT;
	}
    }

    if (*msg == MSSUCC)
    {
        bc_attr.is_polydis = FALSE;
        bc_attr.is_curvedis = TRUE;

        OMmsg = om$send(mode = OM_e_wrt_object,
                        msg = message GRvg.GRgetsymb(&msg2,&symb),
                        senderid = my_id,
                        targetid = my_id);

					/* request is for object only	*/
					/* sweep angle of arc not 2*PI	*/
        if ( (*display_flag != ELEMENT_ONLY) && (num_elem != 1))
        {				/* put extension in first buffer*/
	    dp$build_dis_buffer(buffer = &ele_header[0],
		type = IGRBC,
		range = range,
		level = &me->level,
		display_att = &local_dp,
		ele_spec_att = &bc_attr,
		geometry = &curve1);

            ele_header[0].geometry.bspcurve = &curve1;
	    ele_header[0].range = &range[0];
					/* compute range of geometry	*/
            MAcubepy(&msg2,&curve1,ele_header[0].range,
		     &ele_header[0].range[3]);

	    local_dp = symb.display_attr;
	    local_dp.style = 6;
	}
					/* display extension only	*/
					/* sweep angle of arc was not 0	*/
        if ((*display_flag != EXTENSION_ONLY) && (num_elem != 0))
        {				/* place object in second buffer*/

	    dp$build_dis_buffer(buffer = &ele_header[1],
		type = IGRBC,
		range = range2,
		level = &me->level,
		display_att = &symb.display_attr,
		ele_spec_att = &bc_attr,
		geometry = curve);
					/* get range of arc		*/
            MAcubepy(&msg2,curve,ele_header[1].range,
		     &ele_header[1].range[3]);
	}
	if ((*display_flag == DISPLAY_BOTH) && (num_elem == 2))
	{
	    if (mode[ELEMENT_MODE] == mode[EXTENSION_MODE])
					/* send both elements to display*/
	    {
					/* determine where to display	*/
		OMmsg = dp$display(msg = msg,
				   mode = mode[ELEMENT_MODE],
			  	   objid = display_info->objid,
              			   osnum = display_info->osnum,
				   num_elem = num_elem,
				   buffer = ele_header);
	    }
	    else
	    {
		OMmsg = dp$display(msg = msg,
				   mode = mode[EXTENSION_MODE],
			  	   objid = display_info->objid,
              			   osnum = display_info->osnum,
				   num_elem = 1,
				   buffer = ele_header);
		if (1 & OMmsg)
		{
		    OMmsg = dp$display(msg = msg,
				   mode = mode[ELEMENT_MODE],
			  	   objid = display_info->objid,
              			   osnum = display_info->osnum,
				   num_elem = 1,
				   buffer = &ele_header[1]);
		}
      	    }
	}
	else 
	{
	    hdr_ptr = 0;		/* initialize to none found	*/

	    if (*display_flag == DISPLAY_BOTH)
					/* asked for 2 but found one	*/
	    {				
	        if (num_elem == 1)	/* element is an ellipse	*/
	        {
		    int_mode = mode[ELEMENT_MODE];
		    hdr_ptr = &ele_header[1];
	        }
	    	else			/* degenerate arc; sweep == 0	*/
	    	{
		    num_elem = 1;
		    int_mode = mode[EXTENSION_MODE];
		    hdr_ptr = &ele_header[0];
	        }
	    }
	    else if ((*display_flag == EXTENSION_ONLY) && (num_elem != 1))
	    {				/* asked for extension only	*/
					/* num_elem==1 ==> no extension	*/
		int_mode = mode[ELEMENT_MODE];
		hdr_ptr =  &ele_header[0];
		num_elem = 1;
	    }
	    else if ((*display_flag == DISPLAY_BOTH) && (num_elem != 0))
	    {				/* asked for element only	*/
					/* num_elem==0 ==> extension only*/
		int_mode = mode[ELEMENT_MODE];
		hdr_ptr = &ele_header[1];
		num_elem = 1;
	    }
	    if (hdr_ptr)		/* there is something to display*/
	    {		
		OMmsg = dp$display(msg = msg,
				   mode = int_mode,
			  	   objid = display_info->objid,
              			   osnum = display_info->osnum,
				   num_elem = num_elem,
				   buffer = hdr_ptr);
	    }	    
	}
    }
    GR_NOTIFY_LISTENERS(msg,&OMmsg,GR_DISPLAYED);

wrapup:

    return (OMmsg);

}

end implementation GRconic;
