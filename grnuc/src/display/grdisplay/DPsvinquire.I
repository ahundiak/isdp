/*----
%GP% CODE CLASSIFICATION                           
----
%HD%
 
	CLASS NAME:	GRvw
	METHOD NAME:	GRvwinqname
 
     	Abstract: This method returns the name of
		  the particular view.

-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------

-----
%EX%

     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     msg           IGRlong	 MSSUCC -- successful completion

     name	   * IGRchar     contains the views name

-----
%RL%

	RELATIONS REFERENCED:

-----
%NB%

     NOTES:
-----
%CH%
     CHANGE HISTORY:

	MAS  8/13/86  : Creation date.
-----
%PD%
--------------------------------------------------------------------
              P R O G R A M    D E S C R I P T I O N
--------------------------------------------------------------------

----*/
/*EH*/

class implementation IGEsavedvw;

#include <string.h>
#include <stdio.h>

#include "grimport.h"
#include "OMmacros.h"
#include "dp.h"
#include "dperr.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "exmacros.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"

/* prototype files */
%safe
#include "DPsvinquire.h"
#include "DPaddvwname.h"
#include "DPgetsavvwid.h"

#include "maidmx.h"
#include "mamulmx.h"
%endsafe


#if defined(__STDC__) || defined(__cplusplus)
int DPsi_savvw_name( IGRlong           *msg,
                     IGRchar           inq0_set1,
                     IGRlong           *which_error,
                     struct  var_list  *list,
	             GRspacenum        osnum,
	             IGRchar           *savedvw_name )
#else
int DPsi_savvw_name( msg, inq0_set1, which_error, list, osnum, savedvw_name)

        IGRlong *msg;           /* return message status                */

        IGRchar inq0_set1;    /* indicates if you wish to set a value in
                                the view's instance data or if you wish
                                to inquire a value. (set = 1 inquire = 0) */

        IGRlong *which_error;   /* if an error occurs with one of the 
                                variables which_error will point to the
                                one with the error                      */

        struct  var_list *list; /* list of variables to get             */

	GRspacenum osnum;
	
	IGRchar *savedvw_name;
#endif

{

IGRlong status = OM_S_SUCCESS;
IGRlong number_ids;
struct GRid savvw_GRids[40];
IGRshort i;

    *msg = MSSUCC;	

    dp$get_saved_vw_id (msg = msg,
			osnum = osnum,
			name = savedvw_name,
			numberofids = &number_ids,
			found_GRids = savvw_GRids);
    if (*msg == DPVWSMNODEF || *msg == DPVWSNODEF)
    {
	status = OM_E_ABORT;
	goto fini;
    }
    if (number_ids == 0 )
    {
	status = OM_E_ABORT;
	*msg = DPNOOBJECTS;
    }
    else
    {
	if (inq0_set1)
	{
	    for(i=0; i < number_ids; i++)	    
	    {
		status = om$send ( msg = message IGEsavedvw.DPset
			 (msg, which_error, list),
  		       	  senderid = NULL_OBJID,
    		     	  targetid = savvw_GRids[i].objid,
      		   	  targetos = savvw_GRids[i].osnum);
        	if ( !(status & 1))
        	{
#ifdef DEBUG
       		    printf("\nin DPsi_savvw_name  DPset failed\n");
        	    om$report_error(sts = status);
#endif
        	}
	    } /* close for for */
	} /* close for if set */
	else
	{
	    if (number_ids == 1)
	    {
		status = om$send ( msg = message IGEsavedvw.DPinquire
			 (msg, which_error, list),
  		       	  senderid = NULL_OBJID,
    		     	  targetid = savvw_GRids[0].objid,
      		   	  targetos = savvw_GRids[0].osnum);
        	if ( !(status & 1))
        	{
#ifdef DEBUG
      		    printf("\nin DPsi_savvw_name DPinquire failed\n");
        	    om$report_error(sts = status);
#endif
        	}
    	   }
    	   else
    	   {
		status = OM_E_ABORT;
		*msg = DPAMBIGUOUS;
  	   }
      } /* close for else ---inquire */
   } /*  close for else -- number_ids == 0  */
   fini: 
	;
    return (status);
}

#if defined(__STDC__) || defined(__cplusplus)
int DPsetinqsavvw ( IGRlong           *msg,
                    IGRchar           inq0_set1,
                    IGRlong           *which_error,
                    struct  var_list  *list,
                    GRspacenum        osnum,
                    GRobjid           vw_objid )
#else 
int DPsetinqsavvw (msg, inq0_set1, which_error, list, osnum, vw_objid)


        IGRlong *msg;           /* return message status                */

        IGRchar inq0_set1;    /* indicates if you wish to set a value in
                                the view's instance data or if you wish
                                to inquire a value. (set = 1 inquire = 0) */

        IGRlong *which_error;   /* if an error occurs with one of the 
                                variables which_error will point to the
                                one with the error                      */

        struct  var_list *list; /* list of variables to get             */

	GRspacenum osnum;

	GRobjid vw_objid;
#endif

{

IGRlong status = OM_S_SUCCESS;
GRspacenum mod_osnum;
GRobjid mod_objid;

*msg = MSSUCC;

    if (osnum == 0xFFFF ) 
    {
	ex$get_cur_mod( id=&mod_objid, osnum=&mod_osnum);
    }
    else
    {
	mod_osnum = osnum;
    }

if (inq0_set1)
{
	status = om$send ( msg = message IGEsavedvw.DPset
		 (msg, which_error, list),
         	  senderid = NULL_OBJID,
         	  targetid = vw_objid,
         	  targetos = mod_osnum);
 }
else
{
	status = om$send ( msg = message IGEsavedvw.DPinquire
		 (msg, which_error, list),
         	  senderid = NULL_OBJID,
         	  targetid = vw_objid,
         	  targetos = mod_osnum);
}
 return(status);
}

method DPinquire (IGRlong *msg; IGRlong *which_error; struct var_list *list )

{

IGRlong status = OM_S_SUCCESS;
IGRboolean storage;
IGRdouble rotate[4][4];
IGRdouble trans_mtx[4][4];
IGRshort four = 4;

struct DPsavevw *save_vw;
IGRlong size_mv;
	IGRchar full_name[DI_PATH_MAX];
	IGRchar name[DI_PATH_MAX];

*msg = MSSUCC;

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
		    (*(IGRint *)list->var_ptr) = TYPE_SAVVW;
		}
		break;

	    case SAV_VW_NAME :
	    case GRAGAD_NAME :
		status = di$untranslate (objname = full_name,
			path = GRDP_SAVVWS,
				objid = my_id,
				osnum = OM_Gw_current_OS);
		if (!(status &1))
		{
			#ifdef DEBUG
			di$report_error(sts = status, comment = "untranslate failed in DPsvinquire");
			#endif
	 	   	*which_error = list->var;
			return (status);
		}
		status = di$split(pathname=full_name,
			name=name);
		if (!(status &1))
		{
			#ifdef DEBUG
			di$report_error(sts = status, comment = "split failed in DPsvinquire");
			#endif
 	   		*which_error = list->var;
			return(status);
		}

                *(list->bytes_returned) = strlen(name) + 1;
                storage = (list->num_bytes >= *list->bytes_returned);
                 if (!(storage))
		{
                    *(list->bytes_returned) = list->num_bytes;
		    name[list->num_bytes - 1] = '\0';

		}
                  OM_BLOCK_MOVE( name,
                                 list->var_ptr,
                                 *list->bytes_returned);
                break;

	    case SIZE_DESCRIPT:
		*(list->bytes_returned) = sizeof(IGRint);
		if(list->num_bytes >= *list->bytes_returned)
		{
		    (*(IGRint *)list->var_ptr) = om$dimension_of(varray = me^^IGEsavedvw.descript);
		}
		break;

	    case DESCRIPT:
		*(list->bytes_returned) = om$dimension_of(varray = me^^IGEsavedvw.descript);
		if(list->num_bytes >= *list->bytes_returned)
		{
		    OM_BLOCK_MOVE(me^^IGEsavedvw.descript, 
                                 list->var_ptr,
                                 *list->bytes_returned);
		}
		else
		{
		    *list->bytes_returned = list->num_bytes;
		    OM_BLOCK_MOVE(me^^IGEsavedvw.descript, 
                                 list->var_ptr,
                                 (*list->bytes_returned - 1 ) );
		    (*(IGRchar *)list->var_ptr)[list->bytes_returned - 1] = '\0';
		}
		break;
		
	    case SAV_VW_FLAGS :
            case GRAGAD_FLAGS :
		*(list->bytes_returned) = sizeof (me->gragad.flags);
		storage = (list->num_bytes >= *list->bytes_returned);
		if (storage)
		 {
		  OM_BLOCK_MOVE( &me->gragad.flags,
                                 list->var_ptr,
                                 *list->bytes_returned);
		 }  
		break;

	    case GRID_PER_REF_X :	  
		*(list->bytes_returned) = sizeof (me->gragad.grid_per_ref_x);
		storage = (list->num_bytes >= *list->bytes_returned);
		if (storage)
		 {

		  *( (IGRlong *)list->var_ptr) = me->gragad.grid_per_ref_x;

		 }  			   
		break;

	    case GRID_PER_REF_Y :
		*(list->bytes_returned) = sizeof (me->gragad.grid_per_ref_y);
		storage = (list->num_bytes >= *list->bytes_returned);
		if (storage)
		 {
		  *( (IGRlong *)list->var_ptr) = me->gragad.grid_per_ref_y;
		 }  			   
		break;


	/* put in min_x_indep --- max_y_indep */


	    case  UOR_PER_REF_X :	  
		*(list->bytes_returned) = sizeof (me->gragad.uor_per_ref_x);
		storage = (list->num_bytes >= *list->bytes_returned);
		if (storage)
		 {
		  *( (IGRdouble *)list->var_ptr) = me->gragad.uor_per_ref_x;
		 }  			   
		break;

	    case  UOR_PER_REF_Y :
		*(list->bytes_returned) = sizeof (me->gragad.uor_per_ref_y);
		storage = (list->num_bytes >= *list->bytes_returned);
		if (storage)
		 {
		  *( (IGRdouble *)list->var_ptr) = me->gragad.uor_per_ref_y;
		 }  			   
		break;

	    case VIEW_ORIGIN :  

		*(list->bytes_returned) = sizeof(me->gragad.origin);
		storage = (list->num_bytes >= *list->bytes_returned);
		if (storage)
		 {
#ifndef IDRAW

			if (!(ME.IGEgragad->gragad.flags & IS_PERSP))
#endif
			{
		  	OM_BLOCK_MOVE( me->gragad.origin,
                                 list->var_ptr,
                                 *list->bytes_returned);
			}
#ifndef IDRAW
			else
			{
	                  OM_BLOCK_MOVE( me->gragad.eye_pt,
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
		    if (me->gragad.flags & VALID_ALT_INV &&
me->gragad.flags & CONST_PL_DEF)
		    {
	  	    OM_BLOCK_MOVE( me->gragad.construct_plane,
                                     rotate,
                                     *list->bytes_returned);
		    rotate[3][0] = 0;
		    rotate[3][1] = 0;
		    rotate[3][2] = 0;
	  	    OM_BLOCK_MOVE( rotate,
                                     list->var_ptr,
                                     *list->bytes_returned);
		    }
		    else
		    {
		  	OM_BLOCK_MOVE( me->gragad.rotation,
                                         list->var_ptr,
                                         *list->bytes_returned);
		    }
		 } /* close for if storage */ 
		break;

	    case WLD_TO_VIEW:

                *(list->bytes_returned) = sizeof (IGRdouble) *16;
                storage = (list->num_bytes >= *list->bytes_returned);
                if (storage)
                 {

		  MAidmx(msg, (IGRdouble *)trans_mtx);
		  trans_mtx[0][3] = - me->gragad.origin[0];
		  trans_mtx[1][3] = - me->gragad.origin[1];
		  trans_mtx[2][3] = - me->gragad.origin[2];

		  MAmulmx(msg, &four, &four, &four, (IGRdouble *)me->gragad.rotation,
			  (IGRdouble *)trans_mtx, (IGRdouble *)list->var_ptr);

                 }  
                break;

	    case VW_ROT_NO_CON :

		*(list->bytes_returned) = sizeof (IGRdouble) *16;
		storage = (list->num_bytes >= *list->bytes_returned);
		if (storage)
		 {
		  	OM_BLOCK_MOVE( me->gragad.rotation,
                                         list->var_ptr,
                                         *list->bytes_returned);
		 } /* close for if storage */ 
		break;

	    case VW_VOLUME :       
		*(list->bytes_returned) = (sizeof (IGRdouble) * 6);
		storage = (list->num_bytes >= *list->bytes_returned);
		if (storage)
		 {
		  OM_BLOCK_MOVE( me->gragad.vw_volume,
                                 list->var_ptr,
                                 *list->bytes_returned);
		 }  
		break;

	    case ACT_Z :
		storage = (list->num_bytes >= sizeof( me->gragad.act_z));
		if (storage)
		 {
		  *( (IGRdouble *)list->var_ptr) = me->gragad.act_z;
		  *list->bytes_returned = sizeof (me->gragad.act_z);
		 }
		break;

	    case CONSTRUCT_PLANE:

		*(list->bytes_returned) = sizeof (IGRdouble) *16;
		storage = (list->num_bytes >= *list->bytes_returned);
		if (storage)
		 {
		  OM_BLOCK_MOVE( me->gragad.construct_plane,
                                 list->var_ptr,
                                 *list->bytes_returned);
		 }  
		break;

	    case SAV_VW_STRUCT:
		*(list->bytes_returned) = sizeof (struct DPsavevw);
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
     return (status);

}
method DPset (IGRlong *msg;IGRlong *which_error; struct var_list *list )

{

        IGRboolean storage;
        IGRint *temp_int;
	IGRint temp_flag;
	IGRlong status;	

     	*msg = MSSUCC;
     	status = OM_S_SUCCESS;

        for ( storage = TRUE;
                (list->var != END_PARAM) && (storage == TRUE); list++)
         {
            switch (list->var)
             {

            case SAV_VW_NAME :
            case GRAGAD_NAME :
                 storage = TRUE;
		 /* later I need to check for truncation of name in add name */
                 *(list->bytes_returned) = list->num_bytes;
		    status = DPadd_vw_name_dir(msg,DPCHG_VW_NAME,OM_Gw_current_OS,
					my_id,GRDP_SAVEDVIEWS,
					GRDP_GRSAVEDVIEWS,list->var_ptr);
		    if (!(status & 1))
		    {
           		*which_error = list->var;
			*msg = DPDUPLICNM;
			return (status);
		    }
                 break;
	    case DESCRIPT:
                 storage = TRUE;
                 *(list->bytes_returned) = strlen(list->var_ptr)+1;
		 om$vla_set_dimension (varray = me^^IGEsavedvw.descript, 
					size = *(list->bytes_returned));
                  OM_BLOCK_MOVE( list->var_ptr,
				me^^IGEsavedvw.descript, 
                                *(list->bytes_returned) );
                 break;

            case SAV_VW_FLAGS :   
            case GRAGAD_FLAGS :
                *(list->bytes_returned) = sizeof (IGRint) * 2;
                storage = (list->num_bytes == *list->bytes_returned);
                if (storage)
                 {
        	   temp_int = (IGRint *)list->var_ptr;		    
        	   temp_flag = me->gragad.flags & ~ *temp_int++;
		   me->gragad.flags = temp_flag | *temp_int;
                 }                         
                break;

/* later #defines for min_x_indep ... max_y_indep need to be added */

            case GRID_PER_REF_X :         
                *(list->bytes_returned) = sizeof (me->gragad.grid_per_ref_x);
                storage = (list->num_bytes <= *list->bytes_returned);
                if (storage)
                 {
                    me->gragad.grid_per_ref_x = *( (IGRlong *)list->var_ptr);
                 }                         
                break;
            case GRID_PER_REF_Y :
                *(list->bytes_returned) = sizeof (me->gragad.grid_per_ref_y);
                storage = (list->num_bytes <= *list->bytes_returned);
                if (storage)
                 {
                    me->gragad.grid_per_ref_y = *( (IGRlong *)list->var_ptr);
                 }                         
                break;
            case  UOR_PER_REF_X :         
                *(list->bytes_returned) = sizeof (me->gragad.uor_per_ref_x);
                storage = (list->num_bytes <= *list->bytes_returned);
                if (storage)
                 {
                    me->gragad.uor_per_ref_x = *( (IGRdouble *)list->var_ptr);
                 }                         
                break;
            case  UOR_PER_REF_Y :
                *(list->bytes_returned) = sizeof (me->gragad.uor_per_ref_y);
                storage = (list->num_bytes <= *list->bytes_returned);
                if (storage)
                 {
                    me->gragad.uor_per_ref_y = *( (IGRdouble *)list->var_ptr);
                 }                         
                break;
            case VIEW_ORIGIN :  

                *(list->bytes_returned) = sizeof(me->gragad.origin);
                storage = (list->num_bytes <= *list->bytes_returned);
                if (storage)
                 {
                  OM_BLOCK_MOVE( list->var_ptr,
                                 me->gragad.origin,
                                 *list->bytes_returned);

                 }  
                break;

            case VIEW_ROTATION :  

                *(list->bytes_returned) = sizeof (IGRdouble) *16;
                storage = (list->num_bytes <= *list->bytes_returned);
                if (storage)
                 {
                  OM_BLOCK_MOVE( list->var_ptr,
                                 me->gragad.rotation,
                                 *list->bytes_returned);
                 }  
                break;


            case VW_VOLUME :       
                *(list->bytes_returned) = (sizeof (IGRdouble) * 6);
                storage = (list->num_bytes <= *list->bytes_returned);
                if (storage)
                 {
                  OM_BLOCK_MOVE( list->var_ptr,
                                 me->gragad.vw_volume,
                                 *list->bytes_returned);
                 }  
                break;

            case ACT_Z :
                storage = (list->num_bytes <= sizeof( me->gragad.act_z));
                if (storage)
                 {
                  me->gragad.act_z = *( (IGRdouble *)list->var_ptr);
                  *list->bytes_returned = sizeof (me->gragad.act_z);
                 }
                break;
            case CONSTRUCT_PLANE:

                *(list->bytes_returned) = sizeof (IGRdouble) *16;
                storage = (list->num_bytes <= *list->bytes_returned);
                if (storage)
                 {
                  OM_BLOCK_MOVE( list->var_ptr,
                                 me->gragad.construct_plane,
                                 *list->bytes_returned);
                 }  
                break;
/* put back in later

            case SAV_VW_STRUCT:
                *(list->bytes_returned) = sizeof (struct DPsavevw);
                storage = (list->num_bytes <= *list->bytes_returned);
                if (storage)
                {
                   me->gragad = *((struct DPsavevw *)list->var_ptr);
                }
                break;
*/
            default :
                storage = FALSE;
                break;
            }  /* close for switch */
        if (storage == FALSE)
         {
           *which_error = list->var;
         }
     }    /* close for "for"  */
     if (*msg == MSSUCC)
     {
     	*msg = (storage) ? MSSUCC : MSFAIL;
     }
     if (status == OM_S_SUCCESS)
     {
     	status = (storage) ? OM_S_SUCCESS : OM_E_ABORT;
     }
     return (status);

 }   /* close for set */


end implementation IGEsavedvw;
