/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME:
     METHOD NAME:

     Abstract: 

-----
%SC%    

    VALUE =

-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   ------------------------------------

-----
%EX%
     ON EXIT:

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   -----------------------------------
     message      IGRlong        completion code
                                    - MSSUCC if successful
                                    - MSFAIL (severe) if failure

     VALUE () =

-----
%MD%

     MODULES AND METHODS INVOKED:
     Modules:

     Methods:
-----
%RL%

     RELATIONS REFERENCED:
-----
%NB%

     NOTES:
-----
%CH%

     CHANGE HISTORY:
        
        MAS     05/01/86 : Design date.
-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------

----*/
/*EH*/

class implementation IGEgragad;

#include <stdio.h>
#include <string.h>

#include "grimport.h"
#include "OMmacros.h"
#include "exmacros.h"
#include "igr.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "dpsavevw.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "bsparameters.h"
#include "bstypes.h"

/* prototype files */
%safe
#include "DPsetinq.h"
#include "DPaddvwname.h"
#include "DPzdepfnc.h"
#include "DPwldvw.h"
#include "DPgetggid.h"
#include "dpgetrng.h"
#include "dpsetrng.h"
#include "dpalignper.h"

#include "maidmx.h"
#include "madabs.h"
#include "mainvmx.h"
#include "mamulmx.h"
#include "malnplise.h"
#include "masincos.h"
#include "maptsxfor.h"
#include "bsxtractpar.h"
%endsafe

from IGEwindow import display_name;

int DPsi_gg_name ( IGRlong          *msg,
                   IGRchar          inq0_set1,
                   IGRlong          *which_error,
                   struct var_list  *list,
                   GRspacenum       osnum,
                   IGRchar          *gragad_name,
                   IGRchar          calc_info,
                   IGRchar          update )

{

IGRlong status;
IGRint number_ids;
IGRshort i;
struct GRid gg_ids[EX_MAX_WINDOW];
struct GRid mod_GRid, *p_modid;
GRobjid mod_objid;

    *msg = MSSUCC;	
    status = OM_S_SUCCESS;

    number_ids=0;

    /* 
     * KLUDGE: The comparison of osnum to 0xFFFFFFFF is done to get
     *         around an apogee compiler bug. It should be taken out
     *         as soon as this code is compiled with Apogee Version 32
     *         or later. It shouldn't cause a problem even if it isn't 
     *         taken out .... don't PANIC! Note: This is done in two
     *         places in this file. Jay Wallingford x7725
     */
    if ((osnum == 0xFFFFFFFF) || (osnum == 0xFFFF))
    {
	p_modid = NULL;
    }
    else
    {
	mod_GRid.osnum = osnum;
	ex$get_modid ( mod_osnum = mod_GRid.osnum, mod_id = &mod_objid);
	mod_GRid.objid = mod_objid;
        p_modid = &mod_GRid;
    }
    dp$get_gragad_id(msg = msg, mod_GRid = p_modid, 
			name = gragad_name,array_size = EX_MAX_WINDOW,
			numberofids = &number_ids,
			found_GRids = gg_ids);
    if (number_ids == 0 )
    {
	*msg = DPNOOBJECTS;
    }
    else
    {
    	if (inq0_set1)
    	{
	    for(i=0; i < number_ids; i++)
	    {
	       status = DPsetinqgragad ( msg, inq0_set1, which_error, list,
	       gg_ids[i].osnum, gg_ids[i].objid, calc_info,update);
               if ( !(status & 1))
               {
		   break;
	       }
	    }
    	} /* CLOSE for set */
    	else
    	{
    	    if (number_ids == 1)
    	    {
            	status = om$send(mode = OM_e_wrt_object,
                               msg = message IGEgragad.DPinquire ( msg, 
                                     which_error,  
                                     list ),
                               senderid = NULL_OBJID,
                               targetid = gg_ids[0].objid,
                               targetos = gg_ids[0].osnum);
            } /* close for if number = 1 */
            else
     	    {
		/* *msg = AMBIGUOUSNAME */
	    	*msg = MSFAIL;
    	    }
    	} /* close for else inquire */
    } /* close for else -- number > 0 */
    return (status);
}
        
int DPsetinqgragad ( IGRlong *msg,
                     IGRchar inq0_set1,
                     IGRlong *which_error,
                     struct  var_list *list,
                     GRspacenum osnum,
                     GRobjid gragad_objid,
                     IGRchar calc_info,
                     IGRchar update )

{

        IGRlong status;
	GRobjid mod_objid;
	GRspacenum mod_osnum;        
	struct var_list funvar_list[2];
	IGRlong other_err;
	IGRint inq_flags;
	IGRlong num_bytes;	
    	IGRboolean flag = FALSE;

        *msg = MSSUCC;

        /* 
         * KLUDGE: The comparison of osnum to 0xFFFFFFFF is done to get
         *         around an apogee compiler bug. It should be taken out
         *         as soon as this code is compiled with Apogee Version 32
         *         or later. It shouldn't cause a problem even if it isn't 
         *         taken out .... don't PANIC! Note: This is done in two
         *         places in this file. Jay Wallingford x7725
         */ 
        if ((osnum == 0xFFFFFFFF) || (osnum == 0xFFFF))
	{ 
	    ex$get_cur_mod( id = &mod_objid, osnum = &mod_osnum);
	} 
	else
	{
	    mod_osnum = osnum;
	}
        if ( !inq0_set1 )
         {
          status = om$send(mode = OM_e_wrt_object,
                               msg = message IGEgragad.DPinquire ( msg, 
                                     which_error,  
                                     list ),
                               senderid = NULL_OBJID,
                               targetid = gragad_objid,
                               targetos = mod_osnum);
            if ( !(status & 1))
                 {
		    goto fini;
                 }
         }
        else 
         {
            status = om$send(mode = OM_e_wrt_object,
                             msg = message IGEgragad.DPset ( msg, which_error,
                             list ),
                             senderid = NULL_OBJID,
                             targetid = gragad_objid,
                             targetos = mod_osnum);

            if ( !(status & 1))
                 {
#ifdef DEBUG
		    printf("DPset failed: msg = %d, status = %d\n", *msg, status);
#endif
		    goto fini;
                 }
	    if (calc_info)
	    {
            	status = om$send(mode = OM_e_wrt_object,
                             msg = message IGEgragad.DPcal ( msg),
                             senderid = NULL_OBJID,
                             targetid = gragad_objid,
                             targetos = mod_osnum);

            	if ( !(status & 1))
                 {
#ifdef DEBUG
		    printf("DPcal failed: msg = %d, status = %d\n", *msg, status);
#endif
		    goto fini;
                 }
	    }
	    if(update)
	    {

	    	funvar_list[0].var = GRAGAD_FLAGS;
		funvar_list[0].var_ptr = (char *)&inq_flags;
		funvar_list[0].num_bytes = sizeof(IGRint);
	    	funvar_list[0].bytes_returned = &num_bytes;

		funvar_list[1].var = END_PARAM;

	          status = om$send(mode = OM_e_wrt_object,
                               msg = message IGEgragad.DPinquire ( msg, 
                                     &other_err,  
                                     funvar_list ),
                               senderid = NULL_OBJID,
                               targetid = gragad_objid,
                               targetos = mod_osnum);

            	if ( !(status & 1))
                 {
#ifdef DEBUG
		    printf("DPiquire failed at update: msg = %d, status = %d\n", *msg, status);
#endif
		    goto fini;
                 }


		if (!(inq_flags & DP_DELAY))
		{
            		status = om$send(mode = OM_e_wrt_object,
                             msg = message IGEgragad.DPupdate (msg,NULL,&flag),
                             senderid = NULL_OBJID,
                             targetid = gragad_objid,
                             targetos = mod_osnum);

	    	}

            	if ( !(status & 1))
                 {
#ifdef DEBUG
		    printf("DPupdate failed at inq_flags: msg = %d, status = %d\n", *msg, status);
#endif
		    goto fini;
                 }

            } /* close for update */
	} /* close for if set */
fini:
	;
        return (status);
  }         

int GRwnparam ( msg, set0_inq1, win_id, which_error, var_list )
        
        IGRlong *msg;           /* return message status                */

        IGRshort *set0_inq1;    /* indicates if you wish to set a value in
                                the view's instance data or if you wish
                                to inquire a value. (set = 0 inquire = 1) */

        struct GRid *win_id;    /* window object id                     */

        IGRlong *which_error;   /* if an error occurs with one of the 
                                variables which_error will point to the
                                one with the error                      */

        IGRint var_list;        /* list of variables to get             */

{

        IGRlong status = FALSE;
        
        *msg = MSSUCC;
        
        if ( *set0_inq1 )
         {
          status = om$send(mode = OM_e_wrt_object,
                               msg = message IGEgragad.DPinquire ( msg, 
                                     which_error,  
                                     (struct var_list *) &var_list ),
                               senderid = NULL_OBJID,
                               targetid = win_id->objid,
                               targetos = win_id->osnum);

                if ( !(status & 1))
                 {
                    *msg = MSFAIL;
                 }
         }
        else 
         {
            status = om$send(mode = OM_e_wrt_object,
                             msg = message IGEgragad.DPset ( msg, which_error,   
                                    (struct var_list *) &var_list ),
                             senderid = NULL_OBJID,
                             targetid = win_id->objid,
                             targetos = win_id->osnum);

            if ( !(status & 1))

                 {
                    *msg = MSFAIL;
                 }
         }
	;

        return (status);
  }         

method DPinquire (IGRlong *msg;IGRlong *which_error; struct var_list *list )

{
        IGRboolean storage;
        IGRdouble rotate[4][4];
	IGRdouble view_to_wld[4][4];
	IGRdouble wld_to_view[4][4];
	IGRdouble temp_pt[3];
	IGRdouble scales[3];
	IGRdouble depths[2];
	IGRlong num_points;
        IGRdouble *temper;
        IGRint *temp_int;
        struct gragad_inst *gragad_inst;
	struct IGRplane *vw_plane;
	IGRlong status = 0;		
	IGRlong size_mv;
	IGRshort i;
	IGRshort four = 4;
	struct DPrange_check range_chk;	
	struct DPsavevw *save_vw;
	IGRdouble z_axis[3];
	IGRdouble shear[4][4];
	IGRdouble TransEYEPT[4][4];
	IGRdouble trans_ex[4][4];
	IGRdouble per_trans[4][4];
	IGRdouble scale[4][4];
	IGRdouble half_way_mtx[4][4];
	IGRdouble ss_mtx[4][4];
	IGRdouble fin_vrp[3];
	IGRdouble coi[3];
	struct IGRline vw_vector;
	struct IGRplane proj_plane;
	IGRdouble tolerance;
	IGRdouble COI_plane[3];
	IGRdouble t;
	IGRdouble half_angle;
	IGRdouble sine;
	IGRdouble m_cos;
	IGRdouble x_scrn_ext;
	IGRdouble y_scrn_ext;
	IGRdouble p_plane_ext;
	IGRdouble y_plane_ext;
	IGRdouble x_plane_ext;
	IGRdouble z_min;
	IGRdouble *p_doub;	
	IGRchar full_name[DI_PATH_MAX];
	IGRchar name[DI_PATH_MAX];
	IGRboolean b_sts;
	BSrc rc;
	IGRdouble dist_tol;


        for ( storage = TRUE;
                (list->var != END_PARAM) && (storage == TRUE); list++)
         {
            
            switch (list->var)
             {
	    case VIEW_TYPE:
		storage = (list->num_bytes >= sizeof(IGRint));
		if (storage)
		{
		    *(list->bytes_returned) = sizeof(IGRint);
		    (*(IGRint *)list->var_ptr) = TYPE_GRAGAD;
		}
		break;

            case GRAGAD_NAME :
		status = di$untranslate (objname = full_name,
				path = GRDP_REGVWS,
				objid = my_id,
				osnum = OM_Gw_current_OS);
		if (!(status &1))
		{
			#ifdef DEBUG
			di$report_error(sts = status, comment = "untranslate failed in DPsetinq");
			#endif
			goto fini;
		}
		status = di$split(pathname=full_name,
			name=name);
		if (!(status &1))
		{
			#ifdef DEBUG
			di$report_error(sts = status, comment = "split failed in DPsetinq");
			#endif
			goto fini;
		}
                *(list->bytes_returned) = strlen(name) + 1;
                storage = (list->num_bytes >= *list->bytes_returned);
                 if (!(storage))
		{
                    *(list->bytes_returned) = list->num_bytes;
		    name[list->num_bytes -1] = '\0';

		}
                  OM_BLOCK_MOVE( name,
                                 list->var_ptr,
                                 *list->bytes_returned);
                break;

	    case SIZE_DESCRIPT:
		*(list->bytes_returned) = sizeof(IGRint);
		if(list->num_bytes >= *list->bytes_returned)
		{
		    (*(IGRint *)list->var_ptr) = 0;
		}
		break;
	    case DESCRIPT:
		*(list->bytes_returned) = 1;
		if(list->num_bytes >= *list->bytes_returned)
		{
		    (*(IGRchar *)list->var_ptr) = '\0';
		}
		else
		{
		    *(list->bytes_returned) = 0;
		}
		break;

            case WIN_NO :
                storage = (list->num_bytes >= sizeof( ME.IGEgadget->win_no));
                if (storage)
                 {
                  *( (IGRint *)list->var_ptr) = ME.IGEgadget->win_no;
                  *list->bytes_returned = sizeof (ME.IGEgadget->win_no);
                 }
                break;

            case GRAGAD_DEP :  
                *(list->bytes_returned) = (sizeof (IGRint) * 4);
                storage = (list->num_bytes >= *list->bytes_returned);
                if (storage)
                 {
                        temp_int = (IGRint *)list->var_ptr;
                        *temp_int++ = ME.IGEgadget->min_x_dep;
                        *temp_int++ = ME.IGEgadget->min_y_dep;
                        *temp_int++ = ME.IGEgadget->max_x_dep;
                        *temp_int = ME.IGEgadget->max_y_dep;
                 }  
                break;

            case GRAGAD_INDEP :   
                *(list->bytes_returned) = (sizeof (IGRdouble) * 4);
                storage = (list->num_bytes >= *list->bytes_returned);
                if (storage)
                 {
                        temper = (IGRdouble *)list->var_ptr;
                        *temper++ = ME.IGEgadget->min_x_indep;
                        *temper++ = ME.IGEgadget->min_y_indep;
                        *temper++ = ME.IGEgadget->max_x_indep;
                        *temper = ME.IGEgadget->max_y_indep;
                 }                         
                break;

            case GRAGAD_FLAGS :
                *(list->bytes_returned) = sizeof (ME.IGEgragad->gragad.flags);
                storage = (list->num_bytes >= *list->bytes_returned);
                if (storage)
                 {
                  OM_BLOCK_MOVE( &ME.IGEgragad->gragad.flags,
                                 list->var_ptr,
                                 *list->bytes_returned);
                 }  
                break;

            case FONT_OS_PTR :    
                *(list->bytes_returned) = sizeof(IGRint);
                storage = (list->num_bytes >= *list->bytes_returned);
                if (storage)
                 {
                  OM_BLOCK_MOVE( &ME.IGEgragad->gragad.fnt_os_ptr,
                                 list->var_ptr,
                                 *list->bytes_returned);
                 }                         
                break;

            case GRID_PER_REF_X :         
                *(list->bytes_returned) = sizeof (ME.IGEgragad->gragad.grid_per_ref_x);
                storage = (list->num_bytes >= *list->bytes_returned);
                if (storage)
                 {

                  *( (IGRlong *)list->var_ptr) = ME.IGEgragad->gragad.grid_per_ref_x;

                 }                         
                break;
            case GRID_PER_REF_Y :
                *(list->bytes_returned) = sizeof (ME.IGEgragad->gragad.grid_per_ref_y);
                storage = (list->num_bytes >= *list->bytes_returned);
                if (storage)
                 {
                  *( (IGRlong *)list->var_ptr) = ME.IGEgragad->gragad.grid_per_ref_y;
                 }                         
                break;
            case  UOR_PER_REF_X :         
                *(list->bytes_returned) = sizeof (ME.IGEgragad->gragad.uor_per_ref_x);
                storage = (list->num_bytes >= *list->bytes_returned);
                if (storage)
                 {
                  *( (IGRdouble *)list->var_ptr) = ME.IGEgragad->gragad.uor_per_ref_x;
                 }                         
                break;
            case  UOR_PER_REF_Y :
                *(list->bytes_returned) = sizeof (ME.IGEgragad->gragad.uor_per_ref_y);
                storage = (list->num_bytes >= *list->bytes_returned);
                if (storage)
                 {
                  *( (IGRdouble *)list->var_ptr) = ME.IGEgragad->gragad.uor_per_ref_y;
                 }                         
                break;
            case VIEW_ORIGIN :  

                *(list->bytes_returned) = sizeof (ME.IGEgragad->gragad.origin);
                storage = (list->num_bytes >= *list->bytes_returned);
                if (storage)
                 {
#ifndef IDRAW

			if (!(ME.IGEgragad->gragad.flags & IS_PERSP))
#endif
			{
	                  OM_BLOCK_MOVE( ME.IGEgragad->gragad.origin,
                                 list->var_ptr,
                                 *list->bytes_returned);
			}
#ifndef IDRAW
			else
			{
	                  OM_BLOCK_MOVE( ME.IGEgragad->gragad.eye_pt,
                                 list->var_ptr,
                                 *list->bytes_returned);
			}
#endif
                 }  
                break;

            case VIEW_ROTATION :  

                *(list->bytes_returned) = sizeof (IGRdouble) *16;
                storage = (list->num_bytes >= *list->bytes_returned);
                if (storage)
                 {
                    if (ME.IGEgragad->gragad.flags & VALID_ALT_INV &&
                               ME.IGEgragad->gragad.flags & CONST_PL_DEF)
                    {
                    OM_BLOCK_MOVE( ME.IGEgragad->gragad.construct_plane,
                                     rotate,
                                     *list->bytes_returned);
                    rotate[0][3] = 0;
                    rotate[1][3] = 0;
                    rotate[2][3] = 0;
                    OM_BLOCK_MOVE( rotate,
                                     list->var_ptr,
                                     *list->bytes_returned);
                    }
                    else
                    {
                        OM_BLOCK_MOVE( ME.IGEgragad->gragad.rotation,
                                         list->var_ptr,
                                         *list->bytes_returned);
                    }
                 } /* close for if storage */ 
                break;
            case VW_ROT_NO_CON :

                *(list->bytes_returned) = sizeof (IGRdouble) *16;
                storage = (list->num_bytes >= *list->bytes_returned);
                if (storage)
                 {
                        OM_BLOCK_MOVE( ME.IGEgragad->gragad.rotation,
                                         list->var_ptr,
                                         *list->bytes_returned);
                 } /* close for if storage */ 
                break;

	    case VIEW_PLANE:
                *(list->bytes_returned) = sizeof (struct IGRplane);
                storage = (list->num_bytes >= *list->bytes_returned);
                if (storage)
                 {
    	            num_points = 1;
		    vw_plane = (struct IGRplane *)list->var_ptr;
                    if (ME.IGEgragad->gragad.flags & VALID_ALT_INV && ME.IGEgragad->gragad.flags & CONST_PL_DEF)
                    {
		        for ( i = 0; i < 3; ++i )
		        {
		            vw_plane->normal[i] = ME.IGEgragad->gragad.construct_plane[2][i];
			    vw_plane->point[i] = ME.IGEgragad->gragad.construct_plane[i][3];
		        }
		     }
		     else
		     {
		        for ( i = 0; i < 3; ++i )
		        {
		            vw_plane->normal[i] = ME.IGEgragad->gragad.rotation[2][i];
		        }
			temp_pt[0] = (ME.IGEgragad->gragad.vw_volume[3] - ME.IGEgragad->gragad.vw_volume[0])/2.0;
			temp_pt[1] = (ME.IGEgragad->gragad.vw_volume[4] - ME.IGEgragad->gragad.vw_volume[1])/2.0;
			temp_pt[2] = ME.IGEgragad->gragad.act_z;
		    	MAinvmx(msg, &four, (IGRdouble *)ME.IGEgragad->gragad.wld_to_view, 
					(IGRdouble *)view_to_wld);
			MAptsxform(msg, &num_points, (IGRdouble *)view_to_wld,
					temp_pt,vw_plane->point);
		     }
		  } /* close for if storage */
		break;		
#ifndef IDRAW

	    case PERSP_SCALING :
                *(list->bytes_returned) = sizeof (IGRdouble) * 3;
                storage = (list->num_bytes >= *list->bytes_returned);
		if (!(ME.IGEgragad->gragad.flags & IS_PERSP))
		{
		    storage = FALSE;
		    goto fini;
		}
                if (storage)
                {
		    DPalignper(msg, DPLEFT_VIEW, ME.IGEgragad->gragad.vpn,
				ME.IGEgragad->gragad.vup,
				ME.IGEgragad->gragad.eye_pt,
				(IGRdouble *)rotate, (IGRdouble *)half_way_mtx);
		    num_points = 1;
		    MAptsxform(msg, &num_points, (IGRdouble *)half_way_mtx, 
				ME.IGEgragad->gragad.vrp, fin_vrp);
		    MAptsxform(msg, &num_points, (IGRdouble *)half_way_mtx,
				ME.IGEgragad->gragad.coi,coi);
		    half_angle = ME.IGEgragad->gragad.vw_angle / 2.0;
		    MAsincos(msg,&half_angle,&sine,&m_cos);
		    x_scrn_ext = ME.IGEgadget->max_x_dep - ME.IGEgadget->min_x_dep;
		    y_scrn_ext = ME.IGEgadget->max_y_dep - ME.IGEgadget->min_y_dep;
		    p_plane_ext = 2.0 * (sine/m_cos) * fin_vrp[2];
		    p_plane_ext = MAdabs (msg,&p_plane_ext);	
		    if (y_scrn_ext > x_scrn_ext)
		    {
			x_plane_ext = p_plane_ext;
			y_plane_ext = p_plane_ext * y_scrn_ext / x_scrn_ext;
		    }
		    else
		    {
		    	y_plane_ext = p_plane_ext;
			x_plane_ext = p_plane_ext * x_scrn_ext / y_scrn_ext;
		    }
 		    scales[0] = 2* fin_vrp[2] / 
				(x_plane_ext * ME.IGEgragad->gragad.vw_volume[5]); 
		    scales[1] = 2* fin_vrp[2] /
				(y_plane_ext * ME.IGEgragad->gragad.vw_volume[5]); 
		    scales[2] = 1 /  ME.IGEgragad->gragad.vw_volume[5]; 
		    OM_BLOCK_MOVE(scales,list->var_ptr,
						 *list->bytes_returned);

		}
		break;
            case POST_ROTATION :  
                *(list->bytes_returned) = sizeof (IGRdouble) *16;
                storage = (list->num_bytes >= *list->bytes_returned);
		if (!(ME.IGEgragad->gragad.flags & IS_PERSP))
		{
		    storage = FALSE;
		    goto fini;
		}
                if (storage)
                 {

			temp_pt[0] = 0;
			temp_pt[1] = 0;
			temp_pt[2] = 0;

			z_axis[0] = 0;
			z_axis[1] = 0;
			z_axis[2] = 1;

			/* initalizing matrices */

			MAidmx(msg, (IGRdouble *)shear);
			OM_BLOCK_MOVE(shear,TransEYEPT,(sizeof(IGRdouble)*16));
			OM_BLOCK_MOVE(shear,trans_ex,(sizeof(IGRdouble)*16));
			OM_BLOCK_MOVE(shear,per_trans,(sizeof(IGRdouble)*16));
			OM_BLOCK_MOVE(shear,scale,(sizeof(IGRdouble)*16));
	
			    /* Checking to see if the VPN and VUP are parallel. If they are, then
			       they are invalid.                                                   */  
			    for ( i = 0; i < 3; ++i )
			    {
				TransEYEPT[i][3] = -ME.IGEgragad->gragad.eye_pt[i];
			    }
			    /* be sure that the view vector and the vpn are going in approximately 
				the same direction.  I shouldn't need to do this. */

			    DPalignper(msg, DPLEFT_VIEW, 
					ME.IGEgragad->gragad.vpn,
					ME.IGEgragad->gragad.vup,
					ME.IGEgragad->gragad.eye_pt,
					(IGRdouble *)rotate, 
					(IGRdouble *)half_way_mtx);
			    /*** CALCULATING THE POST ROTATION MATRIX *****/
			    num_points = 1;
			    MAptsxform(msg, &num_points, (IGRdouble *)half_way_mtx,
					ME.IGEgragad->gragad.vrp, fin_vrp);
			    MAptsxform(msg, &num_points, (IGRdouble *)half_way_mtx, 
					ME.IGEgragad->gragad.coi, coi);
				vw_vector.point1 = temp_pt;
				vw_vector.point2 = coi;
				proj_plane.point = fin_vrp;
				proj_plane.normal = z_axis; 
				tolerance = 0.00000001;
				MAlnplisect (msg, &vw_vector, &proj_plane, &tolerance, COI_plane, &t);
				if (((COI_plane[0] != 0)||(COI_plane[1] != 0))&&( fin_vrp[2] != 0 ))
				 {
				    shear[0][2] = COI_plane[0]/fin_vrp[2];
			            shear[1][2] = COI_plane[1]/fin_vrp[2];
				 }
				half_angle = ME.IGEgragad->gragad.vw_angle / 2.0;
				MAsincos(msg,&half_angle,&sine,&m_cos);
				x_scrn_ext = ME.IGEgadget->max_x_dep - ME.IGEgadget->min_x_dep;
				y_scrn_ext = ME.IGEgadget->max_y_dep - ME.IGEgadget->min_y_dep;
				p_plane_ext = 2.0 * (sine/m_cos) * fin_vrp[2];
				p_plane_ext = MAdabs (msg,&p_plane_ext);	
				if (y_scrn_ext > x_scrn_ext)
				{
				    x_plane_ext = p_plane_ext;
				    y_plane_ext = p_plane_ext * y_scrn_ext / x_scrn_ext;
				}
				else
				{
				    y_plane_ext = p_plane_ext;
				    x_plane_ext = p_plane_ext * x_scrn_ext / y_scrn_ext;
				}
				scale[0][0] = 2* fin_vrp[2] / 
				(x_plane_ext * ME.IGEgragad->gragad.vw_volume[5]); 
				scale[1][1] = 2* fin_vrp[2] /
				(y_plane_ext * ME.IGEgragad->gragad.vw_volume[5]); 
				scale[2][2] = 1 /  ME.IGEgragad->gragad.vw_volume[5]; 
				z_min = ME.IGEgragad->gragad.vw_volume[2] /  ME.IGEgragad->gragad.vw_volume[5];
				per_trans[2][2] = 1/(1 - z_min);
				per_trans[2][3] = -z_min / (1 - z_min);
				per_trans[3][2] = 1;
				MAmulmx(msg, &four, &four, &four, (IGRdouble *)scale,
					(IGRdouble *)shear, (IGRdouble *)ss_mtx);
				MAmulmx(msg, &four, &four, &four, (IGRdouble *)per_trans,
					(IGRdouble *)ss_mtx, (IGRdouble *)list->var_ptr);
				/* Scaling can be retrieved from this matrix.
				   x scale is [0][0] position 
				   y scale is [1][1] position
				   z scale is [3][2] position
				*/

		 }
		 break;
#endif /* IDRAW */
/*
            case POST_ROTATION :  

                *(list->bytes_returned) = sizeof (IGRdouble) *16;
                storage = (list->num_bytes >= *list->bytes_returned);
                if (storage)
                 {
                  OM_BLOCK_MOVE( ME.IGEgragad->gragad.post_rotation,
                                 list->var_ptr,
                                 *list->bytes_returned);
                 }  
                break;
*/
            case VW_VOLUME :       
                *(list->bytes_returned) = (sizeof (IGRdouble) * 6);
                storage = (list->num_bytes >= *list->bytes_returned);
                if (storage)
                 {
                  OM_BLOCK_MOVE( ME.IGEgragad->gragad.vw_volume,
                                 list->var_ptr,
                                 *list->bytes_returned);
                 }  
                break;
	    case WLD_VOLUME:
                *(list->bytes_returned) = (sizeof (IGRdouble) * 6);
                storage = (list->num_bytes >= *list->bytes_returned);
                if (storage)
                 {
#ifndef IDRAW

			if (!(ME.IGEgragad->gragad.flags & IS_PERSP))
#endif
			{
		    		MAinvmx(msg, &four, 
					(IGRdouble *)ME.IGEgragad->gragad.wld_to_view, 
					(IGRdouble *)view_to_wld);
			}
#ifndef IDRAW
			else
			{
				b_sts = dp$cal_wldvw_mtx(
						msg=msg,
						in_flags = DPLEFT_VIEW,
						origin = ME.IGEgragad->gragad.eye_pt,
						rotation = (IGRdouble *)ME.IGEgragad->gragad.rotation,
						wldvw_mtx = (IGRdouble *)wld_to_view);
				if (!b_sts)
				{
#ifdef DEBUG
				printf("error in wld mtx");
#endif
		        	}
		    		MAinvmx(msg, &four, (IGRdouble *)wld_to_view,
						(IGRdouble *) view_to_wld);
			}
#endif
    	    	    DPsetrng(msg, (IGRdouble *)view_to_wld, &range_chk);
    	    	    DPgetrng(msg, (IGRdouble *)view_to_wld, &range_chk, 
				ME.IGEgragad->gragad.vw_volume, 
				(IGRdouble *)list->var_ptr);
                 }  
                break;
            case ACT_Z :
                storage = (list->num_bytes >= sizeof( ME.IGEgragad->gragad.act_z));
                if (storage)
                 {
                  *( (IGRdouble *)list->var_ptr) = ME.IGEgragad->gragad.act_z;
                  *list->bytes_returned = sizeof (ME.IGEgragad->gragad.act_z);
                 }
                break;
	    case WLD_ACT_Z:
                storage = (list->num_bytes >= sizeof( ME.IGEgragad->gragad.act_z));
                if (storage)
                 {
#ifndef IDRAW
		    if ( ME.IGEgragad->gragad.flags & IS_PERSP)
		    {
			b_sts = dp$cal_wldvw_mtx(msg=msg,
						in_flags = DPLEFT_VIEW,
						origin = ME.IGEgragad->gragad.eye_pt,
						rotation = (IGRdouble *)ME.IGEgragad->gragad.rotation,
						wldvw_mtx = (IGRdouble *)wld_to_view);
			if (!b_sts)
			{
#ifdef DEBUG
				printf("error in wld mtx");
#endif
		        }
		    }
		    else
#endif
		    {
	                  OM_BLOCK_MOVE( ME.IGEgragad->gragad.wld_to_view,
                                wld_to_view,sizeof(IGRdouble)*16);
		    }

	    		DPgetvwz_in_wld(msg, 0, (IGRdouble *)ME.IGEgragad->gragad.rotation,
					(IGRdouble *)wld_to_view,
					&ME.IGEgragad->gragad.act_z,
					1, (IGRdouble *)list->var_ptr);
			BSxtractpar( &rc, BSTOLLENVEC,  &dist_tol );
			if (*(IGRdouble *)list->var_ptr>-dist_tol&& *(IGRdouble *)list->var_ptr<dist_tol) 
			{
				*(IGRdouble *)list->var_ptr=0.0;
			}
                  	*list->bytes_returned = 
					sizeof (ME.IGEgragad->gragad.act_z);
		    } /* close for if storage */
	      	break;

            case WLD_DISPLAY_DEPTHS :
                storage = (list->num_bytes >= sizeof( IGRdouble)*2);
                if (storage)
                {
			depths[0] = ME.IGEgragad->gragad.vw_volume[2];
			depths[1] = ME.IGEgragad->gragad.vw_volume[5];
#ifndef IDRAW
		    	if ( ME.IGEgragad->gragad.flags & IS_PERSP)
		    	{
				b_sts = dp$cal_wldvw_mtx(msg=msg,
						in_flags = DPLEFT_VIEW,
						origin = ME.IGEgragad->gragad.eye_pt,
						rotation = (IGRdouble *)ME.IGEgragad->gragad.rotation,
						wldvw_mtx = (IGRdouble *)wld_to_view);
				if (!b_sts)
				{
#ifdef DEBUG
					printf("error in wld mtx");
#endif
		        	}
		    	}
		    	else
#endif
		    	{
	                  	OM_BLOCK_MOVE( ME.IGEgragad->gragad.wld_to_view,
                                	wld_to_view,sizeof(IGRdouble)*16);
		    	}
			DPgetvwz_in_wld(msg, 0, (IGRdouble *)ME.IGEgragad->gragad.rotation,
					(IGRdouble *)wld_to_view,depths, 2,
					(IGRdouble *)list->var_ptr);
                  	*list->bytes_returned = sizeof(IGRdouble) *2;
                 } /* close for if storage */

                break;

            case ACT_Z_SCREEN :
                storage = (list->num_bytes >= sizeof( ME.IGEgragad->gragad.act_z_screen));
                if (storage)
                 {
                  *( (IGRdouble *)list->var_ptr) = ME.IGEgragad->gragad.act_z_screen;
                  *list->bytes_returned = sizeof (ME.IGEgragad->gragad.act_z_screen);
                 }
                break;

            case DIT_TOL :
                storage = (list->num_bytes >= sizeof( ME.IGEgragad->gragad.dit_tol));
                if (storage)
                 {
                  *( (IGRdouble *)list->var_ptr) = ME.IGEgragad->gragad.dit_tol;
                  *list->bytes_returned = sizeof (ME.IGEgragad->gragad.dit_tol);
                 }
                break;

            case WLD_TO_VIEWPORT :
                *(list->bytes_returned) = sizeof (IGRdouble) *16;
                storage = (list->num_bytes >= *list->bytes_returned);
                if (storage)
                 {
                  OM_BLOCK_MOVE( ME.IGEgragad->gragad.wld_to_viewport,
                                 list->var_ptr,
                                 *list->bytes_returned);
                 }  
                break;

            case VIEWPORT_TO_WLD :
                *(list->bytes_returned) = sizeof (IGRdouble) *16;
                storage = (list->num_bytes >= *list->bytes_returned);
                if (storage)
                 {

                  OM_BLOCK_MOVE( ME.IGEgragad->gragad.viewport_to_wld,
                                 list->var_ptr,
                                 *list->bytes_returned);
                 }  
                break;

            case ALT_VIEWPORT_TO_WLD :
                *(list->bytes_returned) = sizeof (IGRdouble) *16;
                storage = (list->num_bytes >= *list->bytes_returned);
                if (storage)
                 {
                  OM_BLOCK_MOVE( ME.IGEgragad->gragad.alt_vwport_to_wld,
                                 list->var_ptr,
                                 *list->bytes_returned);
                 }  
                break;
            case WLD_TO_VIEW :
                *(list->bytes_returned) = sizeof (IGRdouble) *16;
                storage = (list->num_bytes >= *list->bytes_returned);
                if (storage)
                 {
#ifndef IDRAW
		    if (!(ME.IGEgragad->gragad.flags & IS_PERSP))
#endif
		    {
                  	OM_BLOCK_MOVE( ME.IGEgragad->gragad.wld_to_view,
                                 list->var_ptr,
                                 *list->bytes_returned);
		    }
#ifndef IDRAW
		    else
		    {
			DPalignper(msg, (DPLEFT_ROT | DPLEFT_VIEW), 
					ME.IGEgragad->gragad.vpn,
					ME.IGEgragad->gragad.vup,
					ME.IGEgragad->gragad.eye_pt,
					(IGRdouble *)rotate,
					(IGRdouble *)list->var_ptr);
		    }
#endif
                 }  
                break;

            case DIT_CLIP_RANGE :
                *(list->bytes_returned) = (sizeof (IGRdouble) * 6);
                storage = (list->num_bytes >= *list->bytes_returned);
                if (storage)
                 {
                  OM_BLOCK_MOVE( ME.IGEgragad->gragad.dit_clip_range,
                                 list->var_ptr,
                                 *list->bytes_returned);
                 }  
                break;

            case VVOL_VIEWPORT_SCALE :
                storage = (list->num_bytes >= sizeof( ME.IGEgragad->gragad.vvol_viewport_scale));
                if (storage)
                 {
                  *( (IGRdouble *)list->var_ptr) = ME.IGEgragad->gragad.vvol_viewport_scale;
                  *list->bytes_returned = sizeof (ME.IGEgragad->gragad.vvol_viewport_scale);
                 }
                break;
            case  WLD_VIEWPORT_TYPE :     
                *(list->bytes_returned) = sizeof (ME.IGEgragad->gragad.wld_viewport_type);
                storage = (list->num_bytes >= *list->bytes_returned);
                if (storage)
                 {
                  *( (IGRshort *)list->var_ptr) = ME.IGEgragad->gragad.wld_viewport_type;
                 }                         
                break;

	    case LEVELS:
                *(list->bytes_returned) = 
			sizeof (IGRint) * ((DP_NUM_OF_LEVELS -1)/32 +1);
                storage = (list->num_bytes >= *list->bytes_returned);
                if (storage)
                 {
                  OM_BLOCK_MOVE( ME.IGEgragad->gragad.levels,
                                 list->var_ptr,
                                 *list->bytes_returned);
                 }                         
                break;
	    case DISPLAY_MODE:
                storage = (list->num_bytes >= sizeof( ME.IGEgragad->gragad.display_mode));
                if (storage)
                 {
                  *((IGRshort *)list->var_ptr) = ME.IGEgragad->gragad.display_mode;
                  *list->bytes_returned = sizeof (ME.IGEgragad->gragad.display_mode);
                 }
                break;
	
	    case GPIPE_ID:
                storage = (list->num_bytes >= sizeof( ME.IGEgragad->gragad.gpipe_id));
                if (storage)
                 {
                  *((IGRint *)list->var_ptr) = ME.IGEgragad->gragad.gpipe_id;
                  *list->bytes_returned = sizeof (ME.IGEgragad->gragad.gpipe_id);
                 }
                break;
	    
            case RANGE_CHK:
                *(list->bytes_returned) = sizeof (struct DPrange_check);
                storage = (list->num_bytes >= *list->bytes_returned);
                if (storage)
                {
                    *((struct DPrange_check *)list->var_ptr) =
ME.IGEgragad->gragad.range_chk;
                }
                break;

#ifndef IDRAW
            case CONSTRUCT_PLANE:

                *(list->bytes_returned) = sizeof (IGRdouble) *16;
                storage = (list->num_bytes >= *list->bytes_returned);
                if (storage)
                 {
                  OM_BLOCK_MOVE( ME.IGEgragad->gragad.construct_plane,
                                 list->var_ptr,
                                 *list->bytes_returned);
                 }  
                break;
            case CONSTRUCT_PL_ORG:

                *(list->bytes_returned) = sizeof (IGRdouble) * 3;
                storage = (list->num_bytes >= *list->bytes_returned);
                if (storage)
                 {
			p_doub = (IGRdouble *)list->var_ptr;
			*p_doub = ME.IGEgragad->gragad.construct_plane[0][3];
			p_doub ++;
			*p_doub = ME.IGEgragad->gragad.construct_plane[1][3];
			p_doub ++;
			*p_doub = ME.IGEgragad->gragad.construct_plane[2][3];
                 }  
                break;
#endif /* IDRAW  */
/*		
	    case PROJ_TO_CONST_PLANE:

                *(list->bytes_returned) = sizeof (IGRdouble) *16;
                storage = (list->num_bytes >= *list->bytes_returned);
                if (storage)
                 {

		    for ( i = 0; i < 3; ++i )
		    {
		        vw_direct_vec[i] = ME.IGEgragad->gragad.rotation[2][i];
		        construct_plane.normal[i] = ME.IGEgragad->gragad.construct_plane[2][i];
		        construct_plane.point[i] = ME.IGEgragad->gragad.construct_plane[i][3];
		    }

 		    MAunitvc(msg, vw_direct_vec, vw_unit_vec);
	            if(! MApapromx(msg, vw_unit_vec, &construct_plane, project_mtx))
        	    {
			*msg = MSFAIL;
			status = OM_E_ABORT;
        	        goto fini;
        	    }
 		    
                    OM_BLOCK_MOVE( project_mtx,
                                 list->var_ptr,
                                 *list->bytes_returned);
                 }  
                break;
*/
            case GRAGAD_STRUCT:
                *(list->bytes_returned) = sizeof (struct DPgra_gad);
                storage = (list->num_bytes >= *list->bytes_returned);
                if (storage)
                {
                    *((struct DPgra_gad *)list->var_ptr) = ME.IGEgragad->gragad;
                }
                break;
            case GRAGAD_INST_STRUCT:
                *(list->bytes_returned) = sizeof (struct gragad_inst);
                storage = (list->num_bytes >= *list->bytes_returned);
                if (storage)
                {
                    gragad_inst = (struct gragad_inst *)list->var_ptr;
                    gragad_inst->win_no = ME.IGEgadget->win_no;
                    gragad_inst->min_x_dep = ME.IGEgadget->min_x_dep;
                    gragad_inst->min_y_dep = ME.IGEgadget->min_y_dep;
                    gragad_inst->max_x_dep = ME.IGEgadget->max_x_dep;
                    gragad_inst->max_y_dep = ME.IGEgadget->max_y_dep;

                    gragad_inst->min_x_indep = ME.IGEgadget->min_x_indep;
                    gragad_inst->min_y_indep = ME.IGEgadget->min_y_indep;
                    gragad_inst->max_x_indep = ME.IGEgadget->max_x_indep;
                    gragad_inst->max_y_indep = ME.IGEgadget->max_y_indep;

                    gragad_inst->gragad = ME.IGEgragad->gragad;
                }
                break;
#ifndef IDRAW
	case VRP:	
	
                *(list->bytes_returned) = sizeof(ME.IGEgragad->gragad.vrp);
                storage = (list->num_bytes >= *list->bytes_returned);
                if (storage)
                 {
                  OM_BLOCK_MOVE( ME.IGEgragad->gragad.vrp,
                                 list->var_ptr,
                                 *list->bytes_returned);
                 }  
                break;
	case VPN:
                *(list->bytes_returned) = sizeof(ME.IGEgragad->gragad.vpn);
                storage = (list->num_bytes >= *list->bytes_returned);
                if (storage)
                 {
                  OM_BLOCK_MOVE( ME.IGEgragad->gragad.vpn,
                                 list->var_ptr,
                                 *list->bytes_returned);
                 }  
                break;

	case VUP:
                *(list->bytes_returned) = sizeof(ME.IGEgragad->gragad.vup);
                storage = (list->num_bytes >= *list->bytes_returned);
                if (storage)
                 {
                  OM_BLOCK_MOVE( ME.IGEgragad->gragad.vup,
                                 list->var_ptr,
                                 *list->bytes_returned);
                 }  
                break;
	
	
	case COI:
                *(list->bytes_returned) = sizeof(ME.IGEgragad->gragad.coi);
                storage = (list->num_bytes >= *list->bytes_returned);
                if (storage)
                 {
                  OM_BLOCK_MOVE( ME.IGEgragad->gragad.coi,
                                 list->var_ptr,
                                 *list->bytes_returned);
                 }  
                break;
	case EYE_PT:
                *(list->bytes_returned) = sizeof(ME.IGEgragad->gragad.eye_pt);
                storage = (list->num_bytes >= *list->bytes_returned);
                if (storage)
                 {
                  OM_BLOCK_MOVE( ME.IGEgragad->gragad.eye_pt,
                                 list->var_ptr,
                                 *list->bytes_returned);
                 }  
                break;
	
	case VIEW_ANGLE:
	
                *(list->bytes_returned) = sizeof(ME.IGEgragad->gragad.vw_angle);
                storage = (list->num_bytes >= *list->bytes_returned);
                if (storage)
                 {
                  OM_BLOCK_MOVE( &(ME.IGEgragad->gragad.vw_angle),
                                 list->var_ptr,
                                 *list->bytes_returned);
                 }  
                break;
#endif /* IDRAW */

	case SAV_VW_STRUCT:
                *(list->bytes_returned) = sizeof(struct DPsavevw);
                storage = (list->num_bytes >= *list->bytes_returned);
                if (storage)
                 {
		    save_vw = (struct DPsavevw *)list->var_ptr;
		    save_vw->flags = ME.IGEgragad->gragad.flags;
		    save_vw->grid_per_ref_x = ME.IGEgragad->gragad.grid_per_ref_x;
		    save_vw->grid_per_ref_y = ME.IGEgragad->gragad.grid_per_ref_y;
		    size_mv = sizeof (IGRint) * ((DP_NUM_OF_LEVELS -1)/32 +1);
		    OM_BLOCK_MOVE (ME.IGEgragad->gragad.levels,
		    			save_vw->levels, size_mv);
		    save_vw->min_x_indep = ME.IGEgadget->min_x_indep;
		    save_vw->min_y_indep = ME.IGEgadget->min_y_indep;
		    save_vw->max_x_indep = ME.IGEgadget->max_x_indep;
		    save_vw->max_y_indep = ME.IGEgadget->max_y_indep;
		    save_vw->uor_per_ref_x = ME.IGEgragad->gragad.uor_per_ref_x;
		    save_vw->uor_per_ref_y = ME.IGEgragad->gragad.uor_per_ref_y;
                    OM_BLOCK_MOVE( ME.IGEgragad->gragad.origin,
					save_vw->origin, sizeof (IGRdouble) *3);

		    OM_BLOCK_MOVE( ME.IGEgragad->gragad.rotation,
		    		save_vw->rotation, sizeof(IGRdouble)*16);

		    OM_BLOCK_MOVE( ME.IGEgragad->gragad.vw_volume,
		    		save_vw->vw_volume,sizeof(IGRdouble) *6);

		    save_vw->act_z = ME.IGEgragad->gragad.act_z;

		    OM_BLOCK_MOVE( ME.IGEgragad->gragad.construct_plane,
		    		save_vw->construct_plane,sizeof(IGRdouble)*16);

		    OM_BLOCK_MOVE( ME.IGEgragad->gragad.eye_pt,
		    		save_vw->eye_pt, sizeof (IGRdouble) *3);

		    OM_BLOCK_MOVE( ME.IGEgragad->gragad.coi,
		    		save_vw->coi,  sizeof (IGRdouble) *3);

		    save_vw->vw_angle = ME.IGEgragad->gragad.vw_angle;

		    OM_BLOCK_MOVE( ME.IGEgragad->gragad.vrp,
		    		save_vw->vrp,  sizeof (IGRdouble) *3);

		    OM_BLOCK_MOVE( ME.IGEgragad->gragad.vpn,
		    		save_vw->vpn,  sizeof (IGRdouble) *3);

		    OM_BLOCK_MOVE( ME.IGEgragad->gragad.vup,
		    		save_vw->vup,  sizeof (IGRdouble) *3);
		  
                 }  
                break;
	
            default :
                storage = FALSE;
                break;
            }  /* close for switch */
        if (storage == FALSE)
         {
           *which_error = list->var;
         }
     }    /* close for "for"  */

     *msg = (storage) ? MSSUCC : MSFAIL;
     status = (storage) ? OM_S_SUCCESS : OM_E_ABORT;
     fini:
     return (status);

 }   /* close for inquire */

method DPset (IGRlong *msg;IGRlong *which_error; struct var_list *list )

{

        IGRboolean storage;
        struct gragad_inst *gragad_inst;
        IGRint *temp_int;
	IGRint temp_flag;
	IGRlong status = OM_S_SUCCESS;	
	IGRlong num_bytes;
	IGRdouble ex_zpt[3];
	IGRdouble *entered_z;
	IGRdouble z_array[3];
	IGRdouble wld_to_view[4][4];
	IGRlong num_points=1;
	IGRdouble *p_doub;
	IGRboolean b_sts;
	IGRchar full_name[DI_PATH_MAX];

	OM_S_CHANSELECT chandef;
	
        for ( storage = TRUE;
                (list->var != END_PARAM) && (storage == TRUE); list++)
         {

            switch (list->var)
             {

            case GRAGAD_NAME :
		
		status = di$untranslate (objname = full_name,
				path = GRDP_REGVWS,
				objid = my_id,
				osnum = OM_Gw_current_OS);

		if (!(status & 1)) /** gragad is not already present **/
		{
			status = DPadd_vw_name_dir (msg,
					(DP_PROTECTION),
					OM_Gw_current_OS,
					my_id,GRDP_REGVIEWS,GRDP_GRVIEWS,
					list->var_ptr);
		}
		else /** gragad is already present **/
		{
			status = DPadd_vw_name_dir (msg,
					(DPCHG_VW_NAME | DP_PROTECTION),
					OM_Gw_current_OS,
					my_id,GRDP_REGVIEWS,GRDP_GRVIEWS,
					list->var_ptr);
		}

		if (status & 1)
		{
		    if (ME.IGEgragad->gragad.flags & IS_ACTIVE)
		    {
		   	chandef.type = OM_e_name;
		   	chandef.u_sel.name = "to_parent";

		   	status = om$send( msg = message IGEwindow.display_name(list->var_ptr),
                 		   	p_chanselect = &chandef );

			if(!(status & 1)){
#ifdef DEBUG
				printf("DPset: send to display_name failed\n");
#endif
			} 
		    }
		}
		else{
#ifdef DEBUG
			printf("DPset: DPadd_vw_name_dir failed\n");
#endif
			status = OM_S_SUCCESS;
			storage = FALSE;
		}
                break;

            case FONT_OS_PTR :
                storage = (list->num_bytes == 4);
                if (storage)
                 {
                  ME.IGEgragad->gragad.fnt_os_ptr = 
                        (struct DPfnt_os_tbl *) list->var_ptr;
                 }
                break;

            case GRAGAD_FLAGS :   
                *(list->bytes_returned) = sizeof (IGRint) * 2;
                storage = (list->num_bytes == *list->bytes_returned);
                if (storage)
                 {
		   /*   The first integer in the array indicates
			the flags that one wishes to effect or change.
			The second integer in array indicates whether
			each of the "above" flags is to be on or off.  */
        	   temp_int = (IGRint *)list->var_ptr;		    
        	   temp_flag = ME.IGEgragad->gragad.flags & ~ *temp_int++;
		   /*   The above statement cuts off all flags that are to be
			effected.  Next the flags that are to be set
			are set with the or.				*/
		   ME.IGEgragad->gragad.flags = temp_flag | *temp_int;
                 }                         
                break;

            case GRID_PER_REF_X :         
                *(list->bytes_returned) = sizeof (ME.IGEgragad->gragad.grid_per_ref_x);
                storage = (list->num_bytes == *list->bytes_returned);
                if (storage)
                 {
                    ME.IGEgragad->gragad.grid_per_ref_x = *( (IGRlong *)list->var_ptr);
                 }                         
                break;
            case GRID_PER_REF_Y :
                *(list->bytes_returned) = sizeof (ME.IGEgragad->gragad.grid_per_ref_y);
                storage = (list->num_bytes == *list->bytes_returned);
                if (storage)
                 {
                    ME.IGEgragad->gragad.grid_per_ref_y = *( (IGRlong *)list->var_ptr);
                 }                         
                break;
            case  UOR_PER_REF_X :         
                *(list->bytes_returned) = sizeof (ME.IGEgragad->gragad.uor_per_ref_x);
                storage = (list->num_bytes == *list->bytes_returned);
                if (storage)
                 {
                    ME.IGEgragad->gragad.uor_per_ref_x = *( (IGRdouble *)list->var_ptr);
                 }                         
                break;
            case  UOR_PER_REF_Y :
                *(list->bytes_returned) = sizeof (ME.IGEgragad->gragad.uor_per_ref_y);
                storage = (list->num_bytes == *list->bytes_returned);
                if (storage)
                 {
                    ME.IGEgragad->gragad.uor_per_ref_y = *( (IGRdouble *)list->var_ptr);
                 }                         
                break;

	    case LEVELS:
/* need to make sure the active level is not turned off? */

                *(list->bytes_returned) = 
			sizeof (IGRint) * ((DP_NUM_OF_LEVELS -1)/32 +1);
                storage = (list->num_bytes <= *list->bytes_returned);
                if (storage)
                 {
                  OM_BLOCK_MOVE( list->var_ptr,
				 ME.IGEgragad->gragad.levels,
                                 *list->bytes_returned);
                 }                         
                break;

            case VIEW_ORIGIN :  

                *(list->bytes_returned) = sizeof (ME.IGEgragad->gragad.origin);
                storage = (list->num_bytes == *list->bytes_returned);
                if (storage)
                 {
                  OM_BLOCK_MOVE( list->var_ptr,
                                 ME.IGEgragad->gragad.origin,
                                 *list->bytes_returned);

                 }  
                break;

            case VIEW_ROTATION :  

                *(list->bytes_returned) = sizeof (IGRdouble) *16;
                storage = (list->num_bytes == *list->bytes_returned);
                if (storage)
                 {
                  OM_BLOCK_MOVE( list->var_ptr,
                                 ME.IGEgragad->gragad.rotation,
                                 *list->bytes_returned);
                 }  
                break;
/*
            case POST_ROTATION :  

                *(list->bytes_returned) = sizeof (IGRdouble) *16;
                storage = (list->num_bytes == *list->bytes_returned);
                if (storage)
                 {
                  OM_BLOCK_MOVE( list->var_ptr,
                                 ME.IGEgragad->gragad.post_rotation,
                                 *list->bytes_returned);
                 }  
                break;
*/
            case VW_VOLUME :       
                num_bytes = (sizeof (IGRdouble) * 6);
                storage = (list->num_bytes == num_bytes);
                if (storage)
                 {
                    OM_BLOCK_MOVE(list->var_ptr,
				 ME.IGEgragad->gragad.vw_volume,
                                 num_bytes);
                 }  /* close for if storage */
                break;

            case ACT_Z :
                storage = (list->num_bytes == sizeof( ME.IGEgragad->gragad.act_z));
                if (storage)
                 {
                  ME.IGEgragad->gragad.act_z = *( (IGRdouble *)list->var_ptr);
                  *list->bytes_returned = sizeof (ME.IGEgragad->gragad.act_z);
                 }
                break;

            case WLD_ACT_Z_PNT :
                storage = (list->num_bytes >= sizeof( ME.IGEgragad->gragad.act_z));
                if (storage)
                 {
			entered_z = (IGRdouble *)list->var_ptr;
    	    		num_points = 1;
		    	if ( ME.IGEgragad->gragad.flags & IS_PERSP)
		    	{
				b_sts = dp$cal_wldvw_mtx(msg=msg,
						in_flags = DPLEFT_VIEW,
						origin = ME.IGEgragad->gragad.eye_pt,
						rotation = (IGRdouble *)ME.IGEgragad->gragad.rotation,
						wldvw_mtx = (IGRdouble *)wld_to_view);
				if (!b_sts)
				{
#ifdef DEBUG
					printf("error in wld mtx");
#endif
		        	}
		    	}
		    	else
		    	{
	                  	OM_BLOCK_MOVE( ME.IGEgragad->gragad.wld_to_view,
                                	wld_to_view,sizeof(IGRdouble)*16);
		    	}
    	    		MAptsxform(msg, &num_points, (IGRdouble *)wld_to_view, 
					entered_z, ex_zpt);

			if(ex_zpt[2] >= ME.IGEgragad->gragad.vw_volume[2] && ex_zpt[2] <=  ME.IGEgragad->gragad.vw_volume[5])
			{
		  	    *list->bytes_returned = sizeof (ME.IGEgragad->gragad.act_z);			
                  	    ME.IGEgragad->gragad.act_z = ex_zpt[2];
			}
			else
			{
                  	    *list->bytes_returned = 0;
			    z_array[0] = ex_zpt[2];
			    z_array[1] = ME.IGEgragad->gragad.vw_volume[2];
			    z_array[2] = ME.IGEgragad->gragad.vw_volume[5];
			
                  	    OM_BLOCK_MOVE( z_array, list->var_ptr,
                                sizeof(IGRdouble)*3 );
                 	}

	    		ME.IGEgragad->gragad.act_z = ex_zpt[2];	
                  ME.IGEgragad->gragad.act_z = *( (IGRdouble *)list->var_ptr);
                  *list->bytes_returned = sizeof (ME.IGEgragad->gragad.act_z);

                 } /* close for if storage */
                break;

            case WLD_ACT_Z_VAL :
                storage = (list->num_bytes >= sizeof( ME.IGEgragad->gragad.act_z));
                if (storage)
                 {
		    entered_z = (IGRdouble *)list->var_ptr;
		    	if ( ME.IGEgragad->gragad.flags & IS_PERSP)
		    	{
				b_sts = dp$cal_wldvw_mtx(msg=msg,
						in_flags = DPLEFT_VIEW,
						origin = ME.IGEgragad->gragad.eye_pt,
						rotation = (IGRdouble *)ME.IGEgragad->gragad.rotation,
						wldvw_mtx = (IGRdouble *)wld_to_view);
				if (!b_sts)
				{
#ifdef DEBUG
					printf("error in wld mtx");
#endif
		        	}
		    	}
		    	else
		    	{
	                  	OM_BLOCK_MOVE( ME.IGEgragad->gragad.wld_to_view,
                                	wld_to_view,sizeof(IGRdouble)*16);
		    	}
		    DPset_zdep(msg, 0, (IGRdouble *)ME.IGEgragad->gragad.rotation,
				(IGRdouble *)wld_to_view, (IGRdouble *)&entered_z[2], 1,
				&ME.IGEgragad->gragad.act_z);
                 } /* close for if storage */
                break;
#ifndef IDRAW
            case CONSTRUCT_PLANE:

                *(list->bytes_returned) = sizeof (IGRdouble) *16;
                storage = (list->num_bytes == *list->bytes_returned);
                if (storage)
                 {
                  OM_BLOCK_MOVE( list->var_ptr,
                                 ME.IGEgragad->gragad.construct_plane,
                                 *list->bytes_returned);
                 }  
                break;
            case CONSTRUCT_PL_ORG:

                *(list->bytes_returned) = sizeof (IGRdouble) * 3;
                storage = (list->num_bytes == *list->bytes_returned);
                if (storage)
                 {
			p_doub = (IGRdouble *)list->var_ptr;
			ME.IGEgragad->gragad.construct_plane[0][3] = *p_doub;
			p_doub ++;
			ME.IGEgragad->gragad.construct_plane[1][3] = *p_doub;
			p_doub ++;
			ME.IGEgragad->gragad.construct_plane[2][3] = *p_doub;
                 }  
                break;
#endif /* IDRAW  */
            case GRAGAD_STRUCT:
                *(list->bytes_returned) = sizeof (struct DPgra_gad);
                storage = (list->num_bytes == *list->bytes_returned);
                if (storage)
                {
                    ME.IGEgragad->gragad = *((struct DPgra_gad *)list->var_ptr);
                }
                break;
            case GRAGAD_INST_STRUCT:
                *(list->bytes_returned) = sizeof (struct gragad_inst);
                storage = (list->num_bytes == *list->bytes_returned);
                if (storage)
                {
                    gragad_inst = (struct gragad_inst *)list->var_ptr;
                    ME.IGEgadget->win_no = gragad_inst->win_no;
                    ME.IGEgadget->min_x_dep = gragad_inst->min_x_dep;
                    ME.IGEgadget->min_y_dep = gragad_inst->min_y_dep;
                    ME.IGEgadget->max_x_dep = gragad_inst->max_x_dep;
                    ME.IGEgadget->max_y_dep = gragad_inst->max_y_dep;

                    ME.IGEgadget->min_x_indep = gragad_inst->min_x_indep;
                    ME.IGEgadget->min_y_indep = gragad_inst->min_y_indep;
                    ME.IGEgadget->max_x_indep = gragad_inst->max_x_indep;
                    ME.IGEgadget->max_y_indep = gragad_inst->max_y_indep;

                    ME.IGEgragad->gragad = gragad_inst->gragad;
                }
                break;
	    case DISPLAY_MODE:
                storage = (list->num_bytes == sizeof( ME.IGEgragad->gragad.display_mode));
                if (storage)
                 {
                  ME.IGEgragad->gragad.display_mode = *( (IGRshort *)list->var_ptr);
                  *list->bytes_returned = sizeof (ME.IGEgragad->gragad.display_mode);
                 }
                break;
	
	    case GPIPE_ID:
                storage = (list->num_bytes == sizeof( ME.IGEgragad->gragad.gpipe_id));
                if (storage)
                 {
                  ME.IGEgragad->gragad.gpipe_id = *( (IGRint *)list->var_ptr);
                  *list->bytes_returned = sizeof (ME.IGEgragad->gragad.gpipe_id);
                 }
                break;
#ifndef IDRAW
            case VPN :  

                *(list->bytes_returned) = sizeof (ME.IGEgragad->gragad.vpn);
                storage = (list->num_bytes == *list->bytes_returned);
                if (storage)
                 {
                  OM_BLOCK_MOVE( list->var_ptr,
                                 ME.IGEgragad->gragad.vpn,
                                 *list->bytes_returned);

                 }  
                break;
	    case VUP :
                *(list->bytes_returned) = sizeof (ME.IGEgragad->gragad.vup);
                storage = (list->num_bytes == *list->bytes_returned);
                if (storage)
                 {
                  OM_BLOCK_MOVE( list->var_ptr,
                                 ME.IGEgragad->gragad.vup,
                                 *list->bytes_returned);

                 }  
                break;
			
	    case VRP :
                *(list->bytes_returned) = sizeof (ME.IGEgragad->gragad.vrp);
                storage = (list->num_bytes == *list->bytes_returned);
                if (storage)
                 {
                  OM_BLOCK_MOVE( list->var_ptr,
                                 ME.IGEgragad->gragad.vrp,
                                 *list->bytes_returned);

                 }  
                break;
	
	    case COI: 
                *(list->bytes_returned) = sizeof (ME.IGEgragad->gragad.coi);
                storage = (list->num_bytes == *list->bytes_returned);
                if (storage)
                 {
                  OM_BLOCK_MOVE( list->var_ptr,
                                 ME.IGEgragad->gragad.coi,
                                 *list->bytes_returned);

                 }  
                break;
	
	    case EYE_PT :
                *(list->bytes_returned) = sizeof (ME.IGEgragad->gragad.eye_pt);
                storage = (list->num_bytes == *list->bytes_returned);
                if (storage)
                 {
                  OM_BLOCK_MOVE( list->var_ptr,
                                 ME.IGEgragad->gragad.eye_pt,
                                 *list->bytes_returned);

                 }  
                break;
	
            case VIEW_ANGLE:  

                *(list->bytes_returned) = sizeof (ME.IGEgragad->gragad.vw_angle);
                storage = (list->num_bytes == *list->bytes_returned);
                if (storage)
                 {
                  OM_BLOCK_MOVE( list->var_ptr,
                                 &ME.IGEgragad->gragad.vw_angle,
                                 *list->bytes_returned);

                 }  
                break;
#endif /* IDRAW */

            default :
                storage = FALSE;
                break;
            }  /* close for switch */

        if (storage == FALSE)
         {
           *which_error = list->var;
         }
     }    /* close for "for"  */

     if (status == OM_S_SUCCESS)
     {
     	*msg = (storage) ? MSSUCC : MSFAIL;
     	status = (storage) ? OM_S_SUCCESS : OM_E_ABORT;
     }

     return (status);

 }   /* close for set */


end implementation IGEgragad;
