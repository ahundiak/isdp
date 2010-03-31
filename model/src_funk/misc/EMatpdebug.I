/************************************************
      This api lists the topolgy of the given solid.
     List outs the total number of surfaces,loops,edges in a solid.
     Also list the mass properties of the solid which uniquely identifies
     a solid.  V.Srinivas
***********************************************/

/***********

   History

    13-8-96       V.Srinivas        created
*************/

 class implementation Root;
  /*** includes **/
#include <stdio.h>
#include <math.h>
#include "OMmacros.h"
#include "OMminimum.h"
#include "EMS.h"
#include "EMSopt.h"
#include "EMSmsgdef.h"
#include "emsdef.h"
#include "emsedgedef.h"
#include "emserr.h"
#include "emsmacros.h"
#include "PWminimum.h"
#include "PWerror.h"
#include "PWapi/clsid.h"
#include "PWapi/sftype.h"
#include "PWapi/sflp.h"
#include "PWapi/lped.h"
#include "PWapi/edprops.h"
#include "PWapi/sf.h"
#include "actparam.h"
#include "bsdefs.h"
#include "bserr.h"
#include "bsparameters.h"
#include "bseig3x3.h"
#include "bsgeom_cvsf.h"
#include "bsdistptpt.h"
#include "alloca.h"
#include "godef.h"

from EMSloopset import EMget_loops;
from EMSsurface import EMgetedges;
from EMSsurface import EMmassprop;
from EMSmassprop import EMinitialize;
from EMSmassprop import EMset_density;
from EMSmassprop import EMset_type;
 /* link list to store the surface ids*/
 struct surfid_list
 {
  GRobjid              surfid;
  struct surfid_list   *next;
 };
%safe
 static int                 dfs(
   GRobjid    objid,
   PWosnum     osnum,
   int        numsf,
   struct surfid_list *surfshead );
%endsafe
 extern OMuword OPP_EMSsolid_class_id,OPP_EMSsubbs_class_id;

void GetSolidTopology
(
   GRobjid    objid,
   PWosnum     osnum,
    FILE       *fp
)
{

    PWclassid               obj_classid;
    int                     num_sfs,i,j,k,cv_type;
    unsigned int            num_full_cyl,num_part_cyl,num_revsurf,
                            num_projsurf,num_full_cone,num_part_cone,
                            num_part_sphere,num_planar,num_bsp,
                            num_torus,num_part_torus,num_sphere,point,
                            linesegment,linestring,circle,ellipse,
                            circular_arc,elliptical_arc,freeform_curve,
                            tnum_loops,tnum_edges;
    struct surfid_list      *surf_head,*curr_node;
    IGRint                  num_edges,num_loops,CinX;
    PWobjid                 *edges,*faceloops;
    short                   sf_type;  
    IGRlong                 sts,msg;
    IGRdouble               prop[20],scaling_factor=1.0,sld,density,sldrange[6];
    IGRvector               trans_vector;
    struct GRmd_env         module_info;
    struct GRid             GRid_out;
    PWresult                retval;
    OM_S_OBJID              outobjid;
    OM_S_CHANSELECT         notify_chan,to_object;
/***********
     initialisation  *********/

    num_edges = 0;
    tnum_edges = 0;
    num_loops = 0;
    tnum_loops = 0;
    num_sfs = 0;
    cv_type = 0;
    sf_type = 0;
    num_full_cyl = 0;
    num_part_cyl = 0;
    num_revsurf = 0;
    num_projsurf = 0;
    num_full_cone = 0;
    num_part_cone = 0;
    num_part_sphere = 0;
    num_planar = 0;
    num_bsp = 0;
    num_torus = 0;
    num_part_torus = 0;
    num_sphere = 0;
    point = 0;
    linesegment = 0;
    linestring = 0;
    circle = 0;
    ellipse = 0;
    circular_arc  = 0;
    elliptical_arc = 0;
    freeform_curve = 0;
    edges = NULL;
    faceloops = NULL;
    trans_vector[0] = 0.0;
    trans_vector[1] = 0.0;
    trans_vector[2] = 0.0;

    obj_classid=omClassidFromObjid(objid,osnum);
    if(!omIsAncestryValid(obj_classid,OPP_EMSsolid_class_id))
    {
        printf(" INPUT OBJECT IS NOT SOLID\n");
          goto ret_end;
    }

   /**** get number of surfaces and its ids by depth first searching
         the tree of nodes ********/
 
       surf_head = (struct surfid_list *)malloc(sizeof(struct surfid_list));
       surf_head->surfid = NULL_OBJID;
       surf_head->next = NULL;
       num_sfs = dfs(objid,osnum,num_sfs,surf_head);
    curr_node=surf_head; 

    for(i=0; i<num_sfs; ++i)
    {
      /*****
              For each surface get the type and total number of loops****/

        sf_type = pwSfType(curr_node->surfid,osnum);
        if(sf_type == BSFULL_CYL)
               ++num_full_cyl;
        else if(sf_type == BSPART_CYL)
               ++num_part_cyl; 
        else if(sf_type == BSSF_OF_REV)
               ++num_revsurf; 
        else if(sf_type == BSSF_OF_PROJ)
               ++num_projsurf; 
        else if(sf_type == BSFULL_CONE)
               ++num_full_cone; 
        else if(sf_type == BSPART_CONE)
               ++num_part_cone; 
        else if(sf_type == BSTORUS)
               ++num_torus; 
        else if(sf_type == BSPART_TORUS)
               ++num_part_torus; 
        else if(sf_type == BSSPHERE)
               ++num_sphere; 
        else if(sf_type == BSPART_SPHERE)
               ++num_part_sphere; 
        else if(sf_type == BSRECT_PLANE)
               ++num_planar; 
        else   ++num_bsp;

        num_loops = pwNumLpsOfSf(curr_node->surfid,osnum);
        faceloops= (PWobjid *)malloc(num_loops*sizeof(PWobjid));
        num_loops = pwLpsOfSf(curr_node->surfid,osnum,faceloops);
        tnum_loops = tnum_loops+num_loops;

        for(j=0; j<num_loops; ++j) 
        {
          /* for each loop get edges and its type */

         num_edges = pwNumEdsOfLp(faceloops[j],osnum);
         edges = (PWobjid *)malloc(num_edges*sizeof(PWobjid));
         num_edges = pwEdsOfLp(faceloops[j],osnum,edges);
         tnum_edges = tnum_edges+num_edges;

         for(k=0; k<num_edges; ++k)
         {
          cv_type = pwGetEdCvType(edges[k],osnum);
           switch (cv_type)
           {
            case EMpoint :
             ++point;
             break;

            case EMlinesegment :
             ++linesegment;
             break;

            case EMlinestring :
             ++linestring;
             break;

            case EMcircle :
             ++circle;
             break;

            case EMellipse :
             ++ellipse;
             break;

            case EMcircular_arc :
             ++circular_arc;
             break;

            case EMelliptical_arc :
             ++elliptical_arc;
             break;

            default :
             ++freeform_curve;
             break;
          
           } 
          }
       }
    curr_node = curr_node->next;
   }
   
   /***  Print the data to the file ***/

   fprintf(fp," No. of surfaces      = %d\n",num_sfs);
   fprintf(fp," No. of fullcylinder  = %d\n",num_full_cyl);
   fprintf(fp," No. of part_cyl      = %d\n",num_part_cyl);
   fprintf(fp," No. of rev.surfaces  = %d\n",num_revsurf);
   fprintf(fp," No. of proj.surfaces = %d\n",num_projsurf);
   fprintf(fp," No. of full cone     = %d\n",num_full_cone);
   fprintf(fp," No. of part cone     = %d\n",num_part_cone);
   fprintf(fp," No. of bspline surf  = %d\n",num_bsp);
   fprintf(fp," No. of torus surf    = %d\n",num_torus);
   fprintf(fp," No. of part torus    = %d\n",num_part_torus);
   fprintf(fp," No. of sphere surf   = %d\n",num_sphere);
   fprintf(fp," No. of part sphere   = %d\n",num_part_sphere);
   fprintf(fp," No. of planar surf   = %d\n",num_planar);
   fprintf(fp," No. of loops         = %d\n",tnum_loops);
   fprintf(fp," No. of edges         = %d\n",tnum_edges);
   fprintf(fp," No. of point edges   = %d\n",point);
   fprintf(fp," No. of linesegments  = %d\n",linesegment);
   fprintf(fp," No. of linestrings   = %d\n",linestring);
   fprintf(fp," No. of circular edges= %d\n",circle);
   fprintf(fp," No. of elliptical ed.= %d\n",ellipse);
   fprintf(fp," No. of circ.arc      = %d\n",circular_arc);
   fprintf(fp," No. of ellip. arc    = %d\n",elliptical_arc);
   fprintf(fp," No. of freeform curve= %d\n",freeform_curve);
  
 /*****************
       print the mass properties of the solid
   ********************/
   for(i=0; i<20; ++i)
       prop[i] = 0.0;
   density = 1.0;
  /** get module envoirnment **/
   msg = pwGetActiveModuleEnv(&module_info); 
   if (! (1 & msg)) goto ret_end;

   retval = pwGetSubbsRtreeRange(objid,osnum,module_info.md_env.matrix_type,
                                             module_info.md_env.matrix,sldrange);
   if(IsError(retval)) goto ret_end;

   sld = BSdistptpt(&msg,&sldrange[0],&sldrange[3]);


  /** construct mass prop class object **/
  sts =  om$construct(classname="EMSmassprop",
                      osnum=osnum,
                      p_objid=&outobjid,
                     msg=message EMSmassprop.EMinitialize(&msg));

   GRid_out.objid = outobjid;
   GRid_out.osnum = osnum;
   om$make_chanselect(channame="GRnotify.notification",
                     p_chanselect=&notify_chan);

  om$make_chanselect(channame="EMSmassprop.to_object",
                     p_chanselect=&to_object);

  CinX=GRDGNLIMITS_MAX_I;
  sts = om$send(msg=message Root.connect(
              to_object,
              CinX,
              objid,
              osnum,
              notify_chan,
              0),
          senderid=GRid_out.objid,
          targetid=GRid_out.objid,
          targetos=GRid_out.osnum);



  sts = om$send(msg=message EMSmassprop.EMset_density(&msg,density),
          senderid=GRid_out.objid,
          targetid=GRid_out.objid,
          targetos=GRid_out.osnum);

  sts = om$send(msg=message EMSmassprop.EMset_type(&msg,0),
          senderid=GRid_out.objid,
          targetid=GRid_out.objid,
          targetos=GRid_out.osnum);


   sts = om$send(msg = message EMSsurface.EMmassprop(&msg,
                                  num_sfs, sld,
                                  &module_info,
                                  scaling_factor, trans_vector,
                                  &density, prop),
                            senderid = objid,
                            targetos = osnum,
                            targetid = objid);
   if (! (1 & sts & msg)) goto ret_end;

   fprintf(fp," Volume =%lf\n",prop[0]);
   fprintf(fp," Surface area =%lf\n",prop[11]);
   fprintf(fp," Centroid  =%lf,%lf,%lf\n",prop[2],prop[3],prop[4]);
   fprintf(fp," Moment about X axis =%lf\n",prop[5]);
   fprintf(fp," Moment about Y axis =%lf\n",prop[6]);
   fprintf(fp," Moment about Z axis =%lf\n",prop[7]);
   fprintf(fp," Product moment XY =%lf\n",prop[8]);
   fprintf(fp," Product moment YZ =%lf\n",prop[9]);
   fprintf(fp," Product moment ZX =%lf\n",prop[10]);
  
   ret_end:
   om$dealloc(ptr=edges);
   om$dealloc(ptr=curr_node);
   om$dealloc(ptr=faceloops);
   
} 

  int dfs( GRobjid objid, 
           PWosnum osnum,
           int     num_sfs, 
           struct surfid_list  *curr_node)
  {
      int                count,tmp_numsfs,i;
      PWobjid            *chan_objs;
      OM_S_CHANSELECT    chan_to_objs;
      PWclassid          obj_classid;
      IGRboolean         is_simple;
      EMmake_chanselect (GRcmpowner_to_components, &chan_to_objs);
       count=0;
      count=omNumObjsOnChannel(objid,osnum,&chan_to_objs); 
      obj_classid=omClassidFromObjid(objid,osnum);

      is_simple=omIsAncestryValid(obj_classid,OPP_EMSsubbs_class_id);
  /** if no objects on the channel or object is simple surface**/
      if(!count || is_simple)
      {
        if(is_simple)
        {
         curr_node->surfid = objid;
         return(++num_sfs);
        }
        return(num_sfs);
      }

      chan_objs=(PWobjid*)malloc(count*sizeof(PWobjid));

      count=omGetObjsOnChannel(objid,osnum,&chan_to_objs,chan_objs);
     
      for(i=0; i<count; ++i)
      {
       tmp_numsfs = dfs(chan_objs[i],osnum,num_sfs,curr_node);
    /* go to the end of linked list */
       while(curr_node->next)
        curr_node=curr_node->next; 
       if(tmp_numsfs != num_sfs)
       {
        num_sfs = tmp_numsfs;
        if(i==(count-1))
        {
         curr_node->next=NULL;
         return(num_sfs);
        }
        if(curr_node->surfid != NULL_OBJID)
        {
         curr_node->next =(struct surfid_list *)malloc(sizeof(struct surfid_list));
         curr_node = curr_node->next;
         curr_node->next=NULL;
         curr_node->surfid = NULL_OBJID;
        }
       }
      } 
    return(num_sfs);

} 
 end implementation Root;
