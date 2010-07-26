/* #######################    APOGEE COMPILED   ######################## */
/*
Abstract:
	This method does a stretch fence contents operation on
	an object.

Arguments
	GRstretch(IGRlong *msg; struct GRmd_env *md_env;
	IGRshort *type_prism; IGRchar *prism;
	IGRmatrix xform_matrix; GRobjid *objid);

	IGRlong *msg; 			return code
	struct GRmd_env *md_env;	environment information
	IGRshort *type_prism; 		type of prism
					    GRCURVE_PRISM
					    GRRIGHT_PRISM
	IGRchar *prism;			prism
	IGRmatrix xform_matrix; 	transformation matrix
	GRobjid *objid			object id after transformation

Return Values
	MSSUCC - successful completion
	GRDEFAULT_USED - object cannot be stretched, object was
		transformed if it is inside
	MSFAIL - failure of routine
*/

class implementation GRinfline;

#include "grimport.h"
#include "msdef.h"
#include "madef.h"
#include "godef.h"
#include "gocmacros.h"
#include "bserr.h"

extern    IGRboolean    MArptsxform();
extern    IGRboolean    GRabsg_del_all();
extern    void		BSpol_infnc();
extern    void		BSpolincfnc();

method GRstretch(IGRlong *msg; struct GRmd_env *md_env;
	IGRshort *type_prism; IGRchar *prism;
	IGRmatrix xform_matrix; GRobjid *objid)
{
    IGRchar	*absgptr;

    IGRshort	mx_type;
    IGRint	indicator[500];

    IGRboolean 	status;	

    IGRlong    	msg1,OMmsg;
    IGRlong    	i,j,num;

    IGRdouble	points[12],
		pt1[3], pt2[3],
		*pole_ptr;

    struct IGRbsp_curve *curve;
    struct GRpost_info info;
    struct IGRline org_line,ext_line;

    *msg = MSSUCC;			/* initialize to success	*/
    OMmsg = OM_S_SUCCESS;
    *objid = my_id;

    GRgetabsg(&msg1,&md_env->md_env.matrix_type,
    	md_env->md_env.matrix,&absgptr,i);
	
    if (! (1 & msg1))		/* an error occurred		*/
    {
	*msg = MSFAIL;
	OMmsg = OM_E_ABORT;
	goto wrapup;
    }
					/* geometry is a curve		*/
    curve = (struct IGRbsp_curve *) absgptr;

    /* Call Math routine to determine which poles to transform
     */

    pole_ptr = curve->poles;
    if (curve->num_poles > 2)
    {
        curve->poles += 3;
        curve->num_poles = 2;
    }

    if ( *type_prism == GRCURVE_PRISM)
    {
        BSpolincfnc(curve,prism,indicator,&msg1);
    }
    else
    {
        BSpol_infnc(curve,prism,indicator,&msg1);
    }

    if ( msg1 != BSSUCC)
    {
	*msg = MSFAIL;
	OMmsg = OM_E_ABORT;
	goto wrapup;
    }

    num = 0;

    for (i=0; i<curve->num_poles; )
    {
	if (indicator[i] == 1 )
	{
	    num = 1;

	    for (j=i+1; j<curve->num_poles; ++j)
	    {
		if (indicator[j] == 1)
		{
		    ++num;
		}    
	    }

	    status = MAptsxform(&msg1,&num,xform_matrix,
		&curve->poles[i*3],&curve->poles[i*3]);

  	    i += num;
	}
	else
	{
	    ++i;
	}
    }

    if (num != 0)
    {
	for (i = 0; i < 6; ++i)
	{
	    points[3+i] = curve->poles[i];
	}

	org_line.point1 = &points[3];
	org_line.point2 = &points[6];

	ext_line.point1 = points;
	ext_line.point2 = &points[9];

	pt1[0] = pt1[1] = pt1[2] = GRDGNLIMITS_MIN_D;
	pt2[0] = pt2[1] = pt2[2] = GRDGNLIMITS_MAX_D;

	MAlncbclip(&msg1,&org_line,pt1,pt2,&ext_line);

	curve->poles = points;
	curve->num_poles = 4;
   	
				/* object is not being constructed	*/
        info.construct_flag = FALSE;
				/* post transformed geometry		*/
        OMmsg = om$send(
		mode = OM_e_wrt_object,
                msg = message GRvg.GRpostabsg
		    (msg,md_env,&info,absgptr,objid),
                targetid = my_id);

        GR_NOTIFY_LISTENERS(msg,&OMmsg,GR_GEOM_XFORMED);
    }
    else
    {
	MAtypemx(msg,xform_matrix,&mx_type);

	om$send(
	    msg = message GRgraphics.GRxform
		(msg,md_env,&mx_type,xform_matrix,objid),
	    targetid = my_id);
    }

wrapup:

    GRabsg_del_all();
    return (OMmsg);

}
end implementation GRinfline;
