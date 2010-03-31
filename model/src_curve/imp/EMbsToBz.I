/* ###################   APOGEE COMPILED   ################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME:	GRbspline	
     METHOD NAME:	EMbctobz	

     Abstract:	This method constructs bezier curves from a 
 		 given B-spline curve. The method returns a
	       	 list of objids corresponding to the bezier
		 curves being extracted. 

		If the method fails and new objects (if any)
 		 are constructed, they are deleted befoere 
		 exiting this method.  	
-----
%SC%    

-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   ------------------------------------
 *construct_list  GRvg_construct    list of construction variables

-----
%EX%
     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     *bz_objid	   GRobjid        pointer to an array of bezier curve
  				   objids.
				
     *nbzier	   IGRint	  no. of bezier curves constructed

     *msg	   IGRlong	  return code
				  - MSSUCC 	successful
				  - MSNOMEM	memory alloaction failed
				  - MSFAIL     any other failure 
-----
%MD%

     MODULES AND METHODS INVOKED:
     Modules:
		GRgetabsg
		BSalloccv
		BSfreecv
		BScvtobz
		om$malloc
		om$send
		om$report_error
		om$os_number_to_name
		om$construct
		om$dealloc
	
     Methods:
		GRclipto	
		GRdelete
-----
%RL%

     RELATIONS REFERENCED:
-----
%NB%

     NOTES:
		The memory allocated for an array of bezier curve
		objids (bz_objids) should be deallocated in
		the command object.

-----
%CH%

     CHANGE HISTORY:
		
		RC : 9/26/86  creation date
        rlw : 01/05/87 : Removed print statements
        dhm : 03/25/88 : added a local construct list to use
                         for constructing the objects so that
                         the pasted in construct list doesn't get
                         corrupted.
    Sudha  06/16/93     Modified for BSprototype ansification
-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------

----*/
/*EH*/

class implementation GRbspline;

#include "EMS.h"
# include "OMminimum.h"     /* for gocmacros.h  */
# include "OMlimits.h"
# include "OMerrordef.h"
# include "OMstackalloc.h"
# include "igrtypedef.h"     /* for gocmacros.h  */
# include "gocmacros.h"     /* GRgetabsg macro  */
# include "msdef.h" /* MS message codes */
# include "madef.h"
# include "godef.h"
# include "griodef.h"
# include "exdef.h"
# include "ex.h"
# include "madef.h"
# include "bsdefs.h"
# include "bserr.h"
# include "emsdef.h"
# include "emserr.h"
# include "EMSerrordef.h"
#include "bsfreecv.h"
#include "bscvtobz.h"
#include "bsalloccv.h"

method EMbctobz ( struct GRvg_construct *construct_list;
		  GRobjid **addr_bz_objid; IGRint *nbezier; IGRlong *msg )
					
{
	IGRchar	  classname[GRNAME_SIZE]; /* classname of bezier curve */
	IGRchar	  osname[OM_K_MAXOSNAME_LEN]; /* osname of bezier curve */
	IGRchar	  *cache_ptr; 		   /* abstract buffer pointer */
	
	IGRint	  new_objts_constructed = 0;
	
	IGRlong	  msg1;			/* return code */
	IGRlong	  i, j;			/* loop index  */
 	IGRlong   OMmsg;
	IGRlong	  nspans;		/* no. of spans ( including */
					/* degenerate spans )	    */
	IGRboolean  status;
	BSrc	    rc; 		/* B-spline function return code */

	GRobjid		*bz_objid;	
	
	struct	GRmd_env	*env;
	struct  IGRbsp_curve	*curve, **bezier_ptr;	
	struct  GRsymbology symbology;	
	struct  IGResbc         esbc_attr;
    struct  GRvg_construct	my_const_list;

	bz_objid = NULL;
	bezier_ptr = NULL;
	*msg = MSSUCC;
	OMmsg = OM_S_SUCCESS;
	env = construct_list->env_info;
	
	/*
	 * get the B-spline geometry in the abstract buffer
	 */
	
	GRgetabsg ( &msg1,
	            &(env->md_env.matrix_type),
	             env->md_env.matrix,
	            &cache_ptr,
	             i );
	
	if ( !( 1 & msg1 ) )
	{
		*msg = MSFAIL;
		goto wrapup;
	}
	
	curve = (struct IGRbsp_curve *) cache_ptr;
	
	nspans = curve->num_poles - curve->order + 1;
	
	/*
	 * allocate memory for an array containing pointers 
	 * to local buffer of bezier curves.
	 */
	
	bezier_ptr = (struct IGRbsp_curve **) OM_stack_alloc ( nspans * 
	               sizeof(struct IGRbsp_curve *) );
	
 	if ( bezier_ptr == NULL)
	{
		*msg = MSNOMEM;
		goto wrapup;
	}
	   	
	/*
   	 * allocate local buffers for bezier curves
 	 */
  
	for ( j = 0; j < nspans; j++ )
	{
	 	 BSalloccv ( curve->order,
		     	             curve->order,
     			             curve->rational,
         	               	     curve->num_boundaries,
                          	    &bezier_ptr[j],
 	                            &rc );

        	if (  rc != BSSUCC )
        	{
			*msg = MSNOMEM;
			goto wrapup;
        	}

		/*
		 * set the rational field of the curve as it may be
		 * messed up and will trouble during free
		 */
			
		bezier_ptr[j]->rational = curve->rational;
			
		/*
		 * intialize num_boundaries
		 */

		bezier_ptr[j]->num_boundaries = curve->num_boundaries;
	}

	/* 
	 * call B-spline math function to extract bezier curves
	 * from the given B-spline curve.
	 */
	
	status = BScvtobz ( &rc,
	                     curve,
		             nbezier,
			     bezier_ptr );
						
	if ( !(status) || ( rc != BSSUCC ) )
	{
		*msg = MSFAIL;
		goto wrapup;
	}
	
	/*
	 * allocate space for an array containg objids of
	 * bezier curves
	 */
	
	bz_objid = (GRobjid *) malloc(*nbezier * sizeof(GRobjid) );
	
	if ( bz_objid == NULL)
	{
		*msg = MSNOMEM;
		goto wrapup;
	}
	
	*addr_bz_objid = bz_objid;
	
	/*
	 * get classname of the new object
	 */
	
	OMmsg = om$send(mode = OM_e_wrt_object,
                    msg = message GRvg.GRclipto (&msg1,
                                                  classname),
                    senderid = my_id,
                    targetid = my_id);
	
	if ( !(1 & OMmsg) )
	{
		OMmsg = OM_E_ABORT;
		goto wrapup;
	}

	if ( !(1 & msg1) )
	{
		*msg = MSFAIL;
		goto wrapup;
	}

	/*
	 * get the symbology of the original object. The
	 * new objects should have the same symbology
	 */
	
	OMmsg = om$send(mode = OM_e_wrt_object,
                    msg = message GRvg.GRgetsymb( &msg1,
					          &symbology),
                    senderid = my_id,
                    targetid = my_id);

	if ( !(1 & OMmsg) )
	{
		OMmsg = OM_E_ABORT;
		goto wrapup;
	}

	if ( !(1 & msg1) )
	{
		*msg = MSFAIL;
		goto wrapup;
	}


	OMmsg = om$os_number_to_name(osnum = env->md_id.osnum,
                                 osname = osname );

	if ( !( 1 & OMmsg ) )
	{
		OMmsg = OM_E_ABORT;
		goto wrapup;
	}
	
    /* 
     * construct bezier curve objects
     */

    my_const_list.msg = &msg1;
    my_const_list.newflag = FALSE;
    my_const_list.env_info = env;
    my_const_list.level = symbology.level;
    my_const_list.properties = ME.GRgraphics->properties;
    my_const_list.properties &= ~GR_RIGID_RELATIONSHIP;
    my_const_list.display = &(symbology.display_attr);
    my_const_list.class_attr = NULL;
    my_const_list.name = NULL;
	for ( j = 0; j < (*nbezier); j++ )
	{
		my_const_list.geometry = (IGRchar *) bezier_ptr[j];

		OMmsg =  om$construct(osname = osname,
                              classname = classname,
                              p_objid = &bz_objid[j]);

		if ( !(1 & OMmsg) )
		{
			OMmsg = OM_E_ABORT;
			goto wrapup;
		}

		OMmsg = om$send(mode = OM_e_wrt_object,
                            msg = message GRvg.GRconstruct(&my_const_list),
                            senderid = my_id,
                            targetid = bz_objid[j],
                            targetos = env->md_id.osnum);
				
		if ( !(1 & OMmsg))		/* the construct failed	*/
		{
			OMmsg = OM_E_ABORT;
			goto wrapup;
		}

		if ( !(1 & *(my_const_list.msg)) )	/* the construct failed	*/
		{
			*msg = MSFAIL;
			goto wrapup;
		}
		
		++new_objts_constructed;
   }
	 
wrapup:

	  for ( j = 0; j < nspans; j++ )
	  {   
		if ( bezier_ptr[j] )
		{
			status = BSfreecv (&rc,
	                        bezier_ptr[j] );
	 
			if ( !(status) || ( rc != BSSUCC ) )
			{
				*msg = MSFAIL;
			}
		 }
	  }
	
	if (bezier_ptr) 
		 OM_stack_dealloc( bezier_ptr);

			
	/* 
	 * if the method fails and new objects (if any ) are
	 * constructed in the method, they have to be deleted
	 * before exiting this method.
	 */
	
	if ( !(1 & OMmsg)  ||  !(1 & *msg) )
	{
		for (j = 0; j < new_objts_constructed; j++)
		
	 		OMmsg =	om$send(mode = OM_e_wrt_object,
	                    msg = message GRgraphics.GRdelete ( &msg1,
								 env),
                            senderid = my_id,
                            targetid = bz_objid[j],
                            targetos = env->md_id.osnum);
						
			if ( !(1 & OMmsg))
	  		{
			OMmsg = OM_E_ABORT;
		}

		if ( !(1 & msg1) )
		{
			*msg = MSFAIL;
	 	}

	}
	
	return (OMmsg);
	
}

end implementation GRbspline;
