/* $Id: VDvalSpades.h,v 1.3 2001/06/22 15:00:37 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vds/include/VDvalSpades.h
 *
 * Description: Spades validation routines
 *
 * Dependencies: 
 *
 * Revision History:
 *      $Log: VDvalSpades.h,v $
 *      Revision 1.3  2001/06/22 15:00:37  ahundiak
 *      ah
 *
 *      Revision 1.2  2001/06/14 18:48:14  ahundiak
 *      ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 06/14/01  ah      Created
 ***************************************************************************/

#ifndef VDvalSpades_include
#define VDvalSpades_include

#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ---------------------------------------------
 * Nice structure for walking through the tree
 */
typedef struct 
{
  TGRid plateID;
  
  TGRid collID;
  
  TGRid drwGm2dID;
  TGRid drwGm3dID;

  IGRint macroFlag;
  
} TVDvalSpadesInfo;

extern IGRstat VDvalSpadesPlateAttributes   __((TGRid *plateID, void *info, IGRint *stopWalk));  
extern void    VDvalSpadesPlateOuterContour __((TGRid *plateID, void *info, IGRint *stopWalk));
extern void    VDvalSpadesPlateHole         __((TGRid *holeID,  void *info, IGRint *stopWalk));
extern void    VDvalSpadesPlaceXmlPlate     __((TGRid *plateID, void *data, IGRint *stopWalk));

extern void VDvalValidateSpadesFile __((IGRchar *fileName, IGRint useMacro, IGRint drawPoints));
  
/* ----------------------------------------------
 * Cleanup
 */
#if defined(__cplusplus)
}
#endif

#endif
