class implementation EMSsubbs;

#include <stdio.h>
#include "igrtypedef.h"
#include "igrdef.h"
#include "igr.h"
#include "igetypedef.h"
#include "gr.h"
#include "griodef.h"
#include "griomacros.h"
#include "report.h"
#include "OMerrordef.h"
#include "OMmacros.h"
#include "DImacros.h"
#include "dpmacros.h"
#include "csmacros.h"
#include "EMSmsgdef.h"
#include "EMSprop.h"
#include "emsedgedef.h"
#include "EMSlcdef.h"
#include "emssfdef.h"

%safe
static void printGeom();
%endsafe

extern IGRlong getCompCharacteristics();

method GRanalyze_element (IGRlong *msg; struct GRmd_env *mdEnv;
                          FILE *saveFileName; 
                          enum GRanalyze_types *analyzeOption)
{
      extern IGRlong prtEdInfo();
      extern IGRlong getEleInfo();

      IGRchar layerName[40];
      IGRlong msgLoc, sts;
      IGRint i, arraySize = 0, numEdges = 0,
             size = 40;
      struct GRid *sfEdges = NULL;
      struct GRobj_info obj_info;
      struct GRsymbology symbology;  

      sts = OM_S_SUCCESS;
      msgLoc = EMS_S_Success;

      if(*analyzeOption == DETAILED || *analyzeOption == GENERAL) {
         IGRlong size = 256, bytesRet;
         IGRchar csName[256];  
         struct GRid locObj;
         IGRshort flag = 0, numAlias = 3;
         GRIOalias_name distUnits[3];  

         extern IGRlong GRprintAssocInfo();

         locObj.objid = my_id;
         locObj.osnum = OM_Gw_current_OS;

         getEleInfo(msg, saveFileName, &locObj, mdEnv);

         cs$get_active_info(msg          = msg,
                            osnum        = mdEnv->md_id.osnum,
                            module       = mdEnv->md_id.objid,
                            namebuf_size = size,
                            name         = csName,
                            namebytes_ret= &bytesRet);

         fprintf((FILE *) saveFileName, "Active Coordinate System: %s\n",
                 csName);

         co$get_default_units ( msg = msg,
                               table_name = GRIO_DISTANCE,
                               flag = &flag,
                               num_defaults = &numAlias,
                               default_units = distUnits );

        fprintf((FILE *) saveFileName, "Units:");
        for(i = 0; i < 3; i++)
           fprintf((FILE *) saveFileName, " %s", distUnits[0]);

        getCompCharacteristics((FILE *)saveFileName, &locObj, mdEnv);

        if(*analyzeOption == DETAILED)
        GRprintAssocInfo(saveFileName, &locObj);

        printGeom(msg, &locObj, mdEnv, saveFileName);

        goto getedges;
      }

      fprintf((FILE *) saveFileName, "\n");

      sts = om$send(msg = message GRgraphics.GRgetobjinfo
                                  (msg, &obj_info),
                    targetid = my_id);
      if(!(1 & sts))
        goto wrapup;

      fprintf((FILE *) saveFileName, "\n");
      fprintf((FILE *) saveFileName, "%s\n", obj_info.type);
      fprintf((FILE *) saveFileName, "Object id : %d \n", my_id);
 
      sts = om$send (msg = message GRvg.GRgetsymb (msg, &symbology),
                       targetid = my_id);
      if(1 & sts)
        dp$levels_number_to_name (msg = msg,
                                  number =  symbology.level,
                                  size_name_buffer = &size,
                                  name = layerName);

       fprintf((FILE *)saveFileName,
               "Layer: %d  %s; Color: %d; Weight: %d; Style: %d\n",
               symbology.level, layerName, symbology.display_attr.color,
               symbology.display_attr.weight, symbology.display_attr.style);

      getedges :

      if(*analyzeOption == DETAILED || *analyzeOption == OWNER_LOCATED)
      { 
        sts = om$send(msg = message EMSsurface.EMgetedges (&msgLoc, 
                                               NULL, &sfEdges, &arraySize,
                                               &numEdges, NULL, NULL,
                                               NULL, NULL),
                      targetid = my_id);
        if(1 & sts) {
          for(i = 0; i < numEdges; i++) {
             prtEdInfo((FILE *) saveFileName, sfEdges[i].objid,
                       sfEdges[i].osnum, mdEnv);
          fprintf((FILE *) saveFileName, "\n");
          }
        }
      }

wrapup :
     return (OM_S_SUCCESS);
}

static void printGeom(msg, locObj, mdEnv, saveFileName)
IGRlong *msg;
struct GRid *locObj;
struct GRmd_env *mdEnv;
FILE *saveFileName;
{
       IGRint i, k, u_num_poles = 1, v_num_poles = 1;
       IGRdouble (*poles)[3];
       IGRlong sts = OM_S_SUCCESS;
       IGRushort type;
       struct IGRbsp_surface *my_sfgeom = NULL;
 
       extern IGRint EMgetvggeom();

       sts = om$send(msg = message EMSsurface.EMget_params(msg, NULL, mdEnv,
                                                           &type, NULL),
                     senderid = NULL_OBJID,
                     targetid = locObj->objid,
                     targetos = locObj->osnum);  

       if(type == EMfreeform_surface) {
         EMgetvggeom (msg, &(mdEnv->md_env).matrix_type,
                      (mdEnv->md_env).matrix,
                      locObj,
                      &my_sfgeom, NULL); 
         if(!my_sfgeom) goto wrapup;
      
         fprintf(saveFileName, "Surface Coordinates and weights of Poles\n");

         poles = (IGRdouble (*)[3]) my_sfgeom->poles;
         for(k = 0; k < (my_sfgeom->u_num_poles * my_sfgeom->v_num_poles); k++)
         {
               if(k == (my_sfgeom->u_num_poles - 1))
               {
                  u_num_poles = 1;
                  ++v_num_poles;
               }

               fprintf(saveFileName, "\nPole(%d, %d)\n", u_num_poles++, 
                       v_num_poles);       

               fprintf(saveFileName, "\n");

               for(i = 0; i < 3; i++)
                  fprintf(saveFileName, "%e\n", poles[k][i]); 

               if(my_sfgeom->rational)
                 fprintf(saveFileName, "\nWeight : %e\n", 
                                         my_sfgeom->weights[k]); 
               
         }

         fprintf(saveFileName, "Knots in U : \n");
         for(i = 0; i < my_sfgeom->u_num_knots; i++) 
            fprintf(saveFileName, "%e\n", my_sfgeom->u_knots[i]); 

         fprintf(saveFileName, "Knots in V : \n");
         for(i = 0; i < my_sfgeom->v_num_knots; i++)
            fprintf(saveFileName, "%e\n", my_sfgeom->v_knots[i]);

         if(my_sfgeom) om$dealloc(ptr = my_sfgeom);
       } 

wrapup : 

  return;
}
end implementation EMSsubbs;
