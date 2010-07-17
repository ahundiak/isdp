class implementation VLedge2Datt;

#include <stdio.h>
#include "growner.h"
#include        "AS_status.h"
#include        "grmacros.h"
#include        "bsparameters.h"
#include        "DIdef.h"
#include        "expression.h"
#include        "expmacros.h"
#include        "exmacros.h"
#include        "msmacros.h"
#include        "msdef.h"
#include        "bserr.h"
#include        "bstypes.h"
#include	"vlmsg.h"

#define  MACRO_NAME    "edge2D_att" /* Name of the macro    		*/
#define  MAX_TEMP      3            /* Number of template of the macro	*/
#define  MAX_FEET      1            /* Number of feet of the macro      */


extern void 		BScveval();
extern GRclassid	OPP_GR3dpoint_class_id;

/* ========================================================================= */

long constructEdge2D(list,fcount,feet_list,md_env)
struct GRid		*list;
int			*fcount;
struct GRid		*feet_list;
struct GRmd_env		*md_env;
{
struct	GRid		AsTemp;
struct	GRobj_env	GoTemp;
struct  IGRbsp_curve	*cv;
	IGRdouble	pt[3];
struct	IGRpolyline	poly;	
long			msg,stat,OMsts;
struct  GRvg_construct  cst;
int			tmp;


  msg = MSFAIL;
  *fcount = 1;
  AsTemp = list[2];
  OMsts = om$send( msg      = message NDmacro.ACreturn_foot(	
					&stat ,
					"",
					&GoTemp.obj_id, 
					&GoTemp.mod_env.md_env.matrix_type, 
					GoTemp.mod_env.md_env.matrix ),
	         senderid = NULL_OBJID,
	         targetid = AsTemp.objid,
	         targetos = AsTemp.osnum );
  if(!(OMsts&stat&1)){
	printf("Error in edge2D_att\n");
	printf("Error in NDmacro.ACreturn_foot for second template\n");
	goto wrapup;
  }

  GoTemp.mod_env.md_id.osnum = GoTemp.obj_id.osnum;


  /*c retrieve the bsgeometry */

  OMsts = om$send(msg = message GRvg.GRgenabsg(
					&stat,
					&GoTemp.mod_env.md_env.matrix_type,
					GoTemp.mod_env.md_env.matrix,
                       			(IGRchar **)&cv ),
	     senderid = NULL_OBJID,
 	     targetid = GoTemp.obj_id.objid,
	     targetos = GoTemp.obj_id.osnum );

  if(!(OMsts&stat&1)){
	printf("Error in edge2D_att\n");
	printf("Error in GRvg.GRgenabsg for second template\n");
	goto wrapup;
  }

  /*c evaluate a point just to be able to locate it */
  BScveval( cv, .15, 0, pt, &stat);
  VLinitCnst(&cst);
  cst.geometry            = (char *)&poly;
  /*c construct the point */
  poly.num_points = 1;
  poly.points     = pt;

  feet_list[0].osnum = md_env->md_id.osnum;
  OMsts = om$construct( classid = OPP_GR3dpoint_class_id,
                        osnum   = feet_list[0].osnum,
                        p_objid = &feet_list[0].objid );
  if(!(OMsts&1)){
	printf("Error in edge2D_att\n");
	feet_list[0].objid = NULL_OBJID;
	goto wrapup;
  }
  tmp = cst.display->weight;
  cst.display->weight = 3;
  OMsts = om$send(msg      = message GRgraphics.GRaltconstruct(&cst),
      	          senderid = NULL_OBJID,
      	          targetid = feet_list[0].objid,
	  	  targetos = feet_list[0].osnum );
  cst.display->weight = tmp;
  if(!(OMsts&1)){
	printf("Error in edge2D_att\n");
	printf("Error in GR3dpoint.GRaltconstruct\n");
	feet_list[0].objid = NULL_OBJID;
	goto wrapup;
  }
  *fcount = 1;
  msg = MSSUCC;
wrapup :
 return msg;
}

/* ========================================================================= */
method ACconstruct_feet (               IGRlong         *msg;
                                        IGRint          cn_type;
                                        IGRint          count;
                         struct         GRid            list[];
                         struct         GRmd_env        *md_env;
                                        IGRint          *fcount;
                         struct         GRid            *feet_list )
{
long	sts;

  *msg = MSFAIL;
  if (!md_env || !list || !fcount || !feet_list ) goto wrapup;
  *fcount = 0;

  sts = constructEdge2D(list,fcount,feet_list,md_env);
  if (!(sts&1)) {
    printf("MAUVAIS\n");
    goto wrapup;
  } 
  *msg = MSSUCC;
wrapup :
  return 1;
}

method VDgetObjDef( long *msg ; VDobjDef *myDef ) {

        long            sts ;   /* OM return code       */

        /*
         * name.
         */
        myDef->info             = VL_I_Obj2DEdgeAtt;
        myDef->type             = 0 ;

        sts     = OM_S_SUCCESS ;
        *msg    = MSSUCC ;

        return sts ;
} /* method VDgetObjdDef */
/*----------------------------------------------------------------------------*/

end implementation VLedge2Datt;
