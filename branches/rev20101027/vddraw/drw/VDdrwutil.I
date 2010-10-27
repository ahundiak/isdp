/* $Id: VDdrwutil.I,v 1.1.1.1 2001/01/04 21:08:37 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vddraw/drw/VDdrwutil.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDdrwutil.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:08:37  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.7  1998/01/04  15:48:06  pinnacle
# string.h
#
 *
 * History:
 *      MM/DD/YY        AUTHOR  DESCRIPTION
 *
 *      01/04/97        ah    	Added header, string.h
 * -------------------------------------------------------------------*/
/*
	I/VDS	Copy (Old log information)

	adz:	The surface can be a composite surface. In that case we
		need to take the components of the composite the use for
		the function VD_drwIsPtHiddenBySf(); 
	adz:	VD_drwGetFacesOfPart. Do not go to graphical object; Get all
		components and filter later.
	Sundar: Added new functions VDdrwcstPoint, VDdrwcstPlane,
		VDdrwCompContour &  VDdrwCompInterContour.
	10/30/97 Art Hundiak
		 UnInted sts return value
	Sundar: Copied the functions VD_drwObjFile, VD_drwObjMacroName,
		VD_drwDbDynSelect, VD_drwObjDynTable, VD_drwDbQuery,
		& VD_drwObjPdmId from expression parser & made some 
		modifications.
*/
class implementation EMSsurface ;

#include <stdio.h>
#include <stdlib.h>
#include "string.h"
#define _INGR_EXTENSIONS
#include <math.h>
#include "OMmacros.h"
#include "bserr.h"
#include "VDScheckin.h" 
#include "ACattrib.h" 
#include "PDUerror.h"
#include "growner.h"
#include "exmacros.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "DImacros.h"
#include "ACdb_info.h"
#include "EMSmsgdef.h"
#include "emseligible.h"
#include "msdef.h"
#include "msmacros.h"
#include "v_edgedef.h"
#include "v_edgemacros.h"
#include "v_datamacros.h"
#include "v_geommacros.h"
#include "v_miscmacros.h"
#include "v_dbgmacros.h"
#include "v_drw.h"
#include "VDBload.h"
/*
 * Includes of function prototypes.
 */
#include "bscveval.h"
#include "bspj_pt_sf1.h"
#include "v_docvsovlap.h"
#include "v_getchanobj.h"
#include "v_ispntonsrf.h"
#include "v_pratpt.h"
#include "v_vecmxproto.h"
#include "v_strngproto.h"

#include "SMmsg.h"
#include "emsmapdef.h"
#include "emsimpdef.h"

extern void		VD_setGRids() ;

extern OMuword		OPP_GRpoint_class_id,
			OPP_EMScompsurf_class_id,
			OPP_VDrelat_hdr_class_id,
			OPP_EMSsolid_class_id ;

from GRlinear	import	GRgetpolyline ;
from GRowner	import	GRdrop ;
from NDnode	import	ASreturn_go ;
from NDmacro	import	ACreturn_foot ;
from ACheader	import	ACfind_model ;
from VDlink	import	ACget_model_list ;	/* image list objects */
from EMSgencompsf	import	EMmake_comp ;
from EMSplane 	import	EMplane_of_curve ;

#define FLOOR_ANGLE  15         /* Means horizontal ~ 15 degrees */
#define SMALL_ANGLE 2           /* some small angle     */
#define MAX_BOUND 100           /* Max. no. of boundaries for a composite surface */
#define  SM_MAX_DW_PL   10           /* Max number of possible plane */
#define FRACTION     0.001   /* small fraction */

#define	_REALLOC( ptr, nelem, type ) \
	(type *) realloc( (ptr), (unsigned) ( (nelem) * sizeof( type ) ) )

extern OMuword		OPP_GR3dpoint_class_id;	
extern OMuword		OPP_EMSgencompsf_class_id;	
extern OMuword		OPP_EMSplane_class_id;	

/*----------------------------------------------------------------------------*/
long VD_drwIsSolidOrSurface( msg, elmId, elmEnv, sol1_surf0 )

long		*msg ;
struct GRid	*elmId ;
struct GRmd_env *elmEnv ;
int		*sol1_surf0 ; {

	/*
	 * Given an element ( elmId, elmEnv ), this function returns TRUE in
	 * argument '*sol1_surf0' if element is a solid, ortherwise if element
	 * is a surface returns FALSE.
	 *
	 * Note :
	 * ------
	 *	If element isn't a solid or a surface 'msg' is equal to
	 *	EMS_E_InvalidArg.
	 */

	long		sts ;	     /* OM completion code.		      */
	struct GRprops	properties ; /* Geometric properties of element.      */

	SetProc( VD_drwIsSolidOrSurface ); Begin

	__DBGpr_obj( "Element", *elmId ) ;

	/*
	 * Get geometric properties of element.
	 */
	sts = om$send( msg	= message GRvg.GRgeomprops(
							  msg,
							  &elmEnv->_MATRIX_TYPE,
							  elmEnv->_MATRIX,
							  &properties ),
		       senderid = elmId->objid,
		       targetid = elmId->objid,
		       targetos = elmId->osnum ) ;
	if( !( sts & 1 & *msg ) ) {
		__DBGpr_com( "Not a solid or surface" ) ;
		vd_$inv_arg() ;
	}

	/*
	 * Even if element is a solid, the properties type is set to GRSURFACE.
	 * So, to see if element is a solid, we have to check its classid.
	 */
	if( properties.type != GRSURFACE ) {
		__DBGpr_com( "Not a solid or surface" ) ;
		vd_$inv_arg() ;
	} else	*sol1_surf0 = FALSE ;

	if( vd_$is_ancestry_valid( object  = elmId,
				  classid = OPP_EMSsolid_class_id ) )
		*sol1_surf0 = TRUE ;

	__DBGpr_int( "Is a solid ?", *sol1_surf0 ) ;

	sts  = OM_S_SUCCESS ;
	*msg = MSSUCC ;

	wrapup :
		End
		return sts ;

} /* VD_drwIsSolidOrSurface */

/*----------------------------------------------------------------------------*/

long VDdrwcstPoint( msg, inp, xData, outp )
 
long                    *msg ;
VD_drwInputData         *inp ;
VD_drwExecData          *xData ;
VD_drwGraphicGroup      *outp ; {
 
        IGRlong                 sts;
        struct GRid             point;
        struct IGRpolyline      pntDef;
        struct GRvg_construct   cst ;

// Not used 
//      struct GRpost_info      post_info;
//      GRobjid                 new_objid;
 
 
        vd_$fill_cnst_list( Msg          = msg,
                           Env_info     = inp->drwInfo.drwEnv,
                           Level        = xData->overrides.elmLevel,
                           Display      = &xData->overrides.elmDisplay,
                           Geometry     = &pntDef,
                           Cnst_list    = cst ) ;
 
        pntDef.num_points       = 1 ;
        pntDef.points           = xData->anchorPoint ;
 
        // point.osnum = inp->elmId->osnum;
	point.osnum = cst.env_info->_MD_OS ;
        sts = om$construct(classid = OPP_GR3dpoint_class_id,
                        osnum      = point.osnum,
                        p_objid    = &point.objid,
                        msg        = message GRvg.GRaltconstruct( &cst ));
 
        if( !( outp->list = _MALLOC( 1, struct GRid ) ) ){
		printf ("Can't allocate memory\n");
		goto wrapup ;
	}
        outp->list[0]  = point ;
        outp->count = 1 ;
 
        wrapup :
                if( !(sts & 1 & *msg) ) {
                        if( outp->list ) {
                                _FREE( outp->list ) ;
                                outp->list  = NULL ;
                                outp->count = 0 ;
                        }
                }
 
        return sts;
}
/*----------------------------------------------------------------------------*/
long VDdrwcstPlane( msg, inp, numProjs, projList, cst, NumPlane, outPlane)
long	*msg;
VD_drwInputData         *inp ;
IGRint numProjs; 
struct GRid *projList;
struct GRvg_construct  cst;
IGRint	*NumPlane;
struct GRid *outPlane;
{
	long                    sts ;
	struct GRlc_info	cvInfo ;
	IGRboolean         	loopset;
	IGRboolean 		*CrvArea, *BelongTo;
	IGRint			NbBound;
	IGRmatrix		TransMat;
	IGRshort		MatType;
	struct GRid		TempObj;

	IGRint 			NbCrPlane,i,j,jj,kk;
	double			*drwNormal;

  // In case of error
  sts = OM_W_ABORT;

	/*
	 * Now create one or more than one plane encompassing
	*/

	drwNormal = inp->drwInfo.drwPlane->normal;
	NbCrPlane = 0;  /* Number of created planes */
	BelongTo = CrvArea = NULL;

	CrvArea  = _MALLOC(numProjs, IGRboolean);
	BelongTo = _MALLOC(numProjs, IGRboolean);
	if(CrvArea == NULL || BelongTo == NULL){
		printf("Error allocating space\n");
		*msg = MSFAIL ;
		goto wrapup ;
    	}

    
   	if(!(SMFdEnCrv(numProjs, projList, cst.env_info, 
			CrvArea, BelongTo) & 1)) {
     		printf("Error getting curve information\n");
     		_FREE(CrvArea) ;
     		_FREE(BelongTo) ;
     		*msg = MSFAIL ;
     		return OM_W_ABORT;
    	}

   	NbCrPlane = 0;  /* Number of created planes */
   	for(i=0;i<numProjs;i++) 
		if(BelongTo[i] == -1 && CrvArea[i] == TRUE) NbCrPlane++;

   	/* We have all the information concerning the curves, but we will only
    	* concidere one level of dependancy...
    	*/

    	/*
     	* Just a small kludge to put the plane a little bit back (top view).
     	* This will allow to see contour, name, cog when the plane is shaded.
     	*/
   	MAidmx ( msg, TransMat );
   	TransMat[11] = -FRACTION * drwNormal[2];
   	MAtypemx ( msg, TransMat, &MatType );


   	if(NbCrPlane > SM_MAX_DW_PL) NbCrPlane = SM_MAX_DW_PL;
   	kk = 0;
   	for(j=0;j<NbCrPlane;j++) {
     		if(BelongTo[j] != -1 || CrvArea[j] != TRUE) continue;

     		outPlane[kk].osnum = cst.env_info->md_id.osnum ;

     		cvInfo.located_obj 	     = projList[j];
     		cvInfo.module_info 	     = *cst.env_info;
     		cvInfo.geom_parms.leaf_id	     = projList[j];

     		loopset = TRUE;
     
     		/*
      		* Note : we only ask for the loopset to be constructed below
      		* if there are more than one curve since we will need the plane
      		* to have some topology for the impose boundary operation.
      		*/

     		sts = om$construct(classid  = OPP_EMSplane_class_id,
			osnum	 = outPlane[kk].osnum,
			p_objid  = &outPlane[kk].objid);
     		if(!(sts & 1)) {
       			printf("Error creating the EMSplane object\n");
       			*msg = MSFAIL ;
       			goto wrapup ;
      		}
       
     		GRabsg_del_all();
     		sts = om$send(msg = message EMSplane.EMplane_of_curve(
								   msg,
				/* Construction list		*/ &cst,
				/* Encompassing curve		*/ &cvInfo,
				/* No imput BS curve		*/ NULL,
				/* No input curve type		*/ NULL,
				/* Test degeneracy ?		*/ TRUE,
				/* Construct loopset ?		*/ loopset,
				/* Don't care about orientation	*/ NULL,
				/* Don't want edges		*/ NULL ),
			senderid = outPlane[kk].objid,
			targetid = outPlane[kk].objid,
			targetos = outPlane[kk].osnum);
     		if( !( sts & 1 & *msg ) )
      		{
       				printf("Error creating plane of curve\n");
       				SMDelInterObj ( 1, &outPlane[kk], cst.env_info, FALSE );
       				*msg = MSFAIL ;
       				goto wrapup ;
      		}

     		/* Take curves depending on this one if exist ... */
     		NbBound=0;
     		for(jj=0;jj<numProjs;jj++) {
       			if(BelongTo[jj] == j) {
	 			NbBound++;
			}
      		}
      
     		if(NbBound>0) {
       			struct GRlc_info	*bndries	= NULL ;
       			int		numBndries;
       			long		mapOptions ;

       			/* imcompasse a curve ... */

       			numBndries = NbBound;  

       			bndries = _MALLOC(numBndries, struct GRlc_info);
       			if(bndries == NULL) {
	 			*msg = MSFAIL ;
	 			goto wrapup ;
			}

       		i = 0;
       		for(jj=0;jj<numProjs;jj++) {
         		if(BelongTo[jj] == j) {
	  			bndries[i].located_obj = projList[jj];
	   			bndries[i++].module_info = *cst.env_info ;
	  		}
        	}
       		if(i!=NbBound){ 
			printf("Grosse error getting the boundaries\n"); 
			*msg = MSFAIL; goto wrapup;
		}

       		mapOptions = EMMapBnd_WantBadCurves | EMMapBnd_StrokeIfNeeded |
		    EMMapBnd_WantStatMsg   | EMMapBnd_SurfIsPlane    |
		    EMImpBnd_NoStateTree;

       		sts = om$send(msg = message EMSsurface.EMimpose_boundaries(
							msg,
							numBndries,
			/* No bound. buffers	*/	NULL,	
							bndries,
			/* No point in area	*/	NULL,	
			/* No area: unused here	*/	TRUE,	
			/* Mod. env of plane	*/	cst.env_info,
							NULL,
							NULL,
							NULL,
							NULL,
							NULL,
							NULL,
							NULL,
							NULL,
							mapOptions,
							  EMImpBnd_NoStateTree
							| EMImpBnd_AutoNest
							| EMImpBnd_CloseReverse,
							NULL ),
			senderid= outPlane[kk].objid, 
			targetid= outPlane[kk].objid, 
			targetos= outPlane[kk].osnum ) ;

       		/*
        	* Free buffer then test restuen codes.
        	*/
       		_FREE(bndries) ;
       		if( !( sts & 1 & *msg ) ) {
	 		printf("Error impose boundaries\n");
	 		*msg = MSFAIL ;
	 		goto wrapup ;
		}
      
      		}
      		sts = om$send ( msg = message GRgraphics.GRxform ( msg, 
				cst.env_info,
				&MatType, TransMat, &TempObj.objid ),
			senderid= outPlane[kk].objid, 
			targetid= outPlane[kk].objid, 
			targetos= outPlane[kk].osnum ) ;
      		outPlane[kk].objid = TempObj.objid;
      		if( !( sts & 1 & *msg ) ) {
	 		printf("Error GRxform\n");
	 		*msg = MSFAIL ;
	 		goto wrapup ;
		}

     		kk++;
    	}

	*NumPlane=kk;

	sts  = OM_S_SUCCESS ;
        *msg = MSSUCC ;

	wrapup :	
   	_FREE(CrvArea) ;
  	_FREE(BelongTo) ;

	return sts;
}
/*----------------------------------------------------------------------------*/
long VDdrwCompContour( msg, inp, xData, outp )
 
long                    *msg ;
VD_drwInputData         *inp ;
VD_drwExecData          *xData ;
VD_drwGraphicGroup      *outp ; {

	/*
         * This function extracts the projection of the contour of the
         * compartment's bottom side.
         */
 
        long                    sts ;             /* OM completion code.      */
        struct GRvg_construct   cst ;             /* Construction list for    */
                                                  /* wireframe elements.      */
        struct GRid             mySolid;          /* Solid of compartment.    */
        OMuword                 pjClassid ;       /* Class of the projected   */
                                                  /* curve.                   */
 
	IGRint		outpcount=0;
	IGRboolean 	parallel;
	IGRint       NbFloor;
	struct GRid  *Floor=NULL, *Floor_in_cstEnv=NULL;
   	GRobjid      *Floor_objid=NULL;
   	struct GRid  *BOUNDtab=NULL;
   	IGRint       nb_bound;
	IGRint       jj, i, numInters;
        struct GRlc_info	objToIntersect ;
        IGRint                  msg1;
	struct  GRid   comp_surf;
	struct  GRid   *intersList;

  // UnUsed 
  // IGRint flatCount;

        SetProc( VDdrwCompContour ); Begin
 
        __DBGpr_obj( "Compartment to draw", *(inp->elmId) ) ;

        outp->count = 0 ;
        outp->list  = NULL ;
 
        comp_surf.objid = NULL_OBJID ;
 
        /*
         * Construct construction list for wireframe elements.
         */
        vd_$fill_cnst_list( Msg          = msg,
                           Env_info     = inp->drwInfo.drwEnv,
                           Level        = xData->overrides.elmLevel,
                           Display      = &xData->overrides.elmDisplay,
                           Cnst_list    = cst ) ;
 
        /*
         * Get the solid of the compartment.
         */
 
        sts = om$send( msg      = message NDmacro.ACreturn_foot(
                                                               msg,
                                                               "sol",
                                                               &mySolid,
                                                               NULL,
                                                               NULL ),
                       senderid = inp->elmId->objid,
                       targetid = inp->elmId->objid,
                       targetos = inp->elmId->osnum ) ;
 
        __CheckRC( sts, *msg, "NDmacro.ACreturn_foot", wrapup ) ;
        __DBGpr_obj( "Solid of the compartment", mySolid ) ;

	/* Copy -- Sundar */
	/* Check if the normal to view plane and SCS Vz are approx. parallel */
	/* In fact the vector is not vwPlane (always [0,0,1]) */
    	/* But the Vz vector of Env which has to be tested  */
    	sts = SMCheckVector ( &inp->elmEnv->md_env.matrix[8], 
					(IGRdouble)SMALL_ANGLE, &parallel );
	if ( !(sts&1) || !parallel )  
     	{
      		ex$message(msgnumb = SM_W_CmExtHorz);
      		ex$message(msgnumb = SM_W_CmFlIgn);
      		goto wrapup;
    	}

	/* Continue only if there is an intersection between solid 
	   and plane */
        objToIntersect.located_obj              = mySolid ;
        objToIntersect.geom_parms.leaf_id.objid = NULL_OBJID;
        objToIntersect.module_info              = *(inp->elmEnv) ;

	sts = om$send(msg = message GRvg.EMintplane(&cst, inp->drwInfo.drwPlane,
                       &objToIntersect, &numInters, &intersList, &msg1 ),
		       senderid= mySolid.objid,
                       targetid= mySolid.objid,
                       targetos= mySolid.osnum ) ;
	if( !( sts & 1 & msg1 ) || !numInters )
		goto wrapup;

	SMDelInterObj ( numInters, intersList, cst.env_info, TRUE );
	/* Get the floor surfaces */
	if(SMGetFloor(&mySolid, inp->drwInfo.drwEnv, (IGRdouble) FLOOR_ANGLE,
			&NbFloor, &Floor) != 1) {
		printf("ERROR, Compartment floor extraction\n");
		goto wrapup;
	}
	if(NbFloor == 0){
		/* No floor found */
        	goto wrapup;
    	} else {

		Floor_in_cstEnv = _MALLOC ( NbFloor, struct GRid);
		if ( !Floor_in_cstEnv ){
			printf ( "Can not allocate memory\n");
			goto wrapup;
		}

		/*  Make copy of floors in the construction env   */
		for ( jj = 0; jj < NbFloor; jj++ ){
			Floor_in_cstEnv[jj].osnum = (cst.env_info)->md_id.osnum;
			sts = om$send ( msg = message GRgraphics.GRcopy
				 ( msg, inp->elmEnv, cst.env_info,
					&Floor_in_cstEnv[jj].objid ),
				senderid = NULL_OBJID,
				targetid = Floor[jj].objid,
                       		targetos = Floor[jj].osnum );
			 __CheckRC( sts, *msg, "GRgraphics.GRcopy", wrapup ) ;
		}
		_FREE ( Floor ) ;
		/* construct composite surface */
		comp_surf.osnum = (cst.env_info)->md_id.osnum;
		if ( NbFloor == 1 )
		          comp_surf.objid = Floor_in_cstEnv[0].objid;
		else{
			Floor_objid = _MALLOC ( NbFloor, GRobjid );
          		if ( Floor_objid == NULL )
           		{ printf ( "Can not allocate memory\n"); goto wrapup;}

       			for ( jj=0; jj<NbFloor; jj++)
              			Floor_objid[jj] = Floor_in_cstEnv[jj].objid;
       			sts = om$construct ( 
				classid = OPP_EMSgencompsf_class_id,
                       		p_objid = &comp_surf.objid,
                       		osnum = comp_surf.osnum);
			__CheckRC( sts, 1, "om$construct", wrapup ); 
       			sts = om$send ( msg = message EMSgencompsf.EMmake_comp ( 
						msg,
                                       		NbFloor, 
						Floor_objid, 
						cst.env_info ),
					senderid = comp_surf.objid,
                       			targetid = comp_surf.objid,
                       			targetos = comp_surf.osnum);
			__CheckRC( sts, 1, "EMSgencompsf.EMmake_comp", wrapup );
       			if( !( sts & 1 & *msg ) ) { 
				SMDelInterObj( NbFloor, Floor_in_cstEnv, 
					cst.env_info, TRUE );
       				SMDelInterObj( 1, &comp_surf, 
				cst.env_info, FALSE );
       				_FREE ( Floor_objid ) ;
       				goto wrapup ;
       			}
       			_FREE ( Floor_objid ) ;
      		}
		BOUNDtab = _MALLOC ( MAX_BOUND, struct GRid );
		if ( !BOUNDtab ) {
			printf("Can not allocate memory\n");
			goto wrapup ;
		}
		sts = SMevaluate_xbound ( 0,comp_surf,cst.env_info,
					BOUNDtab,MAX_BOUND,&nb_bound );
      		if ( !(sts & 1)) { 
			printf("Error SMevaluate_xbound\n");
			SMDelInterObj( NbFloor, Floor_in_cstEnv, cst.env_info, TRUE );
       			if ( NbFloor > 1) 
				SMDelInterObj( 1, &comp_surf, cst.env_info, FALSE );
       			_FREE ( BOUNDtab ) ;
       			goto wrapup ;
       		}
      		/*   printf ( " No. of boundaries : %d\n", nb_bound ); */
 
      		/* delete floors in construction env      */
      		SMDelInterObj( NbFloor, Floor_in_cstEnv, cst.env_info, TRUE );
 
 
      		/* If more than one surfaces => create a composite */
      		/* Extract the stitchable edge */
      		/* Project on the drawing view plane */
      		/* back to the regular process */
 
      		/*
       		* Now project intersection curves onto drawing sheet along view vector.
       		*/
			
		/*
               	* Allocate memory for output list.
               	*/
               	if( !( outp->list=_MALLOC( nb_bound, struct GRid ) ) )
                       	vd_$mem_fail() ;
 
               	for (i=0; i<nb_bound; i++)  outp->list[i].objid=NULL_OBJID;
               	for (i=outpcount=0; i < numInters; i++) {
                       	if(IF_NULL_OBJID(BOUNDtab[i].objid)) continue;
                /*
                 * Project composite curve onto drawing plane.
                 */
                sts = EFproject_any_curve_on_planen( msg,
                                      		&cst,
                                             	&BOUNDtab[i],
                                             	cst.env_info,
                                             	inp->drwInfo.drwPlane,
                                             	inp->drwInfo.viewVector,
                                             	&outp->list[outpcount],
                                             	&pjClassid ) ;
 
               	__CheckRC( sts,*msg,"EFproject_any_curve_on_planen", wrapup );
			
               	if(!(sts & 1 & *msg)) {
                        printf("Warnning, Bad curve projection\n");
                        continue;
                }
 
                if(om$is_ancestry_valid(superclassid = OPP_GR3dpoint_class_id,
                            subclassid   = pjClassid ) == OM_S_SUCCESS)
                        {
                        om$send(msg = message GRgraphics.GRdelete(msg,
                                                        cst.env_info),
                                senderid= outp->list[outpcount].objid,
                                targetid= outp->list[outpcount].objid,
                                targetos= outp->list[outpcount].osnum);
                }
                else { outpcount++ ; }
		}
		/* delete composite surface and boundary curves   */
		if ( NbFloor > 1){
			SMDelInterObj( 1, &comp_surf, cst.env_info, FALSE );
		}
		SMDelInterObj( nb_bound, BOUNDtab, cst.env_info, TRUE ); 
        }
        outp->count=outpcount;
 
	if (outpcount && xData->overrides.dpAttr.filledDisplay ){
                        IGRint NumPlane=0;
                        struct GRid *OutPlane=NULL;
 
                        if( !( OutPlane=_MALLOC( outpcount, struct GRid ) ) )
                                vd_$mem_fail() ;
                        sts = VDdrwcstPlane( msg, inp, outp->count,
                                        outp->list, cst, &NumPlane, OutPlane);
                        __CheckRC( sts,*msg,"VDdrwcstPlane", wrapup );
                        if( !( outp->list=_REALLOC( outp->list,
                                NumPlane+outpcount, struct GRid ) ) )
                                vd_$mem_fail() ;
                        for (i=outpcount; i<outpcount+NumPlane; i++){
                                outp->list[i].objid=OutPlane[i-outpcount].objid;
                                outp->list[i].osnum=OutPlane[i-outpcount].osnum;
 
                        }
                        outp->count=outpcount + NumPlane;
 
                        _FREE(OutPlane);
        }
	
        sts  = OM_S_SUCCESS ;
        *msg = MSSUCC ;
 
        wrapup :
                if( !(sts & 1 & *msg) ) {
                        if( outp->list ) {
                                _FREE( outp->list ) ;
                                outp->list  = NULL ;
                                outp->count = 0 ;
                        }
                }
 
                if ( Floor ){
                         _FREE( Floor );
                }
 
                End
                return sts ;
} /* VDdrwCompContour */
/*----------------------------------------------------------------------------*/
long VDdrwCompInterContour( msg, inp, xData, outp )
 
long                    *msg ;
VD_drwInputData         *inp ;
VD_drwExecData          *xData ;
VD_drwGraphicGroup      *outp ; { 

        long                    sts ;             /* OM completion code.      */
        struct GRvg_construct   cst ;             /* Construction list for    */
                                                  /* wireframe elements.      */
        struct GRid             mySolid,          /* Bottom side of plate.    */
                                cvComp ;          /* Composite curve of       */
                                                  /* contour.                 */
        OMuword                 pjClassid ;       /* Class of the projected   */
                                                  /* curve.                   */
 
	int			outpcount=0;
        struct GRid             *intersList=NULL;
        struct GRid             *flatList=NULL;
 
        SetProc( VDdrwCompInterContour ); Begin
 
        __DBGpr_obj( "Compartment to draw", *(inp->elmId) ) ;
 
        outp->count = 0 ;
        outp->list  = NULL ;
 
        cvComp.objid = NULL_OBJID ;
 
        /*
         * Construct construction list for wireframe elements.
         */
        vd_$fill_cnst_list( Msg          = msg,
                           Env_info     = inp->drwInfo.drwEnv,
                           Level        = xData->overrides.elmLevel,
                           Display      = &xData->overrides.elmDisplay,
                           Cnst_list    = cst ) ;
 
        /*
         * Get the solid of the compartment
         */
 
        sts = om$send( msg      = message NDmacro.ACreturn_foot(
                                                               msg,
                                                               "sol",
                                                               &mySolid,
                                                               NULL,
                                                               NULL ),
                       senderid = inp->elmId->objid,
                       targetid = inp->elmId->objid,
                       targetos = inp->elmId->osnum ) ;
 
        __CheckRC( sts, *msg, "NDmacro.ACreturn_foot", wrapup ) ;
 
        __DBGpr_obj( "The solid of the compartmen", mySolid ) ;
 
        /*
         * Create a composite curve of bottom side's contour.
         */
        {
                IGRint                  i, numInters,flatCount;
                struct GRlc_info        objToIntersect ;
		IGRint			msg1;
 
                objToIntersect.located_obj              = mySolid ;
                objToIntersect.geom_parms.leaf_id.objid = NULL_OBJID;
                objToIntersect.module_info              = *(inp->elmEnv) ;
 
 
		/* inp->drwInfo.viewPlane */
                sts = om$send(msg = message GRvg.EMintplane(&cst,
                                                inp->drwInfo.drwPlane,
                                                &objToIntersect,
                                                &numInters,
                                                &intersList,
                                                &msg1 ),
                        senderid = mySolid.objid,
                        targetid= mySolid.objid,
                        targetos= mySolid.osnum ) ;
 
		sts = SMFlGrGrOfInters(msg, numInters, intersList,
					&cst, &flatCount, &flatList);

		if( !( sts & 1 & *msg ) )
 		{  SMDelInterObj ( numInters, intersList, cst.env_info, TRUE );
    			goto wrapup ;
 		}
		_FREE(intersList ) ;
		 numInters      = flatCount ;
 		intersList     = flatList ;
        	/*
         	* Allocate memory for output list.
         	*/
        	if( !( outp->list=_MALLOC( numInters, struct GRid ) ) ) 
			vd_$mem_fail() ;
 
		for (i=0; i<numInters; i++)  outp->list[i].objid=NULL_OBJID;
		for (i=outpcount=0; i < numInters; i++) {	
			if(IF_NULL_OBJID(intersList[i].objid)) continue;
        		/*
         		* Project composite curve onto drawing plane.
         		*/
        		sts = EFproject_any_curve_on_planen( msg,
                                             &cst,
                                             &intersList[i],
                                             cst.env_info,
                                             inp->drwInfo.drwPlane,
                                             inp->drwInfo.viewVector,
                                             &outp->list[outpcount],
                                             &pjClassid ) ;
 
        		__CheckRC( sts,*msg,"EFproject_any_curve_on_planen", wrapup ) ;
			if(!(sts & 1 & *msg))
     			{
      			printf("Warnning, Bad curve projection\n");
      			continue;
     			}
 
    			if(om$is_ancestry_valid(superclassid = OPP_GR3dpoint_class_id,
                            subclassid   = pjClassid ) == OM_S_SUCCESS)
     			{
      			om$send(msg = message GRgraphics.GRdelete(msg, 
							cst.env_info),
				senderid= outp->list[outpcount].objid,
                                targetid= outp->list[outpcount].objid,
                                targetos= outp->list[outpcount].osnum);
     			}
    			else
     			{
      			outpcount++ ;
     			}
    			/* Delete the intersection curve */
    			om$send(msg = message GRgraphics.GRdelete(msg, 
							cst.env_info),
				senderid= intersList[i].objid,
                                targetid= intersList[i].objid,
                                targetos= intersList[i].osnum ) ;
 
		}
		outp->count=outpcount;
 
		
		if (outpcount && xData->overrides.dpAttr.filledDisplay ){
			IGRint NumPlane=0;
			struct GRid *OutPlane=NULL;

			if( !( OutPlane=_MALLOC( outpcount, struct GRid ) ) )
                        	vd_$mem_fail() ;
                	sts = VDdrwcstPlane( msg, inp, outp->count, 
					outp->list, cst, &NumPlane, OutPlane);
        		__CheckRC( sts,*msg,"VDdrwcstPlane", wrapup );
			if( !( outp->list=_REALLOC( outp->list, 
				NumPlane+outpcount, struct GRid ) ) )
                        	vd_$mem_fail() ;
			for (i=outpcount; i<outpcount+NumPlane; i++){
				outp->list[i].objid=OutPlane[i-outpcount].objid;
				outp->list[i].osnum=OutPlane[i-outpcount].osnum;
				
			}
			outp->count=outpcount + NumPlane;
			_FREE(OutPlane);
		}
        	sts  = OM_S_SUCCESS ;
        	*msg = MSSUCC ;
        }

        wrapup :
                if( !(sts & 1 & *msg) ) {
                        if( outp->list ) {
                                _FREE( outp->list ) ;
                                outp->list  = NULL ;
                                outp->count = 0 ;
                        }
                }
 
                if ( intersList ){
                         _FREE( intersList );
                }
 
                End
                return sts ;
 
} /* VDdrwCompInterContour */
/*----------------------------------------------------------------------------*/
void VD_drwObjFile   (struct GRobj_env       obj_env,
                 int                    pos,
                 VD_execRes             *res    )
{
        int             sts;
        GRname          path_name;
        int                     trunc;
 
        res->type = VD_string;
        *res->_sval = '\0';
 
        /* syntax check */
	/*
        if (!XFLAG) {
                strcpy (res->_sval, "obj_file_name");
                return;
                }
	*/
 
        /* Null object */
        if (obj_env.obj_id.objid == NULL_OBJID) {
                res->type = VD_null;
                return;
                }
 
        sts = di$give_pathname( osnum           = obj_env.obj_id.osnum,
                                pathname        = path_name );
        if( sts != DIR_S_SUCCESS ) {
                di$report_error( sts     = sts,
                                 comment = "Error in di$give_pathname" );
                VD_expReportError ( pos, res, "Cannot evaluate object file name"
);
                }
        else
                VD_strncpy( res->_sval, strrchr(path_name, ':' )+1,
                                                VD_K_tokMAX_SIZE, &trunc ) ;
} /* VD_drwObjFile */

/*----------------------------------------------------------------------------*/
void
VD_drwObjMacroName      (struct GRobj_env       obj_env,
                        int                     pos,
                        VD_execRes              *res    )
{
        int     junk;
        junk = pos;
 
        res->type = VD_string;
        *res->_sval = '\0';
 
        /* syntax check */
	/*
        if (!XFLAG) {
                strcpy (res->_sval, "macro_name");
                return;
                }
	*/
 
        /* Null object */
        if (obj_env.obj_id.objid == NULL_OBJID) {
                res->type = VD_null;
                return;
                }
 
        /* Get ACcpx object macro name */
        if (!VD_drwGetACcpxInfo (&obj_env.obj_id, res->_sval, TRUE)) {
                if (!VD_drwGetGRhdrInfo( &obj_env.obj_id, res->_sval, TRUE )) {
                        *res->_sval = '\0';
                        }
                }
} /* VD_drwObjMacroName */
/*----------------------------------------------------------------------------*/

void
VD_drwDbDynSelect (   const VD_drwArgLst                *list,
			struct GRobj_env        	obj_env,
                        int                             pos,
                        VD_execRes                      *res)
{
        long            sts;
        VD_execRes      Str;
        VD_tktxt        query, buf ;
        int             trunc;
        char            table_name[80];
        char            str[80];
 
        /* default result */
        res->type = VD_null;
 
        /* syntax check */
	/*
        if (!XFLAG) {
                res->type = VD_string;
                strcpy (res->_sval, "dyn_select_result");
                return;
                }
	*/

 
        /* construct query */
        strcpy (query, "select ");
 
        /*
         * Attr name
         */
        if (!VD_expStrncat (query, list->arg, &trunc))
                goto wrapup;
        if (trunc) goto trunc;
 
        /*
         * Table name
         */
        VD_strncat ( query,  " from ", VD_K_tokMAX_SIZE, &trunc);
        /* No table given */
        if (!list->next) {
                VD_drwObjDynTable (obj_env, pos, &Str);
                if (Str.type == VD_null) {
                        goto wrapup;
                        }
 
                if (!VD_expStrncat ( query, Str, &trunc))
                        goto wrapup;
                strcpy (table_name, Str._sval);
                }
        /* table is given */
        else {
                list = list->next ;
                if (!VD_expStrncat ( query, list->arg, &trunc))
                        goto wrapup;
                strcpy (table_name, list->arg._sval);
                }
        if (trunc) goto trunc;
 
        /*
         * Objid
         */
        sprintf (buf, " where comp_seqno = %d and ", obj_env.obj_id.objid);
        VD_strncat ( query, buf, VD_K_tokMAX_SIZE, &trunc);
        if (trunc) goto trunc;
 
        /*
         * Filename (Assembly name)
         */

        VD_drwObjPdmId(obj_env, pos, &Str);
        if (Str._sval[0] == '\0') {
                res->type = VD_null;
                goto wrapup;
                }
 
        VD_expStrncat (query, Str, &trunc);
        if (trunc) goto trunc;

 
        /* execute query */
        sts = VD_drwDbQuery (query, pos, res);
        if (sts == -1 )
                VD_expPrintWarn (
                        "Purge dynamic table to remove multiple values") ;
        else if (sts == -2) {
                sprintf (str, "object not posted to '%s'", table_name);
                VD_expPrintWarn (str);
                }
 
wrapup:
        return ;
trunc:
        /* query was truncated */
        VD_expReportError ( pos, res, "Query too long");
        goto wrapup;
} /* VD_drwDbDynSelect */

/*----------------------------------------------------------------------------*/

VD_drwObjDynTable (     struct GRobj_env        obj_env,   /* I: object */
                        int                     pos,
                        VD_execRes              *res    )
{
        int                     nbCatalogs, sts;
        struct GRid             obj;
        struct ACobj_info_1     obj_info_1;
        struct vdscatalog       *VdsCatalogs = NULL;
        int     junk;
        junk = pos;
 
        res->type = VD_null;
 
        /* syntax check */
	/*
        if (!XFLAG) {
                strcpy (res->_sval, "dynamic_table");
                return;
                }
	*/
 
        /* Null object */
        if (obj_env.obj_id.objid == NULL_OBJID) {
                res->type = VD_null;
                return 1;
                }
 
        obj.objid = obj_env.obj_id.objid;
        obj.osnum = obj_env.obj_id.osnum;
 
        if (!vd_$is_ancestry_valid (    object =  &obj,
                                        classid = OPP_ACdb_info_class_id)){
                res->type = VD_null;
                VD_expPrintWarn ("object cannot be posted to a dynamic table");
                return 1;
                }
 
        VdsGet_db_info( &obj, &obj_info_1, 1 );
        if (obj.objid == NULL_OBJID) goto wrapup;
 
        /* If connected to the database - try to read VDSCATALOGS */
        if ( VDSverify_login () == PDM_S_SUCCESS) {
                VDReadVdsCatalogs( &nbCatalogs, &VdsCatalogs );
                /* ignore return status - vdscatalogs table may not exist */
                }
        else
                VD_expPrintWarn ("using default mapping - not connected to the database ") ;
        sts = VDGetDynTableName( obj_info_1.quantity, obj, obj_env.mod_env,
                           REG_CHECKIN, REP_MODEL, nbCatalogs, VdsCatalogs,
                           res->_sval );
        if( sts == VDS_E_DYNAMIC_TABLE_NOT_FOUND || res->_sval == NULL )
                res->type = VD_null;
        else
                res->type = VD_string;
 
wrapup:
        _FREE(VdsCatalogs);
        return 1;
} /* VD_drwObjDynTable */

/*----------------------------------------------------------------------------*/
int
VD_drwDbQuery ( VD_tktxt        query,
                int             pos,
                VD_execRes      *res)
{
 
        int             countOfColumns  = 0,
                        countOfRows     = 0 ;
        char            **results       = NULL ;
        int             trunc;
        int             flag            = FALSE;
 
        /* initialize return value */
        res->type  = VD_null;
 
        /* verify user is connected to database */
        if ( VDSverify_login () != PDM_S_SUCCESS) {
                VD_expReportError ( pos, res, "No connection to database");
                UI_status ( "Database login required to evaluate expression");
                goto wrapup;
                }
 
        UI_status ("Accessing database...");
        if( !VDSsql_query ( query, &countOfColumns, &countOfRows,
                                                        &results ) ) {
                VD_expReportError ( pos, res, "Query failed");
                goto wrapup;
                }
 
        /* Query succeeded */
        flag = TRUE;
 
        /* Query returned something */
        if( countOfColumns && countOfRows ) {
                /*
                 * We may have multiply equal entries in the items returned
                 * (because of the way the catalogs are made...). So trim down
                 * to one occurence per item.
                 */
                long    msg ;
                int     nbResults = countOfColumns * countOfRows ;
                int     arraySize ;
                char    **compressed ;
 
                VD_remove_dups_in_list( &msg, nbResults, results,
                                                &arraySize, &compressed ) ;
 
                if( !(msg & 1) ) {
                        VD_expPrintWarn ("memory allocation failure") ;
                        goto wrapup;
                        }
 
                if (arraySize > 1 ) {
                        VD_expPrintWarn ("query returns multiple values") ;
                        flag = -1;
                        goto wrapup;
                        }
 
                /* return result */
                res->type       = VD_string ;
                VD_strncpy (res->_sval, compressed[0], VD_K_tokMAX_SIZE,&trunc);
                if (trunc){
                        strcpy (&(res->_sval[VD_K_tokMAX_SIZE-6]), "\n ...");
                        VD_expPrintWarn ("query result was truncated");
                        }
 
                _FREE ( compressed ) ;
                VdsRisFreeBuffer( results, nbResults ) ;
                }
 
        /* No object in table */
        else
                flag = -2;
 
 
wrapup:
        UI_status ("");
        return flag;
}

/*----------------------------------------------------------------------------*/
VD_drwObjPdmId ( struct GRobj_env       obj_env,   /* I: object */
                 int                    pos,
                 VD_execRes             *res)
{
        VD_execRes      Str;
        int             sts;
        char            catalog[VDB_MAX_CATALOG_LEN];
        char            partid[VDB_MAX_CATALOG_LEN];
        char            revision[VDB_MAX_CATALOG_LEN];
        VD_tktxt        buf ;
 
        extern          PDMGetPartInfoGivenFileName(), _pdm_status();
 
        res->type = VD_string;
        *res->_sval = '\0';
 
        /* syntax check */
	/*
        if (!XFLAG) {
                strcpy (res->_sval, "pdmid");
                return;
                }
	*/
 
        /* Null object */
        if (obj_env.obj_id.objid == NULL_OBJID) {
                res->type = VD_null;
                return 1;
                }
 
        /* verify user is connected to database */
        if ( VDSverify_login () != PDM_S_SUCCESS) {
                VD_expReportError ( pos, res, "No connection to database");
                UI_status ( "Database login required to evaluate expression");
                return 1;
                }
 
        VD_drwObjFile (obj_env, pos, &Str);
        sts = PDMGetPartInfoGivenFileName(Str._sval, catalog, partid, revision);
        _pdm_status("PDMGetPartInfoGivenFileName", sts);
 
        if (sts == PDM_S_SUCCESS) {
                sprintf (buf,"%s = '%s' and %s = '%s' and %s = '%s'",
                                "assembly_cat", catalog,
                                "assembly_nam", partid,
                                "assembly_ver", revision);
                strcpy (res->_sval, buf);
                }
        else
                VD_expPrintWarn ( "file not checked into PDU");
	return 1;
} /* VD_drwObjPdmId */

/*----------------------------------------------------------------------------*/
end implementation EMSsurface ;
