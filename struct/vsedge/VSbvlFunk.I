/* $Id: VSbvlFunk.I,v 1.3 2001/06/01 19:52:16 ramarao Exp $  */
/* --------------------------------------------------------------------
 * I/STRUCT
 *
 * File:        struct/vsedge/VSbvlFunk.I
 *
 * Description: Function to place Multiple "two-plate" bevels.
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VSbvlFunk.I,v $
 *      Revision 1.3  2001/06/01 19:52:16  ramarao
 *      Fixed TR# 5284.
 *
 *      Revision 1.2  2001/05/14 15:29:25  ramarao
 *      Fixed TR# 5009.
 *
 *      Revision 1.1  2001/04/17 17:09:50  ramarao
 *      Fixed CR# 5016.
 *
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *      04/17/01        Rama Rao        File Creation.
 * -------------------------------------------------------------------*/

class implementation VDSroot;

#include "VDobj.h"
#include "VDfrm.h"
#include "VDmem.h"
#include "v_geommacros.h"
#include "VSbevel.h"
#include "vsdbgmacros.h"

static IGRint  VScreateBevel( Form                    form,
                              struct GRobj_env        *objOEs,
                              IGRchar                 *lblPntFlag,
			      struct GRobj_env        *bvlMacOE    )
{
BSrc				rc;
IGRlong				sts, msg;
IGRint				retFlag=0;
IGRdouble			offsetVal;
IGRchar				msgStr[128];
struct GRobj_env		bvlCrvOE;
struct IGRbsp_curve		*bvlCrv=NULL;

   if( ObjsIdentical( objOEs[EDGE1].obj_id, objOEs[EDGE2].obj_id) ) 
   {
        gr$get_module_env (buffer = &objOEs[EDGE2].mod_env);
        vd_$grCopy( msg     = &msg ,
                    frObj   = &objOEs[EDGE1].obj_id ,
                    frEnv   = &objOEs[EDGE1].mod_env ,
                    toEnv   = &objOEs[EDGE2].mod_env ,
                    toObj   = &objOEs[EDGE2].obj_id ) ;
        if( !(msg&1) ) 
        {
            printf("vd_$grCopy failed\n") ;
            goto wrapup ;
        }
   }

   // Get bevel curve to compute label points if user not input point
   if ( lblPntFlag[0] == '0' || lblPntFlag[1] == '0' ) 
   {
        sts = ConstructBevel( &objOEs[EDGE1],
                              &objOEs[EDGE2],
                              &bvlCrvOE,
                              &bvlCrv ) ;
        if( !sts || bvlCrvOE.obj_id.objid == NULL_OBJID) 
	{
             printf("ConstructBevel failed\n") ;
                     strcpy(msgStr,
                     "Edges or plates may not adjoin within tolerance");
             objOEs[EDGE1].obj_id.objid = NULL_OBJID ;
             objOEs[EDGE2].obj_id.objid = NULL_OBJID ;
             goto wrapup ;
        }
        // Delete bvlCrvOE, since we only need bvCrv so far and
        // bvlCrvOE will be built in macro as macro input
        vdobj$Delete( objOE = &bvlCrvOE ) ;
        bvlCrvOE.obj_id.objid  = NULL_OBJID ;
   }

   // Get offset value
   FIg_get_value( form, OFFSET_VALUE, &offsetVal ) ;

   if( lblPntFlag[0] == '0' ) 
   {
        sts = GetLabelPoint( &objOEs[PLATE1],
                             bvlCrv,
                             offsetVal,
                             &objOEs[POINT1] ) ;
        if( !sts ) 
	{
              printf("GetLabelPoint() failed\n") ;
              goto wrapup ;
       }
        __DBGpr_obj("objOEs[POINT1]", objOEs[POINT1].obj_id);
   }

   if( lblPntFlag[1] == '0' ) 
   {
       sts = GetLabelPoint( &objOEs[PLATE2],
                            bvlCrv,
                            -offsetVal,
                            &objOEs[POINT2] ) ;
       if( !sts ) 
       {
             printf("GetLabelPoint() failed\n") ;
             goto wrapup ;
       }
       __DBGpr_obj("objOEs[POINT2]", objOEs[POINT2].obj_id);
   }


   sts = CreateBevelMacro("Bevel",objOEs,MAX_TEMP2,lblPntFlag,bvlMacOE);
   if( !sts || bvlMacOE->obj_id.objid == NULL_OBJID ) 
   {
       printf("CreateBevelMacro() failed\n");
       goto wrapup ;
   }
   __DBGpr_obj("bvlMacOE", bvlMacOE->obj_id);

   retFlag = 0;

wrapup:
  _FREE( bvlCrv ) ;
  return retFlag;
}

IGRlong	VScreateMultipleBevels( Form            	form,
				struct GRobj_env	*objOEs,
				IGRchar         	*lblPntFlag,
				IGRint			edgCnt1,
				struct GRobj_env        *edgOEs1,
                                IGRint                  edgCnt2,
                                struct GRobj_env        *edgOEs2   )
{
IGRint			i, j;
IGRboolean		first_overlap=TRUE, overlap=FALSE;
struct GRobj_env	bvlMacOE;

   for( i = 0; i < edgCnt1; i = i+1 ) 
   {
       for( j = 0; j < edgCnt2; j = j+1 ) 
       {
          overlap = Get2crvsOverlap( &edgOEs1[i],
                                     &edgOEs2[j],
				     NULL	   );
          if( overlap ) 
	  {
	      if( first_overlap == TRUE ) first_overlap = FALSE;
	      else
	      {
		 objOEs[EDGE1] = edgOEs1[i];
		 objOEs[EDGE2] = edgOEs2[j];

		 VScreateBevel( form, objOEs, lblPntFlag, &bvlMacOE );
	      }
          }
      }
   }
}

end implementation VDSroot;
