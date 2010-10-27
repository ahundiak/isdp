/* $Id: VDppl1.h,v 1.1.1.1 2001/01/04 21:07:30 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        include/VDppl1.h
 *
 * Description: Interface to ppl routines
 *
 * Dependencies:
 *
 * Revision History:
 * $Log: VDppl1.h,v $
 * Revision 1.1.1.1  2001/01/04 21:07:30  cvs
 * Initial import to CVS
 *
 * Revision 1.1  1998/10/25  11:58:30  pinnacle
 * ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 10/25/98  ah      creation
 ***************************************************************************/
#ifndef VDppl1_include
#define VDppl1_include

#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

/* ----------------------------------------
 * vdah/VDahPPL.I
 * PPL Interface
 */
#if defined(__cplusplus)
extern "C" {
#endif

extern IGRstat VDahPPL_Load __((
  IGRchar *pplName,   // I - PPL File Name
  TGRid   *pplID      // O - PPL objid
));

extern IGRstat VDahPPL_Run __((
  TGRid   *pplID,     // I - PPL objid (Existing)
  IGRchar *pplEntry,  // I - PPL Function Name
  IGRint  *pplVAL     // O - Return Value
));

extern IGRstat VDahPPL_IsEntryDefined __((
  TGRid   *pplID,     // I - PPL objid (Existing)
  IGRchar *pplEntry   // I - PPL Function Name
));

extern IGRstat VDahPPL_SetValue __((
  TGRid   *pplID,          // I - PPL objid (Existing)
  IGRchar *pplValueName,   // I - PPL Variable Name
  IGRint   pplValueSize,   // I - PPL Variable Size
  IGRchar *pplValuePtr     // I - PPL Variable Value
));

extern IGRstat VDahPPL_GetValue __((
  TGRid   *pplID,          // I - PPL objid (Existing)
  IGRchar *pplValueName,   // I - PPL Variable Name
  IGRint   pplValueSize,   // I - PPL Variable Size
  IGRchar *pplValuePtr     // I - PPL Variable Value
));

extern IGRstat VDahPPL_Delete __((
  TGRid *pplID        // I: Existing PPL Object
));

#if defined(__cplusplus)
}
#endif

/* --------------------------------------------------
 * Public interfaces
 */
#omdef vdppl$Load(name,pplID)
VDahPPL_Load((name),(pplID))
#endomdef

#omdef vdppl$Run(pplID,name=NULL,ret)
VDahPPL_Run((pplID),(name),(ret))
#endomdef

#omdef vdppl$GetData(pplID,name,size,data)
VDahPPL_GetValue((pplID),(name),(size),(data))
#endomdef

#omdef vdppl$SetData(pplID,name,size,data)
VDahPPL_SetValue((pplID),(name),(size),(data))
#endomdef

#omdef vdppl$Delete(pplID)
VDahPPL_Delete((pplID))
#endomdef

#omdef vdppl$IsEntryDefined(pplID,name)
VDahPPL_IsEntryDefined((pplID),(name))
#endomdef

#endif










