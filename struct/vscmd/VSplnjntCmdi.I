/* $Id: VSplnjntCmdi.I,v 1.1.1.1 2001/01/04 21:10:26 cvs Exp $  */
/***************************************************************************
 * I/STRUCT
 *
 * File:        struct/vscmd/VSplnjntCmdi.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VSplnjntCmdi.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:10:26  cvs
 *      Initial import to CVS
 *
# Revision 1.9  2000/02/28  20:47:22  pinnacle
# by pnoel for struct.
#
# Revision 1.7  1999/07/22  18:09:54  pinnacle
# tr179900566
#
# Revision 1.6  1998/11/12  20:45:12  pinnacle
# tr179802320
#
# Revision 1.4  1998/11/08  12:33:06  pinnacle
# Replaced: vscmd/VSplnjntCmdi.I for:  by manoj for struct
#
# Revision 1.9  1998/03/13  23:20:50  pinnacle
# New Joints
#
# Revision 1.8  1998/01/22  19:17:28  pinnacle
# Replaced: vscmd/VSplnjntCmdi.I for:  by impd for struct
#
# Revision 1.7  1998/01/06  09:16:42  pinnacle
# Replaced: vscmd/VSplnjntCmdi.I for:  by svkadamb for struct
#
# Revision 1.3  1997/11/20  11:19:40  pinnacle
# Replaced: vscmd/VSplnjntCmdi.I for:  by svkadamb for struct
#
# Revision 1.2  1997/11/19  08:20:32  pinnacle
# Replaced: vscmd/VSplnjntCmdi.I for:  by svkadamb for struct
#
# Revision 1.1  1997/11/14  12:19:36  pinnacle
# Created: vscmd/VSplnjntCmdi.I by svkadamb for struct
#
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 *           suresh  modification
 * 03/13/98  ah      TR179800680 Modify New Joint 
 * 06/24/98  Manoj   TR179801077  prevent joining plates that are already joined. 
 * 11/26/98  Manoj   TR179800867  prevent joining plates that are diagonally opposite. 
 *	                	  Three functions introduced:
 *			           1.VSisDiagonallyOpp()  
 *				   2.VSisPointContact()
 *				   3.VSgetPlatePlateRelation() 
 * 11/12/98  Manoj   TR179802320  enable joint between plate and beams. 
 * 11/12/98  ah                   Additional fixes for childId and sts in construct_joint
 * 07/14/99  Jay/Vin TR179900566  Improper array index corrected
 * 02/28/00  pn      TR179901012  failure after about 100 executions of place joint command
 *                                deleted form if exists before creation noted at site
 *                                
 * 			 
 ***************************************************************************/
/*
	I/STRUCT
*/
class implementation VSplnjntCmd ;

#include <stdio.h>
#include <string.h>
#include "math.h" 
#include "bserr.h"
#include	"bsmdistcvcv.h" // tr17980867
#include	"bsmdistptcv.h" // tr17980867
#include	"bsrgbxint.h"  // tr17980867
#include 	"bscveval.h" // tr17980867
#include	"bssfsfbndck.h" // tr17980867
#include "OMmacros.h"
#include "FI.h"
#include "EMSmsgdef.h"
#include "ACdb_info.h"
#include "ACcheckin.h"
#include "VDScheckdef.h"
#include "igr.h" //To include IGRbsp_curve
#include	"grdpbmacros.h" // tr17980867
#include "vsuattdef.h"
#include "vsoptdef.h"
#include "vsuattmacros.h"
#include "vsdpb.h"
#include "vsdpbdef.h"
#include "vsdpbmacros.h"
#include "vdsmacros.h"
#include "vsjntmacros.h"
#include "vsnamemacros.h"
#include "vsmiscmacros.h"
#include "vsdatamacros.h"
#include "vsglobalmsg.h"
#include "vscmddef.h"
#include "vscmdmacros.h"
#include "vswelddef.h"
#include "vsjnformdef.h"
#include "vsweld.h"
#include "vsjoint.h"
#include "nddef.h"
#include "msmacros.h"// ex$message is defined 
#include "vsplatedef.h"// VS_K_plBotSfPath defined 
#include	"vsgeommacros.h" // tr17980867
#include	"vsedgedef.h" // tr17980867
#include	"vsedgemacros.h" // tr17980867
#include	"v_geommacros.h" // tr17980867
#include "vsformproto.h"
#include "bsrgbxint.h"
#include "vdAPImacros.h"
#include "VDweldsym.h"
/*
#define   vsDEBUG
*/
#include "vsdbgmacros.h"

#define TOL 0.001
#define TOL_par 0.1

void VSisPointContact(  struct GRobj_env *eds1,struct GRobj_env *eds2,
			int count1,int count2, IGRboolean *result);
/*
 * Include of prototypes
 */
extern int COB_FI_form_notification() ;
extern int VS_ActJnAttr_UA_form_notification() ;
extern int VSgetSelectedRow();
extern long VSgetActNewJnAttr() ;

extern void UI_status(); // TR179801077
extern	VScvcvint();  // TR179800867
extern	VSarclen();  // TR179800867


from	VSfeature	import	VSputJoint ;
from	GRvg		import	GRgetname ;
from 	ACdb_info  	import  ACset_db_info ; 
from 	GRgraphics  	import  GRgetrang ; 
from 	GRgraphics  	import  GRdelete ; 

from    VSjoint         import  VSgetJoinedFeatures; // TR 179801077
from NDnode import NDget_objects; // TR 179801077 
extern OMuword OPP_VSjoint_class_id; // TR 179801077
extern OMuword OPP_VSplate_class_id; // TR 179801077

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/
/*      ********************	GLOBAL VARIABLES  *****************************	*/
/* 	Defined in   :								*/
/*		vdweld/imp/weldtxt.I						*/
/* 	Used also in :								*/
/*		vdweld/cmd/VDweldcmd.I & vdweld/cmd/weldform.I			*/
/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/
extern struct VDweld_gadget_sym	sym_char[];

extern int	VDread_weld_sym_char();

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

/*----------------------------------------------------------------------------*/
#define CODE_BUTTON	36
#define PROC_BUTTON	36
#define SIZE_BUTTON	36


#define CODE_COL	2
#define PROC_COL	3
#define SIZE_COL	4

#define PART_MCF	18

#define JNT_ATTR	15

#define CODE_ALL	27
#define CODE_CLEAR	28

#define PROC_ALL	31
#define PROC_CLEAR	30

#define SIZE_ALL	29
#define SIZE_CLEAR	14
/*----------------------------------------------------------------------------*/

#define FI_ACCEPT	1
#define FI_EXECUTE	2
#define FI_CANCEL	4


#define VS_K_jn_PickGeom	42
#define ATTRIBUTE	23

#ifndef MAX_NO
#define MAX_NO	1000
#endif
/*----------------------------------------------------------------------------*/
/*---------------------------------------------------------------------------*/
/*
 * Assumption: plates have a common base surface
 */ 
void VSgetPlatePlateRelation(struct GRid *obj1,// I:
			struct GRid *obj2,// I:
			struct GRobj_env *env1,// I:
			struct GRobj_env *env2, // I:
			int *num1,   //O :
			int *num2,    //O :
			IGRboolean *result){

	long 			msg,sts;
	struct GRid foot_obj1; // base surface of plate 1
	struct GRid foot_obj2; // base surface of plate 2

	struct GRmd_env foot_env1;
	struct GRmd_env foot_env2;

	struct GRobj_env        SurfObj1;
	struct GRobj_env        SurfObj2; 
	struct IGRbsp_surface   *geometry[2]={NULL,NULL}; 


	SetProc(VSgetPlatePlateRelation); Begin 
	geometry[0]=NULL; 
	geometry[1]=NULL; 

	sts = vd_$return_foot( msg    = &msg,
                              name    = VS_K_plBotSfPath,
                              objId   = obj1,
                              objEnv  = &env1->mod_env,
                              footId  = &foot_obj1,
                              footEnv = &foot_env1 );
        __CheckRC (sts, msg, "vd_return_foot", wrapup );

	SurfObj1.obj_id  = foot_obj1; 
	SurfObj1.mod_env = foot_env1; 
	//SurfObj1._md_os = env1->_md_os; 
	sts = ex$get_modid( mod_osnum = SurfObj1._md_os,
                             mod_id   = &SurfObj1._md_id );

	sts = vd_$return_foot( msg    = &msg,
                              name    = VS_K_plBotSfPath,
                              objId   = obj2,
                              objEnv  = &env2->mod_env,
                              footId  = &foot_obj2,
                              footEnv = &foot_env2 );

	SurfObj2.obj_id = foot_obj2; 
	SurfObj2.mod_env= foot_env2; 
	//SurfObj2._md_os = env2->_md_os; 
	sts = ex$get_modid( mod_osnum = SurfObj2._md_os,
                             mod_id   = &SurfObj2._md_id );

	sts = vs$get_geometry(msg = &msg,
			grobjId=&foot_obj1,
			grobjEnv=&foot_env1,
			geometry=&geometry[0]
			);
        __CheckRC ( sts, msg, "get_geometry", wrapup );

	sts = vs$get_geometry(msg = &msg,
			grobjId=&foot_obj2,
			grobjEnv=&foot_env2,
			geometry=&geometry[1]
			);
        __CheckRC ( sts, msg, "get_geometry", wrapup );
 {

    BSrc                  rc;
    int i ; 
    int k ; 
    int count1=0, count2=0 ;
    struct GRobj_env *eds1 = NULL;
    struct GRobj_env *eds2 = NULL; 
    struct GRmd_env locEnv  ;
    IGRlong NumberOfBytes = sizeof(locEnv);
    IGRlong BytesReceived=0;
    struct GRid *listID1=NULL,*listID2=NULL;
	gr$get_module_env(msg    = &msg,
                	  sizbuf = &NumberOfBytes,
			  buffer = &locEnv,
                	  nret   = &BytesReceived);
	__DBGpr_int(" Bytes received ", BytesReceived);
	__DBGpr_obj(" md object ", locEnv.md_id);


	sts = ex$get_modid( mod_osnum = SurfObj1._md_os,
                             mod_id   = &SurfObj1._md_id );
	sts = ex$get_modid( mod_osnum = SurfObj2._md_os,
                             mod_id   = &SurfObj2._md_id );

	vs$make_natural_boundary( msg        = &msg,
                                  surfaceEnv = &SurfObj1.mod_env,
                                  surfaceId  = &SurfObj1.obj_id);
	vs$make_natural_boundary( msg        = &msg,
                                  surfaceEnv = &SurfObj2.mod_env,
                                  surfaceId  = &SurfObj2.obj_id);

           sts = vs$get_surface_edges ( msg      = &msg,
                                             sfId       = &SurfObj1.obj_id,
                                             sfEnv      = &SurfObj1.mod_env
,
                                             edgeType   = VS_K_CONTOUR_EDGES,
                                             edCount    = &count1,
                                             edList     = &listID1 );
                  //printf("\n Edge Count = %d", count1 );
                  if (!count1)   { __DBGpr_com("Error 0"); }

                  sts = vs$get_surface_edges ( msg      = &msg,
                                             sfId       = &SurfObj2.obj_id,
                                             sfEnv      = &SurfObj2.mod_env
,
                                             edgeType   = VS_K_CONTOUR_EDGES,
                                             edCount    = &count2,
                                             edList     = &listID2 );
                  //printf("\n Edge Count = %d", count2);
    		eds1 = _MALLOC(count1, struct GRobj_env);
    		eds2 = _MALLOC(count2, struct GRobj_env);

                  if (!count2)   { __DBGpr_com("Error 0"); }


		  for ( k = 0 ; k < count1 ; k++ ){
	 	      sts = vs$get_graphic_edge (msg     = &msg,
                                                 edId    = &listID1[k],
                                                 edEnv   = &SurfObj1.mod_env,
                                                 copy    = TRUE,
                                                 copyEnv = &locEnv,
                                                 grEdge  = &eds1[k].obj_id );
			__DBGpr_obj(" md object ", locEnv.md_id);

                        eds1[k].mod_env      = locEnv;
			__DBGpr_obj(" object ", eds1[k].obj_id);
	          }

		  for ( k = 0 ; k < count2 ; k++ ){
	 	      sts = vs$get_graphic_edge (msg     = &msg,
                                                 edId    = &listID2[k],
                                                 edEnv   = &SurfObj2.mod_env,
                                                 copy    = TRUE,
                                                 copyEnv = &locEnv,
                                                 grEdge  = &eds2[k].obj_id );
			__DBGpr_obj(" md object ", locEnv.md_id);
                        eds2[k].mod_env      = locEnv;
	          }

		  VSisPointContact(eds1,eds2,count1,count2,result);

		  for ( k = 0 ; k < count2 ; k++ ){
			sts = om$send(  msg     = message GRgraphics.GRdelete(&msg, &locEnv ),
                                        senderid = NULL_OBJID,
                                        targetid= eds2[k].obj_id.objid,
                                        targetos= eds2[k].obj_id.osnum ) ;


		  }
		  for ( k = 0 ; k < count1 ; k++ ){
			sts = om$send(  msg     = message GRgraphics.GRdelete(&msg, &locEnv ),
                                        senderid = NULL_OBJID,
                                        targetid= eds1[k].obj_id.objid,
                                        targetos= eds1[k].obj_id.osnum ) ;
		  }
		  _FREE(eds1);
		  _FREE(eds2);
 } // forced scope


	wrapup:
		_FREE(geometry[0]);
		_FREE(geometry[1]);
	End
	
}/*VSgetPlatePlateRelation*/
/*--------------------------------------------------------------*/
void VSisPointContact(  struct GRobj_env *env1, 
		      struct GRobj_env *env2,
		      int num1,
		      int num2, 
		      IGRboolean *result ){

	BSrc               	    rc;
        int 			    i,j,i_db;
        IGRshort                    k1;
        IGRshort                    n;
        IGRdouble                   dist= NULL;
        IGRdouble                  *par1= NULL;
        IGRdouble                  *par2= NULL;
        IGRpoint                   *pt1;
        IGRpoint                   *pt2;
	IGRdouble 		*intpars= NULL;
	IGRlong			     msg,sts;
	struct IGRbsp_curve   **bspcv1 = _MALLOC(num1,struct IGRbsp_curve*);
	struct IGRbsp_curve   **bspcv2 = _MALLOC(num2,struct IGRbsp_curve*);
	int flag1=0; 
	int flag2=0;
	 /*
         * Get the geometry data for the curve
         */
	__DBGpr_obj(" object ", env1[0].obj_id);
	__DBGpr_obj(" object ", env1[1].obj_id);
	for(i=0; i  < num1; i++ ){  
            sts = vd_$get_geometry ( msg      = &msg,
                           	     grobjId  = &env1[i].obj_id,
                           	     grobjEnv = &env1[i].mod_env,
                           	     geometry = &bspcv1[i] );

            if ( ! ( sts & msg & 1 ) ) {
              printf("Problem with getting curve geometry\n");
              msg = MSFAIL ;
              //printf(" Going to wrapup %d \n", __LINE__); //debug
              goto wrapup;
            }
            __DBGpr_int("bspcv1[].order",bspcv1[i]->order);	
  
	}

	for(i=0; i  < num2; i++ ){  
            sts = vd_$get_geometry ( msg      = &msg,
                           	     grobjId  = &env2[i].obj_id,
                           	     grobjEnv = &env2[i].mod_env,
                           	     geometry = &bspcv2[i] );

            if ( ! ( sts & msg & 1 ) ) {
              printf("Problem with getting curve geometry\n");
              msg = MSFAIL ;
              //printf(" Going to wrapup %d \n", __LINE__); //debug
              goto wrapup;
            }
           __DBGpr_int("bspcv1[].order",bspcv1[i]->order);	
 	} 


	
	// Find the no of common (corner) points,
	// common points, curve incident on common points between 
	// the plates. 

	for ( i = 0 ; i < num1 ; i++ ){
	   for ( j = 0 ; j < num2 ; j++ ){
            IGRint                     num;
            IGRdouble                  dist;
	/*
	Description
    		This function finds the minimum distance, dist, 
	between the two curves,
	curve1 and curve2.  The num is the number of points at which the 
	minimum distance occurs, and the par1 and par2 are the parameter 
	values of the points, pt1 and pt2, at which the minimum distance 
	occurs on curve1 and curve2, respectively.
	*/
	       __DBGpr_int(" i ", i);
	       __DBGpr_int(" j ", j);

		BSmdistcvcv(bspcv1[i], 
			    bspcv2[j],
			    &num,
			    &par1, 
			    &par2, 
			    &pt1,
			    &pt2,
			    &dist,
			    &rc);
           if(rc != BSSUCC) {
	      __DBGpr_com("going to wrapup");
   	      goto wrapup;
	   }
	   for( i_db = 0 ; i_db < num ; i_db++){
		__DBGpr_dbl("parameter at cv1 of intersections ",par1[i_db]);
		__DBGpr_dbl("parameter at cv2 of intersections ",par2[i_db]);
	   }
	   if(num > 1 ) { 
		__DBGpr_com("The curve is intersection of the other curve");
		__DBGpr_int("No of intersections ",num);
		goto wrapup;
	   }

	   if(num == 1  && dist < TOL) { 
		float t = 0;
		struct IGRbsp_curve bsp;
		//The following two varibales store 
		//edge ids. Because two edges(at ehci minimum dist 
		// between curve occurs) must be
		// consecutive for a corner to be on plate.
		int plate1edge_id[2];
		int plate2edge_id[2];
		IGRpoint pt;
		IGRshort k;
		IGRshort n;
		IGRdouble *pars=NULL;
		IGRdouble dist1;

		if( par1[0] < TOL ){      
		  t =TOL_par ; //?? confirm with Avondole how much fraction 
			 // of the total length must stay in touch 
			 // to qualify for welding. 
			 // do the same for the remaining ifs.

		  bsp = *bspcv2[j]; //TR179900566

	          BScveval(&bsp,t,0,&pt,&rc);
		  //printf(" pt1 = %f %f %f \n", pt[0], pt[1],pt[2]); //debug
           	  if(rc != BSSUCC) {
	           __DBGpr_com("Going to wrapup");
   	           goto wrapup;
	          }

		  BSmdistptcv(  &bsp,pt,&k,
				&n,
				&pars,
				&dist1,
			        &intpars,&rc); 
           	  if(rc != BSSUCC) {
	           __DBGpr_com("Going to wrapup");
   	           goto wrapup;
	          }

		  if(dist1 < TOL ){
		      plate1edge_id[flag1] = i;
		      flag1++;
		  }

		}  else  if( par2[0] < TOL ){      

		  t =TOL_par ; //?? same as above 
		  bsp = *bspcv2[j];

	          BScveval(&bsp,t,0,&pt,&rc);
           	  if(rc != BSSUCC) {
	           __DBGpr_com("Going to wrapup");
   	           goto wrapup;
	          }

		  BSmdistptcv(&bsp,
			      pt,
			      &k,
			      &n,
			      &pars,
			      &dist1,
			      &intpars,&rc); 
           	  if(rc != BSSUCC) {
	           __DBGpr_com("Going to wrapup");
   	           goto wrapup;
	          }
		  if(dist1 < TOL ){
		      plate2edge_id[flag2] = j;
		      flag2++;
		  }
		} else if( par1[0] >  1 - TOL  ){      

		  t = 1 - TOL_par;  
		  bsp = *bspcv2[j]; //TR179900566

	          BScveval(&bsp,t,0,&pt,&rc);
           	  if(rc != BSSUCC) {
	           __DBGpr_com("Going to wrapup");
   	           goto wrapup;
	          }

		  BSmdistptcv(&bsp,pt,&k,&n,&pars,&dist1,&intpars,&rc); 
           	  if(rc != BSSUCC) {
	           __DBGpr_com("Going to wrapup");
   	           goto wrapup;
	          }

		  if(dist1 < TOL ){
		      plate1edge_id[flag1] = i;
		      flag1++;
	          }

		} else if( par2[0] >  1 - TOL  ){      
		  t = 1 - TOL_par; 
		  bsp = *bspcv2[j];

	          BScveval(&bsp,t,0,&pt,&rc);
           	  if(rc != BSSUCC) {
	           __DBGpr_com("Going to wrapup");
   	           goto wrapup;
	          }

		  BSmdistptcv(&bsp,pt,&k,&n,&pars,&dist1,&intpars,&rc); 
           	  if(rc != BSSUCC) {
	           __DBGpr_com("Going to wrapup");
   	           goto wrapup;
	          }

		  if(dist1 < TOL ){
		      plate2edge_id[flag2] = j;
		      flag2++;
	          }
		}


	   } // num ==1 and dist < TOL
	
	}  // for each edge of plate 2
            _FREE(par1);
            _FREE(par2);
            _FREE(pt1);
            _FREE(pt2);
	    _FREE(intpars);
	} // for each edge of plate 1
	__DBGpr_int(" flag1 \n",flag1);
	__DBGpr_int(" flag2 \n",flag2);

	//added for TR #179802320: starts
	if((flag1 + flag2)%2==0 && (flag1 || flag2)) {
		*result = TRUE;
		//printf(" result made true \n"); //debug
	}
	//added for TR #179802320: ends
wrapup:
	    _FREE(intpars);
            _FREE(par1);
            _FREE(par2);
            _FREE(pt1);
            _FREE(pt2);
	    if(bspcv1){
		for(i = 0; i < num1; i++ )
			_FREE(bspcv1[i]); 
	    	_FREE(bspcv1);
	    }
	    if(bspcv2){
		for(i = 0; i < num2; i++ )
			_FREE(bspcv2[i]); 
	    	_FREE(bspcv2);
	    }
}/*  VSisPointContact */
/*--------------------------------------------------------------*/
int VSisDiagonallyOpp(
	struct GRid *obj1,// I:
	struct GRid *obj2,// I:,
	struct GRobj_env *env1,// I:
	struct GRobj_env *env2, // I:
	double *wt)// I : the weld thickness
 {
	int num1,num2;
	struct IGRbsp_curve     **bspcv1= NULL; 
	struct IGRbsp_curve     **bspcv2= NULL;  
	IGRboolean result=FALSE;  
	struct GRobj_env      sfForEdges[2];

	SetProc(VSisDiagonallyOpp); Begin
	__DBGpr_com("Calling VSgetPlateBaseEdges");

	VSgetPlatePlateRelation(obj1,obj2,
			      env1,env2, 
			      &num1,&num2,
			      &result);

	__DBGpr_com("Calling anyCornerofP1onP2");
	
	//TR179802320 start:
	if(result) {
	   __DBGpr_com("Plates are diag opp");
	return 1;
	} else {
	   __DBGpr_com("Plates are not diag opp");
	   return 0;
	}
	//TR179802320 ends:

}/*VSisDiagonallyOpp */ 
/*----------------------------------------------------------------------*/
/*---------------------------------------------------------------------------*/
method wakeup( int pos ) {
  SetProc(wakeup ); Begin
		      __DBGpr_me();
        om$send( msg    = message VSlocateCmd.wakeup( pos ),
                 mode   = OM_e_wrt_message,
                 targetid= my_id ) ;

	if ( me->plcJnForm ) {
		int	disp_sts ;
		
		FIf_is_displayed( me->plcJnForm, &disp_sts ) ;
		if(!( disp_sts ) ) {
			FIf_display( me->plcJnForm );
		}
	}
	if ( me->attrForm ){
                int 	disp_sts ;		/* display status of form */
		char	*UAsubForm ;		/* User attr sub form	  */
 
                FIf_is_displayed( me->attrForm, &disp_sts ) ;
 
                if(!( disp_sts ) ) {
			if( me->attrFormErased )
			      FIf_display( me->attrForm );
		}
		/*
		 * get user attribute form point to attribute form 
		 */
		FIf_get_user_pointer( me->attrForm, &UAsubForm ) ;
		if( UAsubForm ) {
			FIf_is_displayed( UAsubForm, &disp_sts ) ;
                	if( !(disp_sts ) ) 
                        	if( me->UAFormErased ) FIf_display( UAsubForm );
		}
        }
	End
	return OM_S_SUCCESS ;

} /* method wakeup */
/*----------------------------------------------------------------------------*/
method init( int type ; char *string ) {
  SetProc( init ); Begin
		     __DBGpr_me();
	me->attrForm = NULL ;
	me->plcJnForm = NULL ;
	me->attrFormErased = FALSE ;
	me->UAFormErased = FALSE ;
 
        om$send( msg    = message VSlocateCmd.init( type, string ),
                 mode   = OM_e_wrt_message,
                 targetid= my_id ) ;
	End
	return OM_S_SUCCESS ;

} /* method init */
/*----------------------------------------------------------------------------*/
method sleep( int pos ){
   SetProc( sleep ); Begin
		     __DBGpr_me();
        if( me->attrForm ) {
                int 	disp_sts ;		/* display status of form */
		char	*UAsubForm ;		/* User attr sub form     */

		/*
		 * Check if the form is displayed,
		 * If displayed the erase the form and store the information
		 * that the form has been erased during sleep. Because wakeup
		 * will act accordingly.
		 */
 
                FIf_is_displayed( me->attrForm, &disp_sts ) ;
		if( disp_sts )	{
			FIf_erase ( me->attrForm );
			me->attrFormErased = TRUE ;
		} else {
			me->attrFormErased = FALSE ;
		}
		/*
		 * get user attribute form pointed to joint attribute form 
		 */
		FIf_get_user_pointer( me->attrForm, &UAsubForm ) ;
		if( UAsubForm ) {
			FIf_is_displayed( UAsubForm, &disp_sts ) ;
                	if( disp_sts )  {
                        	FIf_erase ( UAsubForm );
                        	me->UAFormErased = TRUE ;
                	} else {
                       		me->UAFormErased = FALSE ;
			}
		}
	}
        if( me->plcJnForm ) FIf_erase ( me->plcJnForm );
 
        om$send( msg    = message VSlocateCmd.sleep( pos ),
                 mode   = OM_e_wrt_message,
                 targetid= my_id ) ;
	End
        return OM_S_SUCCESS ;
 
}/* method sleep */
/*----------------------------------------------------------------------------*/
method delete( int f_defer_flag ){

	long 		msg ; 			/* OM return code	*/
  SetProc( init ); Begin
		     __DBGpr_me();
	if ( me->attrForm ) FIf_delete( me->attrForm ) ;
	if ( me->plcJnForm ) FIf_delete( me->plcJnForm ) ;
	
	om$send( msg	= message VSplnjntCmd.cleanUp( &msg ),
		 targetid= my_id );

        om$send( msg    = message VSlocateCmd.delete( f_defer_flag ),
                 mode   = OM_e_wrt_message,
                 targetid= my_id ) ;
	End
        return OM_S_SUCCESS ;
 
}/* method delete */
/*----------------------------------------------------------------------------*/
method cleanUp( long *sts ) {

        int             firstSetSize ,		/* part count in first set    */
			secondSetSize ;		/* part count in second set   */
	int 		from_index = 0;		/* index used to set vla size */
 
	SetProc( VSplnjntCmd_cleanUp ) ; Begin

        firstSetSize = om$dimension_of( varray = me->firstSet ) ;
        secondSetSize = om$dimension_of( varray = me->secondSet ) ;
 
        om$vla_set_dimension( varray = me->firstSet, size = from_index ) ;
        om$vla_set_dimension( varray = me->secondSet, size = from_index ) ;
        om$vla_set_dimension( varray = me->objList, size = from_index ) ;
 
	End
	return OM_S_SUCCESS ;

}/* method cleanUp */
/*----------------------------------------------------------------------------*/
method process_set( long *sts; int whichSet ) {

	int			nbParts ;
	struct GRobj_env	fence,
				*parts ;
				
	SetProc( VSplnjntCmd_process_set ) ; Begin

	fence._grid	= me->event1.located_object[0].located_obj ;
	fence.mod_env	= me->event1.located_object[0].module_info ;

	vs$process_fence(	msg		= &me->ret,
				fence		= &fence,
				classList	= me->locate_eligible,
				filter		= me->PFAH,
				args		= &me->PFAHarg,
				p_count		= &nbParts,
				p_content	= &parts,
				response	= me->response,
				response_data	= me->response_data ) ;
	if( *me->response != EX_DATA || !nbParts ) {
		me->ret = VS_K_NO_FENCE ; goto wrapup ;
	}
	if( me->ret & 1 ) {
		int h ;

		for( h = 0 ; h < nbParts && (me->ret & 1) ; h++ ) {

			me->ret = om$send(
				msg	= message VSplnjntCmd.addToSet(
							&parts[h]._grid,
							&parts[h].mod_env,
							whichSet ),
				targetid= my_id ) ;
		}
		_FREE( parts ) ;
	}

	me->ret = me->ret & 1 ? VS_K_ACT_SUCCESS : VS_K_RESTART_CMD ;

	wrapup :
		End 
		return OM_S_SUCCESS ;

} /* method process_set */
/*----------------------------------------------------------------------------*/
method store_first_feature( long  *msg ) {

	long			sts ;
	int                     firstSet = 1;
	struct GRlc_info	*toStore = me->event1.located_object ;

	SetProc( VSplnjntCmd_store_first_feature ) ; Begin

	sts = om$send ( msg	= message VSplnjntCmd.addToSet(
						&toStore->located_obj,
						&toStore->module_info,
						firstSet ),
			targetid=my_id );

	End 
	return OM_S_SUCCESS ;

}/* method store_first_feature */
/*----------------------------------------------------------------------------*/
method store_second_feature( long  *msg ) {
 
	long			sts ;
        struct  GRobj_env       part;
        int                     secondSet = 2;

	SetProc( VSplnjntCmd_store_second_feature ) ; Begin
 
        part._grid = me->event1.located_object[0].located_obj;
        part.mod_env = me->event1.located_object[0].module_info ;

        sts = om$send ( msg     = message VSplnjntCmd.addToSet(
                                                &part._grid,
                                                &part.mod_env,
                                                secondSet ),
			targetid=my_id );

	End 
        return OM_S_SUCCESS ;

} /* method store_second_feature */
/*----------------------------------------------------------------------------*/
method addToSet(	struct GRid     *objToAdd ;
                        struct GRmd_env *envToAdd ;
                        int             whichSet ) {
	int	i, size = 0;
	long	sts ;
	struct GRid *childId = NULL; // TR 179801077 : argument to NDget_objects()
	SetProc( VSplnjntCmd_addToSet ) ; Begin

	
	switch( whichSet ) {

		case 1 :
			size = om$dimension_of( varray = me->firstSet ) ;
			break ;
		case 2 :
		 //The following "for" loop added for TR #179801077 
                        size = om$dimension_of( varray = me->firstSet ) ;      
                        for( i = 0 ; i < size ; i++ ) {
                           int count=0,j;
                           //struct GRid *childId;
                           //get child of the second selected 
                           // object.
			   childId = NULL;
			   
			   /* Warning, don't free childID !!! */
                           sts = om$send( msg = message NDnode.NDget_objects( 
                                                ND_CHILDREN | ND_IN_BUF,
                                                NULL, 0,
                                                &childId,
                                                0, OM_K_MAXINT,
                                                &count),
                                   senderid = NULL_OBJID,
                                   targetid = me->firstSet[i]._grid.objid,
                                   targetos = me->firstSet[i]._grid.osnum);
                           //__CheckRC( sts,1, "NDnode.NDget_objects", wrapup);
                           //__DBGpr_int("No of children", count);

                           //check if any of the selected children is
                           // a joint. If so find the objects connected by the
                            // joint.

                           for( j=0 ; j < count ; j++ ) {
                              __DBGpr_obj(" child of 2nd selected objects",childId[j] );
                              if( vs$is_ancestry_valid(
                                                object  = &childId[j],
                                                classid = OPP_VSjoint_class_id))
 {
                                 struct GRobj_env       feature0,
                                                        feature1,
                                                        parentJoint  ;
                                 long msg;
			sts = om$send( msg = message VSjoint.VSgetJoinedFeatures(
                                                                &msg ,
                                                                &feature0,
                                                                &feature1,
                                                                &parentJoint ),
                                                senderid = NULL_OBJID,
                                                targetid = childId[j].objid,
                                                targetos = childId[j].osnum);
   			__CheckRC(sts,msg,"VSjoint.VSgetJoinedFeatures" ,wrapup);
                                 __DBGpr_obj(" feature 0", feature0._grid );
                                 __DBGpr_obj(" feature 1", feature1._grid );

                                 __DBGpr_obj(" Object to add", *objToAdd);

                                 if( IF_EQ_GRID( feature0._grid,*objToAdd)
                                  || IF_EQ_GRID( feature1._grid,*objToAdd) ){
                                        GRname name1,name2;
                                        om$send( msg = message GRgraphics.GRgetname(&msg,name1),
                                                senderid = NULL_OBJID,
                                                targetid = feature0._grid.objid,
                                                targetos = feature0._grid.osnum)
;
                                        om$send( msg = message GRgraphics.GRgetname(&msg,name2),
                                                senderid = NULL_OBJID,
                                                targetid = feature1._grid.objid,
                                                targetos = feature1._grid.osnum)
;
                                         printf("Could not place joint between %s and %s.\n",name1,name2);
                                       // the above message will appear also
                                       // when a joint with self is attempted.
                                        // modify wrror message ??
                                        UI_status(" Illegal pair selected to joi n");
                                        goto wrapup;
                                }

                        } // if it is a joint child
                        } // for each child of the 2nd object.
                        // added by Manoj : ends
                     } // for all 2nd selected objects
                        size = om$dimension_of( varray = me->secondSet ) ;
                        break ;
		default :
			/*
		 	 * shouldn't come here
			 */
			goto wrapup ;
	}
        /*
         * Is object already stored ?.
	 */
        for( i = 0 ; i < size ; i++ ) {
                if( IF_EQ_GRID( *objToAdd, 
				(whichSet == 1) ?
				me->firstSet[i]._grid : 
				me->secondSet[i]._grid ) ) {
 
                        sts = VS_K_OBJONCHEXIST ; goto wrapup ;
                }
        }

	switch( whichSet ) {

		case 1	:
			sts = om$vla_set_dimension(	varray  = me->firstSet,
							size    = size + 1 ) ;
			printf("");
        		__CheckRC( sts, 1, "om$vla_set_dimension", wrapup ) ;
        		me->firstSet[size]._grid 	= *objToAdd;
        		me->firstSet[size].mod_env 	= *envToAdd;

			break ;

		case 2	:
			sts = om$vla_set_dimension(	varray  = me->secondSet,
							size    = size + 1 ) ;
        		__CheckRC( sts, 1, "om$vla_set_dimension", wrapup ) ;
 
        		me->secondSet[size]._grid 	= *objToAdd;
        		me->secondSet[size].mod_env 	= *envToAdd;

			break ;
	}
wrapup :
  //_FREE(childId);
	End 
	return OM_S_SUCCESS ;

} /* method addToSet */
/*----------------------------------------------------------------------------*/
void VSupdNewWeldInfo( type, value, wa ) 
int type, value ; 
VSaddWldAttr *wa ; {

        switch( type ) {
 
                case VS_K_jn_FieldWeld  :
                        if( value ) {
                                wa->fieldweld =  value ;
                        } else {
                                wa->fieldweld = 0 ;
                        }
                        break ;
 
		case VS_K_jn_FloorPos 	:
			wa->position = VS_K_wldFloorPos ;	break ;

		case VS_K_jn_HorzPos 	:
			wa->position = VS_K_wdlHorzPos ;	break ;

		case VS_K_jn_CeilPos 	:
			wa->position = VS_K_wldCeilPos ;	break ;

		case VS_K_jn_VertPos 	:
			 wa->position = VS_K_wldVertPos ;	break ;
		default :
			break ;
        }
 
}/*  VSupdNewWeldInfo */
/*----------------------------------------------------------------------------*/
/*
void VSputNewWeldInfo( type, value ) int type, value ; {

        long 		sts, msg ;
        VSweldAttr	wa ;
 
        sts = vs$get_act_pm(	msg   = &msg,
                        	param = VS_e_dpb_J_weldAttr,
                        	p_arg = &wa ) ;
 
        VSupdNewWeldInfo( type, value, &wa ) ;

        sts = vs$put_act_pm(	msg   = &msg,
                        	param = VS_e_dpb_J_weldAttr,
                        	p_arg = &wa ) ;
 
}*/ /* void VSputNewWeldInfo */
/*----------------------------------------------------------------------------*/
method createForm( ) {

	long 		sts , msg;
	int 		firstSetSize, secondSetSize ;
	int 		form_label ;
//	int		i ;
	char    	*usrAttrFm ;
	SetProc( VSplnjntCmd_createForm ) ; Begin
        
	firstSetSize = om$dimension_of( varray = me->firstSet ) ;

	secondSetSize = om$dimension_of( varray = me->secondSet ) ;
	/* new code for TR179901012 E  
	 *  This deletes old forms before making new ones
	 */
	// Delete existing form and replace with NULL pointer
	if( me->plcJnForm != NULL){
	 FIf_delete( me->plcJnForm );
	 me->plcJnForm = NULL;
	}
	/* end of new code for TR179901012 E  no other changes made pn */

	if( firstSetSize == 1 && secondSetSize == 1 ){
		/*
		 * Both the sets have only one feature object to be joined
		 * Display the form appropriately.
		 * Init form.
		 */
		form_label = 0;
		me->ret = FIf_new( form_label, "VSPlaceJnt.fm", 
				COB_FI_form_notification,
                          		&me->plcJnForm ) ;
 
	} else {
		/*
		 * Create the form that is suitable for handling sets
		 * Init form.
		 */
		form_label = 1 ;
		sts = FIf_new( form_label, "VSsetsJoint.fm", 
					COB_FI_form_notification,
					&me->plcJnForm ) ;
	}
	FIf_set_cmd_oid_os( me->plcJnForm, my_id, OM_Gw_current_OS ) ;

	sts = om$send( msg	= message VSplnjntCmd.initForm( &msg, 
								form_label,
								me->plcJnForm ),
			targetid= my_id );
	__CheckRC(sts, msg, "VSplnjntCmd.initForm", wrapup );

	/*
	 * We build the user attributes sub-form to be at hand if needed.
	 */
	sts = FIf_new(	2,
                        VS_K_jn_UsrAttrFormName,
                        VS_ActJnAttr_UA_form_notification,
                        &usrAttrFm ) ;
	if( sts == FI_SUCCESS ) {
        	/*
         	 * Stick sub-form as user-pointer of joint attributes 
		 * sub-form for easy retrieval.
         	 */
        	FIf_set_user_pointer( me->attrForm, usrAttrFm ) ;
	}
	/*
	 * Display the joint placement form
	 */
	FIf_display( me->plcJnForm ) ;

wrapup :
	End 
	me->ret = ( msg & 1 ) ? VS_K_ACT_SUCCESS : VS_K_RESTART_CMD ; 

	return OM_S_SUCCESS ;

}/* method createForm */
/*----------------------------------------------------------------------------*/
method rmLocSet( 	long *msg ; 
			int whichSet )
{
	int from_index = 0;
	SetProc( VSplnjntCmd_rmLocSet ) ; Begin

	switch( whichSet ) {

		case 1:	
       			 om$vla_set_dimension( 	varray = me->firstSet, 
						size = from_index ) ;
			break ;
	
		case 2:
        		om$vla_set_dimension( 	varray = me->secondSet, 
						size = from_index ) ;
			break ;

		default :
			break ;
	}

	End 
	return OM_S_SUCCESS ;

}/* method rmLocSet */
/*----------------------------------------------------------------------------*/
method validateFirstSet( long *sts  )
{

	int 		firstSetSize = 0;	/* part count in first set */
	SetProc( VSplnjntCmd_validateFirstSet ) ; Begin

	/*
	 * get the number of parts that are stored in the first set
	 * If the number of parts are more than one then the first
	 * set is a valid set for trying the 'place joint' for parts within
	 * the set 
	 */
	firstSetSize = om$dimension_of( varray = me->firstSet ) ;
	
	if( firstSetSize > 1 ) 	*sts = me->ret = VS_K_ACT_SUCCESS ;
	else 			*sts = me->ret = VS_K_ABORT_CMD ;

	End 
	return OM_S_SUCCESS ;

}/* method validateFirstSet */
/*----------------------------------------------------------------------------*/
method form_notification(       int     form_label ;
                                int     gadget_label ;
                                double  value ;
                                char    *form_ptr ) {
	int		i, fdsp, response ;
	long		msg , sts ;
	int		isHere, inModel, writable ;
	double		fvalue ;
	char            *name ,
			*type ;

#define PUT_RESPONSE( value )\
        { int resp = (value) ; ex$putque( msg = &msg, response = &resp ) ; }

	SetProc( VSplnjntCmd_form_notification ) ; Begin

	if( form_label == 1 ) {
		om$send( msg = message VSplnjntCmd.VSsetJnts_form_notification(
							form_label,
							gadget_label,
							value,
							me->plcJnForm ),
                        targetid = my_id );
        } else if ( form_label == JNT_ATTR ){
		om$send( msg = message VSplnjntCmd.sub_form_notification(
							form_label,
							gadget_label,
							value,
							me->attrForm ),
			targetid = my_id );
	} else {

	switch( gadget_label ) {

		 case VS_K_jn_Dismiss_Execute    :
		 	__DBGpr_com("VS_K_jn_Dismiss_Execute");    
                        /*
                         * Construct beam(s), then exit command.
                         */
                        response = TERMINATE ;
                        goto EXECUTE ;
 
                case VS_K_jn_Execute            :
			__DBGpr_com("VS_K_jn_Execute");
                        /*
                         * Construct beam, then go to state "start".
                         */
                        response = EX_BACK_UP ;
 
                EXECUTE :
			vs$isDirUsable(	dirname	= me->Cwd,
					isHere	= &isHere,
					inModel	= &inModel,
					writable= &writable ) ;
			if( !isHere ) {
				VSfi_msgkeySts( form_ptr, VS_gW_NoSuchDir ) ;
				FIg_set_state_off( form_ptr, gadget_label ) ;
				break ;
			} else if( !inModel ) {
				/*
				 * Cannot construct if not in master file.
				 */
				VSfi_msgkeySts( form_ptr, VS_gW_CwdNtInMod ) ;
				FIg_set_state_off( form_ptr, gadget_label ) ;
				break ;
			} else if( !writable ) {
				VSfi_msgkeySts( form_ptr, VS_gW_CwdNotWritable ) ;
				FIg_set_state_off( form_ptr, gadget_label ) ;
				break ;
			}

			om$send(msg = message VSplnjntCmd.construct_joint( 
								&msg,
								form_label,
								form_ptr ),
				targetid= my_id ) ;
			FIf_erase( form_ptr );
                        PUT_RESPONSE( response );
                        break ;

		case VS_K_jn_Dismiss :
			__DBGpr_com("VS_K_jn_Dismiss ");
			/*
			 * Exit command.
			 */
                	response = TERMINATE ;
			PUT_RESPONSE ( response );
			break ;

		case JNT_ATTR	:
			__DBGpr_com("JNT_ATTR	");
                        if ( me->attrForm ) {
                                FIf_is_displayed( me->attrForm, &fdsp ) ;
                                if ( ! fdsp ) {
					int x_pos , y_pos ;

					FIf_get_location(form_ptr,
       	                                                 &x_pos,
       	                                                 &y_pos ) ;
				
					FIf_set_location( me->attrForm,
							  x_pos + 300,
							  y_pos + 200 );

                                        FIf_display( me->attrForm ) ;
                                }
                        } else {
				int x_pos , y_pos ;
                                VSf_sub_form(   form_ptr,
                                                gadget_label,
                                                VS_K_Jnt_Attribute_File,
                                                &me->attrForm ) ;

				FIf_get_location(	form_ptr,
                                                        &x_pos,
                                                        &y_pos ) ;
				FIf_set_location( me->attrForm,
						  x_pos + 300,
						  y_pos + 200 );
                                FIg_display( me->attrForm, VS_K_jn_wldSideSym );

                                FIf_display( me->attrForm ) ;
                        }
 
                        FIg_disable( form_ptr, gadget_label ) ;

                        break ;

		case VS_K_jn_Process    :
		case VS_K_jn_Weld_Code  :
			__DBGpr_com("VS_K_jn_Weld_Code  ");
			/*
			 * Retrieve selected row : row number corresponds to
			 * value of datum.
			 */
			i = VSgetSelectedRow( form_ptr, gadget_label ) ;
			VSputWeldInfo( gadget_label, i ) ;

			break ;

		case VS_K_jn_Weld_Size	:
			__DBGpr_com("VS_K_jn_Weld_Size	");
			name = VS_K_dpbActJnWeldSize ;
			type = GRIO_DISTANCE ;
 
			vs$getDpbCollAttr(      msg     = &msg,
						name    = name,
						p_value = &fvalue ) ;
			 
			vs$processUnitField(    msg     = &msg,
						form    = form_ptr,
						field   = gadget_label,
						type    = type,
						oldValue= fvalue,
						newValue= &fvalue ) ;
			if( msg & 1 ) {
				sts = vs$putDpbCollAttr(msg     = &msg,
							name    = name,
							value   = &fvalue ) ;
			}
 
			break ;

 
		case VS_K_jn_PickGeom	:
			__DBGpr_com("VS_K_jn_PickGeom	");
			response = VS_K_CH_STATE ;
			PUT_RESPONSE( response );
			break ;

		default :
			break ;
	}
	}
	
	End 
	return OM_S_SUCCESS ;
}/* method form_notification */
/*----------------------------------------------------------------------------*/
method sub_form_notification(	int 	form_label ;	
				int     gadget_label ; 
				double	value ;
				char	*form ) {
	long		msg, sts ;
	int 		symbol ;
	char		*parentForm = me->plcJnForm ;
	char		*name,
			*type ;
	double		fvalue ;
	char		*UAsubForm ;
	struct GRid	UAid ;
        SetProc(sub_form_notification); Begin	

	switch( gadget_label ) {

		case FI_ACCEPT	:
			FIg_enable( parentForm, JNT_ATTR ) ; 
			FIg_set_state_off( parentForm, JNT_ATTR ) ; 
			FIg_set_state_off( form, gadget_label ) ; 
			FIf_get_user_pointer( form, &UAsubForm ) ;
			if( UAsubForm ) FIf_erase ( UAsubForm );
			FIf_erase( form );

			break ;

		case VS_K_jn_LeftSide  :
			symbol = VS_K_jn_LeftSide  ; goto UPDATE1 ;
		case VS_K_jn_RightSide  :
			symbol = VS_K_jn_RightSide ; goto UPDATE1 ;
		case VS_K_jn_BothSides  :
			symbol = VS_K_jn_BothSides ; goto UPDATE1  ;
		UPDATE1 		:
			FIg_set_state_on( form, symbol ) ;

                case VS_K_jn_FieldWeld  :
			VSputWeldInfo( gadget_label, (int) value ) ;
			break ;

		case VS_K_jn_FloorPos  :
			symbol = VS_K_jn_FloorPos; 
			fvalue	= VS_K_wldFloorPos ;
			goto UPDATE2 ;
		case VS_K_jn_HorzPos  :
			symbol = VS_K_jn_HorzPos ; 
			fvalue	= VS_K_wdlHorzPos ; goto UPDATE2 ;
		case VS_K_jn_CeilPos  :
			symbol = VS_K_jn_CeilPos ; 
			fvalue	= VS_K_wldCeilPos ; goto UPDATE2 ;
		case VS_K_jn_VertPos  :
			symbol = VS_K_jn_VertPos ;
			fvalue	= VS_K_wldVertPos ;
			 
		UPDATE2		:
			FIg_set_state_on( form, symbol ) ;
			sts = vs$putDpbCollAttr(msg     = &msg,
						name    = VS_K_dpbActJnWeldPos,
						value   = &fvalue ) ;
			break ;

		case VS_K_jn_Pitch      :
			name = VS_K_dpbActJnPitch ;
			type = GRIO_DISTANCE ;
			goto UPDATE3 ;

		case VS_K_jn_ShrkRatio :
			name = VS_K_dpbActJnShrkRatio ;
			type = GRIO_DISTANCE ;
			goto UPDATE3 ;
 
		case VS_K_jn_IncrLength :
			name = VS_K_dpbActJnIncrLn ;
			type = GRIO_DISTANCE ;

		UPDATE3 :
			vs$getDpbCollAttr(      msg     = &msg,
						name    = name,
						p_value = &fvalue ) ;
 
			vs$processUnitField(    msg     = &msg,
						form    = form,
						field   = gadget_label,
						type    = type,
						oldValue= fvalue,
						newValue= &fvalue ) ;
			if( msg & 1 ) {
				sts = vs$putDpbCollAttr(msg     = &msg,
							name    = name,
							value   = &fvalue ) ;
			}

			break ;

		case VS_K_jn_UsrAttrsBtn:
                        FIg_set_state_off( form, gadget_label ) ;
 
                        FIf_get_user_pointer( form, &UAsubForm ) ;
                        if( !UAsubForm ) break ;
 
                        /*
                         * Retrieve active collection of user-attributes for
                         * joints.
                         */
                        vs$getActiveUsrAttr( msg        = &msg,
                                             basename   = VS_K_jointUA,
                                             p_activeUA = &UAid ) ;
 
                        if( !IF_NULL_OBJID( UAid.objid ) ) {
                                VSfillJointUsrAttrForm( &msg, UAsubForm, &UAid);
                        }
			{
			int 	x_pos = 0, y_pos = 0 ;

			FIf_get_location( form, &x_pos, &y_pos );

			FIf_set_location( UAsubForm,
					  x_pos + 200,
					  y_pos + 100 );
			}

                        FIf_display( UAsubForm ) ;

                        break ;
		default :
			break ;
	}
	End
	return OM_S_SUCCESS ;

}/* method sub_form_notification */
/*----------------------------------------------------------------------------*/
long VSfillJointPlacementForm( msg, form_label, form, jAttr ) 
long            *msg ;
int		form_label ;
char            *form ;
VSjointAttr    *jAttr ; {

	char		**codeList , **procList;
	long 		sts ,  *list ;
	int		count,  cnt1 = 0, cnt2;
	int		i ;	
	
	SetProc( VSplnjnjCmd_VSfillJointPlacementForm ); Begin

	codeList = procList = NULL ;
	cnt1 = cnt2 = count = 0;
	/*
         * Retrieve list of weld codes from an ASCII file
         */
//        sts = vs$getWeldCodeASCII (     msg     = msg,
//                                        count   = &cnt1,
//                                        list    = &codeList );
//      if( !(sts & *msg & 1 ) ) {

	sts = VDread_weld_sym_char( &cnt1 );	// READ FROM "$VDS/config/weld_symbols"

        if( !(sts & 1 && cnt1 ) ) {
                /*
                 * Retrieve list of weld codes which are static
                 * NOTE `list' not to be freed.
                 */
                sts = vs$getWeldCodes( msg      = msg,
                                       count    = &count,
                                       list     = &list ) ;
                __CheckRC( sts, *msg, "vs$getWeldCodes", wrapup ) ;

		VSfillSelectListAndSetActive(   form,
                                                VS_K_jn_Weld_Code,
                                                count,
                                                list,
                                                (int) jAttr->weldAttr.code ) ;
        } else {
                /*
                 * Set the list of weld codes from the ASCII file
                 * in the form
                 */
//////		int	flag = TRUE ;	
		int	i;

		for ( i = 0; i< cnt1 ; i ++ ) {
			FIfld_set_list_text( form, VS_K_jn_Weld_Code, i, 0,
//////					     codeList[i],
					     sym_char[i].desc,
					     FALSE);
			if( i == (int) jAttr->weldAttr.code )
			{
			  FIfld_set_text( form, VS_K_jn_Weld_Code, 0, 0, sym_char[i].desc, TRUE ) ;
 
			  FIfld_set_list_select( form, VS_K_jn_Weld_Code, i, 0, TRUE ) ;
			}

//////			flag = FALSE ;
               }
        }
        /*
         * Retrieve list of weld processes from an ASCII file
         */
        sts = vs$getWeldProcASCII (     msg     = msg,
                                        count   = &cnt2,
                                        list    = &procList );
        if( !(sts & *msg & 1 ) ) {
                /*
                 * Retrieve list of weld processes which are statis.
                 * NOTE `list' not to be freed.
                 */
                sts = vs$getWeldProcesses(      msg     = msg,
                                                count   = &count,
                                                list    = &list ) ;
                __CheckRC( sts, *msg, "vs$getWeldProcesses", wrapup ) ;
 
                VSfillSelectListAndSetActive(   form,
                                                VS_K_jn_Process,
                                                count,
                                                list,
                                                (int) jAttr->weldAttr.process );
        } else {
                /*
		 * Set the list of weld code from the ASCII file
                 * in the form
                 */
                int     flag = TRUE ;
                int     i;
 
                for ( i = 0; i< cnt2 ; i ++ ) {
                        FIfld_set_list_text( form, VS_K_jn_Process,
                                                i, 0, procList[i], flag);
                        flag = FALSE ;
                }
	}
	vs$fillUnitField(	msg     = msg,
				form    = form,
				field   = VS_K_jn_Weld_Size,
				value   = jAttr->size ) ;

	if( form_label == 1 ) {

		int	row, selCodeRow, selProcRow, selSizeRow ;
		char	*code = NULL, *proc = NULL, *size = NULL ;

		/*
	 	 * This is a set form , hence set all the possible rows
	 	 * with the weld codes
	 	 */
		selCodeRow = VSgetSelectedRow( form, VS_K_jn_Weld_Code ) ;
		/*
	 	 * This is a set form , hence set all the possible rows
	 	 * with the weld processes
	 	 */
		selProcRow = VSgetSelectedRow( form, VS_K_jn_Process ) ;
		/*
	 	 * This is a set form , hence set all the possible rows
	 	 * with the weld sizes
	 	 */
		selSizeRow = VSgetSelectedRow( form, VS_K_jn_Weld_Size ) ;

		code = VSmcf_get_text( form, VS_K_jn_Weld_Code, selCodeRow, 0 );
		proc = VSmcf_get_text( form, VS_K_jn_Process  , selProcRow, 0 );
		size = VSmcf_get_text( form, VS_K_jn_Weld_Size, selSizeRow, 0 );

		row = 0;
		FIfld_get_num_rows( form, PART_MCF, &row );	

		for( i = 0; i < row ; i++ ) {
			FIfld_set_text(	form, PART_MCF, i, CODE_COL, code, 
					FALSE ) ;
			FIfld_set_text(	form, PART_MCF, i, PROC_COL, proc, 
					FALSE ) ;
			FIfld_set_text(	form, PART_MCF, i, SIZE_COL, size, 
					FALSE ) ;
		}

		_FREE( code );
		_FREE( proc );
		_FREE( size );
	}

	wrapup :
                VSfreeList( cnt1, codeList);
                VSfreeList( cnt2, procList);
		End
                return sts ;
}/* VSfillJointPlacementForm */
/*----------------------------------------------------------------------------*/
long VSfillJointAttrForm( 	long 		*msg, 
				int		form_label,
				char		*form_ptr,
				VSjointAttr 	*jAttr ) {
	long 	sts ;
	int	info, g;

	form_label = 0;		// To  avoid warning in compilation
	switch( jAttr->weldAttr.side ) {

		default	:
		case	VS_K_wldLeftSide	:
			g = VS_K_jn_LeftSide ;		break ;
		case	VS_K_wldRightSide	:
			g = VS_K_jn_RightSide ;		break ;
		case	VS_K_wldBothSides	:
			g = VS_K_jn_BothSides;		break ;
	}
	FIg_set_state_on( form_ptr, g );

	switch( ( int )jAttr->addWldAttr.position ) {
		case VS_K_wdlHorzPos 	:
			g = VS_K_jn_HorzPos ;	break ;
		case VS_K_wldCeilPos 	:
			g = VS_K_jn_CeilPos ;	break ;
		case VS_K_wldVertPos 	:
			g = VS_K_jn_VertPos ;	break ;
		default			:
		case VS_K_wldFloorPos 	:
			g = VS_K_jn_FloorPos ;	break ;
	}
	FIg_set_state_on( form_ptr, g );

	sts = vs$fillUnitField( msg     = msg,
				form    = form_ptr,
				field   = VS_K_jn_Pitch,
				value   = jAttr->pitch ) ;
 
	sts = vs$fillUnitField( msg     = msg,
				form    = form_ptr,
				field   = VS_K_jn_IncrLength,
				value   = jAttr->incrLength ) ;

	sts = vs$fillUnitField( msg     = msg,
				form    = form_ptr,
				field   = VS_K_jn_ShrkRatio,
				value   = jAttr->shrinkage ) ;

	info = jAttr->weldAttr.info ;

	if( info & VS_m_wldFieldWeld    ) {
                FIg_set_state_on( form_ptr, VS_K_jn_FieldWeld       ) ;
        } 

	return sts ;

}/* VSfillJointAttrForm */
/*----------------------------------------------------------------------------*/
method initForm( long 	*msg;
		 int 	form_label ;
		 char 	*form_ptr ) {
 
        long            sts ;
        VSjointAttr     jAttr ;
	int    	        dbg_int;

	SetProc( VSplnjntCmd_initForm ) ; Begin

        /*
         * Retrieve active joint attributes from DPB.
         */
        sts = VSgetActNewJnAttr( msg, &jAttr ) ;
        __CheckRC( sts, *msg, "VSgetActNewJnAttr", wrapup ) ;

	/*
	 * If the form is related to sets the display the fields in the 
	 * form that are valid for placement of set joints 
	 */
	if( form_label == 1 ){
		int 	row, firstSetSize, secondSetSize ;
		int	ii, k, j  ;
		IGRboolean intersect = 0;
		GRname 	part1Name , part2Name;
		GRrange interrng ;
		GRrange RANGE1,
                        RANGE2 ;
		IGRboolean world = TRUE ;
		long	rc ;

		row = 0 ;

		__DBGpr_com("form_label == 1 ");
		firstSetSize = om$dimension_of( varray = me->firstSet ) ;

		secondSetSize = om$dimension_of( varray = me->secondSet ) ;
		__DBGpr_com("line 1532");
		for( ii = 0; ii< firstSetSize; ii++ ) {
		   __DBGpr_com(" Entered first for loop\n"); 
			sts = om$send(  msg = message GRgraphics.GRgetrang(
							msg,
							&me->firstSet[ii]._matrix_type,
							me->firstSet[ii]._matrix,
							&world,
							RANGE1 ),
					targetid= me->firstSet[ii]._objid,
					targetos= me->firstSet[ii]._osnum ) ;
			__CheckRC( sts, *msg, "GRgraphics.GRgetrang", wrapup ) ;


			for( j = 0; j< secondSetSize ;  j++ )
			{
		   	__DBGpr_com(" secondSet for loop"); 
				for ( k = 0 ; k <= ii ; k++ ) {
				    if( IF_EQ_GRID( me->firstSet[k]._grid,
                                                    me->secondSet[j]._grid ) ) {

					/*
					 * make sure that a joint doesn't exists
					 * with the same combination
					 */
					goto next_element ;
				    }
				}
		   		__DBGpr_com(" GRgraphics.GRgetrange"); 
				sts = om$send(  msg = message 
							GRgraphics.GRgetrang(
								msg,
								&me->secondSet[j]._matrix_type,
								me->secondSet[j]._matrix,
								&world,
								RANGE2 ),
					targetid= me->secondSet[j]._objid,
					targetos= me->secondSet[j]._osnum ) ;
				__CheckRC( sts, *msg, "GRgraphics.GRgetrang", 
									wrapup);
				BSrgbxint(	&RANGE1[0], &RANGE1[3],
						&RANGE2[0], &RANGE2[3],
						&intersect,
						interrng + 0, interrng + 3,
						&rc ) ;
        			if(rc != BSSUCC) {
	    		   	  goto wrapup;
				}
			dbg_int = om$dimension_of( varray = me->objList ) ;
			__DBGpr_int(" size of object list",dbg_int);
                        	if( intersect ) {
					part1Name[0] = '\0' ;
			
					vd$get_name( 	obj	= &me->firstSet[ii]._grid ,
							name	= part1Name );

					if( part1Name )
						FIfld_set_text(	form_ptr, 
								PART_MCF, 
								row,
								0, 
								part1Name,
								FALSE );
					part2Name[0] = '\0' ;
		
					vd$get_name( obj  = &me->secondSet[j]._grid,
						     name = part2Name ) ;

					if( part2Name )
						FIfld_set_text(	form_ptr, 
								PART_MCF, 
								row,
								1, 
								part2Name,
								FALSE );
					row++ ;

			     __DBGpr_obj(" 1st part ",me->firstSet[ii]._grid);  	
			     __DBGpr_obj(" 2nd part ",me->secondSet[j]._grid);  	
	//added for TR #179802320: start
                              if( vs$is_ancestry_valid(
					     object  = &me->firstSet[ii]._grid, 
                                             classid = OPP_VSplate_class_id) &&				  vs$is_ancestry_valid(
                                             object  = &me->secondSet[j]._grid,					     classid = OPP_VSplate_class_id) ) {
				if( VSisDiagonallyOpp(
					   &me->firstSet[ii]._grid, 
					   &me->secondSet[j]._grid, 
					   &me->firstSet[ii], 
					   &me->secondSet[j],
					   &jAttr.size)) {
	//added for TR #179802320: ends
				  //printf("\n Diagonally opp. plates\n");
						goto next_element ;

	} else {
		__DBGpr_com("Not diagonally opp plates");
		}
		}// if only both parts are plates
				/*
			                if(!VSisSuitableForWeld( 
					   &me->firstSet[ii]._grid, 
					   &me->secondSet[j]._grid, 
					   &me->firstSet[ii].mod_env, 
					   &me->secondSet[j].mod_env,&jAttr->size))
						goto next_element ;
				*/
				//TR179800867 end.

					om$vla_set_dimension( 
						varray 	= me->objList, 
						size 	= 2*row ) ;
					me->objList[2*row - 2]._grid = me->firstSet[ii]._grid ;
					me->objList[2*row - 1]._grid = me->secondSet[j]._grid ;
					me->objList[2*row - 2].mod_env= me->firstSet[ii].mod_env ;
					me->objList[2*row - 1].mod_env= me->secondSet[j].mod_env ;

				}
			 	next_element :
					continue ;
			}
		}
	} else if( form_label == 0 ) {
		__DBGpr_com("form_label == 0 ");
	//TR179800867 start:
	//TR179802320 start:
                if( vs$is_ancestry_valid(
			object  = &me->firstSet[0]._grid, 
                        classid = OPP_VSplate_class_id) &&
		    vs$is_ancestry_valid( 
			object  = &me->secondSet[0]._grid,
			classid = OPP_VSplate_class_id) ) {
	//TR179802320 ends:
		if( VSisDiagonallyOpp(
		    &me->firstSet[0]._grid, 
		    &me->secondSet[0]._grid, 
		    &me->firstSet[0], 
		    &me->secondSet[0],
		    &jAttr.size)) {
		  //printf("\nDiagonally opp. plates\n");
				//goto next_element ;

		} else {
 			__DBGpr_com("Not diagonally opp plates");
			om$vla_set_dimension( varray 	= me->objList, 
					size 	= 2 ) ;
			me->objList[0]._grid = me->firstSet[0]._grid ;
			me->objList[1]._grid = me->secondSet[0]._grid ;
			me->objList[0].mod_env= me->firstSet[0].mod_env ;
			me->objList[1].mod_env= me->secondSet[0].mod_env ;
		} 
	//TR179800867 end:
	} else {
 		__DBGpr_com("Not diagonally opp plates");
		om$vla_set_dimension( varray 	= me->objList, 
					size 	= 2 ) ;
		me->objList[0]._grid = me->firstSet[0]._grid ;
		me->objList[1]._grid = me->secondSet[0]._grid ;
		me->objList[0].mod_env= me->firstSet[0].mod_env ;
		me->objList[1].mod_env= me->secondSet[0].mod_env ;
	}
	}
	//dbg_int = om$dimension_of( varray = me->objList ) ;
	//__DBGpr_int(" size of object list",dbg_int);

        /*
         * Fill form.
         */
	sts = VSfillJointPlacementForm( msg,  form_label, form_ptr, &jAttr ) ;
	/*
	 * Fill the sub form which shows the joint attributes like
	 * weld side, weld position, etc...
	 */
	if( me->attrForm ) {
		/*
		 * do nothing
		 */
	} else {
		VSf_sub_form ( form_ptr,
				JNT_ATTR ,
				VS_K_Jnt_Attribute_File,
				&me->attrForm ) ;
	}
	sts = VSfillJointAttrForm( msg,  form_label, me->attrForm, &jAttr ) ;
 
        wrapup :
                *msg = ( *msg & sts & 1 ) ? VS_K_ACT_SUCCESS : VS_K_ABORT_CMD ;
	End 
        return OM_S_SUCCESS ;

}/* method initForm */
/*----------------------------------------------------------------------------*/
void VSsetWeldCPSattr(  long		*msg ,
			char		*form_ptr, 
			int		mcfRow )
{
	long	sts ;
	int 	index, rows ,flag,i, len;
	char	*code = NULL, *proc = NULL, *size = NULL ;
	char	*wldCode = NULL, *wldProc = NULL, *wldSize = NULL;
				
	index = -1 ; rows = 0 ;
	/*
	 * get the appropriate weld code , weld process
	 * and weld size for this combination 
	 */
	FIfld_get_list_num_rows( form_ptr, 
				 VS_K_jn_Weld_Code, 
				 0, 
				 &rows );

	code = VSmcf_get_text(  form_ptr, PART_MCF, mcfRow, CODE_COL ) ;

	for( i = 0; i < rows ; i++ ) {
		len = 0 ;
		FIfld_get_list_text_length( form_ptr, VS_K_jn_Weld_Code, i, 0,
						&len ) ;
		if( !( wldCode = _MALLOC( len, char ))) vs$mem_fail() ;

		FIfld_get_list_text( form_ptr, VS_K_jn_Weld_Code, i, 0, 
					len, (unsigned char *)wldCode, &flag );
		if( !strcmp( code, wldCode ) ) {
			index = i; 
			break ; 
		}
		_FREE( wldCode )
	}
	if( index != -1 )
		VSputWeldInfo( VS_K_jn_Weld_Code, index );

	index = -1; rows = 0;

	FIfld_get_list_num_rows( form_ptr, 
				 VS_K_jn_Process, 
				 0, 
				 &rows );

	proc = VSmcf_get_text(  form_ptr, PART_MCF, mcfRow, PROC_COL ) ;

	for( i = 0; i < rows ; i++ ) {
		len = 0 ;
		FIfld_get_list_text_length( form_ptr, VS_K_jn_Process, i, 0,
						&len ) ;
		if( !( wldProc = _MALLOC( len, char ))) vs$mem_fail() ;

		FIfld_get_list_text( form_ptr, VS_K_jn_Process, i, 0, 
					len, (unsigned char *)wldProc, &flag );
		if( !strcmp( proc, wldProc ) ) {
			index = i; 
			break ; 
		}
		_FREE( wldProc ) ;
	}
	if( index != -1 )
		VSputWeldInfo( VS_K_jn_Process, index );

	index = -1; rows = 0;

	FIfld_get_list_num_rows( form_ptr, 
				 VS_K_jn_Weld_Size, 
				 0, 
				 &rows );

	size = VSmcf_get_text(  form_ptr, PART_MCF, mcfRow, SIZE_COL ) ;

/*
	for( i = 0; i < rows ; i++ ) {
		len = 0 ;
		FIfld_get_list_text_length( form_ptr, VS_K_jn_Weld_Size, i, 0,
						&len ) ;
		if( !( wldSize = _MALLOC( len, char ))) vs$mem_fail() ;

		FIfld_get_list_text( form_ptr, VS_K_jn_Weld_Size, i, 0, 
					len, (unsigned char *)wldSize, &flag );
		if( !strcmp( size, wldSize ) ) {
			index = i; 
			break ; 
		}
		_FREE( wldSize ) ;
	}
*/
	{
		double	fvalue = 0;

		vs$getDpbCollAttr(      msg     = msg,
					name    = VS_K_dpbActJnWeldSize,
					p_value = &fvalue ) ;
 
		vs$processUnitField(    msg     = msg,
					form    = form_ptr,
					field   = PART_MCF,
					row	= mcfRow,
					column	= SIZE_COL,
					oldValue= fvalue,
					newValue= &fvalue ) ;
		if( *msg & 1 ) {
			sts = vs$putDpbCollAttr(msg     = msg,
						name    = VS_K_dpbActJnWeldSize,
						value   = &fvalue ) ;
		}
	}

		VSputWeldInfo( VS_K_jn_Weld_Size, index );
wrapup :
	_FREE( code );
	_FREE( proc );
	_FREE( size );
	_FREE( wldCode );
	_FREE( wldProc );
	_FREE( wldSize );

}/* VSsetWeldCPSattr */
/*----------------------------------------------------------------------------*/
#if 0 
method construct_joint(  long	*msg ;
			 int	form_label ;
			 char	*form_ptr ) 
{

	long			sts ;		/* OM return code	*/
	struct GRobj_env	*jnCurve ,	/* jn curve i locate	*/	
				locElmnts[2] ;	/* Located elements	*/
	struct GRvg_construct	cst ;		/* Construction list	*/
	VSpartAttr		jnPart ;	/* Part attr. (joint)	*/
	VSjointAttr		jointAttr ;	/* Attributes of joints	*/
	int			i, j, k,	/* for loop index	*/
				row = 0,	/* used for code, proc..*/
				mcfRow = 0,	/* used for part filed  */
				firstSetSize,	/* part cnt in first set*/
				secondSetSize ;	/* part cnt in first set*/
	char			*jnDir ;	/* Directory for joint	*/
	struct GRid		actJnUA,	/* Act. usr attributes	*/
				joint ;		/* Created joint	*/
	GRname			jnPathName ;	/* Name of joint	*/
        struct ACdb_info        dbInfo ;        /* dbinfo               */
	GRrange 		interrng,	/* intersection range	*/
				RANGE1,		/* first element range 	*/
				RANGE2 ;	/* second element range */
	IGRboolean 		world = TRUE,	/* for range evaluation */
				intersect = 0;	/* Is rng-rng intersect?*/
	long    		rc ;		/* BS return code	*/
	
	
	jnCurve = NULL ;

	/*
	 * get the part counts in both the sets
	 */
	firstSetSize  = om$dimension_of( varray = me->firstSet ) ;
	secondSetSize = om$dimension_of( varray = me->secondSet ) ;

	if( form_label == 0  ) {
		/*
		 * Allocate the memory for one object only.
		 */ 
		jnCurve = _MALLOC( 1, struct GRobj_env ) ;

		jnCurve->_objid	= NULL_OBJID ;
		/*
	 	 * Get the geometry being added the locate.
	 	 */ 
		sts = om$send(  msg     = message VSlocateCmd.getLocObjs(
                                        msg, 1, jnCurve ),
                	        targetid= my_id ) ;
		if( !( sts & * msg & 1 ) || ( sts == OM_I_CHAN_EMPTY )) {
			/*
			 * nothing wrong, objects are not store at locate
			 * instance
			 */
			_FREE( jnCurve ) ;
		}
	}

	/*
	 * before placing the joint do a range range check.
	 * Thats how joints were filter in filling the form
	 */
	for( i = 0; i < firstSetSize; i++ ) 
	{

		sts = om$send(  msg = message GRgraphics.GRgetrang(
						msg,
						&me->firstSet[i]._matrix_type,
						me->firstSet[i]._matrix,
						&world,
						RANGE1 ),
				targetid= me->firstSet[i]._objid,
				targetos= me->firstSet[i]._osnum ) ;
		__CheckRC( sts, *msg, "GRgraphics.GRgetrang", wrapup ) ;


		for( j = 0; j< secondSetSize ;  j++ )
		{
			for ( k = 0 ; k <= i ; k++ ) {
			    if( IF_EQ_GRID( 	me->firstSet[k]._grid,
						me->secondSet[j]._grid ) ) {
				/*
				 * make sure that a joint doesn't exists
				 * with the same combination or
				 * within the same objects ( meaningless )
				 */
				goto next_element ;
			    }
			}

			sts = om$send(  msg = message GRgraphics.GRgetrang(
							msg,
							&me->secondSet[j]._matrix_type,
							me->secondSet[j]._matrix,
							&world,
							RANGE2 ),
				targetid= me->secondSet[j]._objid,
				targetos= me->secondSet[j]._osnum ) ;
			__CheckRC( sts, *msg, "GRgraphics.GRgetrang", 
									wrapup);
			BSrgbxint(	&RANGE1[0], &RANGE1[3],
					&RANGE2[0], &RANGE2[3],
					&intersect,
					interrng + 0, interrng + 3,
					&rc ) ;
        			if(rc != BSSUCC) {
	    		   	  goto wrapup;
				}
			if( intersect ) {
				locElmnts[0]._grid = me->firstSet[i]._grid ;
				locElmnts[1]._grid = me->secondSet[j]._grid ;

				locElmnts[0].mod_env = me->firstSet[i].mod_env;
				locElmnts[1].mod_env = me->secondSet[j].mod_env;

				/*
				 * Unhilite located objects.
				 */
				vs$bulk_display( count = 2, 
						 objenvs = locElmnts, 
						 dpmode = GRhe ) ;

				vs$cnstDefaults(msg	= msg,
						symb_id = me->ModuleInfo.md_id,
						symb	= &me->ActiveRep,
						matchKey= me->matchKey,
						matchId = &locElmnts[0]._grid,
						path	= me->Cwd,
						level	= &me->ActiveLevel,
						display	= &me->ActiveDisplay ) ;


				jnPart.specific	= (void *) &jointAttr ;
				jnPart.Iwant	= VS_m_All ;

				vs$fill_cnst_list(Cnst_list = cst,
						  Msg	    = msg,
						  Env_info  = &me->cstEnv,
						  Display   = &me->ActiveDisplay,
						  Level     = me->ActiveLevel,
						  Class_attr= &jnPart ) ;


				if( form_label == 1 )  {
					VSsetWeldCPSattr( msg, 
							  form_ptr,
							  mcfRow );
					mcfRow++ ;
				}
				/*
				 * Get active joint attributes from the DPB.
				 */
				VSgetActNewJnAttr( msg, &jointAttr ) ;

				/*
				 * Get active collection of 
				 * user-attributes for joints.
	 			 */
				vs$getActiveUsrAttr( msg	= msg,
						     basename   = VS_K_jointUA,
						     p_activeUA = &actJnUA ) ;

				if( IF_NULL_OBJID( actJnUA.objid ) ) {
					int	nbAttrs = 1 ;
					char	*attrNames = "__NULL_ATTR" ;
					char	*attrVals = "__1" ;
					vs$makeActiveUsrAttr( 
							msg       = msg,
							basename  = VS_K_jointUA,
							nbEntries = nbAttrs,
							names     = &attrNames,
							syntaxes  = &attrVals,
							p_activeUA= &actJnUA ) ;

// 					jnPart.Iwant	&= ~VS_m_UsrAttr ;
				} else {
					jnPart.usrAttr	= actJnUA ;
				}
				jnPart.usrAttr	= actJnUA ;

				jnDir = me->Cwd ;
			__DBGpr_obj(" Joint Between ",locElmnts[0]._grid );
			__DBGpr_obj(" ... and 	",locElmnts[1]._grid );
				sts = om$send(	msg = message 
							VSfeature.VSputJoint(
								msg,
								&locElmnts[0].mod_env,
								locElmnts + 1,
								jnCurve ,
								me->ActiveRep.representation,
								&cst,
								jnDir,
								&joint ),
						targetid= locElmnts[0]._objid,
						targetos= locElmnts[0]._osnum );
				/*
				 * Do not go to wrapup. 
				 * Try placing all possible joints
				 */
				if( !( sts & *msg & 1 ) ) {
					__DBGpr_com( "VSfeature.VSputJoint Failed" );
					continue ;
				}


				sts = om$send(	msg = message GRvg.GRgetname( 
								msg, 
								jnPathName ),
						targetid= joint.objid,
						targetos= joint.osnum ) ;

				if( ( sts & 1 & *msg ) && *jnPathName ) {
					ex$message( msgnumb = VS_gI_CreatedObj,
						    type    = "%s",
						    var     = `jnPathName` ) ;
				}

				vs$bulk_display( grids  = &joint, 
						 theEnv	= cst.env_info ) ;

				/* 
				 * Put db info 
				 */
			 	dbInfo.quantity   = VD_CKIN_STRUCT_JNT_OBJ;
			 	sts = om$send(msg = message 
							ACdb_info.ACset_db_info(
								       msg,
								       &dbInfo),
			                 	targetid = joint.objid,
                 				targetos = joint.osnum);
				if( !( sts & *msg & 1 ) ) {
					__DBGpr_com( "ACdb_info.ACset_db_info Failed" );
					continue ;
				}
			}
			next_element :
				continue ;
		}
	}


wrapup :
	_FREE( jnCurve ) ;

	if( !( sts & 1 & *msg ) ) {
		om$send(msg	= message VSpartopCmd.setErrorStatus( *msg, 2 ),
			targetid= my_id ) ;
		me->ret = VS_K_RESTART_CMD ;
	} else {
		me->ret = VS_K_ACT_SUCCESS ;
	}

	return OM_S_SUCCESS ;

}/* construct_joint */
#endif
/*----------------------------------------------------------------------------*/
method store_geometry( long *sts ) {
 
        struct GRlc_info        *toStore = me->event1.located_object ;
 
        me->ret = om$send(
                        msg     = message VSlocateCmd.addLocObj(
                                                        &toStore->located_obj,
                                                        &toStore->module_info,
                                                        0 ),
                        targetid= my_id ) ;
 
        me->ret = me->ret & 1 ? VS_K_ACT_SUCCESS : VS_K_RESTART_CMD ;
	/*
	 * Set pick geometry button state to on
	 */
	FIg_set_state_off( me->plcJnForm, VS_K_jn_PickGeom ) ;
 
        return OM_S_SUCCESS ;
 
} /* method store_geometry */

/*----------------------------------------------------------------------------*/
method construct_joint(  long	*msg ;
			 int	form_label ;
			 char	*form_ptr ) 
{

	long			sts = 0;	/* OM return code	*/
	struct GRobj_env	*jnCurve ,	/* jn curve i locate	*/	
				locElmnts[2] ;	/* Located elements	*/
	struct GRvg_construct	cst ;		/* Construction list	*/
	VSpartAttr		jnPart ;	/* Part attr. (joint)	*/
	VSjointAttr		jointAttr ;	/* Attributes of joints	*/
	int			i, j,		/* for loop index	*/
				nrow = 0,	/* used for code, proc..*/
				mcfRow = 0;	/* used for part filed  */
	char			*jnDir ;	/* Directory for joint	*/
	struct GRid		actJnUA,	/* Act. usr attributes	*/
				joint ;		/* Created joint	*/
	GRname			jnPathName ;	/* Name of joint	*/
        struct ACdb_info        dbInfo ;        /* dbinfo               */
	IGRboolean 		selFlag = FALSE;/* row select flag	*/
	int			listSize = 0 ,
				setJnt = FALSE ;
	
	SetProc(construct_joint); Begin
	jnCurve = NULL ;

	/*
	 * get the part counts in both the sets
	 */
	listSize  = om$dimension_of( varray = me->objList ) ;

	if( form_label == 1 ) {	
		int	totalRows = 0 ;

		FIfld_get_num_rows( form_ptr, PART_MCF, &totalRows ) ;

		for( i = 0 ; i < totalRows ; i++ ){
			FIfld_get_select( form_ptr, PART_MCF, i, CODE_COL,
								&selFlag ) ;
			if( selFlag ) {
				setJnt = TRUE ;	 break ;
			}
		}
		if(!setJnt ){
			VSfi_msgkeySts( form_ptr, VS_gE_NoRowsSel ) ;
			goto wrapup ;
		} else {
			VSfi_msgkeySts( form_ptr, VS_gI_EmptyMessage ) ;
		}
		selFlag = FALSE ;
	}

	if( form_label == 0  ) {
		/*
		 * Allocate the memory for one object only.
		 */ 
		jnCurve = _MALLOC( 1, struct GRobj_env ) ;

		jnCurve->_objid	= NULL_OBJID ;
		/*
	 	 * Get the geometry being added the locate.
	 	 */ 
		sts = om$send(  msg     = message VSlocateCmd.getLocObjs(
                                        msg, 1, jnCurve ),
                	        targetid= my_id ) ;
		if( !( sts & * msg & 1 ) || ( sts == OM_I_CHAN_EMPTY )) {
			/*
			 * nothing wrong, objects are not store at locate
			 * instance
			 */
			_FREE( jnCurve ) ;
		}
		selFlag = TRUE ;
	}

	/*
	 * before placing the joint do a range range check.
	 * Thats how joints were filter in filling the form
	 */
	nrow = 0 ;

	for( i = 0; i < listSize; i = i+2 ) 
	{
		if( setJnt ) {
			FIfld_get_select( form_ptr, PART_MCF, nrow, CODE_COL, 
								&selFlag );
		} 
		if( selFlag ) {

			locElmnts[0]._grid = me->objList[2*nrow]._grid ;
			locElmnts[1]._grid = me->objList[2*nrow+1]._grid ;

			locElmnts[0].mod_env = me->objList[2*nrow].mod_env;
			locElmnts[1].mod_env = me->objList[2*nrow+1].mod_env;

			/*
			 * Unhilite located objects.
			 */
			vs$bulk_display( count = 2, 
					 objenvs = locElmnts, 
					 dpmode = GRhe ) ;

			vs$cnstDefaults(msg	= msg,
					symb_id = me->ModuleInfo.md_id,
					symb	= &me->ActiveRep,
					matchKey= me->matchKey,
					matchId = &locElmnts[0]._grid,
					path	= me->Cwd,
					level	= &me->ActiveLevel,
					display	= &me->ActiveDisplay ) ;


			jnPart.specific	= (void *) &jointAttr ;
			jnPart.Iwant	= VS_m_All ;

			vs$fill_cnst_list(Cnst_list = cst,
					  Msg	    = msg,
					  Env_info  = &me->cstEnv,
					  Display   = &me->ActiveDisplay,
					  Level     = me->ActiveLevel,
					  Class_attr= &jnPart ) ;


			if( form_label == 1 )  {
				VSsetWeldCPSattr( msg, 
						  form_ptr,
						  mcfRow );
				mcfRow++ ;
			}
			/*
			 * Get active joint attributes from the DPB.
			 */
			VSgetActNewJnAttr( msg, &jointAttr ) ;

			/*
			 * Get active collection of 
			 * user-attributes for joints.
	 		 */
			vs$getActiveUsrAttr( msg	= msg,
					     basename   = VS_K_jointUA,
					     p_activeUA = &actJnUA ) ;

			if( IF_NULL_OBJID( actJnUA.objid ) ) {
				int	nbAttrs = 1 ;
				char	*attrNames = "__NULL_ATTR" ;
				char	*attrVals = "__1" ;
				vs$makeActiveUsrAttr( 
						msg       = msg,
						basename  = VS_K_jointUA,
						nbEntries = nbAttrs,
						names     = &attrNames,
						syntaxes  = &attrVals,
						p_activeUA= &actJnUA ) ;

 		//		jnPart.Iwant	&= ~VS_m_UsrAttr ;
			} else {
				jnPart.usrAttr	= actJnUA ;
			}

			jnPart.usrAttr	= actJnUA ;
			jnDir = me->Cwd ;

			__DBGpr_obj(" Joint Between ",locElmnts[0]._grid );
			__DBGpr_obj(" ... and 	",locElmnts[1]._grid );

			sts = om$send(	msg = message VSfeature.VSputJoint(
								msg,
								&locElmnts[0].mod_env,
								locElmnts + 1,
								jnCurve ,
								me->ActiveRep.representation,
								&cst,
								jnDir,
								&joint ),
					targetid= locElmnts[0]._objid,
					targetos= locElmnts[0]._osnum );
			/*
			 * Do not go to wrapup. 
			 * Try placing all possible joints
			 */
			if( !( sts & *msg & 1 ) ) {
				__DBGpr_com( "VSfeature.VSputJoint Failed" );
				nrow++ ;
				continue ;
			}

			sts = om$send(	msg = message GRvg.GRgetname( 
								msg, 
								jnPathName ),
					targetid= joint.objid,
					targetos= joint.osnum ) ;

			if( ( sts & 1 & *msg ) && *jnPathName ) {
				ex$message( msgnumb = VS_gI_CreatedObj,
					    type    = "%s",
					    var     = `jnPathName` ) ;
			}

			vs$bulk_display( grids  = &joint, 
					 theEnv	= cst.env_info ) ;

			/* 
			 * Put db info 
			 */
		 	dbInfo.quantity   = VD_CKIN_STRUCT_JNT_OBJ;
		 	sts = om$send(msg = message ACdb_info.ACset_db_info(
							       msg,
							       &dbInfo),
			                targetid = joint.objid,
                 			targetos = joint.osnum);
			if( !( sts & *msg & 1 ) ) {
				__DBGpr_com( "ACdb_info.ACset_db_info Failed" );
				continue ;
			}
		}
		nrow++ ;
	}
	/*
	 * Delete all the selected rows from list that are being show for 
	 * set placement.
	 */
	if( form_label == 1 ) {
		int	totalRows = 0;
		int	delRows = 0;
		int 	num_rows = 1 ;

		FIfld_get_num_rows( form_ptr, PART_MCF, &totalRows ) ;

		j = 0 ;
		for( i = 0; i < totalRows ; i++ ) {

			FIfld_get_select( form_ptr, PART_MCF, i- delRows, 
						CODE_COL, &selFlag ) ;
			if( !selFlag ) {
				me->objList[j++] = me->objList[2*i] ;
				me->objList[j++] = me->objList[2*i+1] ;
			} else {
				FIfld_delete_rows( form_ptr, PART_MCF, 
							i - delRows, num_rows );
				delRows++ ;
			}
		}
		om$vla_set_dimension( 	varray 	= me->objList, 
					size 	= j ) ;

	}


wrapup :
	_FREE( jnCurve ) ;

	if( !( sts & 1 & *msg ) ) {
		om$send(msg	= message VSpartopCmd.setErrorStatus( *msg, 2 ),
			targetid= my_id ) ;
		me->ret = VS_K_RESTART_CMD ;
	} else {
		me->ret = VS_K_ACT_SUCCESS ;
	}
	End
	return OM_S_SUCCESS ;

}/* construct_joint */
/*----------------------------------------------------------------------------*/

end implementation VSplnjntCmd ;
