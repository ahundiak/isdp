/* $Id $  */
/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:       vds/emsfixes/grnuc/GRrflocate.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log $
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *      12/21/00        Rama Rao        Added VDloc_thru_ref check.
 * -------------------------------------------------------------------*/

/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
	GRlocate - locate graphics object

Synopsis

	GRlocate(cvl,range_key)

	struct GRlc_cvl *cvl 
	OM_p_KEY_DESC range_key)

Description

	This method will check to see if the user requested to 
	locate the reference file objects and/or the reference file
	header.  A check will be done to see if the object passes
	the locate criteria check.  If it does, the message is
	passed on to the objects in the reference file.  If none
	of the objects in the file is accepted and the user requested
	to locate the header object, the header is then processed.
	The  owners, if any, are notified the header is being
	located.  Depending on the results of the call to the owners,
	the action handler is called.

Diagnostics

	This method returns in the cvl structure message
	the following return codes:

	MSSUCC - successful completion
	MSFAIL - error occurred
Notes
	None

History
	MAS	08/27/86:	Design Date
        mrm     02/06/91        always return either OM_I_STOP_SENDING or
                                OM_S_SUCCESS to avoid problems with
                                premature termination of the rtree pass
                                during locate
        gang    01/02/93        modified the locate method to locate the
                                reference file by its components not by the
                                range ( WYSIWYG locate ).

        Satya   08/31/94        Sending transformed view_range instead of
			        me->vw_volume for findrefobj function. 
				This is for the PDD/CVE problems -- 
			        TR# 119420391

	rmn	11/01/94	Commented out the GRfindrefobj code within
				ifdef NOTNEEDED - to reduce locate time.

\*/
	
class implementation GRreffile;

#include "grimport.h"
#include "msdef.h"
#include "refpriv.h"
#include "madef.h"
#include "lcdef.h"
#include "godef.h"
#include "grerr.h"
#include "refdef.h"
#include "gocmacros.h"
#include "dpmacros.h"
#include "bserr.h"
#include "OMmacros.h"

from GRcmpowner import GRlocate_owner;

extern IGRboolean GRpassrange();
extern IGRboolean GRexpansion_valid();

%safe
static IGRint	VDloc_thru_ref = 1;
%endsafe

VDrmLocThruRef()
{
   VDloc_thru_ref = 0 ;
}

VDresetLocThruRef()
{
   VDloc_thru_ref = 1 ;
}

IGRint	VDgetLocThruRef()
{
   return VDloc_thru_ref;
}

method GRlocate(struct GRlc_cvl *cvl; OM_p_KEY_DESC range_key)
{
	IGRboolean attachment;		/* flag to locate attachment	*/
	IGRboolean objects;		/* flag to locate objects	*/


	IGRlong OMmsg;			/* OM return code		*/
	IGRlong msg1;			/* local message		*/


	IGRushort	osnum;
	IGRint	locate_properties,
		owner_elig,
		comp_elig;

      	IGRint	dimension,
		path_position;
/*
        IGRint  obj_count;
*/

        struct GRlc_path *path_ptr;
 	OM_S_CHANSELECT  chandef;
		
	OMmsg = OM_S_SUCCESS;		/* initialize return codes	*/
	cvl->msg = MSSUCC;

#ifdef DEBUG
    printf("GRrflocate : my_id = %d, os = %d\n", my_id, OM_Gw_current_OS );
#endif

	if( !VDloc_thru_ref )   return OM_S_SUCCESS;

      	if( !GRexpansion_valid() )
	{
	    goto wrapup;
	}

	/* check to see if the reference file object is locatable
	 * for the command issueing the locate request.
	 */

	locate_properties = cvl->attributes.obj_attr.properties;

#ifdef DEBUG
	printf("locate properties = %X\n", 
	           locate_properties);
	printf("my properties = %X\n", 
	           me->properties);
	printf("locate owner properties = %x\n", 
	           cvl->attributes.obj_attr.owner_action);
#endif

	if (cvl->attributes.obj_attr.owner_action & LC_NO_REF_HEADER)
	{
	    attachment = FALSE;
	}
	else
	{
	    attachment = TRUE;
	}
	if ((cvl->attributes.obj_attr.owner_action & LC_REF_OBJECTS)==
	    LC_REF_OBJECTS)
	{
	    objects = TRUE;
	}
	else
	{
	    objects = FALSE;
	}	

	GRloccheck(&msg1,&cvl->module.md_env.matrix_type,
		cvl->module.md_env.matrix,&me->properties,
		&locate_properties,&me->level,cvl->levels,&my_id);

	if (msg1 == GRLEVEL_OFF)	/*level off; terminate		*/
	{
	    attachment = FALSE;
	    objects = FALSE;
	}
	else if ( ! (1 & msg1))
        {				/* check further 		*/
	    /* If the attachment failed due to displayable or locatable
	     * properties then the objects in the file also fail.
	     * If the attachment failed due to the other properties 
	     * checks send to the reference file objects anyway.
	     * Verify the level first.
	     */

	    attachment = FALSE;

  	    if (! DPlevel_check(me->level,cvl->levels))
	    {
	        objects = FALSE;
	    }

	    if (objects)
	    {
		/* If user requested displayable only or locatable 
		 * only and the GRreffile object fails the check,
		 * the objects in the file also fail.
		 */

	        if (!(me->properties & GRIS_DISPLAYABLE))
		{
		    if ((locate_properties & LC_DP_ONLY) ==
		        (locate_properties & LC_DP_INVIS))
		    {
		 	objects = FALSE;
		    }
		}
	
		if (objects && (!(me->properties & GRIS_LOCATABLE)))
		{
		    if ((locate_properties & LC_LC_ONLY) ==
		        (locate_properties & LC_LC_NONLC))
		    {
		 	objects = FALSE;
		    }
		}
	    }		
	}
	if (objects)
	{
	    /* If the user has requested to locate the objects
	     * in the reference file, a check must be done on
	     * the read/write request to see if the file is
	     * opened with the proper access privilege.
	     */

	    dimension = om$dimension_of(varray=me->filename);
	    if (dimension)		/* the file appears to be opened*/
	    {
		OMmsg = om$os_name_to_number(osname = me->osname,
			p_osnum = &osnum);
#ifdef DEBUG
printf("osnum = %d\n",osnum);
#endif
		if (!(OMmsg & 1))
		{
		    objects = FALSE;
		    OMmsg = OM_S_SUCCESS;
		}
		else
		{  
		    /* if the command requested to locate write
		     * only objects and did not request to locate
		     * both objects check to see if I am read only
		     * and do not allow reference file objects to be
		     * located.
		     */

		    if ((locate_properties & LC_WRITE_ONLY) &&
			((locate_properties & LC_RW) != LC_RW))
		    {
			if (me->ref_properties & GRRF_IS_READ_ONLY)
			{
			    objects = FALSE;
			}
		    }
	    	}
	    }
	    else			/* file is not yet opened	*/
	    {
		objects = FALSE;
	    }
	}
#ifdef NOTNEEDED
/* 
 * rmn - Need not check for the number of objects in reference files
 * before doing the actual locate
 * It is a very time consuming process
 */
        if(cvl->attributes.type != GR_nam_loc)
        {
        if(attachment || objects)
         {
                IGRdouble           d, view_range[6];
                IGRmatrix           ref_to_view_mx;
                IGRint              num_pts = 2;

                                /* let objects in reference file
                                 * be located
                                 */

                /*
                 * Transform me->range from reference file to the view
                 * coordinates and use that range rather than the view volume
                 * range (me->vw_volume) which was sent to GRlocref_objects
                 * previously. This is necessary because modification to
                 * the clipping polygon doesn't update the view volume.
                 */

                /* Get the xformation from ref world to view */
                MAwclsmx (&msg1,
                          me->vw_origin,
                          me->vw_rotation,
                          ref_to_view_mx);

                /* Transform the range to view coordinates */
                MAptsxform (&msg1,
                            &num_pts,
                            ref_to_view_mx,
                            me->range,
                            view_range);

                /* Put range in (lowx,lowy,lowz)-(highx,highy,highz) format */
                if (view_range[0] > view_range[3])
                {
                    d = view_range[0];
                    view_range[0] = view_range[3];
                    view_range[3] = d;
                }

                if (view_range[1] > view_range[4])
                {
                    d = view_range[1];
                    view_range[1] = view_range[4];
                    view_range[4] = d;
                }

                if (view_range[2] > view_range[5])
                {
                    d = view_range[2];
                    view_range[2] = view_range[5];
                    view_range[5] = d;
                }
 
	/** Sending transformed view_range instead of me->vw_volume to
	    take care of the PDD/CVE problems -- Satya -- TR# 119420391 **/

#ifdef DEBUG
    printf("GRrflocate : my_id = %d, os = %d : Calling GRfindref_objects\n", 
	my_id, OM_Gw_current_OS);
#endif
             obj_count = GRfindref_objects(&msg1,cvl,
                             &me->ref_properties,
                           me->dp_levels, &my_id,
                               &OM_Gw_current_OS,
                        me->master_to_ref_matrix,
                                   view_range,
                                 me->vw_rotation,
                                   me->vw_origin);
#ifdef DEBUG
    printf("GRrflocate : my_id = %d, os = %d, obj_count = %d\n ", 
	my_id, OM_Gw_current_OS, obj_count );
#endif
/***
             obj_count = GRfindref_objects(&msg1,cvl,
                             &me->ref_properties,
                           me->dp_levels, &my_id,
                               &OM_Gw_current_OS,
                        me->master_to_ref_matrix,
                                   me->vw_volume,
                                 me->vw_rotation,
                                   me->vw_origin);
***/

             if(obj_count == 0)
              {
                    attachment = FALSE;
                    objects  = FALSE;
              }
              if(cvl->act_parms == NULL)
              {
                  REFinit_count();
              }
              else
              if(strcmp(cvl->act_parms,"Finding_ref_objects") != 0)
              {
                  REFinit_count();
              }
          }
         }
#endif


	if (attachment || objects)	/* if either are valid,continue	*/
	{
    	    GRinit_path(&msg1,cvl,&my_id,&OM_Gw_current_OS,
			&path_ptr,&path_position);

    	    if ( 1 & msg1 )
    	    {
		path_ptr[path_position].object_info =  
		   ((attachment ? GRLOC_ATTACHMENT : 0) | 
		    (objects ? GRLOC_OBJECTS : 0));

		OMmsg = om$make_chanselect(p_chanselect = &chandef,
	 		channame = "GRconnector.to_owners");

		if (1 & OMmsg )
       		{
	 	    msg1 = GR_I_NO_RESPONSE;

	    	    OMmsg = om$send(
			msg = message GRcmpowner.GRlocate_owner
			    (&msg1,cvl,path_ptr,&path_position),
			p_chanselect = &chandef,
			from = 0,
			to = 0);
	    
	    	    if (msg1 == GR_I_NO_RESPONSE)
		    {
			/* the owner (if any) did not handle the message
		 	 */

			owner_elig = 0;
			comp_elig = 1;

			OMmsg = om$send(
		    	    msg = message GRgraphics.GRlocate_processing
		    		(&msg1,cvl,path_ptr,&path_position,
				 &owner_elig,&comp_elig),
		    	    targetid = my_id);
		    }			

		    if ( (1 & OMmsg) && (OMmsg != OM_I_STOP_SENDING))
		    {
			if (path_ptr[path_position].object_info
				& GRLOC_OBJECTS)
			{
                struct GRlc_path	saved_path;
                IGRdouble           d, view_range[6];
                IGRmatrix           ref_to_view_mx;
                IGRint              num_pts = 2;
                
				/* let objects in reference file 
				 * be located
 				 */

                /*
                 * Transform me->range from reference file to the view 
                 * coordinates and use that range rather than the view volume
                 * range (me->vw_volume) which was sent to GRlocref_objects
                 * previously. This is necessary because modification to
                 * the clipping polygon doesn't update the view volume.
                 */

                /* Get the xformation from ref world to view */
                MAwclsmx (&msg1, 
                          me->vw_origin, 
                          me->vw_rotation, 
                          ref_to_view_mx);
                
                /* Transform the range to view coordinates */
                MAptsxform (&msg1,
                            &num_pts,
                            ref_to_view_mx,
                            me->range,
                            view_range);
                
                /* Put range in (lowx,lowy,lowz)-(highx,highy,highz) format */
                if (view_range[0] > view_range[3])
                {
                    d = view_range[0];
                    view_range[0] = view_range[3];
                    view_range[3] = d;
                }
                
                if (view_range[1] > view_range[4])
                {
                    d = view_range[1];
                    view_range[1] = view_range[4];
                    view_range[4] = d;
                }
                
                if (view_range[2] > view_range[5])
                {
                    d = view_range[2];
                    view_range[2] = view_range[5];
                    view_range[5] = d;
                }
                
                saved_path=path_ptr[path_position];

 		/* print the filename being processed in status field */

	        dimension = om$dimension_of(varray=me->filename);
	        if (dimension)		
                {
                    IGRchar buf[256];

                    sprintf( buf, "Locating objs in %s", me->filename );  
		    UI_status( buf );
                }

                OMmsg = GRlocref_objects (&msg1,
                                          cvl,
                                          &me->ref_properties,
                                          me->dp_levels, 
                                          &my_id, 
                                          &OM_Gw_current_OS, 
                                          me->master_to_ref_matrix, 
                                          view_range,
                                          me->vw_rotation,
                                          me->vw_origin);
#ifdef DEBUG
    printf("GRrflocate : my_id = %d, os = %d, locating ref objects\n ", 
	my_id, OM_Gw_current_OS);
#endif

                path_ptr[path_position]=saved_path;
			}

	    		if (path_ptr[path_position].call_action_handler)
            {
			    if (OMmsg != OM_I_STOP_SENDING)
			    {
	    		        OMmsg = (*cvl->action_handler)
					( cvl->act_parms,
    	   				 &path_ptr[path_position].lc_info,
				 	cvl->locate_args,
				 	&path_ptr[path_position].action);
			    }
			}
		    }
		    GRlc_remove_path(path_ptr,&path_position);
		}
	    }
	}

wrapup:
        GR_NOTIFY_LISTENERS(cvl->msg,&OMmsg,GR_LOCATED);

        if (OMmsg != OM_I_STOP_SENDING) OMmsg = OM_S_SUCCESS;

        return(OMmsg);
}

end implementation GRreffile;
