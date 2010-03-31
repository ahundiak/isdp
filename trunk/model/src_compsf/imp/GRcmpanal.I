class implementation EMScompsurf;
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
#include "OMminimum.h"
#include "OMprimitives.h"
#include "DImacros.h"
#include "dpmacros.h"
#include "csmacros.h"
#include "EMSmsgdef.h"
#include "EMSprop.h"
#include "emsedgedef.h"
#include "emssfdef.h"
#include "EMSsfparms.h"
#include "EMSlcdef.h"
#include "report.h"
#include "bstypes.h"
#include "bsarclength.h"
#include "EMSommacros.h"

#ifndef MAX_NO_VERTICES
#define MAX_NO_VERTICES 10
#endif

#ifndef BUFFER_SIZE
#define BUFFER_SIZE 400
#endif

extern OMuword OPP_EMSdpr_class_id, OPP_EMSpolyhdrn_class_id,
               OPP_EMSblock_class_id, OPP_EMSsfsolid_class_id,
               OPP_EMSprjcompsf_class_id, OPP_EMSrevcompsf_class_id,
               OPP_EMSgensolid_class_id, OPP_EMSgencompsf_class_id,
               OPP_EMAplane_class_id, OPP_EMSplane_class_id;

extern IGRlong getEleInfo();
extern IGRlong getEleCharacterstics();
extern IGRlong getCompCharacteristics();

from EMSpolyhdrn import EMget_vertices;
from EMSwedge import EMextract_vtx_hwd;
from EMSblock import EMextract_vtx_hwd;
from EMSrevol import EMgetRevolvedFormat;

method GRanalyze_element (IGRlong *msg; struct GRmd_env *mdEnv;
                          FILE *saveFileName;
                          enum GRanalyze_types *analyzeOption)
{
        GRclassid objClass;
        enum GRanalyze_types locAnalyzeOption;

        OM_S_CHANSELECT toComponents;

        extern IGRlong GRprintAssocInfo();

        EMmake_chanselect(GRcmpowner_to_components, &toComponents);

        om$get_classid (objid = my_id, p_classid = &objClass);

        if(*analyzeOption == DETAILED || *analyzeOption == GENERAL) {
        IGRboolean world = FALSE;
        GRrange range;
        IGRshort flag = 0, numAlias = 3;
        IGRint i, compCount = 0;
        IGRlong size = 256, bytesRet;
        GRIOalias_name distUnits[3];
        IGRchar csName[256];
        struct GRid locObj;

        locObj.objid = my_id;
        locObj.osnum = OM_Gw_current_OS;

	getEleInfo(msg, saveFileName, &locObj, mdEnv);

        om$send (msg = message GRowner.GRget_number_components(msg,
                                                               &compCount),
                 targetid = my_id);

        if (om$is_ancestry_valid (subclassid = objClass,
            superclassid = OPP_EMSdpr_class_id) == OM_S_SUCCESS ||
            objClass == OPP_EMSgensolid_class_id ||
            objClass == OPP_EMSprjcompsf_class_id ||
            objClass == OPP_EMSrevcompsf_class_id ||
            objClass == OPP_EMSgencompsf_class_id)          
        {

        fprintf((FILE *)saveFileName, "Number of Surfaces: %d\n",
                                      compCount);
        }
        
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
       
        fprintf((FILE *) saveFileName, "\n");
        
        if (om$is_ancestry_valid (subclassid = objClass,
            superclassid = OPP_EMSdpr_class_id) == OM_S_SUCCESS ||
            objClass == OPP_EMSprjcompsf_class_id ||
            objClass == OPP_EMSrevcompsf_class_id ||
            objClass == OPP_EMSgencompsf_class_id ||
            objClass == OPP_EMSsfsolid_class_id)
        {
        om$send (msg = message GRgraphics.GRgetrang(msg,
                               &(mdEnv->md_env).matrix_type,
                               (mdEnv->md_env).matrix,
                               &world, range),
                 targetid = my_id);

        fprintf((FILE *)saveFileName, "Max. Range:\n");
        for(i = 0; i < 3; i++)
            fprintf((FILE *)saveFileName, "  %f\n", range[i]);

        fprintf((FILE *)saveFileName, "Min. Range:\n");
        for(i = 3; i < 6; i++)
            fprintf((FILE *)saveFileName, "  %f\n", range[i]);

        if(objClass == OPP_EMSprjcompsf_class_id ||
           objClass == OPP_EMSrevcompsf_class_id) {
           IGRdouble axes[6];
           IGRushort type;
           IGRdouble  static_doubles_buffer[BUFFER_SIZE], *doubles_buffer;
           struct EMsurface_params parms;
           struct IGRbsp_curve revcrv;

           extern int get_projection_axis();
 
           if(objClass == OPP_EMSrevcompsf_class_id) {
           om$send(msg = message EMSsurface.EMget_params (msg, NULL, mdEnv,
                                                          &type, &parms),
                   targetid = my_id);

           ems$get_memory(rc = msg, element_size = sizeof(IGRdouble),
                          num_elements = parms.params.revolve.curve.num_poles *
                                  (parms.params.revolve.curve.rational ? 4:3) +
                                  parms.params.revolve.curve.num_knots,
                          buffer = (IGRchar *)static_doubles_buffer,
                          buffer_size = BUFFER_SIZE,
                          ptr = (IGRchar **)&doubles_buffer);

           revcrv.poles = doubles_buffer;
           revcrv.weights = parms.params.revolve.curve.rational ?
                            doubles_buffer + 
                            parms.params.revolve.curve.num_poles * 3 : NULL;
           revcrv.knots = doubles_buffer +
                          parms.params.revolve.curve.num_poles *
                          (parms.params.revolve.curve.rational ? 4 : 3);

           om$send(msg = message EMSrevol.EMgetRevolvedFormat(msg,
                         FALSE, &(mdEnv->md_env).matrix_type,
                         (mdEnv->md_env).matrix, &revcrv, axes,
                         NULL, NULL, NULL, NULL),
                         targetid = my_id);
           }
           else {
           om$send(msg = message EMSsurface.EMget_params (msg, NULL, mdEnv,
                                                          &type, &parms),
                   p_chanselect = &toComponents, from = 0, to = 0);

           get_projection_axis (msg, type, &parms, axes);
           }

           if(objClass == OPP_EMSprjcompsf_class_id) {

           fprintf(saveFileName, "\n Axis Pt.1 : %f %f %f\n", axes[0], axes[1],
                                                              axes[2]);
           fprintf(saveFileName, "\n Axis Pt.2 : %f %f %f\n", axes[3], axes[4],
                                                              axes[5]); 
           }

           if(objClass == OPP_EMSrevcompsf_class_id) { 
              fprintf(saveFileName, "\n Axis Pt.1 : %f %f %f\n", axes[0],
                      axes[1], axes[2]);

              fprintf(saveFileName, "\n Axis Pt.2 : %f %f %f\n",
                      axes[3], axes[4], axes[5]);

              fprintf(saveFileName, "\n Sweep Angle : %f\n", 
                      parms.params.revolve.sweep_angle);
             }
          }
        }
        else 
        getEleCharacterstics((FILE *)saveFileName, &locObj, mdEnv, 
                              objClass, compCount);

        if(*analyzeOption == DETAILED)
        GRprintAssocInfo(saveFileName, &locObj);
        }

        if(*analyzeOption == DETAILED || *analyzeOption == OWNER_LOCATED) {
        locAnalyzeOption = OWNER_LOCATED;      
        om$send(msg = message EMSsurface.GRanalyze_element(msg, mdEnv,
                                         saveFileName, &locAnalyzeOption),
                p_chanselect = &toComponents);
        }
               
        return(OM_S_SUCCESS);
}

IGRlong getEleInfo(msg, saveFileName, locObj)
IGRlong *msg;
FILE *saveFileName;
struct GRid *locObj;
{
 	IGRint size = 40;
        IGRlong sts;
        IGRchar dgnFileName[OM_K_MAXOSNAME_LEN],
                eleName[MAXNAMSIZE], layerName[40];
        struct GRsymbology symbology;
        struct GRobj_info obj_info;
      
        *msg = EMS_S_Success;
        sts = OM_S_SUCCESS;

        om$os_number_to_name (osnum = locObj->osnum,
                              osname = dgnFileName);

        sts = om$send (msg = message GRvg.GRgetname (msg, eleName),
                       senderid = NULL_OBJID,
                       targetid = locObj->objid,
                       targetos = locObj->osnum);
        if(1 & sts)
        di$cvt_name_for_output(s_path = eleName);

        sts = om$send (msg = message GRvg.GRgetsymb (msg, &symbology),
                       senderid = NULL_OBJID,
                       targetid = locObj->objid,
                       targetos = locObj->osnum);
        if(1 & sts)
        dp$levels_number_to_name (msg = msg,
                                  number =  symbology.level,
                                  size_name_buffer = &size,
                                  name = layerName,
                                  osnum = locObj->osnum);
  
        sts = om$send (msg =  message GRgraphics.GRgetobjinfo
                                      (msg, &obj_info),
                      senderid = NULL_OBJID,
                      targetos = locObj->osnum,
                      targetid = locObj->objid);
          
        fprintf(saveFileName,"Element Type: %s\n", obj_info.type);
        fprintf(saveFileName,"Object id: %d\n", locObj->objid);
        fprintf(saveFileName,"Element Name: %s\n", eleName);
        fprintf(saveFileName,"File Name: %s\n", dgnFileName);
       fprintf(saveFileName,"Layer: %d  %s; Color: %d; Weight: %d; Style: %d\n",
               symbology.level, layerName, symbology.display_attr.color,
               symbology.display_attr.weight, symbology.display_attr.style);

       return(OM_S_SUCCESS);
                                                      
}

IGRlong getEleCharacterstics(saveFileName, locObj, mdEnv, objClass, compCount)
FILE *saveFileName;
struct GRid *locObj;
struct GRmd_env *mdEnv;
GRclassid objClass;
IGRint compCount;
{
       IGRlong msgLoc, sts;

       msgLoc = EMS_S_Success;  
       sts = OM_S_SUCCESS;

              if(objClass == OPP_EMSpolyhdrn_class_id) 
              {
                   IGRint numVertices = 0, i, j;  
                   IGRpoint vertices[MAX_NO_VERTICES];

                   sts = om$send(msg = message EMSpolyhdrn.EMget_vertices(
                                       &msgLoc, mdEnv, MAX_NO_VERTICES,
                                       &numVertices, vertices),
                                 senderid = NULL_OBJID, 
                                 targetid = locObj->objid,
                                 targetos = locObj->osnum);  
                   if(!(1 & sts))
                     goto wrapup;

                   fprintf(saveFileName, "Number of Faces: %d\n",
                                      compCount);
                   fprintf(saveFileName, "Number of Vertices: %d\n",
                                      numVertices);
                   fprintf(saveFileName, "Vertices :\n");
                   for(i = 0; i < 4; i++) {
                       fprintf(saveFileName, "Vertex %d:  ", i+1);
                      for(j = 0; j < 3; j++) {
                          fprintf(saveFileName, "%f  ", vertices[i][j]);
                          if(j == 2) 
                            fprintf(saveFileName, "\n");
                      }
                   }
              }
              else if(objClass == OPP_EMSwedge_class_id ||
                      objClass == OPP_EMSblock_class_id)
              {
                   IGRint i;
                   IGRpoint origin, height, width, depth;
                   IGRvector h, w, d;

                   if(objClass == OPP_EMSwedge_class_id)
                   sts = om$send(msg = message EMSwedge.EMextract_vtx_hwd(
                                       &msgLoc, mdEnv, origin, h, w, d),
                                 senderid = NULL_OBJID,
                                 targetid = locObj->objid,
                                 targetos = locObj->osnum);      
                   else
                   sts = om$send(msg = message EMSblock.EMextract_vtx_hwd(
                                       &msgLoc, mdEnv, origin, h, w, d),
                                 senderid = NULL_OBJID,
                                 targetid = locObj->objid,
                                 targetos = locObj->osnum);  
                   if(!(1 & sts))
                     goto wrapup;

                   for(i = 0; i < 3; i++) {
                      height[i] = origin[i] + h[i];
                      width[i] = origin[i] + w[i];
                      depth[i] = origin[i] + d[i];  
                   }

                   fprintf(saveFileName, "Origin : %f %f %f\n",
                                          origin[0], origin[1], origin[2]);
                   fprintf(saveFileName, "Height : %f %f %f\n",
                                          height[0], height[1], height[2]);
                   fprintf(saveFileName, "width : %f %f %f\n",
                                          width[0], width[1], width[2]);
                   fprintf(saveFileName, "depth : %f %f %f\n",
                                          depth[0], depth[1], depth[2]);
              }  
              else if(objClass == OPP_EMSsfsolid_class_id ||
                      objClass == OPP_EMSprjcompsf_class_id ||
                      objClass == OPP_EMSrevcompsf_class_id) {
                   OM_S_CHANSELECT toComps;
                   struct GRid compId;

                   EMmake_chanselect(GRcmpowner_to_components, &toComps);     
                   sts = om$get_objid_at_index ( objid = locObj->objid,
                                  p_chanselect = &toComps,
                                  index = 0,
                                  objidaddr = &compId.objid,
                                  osnumaddr = &compId.osnum);
                   if(!(1 & sts))
                     goto wrapup;

                   getCompCharacteristics((FILE *)saveFileName, &compId, mdEnv);
              }
wrapup :
return(OM_S_SUCCESS);
}

IGRlong getCompCharacteristics(saveFileName, compId, mdEnv)
FILE *saveFileName;
struct GRid *compId;
struct GRmd_env *mdEnv;
{
      IGRint i;
      IGRushort type;
      IGRlong msgLoc = EMS_S_Success,
              sts = OM_S_SUCCESS;  
      struct EMsurface_params params;

      sts = om$send(msg = message EMSsurface.EMget_params(&msgLoc,
                                  NULL, mdEnv, &type, &params),
                    senderid = NULL_OBJID,
                    targetid = compId->objid,
                    targetos = compId->osnum);
      if(!(1 & sts))
        goto wrapup;         

      switch(type) {
          case EMrevol :
          case EMproject :
          case EMfreeform_surface :
              {   
               GRclassid objClass;
               struct IGRbsp_surface *my_sfgeom = NULL;
               
               extern IGRint EMgetvggeom(); 

               om$get_classid (objid = compId->objid, p_classid = &objClass);

               if(objClass == OPP_EMAplane_class_id ||
                  objClass == OPP_EMSplane_class_id)
               break;

               EMgetvggeom (&msgLoc, &(mdEnv->md_env).matrix_type,
                            (mdEnv->md_env).matrix,
                            compId,
                            &my_sfgeom, NULL); 
               if(!my_sfgeom) goto wrapup;
              
               fprintf(saveFileName,"\n");
            
               if(my_sfgeom->rational)
               fprintf(saveFileName,"Rational : YES   ");
               else
               fprintf(saveFileName,"Rational : NO   ");

               if(type == EMfreeform_surface) {   
               if(my_sfgeom->u_periodic)
               fprintf(saveFileName,"U_PERIODIC : YES   ");
               else
               fprintf(saveFileName,"U_PERIODIC : NO   ");

               if(my_sfgeom->v_periodic)
               fprintf(saveFileName,"V_PERIODIC : YES   ");
               else
               fprintf(saveFileName,"V_PERIODIC : NO   \n");

               if(my_sfgeom->u_phy_closed)
               fprintf(saveFileName,"U_CLOSED : YES   ");
               else
               fprintf(saveFileName,"U_CLOSED : NO   ");

               if(my_sfgeom->v_phy_closed)
               fprintf(saveFileName,"V_CLOSED : YES   ");
               else
               fprintf(saveFileName,"V_CLOSED : NO  \n");
                   
               fprintf(saveFileName,"U_ORDER : %d   ", my_sfgeom->u_order);
               fprintf(saveFileName,"V_ORDER : %d   \n", my_sfgeom->v_order);

               fprintf(saveFileName,"Number of Poles in U: %d \n",
                       my_sfgeom->u_num_poles); 

               fprintf(saveFileName,"Number of Poles in V: %d \n",
                       my_sfgeom->v_num_poles);  
               }

               if(type == EMproject) {
                 IGRboolean status = TRUE;
                 IGRdouble s = 0.0, e = 1.0, totlen = 0.0;

                 fprintf(saveFileName, "Order : %d\n",
                         params.params.project.curve.order);
         
                 if(params.params.project.curve.periodic)
                    fprintf(saveFileName, "Periodic : YES\n");
                 else
                    fprintf(saveFileName, "Periodic : NO\n");  

                 if(params.params.project.curve.phy_closed)
                    fprintf(saveFileName, "Closed : YES\n");
                 else
                    fprintf(saveFileName, "Closed : NO\n");   

                 fprintf(saveFileName, "Number of Poles : %d\n",
                         params.params.project.curve.num_poles);
                     
                 fprintf(saveFileName, "\n Axis Pt.1 : %f %f %f \n",
                         params.params.project.axis_point0[0],
                         params.params.project.axis_point0[1],
                         params.params.project.axis_point0[2]);
                
                 fprintf(saveFileName, "Axis Pt.2 : %f %f %f \n",
                         params.params.project.axis_point1[0],
                         params.params.project.axis_point1[1],
                         params.params.project.axis_point1[2]);  
 
                 status = BSarclength(&msgLoc, &params.params.project.curve,
                                      &s, &e, &totlen);
                 if(!(status & 1))
                 goto wrapup;   

                 fprintf(saveFileName,"Curve Length : %f\n", totlen);  
               }   

               if(type == EMrevol) {
                 IGRlong status = EMS_S_Success;
                 IGRdouble s = 0.0, e = 1.0, totlen = 0.0;
                 IGRdouble  static_doubles_buffer[BUFFER_SIZE],
                            *doubles_buffer, axes[6];
                 struct IGRbsp_curve revcrv;

                 ems$get_memory(rc = &msgLoc, element_size = sizeof(IGRdouble),
                          num_elements = params.params.revolve.curve.num_poles *
                                  (params.params.revolve.curve.rational ? 4:3) +
                                   params.params.revolve.curve.num_knots,
                          buffer = (IGRchar *)static_doubles_buffer,
                          buffer_size = BUFFER_SIZE,
                          ptr = (IGRchar **)&doubles_buffer);

                 revcrv.poles = doubles_buffer;
                 revcrv.weights = params.params.revolve.curve.rational ?
                                  doubles_buffer +
                                  params.params.revolve.curve.num_poles * 3 :
                                  NULL;
                 revcrv.knots = doubles_buffer +
                                params.params.revolve.curve.num_poles *
                                (params.params.revolve.curve.rational ? 4 : 3);

                 om$send(msg = message EMSrevol.EMgetRevolvedFormat(&msgLoc,
                                       FALSE, &(mdEnv->md_env).matrix_type,
                                       (mdEnv->md_env).matrix, &revcrv, axes,
                                       NULL, NULL, NULL, NULL),
                               senderid = NULL_OBJID,
                               targetid = compId->objid,
                               targetos = compId->osnum);

                 fprintf(saveFileName, "Order : %d\n",
                         my_sfgeom->u_order);

                 if(my_sfgeom->u_periodic)
                    fprintf(saveFileName, "Periodic : YES\n");
                 else
                    fprintf(saveFileName, "Periodic : NO\n");

                 if(params.params.revolve.curve.phy_closed)
                    fprintf(saveFileName, "Closed : YES\n");
                 else
                    fprintf(saveFileName, "Closed : NO\n");

                 fprintf(saveFileName, "Number of Poles : %d\n",
                         params.params.revolve.curve.num_poles);

                 fprintf(saveFileName, "\n Axis Pt.1 : %f %f %f\n", axes[0],
                         axes[1], axes[2]);

                 fprintf(saveFileName, "\n Axis Pt.2 : %f %f %f\n",
                         axes[3], axes[4], axes[5]);

                 fprintf(saveFileName, "\nStart Angle : %f\n",
                         params.params.revolve.start_angle);

                 fprintf(saveFileName, "Sweep Angle : %f\n",
                         params.params.revolve.sweep_angle);

                 status = BSarclength(&msgLoc, &revcrv,
                                      &s, &e, &totlen);
                 if(!(status & 1))
                 goto wrapup;

                 fprintf(saveFileName,"Curve Length : %f\n", totlen);
               }

               if(my_sfgeom) om$dealloc(ptr = my_sfgeom);

               break;
               }  
          case EMcylinder :
               {
                 IGRpoint height;
               
                 for(i = 0; i < 3; i++)
                 height[i] = params.params.cyl.base_center[i] +
                             params.params.cyl.height[i];               

                 fprintf(saveFileName, "\n");
 
                 fprintf(saveFileName, "Radius : %f\n", 
                         params.params.cyl.radius);
                 fprintf(saveFileName, "Center : %f %f %f\n",
                         params.params.cyl.base_center[0],
                         params.params.cyl.base_center[1],
                         params.params.cyl.base_center[2]);
                 fprintf(saveFileName, "Height : %f %f %f\n", height[0],
                                        height[1], height[2]);
                 break;
               }
          case EMcone :
               { IGRpoint height;

                 for(i = 0; i < 3; i++)
                    height[i] = params.params.cone.base_center[i] +
                                params.params.cone.height[i];
 
                 fprintf(saveFileName, "\n");

                 fprintf(saveFileName, "Top Radius : %f\n",
                         params.params.cone.top_radius);
                 fprintf(saveFileName, "Bottom Radius : %f\n",
                         params.params.cone.base_radius);
                 fprintf(saveFileName, "Center : %f %f %f\n",
                         params.params.cone.base_center[0],
                         params.params.cone.base_center[1],
                         params.params.cone.base_center[2]);  
                 fprintf(saveFileName, "Height : %f %f %f\n", height[0],
                                        height[1], height[2]);
                 break;
               }
          case EMelliptical_cylinder :
               {
                 IGRpoint height, majorr, minorr;

                 for(i = 0; i < 3; i++) {
                    height[i] = params.params.elpcyl.base_center[i] +
                                params.params.elpcyl.height[i];  
                 fprintf(saveFileName, "\n");  

                    majorr[i] = params.params.elpcyl.base_center[i] +
                                params.params.elpcyl.semi_major_axis[i];
                    minorr[i] = params.params.elpcyl.base_center[i] +
                                params.params.elpcyl.semi_minor_axis[i];  
                 }
                 fprintf(saveFileName, "Base : %f %f %f\n", 
                         params.params.elpcyl.base_center[0],
                         params.params.elpcyl.base_center[1],
                         params.params.elpcyl.base_center[2]);
                 fprintf(saveFileName, "Height  : %f %f %f\n", height[0],
                                        height[1], height[2]);
                 fprintf(saveFileName, "Major Axis : %f %f %f\n", majorr[0],
                                        majorr[1], majorr[2]);
                 fprintf(saveFileName, "Minor Axis : %f %f %f\n", minorr[0],
                                        minorr[1], minorr[2]);  
                  
                                
                 break;
               }
          case EMelliptical_cone :
               {
                 IGRpoint height, majorr, minorr;

                 for(i = 0; i < 3; i++) {
                    height[i] = params.params.elpcone.base_center[i] +
                                params.params.elpcone.height[i];
                    majorr[i] = params.params.elpcone.base_center[i] +
                                params.params.elpcone.semi_major_axis[i];  
                    minorr[i] = params.params.elpcone.base_center[i] +
                                params.params.elpcone.semi_minor_axis[i];
                 }
     
                 fprintf(saveFileName, "\n");
  
                 fprintf(saveFileName, 
                         "Scale Factor of Top Axis to Bottom : %f\n",
                          params.params.elpcone.scale);
                 fprintf(saveFileName, "Center : %f %f %f\n",
                         params.params.elpcone.base_center[0], 
                         params.params.elpcone.base_center[1],
                         params.params.elpcone.base_center[2]);  
                 fprintf(saveFileName, "Height : %f %f %f\n", height[0],
                                        height[1], height[2]);
                 fprintf(saveFileName, "Major Axis : %f %f %f\n", majorr[0],
                                        majorr[1], majorr[2]);
                 fprintf(saveFileName, "Minor Axis : %f %f %f\n", minorr[0],
                                        minorr[1], minorr[2]);
                   
                 break;
               }  
               case EMsphere :
               {
                 fprintf(saveFileName, "\n");
                 fprintf(saveFileName, "Center : %f %f %f\n",
                         params.params.sphere.center[0],
                         params.params.sphere.center[1],
                         params.params.sphere.center[2]);
                 fprintf(saveFileName, "Radius : %f\n",
                                        params.params.sphere.radius); 
 
                 break;
               }
               case EMellipsoid :
               {
                 IGRpoint majorr;

                 majorr[0] = params.params.elpsd.center[0] +
                             params.params.elpsd.semi_major_axis[0];
                 majorr[1] = params.params.elpsd.center[1] +
                             params.params.elpsd.semi_major_axis[1];
                 majorr[2] = params.params.elpsd.center[2] +
                             params.params.elpsd.semi_major_axis[2];

                 fprintf(saveFileName, "\n");
                 fprintf(saveFileName, "Radius At Minor Axis : %f\n",
                                        params.params.elpsd.radius);
                 fprintf(saveFileName, "Origin : %f %f %f\n",
                                        params.params.elpsd.center[0],
                                        params.params.elpsd.center[1],
                                        params.params.elpsd.center[2]);
                 fprintf(saveFileName, "Focus[0] : %f %f %f\n",
                                        params.params.elpsd.focus0[0],
                                        params.params.elpsd.focus0[1],
                                        params.params.elpsd.focus0[2]);
                 fprintf(saveFileName, "Focus[1] : %f %f %f\n",
                                        params.params.elpsd.focus1[0],
                                        params.params.elpsd.focus1[1],
                                        params.params.elpsd.focus1[2]);
                 fprintf(saveFileName, "Major Axis : %f %f %f\n",
                                        majorr[0], majorr[1], majorr[2]);
                
                 break;  
               }
               case EMtorus :
               {
                    IGRpoint normal;

                    normal[0] = params.params.torus.center[0] +
                                params.params.torus.normal[0];
                    normal[1] = params.params.torus.center[1] +
                                params.params.torus.normal[1];
                    normal[2] = params.params.torus.center[2] +
                                params.params.torus.normal[2];

                    fprintf(saveFileName, "\n");
                    fprintf(saveFileName, "Major Radius : %f\n",
                                           params.params.torus.major_radius);
                    fprintf(saveFileName, "Minor Radius : %f\n",
                                           params.params.torus.minor_radius);
                    fprintf(saveFileName, "Base : %f %f %f\n",
                                           params.params.torus.center[0],
                                           params.params.torus.center[1],
                                           params.params.torus.center[2]);
                    fprintf(saveFileName, "Normal : %f %f %f\n",
                                           normal[0], normal[1], normal[2]);
  
                    break;
               }
               case EMpcylinder:
               {
                  IGRpoint height;

                  height[0] = params.params.pcyl.base_center[0] +
                              params.params.pcyl.height[0];
                  height[1] = params.params.pcyl.base_center[1] +
                              params.params.pcyl.height[1];
                  height[2] = params.params.pcyl.base_center[2] +
                              params.params.pcyl.height[2];

                  fprintf(saveFileName, "\n");

                  fprintf(saveFileName, "Base Radius : %f\n",
                                         params.params.pcyl.radius);
                  fprintf(saveFileName, "Sweep Angle : %f\n",
                                         params.params.pcyl.sweep_angle);
                  fprintf(saveFileName, "Center : %f %f %f\n",
                                         params.params.pcyl.base_center[0],
                                         params.params.pcyl.base_center[1],
                                         params.params.pcyl.height[2]);
                  fprintf(saveFileName, "Height : %f %f %f\n", height[0],
                                         height[1], height[2]);
                  fprintf(saveFileName, "Start Point : %f %f %f\n", 
                                         params.params.pcyl.pstart[0],
                                         params.params.pcyl.pstart[1],
                                         params.params.pcyl.pstart[2]);
                  fprintf(saveFileName, "End Point : %f %f %f\n",
                                         params.params.pcyl.pend[0],
                                         params.params.pcyl.pend[1],
                                         params.params.pcyl.pend[2]);  
                
                  break;
               }
               case EMpcone :
               {
                  IGRpoint height;

                  height[0] = params.params.pcone.base_center[0] +
                              params.params.pcone.height[0];
                  height[1] = params.params.pcone.base_center[1] +
                              params.params.pcone.height[1];
                  height[2] = params.params.pcone.base_center[2] +
                              params.params.pcone.height[2];

                  fprintf(saveFileName, "\n");

                  fprintf(saveFileName, "Height Radius : %f\n",
                                         params.params.pcone.top_radius);
                  fprintf(saveFileName, "Base Radius : %f\n",
                                         params.params.pcone.base_radius);  
                  fprintf(saveFileName, "Sweep Angle : %f\n",
                                         params.params.pcone.sweep_angle);
                  fprintf(saveFileName, "Center : %f %f %f\n",  
                                         params.params.pcone.base_center[0],
                                         params.params.pcone.base_center[1],
                                         params.params.pcone.base_center[2]);
                  fprintf(saveFileName, "Height : %f %f %f\n",
                                         height[0], height[1], height[2]);
                  fprintf(saveFileName, "Start Point : %f %f %f\n",
                                         params.params.pcone.pstart[0],
                                         params.params.pcone.pstart[1],
                                         params.params.pcone.pstart[2]);
                  fprintf(saveFileName, "End Point : %f %f %f\n",
                                         params.params.pcone.pend[0],
                                         params.params.pcone.pend[1],
                                         params.params.pcone.pend[2]);
                  break;
               }
      }

wrapup :
return(OM_S_SUCCESS);
}
end implementation EMScompsurf;
