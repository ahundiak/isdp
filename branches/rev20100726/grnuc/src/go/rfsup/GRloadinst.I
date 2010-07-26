/* #######################    APOGEE COMPILED   ######################## */

class implementation GRvg;

#include "grimport.h"
#include "msdef.h"
#include "refdef.h"
#include "OMmacros.h"

GRloadinstance(msg,scale,master_osnum,ref_osnum,filename,
	input_lbsys,view_id,ref_objid,ref_to_master_matrix,
	master_to_ref_matrix,vw_matrix,vw_volume,levels,
	vw_origin,properties)

IGRlong		*msg;
IGRchar		*scale;
GRspacenum	*master_osnum;
GRspacenum	*ref_osnum;
IGRchar		*filename;
struct GRid	*view_id;
struct IGRlbsys	*input_lbsys;
GRobjid		*ref_objid;
IGRmatrix	ref_to_master_matrix;
IGRmatrix	master_to_ref_matrix;
IGRmatrix	vw_matrix;
IGRdouble	*vw_volume;
IGRint		*levels;
IGRdouble	*vw_origin;
IGRint		*properties;

{
    IGRshort	mx_size;

    IGRboolean 	is_skew;

    IGRint	OMmsg,
		i;

    IGRlong	msg1;

    IGRmatrix	scale_matrix;

    struct IGRlbsys *lbsys_ptr,lbsys;

    extern IGRboolean MAinvmx();

    OMmsg = OM_S_SUCCESS;
    *msg = MSSUCC;
 
    if (scale)
    {
	OMmsg = GRmodel_scale(msg,master_osnum,ref_osnum,scale,scale_matrix);
	if (! (1 & *msg & OMmsg))
	{
	   *msg = MSFAIL;
	   OMmsg = OM_E_ABORT;
	   goto wrapup;
 	}

	mx_size = 4;
	MAmulmx(msg,&mx_size,&mx_size,&mx_size,
		input_lbsys->matrix,scale_matrix,lbsys.matrix);

        for (i = 0; i<3; ++i)
	{
	    lbsys.diag_pt1[i]=input_lbsys->diag_pt1[i];
	    lbsys.diag_pt2[i]=input_lbsys->diag_pt2[i];
	}
	lbsys_ptr = &lbsys;
    }
    else
    {
	lbsys_ptr = input_lbsys;
    }
					/* saved view requested		*/
    if ( (!(IF_NULL_OBJID(view_id->objid))) && filename)
    {
					/* put view info into object	*/
	GRputsavevw(msg,lbsys_ptr,view_id,ref_objid,ref_osnum,
		    ref_to_master_matrix,master_to_ref_matrix,
	   	    levels,vw_matrix,vw_origin,vw_volume,
			&is_skew);

        if (1 & *msg)
        {
  	    *properties |=  GRRF_SAVED_VIEW_USED;
	    if (is_skew)
	    {
		*properties |=  GRIS_SKEW;
	    }
        }
	else
	{
	    OMmsg = OM_E_ABORT;
	}
    }					
    else 
    {
	mx_size = 4;
					/* form transformation matrix	*/

	if (MAinvmx(&msg1,&mx_size,lbsys_ptr->matrix,master_to_ref_matrix))
	{
	    for (i=0; i<16; ++i)
	    {
		ref_to_master_matrix[i] = lbsys_ptr->matrix[i];
	    }
					/* turn on all levels		*/
	    for (i=0; i<32;++i)
	    {
               levels[i] = 0xffffffff;

	    }

	    MAidmx(&msg1,vw_matrix);
	    for(i=0; i<3; ++i)
	    {
		vw_volume[i] = input_lbsys->diag_pt1[i];
		vw_volume[i+3] = input_lbsys->diag_pt2[i];
		vw_origin[i] = 0.0;
	    }	    		
	}
	else
	{
	   *msg = OM_E_ABORT;
	}
    }		

wrapup:

    return (OMmsg);
}
end implementation GRvg;
