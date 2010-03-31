/* ###################   APOGEE COMPILED   ################## */
/* 
DESCRIPTION
===========
		
 	This function tests planarity of a group of surfaces.
        The group could be made of:  Surface ids,  Surface geometries, 
        or Composite surface id.

        Refer to struct EMStest_plan_group (It is similar to EMSdataselect
	as in emsdattyp.h).

NOTES
=====

ARGUMENTS
=========
	
    VARIABLE			MODE	DESCRIPTION
    --------                    ----    -----------
    EMmsg			Output	EMS_S_Success If all is well.
				        EMS_E_OMerror If OM error.
					EMS_E_SurfaceError If could not
					get geomprops or 4poles of the
					surfaces.

    data	                Input   Struct which describes and has 
					input.

    md_env			Input	Pointer to module info.

    is_planar		        Output	Boolean describing the result of
				        the planarity check.

RETURN VALUE
============

   OM_stat			OM_S_SUCCESS	If all is well.
				OM_E_ABORT	If any error ( OM or EMS ).

HISTORY
=======
	
	SAM		20-Oct-87	Creation.
        AMD             30-Jun-92       Specified the targetos for all
                                        message sends.
        AMD             11-Jan-93       Fixed a bug introduces during ANSI
                                        conversion.
        Sudha           09-jul-93       Modified for BSprototypes anisfication

*/

class implementation EMSsurface;

#include "EMS.h"
#include <stdio.h>
#include "OMmacros.h"
#include "bs.h"
#include "EMSbnddef.h"
#include "EMSopt.h"
#include "EMSprop.h"
#include "emsmacros.h"
#include "emsplndef.h"
#include "bsplanar.h"

from EMSsubbs import EMss4poles;

IGRlong EMtest_planar(EMmsg, data, md_env, is_planar)

IGRlong 		        *EMmsg; 
struct EMStest_plan_group       *data;
struct GRmd_env 		*md_env;
IGRboolean 			*is_planar;

{
 OM_S_CHANSELECT 		to_compsf_comps;
 OMuword			osnum, osnumaddr;
 struct	GRmdenv_info	        *grmdenv_info = &(md_env->md_env);
 struct     GRprops		individ_sf_props;
 OM_S_OBJID			individ_sf_id;
 IGRpoint			poles_buff[8], pt_buff[4];
 IGRint				i,ii, num_pts = 8, code, num_comps;
 IGRlong 			OM_stat, mthd_stat;
 BSrc	                        rc;
 IGRvector                      nvec;


 *EMmsg = EMS_S_Success;
 OM_stat = OM_S_SUCCESS;

 *is_planar = TRUE;
 osnum = md_env->md_id.osnum;

 if(data->option == EMComposite_Id)
 {
  OM_stat = EMmake_chanselect (GRcmpowner_to_components, &to_compsf_comps);
  EMerr_hndlr(!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);
 
  OM_stat = om$get_channel_count(p_chanselect = &to_compsf_comps,
			         objid = *(data->data.comp_id),
                                 osnum = osnum,
                                 count = (OMuint *)&num_comps);
  EMerr_hndlr(!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);
 }
 else 
 num_comps = data->num_sfs;

 
 for( i = 0; i <= num_comps -1; i++)
 {
  if(data->option == EMComposite_Id)
  {
	OM_stat = om$get_objid_at_index(objid = *(data->data.comp_id),
                                        osnum = osnum,
                                        p_chanselect = &to_compsf_comps,
                                        index = i,
                                        objidaddr = &individ_sf_id,
                                        osnumaddr = &osnumaddr);
    EMerr_hndlr(!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);
  }
  else
  if(data->option == EMIndividual_Ids) individ_sf_id = *(data->data.sf_ids[i]);

  if(!(data->option == EMIndividual_Geoms))
  {
	OM_stat = om$send(msg = message GRvg.GRgeomprops(
              			&mthd_stat,
				&(grmdenv_info->matrix_type),
				grmdenv_info->matrix,
				&individ_sf_props),
			  senderid = NULL_OBJID,
                          targetos = osnum,
                          targetid = individ_sf_id);
    EMerr_hndlr(!(1&OM_stat&mthd_stat), *EMmsg, EMS_E_SurfaceError, wrapup);
  }
  else individ_sf_props.planar = data->data.sf_geoms[i][0].planar;
  
    					
    if(!individ_sf_props.planar)
    {
		*is_planar = FALSE;
		break;
	}
	
}

if(*is_planar)
{
 if(! (data->option == EMIndividual_Geoms) )
 {
  OM_stat = om$send(msg = message EMSsubbs.EMss4poles(
		 				&mthd_stat,
						poles_buff,
						grmdenv_info),
        			senderid = NULL_OBJID,
                                targetos = osnum,
			        targetid = individ_sf_id);
  EMerr_hndlr(!(1&OM_stat&mthd_stat), *EMmsg, EMS_E_SurfaceError, wrapup);
 }
 else
 {
  OM_stat = EMgetsf4pols(&(data->data.sf_geoms[num_comps -1][0]),
						 poles_buff[0]);
  EMerr_hndlr(!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);
 }

for(i = 0; i<= num_comps - 2 ; i++)
{
 if(data->option == EMComposite_Id)
 {
    OM_stat = om$get_objid_at_index(objid = *(data->data.comp_id),
                                    osnum = osnum,
                                    p_chanselect = &to_compsf_comps,
                                    index = i,
                                    objidaddr = &individ_sf_id,
                                    osnumaddr = &osnumaddr);
    EMerr_hndlr(!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);
 }
 else
  if(data->option==EMIndividual_Ids)individ_sf_id=*(data->data.sf_ids[i]);


 if(!(data->option == EMIndividual_Geoms))
 {
	OM_stat = om$send(msg = message EMSsubbs.EMss4poles(
						&mthd_stat,
						pt_buff,
						grmdenv_info),
                                      senderid = NULL_OBJID,
                                      targetos = osnum,
				      targetid = individ_sf_id);
    EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_SurfaceError, wrapup);

   for (ii=0; ii<4; ii++)
   {
    poles_buff[4+ii][0] = pt_buff[ii][0];
    poles_buff[4+ii][1] = pt_buff[ii][1];
    poles_buff[4+ii][2] = pt_buff[ii][2];
   }

 }
 else
 {
    OM_stat = EMgetsf4pols(&(data->data.sf_geoms[i][0]), poles_buff[4]);
    EMerr_hndlr(!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);
 }
    
    BSplanar(&rc, &num_pts, (IGRdouble *)poles_buff, &code, nvec);
    if(BSERROR(rc))
	{
		#if DEBUG
		fprintf(stderr, "BRplanar rc : 2plane/8pt planarity check\n");
		#endif
		om$report_error(sts = rc);
		goto wrapup;
	}
    
 	if(code == 4)
	{
		*is_planar = FALSE;
		break;
	}
  }
}

			
wrapup:
 EMWRAPUP(*EMmsg, OM_stat, "In EMsftstplan.I");
 return(OM_stat);
}

end implementation EMSsurface;
