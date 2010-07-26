class implementation IGEgragad;

#include "grimport.h"
#include "dpdef.h"

/* prototype files */
%safe
#include "dpviewind.h"

#include "maidmx.h"
#include "maptsxfor.h"
%endsafe


static 	IGRint		DPvi_flag;
static  IGRint		DPvi_type;
static  IGRdouble	DPvi_point[3];

IGRint	DPsetviewind(type,point,dp_info,old)

    IGRint			type;
    IGRdouble			*point;
    struct DP_information	*dp_info;
    struct DPviewinfo		*old;


{
   IGRint  status = TRUE;

	   DPvi_flag = TRUE;
	
	   DPvi_type = type;

	   DPvi_point[0] = point[0];
	   DPvi_point[1] = point[1];
	   DPvi_point[2] = point[2];
#ifndef IDRAW
	if (!(dp_info->gragad->flags & DPVIEW_DYNAMICS))
#endif /* IDRAW  */
	{
	   status = om$send( msg = message IGEgragad.set_view_ind(type,point,
					old),
			   	  senderid = NULL_OBJID,
			   	  targetid = dp_info->view_objid,
				  targetos = dp_info->view_osnum);
	}
	return(status);
}


IGRint DPresetviewind(dp_info,old)
   struct DP_information	*dp_info;
   struct DPviewinfo		*old;
{
   IGRint	status = TRUE;

	DPvi_flag = FALSE;
#ifndef IDRAW
	if (!(dp_info->gragad->flags & DPVIEW_DYNAMICS))
#endif
	{
	   status = om$send( msg = message IGEgragad.reset_view_ind(old),
			   	  senderid = NULL_OBJID,
			   	  targetid = dp_info->view_objid,
				  targetos = dp_info->view_osnum);
	}
	return(status);
}

method set_view_ind(IGRint type; IGRdouble *point; 
			     struct DPviewinfo *old)
{
   IGRint i;
   IGRdouble  rot_matrix[16];
   IGRlong    msg;
   IGRlong    one = 1;
   IGRint     status;
   IGRshort   rotate_flag;
   IGRdouble  tmp_point[3];
   IGRdouble  new_extents[3];

	for (i = 0; i< 16; i++)
	{
	   old->rotation[i] = ME.IGEgragad->gragad.rotation[i / 4][i % 4];
	}

	for ( i=0 ; i < 6; i++)
	{
	   old->vw_volume[i] = ME.IGEgragad->gragad.vw_volume[i];
	}

	for ( i=0 ; i < 3; i++)
	{
	   old->origin[i] = ME.IGEgragad->gragad.origin[i];
	}

	old->act_z = ME.IGEgragad->gragad.act_z;

	MAidmx(&msg,rot_matrix);

	switch (type)
	{
	   case ROTATION_IND:

		rotate_flag = REPLACE_MTX ;
		status = om$send( msg = message IGEgragad.DProtate
			  	  	(&msg,rotate_flag,point,rot_matrix,
			    		(IGRboolean) FALSE),
			   	  senderid = my_id,
			   	  targetid = my_id);
		break;

	   case SCALE_IND:

		MAptsxform(&msg, &one, (IGRdouble *)ME.IGEgragad->gragad.wld_to_view,
				      point, tmp_point);

		new_extents[0] = (ME.IGEgragad->gragad.vw_volume[3] -
				     ME.IGEgragad->gragad.vw_volume[0]) *
				     ME.IGEgragad->gragad.vvol_viewport_scale;

		new_extents[1] = (ME.IGEgragad->gragad.vw_volume[4] -
				     ME.IGEgragad->gragad.vw_volume[1]) *
				     ME.IGEgragad->gragad.vvol_viewport_scale;

		new_extents[2] = (ME.IGEgragad->gragad.vw_volume[5] -
				     ME.IGEgragad->gragad.vw_volume[2]) *
				     ME.IGEgragad->gragad.vvol_viewport_scale;

		ME.IGEgragad->gragad.vw_volume[3] = tmp_point[0] + 
				(ME.IGEgragad->gragad.vw_volume[3] - tmp_point[0]) *
			         ME.IGEgragad->gragad.vvol_viewport_scale;

		ME.IGEgragad->gragad.vw_volume[4] = tmp_point[1] + 
				(ME.IGEgragad->gragad.vw_volume[4] - tmp_point[1]) *
			         ME.IGEgragad->gragad.vvol_viewport_scale;

		ME.IGEgragad->gragad.vw_volume[5] = tmp_point[2] + 
				(ME.IGEgragad->gragad.vw_volume[5] - tmp_point[2]) *
			         ME.IGEgragad->gragad.vvol_viewport_scale;

		ME.IGEgragad->gragad.vw_volume[0] = ME.IGEgragad->gragad.vw_volume[3] -
							new_extents[0];


		ME.IGEgragad->gragad.vw_volume[1] = ME.IGEgragad->gragad.vw_volume[4] -
							new_extents[1];

		ME.IGEgragad->gragad.vw_volume[2] = ME.IGEgragad->gragad.vw_volume[5] -
							new_extents[2];

		status = om$send(	msg = message IGEgragad.DPcal(&msg),
			   	  	senderid = my_id,
			    		targetid = my_id);
		break;

	   case ROTATION_SCALE_IND:

		MAptsxform(&msg, &one, (IGRdouble *)ME.IGEgragad->gragad.wld_to_view,
				      point,tmp_point);

		new_extents[0] = (ME.IGEgragad->gragad.vw_volume[3] -
				     ME.IGEgragad->gragad.vw_volume[0]) *
				     ME.IGEgragad->gragad.vvol_viewport_scale;

		new_extents[1] = (ME.IGEgragad->gragad.vw_volume[4] -
				     ME.IGEgragad->gragad.vw_volume[1]) *
				     ME.IGEgragad->gragad.vvol_viewport_scale;

		ME.IGEgragad->gragad.vw_volume[3] = tmp_point[0] + 
				(ME.IGEgragad->gragad.vw_volume[3] - tmp_point[0]) *
			         ME.IGEgragad->gragad.vvol_viewport_scale;

		ME.IGEgragad->gragad.vw_volume[4] = tmp_point[1] + 
				(ME.IGEgragad->gragad.vw_volume[4] - tmp_point[1]) *
			         ME.IGEgragad->gragad.vvol_viewport_scale;

		ME.IGEgragad->gragad.vw_volume[0] = ME.IGEgragad->gragad.vw_volume[3] -
							new_extents[0];


		ME.IGEgragad->gragad.vw_volume[1] = ME.IGEgragad->gragad.vw_volume[4] -
							new_extents[1];

		rotate_flag = REPLACE_MTX ;
		status = om$send( msg = message IGEgragad.DProtate
			  	  	(&msg,rotate_flag,point,rot_matrix,
			    		(IGRboolean) FALSE),
			   	  senderid = my_id,
			   	  targetid = my_id);

		break;

	   default:
		break;

	} /* end switch (type)  */

	return(1);
}

method reset_view_ind(struct DPviewinfo *old)
{
   IGRint  i;
   IGRlong msg;
   IGRint  status;

	for (i = 0; i< 16; i++)
	{
	   ME.IGEgragad->gragad.rotation[i / 4][i % 4] = old->rotation[i];
	}

	for ( i=0 ; i < 6; i++)
	{
	   ME.IGEgragad->gragad.vw_volume[i] = old->vw_volume[i];
	}

	for ( i=0 ; i < 3; i++)
	{
	   ME.IGEgragad->gragad.origin[i] = old->origin[i];
	}

	ME.IGEgragad->gragad.act_z = old->act_z;

	status = om$send( msg = message IGEgragad.DPcal(&msg),
			   senderid = my_id,
			   targetid = my_id);

/*	BEGIN 90N1163
*/
	status = om$send( msg = message IGEgragad.DProtate
			  	(&msg,REPLACE_MTX,old->origin,old->rotation,
			    	(IGRboolean) FALSE),
			   	  senderid = my_id,
			   	  targetid = my_id); 
/*	END 90N1163 
*/

	return(1);

}

void	DPinq_vi_info(flag,type,point)
  IGRint	*flag;
  IGRint	*type;
  IGRdouble	*point;
{
	*flag = DPvi_flag;
	*type = DPvi_type;

	point[0] = DPvi_point[0];
	point[1] = DPvi_point[1];
	point[2] = DPvi_point[2];
}

end implementation IGEgragad;

