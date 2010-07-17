/* $Id $  */
/* --------------------------------------------------------------------
 * I/LOFT
 *
 * File:        src/pin_jig/VLsbPlace.I
 *
 * Description: Set of Functions to extract Steel bands from Units.
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log $
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *      05/23/00        Rama Rao        File Creation.
 *      10/16/00        ah              Added env to VDdrawCurve
 * -------------------------------------------------------------------*/

class implementation VDSroot;

#include "bserr.h"
#include "bscveval.h"
#include "bsdotp.h"
#include "bsmkvec.h"
#include "bsnorvec.h"
#include "bsbxint.h"
#include "bsdistptpt.h"
#include "nddef.h"
#include "asmacros.h"
#include "EMSmsgdef.h"
#include "EMSutlmacros.h"
#include "EMSssprops.h"
#include "VDobj.h"
#include "VDtypedef.h"
#include "VDefp.h"
#include "VDgeom.h"
#include "VDchn.h"
#include "VDexp.h"
#include "v_datamacros.h"
#include "v_miscmacros.h"
#include "vsgeommacros.h"
#include "vsplatedef.h"
#include "vlforkmacros.h"
#include "vlsband.h"
#include "vldbgmacros.h"

#define vdsDEBUG	1
#define vdserrDEBUG	1

#define DEBUG		0

#define MAX_PLATE_THICKNESS	25.0

from    VSfeature	import	VSforwardToOriginal;
from	VLjunction	import	ACget_named_attribute, ACmod_list_attribute;
from	EMSsubbs	import	EMget_point_on_surface, EMget_props;
from	ACrg_collect	import	AClist_attribute;
from	GR3dpoint	import	GRaltconstruct;
from    GRcurve		import	GRptextend;

extern GRclassid	OPP_VSplate_class_id,   OPP_ACpretendin_class_id,
			OPP_VLwatLine_class_id, OPP_GR3dpoint_class_id,
			OPP_VLmrkLine_class_id, OPP_SMSfBnd_class_id,
			OPP_SMSpltSrf_class_id;

static int VLobjCmp( O1, O2 )

#if defined(__STDC__) || defined(__cplusplus)
        const
#endif

void    *O1,
        *O2 ; {

        const struct GRobj_env       *o1 = (const struct GRobj_env *) O1,
                                     *o2 = (const struct GRobj_env *) O2 ;

               if( o1->_osnum <  o2->_osnum )             return -1 ;
          else if( o1->_osnum == o2->_osnum ) {
                     if( o1->_objid <  o2->_objid )       return -1 ;
                else if( o1->_objid == o2->_objid )       return  0 ;
                else                                    return  1 ;
        } else                                          return  1 ;

} /* VLobjCmp */

void VLrmDupObjsInList( IGRint			count, 
			struct GRobj_env	*list, 
			IGRint			*newcount )
{
IGRint 	i;

    if( count == 1 ) 
    {
          *newcount = 1 ;
    } 
    else 
    {
          qsort( list, (unsigned) count, sizeof *list, VLobjCmp ) ;

          *newcount = 1 ;
          for( i = 1 ; i < count ; i++ ) {
               if( !IF_EQ_GRID( list[i-1].obj_id, list[i].obj_id ) ) {
                     list[(*newcount)++] = list[i] ;
               }
          }
    }
} /* VLrmDupObjsInList */

long VLgetListeningPretends( msg, notifier, count, list )

long                    *msg ;
const struct GRid       *notifier ;
int                     *count ;
struct GRid             **list ; {

        /*
         * Get all ACpretendin objects on the notifier's notification
         * channel.
         */
        long            sts ;
        int             i,
                        cnt ;
        struct GRid     *listeners = NULL ;

        *list = NULL ; *count = 0 ;

        { OM_S_CHANSELECT notification ;
          ems$make_chanselect( chan_label    = GRnotify_notification,
                               chan_selector = &notification ) ;
          sts = VS_GetChanObjWithMalloc( notifier,
                                         &notification,
                                         &cnt,
                                         &listeners ) ;
        }
        if( !sts ) {
                /*
                 * Not a notifier ? (eg. ASsources are not notifiers...).
                 */
                *msg = MSSUCC ; sts = OM_S_SUCCESS ; goto wrapup ;
        }

        for( i = 0 ; i < cnt ; i++ ) {
                if( vd_$is_ancestry_valid(
                                object  = listeners + i,
                                classid = OPP_ACpretendin_class_id ) ) {
                        (*count)++ ;
                } else {
                        listeners[i].objid = NULL_OBJID ;
                }
        }

        /*
         * Shrink list.
         */
        if( *count ) {

                int j = 0 ;
                for( i = 0 ; i < cnt ; i++ ) {
                        if( !IF_NULL_OBJID( listeners[i].objid ) ) {
                                listeners[j++] = listeners[i] ;
                        }
                }
        } else {
                if( cnt ) _FREE( listeners ) ; listeners = NULL ;
        }
        sts     = OM_S_SUCCESS ;
        *msg    = MSSUCC ;
        *list   = listeners ;

        wrapup :
                return sts ;

} /* VLgetListeningPretends */

IGRlong	VLgetPlatesThroughPretends(	IGRlong			*msg,
					struct GRobj_env	*object,
					IGRint			*count,
					struct GRobj_env	**list  )
{
IGRlong         sts;
IGRint		sameOScount, othrOScount, loc_count;
struct GRid	*sameOSchildren=NULL, *othrOSchildren=NULL;

   *count = sameOScount = othrOScount = loc_count = 0;
   *list  = NULL;

   /* Get the children in the same OS as source plate */
   sts = om$send(  msg     = message NDnode.NDget_objects(
                                                ND_CHILDREN | ND_IN_BUF,
                                                NULL,
                                                0,
                                                &sameOSchildren,
                                                /* from = */ 0,
                                                /* to   = */ OM_K_MAXINT,
                                                &sameOScount ),
                        senderid= object->_objid,
                        targetid= object->_objid,
                        targetos= object->_osnum ) ;
   __CheckRC( sts, 1, "NDnode.NDget_objects", wrapup ) ;
   __DBGpr_int("Number of Children in the same OS ", sameOScount );

   sts = VLgetListeningPretends(   msg,
                                   object,
                                   &othrOScount,
                                   &othrOSchildren ) ;
   __CheckRC( sts, *msg, "VLgetListeningPretends", wrapup ) ;
   __DBGpr_int("Number of Children in the other OS ", othrOScount );

   loc_count = sameOScount + othrOScount ;

   if( loc_count ) {
      int     		i, j, k ;
      struct GRobj_env	temp_obj;

      if( !( *list = _MALLOC( loc_count, struct GRobj_env ) ) ) {
            loc_count = 0 ;
            vd_$mem_fail() ;
      }

      i = 0 ;
      for( j = 0 ; j < sameOScount ; j++ ) {
   	if ( vd_$is_ancestry_valid(  object  = &sameOSchildren[j],
                                     classid = OPP_VSplate_class_id ) )
	{
    	    (*list)[i].obj_id  = sameOSchildren[j]; 
    	    (*list)[i++].mod_env = object->mod_env;
	}
      }
      _FREE( sameOSchildren );

      for( j = 0 ; j < othrOScount ; j++ ) {
	sts = om$send ( msg =  message NDnode.NDget_objects(
                                                ND_CHILDREN,
						&temp_obj.obj_id,
                                                1,
                                                NULL,
                                                0,
                                                OM_K_MAXINT,
                                                &k ),
                senderid = NULL_OBJID,
                targetid = othrOSchildren[j].objid,
                targetos = othrOSchildren[j].osnum );
	temp_obj.mod_env = object->mod_env;
        if ( vd_$is_ancestry_valid(  object  = &temp_obj.obj_id,
                                     classid = OPP_VSplate_class_id ) )
        {
            (*list)[i++]  = temp_obj;
        }
      }
      _FREE( othrOSchildren ) ;
      *count = i;
   }

wrapup:
   _FREE( sameOSchildren );
   _FREE( othrOSchildren ) ;
   return sts;

}

static IGRlong	VLsbIsOnCenterLine( IGRlong                 *msg,
				    IGRint		    neat_ft_count,
				    struct GRid		    *neat_feet,
				    struct GRmd_env	    *md_env,
				    IGRint		    *on_centerline )
{
IGRlong			sts;
IGRint			i, not_first;
IGRshort		world=TRUE;
GRrange			loc_range, range;

   SetProc( VLsbIsOnCenterLine ); Begin

   sts = *msg = MSSUCC;

   if( !msg || !neat_ft_count || !neat_feet || !on_centerline )
   {
        sts = OM_E_INVARG;
        goto wrapup;
   }

   *on_centerline = FALSE;
   not_first = FALSE ;

   for( i=0; i<neat_ft_count; ++i )
   {
      sts = om$send ( msg = message GRvg.GRgetrang( msg, 
				&md_env->md_env.matrix_type, 
				 md_env->md_env.matrix, &world, loc_range ),
			senderid = NULL_OBJID,
                        targetid = neat_feet[2*i].objid,
                        targetos = neat_feet[2*i].osnum ); 
      if( !(sts&1&(*msg)) ) continue;
      if( not_first ) GRaccumulate_range( msg, loc_range, range );
      else
      {
          not_first = TRUE ;
          dblcpy( range, loc_range, 6 );
      }
   }

   if( ( range[1] < 1e-3 ) && ( range[4] > 1e-3 ) ) *on_centerline = TRUE;
   else                                             *on_centerline = FALSE;

wrapup:
   End
   return sts;
}

IGRlong VSsbGetAllActivePlatesOnPlate( 	IGRlong                	*msg,
					struct GRobj_env	*inp_plate,
					IGRint                 	*nb_plates,
					struct GRobj_env       	**plates )	
{
IGRlong 		sts;
IGRint			i, count=0, loc_nb_plates=0;
struct GRobj_env	src_plate, *children=NULL;

   SetProc( VSsbGetAllActivePlatesOnPlate ); Begin

   if( !msg || !inp_plate || !nb_plates || !plates )
   {
	sts = OM_E_INVARG;
	goto wrapup;
   }

   src_plate = *inp_plate;

   if ( !vd_$is_ancestry_valid(  object  = &src_plate.obj_id,
				 classid = OPP_VSplate_class_id ) )
   {
        sts = OM_E_INVARG;
        goto wrapup;
   }

   sts = VLgetPlatesThroughPretends( msg, &src_plate, &count, &children );
   __CheckRC( sts, *msg, "VLgetPlatesThroughPretends", wrapup );

   __DBGpr_int("Plate Children Count ", count );
   if( !count ) goto wrapup;

   for( i=0; i<count; ++i )
   {
	__DBGpr_obj("Child Plate ", children[i].obj_id );
	if( !(*plates) )
	{
	   if( !( *plates = _MALLOC( 10, struct GRobj_env)) ) vd_$mem_fail();
	}

	if( ((*nb_plates)%10) == 9 )
	{
	   if( !( *plates = _REALLOC( *plates, (*nb_plates)+10, 
				      struct GRobj_env)) ) vd_$mem_fail() ;
	}
	(*plates)[(*nb_plates)++] = children[i];	
	VSsbGetAllActivePlatesOnPlate( msg, children+i, nb_plates, plates );
   }

wrapup:
   _FREE( children );
   End
   return sts;
}


IGRlong	VSsbGetAllActivePlates( IGRlong			*msg,
			   	struct GRobj_env	*inp_surface,
				struct GRobj_env	*inp_plate,  
				IGRint			*nb_plates,
				struct GRobj_env	**plates )
{
IGRlong			sts, isConsumed=0;
IGRint			i, count=0, loc_nb_plates=0;
struct GRid		context_id;
struct GRobj_env	surface, source_plate, *children=NULL;

   SetProc( VSsbGetAllActivePlatesOnSurface ); Begin

   sts = MSSUCC;
   *nb_plates = 0;
   *plates = NULL;

   if( !msg || ( !inp_plate && !inp_surface ) || !nb_plates || !plates )
   {
        sts = OM_E_INVARG;
        goto wrapup;
   }
   if( inp_surface )
   {
/*
       context_id.objid = NULL_OBJID;
       ASget_source( &inp_surface->obj_id, &context_id, 
		     &surface.obj_id, inp_surface->_md_os );
       __DBGpr_obj("Input Surface ",  surface.obj_id );
       surface.mod_env = inp_surface->mod_env;
*/
       surface = *inp_surface;
       __DBGpr_obj("Input Surface ",  inp_surface->obj_id );
/*
       gr$get_module_env (buffer = &surface.mod_env );
       as$make_source( 	go_grid = inp_surface->obj_id,
			mod_env = &inp_surface->mod_env,
			as_os   = &surface._md_os,
			as_grid = &surface.obj_id );	
       __DBGpr_obj("Associative Surface ",  surface.obj_id );
*/

       sts = VLgetPlatesThroughPretends( msg, &surface, &count, &children );
       __CheckRC( sts, *msg, "VLgetPlatesThroughPretends", wrapup );
       __DBGpr_int("Number of Plates on the selected surface ", count );
       if( !count ) goto wrapup;

       source_plate = children[0];
       __DBGpr_obj("Source Plate On the Surface ", source_plate.obj_id );
   }
   else if( inp_plate )
   {
       source_plate = *inp_plate;
       __DBGpr_obj("Input Plate ",  source_plate.obj_id );
   }

   sts = VSsbGetAllActivePlatesOnPlate( msg, &source_plate, 
					&loc_nb_plates, plates);
   __CheckRC( sts, *msg, "VSsbGetAllActivePlatesOnPlate", wrapup );
   VLrmDupObjsInList( loc_nb_plates, *plates, &loc_nb_plates );

   for( i=0; i<loc_nb_plates; ++i )
   {
	isConsumed = 0;
        sts = om$send(  msg     = message NDmacro.ACtest_consumed(&isConsumed),
                        senderid = NULL_OBJID,
                        targetid = (*plates)[i]._objid,
                        targetos = (*plates)[i]._osnum  );
        if((sts&1) && (!isConsumed)) (*plates)[(*nb_plates)++] = (*plates)[i] ;
   }

wrapup:
   _FREE( children );
   End
   return sts;
}

IGRlong		VSsbGetEJEdgeIndex(	IGRlong                 *msg,
					IGRint			nb_edges,
					struct IGRbsp_curve	**edges,
					IGRdouble		*vector,
					IGRint			*index )
{
BSrc		rc;
IGRlong		sts;
IGRint		i, i1, i2;
IGRdouble	dotp, mid_vec[3], mid_pt[6], eval[6];

   SetProc( VSsbGetEJEdgeIndex ); Begin

   sts = *msg = MSSUCC;
   __DBGpr_vec("Input Direction Vector ", vector );

   i1 = i2 = -1;
   for( i=0; i<nb_edges; ++i )
   {
       	BScveval( edges[i], 0.5, 1, (IGRpoint *)eval, &rc );
	if( rc != BSSUCC ) continue;	
	BSnorvec( &rc, &eval[3] );

	dotp = BSdotp( &rc, &eval[3], vector );
	__DBGpr_dbl("Dot Product ", dotp );
	if( fabs(dotp) < 0.5 )
	{
	   if( i1 == -1 )
	   {
		i1 = i;
		dblcpy( &mid_pt[0], &eval[0], 3 );
	   }
	   else if( i2 == -1 )
           {
                i2 = i;
                dblcpy( &mid_pt[3], &eval[0], 3 );
           }

	}
   }
   if( i1 == -1 || i2 == -1 ) goto wrapup;

   __DBGpr_int("First Curve Index ", i1 );
   __DBGpr_int("Second Curve Index ", i2 );

   __DBGpr_vec("Mid Point 1 ", &mid_pt[0] );
   __DBGpr_vec("Mid Point 2 ", &mid_pt[3] );
   BSmkvec ( &rc, &mid_vec[0], &mid_pt[0], &mid_pt[3] );
   BSnorvec( &rc, &mid_vec[0] );
   __DBGpr_vec("Mid Point Vector ", &mid_vec[0] );
   dotp = BSdotp( &rc, &mid_vec[0], vector );
   __DBGpr_dbl("Dot Product ", dotp );

   if( dotp < 0 ) 	*index = i1;
   else			*index = i2;

wrapup:
   End
   return sts;
}

static IGRlong	VSsbCreateEdge(	IGRlong			*msg,
				struct GRid		*sb_mac,
				struct GRobj_env	*gr_obj,
				struct GRid		*edgeId )
{
IGRlong			sts;
IGRint			i, nb_sb_attr=0, nb_pb_attr=0;
struct GRobj_env	pl_bandOE, boxOE;
struct ACrg_coll	sb_attrib[3], attrib[20];
struct ret_struct       expr;

   SetProc( VSsbCreateEdge ); Begin
   sts = *msg = MSSUCC;
   __DBGpr_obj("Input Steel Band Macro ", *sb_mac );

   *edgeId = gr_obj->obj_id;
   pl_bandOE._objid = NULL_OBJID;
   vdobj$GetTemplate( objID      = sb_mac,
		      nth        = 0,
		      templateOE = &pl_bandOE );
   __DBGpr_obj("Parent Plate Band Macro ", pl_bandOE.obj_id );
   if( pl_bandOE._objid == NULL_OBJID ) goto wrapup;

   boxOE._objid = NULL_OBJID;
   vdobj$GetTemplate( objID = &pl_bandOE.obj_id,
                      nth   = 1,
                      templateOE = &boxOE );
   __DBGpr_obj("Plate Band: Parent Attribute Box ", boxOE.obj_id );
   if( boxOE._objid == NULL_OBJID ) goto wrapup;

   sts = om$send ( msg =  message ACrg_collect.AClist_attribute(
				msg, 7, attrib, &nb_pb_attr ),
		senderid = NULL_OBJID,
		targetid = boxOE._objid,
		targetos = boxOE._osnum ); 
   if( !(sts&(*msg)&1) ) goto wrapup;
   __DBGpr_int("Number Of Attributes in Plate Band Collector ", nb_pb_attr );

   boxOE._objid = NULL_OBJID;
   vdobj$GetTemplate( objID = sb_mac,
                      nth   = 1,
                      templateOE = &boxOE );
   __DBGpr_obj("Steel Band: Parent Attribute Box ", boxOE.obj_id );
   if( boxOE._objid == NULL_OBJID ) goto wrapup;

   sts = om$send ( msg =  message ACrg_collect.AClist_attribute(
                                msg, 3, sb_attrib, &nb_sb_attr ),
                senderid = NULL_OBJID,
                targetid = boxOE._objid,
                targetos = boxOE._osnum );
   if( !(sts&(*msg)&1) ) goto wrapup;
   __DBGpr_int("Number Of Attributes in Steel Band Collector ", nb_sb_attr );

   for( i=0; i<nb_sb_attr; ++i )
   {
	attrib[nb_pb_attr] = sb_attrib[i];
	nb_pb_attr++;
   }

   sts = om$send( msg = message  ACcpx.ACfind_temp_struct( (int *)msg, "EJ_dir",
					&expr,&gr_obj->mod_env ),
		senderid = NULL_OBJID,
                targetid = sb_mac->objid,
		targetos = sb_mac->osnum );
   if( !(sts&(*msg)&1) ) goto wrapup;
   strcpy( attrib[nb_pb_attr].name, "EJ_dir" ) ;
   attrib[nb_pb_attr].desc.type = AC_ATTRIB_DOUBLE;
   attrib[nb_pb_attr].desc.value.att_exp = expr.var.root_pm_st.value;
   nb_pb_attr++;

   sts = om$send( msg = message  ACcpx.ACfind_temp_struct( (int *)msg, 
				"Flow_dir", &expr,&gr_obj->mod_env ),
                senderid = NULL_OBJID,
                targetid = sb_mac->objid,
                targetos = sb_mac->osnum );
   if( !(sts&(*msg)&1) ) goto wrapup;
   strcpy( attrib[nb_pb_attr].name, "Flow_dir" ) ;
   attrib[nb_pb_attr].desc.type = AC_ATTRIB_DOUBLE;
   attrib[nb_pb_attr].desc.value.att_exp = expr.var.root_pm_st.value;
   nb_pb_attr++;

   sts = om$send( msg = message  ACcpx.ACfind_temp_struct( (int *)msg, 
			"WaterLines", &expr,&gr_obj->mod_env ),
                senderid = NULL_OBJID,
                targetid = sb_mac->objid,
                targetos = sb_mac->osnum );
   if( !(sts&(*msg)&1) ) goto wrapup;
   strcpy( attrib[nb_pb_attr].name, "WaterLines" ) ;
   attrib[nb_pb_attr].desc.type = AC_ATTRIB_DOUBLE;
   attrib[nb_pb_attr].desc.value.att_exp = expr.var.root_pm_st.value;
   nb_pb_attr++;

   sts = om$send( msg = message  ACcpx.ACfind_temp_struct( (int *)msg, 
				"MarkingLines", &expr,&gr_obj->mod_env ),
                senderid = NULL_OBJID,
                targetid = sb_mac->objid,
                targetos = sb_mac->osnum );
   if( !(sts&(*msg)&1) ) goto wrapup;
   strcpy( attrib[nb_pb_attr].name, "MarkingLines" ) ;
   attrib[nb_pb_attr].desc.type = AC_ATTRIB_DOUBLE;
   attrib[nb_pb_attr].desc.value.att_exp = expr.var.root_pm_st.value;
   nb_pb_attr++;

   strcpy( attrib[nb_pb_attr].name, NAM_SBJ_NAM );
   attrib[nb_pb_attr].desc.type = AC_ATTRIB_TEXT;
   strcpy( attrib[nb_pb_attr].desc.value.att_txt, ":Steel Band Edge" );
   nb_pb_attr++;

   sts = vl$createLoftFork (    msg     = msg,
                                graphic = gr_obj,
                                attr    = attrib,
                                number  = nb_pb_attr,
                                Env     = &gr_obj->mod_env,
                                forkId  = edgeId );

wrapup:
   End
   return sts;
}

IGRlong		VSsbGetCornerAndEdge(	IGRlong			*msg,
					struct GRobj_env	*surf,
					struct GRid		*sb_mac,
					IGRint			dir,
					IGRint			pt_dir,
					struct GRid		*edgeId,
					struct GRid		*pt_id )
{
BSrc			rc;
IGRlong			sts;
IGRint			i, edgeCnt=0, index=0, numRealEdges=0;
IGRdouble               dotp, tol=0.0;
IGRuchar                weight=3;
IGRvector		vec, pt_vec, mid_vec;
IGRpoint		spt, ept, start_point;
struct IGRbsp_curve     *edgeGeom[VDEFP_NEAT_EDGES_MAX], 
			**realEdgeGeom=NULL, **crvGeom=NULL;
struct GRvg_construct   cnst;
struct IGRpolyline      lstr_geom;
struct GRobj_env	gr_obj, grEdge;

   SetProc( VSsbGetCornerAndEdge ); Begin

   *msg = MSSUCC;
   vec[0] = vec[1] = vec[2] = pt_vec[0] = pt_vec[1] = pt_vec[2] = 0.0;
   __DBGpr_obj("Input Surface ",  surf->obj_id );
   __DBGpr_int("Work Flow Direction ", dir );

   switch( dir )
   {
        case FWD:       vec[0] =  1.0;  break;
        case AFT:       vec[0] = -1.0;  break;
        case OB:        vec[1] =  1.0;  break;
        case IB:        vec[1] = -1.0;  break;
        case UPP:       vec[2] =  1.0;  break;
        case DWN:       vec[2] = -1.0;  break;
        default:
                printf("Invalid Work Flow Direction\n" );
		goto wrapup;
   }

   switch( pt_dir )
   {
        case FWD:       pt_vec[0] =  1.0;  break;
        case AFT:       pt_vec[0] = -1.0;  break;
        case OB:        pt_vec[1] =  1.0;  break;
        case IB:        pt_vec[1] = -1.0;  break;
        case UPP:       pt_vec[2] =  1.0;  break;
        case DWN:       pt_vec[2] = -1.0;  break;
        default:
                printf("Invalid Work Flow Direction\n" );
                goto wrapup;
   }

   sts = om$send( msg = message NDnode.ASreturn_go( &gr_obj.obj_id,
                                   &gr_obj._matrix_type, gr_obj._matrix ),
                senderid = NULL_OBJID,
                targetid = surf->_objid,
                targetos = surf->_osnum  );
   if( sts&1 )
   {
      gr_obj._md_os = gr_obj._osnum;
      sts = ex$get_modid( mod_osnum = gr_obj._md_os,
                          mod_id    = &gr_obj._md_id );
   }
   else gr_obj = *surf;
   sts = MSSUCC;

   vdgeom$GetTolerance(cht = &tol);
   __DBGpr_dbl("Chord Height Tolerance ", tol );

   sts = VDefpGetSurfaceEdgeBsps( &gr_obj, VDEFP_NEAT_EDGES_MAX,
                        tol, &edgeCnt, edgeGeom );
   __CheckRC( sts, 1, "VDefpGetSurfaceEdgeBsps", wrapup );
   __DBGpr_int("Number Of Neat Edges ", edgeCnt );

   if( edgeCnt < 4 )
   {
      sts = *msg = MSFAIL;
      goto wrapup;
   }
   else if( edgeCnt > 4 )
   {
      BSsidecntrs( edgeCnt, edgeGeom, FALSE, 0.5, &numRealEdges,
	           &realEdgeGeom, msg ) ;
      if( *msg != BSSUCC ) { *msg = MSFAIL; goto wrapup; }
      numRealEdges++;
      __DBGpr_int("Number Of Edges after BSsidecntrs ", numRealEdges );
      crvGeom = realEdgeGeom ;
   }
   else 
   {
      numRealEdges = edgeCnt ;
      crvGeom = edgeGeom ;
   }

   sts = VSsbGetEJEdgeIndex( msg, numRealEdges, crvGeom, vec, &index );
   __CheckRC( sts, *msg, "VSsbGetEJEdgeIndex", wrapup );
   __DBGpr_int("EJ Edge Index ", index );

   MAbcendpts( msg, crvGeom[index], spt, ept );

   BSmkvec ( &rc, &mid_vec[0], spt, ept );
   BSnorvec( &rc, &mid_vec[0] );
   __DBGpr_vec("Start Point Vector ", &mid_vec[0] );
   dotp = BSdotp( &rc, &mid_vec[0], pt_vec );
   __DBGpr_dbl("Dot Product ", dotp );

   if( dotp < 0 )  {   dblcpy( start_point, spt, 3 );  }
   else            {   dblcpy( start_point, ept, 3 );  } 

   __DBGpr_vec("Start Point For Steel Band ", start_point );

   VLinitCnst( &cnst );

   /* 16 Oct 2000 - Added env */
   VDdrawCurve( crvGeom[index], cnst.env_info, &grEdge.obj_id );
   grEdge.mod_env = *cnst.env_info;

   sts = VSsbCreateEdge( msg, sb_mac, &grEdge, edgeId );
   __CheckRC( sts, *msg, "VSsbCreateEdge", wrapup ); 

   sts = om$send(  msg      = message GRvg.GRchgweight( msg,
							&weight ),
			senderid = NULL_OBJID,
			targetid = edgeId->objid,
			targetos = edgeId->osnum );

   pt_id->objid    = NULL_OBJID;
   pt_id->osnum    = cnst.env_info->md_id.osnum;
   cnst.geometry   = (IGRchar *) &lstr_geom;
   cnst.display->weight = 8;

   sts = om$construct(     classid = OPP_GR3dpoint_class_id,
                                osnum   = pt_id->osnum,
                                p_objid = &pt_id->objid );
   if( sts & 1 ){
                lstr_geom.num_points    = 1;
                lstr_geom.points        = start_point;
                sts = om$send(  msg      = message GRgraphics.GRaltconstruct
                                                ( &cnst ),
                                senderid = NULL_OBJID,
                                targetid = pt_id->objid,
                                targetos = pt_id->osnum );
   }


wrapup:
   for( i=0; i<numRealEdges; ++i )   _FREE( edgeGeom[i] );
   if( realEdgeGeom )
   {
       for(i=0; i<numRealEdges; i++ )
       {
	   if( realEdgeGeom[i] )
	   {
	       BSfreecv( msg, realEdgeGeom[i] );
	       realEdgeGeom[i] = NULL ;
	   }
       }
   }

   End
   return sts;
}

static IGRint	VLsortSBJunction( struct GRid	*obj1, 
				  struct GRid	*obj2 )
{
IGRlong			sts, msg;
IGRdouble		len1=0.0, len2=0.0;
struct  ACrg_coll 	attrib;

   strcpy( attrib.name, NAM_SBJ_LEN );
   sts = om$send(  msg      = message VLjunction.ACget_named_attribute(
				&msg, &attrib ),
                   senderid = NULL_OBJID,
                   targetid = obj1->objid,
                   targetos = obj1->osnum  );
   len1 = attrib.desc.value.att_exp;

   sts = om$send(  msg      = message VLjunction.ACget_named_attribute(
                                &msg, &attrib ),
                   senderid = NULL_OBJID,
                   targetid = obj2->objid,
                   targetos = obj2->osnum  );
   len2 = attrib.desc.value.att_exp;
   return (( len1 == len2 ) ? 0 : ( len1 < len2 ) ? -1 : 1); 
}


IGRlong	VLsbGetMoldSurface(	IGRlong			*msg,
				struct GRobj_env	*plate,
				enum GRdpmode		mode,
				struct GRobj_env	*surface )
{
BSrc			rc;
IGRlong			sts;
IGRint			ACcount=0, index=-1, size, nret;
IGRdouble		par_u, par_v, dist, thick;
IGRpoint		pt, base_pt, offset_pt;
IGRvector		normal, vec;
unsigned char           props;
GRrange			range;
struct EMparms  	base_params, off_params;
struct GRid		ACpretend;
struct GRobj_env	base_surface_id, offset_surface_id, par_srf;
struct ret_struct       attrVal;
struct IGRbsp_surface	*srf_geom=NULL;
struct IGRdisplay	display_attr;
struct GRmd_env         dspEnv ;

   SetProc( VLsbGetMoldSurface ); Begin

   __DBGpr_obj("Input Plate ", plate->obj_id );

   size = sizeof( struct IGRdisplay ) ;

   gr$get_active_display( msg    = msg,
                          sizbuf = &size,
                          nret   = &nret,
                          buffer = &display_attr ) ;
   display_attr.weight = 3;

   if( !vd_$is_ancestry_valid( 	object  = &plate->obj_id,
				classid = OPP_VSplate_class_id )	)
   {
        VSdisplaySurfaceNormal( msg, plate, 0, &display_attr, GRhd );
        sts = MSSUCC ;
	goto wrapup;
   }

   sts = om$send( msg = message NDmacro.ACgive_structure(
			(int *)msg, &index, VS_K_plThcknsAttr, &attrVal, NULL ),
                       senderid = plate->_objid,
                       targetid = plate->_objid,
                       targetos = plate->_osnum ) ;
   __CheckRC( sts, *msg, "NDmacro.ACgive_structure", wrapup ) ;
   thick = attrVal.var.root_pm_st.value;
   __DBGpr_dbl("Plate Thickness ", thick );

   sts = om$send( msg = message NDmacro.ACreturn_foot( msg, VS_K_plBotSfPath,
			&base_surface_id.obj_id, &base_surface_id._matrix_type,
			base_surface_id._matrix ),
                       senderid = plate->_objid,
                       targetid = plate->_objid,
                       targetos = plate->_osnum ) ;
   __CheckRC( sts, *msg, "NDmacro.ACreturn_foot:Base", wrapup ) ;
   base_surface_id._md_os = base_surface_id._osnum;
   sts = ex$get_modid( mod_osnum = base_surface_id._md_os,
                       mod_id    = &base_surface_id._md_id );
   __DBGpr_obj("Base Surface Id ", base_surface_id.obj_id );

   sts = om$send( msg = message NDmacro.ACreturn_foot( msg, VS_K_plTopSfPath,
                     &offset_surface_id.obj_id, &offset_surface_id._matrix_type,
                     offset_surface_id._matrix ),
                       senderid = plate->_objid,
                       targetid = plate->_objid,
                       targetos = plate->_osnum ) ;
   __CheckRC( sts, *msg, "NDmacro.ACreturn_foot:Base", wrapup ) ;
   offset_surface_id._md_os = offset_surface_id._osnum;
   sts = ex$get_modid( mod_osnum = offset_surface_id._md_os,
                       mod_id    = &offset_surface_id._md_id );
   __DBGpr_obj("Offset Surface Id ", offset_surface_id.obj_id );

   sts = om$send( msg = message EMSsubbs.EMget_point_on_surface(
		msg, &base_surface_id.mod_env, 0, 1, base_pt, &base_params ),
		senderid = base_surface_id._objid,
		targetid = base_surface_id._objid,
		targetos = base_surface_id._osnum 	);
   __CheckRC( sts, *msg, "EMSsubbs.EMget_point_on_surface", wrapup );

   sts = om$send( msg = message EMSsubbs.EMget_point_on_surface(
                msg, &offset_surface_id.mod_env, 0, 1, offset_pt, &off_params ),
                senderid = offset_surface_id._objid,
                targetid = offset_surface_id._objid,
                targetos = offset_surface_id._osnum       );
   __CheckRC( sts, *msg, "EMSsubbs.EMget_point_on_surface", wrapup );
				
   /* Get the Input Surface Of the Original Source Plate */
   sts = om$send( msg      = message VSfeature.VSforwardToOriginal(
                             msg,
                             OM_e_wrt_object,
                             message NDnode.NDget_objects( ND_ROOT,
                                                           &ACpretend,
                                                           1,
                                                           NULL,
                                                           0,
                                                           0,
                                                           &ACcount )),
                       senderid = plate->_objid,
                       targetid = plate->_objid,
                       targetos = plate->_osnum ) ;
   __CheckRC( sts, *msg, "VSfeature.VSforwardToOriginal", wrapup ) ;
   __DBGpr_obj("Surface Pretend ", ACpretend );

   sts = om$send( msg      = message NDmacro.ACreturn_foot(
				msg, "", &par_srf._grid, &par_srf._matrix_type,
				par_srf._matrix ),
                       senderid = NULL_OBJID,
                       targetid = ACpretend.objid,
                       targetos = ACpretend.osnum ) ;
   __CheckRC( sts, *msg, "NDmacro.ACreturn_foot", wrapup ) ;
   par_srf._md_os = par_srf._osnum;
   sts = ex$get_modid( mod_osnum = par_srf._md_os,
                       mod_id    = &par_srf._md_id );
   __DBGpr_obj("Surface in the model ", par_srf._grid );

   sts = vs$get_geometry(  msg      = msg,
                           grobjId  = &par_srf._grid,
                           grobjEnv = &par_srf.mod_env,
                           geometry = &srf_geom ) ;
   __CheckRC( sts, *msg, "vs$get_geometry", wrapup ) ;

   BSmdistptsf( &rc, srf_geom, base_pt, &par_u, &par_v, &pt, &dist );
   if( rc != BSSUCC ) { sts = MSFAIL; goto wrapup; }
   __DBGpr_dbl("Minimum Distance between point and surafce ", dist );
   _FREE( srf_geom ) ;

   if( dist < ( thick/2.0 ) )  
   {
     sts = om$send(  msg     = message GRvg.GRgenabsg(
                                          msg,
                                          &base_surface_id._matrix_type,
                                          base_surface_id._matrix,
                                          (char **) &srf_geom ),
                        senderid= base_surface_id._objid,
                        targetid= base_surface_id._objid,
                        targetos= base_surface_id._osnum ) ;
     __CheckRC( sts, *msg, "GRvg.GRgenabsg", wrapup ) ;

     EMavgsfnorm( msg, srf_geom, base_params.u, base_params.v, pt, normal ) ;
     __DBGpr_vec("Base Normal ", normal );

     BSmkvec( &rc, vec, base_pt, offset_pt );
     BSnorvec( &rc, vec );
     __DBGpr_vec("Vector Base to Offset ", vec );

     if( BSdotp(&rc, normal, vec ) < 0.0 ) VSnegvc( normal, normal ) ;
     __DBGpr_vec("Mold Surface Normal ", normal );

     vs$getSurfaceRange( msg	 = msg, 
			 surface = &base_surface_id.obj_id, 
			 range   = range );
     sts = om$send(  msg     = message EMSsubbs.EMget_props( msg, &props ),
                        senderid= base_surface_id._objid,
                        targetid= base_surface_id._objid,
                        targetos= base_surface_id._osnum ) ;
     __CheckRC( sts, *msg, "EMSsubbs.EMget_props", wrapup ) ;

     if( props & EMSIS_NRML_REVERSED ) {
          VSnegvc( normal, normal ) ;
     }

     dspEnv = base_surface_id.mod_env ;
     ex$get_cur_mod( id = &dspEnv._MD_ID, osnum = &dspEnv._MD_OS ) ;
     EFdraw_vector_on_screen( base_surface_id._objid, &display_attr, &dspEnv,
                              GRhd, FALSE, base_pt, normal, range, msg ) ;
     if( surface ) *surface = base_surface_id ;
     __DBGpr_com("Base Surface is the Mold Surface ");
   }
   else
   {
     sts = om$send(  msg     = message GRvg.GRgenabsg(
                                          msg,
                                          &offset_surface_id._matrix_type,
                                          offset_surface_id._matrix,
                                          (char **) &srf_geom ),
                        senderid= offset_surface_id._objid,
                        targetid= offset_surface_id._objid,
                        targetos= offset_surface_id._osnum ) ;
        __CheckRC( sts, *msg, "GRvg.GRgenabsg", wrapup ) ;

     EMavgsfnorm( msg, srf_geom, off_params.u, off_params.v, pt, normal ) ;
     BSmkvec( &rc, vec, offset_pt, base_pt );

     if( BSdotp(&rc, normal, vec) < 0.0 ) VSnegvc( normal, normal ) ;

     vs$getSurfaceRange( msg     = msg,
                         surface = &offset_surface_id.obj_id,
                         range   = range );
     sts = om$send(  msg     = message EMSsubbs.EMget_props( msg, &props ),
                        senderid= offset_surface_id._objid,
                        targetid= offset_surface_id._objid,
                        targetos= offset_surface_id._osnum ) ;
     __CheckRC( sts, *msg, "EMSsubbs.EMget_props", wrapup ) ;

     if( props & EMSIS_NRML_REVERSED ) {
          VSnegvc( normal, normal ) ;
     }

     dspEnv = offset_surface_id.mod_env ;
     ex$get_cur_mod( id = &dspEnv._MD_ID, osnum = &dspEnv._MD_OS ) ;
     EFdraw_vector_on_screen( offset_surface_id._objid, &display_attr, &dspEnv,
                              mode, FALSE, offset_pt, normal, range, msg ) ;

     if( surface ) *surface = offset_surface_id ;
     __DBGpr_com("Offset Surface is the Mold Surface ");
   }

   sts = MSSUCC ;

wrapup:
   _FREE( srf_geom ) ;
   End
   return sts;
}

static IGRlong  VLsbGetMarkRefName(	struct GRobj_env        *mold_line,
					IGRchar			*objName,
					IGRchar			*refName )
{
IGRlong			sts, msg, notUsed;
IGRint			ACrc;
IGRchar			*p;
struct GRid		supp_srf;
struct GRobj_env	plateOE, srf;

   sts = msg = MSSUCC;

   strcpy( refName, objName );
   __DBGpr_obj("Input Marking Line ", mold_line->obj_id );
   vdobj$GetTemplate( objOE       = mold_line,
                      nth         = 2,
                      templateOE  = &plateOE    );
   __DBGpr_obj("Marking Plate ", plateOE.obj_id );

   sts = om$send(  msg = message VSfeature.VSforwardToOriginal(
                    &notUsed,
                    OM_e_wrt_object,
                    message ACcpx.ACfind_temp_obj(
                                        &ACrc,
                                        VS_K_plSuppSurf,
                                        &supp_srf ) ),
            senderid = NULL_OBJID,
            targetid = plateOE._objid,
            targetos = plateOE._osnum  );
   __CheckRC( sts, msg, "ACcpx.ACfind_temp_obj: Support Surface",  wrapup ) ;

   sts = om$send( msg = message NDmacro.ACreturn_foot( &msg, "",
                                        &srf.obj_id, &srf._matrix_type,
                                        srf._matrix ),
                senderid = NULL_OBJID,
                targetid = supp_srf.objid,
                targetos = supp_srf.osnum );
   if( !(sts&1&msg) )
   {
        vdobj$Get  (objOE = &plateOE, objName = refName );
        p = strchr( refName, ':' );
        if( p ) strcpy( refName, p+1 );
        VDstrupr(refName);
        __DBGpr_str("Output Name ", refName );
	return MSSUCC;
   }
   srf._md_os = srf._osnum;
   sts = ex$get_modid( mod_osnum = srf._md_os,
                       mod_id    = &srf._md_id );
   __DBGpr_obj("Parent Surface ", srf.obj_id );
  
   if( DEBUG ) vdobj$Print( objOE = &srf );
 
   if( vd_$is_ancestry_valid( object  = &srf.obj_id,
			      classid = OPP_SMSpltSrf_class_id ) ||
       vd_$is_ancestry_valid( object  = &srf.obj_id,
                              classid = OPP_SMSfBnd_class_id ) )
   {
        vdobj$Get  (objOE = &srf, objName = refName );
        p = strchr( refName, ':' );
       	if( p ) strcpy( refName, p+1 );
       	VDstrupr(refName);
	__DBGpr_str("Output Name ", refName );
   }
   else
   {
        vdobj$Get  (objOE = &plateOE, objName = refName );
        p = strchr( refName, ':' );
        if( p ) strcpy( refName, p+1 );
        VDstrupr(refName);
        __DBGpr_str("Output Name ", refName );
   }

wrapup:
   return sts;
}

static IGRlong	VLsbCreateJunction(	IGRlong                 *msg,
					struct GRobj_env	*srfEdge,
					struct GRobj_env	*mold_line,
					struct GRid		*pt1,
					struct GRid             *pt2,
					struct GRmd_env		*env,
					IGRchar			*name,
					struct GRid		*junction )
{
IGRlong			sts;
IGRdouble		length=0.0;
GRname          	objName, refName;
IGRchar			*p=NULL;
struct ACrg_coll        elem[IDX_SBJ_ATTR];
struct GRobj_env	jn_graphic, planeOE;

   SetProc( VLsbCreateJunction ); Begin

   sts = *msg = MSSUCC;

   sts = VLlengthAlongCv( msg, &srfEdge->obj_id, &srfEdge->mod_env, pt1, env,
			  pt2, env, &length );
   __DBGpr_dbl("Length Between Points ", length );

   if( !name && mold_line )
   {
      sts = om$send(  msg      = message GRgraphics.GRgetname( msg, objName ),
		   senderid = NULL_OBJID,
		   targetid = mold_line->_objid,
		   targetos = mold_line->_osnum  );
      __DBGpr_str("Mold Line Object Name ", objName );

      if( vd_$is_ancestry_valid(  object  = &mold_line->obj_id,
				  classid = OPP_VLwatLine_class_id ) )
      {
	 p = NULL;
         vdobj$GetTemplate( objOE       = mold_line,
                            nth         = 2,
                            templateOE  = &planeOE    );
         vdobj$Get  (objOE = &planeOE, objName = refName );
         p = strchr( refName, '_' );
         if( p ) strcpy( refName, p+1 );
      }
      else if( vd_$is_ancestry_valid(   object  = &mold_line->obj_id,
					classid = OPP_VLmrkLine_class_id ) )
      {
	 VLsbGetMarkRefName( mold_line, objName, refName );
      }
      else strcpy( refName, objName );
   }
   else
   {
      strcpy( objName, name );
      strcpy( refName, name+1 );
   }

   strcpy( elem[IDX_SBJ_IDX].name, NAM_SBJ_IDX );
   strcpy( elem[IDX_SBJ_LEN].name, NAM_SBJ_LEN );
   strcpy( elem[IDX_SBJ_NAM].name, NAM_SBJ_NAM ); 
   strcpy( elem[IDX_SBJ_REF].name, NAM_SBJ_REF );

   elem[IDX_SBJ_IDX].desc.type = AC_ATTRIB_DOUBLE;
   elem[IDX_SBJ_IDX].desc.value.att_exp = 0;

   elem[IDX_SBJ_LEN].desc.type = AC_ATTRIB_DOUBLE;
   elem[IDX_SBJ_LEN].desc.value.att_exp = length;

   elem[IDX_SBJ_NAM].desc.type = AC_ATTRIB_TEXT;
   strcpy( elem[IDX_SBJ_NAM].desc.value.att_txt, objName );

   elem[IDX_SBJ_REF].desc.type = AC_ATTRIB_TEXT;
   strcpy( elem[IDX_SBJ_REF].desc.value.att_txt, refName );

   jn_graphic.obj_id  = *pt2;
   jn_graphic.mod_env = *env;

   sts = vl$createLoftFork (	msg     = msg,
                                graphic = &jn_graphic,
                                attr    = elem,
                                number  = IDX_SBJ_ATTR,
                                Env     = env,
                                forkId  = junction );
wrapup:
   End
   return sts;
}

static IGRchar* GetProperDir( IGRint	ind )
{
   switch( ind )
   {
        case 1: return "AFT" ;
        case 2: return "FWD" ;
        case 3: return "IB"  ;
        case 4: return "OB"  ;
        case 5: return "DOWN"  ;
        case 6: return "UP";
   }
}
					
IGRlong         VSsbGetMoldLines(	IGRlong                 *msg,
                                        struct GRobj_env        *surf,
					struct GRobj_env	*srfEdge,
					struct GRid		*start_pt,
					IGRint			ej_dir,
					IGRint			flow_dir,
					IGRint			wat_val,
					IGRint			mark_val,
					IGRint			*pt_count,
					struct GRid		*pt_list  )
{
BSrc			rc;
IGRlong			sts;
IGRshort          	world=TRUE;
IGRint			i, j, nb_class=0, count=0, nb_inters=0;
IGRchar			start_str[128];
IGRuchar		weight=8;
IGRpoint		inp_pt, spt, ept;
GRclassid		classids[2];
GRrange			srf_range, range1, range2;
GRobjid			*inters=NULL;
struct ACrg_coll	attrib;
struct IGRpolyline	poly;
struct GRid		inter_line, inter_pt;
struct GRmd_env 	loc_env;
struct GRobj_env	gr_obj, gr_srf, *list=NULL;
struct GRvg_construct   cnst;

   SetProc( VSsbGetMoldLines ); Begin

   // Initialization
   sts = *msg = MSSUCC;
   *pt_count = 0;
   VLinitCnst( &cnst );
   memset(&srf_range,0,sizeof(srf_range));
   memset(&range1,0,sizeof(range1));

   sts = om$send( msg = message NDnode.ASreturn_go( &gr_srf.obj_id,
                                   &gr_srf._matrix_type, gr_srf._matrix ),
                senderid = NULL_OBJID,
                targetid = surf->_objid,
                targetos = surf->_osnum  );
   if( sts&1 )
   {
      gr_srf._md_os = gr_srf._osnum;
      sts = ex$get_modid( mod_osnum = gr_srf._md_os,
                          mod_id    = &gr_srf._md_id );
   }
   else gr_srf = *surf;
   sts = MSSUCC;

   vs$getSurfaceRange( 	msg     = msg,
			surface = &gr_srf.obj_id,
			range   = srf_range 	 );	
   __CheckRC( sts, *msg, "vs$getSurfaceRange", wrapup );
   __DBGpr_vec("Surface Low Point ", &srf_range[0] );
   __DBGpr_vec("Surface High Point ", &srf_range[3] );

   gr$get_module_env (buffer = &loc_env );
   sts = om$send(  msg  = message GRgraphics.GRgetrang( msg,
			&srfEdge->_matrix_type, srfEdge->_matrix,
			&world, range1 ),
		   senderid = NULL_OBJID,
		   targetid = srfEdge->_objid,
		   targetos = srfEdge->_osnum  );
   __CheckRC( sts, *msg, "GRgraphics.GRgetrang: Input Edge", wrapup );
   __DBGpr_vec("Edge Low Point ", &range1[0] );
   __DBGpr_vec("Edge High Point ", &range1[3] );

   sts = VLgetPtCoord( msg, *start_pt, &loc_env, inp_pt );
   __CheckRC( sts, *msg, "VLgetPtCoord", wrapup );
   __DBGpr_vec("Input Start Point ", inp_pt );

   sts = VLendpts( msg, &srfEdge->obj_id, &srfEdge->mod_env, spt, ept );
   __CheckRC( sts, *msg, "VLendpts: Edge ", wrapup );

   if( BSdistptpt( &rc, spt, inp_pt ) > BSdistptpt( &rc, ept, inp_pt ) )
   {
	dblcpy( ept, spt, 3 );
   }

   sprintf( start_str, ":Start Point ( %s - %s )", 
		GetProperDir( ej_dir ), GetProperDir( flow_dir ) );

   sts = VLsbCreateJunction( msg, srfEdge, NULL, start_pt, start_pt,
                        &loc_env, start_str, &pt_list[(*pt_count)] );
   __CheckRC( sts, *msg, "VLsbCreateJunction", wrapup );

   sts = om$send(  msg      = message GRvg.GRchgweight( msg,
                                                        &weight ),
                        senderid = NULL_OBJID,
                        targetid = pt_list[(*pt_count)].objid,
                        targetos = pt_list[(*pt_count)].osnum );
   __DBGpr_obj("Junction ", pt_list[(*pt_count)] );
   (*pt_count)++;

   count = 0;
   __DBGpr_int("Water Lines Needed? ", wat_val );
   __DBGpr_int("Marking Lines Needed? ", mark_val );
   if( wat_val || mark_val )
   {
	nb_class=0;
	if( wat_val  )	classids[nb_class++] = OPP_VLwatLine_class_id ;
	if( mark_val )	classids[nb_class++] = OPP_VLmrkLine_class_id ;
	/* Function which will NOT LOCATE */
	VD_findall_objects_in_range( srf_range, nb_class, classids,
				     TRUE, loc_env, &count, &list );
	__DBGpr_int("Number Of Objects Found ", count );
   }

   for( i=0; i<count; ++i )
   {
	nb_inters = 0;
	if( DEBUG ) vdobj$Print( objOE = &list[i] );
	inter_pt.objid = NULL_OBJID;
	memset(&range2,0,sizeof(range2));
   	sts = om$send(  msg  = message GRgraphics.GRgetrang( msg,
                        &loc_env.md_env.matrix_type, loc_env.md_env.matrix,
                        &world, range2 ),
                   senderid = NULL_OBJID,
                   targetid = list[i]._objid,
                   targetos = list[i]._osnum  );
        if( !(sts&1&(*msg)) ) continue;
	for( j=0; j<3; ++j )	range2[j] -= 50.0 ;
  	for( j=3; j<6; ++j )    range2[j] += 50.0 ;

        __DBGpr_vec("Line Low Point ", &range2[0] );
        __DBGpr_vec("Line High Point ", &range2[3] );
	if( !(BSbxint( 	&rc, &range1[0], &range1[3], 
			&range2[0], &range2[3] ) ) ) continue;

	sts = om$send( msg = message NDnode.ASreturn_go( &gr_obj.obj_id,
					&gr_obj._matrix_type, gr_obj._matrix ),
		senderid = NULL_OBJID,
		targetid = list[i]._objid,
		targetos = list[i]._osnum  );
	gr_obj._md_os = gr_obj._osnum;
	sts = ex$get_modid( mod_osnum = gr_obj._md_os,
			    mod_id    = &gr_obj._md_id );

	sts = VLproject_curve( &gr_srf, &gr_obj, &cnst, &nb_inters, &inters );
	__DBGpr_int("Number Of Projection Lines ", nb_inters );
	if( !(sts&1) || !nb_inters || !inters ) continue;

	inter_line.objid = inters[0];
	inter_line.osnum = cnst.env_info->md_id.osnum;
	__DBGpr_obj("Projected Line ", inter_line );

	sts = VLcreatePtInter( 	msg, &inter_line, cnst.env_info,
	       		 	&srfEdge->obj_id, &srfEdge->mod_env, 
				&inter_pt, &loc_env );
	if( (sts&1&(*msg)) && inter_pt.objid != NULL_OBJID )
   	{
	   sts = VLsbCreateJunction( msg, srfEdge, &list[i], start_pt, 
			&inter_pt, &loc_env, NULL, &pt_list[(*pt_count)] );
	   if( !(sts&1&(*msg)) )  goto deldel;

   	   sts = om$send(  msg      = message GRvg.GRchgweight( msg,
                                                        &weight ),
                        senderid = NULL_OBJID,
                        targetid = pt_list[(*pt_count)].objid,
                        targetos = pt_list[(*pt_count)].osnum );
	   __DBGpr_obj("Junction ", pt_list[(*pt_count)] );
	   (*pt_count)++;
	}

deldel:
        for( j=0; j<nb_inters; ++j )
	{
            sts = om$send(msg  = message GRgraphics.GRdelete( msg,
                                                          cnst.env_info ),
                        senderid = NULL_OBJID,
                        targetid = inters[j],
                        targetos = cnst.env_info->md_id.osnum );
	}
	_FREE( inters );
   }

   // Sort the Junction Objects along the edge, based on Length value
   qsort( pt_list, (*pt_count), sizeof(struct GRid), 
	  (int (*)())VLsortSBJunction );

   // Assign Proper Index for each Junction Object
   strcpy( attrib.name, NAM_SBJ_IDX ) ;
   attrib.desc.type = AC_ATTRIB_DOUBLE; 

   for( i=0; i<(*pt_count); ++i )
   {
      attrib.desc.value.att_exp = (double) (i+1) ;
      sts = om$send(  msg      = message VLjunction.ACmod_list_attribute(
                                	msg, 1, &attrib ),
                   senderid = NULL_OBJID,
                   targetid = pt_list[i].objid,
                   targetos = pt_list[i].osnum  );	
   }

   inter_pt.objid  = NULL_OBJID;
   inter_pt.osnum  = cnst.env_info->md_id.osnum;
   cnst.geometry   = (IGRchar *) &poly;
   poly.num_points = 1;
   poly.points     = ept;

   sts = om$construct( 	classid = OPP_GR3dpoint_class_id,
			osnum   = inter_pt.osnum,
			p_objid = &inter_pt.objid,
			msg	= message GRgraphics.GRaltconstruct( &cnst ) );	
   __CheckRC( sts, 1, "om$construct:GR3dpoint", wrapup );

   sts = VLsbCreateJunction( msg, srfEdge, NULL, start_pt, &inter_pt,
                        &loc_env, ":End Point", &pt_list[(*pt_count)] );
   __CheckRC( sts, *msg, "VLsbCreateJunction", wrapup );
   sts = om$send(  msg      = message GRvg.GRchgweight( msg,
                                                        &weight ),
                        senderid = NULL_OBJID,
                        targetid = pt_list[(*pt_count)].objid,
                        targetos = pt_list[(*pt_count)].osnum );
   __DBGpr_obj("Junction ", pt_list[(*pt_count)] );
   (*pt_count)++;
   
wrapup:
   _FREE( inters );
   _FREE( list );
   End
   return sts;
}

IGRlong	  VSsbGetBndSrfObjs(	IGRlong			*msg,
				IGRint			*count,
				struct GRobj_env	**list  )
{
IGRlong			sts;
IGRint			i, nb_srf=0, tmp_count=0;
GRclassid		classids[1];
GRrange			range;
struct GRmd_env		loc_env;
struct GRobj_env	*children=NULL;

   SetProc( VSsbGetBndSrfObjs ); Begin

   *count = 0;
   *list  = NULL;
   for( i=0; i<3; ++i )		range[i] = -1e6;
   for( i=3; i<6; ++i )		range[i] = 1e6;

   gr$get_module_env (buffer = &loc_env );
   classids[0] = OPP_SMSfBnd_class_id ;
   /* Function which will NOT LOCATE */
   VD_findall_objects_in_range( range, 1, classids,
                                TRUE, loc_env, &nb_srf, list );
   __DBGpr_int("Number Of Objects Found ", nb_srf );

   for( i=0; i<nb_srf; ++i )
   {
       tmp_count = 0;
       sts = VLgetPlatesThroughPretends( msg, &(*list)[i], 
					 &tmp_count, &children );
       __CheckRC( sts, *msg, "VLgetPlatesThroughPretends", wrapup );
       __DBGpr_int("Number of Plates on the selected surface ", tmp_count );
       if( tmp_count ) 
       {
          children[0]._md_os = children[0]._osnum;
          sts = ex$get_modid( mod_osnum = children[0]._md_os,
                              mod_id    = &children[0]._md_id );
	  (*list)[(*count)++] = children[0];
       }
       _FREE( children );
   }

   if( DEBUG )
   {
     for( i=0; i<(*count); ++i )
	vdobj$Print( objOE = &(*list)[i] );
   }

wrapup:
   _FREE( children );
   End
   return sts;
}

IGRlong		VLsbCreateSteelBands(	IGRlong			*msg,
					struct GRobj_env	*edgeOE,
					struct GRobj_env        *boxOE,
					IGRint			*pt_count,
					struct GRid		*pt_list )
{
BSrc			rc;
IGRlong			sts;
IGRint			i, nb_attr, neat_ft_count, inp_edge_index, prev_ind,
			next_ind, valid_ind, dir, dir1, dir2, wat_val, mark_val,
			nb_class, count, nmdi=0, edge_dir, on_centerline,
			end_dir;
IGRchar			macName[40], start_str[128];
IGRshort                world=TRUE;
IGRuchar                weight=8;
IGRdouble		dist, min_dist, *line_pa=NULL, *test_pa=NULL;
IGRpoint		start_pt, end_pt, spt1, ept1, spt2, ept2, base,
			*line_pt=NULL, *test_pt=NULL;
GRrange			range;
GRclassid		classids[2];
struct GRid		neat_cont, neat_feet[200], start_pt_id, inter_pt;
struct GRobj_env 	*list=NULL;
struct GRmd_env         loc_env;
struct ACrg_coll	attrib[NB_SB_ATTR];
struct IGRpolyline  	pt_poly;
struct GRvg_construct   cnst;
struct IGRbsp_curve     *edgeGeom=NULL, *moldGeom=NULL;

   SetProc( VLsbCreateSteelBands ); Begin

   sts = *msg = MSSUCC;
   *pt_count  = 0;
   neat_cont.objid = NULL_OBJID;

   if( !msg || !edgeOE || !boxOE || !pt_list ) { sts = MSFAIL; goto wrapup; }

   __DBGpr_obj("Input Edge ", edgeOE->obj_id );
   __DBGpr_obj("Input Attribute Box ", boxOE->obj_id );

   VLinitCnst( &cnst );
   gr$get_module_env (buffer = &loc_env );

   sts = vdchn$GetList(  objOE   = edgeOE,
                         chnIDx  = VDCHN_IDX_TO_OWNERS,
                         maxCnt  = 1,
		         cnt	 = &i,
                         outIDs  = &neat_cont );
   if( !(sts&1) || neat_cont.objid == NULL_OBJID ) return MSFAIL;
   __DBGpr_obj("Neat Contour Object ", neat_cont );

   vdobj$Get( objID   = &neat_cont,
	      macName = macName );
   if( strcmp( macName, "neat_cont" ) )  return MSFAIL;

   sts = vdchn$GetList( objID   = &neat_cont,
                        chnIDx  = VDCHN_IDX_TO_COMPONENTS,
                        maxCnt  = 200,
                        cnt     = &neat_ft_count,
                        outIDs  = neat_feet );
   __DBGpr_int("Neat Feet Count ", neat_ft_count );

   for( i=0; i<neat_ft_count; ++i )
	if( neat_feet[i].objid == edgeOE->_objid &&
	    neat_feet[i].osnum == edgeOE->_osnum )   break;

   inp_edge_index = (IGRint) i/2;

   sts = om$send ( msg =  message ACrg_collect.AClist_attribute(
                                msg, NB_SB_ATTR, attrib, &nb_attr ),
                senderid = NULL_OBJID,
                targetid = boxOE->_objid,
                targetos = boxOE->_osnum );
   __CheckRC( sts, *msg, "ACrg_collect.AClist_attribute", wrapup ) ;

   neat_ft_count = neat_ft_count/2;

   prev_ind = inp_edge_index - 1;
   if( prev_ind < 0 )    		prev_ind = neat_ft_count-1;

   next_ind = inp_edge_index + 1;
   if( next_ind == neat_ft_count )    	next_ind = 0 ;

   dir = (IGRint) attrib[IDX_SB_START_DIR].desc.value.att_exp;
   __DBGpr_int("Side ", dir );
   __DBGpr_obj("Previous Dir Feet ", neat_feet[2*prev_ind+1] );
   __DBGpr_obj("Next Dir Feet ", neat_feet[2*next_ind+1] );

   vdexp$Get( objID = &neat_feet[2*prev_ind+1], jnt = &dir1 );
   vdexp$Get( objID = &neat_feet[2*next_ind+1], jnt = &dir2 );
   vdexp$Get( objID = &neat_feet[2*inp_edge_index+1], jnt = &edge_dir );

   if( edge_dir == dir1 || edge_dir == dir2 )
   {
     while( 1 )
     {
       if( edge_dir == dir1 )
       {
          prev_ind = prev_ind - 1 ;
          if( prev_ind < 0 )    prev_ind = neat_ft_count-1;
       }

       if( edge_dir == dir2 )
       {
          next_ind = next_ind + 1 ;
          if( next_ind == neat_ft_count )    next_ind = 0 ;
       }
       vdexp$Get( objID = &neat_feet[2*prev_ind+1], jnt =&dir1 );
       vdexp$Get( objID = &neat_feet[2*next_ind+1], jnt =&dir2 );
       if( edge_dir != dir1 && edge_dir != dir2 ) break;
     }
   }
   __DBGpr_int("Dir1 ", dir1 );
   __DBGpr_int("Dir2 ", dir2 );

   if( dir == dir1 )             { valid_ind = prev_ind ;  end_dir = dir2; }
   else if( dir == dir2 )        { valid_ind = next_ind ;  end_dir = dir1; }
   else	{ sts = MSFAIL; goto wrapup; }

   VLendpts( msg, &neat_feet[2*inp_edge_index], &loc_env, spt1, ept1 );
   VLendpts( msg, &neat_feet[2*valid_ind], &loc_env, spt2, ept2 );

   min_dist = 1e30;
   dist = BSdistptpt( &rc, spt1, spt2 );
   if( dist < min_dist )
   {
      dblcpy( start_pt, spt1, 3 );
      min_dist = dist;
   }

   dist = BSdistptpt( &rc, spt1, ept2 );
   if( dist < min_dist )
   {
      dblcpy( start_pt, spt1, 3 );
      min_dist = dist;
   }

   dist = BSdistptpt( &rc, ept1, spt2 );
   if( dist < min_dist )
   {
      dblcpy( start_pt, ept1, 3 );
      min_dist = dist;
   }

   dist = BSdistptpt( &rc, ept1, ept2 );
   if( dist < min_dist )
   {
      dblcpy( start_pt, ept1, 3 );
      min_dist = dist;
   }

   if( BSdistptpt( &rc, start_pt, spt1 ) < BSdistptpt( &rc, start_pt, ept1 ) )
		dblcpy( end_pt, ept1, 3 );	
   else 	dblcpy( end_pt, spt1, 3 );
   __DBGpr_vec("Start Point ", start_pt );
   __DBGpr_vec("End Point ", end_pt );

   pt_poly.num_points  = 1;
   pt_poly.points      = start_pt;
   cnst.geometry       = (IGRchar *) &pt_poly;
   start_pt_id.osnum   = cnst.env_info->md_id.osnum;
   sts = om$construct(  classid = OPP_GR3dpoint_class_id,
                        osnum   = start_pt_id.osnum,
                        p_objid = &start_pt_id.objid,
                        msg     = message GRgraphics.GRaltconstruct( &cnst ) );
   __CheckRC( sts, *msg, "GR3dpoint.GRaltconstruct: Start Point", wrapup ) ;
   cnst.geometry = NULL;

   on_centerline = FALSE;
   sts = VLsbIsOnCenterLine( msg, neat_ft_count, neat_feet, 
			     cnst.env_info, &on_centerline );
   __CheckRC( sts, *msg, "VLsbIsOnCenterLine", wrapup );

   dir1 = (IGRint) attrib[IDX_SB_SIDE].desc.value.att_exp;
   dir2 = (IGRint) attrib[IDX_SB_START_DIR].desc.value.att_exp;

   if( on_centerline && ( dir2 == OB || dir2 == IB ) )
   {
       if( dir2 == IB )
       {
	 sprintf( start_str, ":Start Point ( %s - OB ) STBD", 
		GetProperDir( dir1 ) );
       }
       else
       {
         sprintf( start_str, ":Start Point ( %s - OB ) PORT", 
                GetProperDir( dir1 ) );
       }
   }
   else
   {
       sprintf( start_str, ":Start Point ( %s - %s )",
                GetProperDir( dir1 ), GetProperDir( dir2 ) );
   }

   sts = VLsbCreateJunction( msg, edgeOE, NULL, &start_pt_id, &start_pt_id,
                        &loc_env, start_str, &pt_list[(*pt_count)++] );
   __CheckRC( sts, *msg, "VLsbCreateJunction", wrapup );

   wat_val  = (IGRint) attrib[IDX_SB_WATERLINES].desc.value.att_exp;
   mark_val = (IGRint) attrib[IDX_SB_MARKINGLINES].desc.value.att_exp;

   count = 0;
   __DBGpr_int("Water Lines Needed? ", wat_val );
   __DBGpr_int("Marking Lines Needed? ", mark_val );

   sts = om$send(  msg  = message GRgraphics.GRgetrang( msg,
                        &edgeOE->_matrix_type, edgeOE->_matrix,
                        &world, range ),
                   senderid = NULL_OBJID,
                   targetid = edgeOE->_objid,
                   targetos = edgeOE->_osnum  );
   __CheckRC( sts, *msg, "GRgraphics.GRgetrang: Input Edge", wrapup );
   __DBGpr_vec("Edge Low Point ", &range[0] );
   __DBGpr_vec("Edge High Point ", &range[3] );

   for( i=0; i<3; ++i ) range[i] -= 20*MAX_PLATE_THICKNESS;
   for( i=3; i<6; ++i ) range[i] += 20*MAX_PLATE_THICKNESS;

   __DBGpr_vec("Extended Edge Low Point ", &range[0] );
   __DBGpr_vec("Extended Edge High Point ", &range[3] );

   if( wat_val || mark_val )
   {
        nb_class=0;
        if( wat_val  )  classids[nb_class++] = OPP_VLwatLine_class_id ;
        if( mark_val )  classids[nb_class++] = OPP_VLmrkLine_class_id ;
        /* Function which will NOT LOCATE */
        VD_findall_objects_in_range( range, nb_class, classids,
                                     TRUE, loc_env, &count, &list );
        __DBGpr_int("Number Of Objects Found ", count );

        sts = VLgetGeometry( edgeOE, FALSE, NULL_OBJID,
                             (IGRchar **)&edgeGeom, msg );
        __CheckRC( sts, *msg, "VLgetGeometry", wrapup ) ;
   }

   for( i=0; i<count; ++i )
   {
       	nmdi = 0;
       	dist = 0.0;
       	_FREE( line_pa  );
       	_FREE( test_pa  );
       	_FREE( line_pt  );
       	_FREE( test_pt  );
	_FREE( moldGeom );

        if( DEBUG ) vdobj$Print( objOE = &list[i] );

	sts = VLgetGeometry( &list[i], FALSE, NULL_OBJID,
			     (IGRchar **)&moldGeom, msg );
	if( !(sts&1&(*msg)) )  continue;

	BSmdistcvcv( edgeGeom, moldGeom, &nmdi, &line_pa, &test_pa,
                     &line_pt, &test_pt, &dist, &rc );
        if( dist < MAX_PLATE_THICKNESS )  pt_poly.points  = line_pt[0];
	else
	{
	   IGRdouble		mdist1, mdist2, par, pt[3], pt_to_extend[3],
				new_end[3];
	   struct GRid		mld_id;

	   VDdrawCurve( moldGeom, cnst.env_info, &mld_id );
	   MAbcendpts( msg, moldGeom, spt1, ept1 );
  
	   BSmdstptcv( edgeGeom, spt1, &par, pt, &mdist1, &rc );
	   BSmdstptcv( edgeGeom, ept1, &par, pt, &mdist2, &rc );

	   if( mdist1 < mdist2 ) 
	   {
	       dblcpy( pt_to_extend, spt1, 3 );
	       BSmdstptcv( edgeGeom, spt1, &par, new_end, &mdist1, &rc );
	   }
	   else
           {
               dblcpy( pt_to_extend, ept1, 3 );
               BSmdstptcv( edgeGeom, ept1, &par, new_end, &mdist2, &rc );
           }

           sts = om$send(msg = message GRcurve.GRptextend(
                              msg, cnst.env_info, pt_to_extend, new_end, base ),
                      senderid = NULL_OBJID,
                      targetid = mld_id.objid,
                      targetos = mld_id.osnum );

	   BSmdstptcv( edgeGeom, base, &par, new_end, &mdist2, &rc );

           sts = om$send(msg  = message GRgraphics.GRdelete( msg,
                                                          cnst.env_info ),
                        senderid = NULL_OBJID,
                        targetid = mld_id.objid,
                        targetos = mld_id.osnum );

	   if( mdist2 < MAX_PLATE_THICKNESS ) pt_poly.points  = new_end ;
	   else continue;
	}

	inter_pt.objid = NULL_OBJID;
        inter_pt.osnum = cnst.env_info->md_id.osnum;
        cnst.geometry   = (IGRchar *) &pt_poly;
        sts = om$construct(  classid = OPP_GR3dpoint_class_id,
                             osnum   = inter_pt.osnum,
                             p_objid = &inter_pt.objid,
                             msg     = 
				message GRgraphics.GRaltconstruct( &cnst ) );
        if( (sts&1&(*msg)) && inter_pt.objid != NULL_OBJID )
        {
           sts = VLsbCreateJunction( msg, edgeOE, &list[i], &start_pt_id,
                        &inter_pt, &loc_env, NULL, &pt_list[(*pt_count)] );
           if( !(sts&1&(*msg)) )  continue;
           (*pt_count)++;
        }
   }

   pt_poly.points  = end_pt;
   inter_pt.osnum = cnst.env_info->md_id.osnum;
   cnst.geometry   = (IGRchar *) &pt_poly;
   sts = om$construct(  classid = OPP_GR3dpoint_class_id,
                        osnum   = inter_pt.osnum,
                        p_objid = &inter_pt.objid,
                        msg     = message GRgraphics.GRaltconstruct( &cnst ) );
   __CheckRC( sts, *msg, "GR3dpoint.GRaltconstruct: End Point", wrapup ) ;

   if( on_centerline && ( dir2 == OB || dir2 == IB ) )
   {
       if( dir2 == IB )
       {
         sprintf( start_str, ":End Point ( %s - OB ) PORT",
                GetProperDir( dir1 ) );
       }
       else
       {
         sprintf( start_str, ":End Point ( %s - OB ) STBD",
                GetProperDir( dir1 ) );
       }
   }
   else
   {
       sprintf( start_str, ":End Point ( %s - %s )",
                GetProperDir( dir1 ), GetProperDir( end_dir ) );
   }

   sts = VLsbCreateJunction( msg, edgeOE, NULL, &start_pt_id, &inter_pt,
                        &loc_env, start_str, &pt_list[(*pt_count)++] );
   __CheckRC( sts, *msg, "VLsbCreateJunction", wrapup );

   // Sort the Junction Objects along the edge, based on Length value
   qsort( pt_list, (*pt_count), sizeof(struct GRid),
          (int (*)())VLsortSBJunction );

   for( i=0; i<(*pt_count); ++i )
   {
      sts = om$send(  msg      = message GRvg.GRchgweight( msg, &weight ),
		      senderid = NULL_OBJID,
                      targetid = pt_list[i].objid,
                      targetos = pt_list[i].osnum );
   }

wrapup:
   _FREE( list     );
   _FREE( line_pa  );
   _FREE( test_pa  );
   _FREE( line_pt  );
   _FREE( test_pt  );
   _FREE( edgeGeom );
   _FREE( moldGeom );
   End
   return sts;
}

end implementation VDSroot;
