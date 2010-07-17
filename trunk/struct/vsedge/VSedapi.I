/* $Id: VSedapi.I,v 1.1.1.1 2001/01/04 21:10:35 cvs Exp $  */

/***************************************************************************
 * I/STRUCT
 *
 * File:        vsedge/vsedapi
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VSedapi.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:10:35  cvs
 *      Initial import to CVS
 *
# Revision 1.3  1999/12/06  16:24:58  pinnacle
# tr179900967
#
# Revision 1.2  1999/05/12  14:58:04  pinnacle
# unique ACrg_collect for each edge
#
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.4  1998/03/09  23:33:22  pinnacle
# Replaced: vsedge/VSedapi.I for:  by impd for struct
#
# Revision 1.3  1997/11/03  20:57:46  pinnacle
# Replaced: vsedge/VSedapi.I for:  by rchennup for struct
#
# Revision 1.2  1997/10/31  14:33:46  pinnacle
# Update include list
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *      10/31/97        ah              added header
 *                                      UnInit Warnings
 *      05/07/99        ejm             Create a unique ACrg_collect for each
 *					  edge; added DTHK attribute
 *      11/29/99        ah              Changed ext_bound to ext_bound2 which
 *                                      uses neat_plate routines for getting edges
 ***************************************************************************/

class implementation Root;

#include "OMprimitives.h"
#include "OMerrordef.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "bserr.h"
#include "bsparameters.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "godef.h"
#include "go.h"
#include "growner.h"
#include "nddef.h"
#include "acrepdef.h"
#include "ACattrib.h"
#include "ACrg_collect.h"
#include "macro.h"
#include "asmacros.h"
#include "ndmacros.h"
#include "EMSmsgdef.h"
#include "VDSsymb_def.h"
#include "vsdef.h"
#include "vs.h"
#include "vsdatamacros.h"
#include "vscmdmacros.h"
#include "vsplatedef.h"
#include "vsgeommacros.h"
#include "vsedgedef.h"
#include "vsedgemacros.h"
#include "vsmiscmacros.h"
#include "vsedgeattr.h"

#include "acdef.h"
#include "acmacros.h"

extern OMuword          OPP_ACcpx_class_id, OPP_ACpretend_class_id, 
	       		OPP_VSplate_class_id, OPP_nci_macro_class_id,
			OPP_ACrg_collect_class_id, OPP_VSedge3Datt_class_id,
			OPP_VSholPlate_class_id, OPP_VSbooPlate_class_id;
extern OM_S_CHANSELECT  AS_to_comp;

from  GRgraphics import  GRconstruct, GRchgprops;
from  NDnode	 import	 NDget_objects, ASreturn_go, 
			 NDchg_state, NDchange_connect;
from  NDmacro	 import  ACreturn_foot;
from  ci_macro   import  init;
from  ACcpx	 import  find_macro, ACfind_exp_temp_obj;
from  ACcpx_defn import  ACgive_name;
from  ACrg_collect import ACadd_list_attribute, AClist_attribute;
from  VSfeature	   import VSgetOperationHistory;
from  EMSedge	   import EMget_bcxyz_geom;

/*
#define DEBUG      1
#define vsDEBUG    1
#define vserrDEBUG 1
*/

#include "vsdbgmacros.h"

IGRlong  VSgetChldMac(
		struct GRid     parentId,    /* I As source object */
		char            *macName,    /* I macro name */
		struct GRid     *macrosOcId, /* O list allocated by caller*/
		IGRint          numMaxMacros,/* I Max. number of ID allocated */
		IGRint          *numMacros   /* O number of ID found */   )
{
   IGRlong         status;
   IGRchar         *theMacroName;
   struct GRid     *GridBuffer,theMacroId;
   IGRint     	   i=0, numObjects=0, numMacro=0;

   status = OM_E_INVARG;

   if ( !numMacros || !macrosOcId || !macName ) goto wrapup;

   *numMacros = 0;

   status= om$send ( msg =  message NDnode.NDget_objects( 
						ND_IN_BUF |ND_CHILDREN,
                        			(struct GRid *)NULL,
                        			0,
                        			&GridBuffer,
                        			0,
                        			OM_K_MAXINT,
                        			&numObjects),
			senderid	= NULL_OBJID,
                	targetid        = parentId.objid,
                	targetos        = parentId.osnum	);
   __CheckRC( status, 1, "NDnode.NDget_objects", wrapup );
   __DBGpr_objlist( "NDget_objects", numObjects, GridBuffer );

   while ((i<numObjects)&&( numMacro<numMaxMacros))  
   {
      if( vs$is_ancestry_valid(  object  = &GridBuffer[i],
                                 classid = OPP_nci_macro_class_id ) ||
          vs$is_ancestry_valid(  object  = &GridBuffer[i],
                                 classid = OPP_VSedge3Datt_class_id ) )
      {
         status= om$send ( msg = message ACcpx.find_macro(&theMacroId),
			senderid	= NULL_OBJID,
                       	targetid        = GridBuffer[i].objid,
                       	targetos        = GridBuffer[i].osnum);
         __CheckRC( status, 1, "ACcpx.find_macro", wrapup );

         status= om$send ( msg = message ACcpx_defn.ACgive_name(&theMacroName),
			senderid	= NULL_OBJID,
                       	targetid        = theMacroId.objid,
                       	targetos        = theMacroId.osnum);
         __CheckRC( status, 1, "ACcpx_defn.ACgive_name", wrapup );
         __DBGpr_str("found macro", theMacroName );
         __DBGpr_obj("id", theMacroId );

         if (!strcmp(theMacroName,macName))      
         {
            macrosOcId[numMacro].objid = GridBuffer[i].objid;
            macrosOcId[numMacro].osnum = GridBuffer[i].osnum;
            numMacro = numMacro + 1;
         }
      }
      ++i;
   } /** end while **/

   *numMacros = numMacro;
   status = OM_S_SUCCESS;
wrapup:

   return status;
}

IGRlong  VSchange_edgestructure     (   IGRlong             *msg,
					IGRint              opt,
					struct edge_set     *edge_attrvals,
					struct ACrg_coll    *ACrg           )
{
   IGRlong status;
   status = OM_E_INVARG;
 
   if( !msg || !edge_attrvals || !ACrg )  goto wrapup;

   /* if opt==1, convert from 'struct edge_set' to 'struct ACrg_coll' */
   if( opt )
   {
      /* Prepare ACrg collection */

      strcpy(ACrg[ATT_IDX_DTHK].name,ATT_DEL_THK);
      ACrg[ATT_IDX_DTHK].desc.type = AC_ATTRIB_DOUBLE;
      ACrg[ATT_IDX_DTHK].desc.value.att_exp = edge_attrvals->DTHK;

      strcpy(ACrg[ATT_IDX_LO].name,ATT_LO);
      ACrg[ATT_IDX_LO].desc.type = AC_ATTRIB_DOUBLE;
      ACrg[ATT_IDX_LO].desc.value.att_exp = edge_attrvals->L_OFF;

      strcpy(ACrg[ATT_IDX_LB].name,ATT_LB);
      ACrg[ATT_IDX_LB].desc.type = AC_ATTRIB_DOUBLE;
      ACrg[ATT_IDX_LB].desc.value.att_exp = edge_attrvals->L_BASE;

      strcpy(ACrg[ATT_IDX_SO].name,ATT_SO);
      ACrg[ATT_IDX_SO].desc.type = AC_ATTRIB_DOUBLE;
      ACrg[ATT_IDX_SO].desc.value.att_exp = edge_attrvals->S_OFF;

      strcpy(ACrg[ATT_IDX_SB].name,ATT_SB);
      ACrg[ATT_IDX_SB].desc.type = AC_ATTRIB_DOUBLE;
      ACrg[ATT_IDX_SB].desc.value.att_exp = edge_attrvals->S_BASE;

      strcpy(ACrg[ATT_IDX_A].name,ATT_A);
      ACrg[ATT_IDX_A].desc.type = AC_ATTRIB_DOUBLE;
      ACrg[ATT_IDX_A].desc.value.att_exp = edge_attrvals->A;

      strcpy(ACrg[ATT_IDX_TYPE_ANGLE].name,ATT_TYPE_ANGLE);
      ACrg[ATT_IDX_TYPE_ANGLE].desc.type = AC_ATTRIB_TEXT;
      ACrg[ATT_IDX_TYPE_ANGLE].desc.value.att_txt[0] = 
					edge_attrvals->groove_type;
      ACrg[ATT_IDX_TYPE_ANGLE].desc.value.att_txt[1] = '\0';

      strcpy(ACrg[ATT_IDX_TYPE_CHAMF].name,ATT_TYPE_CHAMF);
      ACrg[ATT_IDX_TYPE_CHAMF].desc.type = AC_ATTRIB_DOUBLE;
      ACrg[ATT_IDX_TYPE_CHAMF].desc.value.att_exp = 
					edge_attrvals->add_material;
       
      strcpy(ACrg[ATT_IDX_B].name,ATT_B);
      ACrg[ATT_IDX_B].desc.type = AC_ATTRIB_DOUBLE;
      ACrg[ATT_IDX_B].desc.value.att_exp = edge_attrvals->B;
      
      strcpy(ACrg[ATT_IDX_V].name,ATT_V);
      ACrg[ATT_IDX_V].desc.type = AC_ATTRIB_DOUBLE;
      ACrg[ATT_IDX_V].desc.value.att_exp = edge_attrvals->V;
     
      strcpy(ACrg[ATT_IDX_Y].name,ATT_Y);
      ACrg[ATT_IDX_Y].desc.type = AC_ATTRIB_DOUBLE;
      ACrg[ATT_IDX_Y].desc.value.att_exp = edge_attrvals->Y;
    
      strcpy(ACrg[ATT_IDX_X].name,ATT_X);
      ACrg[ATT_IDX_X].desc.type = AC_ATTRIB_DOUBLE;
      ACrg[ATT_IDX_X].desc.value.att_exp = edge_attrvals->X;

      strcpy(ACrg[ATT_IDX_H].name,ATT_H);
      ACrg[ATT_IDX_H].desc.type = AC_ATTRIB_DOUBLE;
      ACrg[ATT_IDX_H].desc.value.att_exp = edge_attrvals->H;
  
      strcpy(ACrg[ATT_IDX_C].name,ATT_C);
      ACrg[ATT_IDX_C].desc.type = AC_ATTRIB_DOUBLE;
      ACrg[ATT_IDX_C].desc.value.att_exp = edge_attrvals->C;
 
      strcpy(ACrg[ATT_IDX_N].name,ATT_N);
      ACrg[ATT_IDX_N].desc.type = AC_ATTRIB_DOUBLE;
      ACrg[ATT_IDX_N].desc.value.att_exp = edge_attrvals->N;

      strcpy(ACrg[ATT_IDX_T].name,ATT_T);
      ACrg[ATT_IDX_T].desc.type = AC_ATTRIB_DOUBLE;
      ACrg[ATT_IDX_T].desc.value.att_exp = edge_attrvals->T;

      strcpy(ACrg[ATT_IDX_ALLOWANCE].name,ATT_ALLOWANCE);
      ACrg[ATT_IDX_ALLOWANCE].desc.type = AC_ATTRIB_DOUBLE;
      ACrg[ATT_IDX_ALLOWANCE].desc.value.att_exp = edge_attrvals->allowance;

      strcpy(ACrg[ATT_IDX_PROCESS].name,ATT_PROCESS);
      ACrg[ATT_IDX_PROCESS].desc.type = AC_ATTRIB_TEXT;
      strcpy(ACrg[ATT_IDX_PROCESS].desc.value.att_txt,edge_attrvals->process);

      strcpy(ACrg[ATT_IDX_SPEC_NB].name,ATT_SPEC_NB);
      ACrg[ATT_IDX_SPEC_NB].desc.type = AC_ATTRIB_TEXT;
      strcpy(ACrg[ATT_IDX_SPEC_NB].desc.value.att_txt,edge_attrvals->spec_ind);

      strcpy(ACrg[ATT_IDX_ABS].name,ATT_ABS);
      ACrg[ATT_IDX_ABS].desc.type = AC_ATTRIB_DOUBLE;
      if( edge_attrvals->is_absolute == TRUE )
      	ACrg[ATT_IDX_ABS].desc.value.att_exp = 1.0;
      else
	ACrg[ATT_IDX_ABS].desc.value.att_exp = 0.0;
	
      strcpy(ACrg[ATT_IDX_TYPE].name,ATT_TYPE);
      ACrg[ATT_IDX_TYPE].desc.type = AC_ATTRIB_DOUBLE;
     
      if( edge_attrvals->add_material == 0 )
      {
	 ACrg[ATT_IDX_TYPE_CHAMF].desc.value.att_exp = 0;
	 ACrg[ATT_IDX_TYPE].desc.value.att_exp = ATT_BASE_FAT;
      } 
      else
      {
	 ACrg[ATT_IDX_TYPE_CHAMF].desc.value.att_exp = 1;
	 ACrg[ATT_IDX_TYPE].desc.value.att_exp = ATT_BASE_THIN;
      }

   }
   else
   {
      edge_attrvals->DTHK   = ACrg[ATT_IDX_DTHK].desc.value.att_exp;
      edge_attrvals->L_OFF  = ACrg[ATT_IDX_LO].desc.value.att_exp;
      edge_attrvals->S_OFF  = ACrg[ATT_IDX_SO].desc.value.att_exp;
      edge_attrvals->L_BASE = ACrg[ATT_IDX_LB].desc.value.att_exp;
      edge_attrvals->S_BASE = ACrg[ATT_IDX_SB].desc.value.att_exp;
      edge_attrvals->A = ACrg[ATT_IDX_A].desc.value.att_exp;
      edge_attrvals->B = ACrg[ATT_IDX_B].desc.value.att_exp;
      edge_attrvals->V = ACrg[ATT_IDX_V].desc.value.att_exp;
      edge_attrvals->X = ACrg[ATT_IDX_X].desc.value.att_exp;
      edge_attrvals->Y = ACrg[ATT_IDX_Y].desc.value.att_exp;
      edge_attrvals->H = ACrg[ATT_IDX_H].desc.value.att_exp;
      edge_attrvals->C = ACrg[ATT_IDX_C].desc.value.att_exp;
      edge_attrvals->N = ACrg[ATT_IDX_N].desc.value.att_exp;
      edge_attrvals->T = ACrg[ATT_IDX_T].desc.value.att_exp;
      if( ACrg[ATT_IDX_ABS].desc.value.att_exp < 0.5 )
           edge_attrvals->is_absolute = FALSE;
      else edge_attrvals->is_absolute = TRUE;
      edge_attrvals->allowance = ACrg[ATT_IDX_ALLOWANCE].desc.value.att_exp;
      edge_attrvals->add_material = 
			(int) ACrg[ATT_IDX_TYPE_CHAMF].desc.value.att_exp;
      strcpy( edge_attrvals->process, 
			ACrg[ATT_IDX_PROCESS].desc.value.att_txt);
      strcpy( edge_attrvals->spec_ind, 
			ACrg[ATT_IDX_SPEC_NB].desc.value.att_txt);
      edge_attrvals->groove_type = 
			ACrg[ATT_IDX_TYPE_ANGLE].desc.value.att_txt[0];
   }
wrapup:
   return OM_S_SUCCESS;
}

IGRlong  VSplace_edgeattrs_on_plate (   IGRlong            *msg,
					struct GRobj_env   surfObj,
					struct edge_set    *edge_attrvals,
					struct GRmd_env    *cst_env,
                                        IGRint             *num_edges,
                                        struct GRid        **edge_list  )
{
   IGRint		i_msg, edCount=0;
   IGRuint              objs_on_chan;
   IGRlong 		status=OM_S_SUCCESS;
   IGRint     		i,j,nb_edge=0, numMacros=0, cur_loop, already_placed=0;
   IGRchar              state_ed = ND_DONT_MVRT ,
                        state_ex = ND_DONT_MVRT | ND_DEL_NO_CH;
   IGRboolean           fl_edge_loop, onEdge, is_holplate;
   IGRchar		bound_name[32];
   IGRpoint		pt;
   IGRshort             action, prop, matrix_type, active_level,k,n;
   IGRdouble            matrix[16];
   struct GRid 		EDGE_ATT, base_surf, ext_bound, boundary,
			TEMP[3], *edList=NULL;
   struct IGRdisplay    active_display;
   struct GRobj_env   	parents[3], parent_surf;
   struct ACrg_coll     ACrg[ATT_NB_ATT];
   struct VScnst_list   vsargs ;
   struct VDSsymb       active_symb;
   struct GRvg_construct cstargs ;
   double                dist, tolerance, *pars=NULL, *intpars=NULL, ii ;

   status = OM_S_SUCCESS;

  // Get rid of UnInit ref warnings
  is_holplate = FALSE;
  onEdge      = FALSE;
  BSEXTRACTPAR( msg, BSTOLCHRDHT, tolerance );

   if( edge_attrvals )
   {
      if( !cst_env )
      {
	status = OM_E_INVARG;
	goto wrapup;
      }

      /* Fill construction list    */
      status = vs$cnstDefaults(  msg     = msg,
                                 symb_id = surfObj.mod_env.md_id,
                                 symb    = &active_symb,
                                 level   = &active_level,
			         display = &active_display ) ;
      __CheckRC( status, *msg, "vs$cnstDefaults", wrapup   ) ;

      vs$fill_cnst_list(      Env_info   = cst_env,
                              Display    = &active_display,
                              Level      = active_level,
                              Class_attr = &vsargs,
                              Cnst_list  = cstargs,
                              Msg        = msg 	        ) ;

      cstargs.newflag         = FALSE ;
      cstargs.name            = '\0' ;

      vsargs.representation   = AC_NO_REP ;
      vsargs.feature_att      = NULL;
      vsargs.parent_count     = 3;
      vsargs.parent_list      = parents;

      /* Retrieve the support surface of the plate */
      base_surf = surfObj.obj_id;

      if( vs$is_ancestry_valid(    object  = &surfObj.obj_id,
                                   classid = OPP_ACpretend_class_id ) )
      {
         __DBGpr_obj( "got reference object before ret_go",surfObj.obj_id );

         status = om$send( msg  = message NDnode.ASreturn_go(
                                        &base_surf,
                                        &surfObj._matrix_type,
                                         surfObj._matrix ),
                        senderid = NULL_OBJID,
                        targetid = surfObj._objid,
                        targetos = surfObj._osnum );
         __CheckRC( status, 1, "PlEd:return_go", wrapup );
      }  // end if its a reference object

      if( vs$is_ancestry_valid(    object  = &base_surf,
                                   classid = OPP_VSplate_class_id ) )
      {
	struct GRid        oid;
	VSopHistory        *h=NULL, *history=NULL;

        __DBGpr_com( "It's a plate!!" );			
        status= om$send( msg = message NDmacro.ACreturn_foot(
                                        msg,
                                        VS_K_plBotSfPath,
                                        &TEMP[0],
                                        &surfObj.mod_env.md_env.matrix_type,
                                        surfObj.mod_env.md_env.matrix ),
			senderid = NULL_OBJID,
			targetid = base_surf.objid,
			targetos = base_surf.osnum ) ;
        __CheckRC( status, *msg, "Getting plate base surf", wrapup ) ;

    	if( !(vs$is_ancestry_valid(  object  = &base_surf,
                               	   classid = OPP_VSholPlate_class_id )) &&
	    !(vs$is_ancestry_valid(  object  = &base_surf,
                                   classid = OPP_VSbooPlate_class_id )) )
	{ is_holplate = FALSE; goto make_source; }
        else is_holplate = TRUE;

	status= om$send( msg = message VSfeature.VSgetOperationHistory(
					msg,
					&surfObj.mod_env,
					&history         ),
                        senderid = NULL_OBJID,
                        targetid = base_surf.objid,
                        targetos = base_surf.osnum ) ;
	__CheckRC( status, *msg, "Getting Operation History", wrapup ) ;

	for( h = history ; h ; h = h->next ) {
		oid.objid = h->resultId;
		oid.osnum = h->resultOs;
      	    	if( !(vs$is_ancestry_valid( object  = &oid,
                                  	    classid = OPP_VSholPlate_class_id ))
		 && !(vs$is_ancestry_valid( object  = &oid,
                                            classid = OPP_VSbooPlate_class_id)))
		break;
        }
        status= om$send( msg = message NDmacro.ACreturn_foot(
                                        msg,
                                        VS_K_plBotSfPath,
                                        &parent_surf.obj_id,
                                        NULL,
                                        NULL   ),
			senderid = NULL_OBJID,
			targetid = oid.objid,
			targetos = oid.osnum ) ;
        __CheckRC( status, *msg, "Getting plate base surf", wrapup ) ;
        parent_surf.mod_env = h->resultEnv;
	VSfreeOpHistory( history ) ;

        /*
         * get the surface edges
         */
        status = vs$get_surface_edges(  msg     = msg,
                                        sfId    = &parent_surf._grid,
                                        sfEnv   = &parent_surf.mod_env,
                                        edgeType= VS_K_CONTOUR_EDGES,
                                        edCount = &edCount,
                                        edList  = &edList );
        __CheckRC( status, *msg, "vs$get_surface_edges", wrapup ) ;

	// BSEXTRACTPAR( msg, BSTOLCHRDHT, tolerance );
      } // if it's a plate
      else{
         __DBGpr_com("not a Plate!");
         TEMP[0] = base_surf;
      }

make_source:
      as$make_source(    go_grid = TEMP[0],
                         mod_env = &surfObj.mod_env,
                         as_grid = &TEMP[0] );

      __DBGpr_obj("Surface", TEMP[0] );

      parents[0].obj_id  = TEMP[0];
      parents[0].mod_env = surfObj.mod_env;

      /* Place 'ext_bound' macro on the surface */

      numMacros=0;

      status = VSgetChldMac( TEMP[0], "ext_bound2", &ext_bound, 1, &numMacros);
      __CheckRC( status, 1, "VSgetChldMac", wrapup ) ;       

      if ( numMacros == 0 )
      {
         GRobjid save_id;

	 // TR179900976, for now ext_bound2 lices in VDefp
	 ac$construct_path(mode = AC_ADD_PATH, name = "VDefp");

         ext_bound.objid = NULL_OBJID;
         ext_bound.osnum  = cst_env->md_id.osnum;
         save_id = cst_env->md_id.objid;
         cst_env->md_id.objid  = NULL_OBJID;
         status = om$construct( classid = OPP_nci_macro_class_id,
                			msg = message ci_macro.init(
					      &i_msg ,
                                              AChdr_nodisplay |AChdr_norange,
                                              "ext_bound2",
                                              1 ,
                                              TEMP,
                                              NULL, cst_env ),
                        p_objid = &ext_bound.objid,
                        osnum   = ext_bound.osnum);
         __CheckRC( status, i_msg, "Placing ext_bound macro", wrapup ) ;       

         cst_env->md_id.objid = save_id;
   
         status = om$send( msg = message NDnode.NDchg_state
                             		    ( state_ex, state_ex ),
                      	   senderid = NULL_OBJID,
                      	   targetid = ext_bound.objid,
                       	   targetos = ext_bound.osnum );
         __CheckRC( status, 1, "NDnode.NDchg_state", wrapup ) ;       
      } //c if on numMacros

      TEMP[ATT_T_IDX_SURF] = TEMP[0];

      /* Find boundary foot of ext_bound macro */

      for( cur_loop=0; ; ++cur_loop )
      {
	 struct IGRbsp_curve *cvGeom=NULL;

         if( cur_loop == 0 )     sprintf( bound_name, "boundary" );
         else                    sprintf( bound_name, "bound%d", cur_loop+ 1 );

         boundary.objid  = NULL_OBJID;
         status = om$send(msg = message  NDmacro.ACreturn_foot(
                                                  msg,
                                                  bound_name,
                                                  &boundary,
                                                  &matrix_type,
                                                  matrix ),
                       senderid     = NULL_OBJID,
                       targetid     = ext_bound.objid,
                       targetos     = ext_bound.osnum);
         if (!(status&(*msg)&1))        break;

         if( boundary.objid == NULL_OBJID )
         {
	    __DBGpr_com( " No more boundaries ");
	    goto boundary_break;
         }
         else 
         {
	    __DBGpr_obj(" boundary ", boundary );
	    __DBGpr_str(" bound_name ",bound_name );
         }

         /* Find components of boundary contour */

         objs_on_chan =0;
         status = om$get_channel_count(   osnum        = boundary.osnum,
                                          objid        = boundary.objid,
                                          p_chanselect = &AS_to_comp,
                                          count        = &objs_on_chan );
         __DBGpr_int(" objs_on_chan ", objs_on_chan );

         if( objs_on_chan == 0 ) 
         {
	    __DBGpr_int( "IN objs_on_chan == 0", objs_on_chan );
            TEMP[ATT_T_IDX_EDGE_3D]       = boundary;
            fl_edge_loop    = (IGRboolean)TRUE;
            objs_on_chan       = 1;
         }
         else          fl_edge_loop    = (IGRboolean)FALSE;


         /* Prepare ACrg collection */
	 status = VSchange_edgestructure( msg, 1, edge_attrvals, ACrg );
	 __CheckRC( status, *msg, "VSchange_edgestructure", wrapup ) ;

         EDGE_ATT.osnum  = surfObj.mod_env.md_id.osnum;
         for( i=0; i<objs_on_chan; i=i+1 )
         {

	   // Create a unique collector object for each edge
	   TEMP[ATT_T_IDX_BOX].objid = NULL_OBJID;
	   TEMP[ATT_T_IDX_BOX].osnum = cst_env->md_id.osnum;
	   status = om$construct(  classid = OPP_ACrg_collect_class_id,
                                   osnum   = TEMP[ATT_T_IDX_BOX].osnum,
                                   p_objid = &TEMP[ATT_T_IDX_BOX].objid);
	   __CheckRC( status, 1, "om$construct:ACrg_collect", wrapup ) ;       
      
	   status = om$send( msg = message NDnode.NDchg_state(
						ND_DEL_NO_CH, ND_DEL_NO_CH ),
		 	senderid = NULL_OBJID,
                 	targetid = TEMP[ATT_T_IDX_BOX].objid,
                 	targetos = TEMP[ATT_T_IDX_BOX].osnum );
	   __CheckRC( status, 1, "NDnode.NDchg_state", wrapup ) ;             

	   status = om$send( msg = message ACrg_collect.ACadd_list_attribute
                         			(msg, ATT_NB_ATT, ACrg),
			 	senderid = NULL_OBJID,
                         	targetid = TEMP[ATT_T_IDX_BOX].objid,
                         	targetos = TEMP[ATT_T_IDX_BOX].osnum);
	  __CheckRC( status, *msg, "ACrg_collect.ACadd_list_attribute", wrapup);

	  __DBGpr_int( "Constructed ACrg_collect", TEMP[ATT_T_IDX_BOX].objid );

	  parents[ATT_T_IDX_BOX].obj_id  = TEMP[ATT_T_IDX_BOX];
	  parents[ATT_T_IDX_BOX].mod_env = surfObj.mod_env;


	    if( fl_edge_loop == (IGRboolean)FALSE )
	    {
	       	status = om$get_objid_at_index(
                                osnum   = boundary.osnum,
                                objid   = boundary.objid,
                        p_chanselect    = &AS_to_comp,
                        index           = i,
                        objidaddr       = &TEMP[ATT_T_IDX_EDGE_3D].objid,
                        osnumaddr       = &TEMP[ATT_T_IDX_EDGE_3D].osnum );
               	__CheckRC( status, 1, "Getting boundary edges", wrapup ) ;
	    }

	    /* TR179900967 Not sure what this is all about
	     * comparing edges generated by ext_bound2 with those returned by
	     * get_surface_edges and skipping certain ones.
	     *
	     * Know that the new ext_bound2 routine only returns valid edges
	     * so added the || 1 here to always skip this check
	     */
	    if( !is_holplate || (cur_loop==0) || 1) goto skip;

            status = vs$get_geometry(  msg      = msg,
                                           grobjId  = &TEMP[ATT_T_IDX_EDGE_3D],
                                           grobjEnv = &surfObj.mod_env,
                                           geometry = &cvGeom );
            __CheckRC( status, *msg, "vs$get_geometry", wrapup ) ;

            for ( j = 0; j<edCount; j++ )
            {
		struct IGRbsp_curve edGeom;

              	edGeom.knots = NULL;
              	edGeom.poles = NULL;
            	edGeom.weights = NULL;
            	edGeom.bdrys = NULL;
             	onEdge = TRUE;

                status = om$send(msg = message EMSedge.EMget_bcxyz_geom(
                                                msg,
                                                &parent_surf.mod_env.md_env,
						NULL,
                                                NULL,
                                                NULL,
                                                OM_K_MAXINT,
                                                FALSE,
                                                NULL,
                                                &edGeom),
                                        senderid = edList[j].objid,
                                        targetid = edList[j].objid,
                                        targetos = edList[j].osnum );
                __CheckRC(status,*msg,"EMSedge.EMget_bcxyz_geom", wrapup );

                for( ii = 0.; ii<=1.0; ii=ii+0.1)
                {
                   BScveval( cvGeom, ii, 0, &pt, msg );
                   if( BSERROR( *msg ) ) { *msg = EMS_E_BSerror; goto wrapup; }

                   pars = intpars = NULL;

                   BSmdistptcv(    &edGeom, pt, &k, &n, &pars, &dist,
                                        &intpars, msg );
		   if( BSERROR( *msg ) ) { *msg = EMS_E_BSerror; goto wrapup; }

                   if(dist > tolerance ) {  onEdge = FALSE; break; }
		}
		if( onEdge == TRUE ) break;
	    }

	    if( onEdge == FALSE ) continue;
   	    _FREE(cvGeom) ;

skip:
	    status = as$make_source( go_grid = TEMP[ATT_T_IDX_EDGE_3D],
                         	     mod_env = &surfObj.mod_env,
                                     as_grid = &TEMP[ATT_T_IDX_EDGE_3D] );
            __CheckRC( status, 1, "as$make_source", wrapup ) ;

	    numMacros=0;
	    status = VSgetChldMac( TEMP[ATT_T_IDX_EDGE_3D], "VSedge3Datt", 
					&EDGE_ATT, 1, &numMacros);
            __CheckRC( status, 1, "VSgetChldMac", wrapup ) ;
            nb_edge++;

            if ( numMacros == 0 ) 
	    {
	       __DBGpr_objlist( "placement T", NB_TEMPLATE, TEMP );

               EDGE_ATT.objid  = NULL_OBJID;
               EDGE_ATT.osnum  = cst_env->md_id.osnum;

	       parents[ATT_T_IDX_EDGE_3D].obj_id  = TEMP[ATT_T_IDX_EDGE_3D];
	       parents[ATT_T_IDX_EDGE_3D].mod_env = surfObj.mod_env;

     	       status = om$construct(   classid = OPP_VSedge3Datt_class_id,
                                	osnum   = EDGE_ATT.osnum,
                              	        p_objid = &EDGE_ATT.objid,
                              	        msg     = message GRgraphics.GRconstruct
								( &cstargs ));
	       __CheckRC( status, 1, "om$construct:VSedge3Datt", wrapup );

	       __DBGpr_int( "Constructed VSedge3Datt", EDGE_ATT.objid );

               status = om$send(msg = message NDnode.NDchg_state
                                 		( state_ed, state_ed ),
                        	senderid = NULL_OBJID,
                        	targetid = EDGE_ATT.objid,
                        	targetos = EDGE_ATT.osnum );
	       __CheckRC( status, 1, "NDnode.NDchg_state", wrapup );
	    } //c if num macros is 0
	    else 
	    {
               already_placed++;
               __DBGpr_int( "found edge_att macros", numMacros );
	    }
         } //c end for edge
      } //c end for loop on boundaries

      boundary_break:

      if( ext_bound.objid != NULL_OBJID )
      {
         action= 0;	//c action set to clear
         prop    = GRIS_DISPLAYABLE | GRIS_LOCATABLE;
         status  = om$send( msg = message GRgraphics.GRchgprops
                                        ( msg, &action, &prop),
                        senderid = NULL_OBJID,
                        targetid = ext_bound.objid,
                        targetos = ext_bound.osnum);
         __CheckRC( status, *msg, "GRgraphics.GRchgprops", wrapup );
      } //c if ext_bound exists
   } //c end if 'edge_attrval' are given

   if( num_edges || edge_list )
   {
      IGRint      edge_ind=0;
      struct GRid *edge3D=NULL;
      
      status = VSgetChildrenGoThruPretends( msg, &surfObj.obj_id, 
					&numMacros,  &edge3D );
      __CheckRC( status, *msg, "VSgetChildrenGoThruPretends", wrapup ) ;

      for( i=0; i<numMacros; ++i )
      {
         if( vs$is_ancestry_valid(    object  = &edge3D[i],
                                      classid = OPP_VSedge3Datt_class_id ) )
	 {
	    edge3D[edge_ind++] = edge3D[i];
         }
      }
      if( num_edges ) *num_edges = edge_ind;
      if( edge_list )
      {
         if( !( (*edge_list) = _MALLOC( edge_ind, struct GRid ) ) )
		vs$mem_fail( sts = status ) ;
	 for( i=0; i<edge_ind; ++i )
	 {
	    (*edge_list)[i] = edge3D[i];
	 }
      }
      _FREE( edge3D );
   }

   status = OM_S_SUCCESS;

#if 0
  nb_edge = nb_edge - already_placed;
  ex$message(msgnumb = VL_E_EdgeAttPlaced,type="%d",var=`nb_edge`);
  if (already_placed)
    ex$message(msgnumb = VL_E_EdgeAttAlDef,type="%d",var=`already_placed`);
#endif

wrapup:	
   if( is_holplate )
   {
      _FREE(pars) ;
      _FREE(intpars) ;
      _FREE(edList) ;
   }

   return ( status );
}

IGRlong  VSget_attrvals_from_edge   ( 	IGRlong            *msg,
					struct GRid        edge_obj,
					struct edge_set    *edge_attrvals )
{
   IGRlong          status;
   IGRint           loc_sts, nb_attr=0;
   struct GRid      attr_col;
   struct ACrg_coll ACrg[ATT_NB_ATT];

   status = om$send(msg=message ACcpx.ACfind_exp_temp_obj(
                                          &loc_sts, ATT_T_IDX_BOX, &attr_col),
			senderid = NULL_OBJID,
                	targetid = edge_obj.objid,
                	targetos = edge_obj.osnum  );
   __CheckRC( status, loc_sts, "Finding the attr collection", wrapup );
   __DBGpr_obj( "Edge attr collection : ", attr_col );

   /* find attributes */
   status = om$send(msg = message ACrg_collect.AClist_attribute
                              ( msg, ATT_NB_ATT, ACrg,&nb_attr ),
			senderid = NULL_OBJID,
                       targetid = attr_col.objid,
                       targetos = attr_col.osnum);
   __CheckRC( status, *msg, "ACrg_collect.AClist_attribute", wrapup );

   status = VSchange_edgestructure( msg, 0, edge_attrvals, ACrg );
   __CheckRC( status, *msg, "VSchange_edgestructure", wrapup );

wrapup:
   return status;
}

IGRlong  VSput_attrvals_to_edge     (  	IGRlong            *msg,
					struct GRid        edge_obj,
					struct edge_set    edge_attrvals )
{
   IGRlong          status;
   IGRint           loc_sts, b_mod,cn_type;
   struct GRid      attr_col, old_col;
   struct ACrg_coll ACrg[ATT_NB_ATT];
   struct edge_set  old_attrvals;

   status = VSget_attrvals_from_edge( msg, edge_obj, &old_attrvals );
   __CheckRC( status, *msg, "VSget_attrvals_from_edge", wrapup );

   if( 	(edge_attrvals.T != old_attrvals.T) ||
       	(edge_attrvals.H != old_attrvals.H) ||
       	(edge_attrvals.C != old_attrvals.C) ||
       	(edge_attrvals.N != old_attrvals.N) ||
       	(edge_attrvals.X != old_attrvals.X) ||
       	(edge_attrvals.Y != old_attrvals.Y) ||
       	(edge_attrvals.L_BASE != old_attrvals.L_BASE) ||
       	(edge_attrvals.L_OFF  != old_attrvals.L_OFF)  ||
       	(edge_attrvals.S_BASE != old_attrvals.S_BASE) ||
       	(edge_attrvals.S_OFF  != old_attrvals.S_OFF)  ||
       	(edge_attrvals.V != old_attrvals.V) ||
       	(edge_attrvals.A != old_attrvals.A) ||
       	(edge_attrvals.B != old_attrvals.B) ||
        (edge_attrvals.DTHK != old_attrvals.DTHK) ||
       	(edge_attrvals.allowance    != old_attrvals.allowance    ) ||
	(edge_attrvals.add_material != old_attrvals.add_material ) ||
	(edge_attrvals.groove_type  != old_attrvals.groove_type  ) ||
	!strcmp( edge_attrvals.process,  old_attrvals.process )    ||
	!strcmp( edge_attrvals.spec_ind, old_attrvals.spec_ind )	)
   {
      attr_col.objid = NULL_OBJID;
      attr_col.osnum = edge_obj.osnum;
      status = om$construct(classid = OPP_ACrg_collect_class_id,
                              osnum   = attr_col.osnum,
                              p_objid = &attr_col.objid);
      __CheckRC( status, 1, "om$construct: ACrg_collect", wrapup );

      status = om$send( msg = message NDnode.NDchg_state(
					ND_DEL_NO_CH, ND_DEL_NO_CH ),
				senderid = NULL_OBJID,
                 		targetid = attr_col.objid,
                 		targetos = attr_col.osnum );
      __CheckRC( status, 1, "NDnode.NDchg_state", wrapup );

      status = VSchange_edgestructure( msg, 1, &edge_attrvals, ACrg );
      __CheckRC( status, *msg, "VSchange_edgestructure", wrapup );

      status = om$send( msg = message ACrg_collect.ACadd_list_attribute
                         		( msg, ATT_NB_ATT, ACrg),
			 	senderid = NULL_OBJID,
                         	targetid = attr_col.objid,
                         	targetos = attr_col.osnum);
      __CheckRC( status, *msg, "ACrg_collect.ACadd_list_attribute", wrapup );

      status = om$send( msg=message ACcpx.ACfind_exp_temp_obj(
                                          &loc_sts, ATT_T_IDX_BOX, &old_col),
				senderid = NULL_OBJID,
                		targetid = edge_obj.objid,
                		targetos = edge_obj.osnum  );
      __CheckRC( status, loc_sts, "Finding the attr collection", wrapup );

      status = om$send( msg = message NDnode.NDchange_connect
               				( 1, &old_col, &attr_col ),
				senderid = NULL_OBJID,
                      		targetid = edge_obj.objid,
                      		targetos = edge_obj.osnum  );
      __CheckRC( status, 1, "NDnode.NDchange_connect", wrapup );

      /* Recompute the object */
      cn_type    = ND_COMP;
      status = nd$wait_batch(type        = GR_GEOM_POSTED,
                             nb_obj      = 1,
                             l_object    = &edge_obj,
                             l_obj_info  = &cn_type   );

      nd$mod_batch(request     = ND_INQ,
                   p_ret_mode  = &b_mod );
      if( b_mod != ND_DEFER )  nd$exec_batch();
   }
wrapup:
   return status;
}

end implementation Root;
