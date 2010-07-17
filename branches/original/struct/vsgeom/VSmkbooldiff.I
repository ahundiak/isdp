/* $Id: VSmkbooldiff.I,v 1.17 2002/02/26 23:39:06 ylong Exp $  */

/***************************************************************************
 * I/STRUCT
 *
 * File:        vsgeom/VSmkbooldiff.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VSmkbooldiff.I,v $
 *      Revision 1.17  2002/02/26 23:39:06  ylong
 *      etl#10175
 *
 *      Revision 1.16  2001/10/12 14:56:52  ylong
 *      fix for TR#5647 by Jayadev
 *
 *      Revision 1.15  2001/09/13 16:24:29  hans
 *      *** empty log message ***
 *
 *      Revision 1.14  2001/09/13 16:20:49  hans
 *      Fix for TR# MP5347
 *
 *      Revision 1.13  2001/08/25 18:31:06  jayadev
 *      changes for TR#MP5410
 *
 *      Revision 1.12  2001/04/19 16:50:40  jayadev
 *      *** empty log message ***
 *
 *      Revision 1.11  2001/04/19 16:42:45  jayadev
 *      *** empty log message ***
 *
 *      Revision 1.10  2001/04/19 16:23:16  jayadev
 *      args check added
 *
 *      Revision 1.9  2001/03/23 00:41:50  ad
 *      Remove requested print
 *
 *      Revision 1.8  2001/03/22 19:51:12  ad
 *      Reduce the number interactions and inform end user.
 *
 *      Revision 1.7  2001/03/20 19:26:13  jayadev
 *      No. of iterations reduced from 10 to 5
 *
 *      Revision 1.6  2001/03/14 00:50:38  jayadev
 *      boolean changes
 *
 *      Revision 1.5  2001/01/26 21:41:44  jayadev
 *      removing warnings
 *
 *      Revision 1.4  2001/01/26 21:32:28  jayadev
 *      scale factor modified
 *
 *      Revision 1.3  2001/01/25 22:01:35  jayadev
 *      boolean changes for etls#6025, 6090
 *
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTIO
 *      09/26/97        ah              added header
 *      09/26/97        ah		pathway variables
 *					file specific tolerances
 *      11/16/00        Jayadev         options added in EMSslboolean.EMboolean
 *					for etl#4231
 *      12/02/00        Jayadev         VSiterateBoolean if an operator fails to
 *					process operand in boolean operation
 *      01/25/00        Jayadev         Try with modified(divided by 10) cht on
 *					each boolean failure; scaleCurve scaled
 *					with cht now; used to be 100*bastol;
 *					no. of iterations made to 10
 *      06/25/01        Jayadev         scaling factor supplied for VSscaleCurve
 *      09/13/2001      HF              Fix for TR# MP5347
 *      10/12/01        Jayadev         TR# MP5647 - reduce range attempt by fix
 *                                      for TR# MP5347 is causing problems in the
 *                                      resulting boolean solid w.r.t named faces
 *                                      Fix for TR# MP5347 commented 
 *      02/26/02        Jayadev         etl#10175 - Beams disappearing on recompute
 *                                      EMSdpr.EMmake_primitive1() failure shouldnot
 *                                      delete the result of the boolean operation
 ***************************************************************************/

class implementation EMSslboolean ;

#include <stdlib.h>
#include "OMmacros.h"
#include "msdef.h"

#include "growner.h"
#include "grdpb.h"
#include "grdpbmacros.h"
#include "exmacros.h"

#include "ms.h"
#include "msmacros.h"
#include "emssfintdef.h"
#include "emsbool.h"
#include "msmacros.h"
#include "EMSmsgdef.h"
#include "ECmsg.h"
#include "emsmapdef.h"
#include "emsimpdef.h"
#include "vsglobalmsg.h"
#include "vsmiscmacros.h"
#include "vsgeommacros.h"
#include "vsdatamacros.h"
#include "vsdbgmacros.h"
#include "bsxtractpar.h"
#include "bsparameters.h"
/*
 * Includes of function prototypes.
 */
#include "vsioproto.h"

extern void	 VSresetObjidList() ;
extern long	 VSchgEMSseverity() ;
extern IGRdouble BSdistptpt();

extern OMuword		OPP_EMSslboolean_class_id,
			OPP_EMSsubbs_class_id ;
extern IGRboolean	ASbroadcast_in_progress ;

extern IGRboolean       _Pathway,_pathway_orient,_pathway_trim;

//static IGRboolean     shrink;
//static IGRint         listIndex;

#define	MAX_INTER	3


/*----------------------------------------------------------------------------*/
long VSmake_boolean_difference(	msg,
				optrCount,
				optrList,
				operand,
				resCst,
				compress,
				oneAtATime,
				result,
				refList,
				refCount,
				solidRange )
/*
 * This function is interfaced by macro vs$make_boolean_difference, #defined
 * in "vsgeommacros.h".
 */

long			*msg ;
int			optrCount,
			compress,
			oneAtATime ;
struct GRobj_env	optrList[],
			*operand ;
struct GRvg_construct	*resCst ;
struct GRid		*result ;
VSboolRef		*refList;
int			refCount;
GRrange			solidRange;
{
  int		        i,retSts ;	/* Loop index			*/
  long		        sts,     	/* OM return code		*/
                        msg1, rc ;	/* Return code of boolean op.	*/
  IGRboolean	        saveBroadcast ;	/* Save-broadcast flag		*/
  OM_S_OBJID	        *operator = NULL ;/* List of operators		*/
  struct GRmd_env	*cstEnv	;	/* Unburdens compiler		*/
  struct GRsymbology    symb ;
  struct GRobj_env      primOprnd;   /* primitive - fresh and uncut operand */
  int		        nbSuccesses = 0 ;
  OMbyte		*successes  = NULL ;
  unsigned short        option;
  IGRboolean            retryFlag = FALSE;
  double                originalBastol, originalChtol;

  // Save current pathway values
  IGRboolean pw_trim   = _pathway_trim;
  IGRboolean pw_orient = _pathway_orient;

  struct
  {
    int flag;
    double orgCht,orgBas;
    double newCht,newBas;
    double adjust;
  } tol;

  //args check
  if((optrCount == 0) || (optrList == NULL)) goto wrapup;

  // get the original value of chtol to put it back again at the end of
  // boolean operation

  gr$get_chord_height_tolerance(sizbuf = sizeof(originalChtol),
                                buffer = &originalChtol);

  tol.flag = VSgetVariableTolerance("VSboolDiff",&tol.adjust);
  if (tol.flag)
  {
    gr$get_chord_height_tolerance(sizbuf = sizeof(tol.orgCht),
                                  buffer = &tol.orgCht);
    tol.newCht = tol.orgCht * tol.adjust;
    gr$get_basis_tolerance(sizbuf = sizeof(tol.orgBas),
                           buffer = &tol.orgBas);
    tol.newBas = tol.orgBas * tol.adjust;
  }
  sts = OM_S_SUCCESS ;
  //shrink = 0;

  cstEnv = resCst->env_info ; result->objid = NULL_OBJID ;

  if(    !( operator  = _MALLOC( optrCount, OM_S_OBJID ) )
         || !( successes = _CALLOC( optrCount, OMbyte ) ) )
  {
    vs$mem_fail() ;
  }
  VSresetObjidList( optrCount, operator ) ;

  /*
   * We have to copy the input solid since they will be absorbed by the
   * boolean difference.
   */
  for( i = 0 ; i < optrCount ; i++ )
  {
    saveBroadcast = ASbroadcast_in_progress ;
    ASbroadcast_in_progress = TRUE ;

    sts = om$send(msg     = message GRgraphics.GRcopy( msg,
                                                             &optrList[i].mod_env,
                                                             cstEnv,
                                                             operator + i ),
                  senderid= optrList[i]._objid,
                  targetid= optrList[i]._objid,
                  targetos= optrList[i]._osnum ) ;
    ASbroadcast_in_progress = saveBroadcast ;

    if( vs$is_ancestry_valid( object	= &optrList[i]._grid,
                              classid	= OPP_EMSsubbs_class_id ) )
    {
      struct GRid	O ;

      /*
       * If we have got a surface, we must put some topology
       * on it (if it has none), otherwise its boundaries
       * will be kept in the boolean difference.
       */
      O.objid = operator[i] ;
      O.osnum = cstEnv->_MD_OS ;

      sts = vs$make_natural_boundary( msg        = msg,
                                      surfaceEnv = cstEnv,
                                      surfaceId  = &O ) ;
      __CheckRC( sts, *msg, "vs$make_natural_boundary", wrapup ) ;
    }
  }

  if( oneAtATime )
  {
    OM_S_OBJID	oprnd ;
    primOprnd = *operand;

    oprnd = operand->_objid ;

    for( i = 0 ; i < optrCount ; i++ )
    {
      __DBGpr_int("OPERATOR ",i);

      retryFlag = FALSE;
      result->osnum = cstEnv->_MD_OS ;
      *msg = EMS_E_OMerror ;
      sts = om$construct( classid = OPP_EMSslboolean_class_id,
                          osnum   = result->osnum,
                          p_objid = &result->objid ) ;
      __CheckRC( sts, 1, "om$construct", wrapup ) ;

      if (_Pathway)
      {
        _pathway_trim   = 1;
        _pathway_orient = 1;
      }
      if (tol.flag)
      {
        gr$put_chord_height_tolerance(sizbuf = sizeof(tol.newCht),
                                      buffer = &tol.newCht);
        gr$put_basis_tolerance       (sizbuf = sizeof(tol.newBas),
                                      buffer = &tol.newBas);
      }
      option =  EMSsfbool_opt_retryDisjoint | EMSsfbool_opt_noredraw |
                EMSsfbool_opt_doublecheck   | EMSsfbool_opt_HandleStop;
      /*
        _pathway_trim   = 1;
        _pathway_orient = 1;
      */
try_modCht:
      __DBGpr_com("Before EMSslboolean.EMboolean in main code ");
      sts = om$send(msg     = message EMSslboolean.EMboolean( &rc,
                                                              &cstEnv->_MATRIX_TYPE,
                                                              cstEnv->_MATRIX,
                                                              oprnd,
                                                              1,
                                                              operator + i,
                                                              resCst,
                                                              EMSbool_difference,
                                                              option,
                                                              VSmsgkey2string( VS_gI_Processing ),
                                                              NULL,
                                                              NULL,
                                                              NULL,
                                                              NULL ),
                    senderid= result->objid,
                    targetid= result->objid,
                    targetos= result->osnum ) ;
      __DBGpr_com("After EMSslboolean.EMboolean in main code ");

      // put back the original value of chtol
      if(retryFlag)
      {
        gr$put_chord_height_tolerance(sizbuf = sizeof(originalChtol),
                                      buffer = &originalChtol);
      }

      if (tol.flag)
      {
        gr$put_chord_height_tolerance(sizbuf = sizeof(tol.orgCht),
                                      buffer = &tol.orgCht);
        gr$put_basis_tolerance       (sizbuf = sizeof(tol.orgBas),
                                      buffer = &tol.orgBas);
      }

      if (_Pathway)
      {
        _pathway_trim   = pw_trim;
        _pathway_orient = pw_orient;
      }

      if((( EMS_I_NoIntersection == rc ) || (!(sts&1))) && (!retryFlag))
      {
        // not yet tried with new cht
        retryFlag = TRUE;
        gr$get_chord_height_tolerance(sizbuf = sizeof(tol.orgCht),
                                      buffer = &tol.orgCht);

        tol.newCht = 0.1 * tol.orgCht;  // try with reduced cht
        gr$put_chord_height_tolerance(sizbuf=sizeof(tol.newCht),
                                      buffer=&tol.newCht);
        __DBGpr_dbl("Try with finer chtol of ",tol.newCht);

        goto try_modCht;
      }

      /*
       * Skip those which fails...
       */
      if(( EMS_I_NoIntersection == rc ) || (!(sts&1)))
      {
        /* It is success to EMS but not to us!
         */
        vs$bulk_delete( grids = result,
                        theEnv= cstEnv ) ;

        __DBGpr_com(" Ordinary boolean failed - trying VSiterateBoolean() ");
        __DBGpr_int(" refCount ",refCount);

        if((refList!=NULL) && (refCount > 0))
        {
          retSts = VSiterateBoolean(&primOprnd,&oprnd,refList,
                                    refCount,&optrList[i],resCst,solidRange);
          if(retSts&1)
          {
            // oprnd already updated with latest result in VSiterateBoolean

            __DBGpr_com(" VSiterateBoolean succeeded ");

            successes[i] = FALSE ; // to delete the operator copy in the end
            nbSuccesses++ ;
          }
          else
          {
            /*
	      __DBGpr_com(" VSiterateBoolean failed with curve expansion ");
	      __DBGpr_com(" Trying VSiterateBoolean with curve shrinking ");

	      // this is a very risky affair
	      shrink = 1;
	      refList[listIndex].nb_iter = 0;
	      retSts = VSiterateBoolean(&primOprnd,&oprnd,refList,
	                                refCount,&optrList[i],resCst,solidRange);
	      if(retSts&1)
	      {
	      // oprnd already updated with latest result in VSiterateBoolean

	      __DBGpr_com(" VSiterateBoolean succeeded with curve shrinking ");

	      successes[i] = FALSE ; // to delete the operator copy in the end
	      nbSuccesses++ ;
	      }
            */
          }
        }
        if( optrCount - 1 == i )
        {
	  /* Set the last result to the previous
	   * result (now stored in `oprnd').
	   */
	  if( nbSuccesses )
          {
	    result->objid = oprnd ;
	    *msg = MSSUCC ;
	  }
          else
          {
	    *msg = MSFAIL ;
	  }
	}
      }
      else
      {
        __DBGpr_com(" VSchgEMSseverity() ");

        *msg = VSchgEMSseverity( rc ) ;
        if( sts & 1 & *msg )
        {
        /******* commented for TR# MP5647 **************
         *
         *
          struct GRid save_result = *result;
          // HF: 09/13/2001 - Fix for TR# MP5347
          if ( optrCount > 1 && i < optrCount - 1 )
          {
            sts = VDreduce_range(&msg1, cstEnv, &save_result, solidRange);
            if(!(sts&msg1&1))
            {
              __DBGpr_com(" VSreduce_range FAILED ");
            }
            else
            {
              *result = save_result;
            }
          }
         *
         *
         ***********************************************/
          oprnd = result->objid ;
          successes[i] = TRUE ;
          nbSuccesses++ ;
        }
        else
        {
          /*  Failure -- Rama Rao TR#179700166 */
          vs$bulk_delete( grids = result,
                          theEnv= cstEnv ) ;
          if( optrCount - 1 == i )
          {
            /* Set the last result to the previous
             * result (now stored in `oprnd').
             */
            if( nbSuccesses )
            {
              result->objid = oprnd ;
              *msg = MSSUCC ;
            }
            else
            {
              *msg = MSFAIL ;
            }
          }
        }
      }
    }
    *msg = nbSuccesses ? MSSUCC : MSFAIL ;
    sts = OM_S_SUCCESS ;
  }
  else
  {
    result->osnum = cstEnv->_MD_OS ;
    *msg = EMS_E_OMerror ;
    sts = om$construct(	classid = OPP_EMSslboolean_class_id,
                        osnum	= result->osnum,
                        p_objid = &result->objid ) ;
    __CheckRC( sts, 1, "om$construct( EMSslboolean )", wrapup ) ;

    if (_Pathway)
    {
      _pathway_trim   = 1;
      _pathway_orient = 1;
    }
    if (tol.flag)
    {
      gr$put_chord_height_tolerance(sizbuf=sizeof(tol.newCht),
                                    buffer=&tol.newCht);
      gr$put_basis_tolerance       (sizbuf=sizeof(tol.newBas),
                                    buffer=&tol.newBas);
    }
    sts = om$send(msg     = message EMSslboolean.EMboolean(
	                                  &rc,
	                                  &cstEnv->_MATRIX_TYPE,
	                                  cstEnv->_MATRIX,
	                        	  operand->_objid,
					  optrCount,
					  operator,
					  resCst,
					  EMSbool_difference,
					  EMSsfbool_opt_retryDisjoint,
					  VSmsgkey2string( VS_gI_Processing ),
					  NULL,
					  NULL,
					  NULL,
					  NULL ),
                  senderid= result->objid,
                  targetid= result->objid,
                  targetos= result->osnum ) ;
    if (tol.flag)
    {
      gr$put_chord_height_tolerance(sizbuf=sizeof(tol.orgCht),
                                    buffer=&tol.orgCht);
      gr$put_basis_tolerance       (sizbuf=sizeof(tol.orgBas),
                                    buffer=&tol.orgBas);
    }
    if (_Pathway)
    {
      _pathway_trim   = pw_trim;
      _pathway_orient = pw_orient;
    }
    *msg = VSchgEMSseverity( rc ) ;
  }

  if( !( sts & 1 & *msg ) )
  {
    /*
     * Caution: result may have absorbed operand.
     */
    if( rc & 1 )
    {
      long	RC ;
      om$send(msg      = message GRconnector.GRdisconn( &RC, result ),
              senderid = operand->_objid,
              targetid = operand->_objid,
              targetos = operand->_osnum ) ;
    }
    *msg = EMS_E_BoolFail ;
    goto wrapup ;
  }

  if( compress )
  {
    sts = om$send( msg     = message EMSdpr.EMmake_primitive1( msg, cstEnv, result ),
                   senderid= result->objid,
                   targetid= result->objid,
                   targetos= result->osnum );
    //__CheckRC( sts, *msg, "EMSdpr.EMmake_primitive1", wrapup ) ;
    if(!(sts&*msg&1))
    {
      __DBGpr_obj("EMSdpr.EMmake_primitive1 failed for:",*result);
      sts = *msg = 1;
    }
  }

  /*
   * For some reason, the intersection surfaces of the result of the
   * boolean solid take the color of the input solids. So let's reset
   * them.
   */
  symb.level        = resCst->level ;
  symb.display_attr = *resCst->display ;
  sts = om$send(msg	= message GRvg.GRputsymb( msg, &symb ),
                senderid= result->objid,
                targetid= result->objid,
                targetos= result->osnum ) ;

wrapup :
  ex$message( msgnumb = VS_gI_EmptyMessage ) ;

  if( !( sts & 1 & *msg ) )
  {
    /*
     * Delete result if constructed.
     */
    vs$bulk_delete(	count	= 1,
			grids	= result,
			theEnv	= cstEnv ) ;
    if( operator )
    {
      vs$bulk_delete(	count	= optrCount,
			objids	= operator,
			theEnv	= cstEnv ) ;

    }
  }
  else
  {
    /*
     * The parent solids will have been undisplayed when their
     * copies are undisplayed, since they are at the same locations.
     * Redisplay them.
     */
    vs$bulk_display(count	= optrCount,
                   objenvs	= optrList,
                   dpmode	= GRbd ) ;
    *msg = nbSuccesses == optrCount ? MSSUCC : EMS_I_Fail ;
    /*
     * If we have partrly succeeded, delete the objects which
     * have not beenn absorbed in the boolean difference.
     */
    for( i = 0 ; i < optrCount ; i++ )
    {
      if( !successes[i] )
      {
        vs$bulk_delete(	objids	= operator + i,
                        theEnv	= cstEnv ) ;
      }
    }
  }
  _FREE( operator  ) ;
  _FREE( successes ) ;

  return sts ;

} /* VSmake_boolean_difference */
/*----------------------------------------------------------------------------*/
IGRint VSiterateBoolean(struct GRobj_env      *oprndOld, // input operand
			GRobjid               *oprndNew, // resulting bool operand
			VSboolRef             *refList,
			IGRint    	      refCount,
			struct GRobj_env      *operator,
			struct GRvg_construct *resCst ,
			GRrange               solidRange )
{
  IGRint             i,retFlag = 0,delCount = 0;
  IGRint             retSts,listIndex;
  struct GRid        result,cvCopy;
  struct GRobj_env   curveObj,optrSolid,extCurve;
  struct GRobj_env   delList[500];
  IGRlong            sts,msg,rc;
  IGRboolean         optrFound = FALSE,retryFlag = FALSE;
  unsigned short     option;
  double             originalBastol, originalChtol;
  double             newBastol, newChtol;
  int                saveStyle ;

  // Save current pathway values
  IGRboolean pw_trim   = _pathway_trim;
  IGRboolean pw_orient = _pathway_orient;

  struct {
    int flag;
    double orgCht,orgBas;
    double newCht,newBas;
    double adjust;
  } tol;

  if((!oprndOld) || (!oprndNew) || (!refList) || (refCount == 0))
    goto wrapup;

  result.objid = NULL_OBJID;
  extCurve.obj_id.objid = NULL_OBJID;

  gr$get_chord_height_tolerance(sizbuf = sizeof(originalChtol),
				buffer = &originalChtol);

  tol.flag = VSgetVariableTolerance("VSboolDiff",&tol.adjust);
  if (tol.flag) {
    gr$get_chord_height_tolerance(sizbuf = sizeof(tol.orgCht),
				  buffer = &tol.orgCht);
    tol.newCht = tol.orgCht * tol.adjust;
    gr$get_basis_tolerance(sizbuf = sizeof(tol.orgBas),
			   buffer = &tol.orgBas);
    tol.newBas = tol.orgBas * tol.adjust;
  }


  /*
   * see if the operator solid is generated from a curve??
   * we have this information in the refList structure
   */
  for(i=0; i<refCount; i++)
  {
    if((refList[i].new.obj_id.objid == operator->obj_id.objid) &&
       (refList[i].new.obj_id.osnum == operator->obj_id.osnum))
    {
      if(refList[i].type == VS_K_blCurve)
      {
	curveObj  = refList[i].org;
	optrFound = TRUE;
	listIndex = i;
	break;
      }
    }

  }

  if(!optrFound) goto wrapup;

 try_again:

  retryFlag = FALSE;

  optrSolid.obj_id.objid = NULL_OBJID;
  extCurve.obj_id.objid = NULL_OBJID;

  retSts = VSscaleAndExtend(&curveObj,resCst,oprndOld,
                            &optrSolid,&extCurve, solidRange);
  if(!(retSts&1)) goto wrapup;
  if(optrSolid.obj_id.objid == NULL_OBJID) goto wrapup;
  if(extCurve.obj_id.objid == NULL_OBJID) goto wrapup;

  {
    curveObj = extCurve;
    delList[delCount] = extCurve;
    delCount ++;
  }
  __DBGpr_int("ITERATION NO. ",refList[listIndex].nb_iter);
  refList[listIndex].nb_iter ++;

 process_boolean:
  {
    result.osnum = resCst->env_info->_MD_OS ;
    msg = EMS_E_OMerror ;
    sts = om$construct(
                       classid = OPP_EMSslboolean_class_id,
                       osnum   = result.osnum,
                       p_objid = &result.objid ) ;
    __CheckRC( sts, 1, "om$construct", wrapup ) ;

    if (_Pathway) {
      _pathway_trim   = 1;
      _pathway_orient = 1;
    }
    if (tol.flag) {
      gr$put_chord_height_tolerance(sizbuf=sizeof(tol.newCht),
				    buffer=&tol.newCht);
      gr$put_basis_tolerance       (sizbuf=sizeof(tol.newBas),
				    buffer=&tol.newBas);
    }


    option =  EMSsfbool_opt_retryDisjoint | EMSsfbool_opt_noredraw |
              EMSsfbool_opt_doublecheck | EMSsfbool_opt_HandleStop;
    /*
      _pathway_trim   = 1;
      _pathway_orient = 1;
    */
  try_modCht1:
    __DBGpr_com("Before EMSslboolean.EMboolean in iteration code ");

    sts = om$send(	msg  = message EMSslboolean.EMboolean(
                                       &rc,
                                       &resCst->env_info->_MATRIX_TYPE,
                                       resCst->env_info->_MATRIX,
                                       *oprndNew,
				       1,
                                       &optrSolid.obj_id.objid,
                                       resCst,
                                       EMSbool_difference,
				       option,
				       VSmsgkey2string( VS_gI_Processing ),
				       NULL,
				       NULL,
				       NULL,
				       NULL ),
			senderid= result.objid,
			targetid= result.objid,
			targetos= result.osnum ) ;
    __DBGpr_com("After EMSslboolean.EMboolean in iteration code ");
    // put back the original value of chtol
    if(retryFlag)
    {
      gr$put_chord_height_tolerance(sizbuf=sizeof(originalChtol),
				    buffer=&originalChtol);
    }

    if (tol.flag) {
      gr$put_chord_height_tolerance(sizbuf=sizeof(tol.orgCht),
				    buffer=&tol.orgCht);
      gr$put_basis_tolerance(sizbuf=sizeof(tol.orgBas),
			     buffer=&tol.orgBas);
    }

    if (_Pathway) {
      _pathway_trim   = pw_trim;
      _pathway_orient = pw_orient;
    }

    if((( EMS_I_NoIntersection == rc ) || (!(sts&1))) && (!retryFlag)){
      // not yet tried with new cht
      retryFlag = TRUE;
      newChtol = 0.1 * originalChtol;  // try with reduced cht
      gr$put_chord_height_tolerance(sizbuf=sizeof(newChtol),
				    buffer=&newChtol);
      __DBGpr_dbl("Retrying boolean with finer chtol of ",newChtol);

      goto try_modCht1;
    }
    /*
     * Skip those which fails...
     */
    if( EMS_I_NoIntersection == rc ) {
      /* It is success to EMS but not to us!
       */
      vs$bulk_delete( grids = &result,
		      theEnv= resCst->env_info ) ;
      vs$bulk_delete( grids = &optrSolid.obj_id,
		      theEnv= resCst->env_info ) ;
      if(refList[listIndex].nb_iter > MAX_INTER ) goto wrapup;
      else goto try_again;
    }
    else {
      msg = VSchgEMSseverity( rc ) ;
      if( sts & 1 & msg ) {
	*oprndNew = result.objid ;
	retFlag = 1;
	goto wrapup;
      }
      else{
	vs$bulk_delete( grids = &result,
			theEnv= resCst->env_info ) ;
	vs$bulk_delete( grids = &optrSolid.obj_id,
			theEnv= resCst->env_info ) ;
	if(refList[listIndex].nb_iter > MAX_INTER ) goto wrapup;
	else goto try_again;
      }

    }
  }

 wrapup:
 vs$bulk_delete( count   = delCount,
	         objenvs = delList) ;

  __DBGpr_int(" VSiterateBoolean iteration ",refList[listIndex].nb_iter);
  __DBGpr_int(" VSiterateBoolean retFlag   ",retFlag);
  return retFlag;
}
// This function scales an input curve and generates a solid by extending it
IGRint VSscaleAndExtend(
                        struct GRobj_env      *curve,
			struct GRvg_construct *resCst,
			struct GRobj_env      *oprndSolid,
			struct GRobj_env      *optrSolid, // extended solid out
		        struct GRobj_env      *cvCopy,
			GRrange               solidRange
                       )
{
  IGRint      i,retFlag = 0,retSts;
  IGRlong     sts,msg,rc;
  int         saveStyle ;
  IGRdouble   scaleFact;

  cvCopy->obj_id.objid = NULL_OBJID;
  scaleFact            = 0.0;
    retSts = VSscaleCurve(&curve->obj_id,&curve->mod_env,
         		  resCst,&cvCopy->obj_id, scaleFact);
    if((!(retSts&1)) || (cvCopy->obj_id.objid == NULL_OBJID))
    {
      goto wrapup;
    }

  // make a penetrating cylinder out of the scaled curve
  saveStyle           = resCst->display->style ;
  resCst->display->style  = 3 ;
  optrSolid->obj_id.objid = NULL_OBJID;

  optrSolid->mod_env = *resCst->env_info;
  cvCopy->mod_env    = *resCst->env_info;

  sts = VSmakePenetratingCyl( &msg,
			      &oprndSolid->obj_id,
			      &oprndSolid->mod_env,
			      &cvCopy->obj_id,
			      resCst->env_info,
			      resCst,
			      &optrSolid->obj_id ,
			      solidRange ) ;
  resCst->display->style  = saveStyle ;
  if( !( sts & 1 & msg ) ) goto wrapup ;
  if(optrSolid->obj_id.objid == NULL_OBJID) goto wrapup;

  retFlag = 1;
 wrapup:

  __DBGpr_int(" VSscaleAndExtend retFlag ",retFlag);
  return retFlag;
}
/*----------------------------------------------------------------------------*/
/* This function gets the range points of the curve and scales it based on the
 * midpoint of the range points as the scaling cs origin. It returns a copy of
 * the scaled curve; the scale factor is the ratio of the range diagonal length
 * and 10times bastol added to the same
 */
IGRint VSscaleCurve(
                    struct GRid           *cvId,
		    struct GRmd_env       *cvEnv,
		    struct GRvg_construct *cst,
		    struct GRid           *cvCopy,       // copy scale curve
                    IGRdouble             scaleFactor    // optional scale factor
                   )
{
  IGRint 		  retFlag = 0,i;
  GRrange		  cvRng;
  IGRdouble               chtol = 0.1;
  IGRdouble               scale = 1.0,dist,distNew;
  IGRmatrix               st_ref,end_ref,trans_matrix,tmp_matrix;
  short            	  mat_type;
  short            	  four;
  IGRchar          	  debugfile[50];
  struct GRobj_env 	  debugOE;
  long           	  sts ,stat,msg;
  IGRboolean      	  world = TRUE ;  /* For GRgetrang */
  IGRpoint                midPoint;
  GRobjid		  dummy;

  sts = om$send(  msg     = message GRgraphics.GRgetrang(
                                    &msg,
                                    &cvEnv->_MATRIX_TYPE,
                                    cvEnv->_MATRIX,
                                    &world,
                                    cvRng ),
		  senderid= NULL_OBJID,
		  targetid= cvId->objid,
		  targetos= cvId->osnum ) ;
  if( !( sts & 1 & msg ) )
  {
    __DBGpr_obj(" GRgraphics.GRgetrang failed for ",*cvId);
    goto wrapup ;
  }
  // copy the curve
  cvCopy->osnum = cst->env_info->md_id.osnum;

  stat = om$send( msg = message GRgraphics.GRcopy(&msg,
						  cvEnv,
						  cst->env_info,
						  &cvCopy->objid ),
		  senderid = NULL_OBJID,
		  targetid = cvId->objid,
		  targetos = cvId->osnum  );
  if(!(stat&msg&1)){
    printf("\n GRgraphics.GRcopy failed inside VSscaleCurve()\n");
    goto wrapup;
  }

  __DBGpr_obj(" cvCopy ",*cvCopy);
  __DBGpr_vec("cvRng[0] ",cvRng);
  __DBGpr_vec("cvRng[1] ",&cvRng[3]);

  for( i = 0 ; i < 3 ; i++ )
    midPoint[i] = (cvRng[i]+cvRng[i+3])*0.5;
  __DBGpr_vec(" midpoint ",midPoint);

  for( i = 0 ; i < 16 ; i++ ) { st_ref[i] = end_ref[i] = 0.0;}

  st_ref[0] = end_ref[0] = 1.0;
  st_ref[5] = end_ref[5] = 1.0;
  st_ref[10] = end_ref[10] = 1.0;
  st_ref[15] = end_ref[15] = 1.0;

  // fill the translation part of the matrices
  for( i = 0 ; i < 3 ; i++ )
    st_ref[i+3*(i+1)] = end_ref[i+3*(i+1)] = midPoint[i];

  dist = BSdistptpt( &msg, midPoint, &cvRng[3] );
  __DBGpr_dbl("half of range diagonal length ",dist);

  BSxtractpar(&msg, BSTOLCHRDHT, &chtol );
  __DBGpr_dbl(" chtol ",chtol);

  distNew = dist+(4*chtol);

  __DBGpr_dbl(" dist ",dist);
  __DBGpr_dbl(" distNew ",distNew);

  /*
    if(!shrink) scale   = (double)(distNew/dist);
    else        scale   = (double)(dist/distNew);
  */
  if(scaleFactor == 0.0) scale   = (double)(distNew/dist);
  else                   scale   = scaleFactor;
  __DBGpr_dbl(" scale ",scale);

  four = 4;
  for( i=0;i<12;i=i+4){
    st_ref[i]  = st_ref[i]  / scale;
    st_ref[i+1]  = st_ref[i+1]  / scale;
    st_ref[i+2] = st_ref[i+2] / scale;
  }
  MAinvmx(&msg,&four,st_ref,tmp_matrix);
  MAmulmx(&msg,&four,&four,&four,end_ref,tmp_matrix,trans_matrix);
  MAtypemx(&msg,trans_matrix,&mat_type);

  stat = om$send(msg= message GRgraphics.GRxform(&msg,
						 cst->env_info,
						 &mat_type,
						 trans_matrix,
						 &dummy ),
		 senderid = NULL_OBJID,
		 targetid = cvCopy->objid,
		 targetos = cvCopy->osnum  );

  if( !( stat&msg&1)){

    __DBGpr_com( " GRgraphics.GRxform error " );

    om$send(msg = message GRgraphics.GRdelete(&msg,cst->env_info),
	    senderid = NULL_OBJID,
	    targetid = cvCopy->objid,
	    targetos = cvCopy->osnum );
    goto wrapup;
  }
  retFlag = 1;
 wrapup:

  __DBGpr_obj(" cvCopy ",*cvCopy);
  __DBGpr_int(" VSscaleCurve retFlag ",retFlag );

  return retFlag;
}
end implementation EMSslboolean ;



