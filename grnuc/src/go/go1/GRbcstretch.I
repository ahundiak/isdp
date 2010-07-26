/* #######################    APOGEE COMPILED   ######################## */
/*
Abstract:
	This method does a stretch fence contents operation on
	an object.  The object is assumed to be either overlapping
	or inside the prism.

Arguments
	GRstretch(msg,md_env,type_prism,prism,xform_matrix,
		objid)

	IGRlong *msg; 			return code
	struct GRmd_env *md_env;	environment information
	IGRshort *type_prism; 		type of prism
					    GRCURVE_PRISM
					    GRRIGHT_PRISM
					    (defined in godef.h)
	IGRchar *prism;			prism
	IGRmatrix xform_matrix; 	transformation matrix
	GRobjid *objid			object id after transformation

Return Values
	MSSUCC - successful completion
	GRDEFAULT_USED - object cannot be stretched, object was
		transformed if it is inside
	MSFAIL - failure of routine
*/

class implementation GRbspline;

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

    IGRboolean 	status;	

    IGRshort	mx_type;

    IGRlong    	msg1,OMmsg;
    IGRlong    	i,j,num;

    IGRint	indicator_array[500],
		*ind;

    struct IGRbsp_curve *curve;
    struct GRpost_info info;

    *msg = MSSUCC;			/* initialize to success	*/
    OMmsg = OM_S_SUCCESS;
    *objid = my_id;
    ind = 0;

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

    if ( curve->num_poles > 500)
    {
	ind = (IGRint *)om$malloc(size=(curve->num_poles * sizeof(IGRint)));
	if ( ! ind)
	{
	    *msg = MSFAIL;
	    OMmsg = OM_E_ABORT;
	    goto wrapup;
	}
    }
    else
    {
	ind = indicator_array;
    }

    if ( *type_prism == GRCURVE_PRISM)
    {
        BSpolincfnc(curve,prism,ind,&msg1);
    }
    else
    {
        BSpol_infnc(curve,prism,ind,&msg1);
    }

    if ( msg1 != BSSUCC)
    {
	*msg = MSFAIL;
	OMmsg = OM_E_ABORT;
	goto wrapup;
    }

    num = 0;

    for (i=0; i<curve->num_poles;)
    {
	if (ind[i] == 1 )
	{
	    num = 1;

	    for (j=i+1; j<curve->num_poles && ind[j] ; ++j)
	    {
		++num;
	    }

/* BLOCK START
   This block modified for TR90N2594 - Ashok - 8/oct/1990 */
/* next 3 lines commented out - "weights" argument not passed correctly
	    status = MArptsxform(&msg1,&num,&curve->rational,
		curve->weights,xform_matrix,
		&curve->poles[i*3],&curve->poles[i*3]);
*/
	    status = MArptsxform(&msg1,&num,&curve->rational,
		(curve->rational ? &curve->weights[i] : curve->weights),
	        xform_matrix,
		&curve->poles[i*3],&curve->poles[i*3]);
/* BLOCK END */

  	    i +=  num;
	}
	else
	{
	    i++;
	}	
    }
    if ( num != 0)		/* at least 1 pole was changed		*/
    {
				/* object is not being constructed	*/
        info.construct_flag = FALSE;
				/* post transformed geometry		*/
        OMmsg = om$send(
		mode = OM_e_wrt_object,
                msg = message GRvg.GRpostabsg
		    (msg,md_env,&info,absgptr,objid),
                senderid = my_id,
                targetid = my_id);
 
	GR_NOTIFY_LISTENERS(msg,&OMmsg,GR_GEOM_XFORMED);
    }
    else
    {
	/* All of the poles were outside the prism.  Since the object
	 * overlaps the prism, we will transform it.
	 */

	MAtypemx(msg,xform_matrix,&mx_type);

	OMmsg = om$send(msg = message GRgraphics.GRxform
		(msg,md_env,&mx_type,xform_matrix,objid),
	    targetid = my_id);
    }

wrapup:

    if (( curve->num_poles > 500) && ind)
    {
	om$dealloc(ptr = ind);
    }

    if ( ! (1 & OMmsg))
    {
	GRabsg_del_all();
       
    }

    return (OMmsg);
}
end implementation GRbspline;
