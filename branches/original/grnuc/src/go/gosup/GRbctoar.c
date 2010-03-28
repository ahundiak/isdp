/* #######################    APOGEE COMPILED   ######################## */
#include "grimport.h"
#include "igrtypedef.h"
#include "igrdef.h"
#include "igr.h"
#include "stdio.h"
#include "mapriv.h"
#include "msdef.h"
#include "bserr.h"
#include "madef.h"
#include "bsconic.h"

extern    IGRboolean    MAbcendpts();
extern    IGRboolean    MAptwcangel();
extern    IGRboolean    MA2pt2dis();
extern    IGRboolean    MAptonar();
extern    IGRboolean    MAbcueval();

GRbctoar(msg,curve,arc)

IGRlong			*msg;
struct IGRbsp_curve	*curve;
struct IGRarc		*arc;
{
    IGRshort	mx_size = 4,
    		option;

    IGRint	type;

    IGRlong 	msg1;

    IGRpoint	point,
		f1_f,
		f2,
		prim_axis_point1,
		prim_axis_point2,
		sec_axis_point1,
		sec_axis_point2,
		start_pt,
		end_pt,
		x_axis,
		y_axis,
		z_axis;

    IGRdouble	prim_axis,
		sec_axis,
		h,u,
		tol;

    struct IGRplane	plane;


    *msg = MSSUCC;

    MAbcunweight(msg,curve);

    plane.point = y_axis;
    plane.normal = z_axis;
    tol = .00000001;
    
    MAdetplane(msg,curve->poles,&curve->num_poles,&tol,&plane);

    BScncprop(msg,z_axis,curve->poles,&curve->poles[3],&curve->poles[6],
	curve->weights,&curve->weights[1],&curve->weights[2],
	&type,arc->origin,&prim_axis,&sec_axis,f1_f,f2,
	prim_axis_point1,prim_axis_point2,
	sec_axis_point1,sec_axis_point2);

    if (*msg == BSSUCC)
    {
	if (type == BSCELLIPSE)
	{
	    arc->sec_axis = sec_axis;
	}
	else
	{
	    prim_axis_point1[0] = curve->poles[0];
	    prim_axis_point1[1] = curve->poles[1];
	    prim_axis_point1[2] = curve->poles[2];

	    arc->sec_axis = prim_axis;
	}

	arc->prim_axis = prim_axis;
	MAbcweight(msg,curve);

				/* form the matrix for the arc */
  	MAsubvc(&msg1,prim_axis_point1,arc->origin,x_axis);
	MAunitvc(&msg1,x_axis,x_axis);
	MAcrossvc(&msg1,z_axis,x_axis,y_axis);
	MAaddvc(&msg1,y_axis,arc->origin,y_axis);

	MA3protmx(msg,arc->origin,prim_axis_point1,y_axis,arc->rot_matrix);
	if ( 1 & *msg)
	{		
	    MAtrnmx(&msg1,&mx_size,arc->rot_matrix,arc->rot_matrix);
	    
	    /* determine if the object is a full circle/ellipse or
	     * an arc.
	     */
	
	    if (MAbcendpts(&msg1,curve,start_pt,end_pt))
	    {
		MAptwcangel(&msg1,start_pt,arc,&arc->start_angle);
		MAptwcangel(&msg1,end_pt,arc,&arc->sweep_angle);
	
		if (arc->sweep_angle < arc->start_angle)
		{
		    arc->sweep_angle += 2 * PI - arc->start_angle;
		}
		else if (arc->sweep_angle != 0.0)
		{
 		    arc->sweep_angle  -= arc->start_angle;
		}
	        
		u = (curve->knots[curve->order-1] +
		    curve->knots[curve->num_poles]) / 2;

		option = 0;
					/* find another point on arc	*/
		if ( MAbcueval(&msg1,curve,&option,&u,point,&h))
		{
		    if (arc->sweep_angle == 0.0)
		    {			/* see if sweep is really 2*PI  */
		        MA2pt2dis(&msg1,point,end_pt,&h);
			if (h > MAETA)	/* the points are different	*/
			{		/* therefore, sweep is 2*PI	*/
			    arc->sweep_angle = 2 * PI;
			}
		    }   
					/* is the arc correct?		*/
		    if (! MAptonar(&msg1,point,arc))
		    {			/* return other arc defined by 
					   this information		*/
			arc->sweep_angle = 2*PI - arc->sweep_angle;
					/* alter the matrix		*/
			arc->rot_matrix[1] = -arc->rot_matrix[1];
			arc->rot_matrix[2] = -arc->rot_matrix[2];
			arc->rot_matrix[5] = -arc->rot_matrix[5];
			arc->rot_matrix[6] = -arc->rot_matrix[6];
			arc->rot_matrix[9] = -arc->rot_matrix[9];
			arc->rot_matrix[10] = -arc->rot_matrix[10];
		    }
		}
		else
		{
		    *msg = MSFAIL;
		}
	    }		
	    else
	    {
		*msg = MSFAIL;
	    }
	}
	else
	{
	    *msg = MSFAIL;
	}	
	
    }

    return (1 & *msg);
}
   
