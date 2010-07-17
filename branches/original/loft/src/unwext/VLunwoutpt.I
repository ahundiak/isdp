/* $Id: VLunwoutpt.I,v 1.10 2001/09/19 14:23:31 ramarao Exp $  */

/*************************************************************************
 * I/LOFT
 *
 * File:        src/unwext/VLunwoutpt.I
 *
 * Description: STRUDEL implementation functions.
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VLunwoutpt.I,v $
 *      Revision 1.10  2001/09/19 14:23:31  ramarao
 *      Implemented CR# 5546.
 *
 *      Revision 1.9  2001/09/15 20:40:25  ramarao
 *      Fixed TR# 5568. Extended the unwrap contour in variable bevel case.
 *
 *      Revision 1.8  2001/08/06 18:32:02  ramarao
 *      Fixed TR# 2917.
 *
 *      Revision 1.7  2001/05/31 14:34:25  ramarao
 *      Fixed TR# 5270.
 *
 *      Revision 1.5  2001/03/16 23:59:00  ramarao
 *      Fixed CR# 4467
 *
 *      Revision 1.4  2001/02/20 15:21:50  ramarao
 *      Fixed TR# 4653.
 *
 *      Revision 1.3  2001/02/20 01:07:41  build
 *      Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *      Revision 1.2  2001/01/16 20:01:29  ramarao
 *      *** empty log message ***
 *
# Revision 1.13  2000/12/05  16:11:18  pinnacle
# Replaced: loft/src/unwext/VLunwoutpt.I for:  by rchennup for Service Pack
#
# Revision 1.12  2000/11/01  17:07:50  pinnacle
# Replaced: loft/src/unwext/VLunwoutpt.I for:  by rchennup for Service Pack
#
# Revision 1.10  2000/07/12  22:57:08  pinnacle
# Replaced: loft/src/unwext/VLunwoutpt.I for:  by rchennup for Service Pack
#
# Revision 1.8  2000/05/24  21:58:50  pinnacle
# Replaced: loft/src/unwext/VLunwoutpt.I for:  by rchennup for Service Pack
#
# Revision 1.7  2000/05/19  18:39:00  pinnacle
# Replaced: loft/src/unwext/VLunwoutpt.I for:  by rchennup for Service Pack
#
# Revision 1.23  2000/03/23  20:43:06  pinnacle
# Replaced: src/unwext/VLunwoutpt.I for:  by impd252 for loft
#
# Revision 1.21  2000/03/10  19:22:48  pinnacle
# (No comment)
#
# Revision 1.19  2000/03/06  18:34:12  pinnacle
# (No comment)
#
# Revision 1.18  2000/03/06  15:55:40  pinnacle
# Replaced GRptproject with BSmdistptsf in text projection.
#
# Revision 1.17  2000/03/01  20:40:40  pinnacle
# Replaced VLunwoutpt.I by jpulapar
#
# Revision 1.16  2000/02/16  15:29:46  pinnacle
# (No comment)
#
# Revision 1.15  2000/02/10  21:50:12  pinnacle
# (No comment)
#
# Revision 1.13  2000/01/20  23:01:50  pinnacle
# (No comment)
#
# Revision 1.11  1999/05/26  19:46:26  pinnacle
# Fixed Stock Symbol problem.
# .,
#
# Revision 1.10  1999/05/25  14:07:48  pinnacle
# automarking
#
# Revision 1.9  1999/05/18  16:03:10  pinnacle
# (No comment)
#
# Revision 1.8  1999/04/09  21:20:54  pinnacle
# Rama Rao SP08
#
# Revision 1.7  1998/11/07  15:56:26  pinnacle
# ah
#
# Revision 1.6  1998/11/07  15:31:20  pinnacle
# ah
#
# Revision 1.5  1998/11/05  06:41:32  pinnacle
# Replaced: src/unwext/VLunwoutpt.I for:  by smpathak for loft
#
# Revision 1.4  1998/09/09  04:31:36  pinnacle
# Replaced: src/unwext/VLunwoutpt.I for:  by smpathak for loft
#
# Revision 1.3  1998/09/04  13:41:44  pinnacle
# tr179800900
#
# Revision 1.2  1998/07/08  15:53:28  pinnacle
# Replaced: src/unwext/VLunwoutpt.I for:  by smpathak for loft
#
# Revision 1.1  1998/04/30  10:32:50  pinnacle
# LOFT 2.5.1
#
# Revision 1.4  1998/03/25  10:31:36  pinnacle
# Replaced: src/unwext/VLunwoutpt.I for:  by rchennup for loft
#
# Revision 1.3  1997/10/31  22:07:40  pinnacle
# Replaced: src/unwext/VLunwoutpt.I for:  by rchennup for loft
#
# Revision 1.2  1997/10/31  19:27:32  pinnacle
# Replaced: src/unwext/VLunwoutpt.I for:  by rchennup for loft
#
 *
 * History:
 * MM/DD/YY   AUTHOR       DESCRIPTION
 * 10/28/97   Rama Rao     File Creation
 * 07/08/98   Sandeep      File modification for TR# 179800946
 * 09/04/98   ah           TR179800900 Allow getting attrs from plate during unwrap
 * 09/08/98   Sandeep	   Modified for crash reported be Ad. VLunwFeat made
			   available in parser.
 * 11/03/98   SM PAthak    File modification for TR179801542
 * 11/07/98   ah           Compiler warning about long to int conversion
 *                         Also, clix does not like ushort
 * 04/09/99   ah           Rama Rao SP08 Fixes
 * 05/25/99   ah           Automarking is corrupted
 * 02/04/00   ad	   Set the is_marking_hidden as local.
 * 02/10/00   RR	   Used VLqueryWithNoLocate() instead of VLquery1(),
 *			   which is very costly;
 *************************************************************************/

class implementation VDSroot;

#include        <stdio.h>
#include        <string.h>
#include        "EMSmsgdef.h"
#include        "ACattrib.h"
#include        "ACrg_collect.h"
#include        "bsparameters.h"
#include        "nddef.h"
#include        "exmacros.h"
#include        "asmacros.h"
#include        "vddrwattr.h"
#include        "v_drwapi.h"
#include        "v_drwmacros.h"
#include        "v_datamacros.h"
#include        "v_miscmacros.h"
#include        "vsmiscmacros.h"
#include        "vsplatedef.h"
#include        "v_drw.h"
#include        "vsstfnrdef.h"
#include        "vsbmaxisdef.h"
#include        "vlunfold.h"
#include        "vlunwext.h"
#include        "vlmsg.h"
#include        "vlquerydef.h"
#include        "vlstructure.h"
#include        "vlstifftpl.h"
#include        "vluserkey.h"
#include        "vlmark.h"
#include        "VDchn.h"
#include        "VDobj.h"
#include        "VDmem.h"
#include        "VDsa.h"
#include        "bsdistptpt.h"
#include        "VLunwMisc.h"
#include        "vldbgmacros.h"

#define vdsDEBUG        1
#define vdserrDEBUG     1

extern GRclassid 	OPP_VSbooPlate_class_id, OPP_VSimbPlate_class_id,
			OPP_VSholPlate_class_id, OPP_VSbeam_class_id,
			OPP_VSfeature_class_id,  OPP_VSplate_class_id,
			OPP_VSsubPlate_class_id, OPP_nci_macro_class_id;

#define MAX_VISUAL_FUNC   25

extern VLgetMacrosAtStep(), VLcheckStiffOnPlate();
extern IGRint  VLcheckPlateSideToMark();

extern   OM_S_CHANSELECT AS_to_owner, AS_to_comp;

%safe
static IGRint	firstMap=1;
%endsafe

static	struct GRid   mappedObj[2];

from    ACrg_collect	import	AClist_attribute, ACmod_list_attribute;
from    VSfeature	import  VSgetResultType, VSgetOperationHistory;
from 	VLunwFeat	import	VLgetUnw_obj;
from    VLunwObj	import  VLgetInst_devSrf;
from    VLmrkLine  	import  VLplace_mark;
from	VSstfBeam	import  VSgetPlateSide;
from    GR3dtext	import  GRgenabsg; 
from    ACpretend	import	ACgive_downscan;
from    GRcurve		import	GRtotlength;

IGRint  VLunwext_LoadKeyWords()
{
        char                    *visK   [ MAX_VISUAL_FUNC ] ;
        VD_drwUsrTokType        visU    [ MAX_VISUAL_FUNC ] ;
        VD_drwAction            visA    [ MAX_VISUAL_FUNC ] ;
	VD_drwTOKEN		token ;
        int                     sts,
				i,
                                k = 0,
                                u = 0,
                                a = 0;

	SetProc( VLunwext_LoadKeyWords ); Begin

        visK[ k++     ]        = "unwrap-contour" ;
        visU[ u++     ]        = VD_drwOUTPUT ;       /* unwrap-contour */
        visA[ a++     ].output = OUTPUT_ADDRESS( VD,  unwrap_contour );

        visK[ k++     ]        = "map" ;
        visU[ u++     ]        = VD_drwOUTPUT ;       /* map */
        visA[ a++     ].output = OUTPUT_ADDRESS( VD,  map );

        visK[ k++     ]        = "stocklines" ;
        visU[ u++     ]        = VD_drwOUTPUT ;       /* stocklines */
        visA[ a++     ].output = OUTPUT_ADDRESS( VD,  stocklines );

        visK[ k++     ]        = "is-marking-hidden" ;
        visU[ u++     ]        = VD_drwFUNCTION ;       /* is-marking-hidden */
        visA[ a++     ].function = FUNCTION_ADDRESS( VD, is_marking_hidden );

        visK[ k++     ]        = "mapsource" ;
        visU[ u++     ]        = VD_drwOUTPUT ;       /* mapsource */
        visA[ a++     ].output = OUTPUT_ADDRESS( VD,  mapsource );

        visK[ k++     ]        = "delete-cut" ;
        visU[ u++     ]        = VD_drwOUTPUT ;       /* delete-cut */
        visA[ a++     ].output = OUTPUT_ADDRESS( VD,  delete_cut );

        visK[ k++     ]        = "is-ns-fs-mark" ;
        visU[ u++     ]        = VD_drwFUNCTION ;       /* is-ns-fs-mark-cut */
        visA[ a++     ].function = FUNCTION_ADDRESS( VD,  is_ns_fs_mark );

        visK[ k++     ]        = "get-knuckle-angle" ;
        visU[ u++     ]        = VD_drwFUNCTION ;       /* get-knuckle-angle */
        visA[ a++     ].function = FUNCTION_ADDRESS( VD,  get_knuckle_angle );

        visK[ k++     ]        = "extend-contour" ;
        visU[ u++     ]        = VD_drwOUTPUT ;       /* extend-contour */
        visA[ a++     ].output = OUTPUT_ADDRESS( VD,  extend_contour );

        visK[ k++     ]        = "dimension-lines" ;
        visU[ u++     ]        = VD_drwOUTPUT ;       /* dimension-lines */
        visA[ a++     ].output = OUTPUT_ADDRESS( VD,  dimension_lines );

        visK[ k++     ]        = "get-curve-length" ;
        visU[ u++     ]        = VD_drwFUNCTION ;     /* get-curve-length */
        visA[ a++     ].function = FUNCTION_ADDRESS( VD,  get_curve_length );

        visK[ k++     ]        = "is-partial-bevel" ;
        visU[ u++     ]        = VD_drwFUNCTION ;     /* is-partial-bevel */
        visA[ a++     ].function = FUNCTION_ADDRESS( VD,  is_partial_bevel );

        /*
         * validation check.
         */
        if( k != u || k != a || u != a ){
                printf(" Error in setup external for Visualization.\n");
                return FALSE ;
        }

	for( i=0; i<k; ++i )
	{
	   if( VD_drwKeyword( visK[i], (FILE *) NULL, &token ) ) 
	   {
		return TRUE;
	   }
	}

        sts = VD_drwAddFunctions( k, visK, visU, visA );
        if( ! (sts & 1)){
          printf(" Error: VD_drwAddFunctions in VLunwext_LoadKeyWords\n");
        }

        End ;
        return sts ;

}
/* -----------------------------------------------------
 * TR179800900
 * Dummy implementation for zdl testing
 * Ends up getting overridden by vds version
 */
#if 0
static struct GRobj_env gparserModelOE;

void VDSetParserModelOE(struct GRobj_env *modelOE) 
{
  if (modelOE == NULL) gparserModelOE.obj_id.objid = NULL_OBJID;
  else gparserModelOE = *modelOE;
}
void VDGetParserModelOE(struct GRobj_env *modelOE) 
{
  if (modelOE != NULL) *modelOE = gparserModelOE;
}
#endif

/*------------------------------ Automarking Function --------------------*/
/*  Implimented here for TR179801542             */

long VLautomarking(struct GRobj_env plate )
{

 int                    nb_mark=0,nb_mac=0,numObjects=0,j,i,stiff_side;
 IGRdouble              ChtTol,RangTol;
 IGRlong                msg,stat;
 GRclassid		classids[1];
 struct GRobj_env       *list_obj  = NULL, *buf=NULL ;
 struct GRsymbology      loc_symb;
 IGRchar                 MarkName [50], status_msg[128],
                         loc_path[DI_PATH_MAX];
 enum    GRdpmode        dpmode=GRbd;            // mode for placed mark
 struct  GRmd_env        curr_env;
 GRspacenum              osNum;



        stat = gr$get_module_env(  buffer = &curr_env );
        stat = ex$get_cur_mod (osnum = &osNum);

	UI_status(" Getting the plates/stiffeners in the plate range..." );

	classids[0] = OPP_VSfeature_class_id;

             stat = VLqueryWithNoLocate ( &msg, &plate, &curr_env, 1,
                classids, VLcheckStiffOnPlate, &nb_mac, &buf );
             if( !( stat&msg&1) )  goto wrapup;

             nb_mark = 0;

             for( i=0; i<nb_mac; ++i )
             {
                struct GRid        stiff_obj;
                struct GRobj_env   templates[2];
                struct GRobj_env   markPlateOE;

		sprintf(status_msg, "Marking ... %d / %d", i+1, nb_mac );
		UI_status( status_msg );

                VLbrowseFctInTree( &buf[i], VL_Q_TOP_SOURCE, NULL,
                 VL_Q_DOWN_DIRECT,VLgetMacrosAtStep, &numObjects, &list_obj );
                VLfilterDef(numObjects,list_obj,&numObjects,"Mark");

                for( j=0; j<numObjects; ++j )
                {
		  // Compiler warning
		  IGRint msgi;
		  
                   stat = _VD_SEND_OBJN( list_obj[j].obj_id,
                                        ACcpx.ACfind_exp_temp_obj(
                                                &msgi, 1, &stiff_obj ) );
                   __CheckRC( stat, msgi, "ACcpx.ACfind_exp_temp_obj", wrapup );
               /* -----------------------------------------------------
                * TR179801074 We could have an ACpretendin at this point instead
                * of the actual parent plate which will cause another marking
                * line to be placed
                */
                   VDahGetObjectEnv(&stiff_obj,&markPlateOE);
                   if( markPlateOE.obj_id.objid == plate._objid &&
                       markPlateOE.obj_id.osnum == plate._osnum    ) break;
                }


                if( numObjects && j<numObjects ) goto free_mem;

                templates[0] = plate;
                templates[1] = buf[i];

                // Note how this changes the osnum of buf[i]
                buf[nb_mark].obj_id.osnum = osNum;
                buf[nb_mark].mod_env = curr_env;
                stiff_side = VS_K_stOnBotOfPlate;
		
		// So this dont work very good
		// if( vd_$is_ancestry_valid( object  = &buf[i].obj_id,
                //                            classid  = OPP_VSbeam_class_id ))
              	if( vd_$is_ancestry_valid( object  = &templates[1].obj_id,
                                        classid  = OPP_VSbeam_class_id ))
		{
        	  stat = _VD_SEND_OBJN( templates[1].obj_id, VSstfBeam.VSgetPlateSide(
                                        &msg, &stiff_side ));

	          if( !(stat&msg&1) ) stiff_side = VS_K_stOnBotOfPlate;
		}
		else if( vd_$is_ancestry_valid( object  = &templates[1].obj_id,
                                        classid  = OPP_VSplate_class_id ))
		{
		  if( VLcheckPlateSideToMark(&plate, &templates[1],&curr_env))
		  {
		     stiff_side = VS_K_stOnTopOfPlate;
		  }
		  else
		  {
		     stiff_side = VS_K_stOnBotOfPlate;
		  }
		}
                stat = om$construct(classid =  OPP_VLmrkLine_class_id,
                                osnum      =   buf[nb_mark].obj_id.osnum,
                                p_objid    =  &buf[nb_mark].obj_id.objid,
                                msg        =  message VLmrkLine.VLplace_mark(
                                                 &msg ,
                                                 stiff_side,
                                                 VS_K_baOnBotOfPlate,
                                                 2,
                                                 templates,
                                                 &curr_env     ) );
                if (!(stat& msg&1)) goto free_mem;

                loc_path[0] = '\0';
                stat = VDSget_dir_and_symb ( & msg, &buf[nb_mark].obj_id,
                                  MARK_KEY, NULL, loc_path, &loc_symb.level,
                                  &loc_symb.display_attr );
                if (!(stat& msg&1)) goto free_mem;

                VLoccNaming1 ( loc_path, VLMarkName, MarkName, &msg);
                if (!(msg&1)) goto free_mem;

                stat =     VLsetSymb_Name_Disp(
                                     &msg,
                                     MarkName,
                                     MARK_KEY,
                                     &templates[0].obj_id,
                                     &buf[nb_mark].obj_id,
                                     &dpmode,
                                     &buf[nb_mark].mod_env  );
                ++nb_mark;
free_mem:
                _FREE( list_obj );      list_obj = NULL;
                numObjects=0;

        }

	UI_status("Finished AutoMarking");
        __DBGpr_int(" the no of mark = %d ",nb_mark);

wrapup:
        _FREE( buf );      buf = NULL;
        return 1;

}

/*********** End Automarking Function ********************/





/*----------------------------------------------------------------------------*/
#argsused
IMPLEMENT_OUTPUT( VD, unwrap_contour ) {
	BSrc			rc;
	int			j, k, count, map_option,optlines[UNWEXT_NB_OPT];
	short			trfMatType;
        long            	sts, msg ;
	IGRdouble		fromMat[16], toMat[16], trfMat[16];
	unsigned long           obj_type ;
	struct GRid		UnwObj, res_id, list[2];
	struct unw_obj_plat  	dev;
	struct mise_a_plat      myDev;
	struct GRobj_env	plate, par_plate, temp_obj;
  	VSopHistory             *history=NULL, *h ;
	VDpartAttr              attr ;
	struct  ACrg_coll       list_att[UNFOLD_NB_OPT];
        const char      	*type = xData->parsedElmDesc ;

	SetProc( VDdrwOUTPUTunwrap_contour ); Begin

	if( strcmp( type, "unwrap" ) ) 
	{ 
	    WRONG_OUTPUT ;
	}

	UnwObj= *(inp->elmId);

	VLinitDev( &myDev );

        sts = _VD_SEND_OBJN( UnwObj, NDnode.NDget_objects( ND_ROOT,
                                list, 2, NULL, 0, 1, &count ));
        __CheckRC( sts, 1, "NDnode.NDget_objects", quit );

	/* Find attributes */
	sts = _VD_SEND_OBJN( list[0], ACrg_collect.AClist_attribute(
				&msg, UNFOLD_NB_OPT, list_att, &k) );
        __CheckRC( sts, msg, "ACrg_collect.AClist_attribute", quit );

  	if ((j=VLseekFields(list_att,k,UNFOLD_ATT_SIDE)) != -1) {
    	    myDev.side_of_plate = list_att[j].desc.value.att_exp;
  	}
  	if ((j=VLseekFields(list_att,k,UNFOLD_ATT_TESSELATION)) != -1) {
    	    myDev.tesselation_option = list_att[j].desc.value.att_exp;
  	}
  	if ((j=VLseekFields(list_att,k,UNFOLD_ATT_LINES)) != -1) {
    	    myDev.WantedLinesCode = (int) list_att[j].desc.value.att_exp;
	    VLdecode( myDev.WantedLinesCode, UNWEXT_NB_OPT, optlines );
  	}
  	if ((j=VLseekFields(list_att,k,UNFOLD_ATT_FIB_RATIO)) != -1) {
   	   myDev.fib_ratio = list_att[j].desc.value.att_exp;
  	}
  	if ((j=VLseekFields(list_att,k,UNFOLD_ATT_WATONPLATE)) != -1) {
    	   myDev.AllWaterLines  = list_att[j].desc.value.att_exp;
  	}

        if ((j=VLseekFields(list_att,k,UNFOLD_ATT_UNWOPT)) != -1) {
               map_option = (IGRint) list_att[j].desc.value.att_exp;
        }
        else    map_option = 0;
 
        sts = _VD_SEND_OBJN( list[1], NDmacro.ACreturn_foot(
                                        &msg, "", &plate.obj_id,
                                        &plate._matrix_type,
                                        plate._matrix           ) );
        __CheckRC( sts, msg, "NDmacro.ACreturn_foot", wrapup );
        __DBGpr_obj( " Original Plate in model ", plate.obj_id );
        plate._md_os = plate.obj_id.osnum;
        ex$get_modid(   mod_osnum = plate._md_os,
                        mod_id    = &plate._md_id ) ;

	/* TR179800900
	 *Tell everyone that this is the master model object
	 */
	VDSetParserModelOE(&plate);
	
	if( optlines[UNWEXT_ATT_IDX_PARENT] )
	{
           sts = _VD_SEND_OBJN( plate.obj_id, VSfeature.VSgetResultType(
                                                        &msg, &obj_type ) );
           __CheckRC( sts, msg, "Getting plate type", wrapup ) ;

          if( ( obj_type & VS_m_BOO_PLATE ) || ( obj_type & VS_m_IMB_PLATE ) )
          {
            sts = _VD_SEND_OBJN( plate.obj_id, VSfeature.VSgetOperationHistory(
                                        &msg, &plate.mod_env, &history ) );
            __CheckRC( sts, msg, "Getting Operation History", wrapup ) ;

            for( h = history ; h ; h = h->next ) {
	      	res_id.objid = h->resultId;
	      	res_id.osnum = h->resultOs;
              	if( vd_$is_ancestry_valid( object  = &res_id,
                                        classid  = OPP_VSbooPlate_class_id ) ||
		    vd_$is_ancestry_valid( object  = &res_id,
					classid  = OPP_VSimbPlate_class_id ) ||
		    vd_$is_ancestry_valid( object  = &res_id,
		     			classid  = OPP_VSholPlate_class_id ) )
 	          continue;

		par_plate.obj_id.objid = h->resultId;
		par_plate.obj_id.osnum = h->resultOs;
		par_plate.mod_env      = h->resultEnv;
	    }
	  } else par_plate = plate;
	}
	else par_plate = plate;

	/********* Modification for TR#179801542 *********/
        if( optlines[UNWEXT_ATT_IDX_AUTOMRK] && optlines[UNFOLD_ATT_IDX_MARK] )
                VLautomarking( par_plate );
	/********* End Modification  ********************/

	sts = VLextractSurf( &par_plate.obj_id, inp->elmEnv, &myDev, NULL );
	__CheckRC( 1, sts, "VLextractSurf", quit );

	sts = VLgetGeometry( &myDev.surf_id, TRUE, NULL_OBJID, 
				(IGRchar **)&myDev.surface, &msg );
	__CheckRC( sts, msg, "VLgetGeometry", quit );

	/* Set up to fold as QUAD */
	myDev.type = 4;
	myDev.developpable = 0;

	j = myDev.tesselation_option;
	
	sts = VLgetPtsNorms( &myDev, myDev.tesselation_option, 0 );
	__CheckRC( 1, sts, "VLgetPtsNorms", quit );

 	if (myDev.tesselation_option != j) {
    	   strcpy(list_att[0].name,UNFOLD_ATT_TESSELATION);
           list_att[0].desc.type = AC_ATTRIB_DOUBLE;
           list_att[0].desc.value.att_exp = myDev.tesselation_option;

	   sts = _VD_SEND_OBJN( list[0], ACrg_collect.ACmod_list_attribute(
						&msg, 1, list_att ) );
           __CheckRC( sts, msg, "ACrg_collect.ACmod_list_attribute", quit );
	}

	sts = VLmaplatNDevelNew( &myDev, map_option );
      	__CheckRC( 1, sts, "VLmaplatNDevel", quit );

        attr.Iwant = VL_I_devStruct ;
        attr.specific = (void *) &myDev ;
        sts = _VD_SEND_OBJN( UnwObj, GRvg.GRputattr( &msg, (char *)&attr ));
        __CheckRC( sts, msg, "GRvg.GRgettattr", wrapup );

	/* Initialize the 'dev' structure */
	dev.devsrf  = NULL;
	dev.surface = NULL;
	dev.P       = NULL;
	dev.def     = NULL;
	dev.Param_u = NULL;
	dev.Param_v = NULL;

        attr.Iwant = VL_I_devStruct ;
        attr.specific = (void *) &dev ;
        sts = _VD_SEND_OBJN( UnwObj, GRvg.GRgetattr( &msg, (char *)&attr ));
        __CheckRC( sts, msg, "GRvg.GRgettattr", wrapup );

	dev.surface = myDev.surface;
	dev.devsrf  = myDev.devsrf;

    	sts = VLunwProcessUnwrap( &msg, &UnwObj, &dev,
					inp, xData, outpgr ) ;
        __CheckRC( sts, msg, "VLunwProcessUnwrap", wrapup );

//	VD_drwCstSymbology( &msg, inp, xData, outpgr ) ;

        attr.Iwant = VL_I_fromMat ;
        attr.specific = (void *) fromMat ;
        sts = _VD_SEND_OBJN( UnwObj, GRvg.GRgetattr( &msg, (char *)&attr ));
        __CheckRC( sts, msg, "GRvg.GRgettattr", wrapup );

        attr.Iwant = VL_I_toMat ;
        attr.specific = (void *) toMat ;
        sts = _VD_SEND_OBJN( UnwObj, GRvg.GRgetattr( &msg, (char *)&attr ));
        __CheckRC( sts, msg, "GRvg.GRgettattr", wrapup );

        sts = _VD_SEND_OBJN( outpgr->list[0], 
				GRgraphics.GRcopy( &msg, 
						   inp->drwInfo.drwEnv,
						   inp->drwInfo.drwEnv,
						   &temp_obj._objid ));

	temp_obj._osnum  = outpgr->list[0].osnum;
	temp_obj.mod_env = *(inp->drwInfo.drwEnv);

        sts = VLapplyTransf( &temp_obj.obj_id, 1, inp->drwInfo.drwEnv, 
				fromMat, toMat,
                            trfMat, &trfMatType, &msg );
        __CheckRC( sts, msg, "VLapplyTransf", wrapup );

	xData->txPosHelper = VD_useAnchorCurve ;
	xData->anchorCurve = temp_obj;

        VD_drwAddGarbage( &msg, xData, &temp_obj );

wrapup:
	_FREE( dev.P   );
	_FREE( dev.def );
	_FREE( dev.Param_u );
	_FREE( dev.Param_v );
	_FREE( myDev.surface );
quit:
        VSfreeOpHistory( history ) ;
	VLfreeDev( &myDev );
        End ;
        return sts & 1 & msg ? xfSUCCESS : xfFAILURE ;

} /* VDdrwOUTPUTunwrap_contour */
/*----------------------------------------------------------------------------*/


/*----------------------------------------------------------------------------*/
#argsused
IMPLEMENT_OUTPUT( VD, map ) {
	BSrc			rc;
        long            	sts, msg ;
	int			numObjects=0, count=0, va_count=0;
	IGRboolean		hasFeet;
	IGRchar			side[10];
	struct GRid		FeatObj, UnwObj, plateId;
	struct GRobj_env        inp_elm, *list_obj=NULL, unw_srf,tmp_obj, 
				plateOE, dev_surf_id, ext_surf;
	struct GRmd_env		md_env;
	struct unw_obj_plat  	dev;
	VDpartAttr              attr ;
	struct IGRlbsys         *lbs = NULL;
        const char      	*type = xData->parsedElmDesc ;

	SetProc( VDdrwOUTPUTmap ); Begin

	/* Initialize the 'dev' structure */
	dev.devsrf  = NULL;
	dev.surface = NULL;
	dev.P       = NULL;
	dev.def     = NULL;
	dev.Param_u = NULL;
	dev.Param_v = NULL;

	inp_elm.obj_id  = *(inp->elmId);
	inp_elm.mod_env = *(inp->elmEnv);
	gr$get_module_env (buffer = &md_env );

        __DBGpr_obj(" The input obj is ",inp_elm.obj_id);
        if(!strcmp( type, "control-line"))
        {
          vdchn$Get(il_objOE  = & (inp_elm) ,
                ic_IDX    = VDCHN_IDX_TO_OWNERS,
                ir_objIDX = 0,
                or_objID  = & (tmp_obj.obj_id));
           __DBGpr_obj("The tmp_obj   ",tmp_obj.obj_id);
 
         tmp_obj.mod_env =  *(inp->elmEnv);
         VLbrowseFctInTree( &tmp_obj, VL_Q_TOP_SOURCE, NULL,VL_Q_DOWN_DIRECT,
                           VLgetMacrosAtStep, &numObjects, &list_obj );
        }
        else {
        VLbrowseFctInTree( &inp_elm, VL_Q_TOP_SOURCE, NULL,VL_Q_DOWN_DIRECT,
                           VLgetMacrosAtStep, &numObjects, &list_obj );
         }
 
        __DBGpr_int(" The numObjects = ",numObjects);

        VLfilterDef(numObjects,list_obj,&numObjects,"VLunwFeat");
	if( !numObjects ) { 	sts = 0; 	goto quit; 	}

	/***  Modified for unwrap crash the latest object need not be last 
	in list , The VLunwFeat made available through parser. ***/
//	FeatObj = list_obj[numObjects-1].obj_id;
        FeatObj = *((struct GRid *)inp->appData);
        __DBGpr_obj (" The FeatObj  is ",FeatObj);

	sts = om$send( msg = message VLunwFeat.VLgetUnw_obj( &msg, &UnwObj ),
			targetid = FeatObj.objid,
			targetos = FeatObj.osnum,
			senderid = FeatObj.objid	);
	__CheckRC( sts, msg, "VLunwFeat.VLgetUnw_obj", wrapup );

        sts = _VD_SEND_OBJN( UnwObj, NDnode.NDget_objects( ND_ROOT,
                             &plateId, 1, NULL, 1, 1, &count ));
        __CheckRC( sts, 1, "NDnode.NDget_objects", wrapup );
        __DBGpr_obj( " Parent Plate ", plateId );

        sts = _VD_SEND_OBJN( plateId, NDmacro.ACreturn_foot(
                                        &msg, "", &plateOE.obj_id,
                                        &plateOE._matrix_type,
                                        plateOE._matrix           ) );
        __CheckRC( sts, msg, "NDmacro.ACreturn_foot", wrapup );
        __DBGpr_obj( " Original Plate in model ", plateOE.obj_id );
        plateOE._md_os = plateOE._osnum;
        ex$get_modid(   mod_osnum = plateOE._md_os,
                        mod_id    = &plateOE._md_id ) ;

        attr.Iwant = VL_I_devStruct ;
        attr.specific = (void *) &dev ;
        sts = _VD_SEND_OBJN( UnwObj, GRvg.GRgetattr( &msg, (char *)&attr ));
        __CheckRC( sts, msg, "GRvg.GRgettattr", wrapup );
	
	// Get the correct surface from the Non-hole plate parent
	if (  dev.side_of_plate == OFFSET_SIDE ||
              dev.side_of_plate == OFFSET_FLIP    )
                     strcpy(side, VS_K_plTopSfPath);
        else         strcpy(side, VS_K_plBotSfPath);
        __DBGpr_str("Side to Unwrap ", side );

	sts = VLunwPlateHasVABevel( &msg, &plateOE, &va_count, NULL, TRUE,
				    side, &ext_surf );
	__CheckRC( sts, msg, "VLunwPlateHasVABevel", wrapup );
	if( (sts&1) && va_count  && ext_surf._objid != NULL_OBJID)	
		dev.surf_id = ext_surf;

        __DBGpr_obj( " Plate Surface Id ", dev.surf_id.obj_id );
        sts = VLgetGeometry( &dev.surf_id, TRUE, NULL_OBJID,
                                (IGRchar **)&dev.surface, &msg );
        __CheckRC( sts, msg, "VLgetGeometry", wrapup );

        sts = _VD_SEND_OBJN( UnwObj, NDmacro.ACreturn_foot(
                        &msg, UNFOLD_NAM_UNWSRF, &unw_srf.obj_id, NULL, NULL ));
	if( !(sts&msg&1) )
	{
	   sts = _VD_SEND_OBJN( UnwObj, VLunwObj.VLgetInst_devSrf(
							&dev.devsrf ) );
	   __CheckRC( sts, 1, "VLunwObj.VLgetInst_devSrf", wrapup );
	  hasFeet = FALSE;
	}
	else
	{
          __DBGpr_obj( " UnwrapSrf Feet ", unw_srf.obj_id );

	  unw_srf.mod_env = list_obj[numObjects-1].mod_env;
          sts = VLgetGeometry( &unw_srf, TRUE, NULL_OBJID,
                                (IGRchar **)&dev.devsrf, &msg );
          __CheckRC( sts, msg, "VLgetGeometry", wrapup );
	  hasFeet = TRUE;
	}

	__DBGpr_obj( " UVSrf Feet ", dev.uvSrfId );
	if( dev.tesselation_option == ARC_LENGTH  &&
	    (om$is_objid_valid ( osnum = dev.uvSrfId.osnum ,
			         objid = dev.uvSrfId.objid ) == OM_S_SUCCESS ))
	{
	   struct GRobj_env	 uvSrf_id;
	   struct IGRbsp_surface *uvSurf=NULL;

	   uvSrf_id.obj_id  = dev.uvSrfId;
	   uvSrf_id.mod_env = list_obj[numObjects-1].mod_env;
	   sts = VLgetGeometry( &uvSrf_id, FALSE, NULL_OBJID,
				(IGRchar **)&uvSurf, &msg );
	   if( sts&1&msg )
	   {
	      sts = VLunwFillDevStructureFromSrf( &msg, uvSurf, &dev );
	   }
	   _FREE(uvSurf); 
	}

	if( argc == 1 )	
	{
	   IGRchar	feet_name[30];

	   VSdrwStrVal( &arglist->arg, feet_name );
	   // if( !strcmp(feet_name, "text") )
	   {
	      BSrc			rc;
	      IGRint			i;
	      IGRdouble			pt[6], tmp[3], dist;
	      struct GRobj_env 		text_obj;
	      struct GRparms		param;
	      struct GRvg_construct     cst;
	      struct GRobj_env		Line;
	      IGRboolean		world = FALSE ;

              sts = om$send( msg      = message NDmacro.ACreturn_foot(
                                        &msg,
                                        feet_name,
                                        &text_obj.obj_id,
                                        &text_obj.mod_env.md_env.matrix_type,
                                        text_obj.mod_env.md_env.matrix),
                            targetid = inp->elmId->objid,
                            targetos = inp->elmId->osnum,
                            senderid = inp->elmId->objid  );
              if( sts & msg & 1 )
              {
		int 	jj;
		double	ptDr[3], vecDr[6];

                text_obj.mod_env._MD_OS = text_obj.obj_id.osnum;
                sts = ex$get_modid(
                                mod_osnum = text_obj.mod_env._MD_OS,
                                mod_id    = &text_obj.mod_env._MD_ID );

		if(!( vs$is_ancestry_valid( object   = &text_obj.obj_id,
                            		  classid = OPP_GRtext_class_id)))
		goto skip_check;

		__DBGpr_obj("Text Feet ", text_obj.obj_id );
		xData->txPosHelper = VD_undefTxPosHelper ;

                // Need 3d location
                sts = om$send(msg = message GR3dtext.GRgenabsg(&msg,
                                           &text_obj.mod_env.md_env.matrix_type,
                                            text_obj.mod_env.md_env.matrix,
                                           (IGRchar**)&lbs),
                        senderid = NULL_OBJID,
                        targetid = text_obj.obj_id.objid,
                        targetos = text_obj.obj_id.osnum);
                if (lbs == NULL) {
                        printf("Problem getting label location\n");
                        goto wrapup;
                }

                sts = om$send(msg = message GRvg.GRgetrang(&msg,
                                            &text_obj.mod_env.md_env.matrix_type,
                                            text_obj.mod_env.md_env.matrix,
					    &world,
                                            pt     ),
                        senderid = NULL_OBJID,
                        targetid = text_obj.obj_id.objid,
                        targetos = text_obj.obj_id.osnum);
                if ( !(sts&msg&1) ) {
                        printf("Problem getting the range\n");
                        goto wrapup;
                }
		__DBGpr_vec("PT 1", &pt[0] );
		__DBGpr_vec("PT 2", &pt[3] );
		for( i=0; i<3; i++ ) tmp[i] = ( pt[i] + pt[i+3] ) / 2.0 ;

		__DBGpr_vec("MID PT", tmp );

		dist = ( BSdistptpt( &rc, &pt[0], &pt[3] ) ) / 2.0 ;
		__DBGpr_dbl("Distance ", dist );

		pt[0] = tmp[0] - dist*lbs->matrix[0] ;
		pt[1] = tmp[1] - dist*lbs->matrix[4] ;
		pt[2] = tmp[2] - dist*lbs->matrix[8] ;

		pt[3] = tmp[0] + dist*lbs->matrix[0] ;
		pt[4] = tmp[1] + dist*lbs->matrix[4] ;
		pt[5] = tmp[2] + dist*lbs->matrix[8] ;

                __DBGpr_vec("PT 1", &pt[0] );
                __DBGpr_vec("PT 2", &pt[3] );

                for( i=0; i<3; i++ ) tmp[i] = ( pt[i] + pt[i+3] ) / 2.0 ;

                BSmdistptsf( &rc, dev.surface, tmp, &param.u,
                             &param.v, tmp, &dist );
                if( rc != BSSUCC || param.u == 0.0 || param.u == 1.0 ||
                     		    param.v == 0.0 || param.v == 1.0 )
                {
                        msg = MSFAIL;
                        goto wrapup;
                }


		for( i=0; i<2; i++ )
		{
                    BSmdistptsf( &rc, dev.surface, &pt[3*i], &param.u,
                                 &param.v, tmp, &dist );

                    if( dev.tesselation_option == PARAMETRIC ||
                        dev.developpable > 0  )
                    {
                        BSsfeval( dev.devsrf, param.u, param.v, 
				  0, &pt[3*i], &rc );
                    }
                    else
                    {
                        BSsfevaln( dev.surface, param.u, param.v, 1,
                                   &jj,ptDr,vecDr,&rc);
                        FAevPtSfFaDr((IGRshort) 3,dev.P,dev.devsrf,dev.def,
                                 ptDr, vecDr, param.u, param.v, &pt[3*i], &rc);
                    }

                    if( rc != BSSUCC ) 
                    {
                        msg = MSFAIL;
                        goto wrapup;
                    }
		}

		Line.mod_env = inp_elm.mod_env;

		VLinitCnst( &cst );	
		sts = VLcreateLineSeg ( &pt[0], &pt[3], &inp_elm.mod_env, 
					&cst, &Line.obj_id, &msg);
		if( !(sts&msg&1) )  goto wrapup;
	
		xData->anchorCurve	= Line;
		xData->txPosHelper      = VD_useAnchorCurve;
		VD_drwAddGarbage( &msg, xData, &Line );
	      }
	      goto wrapup;
	   }
	}

skip_check:
        if(    !strcmp( type, "marking-line"  ) ) {
		sts = VLunwMarkProj( &msg, &dev, inp, xData, outpgr ) ;
        } else if( !strcmp( type, "roll-line" ) ) {
		sts = VLunwRollProj( &msg, &dev, inp, xData, outpgr ) ;
        } else if( (!strcmp( type, "butt-line" ))  ||
		   (!strcmp( type, "seam-line" ))  ||
                   (!strcmp( type, "water-line" )) ||
                   (!strcmp( type, "trace-line" )) ||
                   (!strcmp( type, "macro" )) 	   ||
                   (!strcmp( type, "control-line"))   )
	{
		sts = VLunwLineProj( &msg, &dev, inp, xData, arglist, argc, outpgr ) ;
        } else {
                WRONG_OUTPUT ;
        }

	xData->txPosHelper = VD_useFirstCurve ;

wrapup:
	_FREE( dev.P   );
	_FREE( dev.def );
	_FREE( dev.Param_u );
	_FREE( dev.Param_v );
	_FREE( lbs );
	_FREE( dev.surface );
	if( va_count && ext_surf._objid != NULL_OBJID )
	{
	   sts = _VD_SEND_OBJN( ext_surf.obj_id,
		GRgraphics.GRdelete( &msg, &md_env ));
	}
	if( hasFeet )
	{
 	   _FREE( dev.devsrf );
	}
	else
	{
	   _FREESF( &rc, dev.devsrf );
	}

	if( ( outpgr->count > 0 ) && ( outpgr->list ) )
	{
	   if( firstMap )  mappedObj[0] = outpgr->list[0];
	   else		   mappedObj[1] = outpgr->list[0];
	   firstMap = !(firstMap) ;
	}
quit:
	_FREE( list_obj );
        End ;
	return xfSUCCESS;
//      return sts & 1 & msg ? xfSUCCESS : xfFAILURE ;

} /* VDdrwOUTPUTmap */
/*----------------------------------------------------------------------------*/

/*----------------------------------------------------------------------------*/
#argsused
IMPLEMENT_OUTPUT( VD, mapsource ) {
	BSrc			rc;
        long            	sts, msg ;
	int			numObjects=0;
	IGRboolean              hasFeet;
	struct GRid		FeatObj, UnwObj;
	struct GRobj_env        inp_elm, *list_obj=NULL, tmp_obj, unw_srf;
	struct unw_obj_plat  	dev;
	VDpartAttr              attr ;
        struct GRvg_construct   cst;
        struct IGRdisplay       dspVis;
	struct IGRlbsys         *lbs = NULL;
        const char      	*type = xData->parsedElmDesc ;

	SetProc( VDdrwOUTPUTmapsource ); Begin

	/* Initialize the 'dev' structure */
	dev.devsrf  = NULL;
	dev.surface = NULL;
	dev.P       = NULL;
	dev.def     = NULL;
	dev.Param_u = NULL;
	dev.Param_v = NULL;

        outpgr->list  = NULL ;
        outpgr->count = 0 ;

	inp_elm.obj_id  = *(inp->elmId);
	inp_elm.mod_env = *(inp->elmEnv);

        dspVis = xData->overrides.elmDisplay ;

        /* Construct construction list */
        vs$fill_cnst_list( Msg          = &msg,
                           Env_info     = inp->drwInfo.drwEnv,
                           Level        = xData->overrides.elmLevel,
                           Display      = &dspVis,
                           Cnst_list    = cst ) ;

        __DBGpr_obj(" The input obj is ",inp_elm.obj_id);
        if(!strcmp( type, "control-line"))
        {
          vdchn$Get(il_objOE  = & (inp_elm) ,
                ic_IDX    = VDCHN_IDX_TO_OWNERS,
                ir_objIDX = 0,
                or_objID  = & (tmp_obj.obj_id));
           __DBGpr_obj("The tmp_obj   ",tmp_obj.obj_id);
 
         tmp_obj.mod_env =  *(inp->elmEnv);
         VLbrowseFctInTree( &tmp_obj, VL_Q_TOP_SOURCE, NULL,VL_Q_DOWN_DIRECT,
                           VLgetMacrosAtStep, &numObjects, &list_obj );
        }
        else {
        VLbrowseFctInTree( &inp_elm, VL_Q_TOP_SOURCE, NULL,VL_Q_DOWN_DIRECT,
                           VLgetMacrosAtStep, &numObjects, &list_obj );
         }
 
        __DBGpr_int(" The numObjects = ",numObjects);

        VLfilterDef(numObjects,list_obj,&numObjects,"VLunwFeat");
	if( !numObjects ) { 	sts = 0; 	goto quit; 	}

	/***  Modified for unwrap crash the latest objrct need not be last 
	in list , The VLunwFeat made available through parser. ***/
//	FeatObj = list_obj[numObjects-1].obj_id;
        FeatObj = *((struct GRid *)inp->appData);
        __DBGpr_obj (" The FeatObj  is ",FeatObj);

	sts = om$send( msg = message VLunwFeat.VLgetUnw_obj( &msg, &UnwObj ),
			targetid = FeatObj.objid,
			targetos = FeatObj.osnum,
			senderid = FeatObj.objid	);
	__CheckRC( sts, msg, "VLunwFeat.VLgetUnw_obj", wrapup );

        attr.Iwant = VL_I_devStruct ;
        attr.specific = (void *) &dev ;
        sts = _VD_SEND_OBJN( UnwObj, GRvg.GRgetattr( &msg, (char *)&attr ));
        __CheckRC( sts, msg, "GRvg.GRgettattr", wrapup );

        __DBGpr_obj( " Plate Surface Id ", dev.surf_id.obj_id );
        sts = VLgetGeometry( &dev.surf_id, TRUE, NULL_OBJID,
                                (IGRchar **)&dev.surface, &msg );
        __CheckRC( sts, msg, "VLgetGeometry", wrapup );

        sts = _VD_SEND_OBJN( UnwObj, NDmacro.ACreturn_foot(
                        &msg, UNFOLD_NAM_UNWSRF, &unw_srf.obj_id, NULL, NULL ));
        if( !(sts&msg&1) )
        {
           sts = _VD_SEND_OBJN( UnwObj, VLunwObj.VLgetInst_devSrf(
                                                        &dev.devsrf ) );
           __CheckRC( sts, 1, "VLunwObj.VLgetInst_devSrf", wrapup );
          hasFeet = FALSE;
        }
        else
        {
          __DBGpr_obj( " UnwrapSrf Feet ", unw_srf.obj_id );

          unw_srf.mod_env = list_obj[numObjects-1].mod_env;
          sts = VLgetGeometry( &unw_srf, TRUE, NULL_OBJID,
                                (IGRchar **)&dev.devsrf, &msg );
          __CheckRC( sts, msg, "VLgetGeometry", wrapup );
          hasFeet = TRUE;
        }

        __DBGpr_obj( " UVSrf Feet ", dev.uvSrfId );
        if( dev.tesselation_option == ARC_LENGTH  &&
            (om$is_objid_valid ( osnum = dev.uvSrfId.osnum ,
                                 objid = dev.uvSrfId.objid ) == OM_S_SUCCESS ))
        {
           struct GRobj_env      uvSrf_id;
           struct IGRbsp_surface *uvSurf=NULL;

           uvSrf_id.obj_id  = dev.uvSrfId;
           uvSrf_id.mod_env = list_obj[numObjects-1].mod_env;
           sts = VLgetGeometry( &uvSrf_id, FALSE, NULL_OBJID,
                                (IGRchar **)&uvSurf, &msg );
           if( sts&1&msg )
           {
              sts = VLunwFillDevStructureFromSrf( &msg, uvSurf, &dev );
           }
           _FREE(uvSurf);
        }

	if( argc == 1 )	
	{
	   IGRchar	feet_name[30];

	   VSdrwStrVal( &arglist->arg, feet_name );
	   sts = VLprocessFieldCut( &msg, &dev, inp, xData, feet_name,
				    &cst, outpgr ) ;
	   __CheckRC( sts, msg, "VLprocessFieldCut", wrapup );
        } else {
                WRONG_OUTPUT ;
        }


wrapup:
	_FREE( dev.P );
	_FREE( dev.def );
	_FREE( dev.Param_u );
	_FREE( dev.Param_v );
	_FREE( lbs );
	_FREE( dev.surface );
	if( hasFeet )		
	{
	    _FREE( dev.devsrf );
	}
	else
	{
	    _FREESF( &rc, dev.devsrf );	
	}

quit:
	_FREE( list_obj );
        End ;
	return xfSUCCESS;
//      return sts & 1 & msg ? xfSUCCESS : xfFAILURE ;

} /* VDdrwOUTPUTmapsource */
/*----------------------------------------------------------------------------*/

/*----------------------------------------------------------------------------*/
#argsused
IMPLEMENT_OUTPUT( VD, stocklines ) {
	int			ret_stat;
        long            	sts, msg ;
	struct unw_obj_plat	*dev ;
	short			trfMatType;
	IGRdouble		fromMat[16], toMat[16], trfMat[16];
	struct GRid		res_id, unwrap_id,*macroIds=NULL;
	struct GRobj_env	temp_obj;
	VDpartAttr              attr ;
        const char      	*type = xData->parsedElmDesc ;

	SetProc( VDdrwOUTPUTstocklines ); Begin

	sts = OM_S_SUCCESS;

	dev = ((struct unw_obj_plat *) (inp->appData));

        if(    !strcmp( type, "stock-line"  ) ) {
		sts = VLunwProcessStock( &msg, &dev, inp, xData, outpgr ) ;
		VD_drwCstSymbology( &msg, inp, xData, outpgr ) ;
		xData->txPosHelper = VD_useFirstCurve ;
        } else if(    !strcmp( type, "min-rec"  ) ) {
		outpgr->count = 1;
		if( !(outpgr->list = _MALLOC( 1, struct GRid )) ) 
		  vd_$mem_fail( msg = &msg );
		outpgr->list[0] = *(inp->elmId);
                VD_drwCstSymbology( &msg, inp, xData, outpgr ) ;
                xData->txPosHelper = VD_useFirstCurve ;
        } else {
                WRONG_OUTPUT ;
        }

	ret_stat = VLgetUnwIdFromSurf(&dev->surf_id,inp,&unwrap_id,NULL); 
        if(!(ret_stat & 1)) goto wrapup;

        attr.Iwant = VL_I_fromMat ;
        attr.specific = (void *) fromMat ;
        sts = _VD_SEND_OBJN( unwrap_id, GRvg.GRgetattr( &msg, (char *)&attr ));
        __CheckRC( sts, msg, "GRvg.GRgettattr", wrapup );

        attr.Iwant = VL_I_toMat ;
        attr.specific = (void *) toMat ;
        sts = _VD_SEND_OBJN( unwrap_id, GRvg.GRgetattr( &msg, (char *)&attr ));
        __CheckRC( sts, msg, "GRvg.GRgettattr", wrapup );

        sts = _VD_SEND_OBJN( outpgr->list[0], 
				GRgraphics.GRcopy( &msg, 
						   inp->drwInfo.drwEnv,
						   inp->drwInfo.drwEnv,
						   &temp_obj._objid ));

	temp_obj._osnum  = outpgr->list[0].osnum;
	temp_obj.mod_env = *(inp->drwInfo.drwEnv);

        sts = VLapplyTransf( &temp_obj.obj_id, 1, inp->drwInfo.drwEnv, 
				fromMat, toMat,
                            trfMat, &trfMatType, &msg );
        __CheckRC( sts, msg, "VLapplyTransf", wrapup );

	xData->txPosHelper = VD_useAnchorCurve ;
	xData->anchorCurve = temp_obj;

	VD_drwAddGarbage( &msg, xData, &temp_obj );

wrapup:
	_FREE( macroIds );

        End ;
        return sts & 1 & msg ? xfSUCCESS : xfFAILURE ;

} /* VDdrwOUTPUTstocklines */

/*----------------------------------------------------------------------------*/
#argsused
IMPLEMENT_FUNCTION( VD, is_ns_fs_mark ) {

IGRlong			sts, msg;
IGRint			is_ns_fs;
struct GRid		FeatObj, graphicID;
struct GRobj_env	unwrapOE;

   SetProc( is_ns_fs_mark ); Begin

   INT_RES( 0 );

   FeatObj = *((struct GRid *)inp->appData);

   sts = om$send( msg = message VLunwFeat.VLgetUnw_obj( 
					&msg, &unwrapOE.obj_id ),
                        targetid = FeatObj.objid,
                        targetos = FeatObj.osnum,
                        senderid = FeatObj.objid        );
    __CheckRC( sts, msg, "VLunwFeat.VLgetUnw_obj", wrapup );
    unwrapOE.mod_env = *(inp->elmEnv);

   if( !xData || !(xData->lastGraphic) ) goto wrapup;
   __DBGpr_int("Map output count ", xData->lastGraphic->count );
   if( xData->lastGraphic->count > 2 )
   {
      graphicID = xData->lastGraphic->list[2];
      __DBGpr_obj("Mapped Curve ", xData->lastGraphic->list[2]  );
      VLunwChkMarkOverlap( &msg, &unwrapOE, &FeatObj, &graphicID, &is_ns_fs );
   }
   else
   {
      __DBGpr_com("No Previous Graphics" );
      goto wrapup;
   }

   INT_RES( is_ns_fs );

   __DBGpr_int( "Is NS/FS?", is_ns_fs );

wrapup:
   End ;
   return xfSUCCESS ;
}

/*----------------------------------------------------------------------------*/
#argsused
IMPLEMENT_FUNCTION( VD, get_knuckle_angle ) {

IGRlong			sts;
IGRdouble		angle;
IGRchar			macName[40], down_scan[40], angle_str[40];
struct GRid		srf_tang, pretendID;

  SetProc( VDdrwFUNCTIONget_knuckle_angle ); Begin

  res->type  = VD_double ;
  res->_dval = 0.0 ;

  vdobj$Get( objID = inp->elmId, macName = macName );
  if( strcmp( macName, "PartMark" ) )  goto wrapup;

  vdobj$GetParent( objID = inp->elmId, idx = 1, parentID = &srf_tang );
  vdobj$Get( objID = &srf_tang, macName = macName );
  if( strcmp( macName, "srf_tangents" ) )  goto wrapup;

  vdchn$Get2( objID = inp->elmId, 
	      chnIDx= VDCHN_IDX_PARENT,
	      nth   = 1, 
	      outID = &pretendID );
  if( pretendID.objid == NULL_OBJID )  goto wrapup;

  down_scan[0] = '\0' ;
  sts = om$send( msg      = message ACpretend.ACgive_downscan( down_scan ),
		 senderid = NULL_OBJID,
                 targetid = pretendID.objid,
                 targetos = pretendID.osnum );
  __CheckRC( sts, 1, "ACpretend.ACgive_downscan", wrapup );  

  sprintf( angle_str, "angle%s", down_scan+7 );

  vdsa$GetStruct( objID = &srf_tang, name = angle_str, dbl = &angle );

  res->_dval = fabs( angle );
  if( res->_dval < 0.1 ) res->_dval = 0.0 ;

wrapup:
   End ;
   return xfSUCCESS ;
}

/*----------------------------------------------------------------------------*/
#argsused
IMPLEMENT_OUTPUT( VD, delete_cut ) {
IGRlong			sts, msg;
IGRint			i, objCnt=0;
IGRdouble		thickness=0.0;
struct GRid		FeatObj, plate;
struct GRobj_env 	UnwObj, curve_env, objOEs[50];
struct IGRbsp_curve     *feat_geom=NULL, *cutoutGeom=NULL;

   SetProc( VDdrwOUTPUTdelete_cut ); Begin

   FeatObj = *((struct GRid *)inp->appData);
   __DBGpr_obj (" The FeatObj  is ",FeatObj);

   sts = om$send( msg = message VLunwFeat.VLgetUnw_obj( 
					&msg, &UnwObj.obj_id ),
                        targetid = FeatObj.objid,
                        targetos = FeatObj.osnum,
                        senderid = FeatObj.objid        );
   __CheckRC( sts, msg, "VLunwFeat.VLgetUnw_obj", wrapup );
   __DBGpr_obj("Unwrap Object ", UnwObj.obj_id );
   UnwObj.mod_env = *(inp->drwInfo.drwEnv); 

   vdobj$GetParent(  objID      = &UnwObj.obj_id,
		     idx	= 1,
		     parentID	= &plate );
   __DBGpr_obj("Unwrap Parent Plate ", plate );

   vdsa$Get( objID = &plate, name = "plate_thk", dbl = &thickness);
   __DBGpr_dbl("Plate Thickness ", thickness );
   if( !xData || !(xData->lastGraphic) ) goto wrapup;
   __DBGpr_int("MapSource output count ", xData->lastGraphic->count );
   if( xData->lastGraphic->count ) 
   {
      __DBGpr_obj("Cut-Out Curve ", xData->lastGraphic->list[0]  );
      curve_env.obj_id  = xData->lastGraphic->list[0];
      curve_env.mod_env = *(inp->drwInfo.drwEnv);
      sts = VLgetGeometry( &curve_env, FALSE, NULL_OBJID,
                            (IGRchar **)&feat_geom, &msg );
      if( !(sts&1&msg) ) goto wrapup;
   }
   else
   {
      __DBGpr_com("No Previous Graphics" );
      goto wrapup;
   }

   objCnt = 0;
   VLunwGetComponents( &UnwObj, VLEXT_TYPE_CONTOUR, 50, &objCnt, objOEs );
   __DBGpr_int("Number of Holes on Unwrap ", objCnt );

  cutoutGeom = NULL;

  for( i=0; i<objCnt; ++i )
  {
     __DBGpr_obj("Cutout Object ", objOEs[i].obj_id );
     sts = VLgetGeometry( &objOEs[i], FALSE, NULL_OBJID,
			  (IGRchar **)&cutoutGeom, &msg );
     if( !(sts&1&msg) ) continue;
     if( VLcheck3DCrvThk( feat_geom, cutoutGeom, thickness ) == TRUE )
     {
	VD_bulkDeleteByGRids( inp->drwInfo.drwEnv, 1, &objOEs[i].obj_id );
        break;
     }
     _FREE( cutoutGeom );
  }

wrapup:
   _FREE( feat_geom );
   _FREE( cutoutGeom );
   End ;
   return xfSUCCESS ;
}

/*----------------------------------------------------------------------------*/
#argsused
IMPLEMENT_OUTPUT( VD, extend_contour ) {

IGRlong                 sts, msg;
struct GRid             featID;
struct GRobj_env        unwrapOE, contourOE;

   SetProc( VDdrwOUTPUTextend_contour ); Begin

   featID = *((struct GRid *)inp->appData);
   __DBGpr_obj("Unwrap Feature", featID );

   sts = om$send( msg = message VLunwFeat.VLgetUnw_obj(
                                        &msg, &unwrapOE.obj_id ),
                        targetid = featID.objid,
                        targetos = featID.osnum,
                        senderid = featID.objid        );
   __CheckRC( sts, msg, "VLunwFeat.VLgetUnw_obj", wrapup );
   __DBGpr_obj( "Unwrap Object ", unwrapOE.obj_id );
   unwrapOE.mod_env = *(inp->drwInfo.drwEnv);

   VLunwGetExternalContour( &unwrapOE, &contourOE );
   __DBGpr_obj( "Contour Object ", contourOE.obj_id );
   if( contourOE._objid == NULL_OBJID ) goto wrapup;

   __DBGpr_obj( "First Curve", mappedObj[0] );
   __DBGpr_obj( "Second Curve", mappedObj[1] );

   VLunwExtendUnwrapContour( contourOE, mappedObj );

wrapup:
   End ;
   return xfSUCCESS ;
}

/*----------------------------------------------------------------------------*/
#argsused
IMPLEMENT_OUTPUT( VD, dimension_lines ) {

IGRlong                 sts, msg;
IGRint			i, outside;
IGRdouble		offset;
struct GRid             featID;
struct GRobj_env        unwrapOE, contourOE;
struct GRsymbology	elmSymb;

   SetProc( VDdrwOUTPUTdimension_lines ); Begin

   CHECK_ARGCOUNT( 2 )

   if( !xData || !(xData->lastGraphic) || !(xData->lastGraphic->count) ) 
	goto wrapup;

   outside = VD_drwIntVal( &arglist->arg );
   if( outside )   outside = 1;
   else		   outside = 0;

   offset = VD_drwDblVal( &arglist->next->arg );

   __DBGpr_int( "Outside?", outside );
   __DBGpr_dbl( "Offset", offset );

   __DBGpr_int("Map output count ", xData->lastGraphic->count );
   __DBGpr_obj( "Mapped Bevel Curve", xData->lastGraphic->list[0] );

   featID = *((struct GRid *)inp->appData);
   __DBGpr_obj("Unwrap Feature", featID );

   sts = om$send( msg = message VLunwFeat.VLgetUnw_obj(
                                        &msg, &unwrapOE.obj_id ),
                        targetid = featID.objid,
                        targetos = featID.osnum,
                        senderid = featID.objid        );
   __CheckRC( sts, msg, "VLunwFeat.VLgetUnw_obj", wrapup );
   __DBGpr_obj( "Unwrap Object ", unwrapOE.obj_id );
   unwrapOE.mod_env = *(inp->drwInfo.drwEnv);

   VLunwGetExternalContour( &unwrapOE, &contourOE );
   __DBGpr_obj( "Contour Object ", contourOE.obj_id );
   if( contourOE._objid == NULL_OBJID ) goto wrapup;

   outpgr->count = 3;
   if( !(outpgr->list = _MALLOC( 3, struct GRid )) ) 
      vd_$mem_fail( msg = &msg );

   VLunwDimensionCurve( &contourOE, xData->lastGraphic->list, outside,
			offset, outpgr->list );

   elmSymb.level               = xData->overrides.elmLevel ;
   elmSymb.display_attr.color  = xData->overrides.elmDisplay.color ;
   elmSymb.display_attr.weight = xData->overrides.elmDisplay.weight ;
   elmSymb.display_attr.style  = xData->overrides.elmDisplay.style ;

   for( i=0; i<3; ++i )
   {
      sts = _VD_SEND_OBJN( outpgr->list[i], GRvg.GRputsymb( &msg, &elmSymb ));
      __CheckRC( sts, msg, "GRvg.GRputsymb", wrapup );
   }

   xData->txPosHelper = VD_useFirstCurve ;

wrapup:
   End ;
   return xfSUCCESS ;
}

/*----------------------------------------------------------------------------*/
#argsused
IMPLEMENT_FUNCTION( VD, get_curve_length ) {

IGRlong			sts, msg;
IGRdouble		crvLength=0.0;

   SetProc( VDdrwOUTPUTget_curve_length ); Begin

   if( !xData || !(xData->lastGraphic) || !(xData->lastGraphic->count) ) 
	goto wrapup;

   res->type   = VD_string ;
   *res->_sval = '\0';

   sts = _VD_SEND_OBJN( xData->lastGraphic->list[0], GRcurve.GRtotlength( &msg,
            	&inp->drwInfo.drwEnv->md_env.matrix_type, 
		inp->drwInfo.drwEnv->md_env.matrix, &crvLength ));
   __CheckRC( sts, msg, "GRcurve.GRtotlength", wrapup );
   __DBGpr_dbl( "Curve Length", crvLength );

   sprintf( res->_sval, "%g", crvLength );

wrapup:
   End ;
   return xfSUCCESS ;
}

/*----------------------------------------------------------------------------*/
#argsused
IMPLEMENT_FUNCTION( VD, is_partial_bevel ) {

BSrc			rc;
IGRlong                 sts, msg;
IGRint			i, k, crvCount=0, numDistCvs1=0, numDistCvs2=0, numOvCvs=0,
			ovLapCode;
OM_S_OBJECT_LINKAGE     crvList[100];
struct GRid		featID;
struct GRobj_env	unwrapOE, contourOE, crvOE;
struct IGRbsp_curve	*bvlGeom=NULL, *crvGeom=NULL, **DCvs1=NULL,
                        **DCvs2=NULL, **OCvs=NULL;

   SetProc( VDdrwOUTPUTis_partial_bevel ); Begin

   CHECK_ARGCOUNT( 0 )

   if( !xData || !(xData->lastGraphic) || !(xData->lastGraphic->count) ) 
	goto wrapup;

   res->type  = VD_int ;
   res->_ival = 0 ;

   __DBGpr_int("Map output count ", xData->lastGraphic->count );
   __DBGpr_obj( "Mapped Bevel Curve", xData->lastGraphic->list[0] );

   crvOE.obj_id  = xData->lastGraphic->list[0];
   crvOE.mod_env = *(inp->drwInfo.drwEnv);
   sts = VLgetGeometry( &crvOE, FALSE, NULL_OBJID, (IGRchar **)&bvlGeom, &msg );
   __CheckRC( sts, msg, "VLgetGeometry: Bevel Curve", wrapup );

   featID = *((struct GRid *)inp->appData);
   __DBGpr_obj("Unwrap Feature", featID );

   sts = om$send( msg = message VLunwFeat.VLgetUnw_obj(
                                        &msg, &unwrapOE.obj_id ),
                        targetid = featID.objid,
                        targetos = featID.osnum,
                        senderid = featID.objid        );
   __CheckRC( sts, msg, "VLunwFeat.VLgetUnw_obj", wrapup );
   __DBGpr_obj( "Unwrap Object ", unwrapOE.obj_id );
   unwrapOE.mod_env = *(inp->drwInfo.drwEnv);

   VLunwGetExternalContour( &unwrapOE, &contourOE );
   __DBGpr_obj( "Contour Object ", contourOE.obj_id );
   if( contourOE._objid == NULL_OBJID ) goto wrapup;

   om$get_channel_objects( objid = contourOE._objid,
                           osnum = contourOE._osnum,
                           p_chanselect = &AS_to_comp,
                           list  = crvList,
                           size  = 100,
                           count = (OMuint *) &crvCount );
   __DBGpr_int( "Composite Curve Count", crvCount );

   crvOE.mod_env = *(inp->drwInfo.drwEnv);
   for( i=0; i<crvCount; ++i )
   {
       _FREE( crvGeom );
       crvOE._objid  = crvList[i].S_objid;
       crvOE._osnum  = crvList[i].osnum;
       sts = VLgetGeometry( &crvOE, FALSE, NULL_OBJID, (IGRchar **)&crvGeom, &msg );
       __CheckRC( sts, msg, "VLgetGeometry: Contour Curve", wrapup );

       if( numDistCvs1 )
       {
          for( k=0; k<numDistCvs1; ++k )      BSfreecv( &rc, DCvs1[k] );
          _FREE( DCvs1 );
          numDistCvs1 = 0;
       }
       if( numDistCvs2 )
       {
          for( k=0; k<numDistCvs2; ++k )      BSfreecv( &rc, DCvs2[k] );
          _FREE( DCvs2 );
          numDistCvs2 = 0;
       }
       if( numOvCvs )
       {
          for( k=0; k<numOvCvs; ++k )      BSfreecv( &rc, OCvs[k] );
          _FREE( OCvs );
          numOvCvs = 0;
       }

       BSchk2cvsov( crvGeom, bvlGeom, 1.0, 1, &ovLapCode,
                    &numDistCvs1, &DCvs1, &numDistCvs2, &DCvs2,
                    &numOvCvs, &OCvs, &rc );
       if( rc != BSSUCC ) continue;
       if( ovLapCode == 3 || ovLapCode == 4 )
       {
          res->_ival = 1 ;
	  break;
       }
   }
   __DBGpr_int( "Is Partial Bevel?", res->_ival );

wrapup:
   if( numDistCvs1 )
   {
       for( k=0; k<numDistCvs1; ++k )      BSfreecv( &rc, DCvs1[k] );
       _FREE( DCvs1 );
       numDistCvs1 = 0;
   }
   if( numDistCvs2 )
   {
       for( k=0; k<numDistCvs2; ++k )      BSfreecv( &rc, DCvs2[k] );
       _FREE( DCvs2 );
       numDistCvs2 = 0;
   }
   if( numOvCvs )
   {
       for( k=0; k<numOvCvs; ++k )      BSfreecv( &rc, OCvs[k] );
       _FREE( OCvs );
       numOvCvs = 0;
   }

   _FREE( bvlGeom );
   _FREE( crvGeom );
   End ;
   return xfSUCCESS ;
}

/*----------------------------------------------------------------------------*/
IGRint VLgetUnwIdFromSurf(  struct GRobj_env 	*surfID,
			    VD_drwInputData 	*inp ,
			    struct GRid 	*UnwId,
			    struct GRobj_env 	*consPlate)
{

	IGRint retFlag = FALSE;
        int 		 numMac;
	struct GRobj_env consumedPlate, consumingChild, par_surface;
        long          	 sts, msg;
	unsigned long    type;
	VSopHistory      *history, *h ;
	struct GRid	 solid_id, res_id, *macroIds=NULL,unwrap_id;

	history         = NULL ;

     	as$make_source(go_grid = surfID->obj_id,
                       mod_env = &surfID->mod_env,
                       as_os   = inp->drwInfo.drwEnv->md_id.osnum,
                       as_grid = &par_surface.obj_id);

	par_surface.mod_env = *(inp->drwInfo.drwEnv);

        sts = VLgetChildrenMacro( par_surface, "VLunwObj",
                                    &numMac, &macroIds, &res_id );
	__DBGpr_int("Number of macros ", numMac );
 	if( numMac < 1 )
	{
	  __DBGpr_com( "Number macros is 0");
	  // try to get the VLunwObj macro on the consuming child
	  sts = om$get_objid_at_index( 	osnum        = surfID->_osnum,
					objid        = surfID->_objid,
					p_chanselect = &AS_to_owner,
					index        = 0,
					objidaddr    = &consumedPlate._objid,
					osnumaddr    = &consumedPlate._osnum);
	  if( !(sts&1) ) VDGetParserModelOE( &consumedPlate );
	  __DBGpr_obj("Surface Parent ", consumedPlate.obj_id);

	  if( vs$is_ancestry_valid( object  = &consumedPlate.obj_id,
				    classid = OPP_nci_macro_class_id ) )
	  {
	      struct GRid	rogue_parent;
	      vdobj$GetParent( 	objOE    = &consumedPlate,
				idx      = 0,
				parentID = &rogue_parent );
	      consumedPlate.obj_id = rogue_parent;
	  }
          consumingChild.mod_env = surfID->mod_env;
          consumingChild._md_os = consumingChild._osnum;
          ex$get_modid(   mod_osnum = consumingChild._md_os,
                          mod_id    = &consumingChild._md_id );
          __DBGpr_obj("Consumed Plate", consumedPlate.obj_id);
	  if(consPlate) *consPlate = consumedPlate;

	  VDatGetConsumingChild( &consumedPlate, &consumingChild);
	  if(consumingChild.obj_id.objid == NULL_OBJID) 
	  {
	      sts = MSFAIL;
	      goto wrapup;
	  }
	  __DBGpr_obj("Plate in the model ", consumingChild.obj_id);

	  sts = VSfindChildByType( &consumingChild.obj_id, 
				   OPP_VLunwObj_class_id, &unwrap_id );
	  __CheckRC( sts, 1, "VSfindChildByType", wrapup ) ;
	  __DBGpr_obj("Unwrap Object ", unwrap_id );
	}
	else
	{
	  if(consPlate)
	  {
             sts = om$get_objid_at_index(osnum        = surfID->_osnum,
                                         objid        = surfID->_objid,
                                         p_chanselect = &AS_to_owner,
                                         index        = 0,
                                         objidaddr    = &solid_id.objid,
                                         osnumaddr    = &solid_id.osnum);
             __CheckRC( sts, 1, "om$get_objid_at_index", wrapup ) ;
	     __DBGpr_obj("EMS Solid ID ", solid_id );

             sts = om$get_objid_at_index(osnum        = solid_id.osnum,
                                         objid        = solid_id.objid,
                                         p_chanselect = &AS_to_owner,
                                         index        = 0,
                                         objidaddr    = &consumingChild._objid,
                                         osnumaddr    = &consumingChild._osnum);
             __CheckRC( sts, 1, "om$get_objid_at_index", wrapup ) ;
	     __DBGpr_obj("Plate in the model ", consumingChild.obj_id );

	     consumingChild.mod_env = surfID->mod_env;
	     consumingChild._md_os = consumingChild._osnum;
	     ex$get_modid(   mod_osnum = consumingChild._md_os,
			     mod_id    = &consumingChild._md_id );

	     if( !vd_$is_ancestry_valid(object  = &consumingChild.obj_id,
					classid = OPP_VSsubPlate_class_id ) )
	     {
		sts = _VD_SEND_OBJN( consumingChild.obj_id, 
				VSfeature.VSgetResultType(&msg, &type ) );
     		__CheckRC( sts, msg, "Getting plate type", wrapup ) ;
    
     		if( ( type & VS_m_BOO_PLATE ) || ( type & VS_m_IMB_PLATE ) )
     		{
       		    sts = _VD_SEND_OBJN( consumingChild.obj_id, 
			  VSfeature.VSgetOperationHistory( &msg, 
					&consumingChild.mod_env, &history ) );
       		    __CheckRC( sts, msg, "Getting Operation History", wrapup ) ;

       		    for( h = history ; h ; h = h->next ) {
         		res_id.objid = h->resultId;
         		res_id.osnum = h->resultOs;
         		if( vd_$is_ancestry_valid( object  = &res_id,
                                        classid  = OPP_VSbooPlate_class_id ) ||
             		    vd_$is_ancestry_valid( object  = &res_id,
                                        classid  = OPP_VSimbPlate_class_id ) ||
             		    vd_$is_ancestry_valid( object  = &res_id,
					classid  = OPP_VSholPlate_class_id ) )
			continue;
			
			consPlate->_objid  = h->resultId;
			consPlate->_osnum  = h->resultOs;
			consPlate->mod_env = h->resultEnv;	
		    }
		}
		else *consPlate = consumingChild;
	     }  else *consPlate = consumingChild;
	     __DBGpr_obj("Consuming Plate ", consumingChild.obj_id);
	  }
	  unwrap_id = macroIds[0] ;
	}

	if(UnwId) *UnwId = unwrap_id;
	retFlag = TRUE;
wrapup:
	if( history ) VSfreeOpHistory( history ) ;
	_FREE( macroIds );
	return retFlag;
}
end implementation VDSroot;
