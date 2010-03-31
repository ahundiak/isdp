class implementation Root;

#include <stdio.h>
#include "igrtypedef.h"
#include "igrdef.h"
#include "igr.h"
#include "igetypedef.h"
#include "gr.h"
#include "OMerrordef.h"
#include "EMSmsgdef.h"
#include "EMSprop.h"
#include "emsedgedef.h"
#include "EMSlcdef.h"
#include "EMSopt.h"

%safe
static void prtCvinfo();
static void prtCvType();
%endsafe

struct prtInfo{
IGRuchar cvType;
union {
    struct IGRbsp_curve poleInfo;
    struct IGRarc arcInfo;
    }cvInfo;
};
   
from EMSedge import EMget_props_type, EMget_bcxyz_geom,
                    EMgetxyzobj, EMset_props;
from GRconic import GRgetarc;
from GRgraphics import GRdelete;

IGRlong prtEdInfo (reportFile,
                   edId, edOs,
                   mdEnv)
FILE *reportFile;
GRobjid edId;
OMuword edOs;
struct GRmd_env *mdEnv;
{
	IGRlong msg = EMS_S_Success, 
                OM_stat = OM_S_SUCCESS;
	IGRuchar edcvType;
        IGRushort edProps, mscExists;
        struct prtInfo edGeom;

	OM_stat = om$send(msg = message EMSedge.EMget_props_type(
                                        &msg, &edProps, &edcvType),
                  targetid = edId,
                  targetos = edOs,
                  senderid = NULL_OBJID);
        if (!(1 & OM_stat)) goto wrapup;

        mscExists = edProps & EMED_MSCEXISTS;
         
	prtCvType(reportFile, edcvType);
        fprintf(reportFile, "\n Object id : %d ", edId);
       
        /* ????????????????????????????*/

        fprintf(reportFile, "\n Element Name : ");

        edGeom.cvType = edcvType;

        switch (edcvType) {

              case EMlinestring :
              case EMlinesegment :
              case EMfreeform_curve :
              {
                   edGeom.cvInfo.poleInfo.poles = NULL;
                   edGeom.cvInfo.poleInfo.weights = NULL;
                   edGeom.cvInfo.poleInfo.knots = NULL;
                   edGeom.cvInfo.poleInfo.bdrys = NULL;

                   OM_stat = om$send(msg = message EMSedge.EMget_bcxyz_geom (
                                              &msg, &mdEnv->md_env, NULL, NULL,
                                              0, OM_K_MAXINT, FALSE, NULL,
                                              &(edGeom.cvInfo.poleInfo)),
                             targetid = edId,
                             targetos = edOs,
                             senderid = NULL_OBJID);
                   if (!(1 & OM_stat)) goto wrapup;
                 
                   break;
  
              }
              case EMcircular_arc :
              case EMcircle :
              case EMelliptical_arc :
              case EMellipse :
              {
                   GRobjid xyzObj;

                   OM_stat = om$send(msg = message EMSedge.EMgetxyzobj (
                                                                &msg, 
                                                   EMSlcopt_nodgnedge | 
                                                   EMSlcopt_nocommon |
                                                   EMSlcopt_noassoc,
                                                   &mdEnv->md_env,
                                                   NULL, NULL, NULL, NULL,
                                                   edOs, &xyzObj),
                             senderid = NULL_OBJID,
                             targetid = edId,
                             targetos = edOs);
                   if (!(1 & OM_stat)) goto wrapup; 

                   OM_stat = om$send(msg = message GRconic.GRgetarc (
                                           &msg,
                                           &mdEnv->md_env.matrix_type,
                                           mdEnv->md_env.matrix,
                                           &(edGeom.cvInfo.arcInfo)),
                             senderid = NULL_OBJID,
                             targetid = xyzObj,
                             targetos = edOs);
                   if (!(1 & OM_stat)) goto wrapup;

                   if(!mscExists) {
                     OM_stat = om$send(msg = message GRgraphics.GRdelete (
                                             &msg,
                                             mdEnv),
                               senderid = NULL_OBJID,
                               targetid = xyzObj,
                               targetos = edOs);
                     if (!(1 & OM_stat)) goto wrapup;  
    
                     OM_stat = om$send(msg = message EMSedge.EMset_props (
                                             &msg, EMED_MSCEXISTS, EMS_O_OFF),
                                       senderid = NULL_OBJID,
                                       targetid = edId,
                                       targetos = edOs);
                     if (!(1 & OM_stat)) goto wrapup;
                   }
                
                   break;
              }            
        }

        prtCvinfo (reportFile, &edGeom);
   
wrapup :
return(OM_S_SUCCESS);
        
}

static void prtCvinfo(reportFile, crvInfo)

FILE *reportFile;
struct prtInfo *crvInfo;
{
     IGRint i, j;

	switch(crvInfo->cvType) {
              case EMlinestring :
              case EMlinesegment :
              case EMfreeform_curve :
              {
                 IGRint numVtxs;
                 IGRdouble (*vtxs)[3];

                 numVtxs = (IGRlong) (crvInfo->cvInfo.poleInfo).num_poles;
                 vtxs = (IGRdouble (*)[3]) 
                        (crvInfo->cvInfo.poleInfo).poles;
                 fprintf(reportFile, "\n Number of Vertices : %d", numVtxs);

                 for (i = 0; i < numVtxs; i++) {
                     fprintf(reportFile, "\n Vertex %d", i+1);
                     for (j = 0; j < 3; j++)
                         fprintf(reportFile, "\n %7.12lf", vtxs[i][j]);
                 }

                 break;
              }
              case EMcircle :
              case EMcircular_arc :
              {
              IGRdouble (*rotMtrx)[4];
  
              fprintf(reportFile, "\n Radius : %f ", 
                                  crvInfo->cvInfo.arcInfo.prim_axis);

              fprintf(reportFile, "\n Center :");
              for (j = 0; j < 3; j++)
                  fprintf(reportFile, "\n %7.12lf",
                                      crvInfo->cvInfo.arcInfo.origin[j]);

              rotMtrx = (IGRdouble (*)[4]) 
                         (crvInfo->cvInfo.arcInfo).rot_matrix;              
              for (i = 0; i < 3; i++) {
                  fprintf(reportFile, "\n Rot Matrix(row %d)", i+1);
                  for (j = 0; j < 3; j++)
                      fprintf(reportFile, "\n %0.1f", rotMtrx[i][j]);
                 }

              break;
             }
             case EMelliptical_arc:
             case EMellipse :
             {
             IGRdouble (*rotMtrx)[4];

              fprintf(reportFile, "\n Major Axis Length : %f ",
                                  (crvInfo->cvInfo.arcInfo.prim_axis) * 2);

              fprintf(reportFile, "\n Minor Axis Length: %f ",
                                  (crvInfo->cvInfo.arcInfo.sec_axis) * 2);

              fprintf(reportFile, "\n Center :");
              for (j = 0; j < 3; j++)
                  fprintf(reportFile, "\n %7.12lf",
                                      crvInfo->cvInfo.arcInfo.origin[j]);

              rotMtrx = (IGRdouble (*)[4])
                         (crvInfo->cvInfo.arcInfo).rot_matrix;
              for (i = 0; i < 3; i++) {
                  fprintf(reportFile, "\n Rot Matrix(row %d)", i+1);
                  for (j = 0; j < 3; j++)
                      fprintf(reportFile, "\n %0.1f", rotMtrx[i][j]);
                 }
             } 
        }
}

static void prtCvType(reportFile, cvType)

FILE *reportFile;
IGRuchar cvType;
{
      switch(cvType) {
            case EMfreeform_curve :
                 fprintf(reportFile, "\n Element Type : Freeform Curve ");
                 break;

            case EMcircular_arc :
                 fprintf(reportFile, "\n Element Type : Circular Arc ");
                 break;

            case EMcircle :
                 fprintf(reportFile, "\n Element Type : Circle ");
                 break;

            case EMelliptical_arc :
                 fprintf(reportFile, "\n Element Type : Elliptical Arc "); 
                 break;  

            case EMellipse :
                 fprintf(reportFile, "\n Element Type : Ellipse ");
                 break;

            case EMlinesegment :
                 fprintf(reportFile, "\n Element Type : Line Segment ");
                 break;
      }

return;
}
end implementation Root;
