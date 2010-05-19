/* $Id: VDxdom.h,v 1.4 2001/11/16 14:25:43 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vds/include/VDxdom.h
 *
 * Description: Public isdp interface to xdom objects
 *
 * Dependencies: 
 *
 * Revision History:
 *      $Log: VDxdom.h,v $
 *      Revision 1.4  2001/11/16 14:25:43  ahundiak
 *      ah
 *
 *      Revision 1.3  2001/11/09 14:17:55  ahundiak
 *      ah
 *
 *      Revision 1.2  2001/09/20 14:36:44  ahundiak
 *      ah
 *
 *      Revision 1.1  2001/08/24 19:58:34  ahundiak
 *      ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 05/14/01  ah      Created
 ***************************************************************************/

#ifndef VDxdom_include
#define VDxdom_include

#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

extern void VDxdomCreateTreeFromXmlFile __((IGRchar *xmlFileName, TGRid *treeID));
extern void VDxdomCreateTreeFromXmlBuf  __((IGRchar *xmlBuf,      TGRid *treeID));
extern void VDxdomCreateTreeFromWebFile __((IGRchar *server, IGRchar *fileName, TGRid *treeID));

extern void VDxdomCreateRootFromXmlFile __((IGRchar *xmlFileName, TGRid *treeID));
extern void VDxdomCreateRootFromXmlBuf  __((IGRchar *xmlBuf,      TGRid *treeID));

extern void VDxdomSaveTreeToXmlFile __((TGRid *treeID, IGRchar *fileName));
extern void VDxdomSaveTreeToXmlBuf  __((TGRid *treeID, IGRchar **bufXml));
  
extern void VDxdomDeleteNode            __((TGRid *nodeID));

extern void VDxdomCreateNode __((TGRid *parentID, IGRchar *eleName, TGRid *nodeID));
extern void VDxdomCreateTree __((                 IGRchar *eleName, TGRid *treeID));

/* ----------------------------------------------
 * Style sheet processing
 */
extern void VDxdomCreateStyleSheetFromFile __((IGRchar *fileName, TGRid *styleSheetID));
  
extern void VDxdomDeleteStyleSheet __((TGRid *styleSheetID));  

extern void VDxdomApplyStyleSheet  __((TGRid *styleSheetID, TGRid *treeID, IGRchar *params[], TGRid *resID));
  

#if defined(__cplusplus)
}
#endif

#endif
