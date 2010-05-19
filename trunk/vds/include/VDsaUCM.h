/* $Id: VDsaUCM.h,v 1.1 2001/01/10 16:11:30 art Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        include/VDsaUCM.h
 *
 * Description: Structure data transfer from .u to .I files
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDsaUCM.h,v $
 *      Revision 1.1  2001/01/10 16:11:30  art
 *      sp merge
 *
 * Revision 1.1  2000/10/06  20:40:42  pinnacle
 * initial revision
 *

 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 09/27/00  pn      Creation
 * 01/10/01  ah      sp merge
 ***************************************************************************/

#ifndef VDsaUCM_include
#define VDsaUCM_include

/***************************************************************************
 * Structure Definition for data transfer to and from the PPL  
 **************************************************************************/
typedef struct
{
  TGRid nodeID;
  TGRid saID;
  TGRid psaID;
  TGRid unitID;
  TGRid psuID;
  TGRid cpsuID;
  TGRid pmID;
  TGRid safID;
  TGRid samID;
  TGRid saeID;

  TGRobj_env modelOE;
} NameData;

typedef struct
{
  IGRstat lookupCount;
  IGRstat searchCount;
  IGRstat clearCount;
  IGRstat callCount;
} OpCnt;


// ***************  prototypes  of functions **********************
// included from VDsaUCM.I for PPL access
extern IGRstat VDsaLookupExpID(TGRid *nodeID);
extern IGRstat VDatGetNodeName();
extern IGRstat VDatGetNodeType();
extern IGRstat VDatGetSetType();


extern IGRstat VDsaPrintNameDT __((IGRchar *title));
#omdef vdsa$PrintNameDT(title = NULL)
VDsaPrintNameDT((title))
#endomdef

extern IGRstat VDsaGetNameDTData __((TGRid *nodeID,
                                     TGRid *pmID,
                                     TGRid *saID,
                                     TGRid *psuID,
                                     TGRid *cpsuID,
                                     TGRid *unitID,
                                     TGRid *saeID,
                                     TGRid *safID,
                                     TGRid *samID,
                                     TGRid *psaID,
                                     TGRobj_env *modelOE));

#omdef vdsa$GetNameDTData(nodeID = NULL,
                          pmID    = NULL,
                          saID    = NULL, 
                          psuID   = NULL,
                          cpsuID  = NULL,
                          unitID  = NULL,
                          saeID   = NULL,
                          safID   = NULL,
                          samID   = NULL,
                          psaID   = NULL,
                          modelOE = NULL)

VDsaGetNameDTData((nodeID),
                  (pmID),
                  (saID),
                  (psuID),
                  (cpsuID),
                  (unitID),
                  (saeID),
                  (safID),
                  (samID),
                  (psaID),
                  (modelOE))
#endomdef

// ************** end prototypes of functions *********************



#endif
