/* $Id: VLpcBendFk.I,v 1.2 2001/02/20 01:05:22 build Exp $  */

/*************************************************************************
 * I/LOFT
 *
 * File:        src/pcard/VLpcBendFk.I
 *
 * Description: Functions related to the placement of Inverse Bending Lines
 *              on Profile Card.
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VLpcBendFk.I,v $
 *      Revision 1.2  2001/02/20 01:05:22  build
 *      Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *      Revision 1.1.1.1  2001/01/04 21:11:32  cvs
 *      Initial import to CVS
 *
# Revision 1.2  2000/03/23  21:47:42  pinnacle
# Replaced: src/pcard/VLpcBendFk.I for:  by impd252 for loft
#
# Revision 1.1  1998/04/30  10:32:50  pinnacle
# LOFT 2.5.1
#
# Revision 1.1  1997/11/10  16:29:50  pinnacle
# Created: src/pcard/VLpcBendFk.I by rchennup for loft
#
 *
 * History:
 *      MM/DD/YY   AUTHOR       DESCRIPTION
 *      11/10/97   Rama Rao     File Creation
 *************************************************************************/

class implementation VDSroot;

#include <stdio.h>
#include "bstypes.h"
#include "bsdistptpt.h"
#include "EMSmsgdef.h"
#include "ACattrib.h"
#include "exmacros.h"
#include "acmacros.h"
#include "v_datamacros.h"
#include "v_miscmacros.h"
#include "vsdrw.h"
#include "vsdrwmacros.h"
#include "vsbeamdef.h"
#include "vlsdl.h"
#include "vlsdldef.h"
#include "vlsdlmacros.h"
#include "vlstifbend.h"
#include "vlpcdef.h"
#include "vldbgmacros.h"

extern GRclassid 	OPP_VSbeam_class_id, OPP_VDdrwGm_class_id;

from  ASsource		import	ASreturn_go;
from  GRgencs		import	GRgetmatrix;
from  GRlinear		import	GRgetpolyline;

#define vdsDEBUG  1
#define vdserrDEBUG  1

IGRlong		VLplaceBendLines( IGRlong		*msg,
				  struct GRobj_env	*Stiff,
                                  struct GRobj_env	*Border,
				  struct GRid		*gmId	 )
{
  IGRint		i, gm, gmCount=0, gmMax;
  IGRlong		sts=OM_S_SUCCESS;
  GRname		gmMacro;
  struct GRid		sel_list[2], *gmList=NULL, gmMacDef;
  struct ACrg_coll	attr;
  VLsdlContext    	sdlC;
  VSdrwOutputData	*output=NULL;
  struct  GRid          context;

	vl$sdlInit( ctx = &sdlC );
	VLvl_pc_LoadKeyWords();

	sel_list[VLPC_IDX_SUPPORT] = Stiff->obj_id;
	sel_list[VLPC_IDX_BORDER]  = Border->obj_id;

	vl$sdlSetState( ctx = &sdlC, state = VLPC_BEND_LINES );

        // set working view
        strcpy( attr.name, VLSDL_VIEW );
        attr.desc.type = AC_ATTRIB_TEXT;
        strcpy( attr.desc.value.att_txt, VLPC_VIEW_SIDE );
        vl$sdlSetAttr(  ctx     = &sdlC,
                        attr    = &attr,
                        colType = VLSDL_SYST_COL );

        vl$sdlGetCol(   ctx     = &sdlC,
                        colType = VLSDL_SYST_COL,
                        colId   = &context );

        vs$drwExecConfig (      msg             = msg,
                                elmId           = &context,
                                elmEnv          = &Border->mod_env,
                                drwPlane        = NULL,
                                viewPlane       = NULL,
                                viewVector      = NULL,
                                drwEnv          = &Border->mod_env,
                                drwLbsys        = NULL,
                                selCount        = 2,
                                selList         = sel_list,
                                filename        = VLPC_GR_FILE,
				appData         = &sdlC,
                                output          = &output	);
        if( !(sts & 1 & *msg )){
                int                     n       = 0 ;
                VSdrwOutputData        *p      = output ;
                while( p ) { n += p->set.count ; p = p->next ; }

                if( n ) {
                        sts  = OM_S_SUCCESS ;
                        *msg = MSSUCC ;
                }
        }

        if( sts & 1 & *msg ) {
                int                     n       = 0 ;
                VSdrwOutputData        *p      = output ;
                while( p ) { n += p->set.count ; p = p->next ; }

                if( n ) {
                        gmList = _MALLOC( n, struct GRid ) ;
                        if( gmList ) {
                                n = 0 ;
                                p = output ;
                                while( p ) {
                                        int i ;
                                        int max = p->set.count ;
                                        struct GRid *l = p->set.list ;
                                        for( i = 0 ; i < max ; i++ ) {
                                                gmList[n++] = l[i] ;
                                        }
                                        p = p->next ;
                                }
                                gmCount = n ;
                        }
                }
        }
        /*
         * Check the number of components of the return graphics
         */
        gmMax = 0 ;
        for( i=0 ; i<gmCount ; i++ ){

           if(  vd_$is_ancestry_valid(
                        object  = gmList +i,
                        classid = OPP_GRowner_class_id )){

                IGRint  count = 0 ;

                sts =
                _VD_SEND_OBJN(   gmList[i],
                                GRowner.GRget_number_components(msg, &count));
                gmMax = (sts&*msg&1) ? (gmMax + count) : (gmMax + 5);
           }
           else{
                gmMax ++;
           }
        }
        __DBGpr_int(" gmCount" , gmCount );
        __DBGpr_int(" gmMax  " , gmMax   );

        sts =
        VD_drwGeomGiveMacroBySize( msg, gmMax, gmMacro );
        __CheckRC( sts, *msg, "VD_drwGeomGiveMacroBySize", wrapup );

        __DBGpr_str(" Macro Name ", gmMacro );

        /*
         * find the macro definition for the first occurence.
         */
        gmMacDef.objid = NULL_OBJID ;
        sts =
        ac$find_macro_defn(     action           = ACfind_load,
                                macro_name       = gmMacro,
                                p_macro_defn_id  = &gmMacDef );

        if( ! ( sts&1 ) || gmMacDef.objid == NULL_OBJID ){
                return OM_S_SUCCESS ;
        }

        /*
         * load the macro definition.
         */
        gmId->osnum = Border->mod_env.md_id.osnum;
        sts =
        om$construct(   classid = OPP_VDdrwGm_class_id,
                        osnum   = gmId->osnum,
                        p_objid = &gmId->objid,
                        msg     = message ACcpx.ACload_macro(gmMacDef));
        __CheckRC( sts, 1, "Construct VDdrwGm and Load Geom macro", wrapup );

        sts =
        _VD_SEND_OBJN(   *gmId,
                        NDnode.NDmove_to_root( msg, gmId, &Border->mod_env ));
        __CheckRC( sts, *msg, "NDnode.NDmove_to_root", wrapup );
        for( gm=0 ; gm<gmCount ; gm++ ){
             IGRlong  tmp_ind = OM_K_MAXINT;
             sts = _VD_SEND_OBJN(  gmList[gm], GRconnector.GRrigidconn(
                                        msg, gmId, &tmp_ind ) );
             __CheckRC( sts, *msg, "GRconnector.GRrigidconn", wrapup );
        }
        sts =
        _VD_SEND_OBJN(   *gmId,
                        NDnode.NDmove_to_root( msg, gmId, &Border->mod_env ));
        __CheckRC( sts, *msg, "NDnode.NDmove_to_root", wrapup );

wrapup:
	_FREE( gmList );
	vl$sdlFree( ctx = &sdlC );
	VSdrwFreeOutputData( &output ) ;
        VSdrwRmFunctions ();

        return sts;

}

IGRlong		VLcreBendOnPc( 	IGRlong			*msg,
				struct 	GRobj_env	Stiff,
				struct  GRobj_env	Cs_obj,
				struct  GRobj_env	Rng,
				char			*webSide,
				IGRboolean		onlyLines,
				struct  GRmd_env	*md_env,
				IGRint			*out_count,
				struct  GRid		**out_list	)
{
	IGRshort		RefMatType, trfMatType;
	IGRint			i, j, start_ind, nblines, four=4, action=1;
	IGRdouble		length, width, tmp_val,
				x_scale=1.0, y_scale=1.0, z_scale=1.0;
	IGRlong			rc, sts=OM_S_SUCCESS;
    	IGRmatrix       	OrgMat, RefMat, ScaleMat, trfMat, invMat;
	GRobjid			dummy;
	struct GRid		go;
        struct GRobj_env        BaseSrf, beam, cs, rng_pt;
	struct GRvg_construct   cst;
   	struct IGRpolyline 	poly;
        IGRchar         	srfName[DI_PATH_MAX];

	 SetProc( VLcreBendOnPc ); Begin

        /* Initialize */
   	VLinitCnst( &cst );
   	cst.env_info = md_env;
	*out_list    = NULL;

        *out_count   = MACRO_SB_FFEET+MACRO_SB_VFEET;
	if( !((*out_list) = _MALLOC( (*out_count), struct GRid )) ) 
	  vd_$mem_fail();

        for ( i=0; i<(*out_count); i++) {
                (*out_list)[i].objid = NULL_OBJID;
                (*out_list)[i].osnum = cst.env_info->md_id.osnum;
        }

        // Stiffner
        sts = om$send(  msg     = message NDmacro.ACreturn_foot( msg, "",
                                        &beam.obj_id,
                                        &beam._matrix_type,
                                        beam._matrix ),
			senderid = NULL_OBJID,
                        targetid = Stiff._objid,
                        targetos = Stiff._osnum );
        beam.mod_env.md_id   = md_env->md_id;

        // Cs
        sts = om$send(  msg     = message NDmacro.ACreturn_foot( msg, "",
                                        &cs.obj_id,
                                        &cs._matrix_type,
                                        cs._matrix ),
			senderid = NULL_OBJID,
                        targetid = Cs_obj._objid,
                        targetos = Cs_obj._osnum );
        cs.mod_env.md_id        = md_env->md_id;

        // Range Point
        sts = om$send(  msg     = message NDmacro.ACreturn_foot( msg, "",
                                        &rng_pt.obj_id,
                                        &rng_pt._matrix_type,
                                        rng_pt._matrix ),
			senderid = NULL_OBJID,
                        targetid = Rng._objid,
                        targetos = Rng._osnum );
        rng_pt.mod_env.md_id        = md_env->md_id;

        /* Get the coordinate system matrix */
	sts = om$send ( msg = message GRgencs.GRgetmatrix
						( msg, OrgMat ),
			senderid = NULL_OBJID,
                        targetid = cs._objid,
                        targetos = cs._osnum );
	__CheckRC( sts, *msg, "GRgencs.GRgetmatrix", wrapup );
        if( cs._matrix_type != MAIDMX ){
             MAmulmx( msg, &four, &four, &four, cs._matrix, OrgMat, trfMat );
             for( i=0; i<16; i++ )   RefMat[i] = trfMat[i];
	}
	else 
	{
	     for( i=0; i<16; i++ )   RefMat[i] = OrgMat[i];
	}
	MAtypemx( msg, RefMat, &RefMatType);

        if ( (vd_$is_ancestry_valid ( object  = &beam.obj_id,
                                     classid = OPP_VSbeam_class_id ) ) ) {

                srfName[0] = '\0';
                sprintf ( srfName, "%s:%s:%s", VS_K_bmGrCmpName, VS_K_bmBody,
                          webSide );

                sts = om$send ( msg = message NDmacro.ACreturn_foot(
                                        msg,
                                        srfName,
                                        &BaseSrf.obj_id,
                                        &BaseSrf.mod_env.md_env.matrix_type,
                                        BaseSrf.mod_env.md_env.matrix ),
				senderid = NULL_OBJID,
                                targetid = beam._objid,
                                targetos = beam._osnum );
		__CheckRC( sts, *msg, "NDmacro.ACreturn_foot", wrapup );
		BaseSrf.mod_env = beam.mod_env;
	}

        /* Call computation function */
        sts = VLcreStifBend ( &beam, &BaseSrf, &cst, RefMat, webSide,
                              out_count, *out_list, msg );
	__CheckRC( sts, *msg, "VLcreStifBend", wrapup );

        sts = om$send( msg = message ASsource.ASreturn_go(
                                                        &go, NULL, NULL),
                                senderid = NULL_OBJID,
                                targetid = (*out_list)[0].objid,
                                targetos = (*out_list)[0].osnum  );
        if( !(sts&1) ) go = (*out_list)[0];

        poly.num_points = 5;
        if( !( poly.points = _MALLOC( 15, IGRdouble ) ) )
                 vd_$mem_fail();

        sts = om$send( msg = message GRlinear.GRgetpolyline(
                                                msg, &RefMatType, RefMat,
                                                &action, &poly            ),
                        senderid = NULL_OBJID,
                        targetid = go.objid,
                        targetos = go.osnum  );
        __CheckRC( sts, *msg, "GRlinear.GRgetpolyline", wrapup );

        length = BSdistptpt( &rc, &poly.points[0], &poly.points[3] );
        width  = BSdistptpt( &rc, &poly.points[3], &poly.points[6] );
        if( length < width ) // Interchange
        {
              tmp_val = length;
              length  = width;
              width   = tmp_val;
        }

        MAinvmx( msg, &four, OrgMat, invMat );
        poly.num_points = 1;
        sts = om$send( msg = message GRlinear.GRgetpolyline(
                                                msg, &RefMatType, invMat,
                                                &action, &poly            ),
                        senderid = NULL_OBJID,
                        targetid = rng_pt._objid,
                        targetos = rng_pt._osnum  );
        __CheckRC( sts, *msg, "GRlinear.GRgetpolyline", wrapup );

        x_scale = poly.points[0]/length;
        y_scale = poly.points[1]/width;
        z_scale = 1.0;

        for( j=0;j<16; ++j )  ScaleMat[j] = RefMat[j];
        for( j=0;j<12;j=j+4)
        {
            ScaleMat[j]   /= x_scale;
            ScaleMat[j+1] /= y_scale;
            ScaleMat[j+2] /= z_scale;
        }

        MAinvmx( msg, &four, ScaleMat, invMat );
        MAmulmx( msg, &four, &four, &four, RefMat, invMat, trfMat );
        MAtypemx( msg, trfMat, &trfMatType);

	__DBGpr_int("Output Count of VLcreStifBend ", *out_count );

        if( onlyLines )  
        {
            for( i=0; i<2; ++i )
            {
                sts = om$send ( msg = message GRgraphics.GRdelete(
                                                msg, cst.env_info ),
                        senderid = NULL_OBJID,
                        targetid = (*out_list)[i].objid,
                        targetos = (*out_list)[i].osnum );
            }
            start_ind = 2;
        }
        else    start_ind = 0;

	nblines = (*out_count)/2 - 1;
	for( i=2; i<nblines+2; ++i )
	{
  	    sts = om$send ( msg = message GRgraphics.GRdelete(
						msg, cst.env_info ),
                       senderid = NULL_OBJID,
                       targetid = (*out_list)[i].objid,
                       targetos = (*out_list)[i].osnum );
	    (*out_list)[i-start_ind] = (*out_list)[i+nblines];
	}
        if( onlyLines )  *out_count -= (nblines+2);
        else             *out_count -= nblines;

	__DBGpr_int("Output Count ", (*out_count) );
	for( i=0; i<(*out_count); ++i )
	{
  	     /* We now can apply the xform to the object */
  	     dummy = NULL_OBJID ;
	     __DBGpr_obj("Output Object ", (*out_list)[i] );
  	     sts = om$send(  msg     = message GRgraphics.GRxform(   
								msg,
                                                                cst.env_info,
                                                                &trfMatType,
                                                                trfMat,
                                                                &dummy ),
				senderid = NULL_OBJID,
				targetid = (*out_list)[i].objid,
				targetos = (*out_list)[i].osnum  );
	     __CheckRC( sts, *msg, "GRgraphics.GRxform", wrapup );
	     (*out_list)[i].objid = dummy;
	}

wrapup:
	_FREE( poly.points );
	End
	return sts;
}

end implementation VDSroot;
