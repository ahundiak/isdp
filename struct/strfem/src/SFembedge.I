/***************************************************************************
 * I/FEM
 *
 * File:        VSFembedge.I
 *
 * Description:
 *       This file contains the api functions to convert plates
 *
 *       Corresponding macros are
 *              1. vsf$convert_plates_with_all_stfs
 *		2. vsf$convert_plate_and_given_stfs.
 *
 * Dependencies:
 *
 * Revision History:
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *
 ***************************************************************************/

class implementation Root;

#include "OMerrordef.h"
#include "ex.h"
#include "exmacros.h"
#include "msdef.h"
#include "msmacros.h"
#include "bserr.h"
#include "bsparameters.h"
#include "dp.h"
#include "griodef.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igrdp.h"
#include "igrdef.h"
#include "gr.h"  
#include "go.h"  
#include "grio.h" 
#include "igr.h"
#include "growner.h"
#include "grdpbmacros.h" 
#include "grmacros.h"
#include "emsmapdef.h"
#include "emsdattyp.h"
#include "ECmsg.h"
#include "EMSmsgdef.h"
#include "EMSdef.h"
#include "EMSopt.h"
#include "vsdef.h"
#include "vsplatedef.h"
#include "APlcdef.h"
#include "APerrmac.h"
#include "APapidef.h"
#include "FEextdbg.h"
#include "FElimits.h"
#include "FEapimacros.h"
#include "SFapimacros.h"


from GRgraphics   import GRcopy,GRdelete;
from GRcurve      import GRendpts;
from EMSboundary  import EMget_edges;
from EMSedge      import EMget_bcxyz_geom;
from EMSsurface   import EMputLsIfNotThere;
from EMSsubbs	  import EMproject_curve_along_surface_normals;
from NDmacro      import ACreturn_foot,ACgive_structure;
from VSfeature    import VSforwardToSource,VSgetSupportedElements;
from VSbeam       import VSgetSupportAxis;


/* 
 *  FEsame_point() returns 1 if the distance between two given points 
 *  is less than given tolerance.
 *  Otherwise returns 0
 */
static int VSFsame_point (
		IGRdouble  *pt1,
		IGRdouble  *pt2,
		IGRdouble  EPS   )
{
  if (
      ((pt1[0] - pt2[0] <= EPS) && (pt1[0] - pt2[0] >= -EPS)) &&
      ((pt1[1] - pt2[1] <= EPS) && (pt1[1] - pt2[1] >= -EPS)) &&
      ((pt1[2] - pt2[2] <= EPS) && (pt1[2] - pt2[2] >= -EPS))
     )       return 1;
  else return 0;
}

/* *****************************H H H H H******************************* */
/* Doc: vsf$convert_plate_and_given_stfs

   Abstract: Given a plate and list of stiffners/beams, 
	     this macro does the following :

	      i.  Extracts base surface of plate. Assigns plate material/
		  element property to the base surface as per the options
		  specified to the macro.

             ii.  If any stiffeners/beams are specified to the macro, for each
		  of the stiffeners/beams it extracts stiffener axis. Then it
                  creates a non-manifold object ( edge creation state ) with
                  the base surface and stiffener axes. It assigns 
                  material/element property to the edges on the non-manifold 
                  object ( which correspond to stiffeners/beams ) as per the 
                  options specified to the macro.

	     The base surface of the plate and axes of all stiffners/beams
             will be copied and a non-manifold object will be created with them.
	     With this macro, material/element property can be attatched to
	     surface and edges.

	     EMSsurface can be input instead of plate.
	     GRcurves can be input instead of stiffeners.

	     Options for placing ( material/property )
		0  - Don't place
		1  - Place the given name
		2  - Get the name from the Database and place. ( Default )

   Arguments:
        IGRlong                 *msg;              O  message return code
	struct GRobj_env        *plate;            I  Plate object
	IGRint			nb_stfnrs;	   I  Number of Stiffeners/Beams
	struct GRobj_env        *stfnrs_list;      I  List of Stiffeners/Beams
	struct GRvg_construct   *cst;		   I  Construction List
	IGRint			pl_mat_opt;        I  Plate Material Option
	IGRchar		        plate_mat;         I  Plate Material name
			                              Will be used only when 
						      pl_mat_opt is 1 
	IGRint			pl_prp_opt;        I  Plate Property Option
	IGRchar		        plate_prop;        I  Plate Property name
			                              Will be used only when 
						      pl_prp_opt = 1
	IGRint			st_mat_opt;        I  Stiffener Material Option
	IGRchar		        stf_mat;           I  Stiffener Material name
			                              Will be used only when 
						      st_mat_opt is 1 
	IGRint			st_prp_opt;        I  Stiffener Property Option
	IGRchar			stf_prop;          I  Stiffener Property name
			                              Will be used only when 
						      st_prp_opt is 1
	struct GRid		*nm_obj;	   O  NMobject created

   Return Status:
	OM_S_SUCCESS	Success
	OM_E_INVARG     Invalid arguments sent
        OM_E_NODYNMEM   No dynamic memory available

   Examples:
	See the ppl program in file "pl_stf.u"

*/
/* *****************************H H H H H******************************* */

IGRlong VSFmakeedges_on_plate_with_given_stfs(
		IGRlong			*msg,
		struct GRobj_env	*plate, 
		IGRint 			num_cvs, 
		struct GRobj_env	*curves, 
		struct GRvg_construct 	*cst, 
		IGRint			pl_mat_opt,
		IGRint			pl_prp_opt,
		IGRint			st_mat_opt,
		IGRint			st_prp_opt,
		IGRchar			*plate_prop,
		IGRchar			*plate_mat,
		IGRchar			*curve_prop,
		IGRchar			*curve_mat,
		struct GRid 		*nm_obj  )
{
  IGRint    	   i, j, index=-1, num_flps = 0, num_flp_edges = 0, 
		   suc, flp_edges_bufsize = 0;
  BSrc		   rc;
  IGRlong   	   sts;
  IGRdouble	   EPS, *pt_list=NULL;	
  IGRpoint 	   startpt, endpt;
  GRclassid 	   cid;
  OM_S_OBJID 	   cvCopy;
  struct GRobj_env *operator=NULL, botSf, axis;
  struct GRid	   *flps = NULL, *flp_edges = NULL;
  IGRchar	   **prop_names=NULL, **mat_names=NULL, newflag,
		   plate_mat_name[FE_MAX_MPNAME_SIZE], 
		   plate_prp_name[FE_MAX_MPNAME_SIZE], 
		   MatType[80], MatGrade[80], VERBOSE = FE_DBG_MP;
  struct ret_struct     rs;

  /* Check the input arguments */
  if( !msg || !plate ||!cst || !nm_obj ||
//      ( !num_cvs && (st_mat_opt||st_prp_opt) ) ||
      ( num_cvs && !curves )        ||
      pl_mat_opt>2 || pl_mat_opt<0  || pl_prp_opt>2 || pl_prp_opt<0    ||
      st_mat_opt>2 || st_mat_opt<0  || st_prp_opt>2 || st_prp_opt<0    ||
      (pl_mat_opt ==1 && !plate_mat)|| (pl_prp_opt ==1 && !plate_prop) ||
      (st_mat_opt ==1 && !curve_mat)|| (st_prp_opt ==1 && !curve_prop)    )
  {  
      printf("Error in Input Arguments for ");
      sts = OM_E_INVARG;
      goto quit;
  }

  sts  = OM_S_SUCCESS;
  *msg = MSSUCC;

  /* Check for the VSplate class */
  sts = om$get_classid (  osnum      = plate->obj_id.osnum,
                           objid     = plate->obj_id.objid,
                           p_classid = &cid);
  AP_ERR_HNDLR("om$get_classid",sts,1,VERBOSE, quit);

  if ( om$is_ancestry_valid(superclassname = "VSplate",
                            subclassid     = cid        ) == OM_S_SUCCESS )
  {
    if( pl_mat_opt == 2) /* Get Material name using the data from Database */
    {
        /* get the material type */
        sts = om$send( msg = message NDmacro.ACgive_structure(
                                        &suc, &index, VS_K_prMatTypAttr, &rs,
                                        &plate->mod_env ),
			senderid = NULL_OBJID,
                        targetid = plate->obj_id.objid,
                        targetos = plate->obj_id.osnum );
	AP_ERR_HNDLR("NDmacro.ACgive_structure",sts,suc,VERBOSE, quit);
	strcpy( MatType, rs.var.text_st.text_string );

        /* get the material grade */
        sts = om$send( msg = message NDmacro.ACgive_structure(
                                        &suc, &index, VS_K_prMatGrdAttr, &rs,
                                        &plate->mod_env ),
			senderid = NULL_OBJID,
                        targetid = plate->obj_id.objid,
                        targetos = plate->obj_id.osnum );
	AP_ERR_HNDLR("NDmacro.ACgive_structure",sts,suc,VERBOSE, quit);
	strcpy( MatGrade, rs.var.text_st.text_string );

	sts = SFgetMatName( msg, MatType, MatGrade, plate_mat_name, &newflag);
        AP_ERR_HNDLR("SFgetMatName",sts,*msg,VERBOSE, quit);
     }
     else if(pl_mat_opt == 1) strcpy( plate_mat_name, plate_mat );/*Given name*/
     else plate_mat_name[0] = '\0'; /* No name */

     if(pl_prp_opt == 2) /* Get Property name using the data from Database */
     {
        sts = SFgenPlateProperty ( msg, plate->obj_id, 
			&plate->mod_env, plate_prp_name, &newflag );
        AP_ERR_HNDLR("SFgenPlateProperty",sts,*msg,VERBOSE, quit);
     }
     else if(pl_prp_opt == 1) strcpy( plate_prp_name, plate_prop );//Given name
     else plate_prp_name[0] = '\0'; /* No name for the plate */

     /*  Get the bottom surface of the plate */
     sts = om$send(  msg     = message NDmacro.ACreturn_foot(
                                            msg,
                                            VS_K_plBotSfPath,
                                            &botSf.obj_id,
                                            &botSf.mod_env.md_env.matrix_type,
                                            botSf.mod_env.md_env.matrix ),
			senderid = NULL_OBJID,
                        targetid = plate->obj_id.objid,
                        targetos = plate->obj_id.osnum ) ;
     AP_ERR_HNDLR("NDmacro.ACreturn_foot",sts,*msg,VERBOSE, quit);

     /* Get the proper module environment for the bottom surface of the plate */
     botSf.mod_env = plate->mod_env;

     /* Copy the Bottom surface into current environment */
     sts = om$send( msg	= message GRgraphics.GRcopy(  
						     msg,
						     &botSf.mod_env,
						     cst->env_info,
						     &cvCopy ),
			senderid= botSf.obj_id.objid,
			targetid= botSf.obj_id.objid,
			targetos= botSf.obj_id.osnum ) ;
     AP_ERR_HNDLR("GRgraphics.GRcopy",sts,*msg,VERBOSE, quit);

     botSf.obj_id.objid = cvCopy;
     botSf.mod_env      = *cst->env_info;
     botSf.obj_id.osnum = botSf.mod_env.md_id.osnum;
  }
  else 
  {
     /* Input is not a plate */
     botSf = *plate;
  }

  if( num_cvs )
  {
     /* Input curves for the embed edges function */
     operator = (struct GRobj_env *) malloc( 
				sizeof(struct GRobj_env) * num_cvs );
     if( !operator )
     {
       printf("Error in Memory Allocation\n");
       sts = OM_E_NODYNMEM;
       goto quit;
     }

     /* Property names list for the stiffeners */
     prop_names = (char **)malloc( num_cvs * sizeof(char *) );
     if( !prop_names )
     {  
       printf("Error in Memory Allocation\n");
       sts = OM_E_NODYNMEM;
       goto quit;
     }

     /* Material names list for the stiffeners */
     mat_names = (char **)malloc( num_cvs * sizeof(char *) );
     if( !mat_names )
     {  
       printf("Error in Memory Allocation\n");
       sts = OM_E_NODYNMEM;
       goto quit;
     }

     /* Array for storing the end points of projected curves */
     pt_list = (IGRdouble *)malloc( 6 * num_cvs * sizeof(IGRdouble) );
     if( !pt_list )
     {   
       printf("Error in Memory Allocation\n");
       sts = OM_E_NODYNMEM;
       goto quit;
      }
  }

  for( i=0; i<num_cvs; ++i )
  {
    prop_names[i] = (char *)calloc( (unsigned)FE_MAX_MPNAME_SIZE,
				(unsigned)sizeof(char) );
    if( !prop_names[i] )
    {  
      printf("Error in Memory Allocation\n");
      sts = OM_E_NODYNMEM;
      goto quit;
    }

    mat_names[i] = (char *)calloc( (unsigned)FE_MAX_MPNAME_SIZE,
				(unsigned)sizeof(char) );
    if( !mat_names[i] )
    {  
      printf("Error in Memory Allocation\n");
      sts = OM_E_NODYNMEM;
      goto quit;
    }

    /* Check whether the input curve is a stiffener */
    sts = om$get_classid (  osnum     = curves[i].obj_id.osnum,
                            objid     = curves[i].obj_id.objid,
                            p_classid = &cid);
    AP_ERR_HNDLR("om$get_classid",sts,1,VERBOSE, quit);
    
    if ( om$is_ancestry_valid(superclassname = "VSbeam",
                              subclassid     = cid        ) == OM_S_SUCCESS )
    {
	IGRlong		   nb_obj = 0;
  	OM_S_OBJID	   *obj=NULL;
	struct	GRlc_info  sf_info, cv_info;
	
	if(st_mat_opt == 2 )/* Get Materail name using the data from Database */
	{
          /* get the material type */
          sts = om$send( msg = message NDmacro.ACgive_structure(
                                        &suc, &index, VS_K_prMatTypAttr, &rs,
                                        &curves[i].mod_env ),
			senderid = NULL_OBJID,
                        targetid = curves[i].obj_id.objid,
                        targetos = curves[i].obj_id.osnum );
	  AP_ERR_HNDLR("NDmacro.ACgive_structure",sts,suc,VERBOSE, quit);
	  strcpy( MatType, rs.var.text_st.text_string );

          /* get the material grade */
          sts = om$send( msg = message NDmacro.ACgive_structure(
                                        &suc, &index, VS_K_prMatGrdAttr, &rs,
                                        &curves[i].mod_env ),
			senderid = NULL_OBJID,
                        targetid = curves[i].obj_id.objid,
                        targetos = curves[i].obj_id.osnum );
	  AP_ERR_HNDLR("NDmacro.ACgive_structure",sts,suc,VERBOSE, quit);
	  strcpy( MatGrade, rs.var.text_st.text_string );

	  /* Generate a material name for the stiffener */
	  sts = SFgetMatName( msg, MatType, MatGrade, mat_names[i], &newflag);
          AP_ERR_HNDLR("SFgetMatName",sts,*msg,VERBOSE, quit);
	}
	else if(st_mat_opt == 1 ) strcpy( mat_names[i], curve_mat );//Given name
	else mat_names[i][0] = '\0'; /* No name for the stiffener */

	if(st_prp_opt == 2 )
	{
	  /* Generate Beam property using the data from Database */
	  sts = SFgenBeamProperty ( msg, curves[i].obj_id, 
					prop_names[i], &newflag );
          AP_ERR_HNDLR("SFgenBeamProperty",sts,*msg,VERBOSE, quit);
	}
	else if(st_prp_opt == 1 ) strcpy( prop_names[i], curve_prop );
        else prop_names[i][0] = '\0'; /* No name */

	/* Get the axis of the stiffener or beam */
  	sts = om$send(  msg     = message VSfeature.VSforwardToSource(
                                        msg, OM_e_wrt_object,
                                        message VSbeam.VSgetSupportAxis(
                                                msg,
						&curves[i].mod_env,
						&axis              ) ),
                        senderid= curves[i].obj_id.objid,
                        targetid= curves[i].obj_id.objid,
                        targetos= curves[i].obj_id.osnum ) ;
        AP_ERR_HNDLR("VSbeam.VSgetSupportAxis",*msg,1,VERBOSE, quit);
        AP_ERR_HNDLR("VSfeature.VSforwardToSource",sts,1,VERBOSE, quit);

	/* Set proper module environment for axis */
	axis.mod_env = curves[i].mod_env;

	/* Copy the Axis into current environment */
  	sts = om$send( msg	= message GRgraphics.GRcopy(  
						      msg,
						      &axis.mod_env,
						      cst->env_info,
						      &cvCopy ),
			senderid= axis.obj_id.objid,
			targetid= axis.obj_id.objid,
			targetos= axis.obj_id.osnum ) ;
        AP_ERR_HNDLR("GRgraphics.GRcopy",sts,*msg,VERBOSE, quit);

	/* Set proper module environment */
  	axis.obj_id.objid = cvCopy;
	axis.mod_env      = *cst->env_info;
	axis.obj_id.osnum = axis.mod_env.md_id.osnum;

	/* Fill the operators list */
        operator[i] = axis;
/*
gr$display_object ( object_id = &operator[i].obj_id, mode  = GRhd );
*/
	/* Prepare the data for calling the method EMproject_curve_along_...*/
	sf_info.located_obj	= botSf.obj_id;
	sf_info.module_info	= botSf.mod_env;
	cv_info.located_obj	= axis.obj_id;
	cv_info.module_info	= axis.mod_env;

	/* Project the copied curve on to the copied base surfcae */
	sts = om$send(	msg	 = message 
			EMSsubbs.EMproject_curve_along_surface_normals(
					&cv_info,
					&sf_info,
					cst,
					TRUE,  // Want staus messages
					FALSE, // trimming required
					&nb_obj,
					&obj,
					msg ),
			senderid = NULL_OBJID,
			targetid = sf_info.located_obj.objid,
			targetos = sf_info.located_obj.osnum );
        AP_ERR_HNDLR("EMSsubbs.EMproject_curve_along_surface_normals",sts,*msg,VERBOSE, quit);

        if( nb_obj>0 && obj && obj[0] != NULL_OBJID )
	{
	   /* Get the end points for the projected curve */
	   sts = om$send( msg = message GRcurve.GRendpts( 
				msg,
				&cst->env_info->md_env.matrix_type,
				cst->env_info->md_env.matrix,
				startpt, 
				endpt ),
                        senderid = NULL_OBJID,
                        targetid = obj[0],
                        targetos = axis.obj_id.osnum );
           AP_ERR_HNDLR("GRcurve.GRendpts",sts,*msg,VERBOSE, quit);

	   /* Store the end points in 'pt_list' array */
	   for(j=0; j<3; ++j )
	   {
	      pt_list[6*i+j]   = startpt[j];
	      pt_list[6*i+j+3] = endpt[j];
	   }

	   /* Now delete the projected curve */
 	   sts = om$send( msg = message GRgraphics.GRdelete
					( msg, &axis.mod_env ),
				senderid = NULL_OBJID,
				targetid = obj[0],
				targetos = axis.obj_id.osnum );
	   AP_ERR_HNDLR("GRgraphics.GRdelete",sts,*msg,VERBOSE, quit);

	   if(obj) { om$dealloc( ptr = obj ); obj = NULL; }
	}
     }
     else 
     {
	/* Input curve is not a stiffener */
	operator[i] = curves[i];
     }
  }

  if( num_cvs )
  {
      /* Embed edges on surface */
      sts = MHmake_emb_edges( msg, &botSf, num_cvs, operator, cst, nm_obj );
      AP_ERR_HNDLR("MHmake_emb_edges",sts,*msg,VERBOSE, quit);
  }
  else
  {
      /* Only surface is given without any curves to impose */
      nm_obj->objid = botSf.obj_id.objid;
      nm_obj->osnum = botSf.obj_id.osnum;
  }

  /* Get the chord height tolerance to test the proximity of points */
  BSxtractpar ( &rc, BSTOLCHRDHT, &EPS);
  if( rc != BSSUCC ) goto quit;

  if( st_mat_opt || st_prp_opt )
  {
     IGRint ind;

     /* Get the feature loops in the NMobject */
     sts = NMget_feature_loops( msg, nm_obj, &num_flps, &flps, 
			NULL, NULL, NULL, NULL, NULL);
     AP_ERR_HNDLR("NMget_feature_loops",sts,*msg,VERBOSE, quit);

     /* Collect only "NMfeaturelp" objects. Leave "NMedflp" objects */
     ind = 0;
     for(i=0; i<num_flps; ++i)
     {
	IGRchar flp_name[50];
        sts = om$get_classname( objid        = flps[i].objid,
                                osnum        = flps[i].osnum,
                                classname    = flp_name );
        AP_ERR_HNDLR("om$get_classname",sts,1,VERBOSE, quit);

	if( strcmp( "NMfeaturelp", flp_name ) )  continue;
	flps[ind] = flps[i]; ++ind;
     }

     num_flps = ind;

     for(i=0; i<num_flps; ++i)
     {
	/* Get the EMSedges from the loops */
        num_flp_edges = 0;
        sts = om$send(msg = message EMSboundary.EMget_edges(
						msg, 
						MAXINT, 
	   					EMS_OPT_ALL, 
						&flp_edges, 
						&flp_edges_bufsize, 
						&num_flp_edges      ), 
			senderid = NULL_OBJID,
	   		targetid = flps[i].objid, 
			targetos = flps[i].osnum  );
        AP_ERR_HNDLR("EMSboundary.EMget_edges",sts,*msg,VERBOSE, quit);

	for( j=0; j<num_flp_edges; ++j )
	{
	  /* Get the geometry of the EMSedge */
	  struct IGRbsp_curve      lcl_curve;

          lcl_curve.poles   = NULL;
          lcl_curve.knots   = NULL;
          lcl_curve.weights = NULL;
          lcl_curve.bdrys   = NULL;

	  sts = om$send(msg = message EMSedge.EMget_bcxyz_geom(
				msg,
				(struct GRmdenv_info *)&cst->env_info->md_env,
				NULL,
				NULL,
				NULL,
				OM_K_MAXINT,
				FALSE,
				NULL,
				&lcl_curve ),
			senderid = NULL_OBJID,
			targetid = flp_edges[j].objid,
			targetos = flp_edges[j].osnum  );
	  AP_ERR_HNDLR("EMSedge.EMendpts",sts,*msg,VERBOSE, quit);

	  /* Evaluate the curve at the end points */
	  BScveval( &lcl_curve, 0.0, 0, startpt, &rc );
	  if( rc != BSSUCC ) goto quit;

	  BScveval( &lcl_curve, 1.0, 0, endpt, &rc );
	  if( rc != BSSUCC ) goto quit;

	  /* Check for corresponding input curve */
	  if((    VSFsame_point( &pt_list[6*i], startpt, EPS )
               && VSFsame_point( &pt_list[6*i+3], endpt, EPS )) ||
		  VSFsame_point( &pt_list[6*i], endpt, EPS )
	       && VSFsame_point( &pt_list[6*i+3], startpt, EPS ) )
	  {
	    /* Edges matched */
	    if ( mat_names[i][0] != '\0' )
	    {
	      /* Place the material on the EMSedge */
	      sts = fe$place_mat_on_geom ( nb_obj  = 1,
					   obj_list = &flp_edges[j],
					   obj_type = FE_EDGE_TYPE,
					   mat_name = mat_names[i] );
              AP_ERR_HNDLR("fe$place_mat_on_geom",sts,1,VERBOSE, quit);
/*
	      gr$display_object ( object_id = &flp_edges[j], mode = GRhd );
*/
	    }

	    if ( prop_names[i][0] != '\0' )
            {
	      /* Place the propertry on the EMSedge */
	      sts = fe$place_prop_on_geom ( nb_obj   = 1,
					    obj_list  = &flp_edges[j],
					    obj_type  = FE_EDGE_TYPE,
					    prop_name = prop_names[i] );
              AP_ERR_HNDLR("fe$place_prop_on_geom",sts,1,VERBOSE, quit);
	    }
          } 
        }
     }
  }

  if( pl_mat_opt )
  {
     /* Place the material on the plate */
     sts = fe$place_mat_on_geom ( nb_obj  = 1,
				  obj_list = nm_obj,
				  mat_name = plate_mat_name );
     AP_ERR_HNDLR("fe$place_mat_on_geom",sts,1,VERBOSE, quit);
  }

  if( pl_prp_opt )
  {
     /* Place the property on the plate */
     sts = fe$place_prop_on_geom ( nb_obj   = 1,
				   obj_list  = nm_obj,
				   prop_name = plate_prp_name );
     AP_ERR_HNDLR("fe$place_prop_on_geom",sts,1,VERBOSE, quit);
  }

quit:
  /* Deallocate the memory */
  if( prop_names )
  {
     for(i=0; i<num_cvs; ++i)
     {
       if( prop_names[i] ) 
       { 
	 om$dealloc( ptr = prop_names[i] ); 
	 prop_names[i]   = NULL; 
       }
     }
     om$dealloc( ptr = prop_names );
     prop_names = NULL;
  }
  if( mat_names )
  {
     for(i=0; i<num_cvs; ++i)
     {
       if( mat_names[i] ) 
       { 
	 om$dealloc( ptr = mat_names[i] ); 
	 mat_names[i]   = NULL; 
       }
     }
     om$dealloc( ptr = mat_names );
     mat_names = NULL;
  }

  if( operator  ) { om$dealloc( ptr = operator  ); operator  = NULL; }
  if( pt_list  )  { om$dealloc( ptr = pt_list   ); pt_list   = NULL; }
  if( flp_edges ) { om$dealloc( ptr = flp_edges ); flp_edges = NULL; }
  if( flps )      { om$dealloc( ptr = flps      ); flps      = NULL; }
  return sts;
}

/* *****************************H H H H H******************************* */
/* Function: VSFmake_embedges_on_plates()

   Abstract: Given a list of plates, this function will create a nonmanifold 
	     object with all the stiffners on it.

             The base surface of the plate and axes of all stiffners will be
	     copied and creates a nonmanifold object with them.
	     With this function, property/material can be attatched.

	     Options for placing ( material/property )
		0  - Don't place
		1  - Place the given name
		2  - Get the name from the Database. ( Default )

   Arguments:

        IGRlong                 *msg;              O  message return code
	IGRint			num_plates;	   I  Number of Plates
	struct GRobj_env        *plates;           I  List of Plates
	struct GRvg_construct   *cst;              I  Construction List
	IGRint			pl_mat_opt;        I  Plate Material Option
	IGRint			pl_prp_opt;        I  Plate Property Option
	IGRint			st_mat_opt;        I  Stiffener Material Option
	IGRint			st_prp_opt;        I  Stiffener Property Option
	IGRchar		        plate_prop;        I  Plate Property name
			                              Will be used only when 
						      pl_prp_opt is 1 
	IGRchar		        plate_mat;         I  Plate Material name
			                              Will be used only when 
						      pl_mat_opt is 1 
	IGRchar		        curve_prop;        I  Stiffener Property name
			                              Will be used only when 
						      st_prp_opt is 1 
	IGRchar		        curve_mat;         I  Stiffener Material name
			                              Will be used only when 
						      st_mat_opt is 1 
	struct GRid		**maniobj_list;    O  List of NMobjects created

   Return Status:

	OM_S_SUCCESS	Success
	OM_E_INVARG     Invalid arguments sent
        OM_E_NODYNMEM   No dynamic memory available
*/
/* *****************************H H H H H******************************* */

IGRlong VSFmake_embedges_on_plates(
		IGRlong			*msg,
		IGRint			num_plates,
		struct GRobj_env	*plates, 
		struct GRvg_construct 	*cst, 
		IGRint			pl_mat_opt,
		IGRint			pl_prp_opt,
		IGRint			st_mat_opt,
		IGRint			st_prp_opt,
		IGRchar			*plate_prop,
		IGRchar			*plate_mat,
		IGRchar			*curve_prop,
		IGRchar			*curve_mat,
		struct GRid 		*maniobj_list  )
{
   IGRint 	    i, j, nb_stif;
   IGRlong	    sts;
   GRclassid	    cid;
   struct GRid 	    *stif_list=NULL;
   struct GRobj_env *stfnrs=NULL;
   IGRchar	    VERBOSE=FE_DBG_MP;

   /* Check the input arguments */
   if( !msg || !num_plates || !plates || !cst || !maniobj_list )
   {
      printf("Error in Input Arguments for FEmake_embedges_on_plates()\n");
      sts = OM_E_INVARG;
      goto quit;
   }

   sts  = OM_S_SUCCESS;
   *msg = MSSUCC;

   for( i=0; i<num_plates; ++i )
   {
      maniobj_list[i].objid = NULL_OBJID;
      maniobj_list[i].osnum = cst->env_info->md_id.osnum;

      /* Check for the VSplate class, otherwise continue */
      sts = om$get_classid (  osnum     = plates[i].obj_id.osnum,
                              objid     = plates[i].obj_id.objid,
                              p_classid = &cid);
      AP_ERR_HNDLR("om$get_classid",sts,1,VERBOSE, quit);

      if ( om$is_ancestry_valid(superclassname = "VSplate",
                      subclassid     = cid        ) != OM_S_SUCCESS ) continue;

      nb_stif = 0;

      /* Get all the stiffeners on the plate */
      sts = om$send ( msg = message VSfeature.VSgetSupportedElements (
                        				msg,
                        				TRUE,
                        				&nb_stif,
                        				&stif_list ),
                   		senderid = NULL_OBJID,
                   		targetid = plates[i].obj_id.objid,
                   		targetos = plates[i].obj_id.osnum );
      AP_ERR_HNDLR("VSfeature.VSgetSupportedElements",sts,*msg,VERBOSE, quit);

      if( nb_stif == 0 ) /* No stiffeners on the plate */
      {
	sts = vsf$convert_plate_and_given_stfs(
				msg	       = msg,
				plate          = &plates[i],/* Plate object  */
                         	nb_stfnrs      = 0,         /* No stiffeners */
                         	stfnrs_list    = NULL,
                         	cst            = cst,
                         	pl_mat_opt     = pl_mat_opt,
                         	pl_prp_opt     = pl_prp_opt,
                         	st_mat_opt     = 0,
                         	st_prp_opt     = 0,
                         	plate_prop     = plate_prop,
                         	plate_mat      = plate_mat,
                         	stf_prop       = NULL,
                         	stf_mat        = NULL,
                         	nm_obj         = &(maniobj_list)[i] );
        AP_ERR_HNDLR("vsf$embedges_with_given_stfs",sts,*msg,VERBOSE, quit);
      }
      else
      {
	/* Get the stiffener ids into an array */
        stfnrs = (struct GRobj_env *) malloc( 
				sizeof(struct GRobj_env) * nb_stif );
        if( !stfnrs )
        {
           printf("FEmake_embedges_on_plates():Error in Memory Allocation\n");
           sts = OM_E_NODYNMEM;
           goto quit;
        }

	for( j=0; j<nb_stif; ++j )
        {
	   stfnrs[j].obj_id  = stif_list[j];
	   stfnrs[j].mod_env = plates[i].mod_env;
	}

	sts = vsf$convert_plate_and_given_stfs(
				msg            = msg, 
				plate          = &plates[i],
                         	nb_stfnrs      = nb_stif,
                         	stfnrs_list    = stfnrs,
                         	cst            = cst,
                         	pl_mat_opt     = pl_mat_opt,
                         	pl_prp_opt     = pl_prp_opt,
                         	st_mat_opt     = st_mat_opt,
                         	st_prp_opt     = st_prp_opt,
                         	plate_prop     = plate_prop,
                         	plate_mat      = plate_mat,
                         	stf_prop       = curve_prop,
                         	stf_mat        = curve_mat,
                         	nm_obj         = &(maniobj_list)[i] );
        AP_ERR_HNDLR("vsf$embedges_with_given_stfs",sts,*msg,VERBOSE, quit);
      }
   }

quit:
   if(stif_list) { om$dealloc( ptr = stif_list );  stif_list = NULL; }
   if(stfnrs)    { om$dealloc( ptr = stfnrs    );  stfnrs    = NULL; }
   return sts;
}

end implementation Root;
