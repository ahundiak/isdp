/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME:   GRlinear
     METHOD NAME:   GRlocaldp

     Abstract: 	    This method displays a local area defined on a 
		    linear geometry object.

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
				   2 : display segment only
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
		MAutoparms
		MApytobc
		MApyextents
		MAlncbclip
     Methods:
		GRgetsymb
-----
%RL%

     RELATIONS REFERENCED:
	     none.
-----
%NB%

     NOTES:	None.

-----
%CH%

     CHANGE HISTORY:
	
	REJ	04/09/86 : Creation date.
-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
	TBD.
----*/
/*EH*/

class implementation GRlinear;

#include "grimport.h"
#include  "msdef.h"
#include  "godef.h"
#include  "igrdef.h"
#include  "gocmacros.h"
#include  "dpdef.h"
#include  "dpmacros.h"

extern    IGRboolean    MApytobc();
extern    IGRboolean    MApyextents();
extern    IGRboolean    MAutoparms();
extern    IGRboolean    MAlncbclip();

method  GRlocaldp(IGRlong *msg; IGRshort *mx_type; IGRmatrix
     		  matrix; struct GRparms *parm; enum GRdpmode *mode; 
		  struct GRid *display_info; IGRshort *display_location;
		  IGRshort *display_flag )
{
    IGRchar    *ptr;			/* pointer			*/

    IGRlong    OMreturn;		/* OM return value		*/
    IGRlong    i;			/* loop index			*/
    IGRlong    msg2;			/* local return message		*/

    GRrange    range;			/* range of element		*/

    struct     DPele_header 		/* element headers for dp	*/
	       ele_header[2],*hdr_ptr;
    struct     IGRbsp_curve *curve;	/* structure for B-spline curve */
    struct     IGRbsp_curve curve1,	/* curves to display		*/
	       curve2;
    struct     IGResbc bc_attr;		/* element spec. attributes	*/
    struct     IGRpolyline   py;	/* polyline structure		*/
    struct     IGRline_seg lineseg;
    struct     IGRdisplay  local_dp;	/* display for extensions	*/
    struct     IGRline    line;
    struct     GRsymbology  symb;


    IGRdouble  t;			/* t parameter on segment	*/
    IGRlong    segnum;			/* segment number		*/
    IGRpoint   diag1,diag2;		/* cube diagonal points		*/
    IGRlong    num_elem = 2;		/* number to display		*/
    IGRdouble  poles1[12],		/* storage for curves		*/
	       poles2[12],knots1[6],
	       knots2[6],bdrys1[4],bdrys2[2];	


    *msg = MSSUCC;
    OMreturn = OM_S_SUCCESS;


    curve1.poles = poles1;
    curve1.knots = knots1;
    curve1.bdrys = bdrys1;
    curve2.poles = poles2;
    curve2.knots = knots2;
    curve2.bdrys = bdrys2;
    curve2.weights = NULL;

			    	/* generate the abstract geometry	*/
    GRgetabsg(&msg2,mx_type,matrix,&ptr,i);

    if (! (1 & msg2))
    {
 	*msg = MSFAIL;
	OMreturn = OM_E_ABORT;
	goto wrapup;
    }
    curve = (struct IGRbsp_curve *) ptr;

    if (*display_flag != 2)		/* display_flag ==2 means 
				           display object only		*/
    {	
	*msg = MSFAIL;
					/* find segment to extend	*/
        if (MAutoparms(&msg2,curve,&parm->u,&segnum,&t))
	{
	    segnum = (segnum - 1) * 3;	/* adjust segnum to use as index*/
            for (i = 0; i < 6; i++)
            {
	        poles1[3+i] = curve->poles[segnum + i];
            }
					/* lines for clip		*/
            line.point1 = &poles1[3];
            line.point2 = &poles1[6];
            lineseg.beg_point = &poles1[0];
            lineseg.end_point = &poles1[9];
					/* cube defined by design limits*/
    	    diag1[0] = diag1[1] = diag1[2] = GRDGNLIMITS_MIN_D;
    	    diag2[0] = diag2[1] = diag2[2] = GRDGNLIMITS_MAX_D;
					/* extend line to infinity	*/
            if (MAlncbclip(&msg2,&line,diag1,diag2,&lineseg))
	    {
           	py.num_points = 4;
        	py.points = poles1;

        	if (MApyextents(&msg2,&py,range,&range[3]))
		{
            	    if ( MApytobc(&msg2,&py,&curve1))
	    	    {
        		if (MAbccopy(&msg2,&curve1,&curve2))
			{
       		    	    curve1.num_boundaries = 2;
    		            curve2.num_boundaries = 1;

    		    	    for (i = 0; i < 4; i++)
    		    	    {
      				bdrys1[i] = knots1[1+i];
    		    	    }

    		   	    bdrys2[0] = knots2[2];
    		            bdrys2[1] = knots2[3];
					/* assign pointer for object	*/
		            curve = &curve1;
			    *msg = MSSUCC;
			}
		    }
		}
	    }
    	}
    }
    else				/* display object only		*/
    {
	*msg = MSFAIL;
					/* find segment to extend	*/
        if (MAutoparms(&msg2,curve,&parm->u,&segnum,&t))
	{
	    py.num_points = 4;
	    py.points = &curve->poles[(segnum-1)*3];

	    if (MApyextents(&msg2,&py,range,&range[3]))
	    {
	        if (MApytobc(&msg2,&py,&curve1))
	        {
		    *msg = MSSUCC;
		    curve = &curve1;
	        }
	    }
	}
    }

    if (*msg == MSSUCC)
    {
        OMreturn = om$send(mode = OM_e_wrt_object,
                           msg = message GRvg.GRgetsymb(&msg2,&symb),
                           senderid = my_id,
                           targetid = my_id);


	if (*display_flag !=2)		/* request is for object only	*/
	{				/* load extension into buffer	*/

	    dp$build_dis_buffer(buffer = &ele_header[0],
		type = IGRBC,
		range = range,
		level = &me->level,
		display_att = &local_dp,
		ele_spec_att = &bc_attr,
		geometry = &curve2);

	    local_dp = symb.display_attr;
	    local_dp.style = 6;
	}
	if (*display_flag !=  1)	/* request is for extension only*/
	{				/* load object into buffer	*/

	    dp$build_dis_buffer(buffer = &ele_header[1],
		type = IGRBC,
		range = range,
		level = &me->level,
		display_att = &symb.display_attr,
		ele_spec_att = &bc_attr,
		geometry = curve);
	}

        bc_attr.is_polydis = FALSE;
        bc_attr.is_curvedis = TRUE;
	if(*display_flag == 0)		/* object and extension requested*/
	{
	    if (mode[0] == mode[1])
	    {
	        OMreturn = dp$display( 
				msg = msg,
				mode = mode[0],
				objid = display_info->objid,
         			osnum = display_info->osnum,
				buffer = ele_header,
				num_elem = num_elem);

            }
	    else			/* different modes; display	*/
	    {        			/* must be called twice		*/
		num_elem = 1;

	        OMreturn = dp$display( 
				msg = msg,
				mode = mode[1],
				objid = display_info->objid,
         			osnum = display_info->osnum,
				buffer = ele_header);

		if (1 & OMreturn)
		{
	            OMreturn = dp$display( 
				msg = msg,
				mode = mode[0],
				objid = display_info->objid,
         			osnum = display_info->osnum,
				buffer = &ele_header[1]);
		}
	    }
	}
	else				/* display requested portion	*/
	{
	    num_elem = 1;		/* number of elements to display*/

	    if (*display_flag == 1)	/* display extension only	*/
	    {
		hdr_ptr = &ele_header[0];
	    }
	    else			/* display element only		*/
	    {
		hdr_ptr = &ele_header[1];
	    }

            OMreturn = dp$display( 
				msg = msg,
				mode = mode[0],
				objid = display_info->objid,
         			osnum = display_info->osnum,
				buffer = hdr_ptr);

	}
    }

	GR_NOTIFY_LISTENERS(msg,&OMreturn,GR_DISPLAYED);

wrapup:

    return (OMreturn);

}

end implementation GRlinear;
