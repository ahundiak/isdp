/* $Id: VDvalConv.h,v 1.4 2002/03/08 17:00:14 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vds/include/VDvalConv.h
 *
 * Description: Convert to dom protos for clients
 *
 * Dependencies: 
 *
 * Revision History:
 *      $Log: VDvalConv.h,v $
 *      Revision 1.4  2002/03/08 17:00:14  ahundiak
 *      ah
 *
 *      Revision 1.3  2001/11/16 14:25:43  ahundiak
 *      ah
 *
 *      Revision 1.2  2001/11/09 18:10:13  ahundiak
 *      ah
 *
 *      Revision 1.1  2001/11/09 15:36:57  ahundiak
 *      ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 11/09/01  ah      Created
 ***************************************************************************/

#ifndef VDvalConv_include
#define VDvalConv_include

/* ----------------------------------------------
 * Usual header
 */
#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

    
/* ----------------------------------------------
 * vdval/om/VDvalGenPiece.c
 */
extern IGRstat VDvalConvertPieceToDom __((TGRobj_env *pieceOE, 
					  TGRid      *parentID, 
					  TGRid      *domID,
					  IGRint     *errCnt,
					  IGRint      wantFlag));

#define VDVAL_DOM_WANT_MIN  1
#define VDVAL_DOM_WANT_MED  2
#define VDVAL_DOM_WANT_GEOM 3
#define VDVAL_DOM_WANT_ALL  9

/* ----------------------------------------------
 * vdval/om/VDvalPiece.c
 */
extern IGRstat VDvalAddBeamAttributes  __((TGRobj_env *modelOE, TGRid *pieceID, IGRint *errCnt, IGRint wantFlag));
extern IGRstat VDvalAddPlateAttributes __((TGRobj_env *modelOE, TGRid *pieceID, IGRint *errCnt, IGRint wantFlag));
extern IGRstat VDvalAddPieceAttributes __((TGRobj_env *modelOE, TGRid *pieceID, IGRint *errCnt, IGRint wantFlag));

extern IGRstat VDvalAddBevelAttributes __((TGRobj_env *modelOE, TGRid *pieceID, IGRint *errCnt, IGRint wantFlag));
extern IGRstat VDvalAddPenAttributes   __((TGRobj_env *modelOE, TGRid *pieceID, IGRint *errCnt, IGRint wantFlag));

/* ----------------------------------------------
 * vdval/om/VDvalGenEqp.I
 */
extern IGRstat VDvalConvertEqpToDom __((TGRobj_env *pieceOE, 
					TGRid      *parentID, 
					TGRid      *domID));

/* ----------------------------------------------
 * vvval/om/VDvalGenComp.I
 */
extern IGRstat VDvalConvertComponentToDom __((TGRobj_env *pieceOE, 
					      TGRid      *parentID, 
					      TGRid      *domID));
  
/* ----------------------------------------------
 * vrval/om/VRvalGenNoz.I
 */
extern IGRstat VRvalConvertNozToDom __((TGRobj_env *nozOE, TGRid *parentID, TGRid *nozID));

/* ----------------------------------------------
 * vrval/om/VRvalGenCpt.I
 */
extern IGRstat VRvalConvertCptToDom __((TGRobj_env *genericOE, TGRid *parentID, TGRid *cptsID));


/* ----------------------------------------------
 * Cleanup
 */
#if defined(__cplusplus)
}
#endif

#endif

