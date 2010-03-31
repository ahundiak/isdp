
/*
Name

    TOprint_em.c

Abstract

    Print protocol file for the results of the Investigate Edge Match
    Function
    the file contains three routines:
    TOprint_hd        - output file header
    TOprint_all_viol  - output for distance, normal and radius investigation
    TOprint_dist_viol - outputfor distance investigation

Synopsis

     see functions

Description


Return Value



Notes

Index

Keywords

History

    20 Aug 94   B.Burkhardt     Creation
*/
#include <stdio.h>
#include <string.h>
#include "TOtopology.h"
#include "TOstruct1.h"
#include "TOproto_ta.h"
#include <math.h>
#include "bs.h"
#include "bsparameters.h"

#define ARC_TO_DEG 180.0/3.1415926

/*
Description
   topo   - main structure for topological data
*/

int TOprint_hd(struct topology *topo)
{
   FILE *fp = NULL;
   int   i  = NULL;
 
   if(topo->pa.file_name == NULL)
     goto wrapup;
       
   /* fname = topo->pa.file_name;*/
   if((fp = fopen(topo->pa.file_name,"a"))== NULL)
   {
      printf("can't open TOprint_hd \n");
      return(-10);
   }

   fprintf(fp,"\n");
       fprintf(fp,"             **********Analyze Adjacency between Surfaces**********\n\n\n");
   fprintf(fp,"    ");
   for(i=0; i<72; fprintf(fp,"-"), i++);
   fprintf(fp,"\n");
   if(topo->pa.header_line != NULL)
   fprintf(fp,"    %s", topo->pa.header_line);
   fprintf(fp,"\n");
   fprintf(fp,"    ");
   for(i=0; i<72; fprintf(fp,"-"), i++);
   fprintf(fp,"\n\n");
wrapup:
   if(fp)
      fclose(fp);
   return(0);
}
/*
Description

size_flag     - print controling, see code
ovlap0[0:1]   - start and end parameter of the curve which delivers
                the input points
ovlap1[0:1]   - start and end parameter of the curve which delivers
                the output points
in_pts        - array of 3D points
                (in_pts[0]  - x component of first point,
                       [1]  - y component of first point)
in_par        - parameter values of the input points
out_pts       - array of 3D points on the curve which
                are the projection points
out_par       - array of parameters of output points
dist          - array of distances between input_pts
                and output_points
max_i         - point number where distance is maximum
max_dist      - maximum distance
ret           - return code
                                     (ret = 0 - success,
                                         !=0  - failure )
*/

int TOprint_dist_viol(struct topology *topo,
                      IGRint          size_flag,
                      IGRdouble       *ovlap0,
                      IGRdouble       *ovlap1,
                      IGRdouble       *in_pts,
                      IGRdouble       *in_par,
                      IGRdouble       *out_pts,
                      IGRdouble       *out_par,
                      IGRdouble       *dist,
                      IGRint          max_i,
                      IGRdouble       max_dist,
                      IGRlong         *ret)

{
   IGRchar   *viola_hit = "       ";
   IGRchar   *viola_mis = "VIO-DIST";
   IGRchar   violate[9];
   IGRchar   *mode = "a";
   IGRint    i = NULL;
   IGRint    j = NULL;
   IGRint    num_pts;
   IGRint    num_hits = NULL;
   IGRint    num_misses = NULL;
   IGRdouble toler;
   IGRdouble *p, *q;
   FILE      *fp = NULL;

/*** start executable code ***/

   ret = NULL;
   if(topo->pa.file_name == NULL)
     goto wrapup;
   
   /* fname = topo->pa.file_name;*/
   if((fp = fopen(topo->pa.file_name,mode))== NULL)
   {
      printf("file %s does not exist no output will be done \n",
              topo->pa.file_name);
      goto wrapup;
   }
       
   num_pts  = topo->pa.number_of_edge_match_points;
   if(size_flag<NULL)
      num_pts++;
   toler    = topo->pa.distance;
   fprintf(fp,"\n");
   if(size_flag>NULL)
   {
      fprintf(fp,"    Edge 1:\n    start parameter: %f   end parameter %f\n",
                 ovlap0[0],ovlap0[1]);
      fprintf(fp,"    Edge 2:\n    start parameter: %f   end parameter %f\n",
              ovlap1[0],ovlap1[1]);
      fprintf(fp,"\n");
   }
   if(size_flag > NULL)
   {
      fprintf(fp,"    1. Project sample points of edge1 to edge2");
      fprintf(fp,"\n\n");
   }
   else
   {
      fprintf(fp,"\f");
      fprintf(fp,"\n");
      fprintf(fp,"    2. Project sample points of edge2 to edge1");
      fprintf(fp,"\n\n");
   }
   fprintf(fp,"    Number fo sample points: %d\n\
    Investigation tolerance: %f\n\
    Maximum distance violation: %f\n\
    Number of the point with the maximum violation: %d",\
      num_pts,toler,max_dist,(max_i+1));
      fprintf(fp,"\n\n");
   fprintf(fp, \
"     num   xyz of sample point               parameter   distance\n");
   fprintf(fp,\
"           xyz of projected point            parameter\n");
   fprintf(fp,"    ");
   for(j=0; j<75; fprintf(fp,"-"), j++);
   fprintf(fp,"\n\n");

   for(i=0,p=in_pts,q=out_pts; i<num_pts; i++)
   {
      if(dist[i]<toler)
      {
         num_hits++;
         strcpy(violate,viola_hit);
         if(fabs(size_flag) == 5) continue;
      }
      else
      {
         num_misses++;
         strcpy(violate,viola_mis);
      }
      /* nr xi yi zi pi dist MISS-HIT
            xo yo zo po */
      if(i == max_i)
      {
         fprintf(fp,"    ");
         for(j=0; j<4; fprintf(fp,"*"), j++);
         fprintf(fp,"Maximum of Distance Violation");
         for(j=0; j<4; fprintf(fp,"*"), j++);
         fprintf(fp,"\n");
      }
      fprintf(fp,"%6d %10.4f %10.4f %10.4f  %10.4f    %8.4f     %s\n\
       %10.4f %10.4f %10.4f  %10.4f",
              (i+1),*(p++),*(p++),*(p++),in_par[i],dist[i],violate,
                *(q++),*(q++),*(q++),out_par[i]);
      fprintf(fp,"\n");
   }
   fprintf(fp,"\n\n");
   fprintf(fp,"    Number of distance violations: %5d\n",num_misses);
   fprintf(fp,"\n");
   if(size_flag<NULL)
   {
      fprintf(fp,"END OF PROTOCOL\n");
      fprintf(fp,"\f");
      fprintf(fp,"\n");
   }
wrapup:
       if(fp)
          fclose(fp);
       return(0);
}

/*
Description

size_flag     - print controling, see code
ovlap0[0:1]   - start and end parameter of the curve which delivers
                the input points
ovlap1[0:1]   - start and end parameter of the curve which delivers
                the output points
in_pts        - array of 3D points
                (in_pts[0]  - x component of first point,
                       [1]  - y component of first point)
in_par        - parameter values of the input points
out_pts       - array of 3D points on the curve which
                are the projection points
out_par       - array of parameters of output points
dist          - array of distances between input_pts
                and output_points
max_i         - point number where distance is maximum
max_dist      - maximum distance
nor           - array of angles between surface normals of input_pts 
                and output_points
max_n         - point number where angle is maximum
max_nor       - maximum angle
rad           - array of relative radius errors of input_pts
                and output_points
max_r         - point number where relative radius error is maximum
max_rad       - maximum relative radius error
ret           - return code
                                     (ret = 0 - success,
                                         !=0  - failure )
*/

int TOprint_all_viol(struct topology *topo,
                     IGRint          size_flag,
                     IGRdouble       *ovlap0,
                     IGRdouble       *ovlap1,
                     IGRdouble       *in_pts,
                     IGRdouble       *in_par,
                     IGRdouble       *out_pts,
                     IGRdouble       *out_par,
                     IGRdouble       *dist,
                     IGRint          max_i,
                     IGRdouble       max_dist,
                     IGRdouble       *nor,
                     IGRint          max_n,
                     IGRdouble       max_nor,
                     IGRdouble       *rad,
                     IGRint          max_r,
                     IGRdouble       max_rad,
                     IGRlong         *ret)

{
   IGRchar   *viola_hit = "        ";
   IGRchar   *viola_dis = "VIO-DIST";
   IGRchar   *viola_nor = "VIO-NOR";
   IGRchar   *viola_rad = "VIO-RAD";
   IGRchar   violate[9];
   IGRchar   *mode = "a";
   IGRint    i = NULL;
   IGRint    j = NULL;
   IGRint    num_pts;
   IGRint    vio_dis = NULL;
   IGRint    vio_nor = NULL;
   IGRint    vio_rad = NULL;
   IGRdouble toler;
   IGRdouble tol_nor;
   IGRdouble tol_rad;
   IGRdouble *p, *q;
   FILE      *fp = NULL;

/*** start executable code ***/
   ret = NULL;

   if(topo->pa.file_name == NULL)
     goto wrapup;
   
   /* fname = topo->pa.file_name;*/
   if((fp = fopen(topo->pa.file_name,mode))== NULL)
   {
      printf("file %s does not exist no output will be done \n",
              topo->pa.file_name);
      goto wrapup;
   }
       
   num_pts  = topo->pa.number_of_edge_match_points;
   if(size_flag<NULL)
      num_pts++;
   toler    = topo->pa.distance;
   tol_nor  = topo->pa.normal;
   tol_rad  = topo->pa.radius;
   fprintf(fp,"\n");
   if(size_flag>NULL)
   {
      fprintf(fp,"    Edge 1:\n    start parameter: %f   end parameter %f\n",
                 ovlap0[0],ovlap0[1]);
      fprintf(fp,"    Edge 2:\n    start parameter: %f   end parameter %f\n",
              ovlap1[0],ovlap1[1]);
      fprintf(fp,"\n");
   }
   if(size_flag > NULL)
   {
      fprintf(fp,"    1. Project sample points of edge1 to edge2");
      fprintf(fp,"\n\n");
   }
   else
   {
      fprintf(fp,"\f");
      fprintf(fp,"\n");
      fprintf(fp,"    2. Project sample points of edge2 to edge1");
      fprintf(fp,"\n\n");
   }
   if(!(topo->pa.option& TOPO_MO_RADIUS))
   {
   fprintf(fp,"    Number fo sample points: %d\n\
    Distance tolerance: %f\n\
    Normal tolerance: %f\n\
    Maximum distance violation: %f\n\
    Number of the point with the maximum distance violation: %d\n\
    Maximum normal violation: %f\n\
    Number of the point with the maximum normal violation: %d\n",
   num_pts,toler,tol_nor,max_dist,(max_i+1),(max_nor*ARC_TO_DEG),(max_n+1));
   }
   else
   {
   fprintf(fp,"    Number fo sample points: %d\n\
    Distance tolerance: %f\n\
    Normal tolerance: %f\n\
    Radius tolerance: %f\n\
    Maximum distance violation: %f\n\
    Number of the point with the maximum distance violation: %d\n\
    Maximum normal violation: %f\n\
    Number of the point with the maximum normal violation: %d\n\
    Maximum radius violation: %f\n\
    Number of the point with the maximum radius violation: %d\n",
    num_pts,toler,tol_nor,tol_rad,max_dist,(max_i+1),
    max_nor*ARC_TO_DEG,(max_n+1), max_rad,(max_r+1));
   } 
      fprintf(fp,"\n\n");
   if(topo->pa.option & TOPO_MO_RADIUS)
   {
   fprintf(fp, \
"     num   xyz of sample point              distance  normal    radius\n");
   }
   else
   {
   fprintf(fp, \
"     num   xyz of sample point              distance   normal  \n");
   }
   fprintf(fp,\
"           xyz of projected point\n");
   fprintf(fp,
"           parameter1 parameter2\n");
   fprintf(fp,"    ");
   for(j=0; j<75; fprintf(fp,"-"), j++);
   fprintf(fp,"\n\n");

   for(i=0,p=in_pts,q=out_pts; i<num_pts; i++)
   {
      if(dist[i]>toler)
      {
         vio_dis++;
         strcpy(violate,viola_dis);
      }
      else if(nor[i]>tol_nor)
      {
         vio_nor++;
         strcpy(violate,viola_nor);
      }
      else if(rad[i]>tol_rad)
      {
         vio_rad++;
         strcpy(violate,viola_rad);
      }
      else
      {
         strcpy(violate,viola_hit);
         if(fabs(size_flag) == 5) continue;
      }
      /* nr xi yi zi dist nor rad
            xo yo zo
            pi po */
      if(i == max_i)
      {
         fprintf(fp,"    ");
         for(j=0; j<4; fprintf(fp,"*"), j++);
         fprintf(fp,"Maximum of Distance Violation");
         for(j=0; j<4; fprintf(fp,"*"), j++);
         fprintf(fp,"\n");
      }
      if(i == max_n)
      {
         fprintf(fp,"    ");
         for(j=0; j<4; fprintf(fp,"*"), j++);
         fprintf(fp,"Maximum of Normal Violation");
         for(j=0; j<4; fprintf(fp,"*"), j++);
         fprintf(fp,"\n");
      }
      if(i == max_r &&(topo->pa.option & TOPO_MO_RADIUS))
      {
         fprintf(fp,"    ");
         for(j=0; j<4; fprintf(fp,"*"), j++);
         fprintf(fp,"Maximum of Radius Violation");
         for(j=0; j<4; fprintf(fp,"*"), j++);
         fprintf(fp,"\n");
      }
      if(topo->pa.option & TOPO_MO_RADIUS)
      {
      fprintf(fp,"%6d %10.4f %10.4f %10.4f   %8.4f  %8.4f  %8.4f  %s\n\
       %10.4f %10.4f %10.4f\n\
       %10.4f %10.4f",
              (i+1),*(p++),*(p++),*(p++),dist[i],(ARC_TO_DEG*nor[i]),
              rad[i],violate,
              *(q++),*(q++),*(q++),in_par[i],out_par[i]);
      }
      else
      {
      fprintf(fp,"%6d %10.4f %10.4f %10.4f   %8.4f   %8.4f    %s\n\
       %10.4f %10.4f %10.4f\n\
       %10.4f %10.4f",
              (i+1),*(p++),*(p++),*(p++),dist[i],(ARC_TO_DEG*nor[i]),violate,
              *(q++),*(q++),*(q++),in_par[i],out_par[i]);
      }
      fprintf(fp,"\n");
   }
   fprintf(fp,"\n\n");
   fprintf(fp,"    Number of distance violations: %5d\n",vio_dis);
   fprintf(fp,"    Number of normal violations: %5d\n",vio_nor);
   if(topo->pa.option & TOPO_MO_RADIUS)
   {
   fprintf(fp,"    Number of radius violations: %5d\n",vio_rad);
   }
   fprintf(fp,"\n");
   if(size_flag<NULL)
   {
      fprintf(fp,"END OF PROTOCOL\n");
      fprintf(fp,"\f");
      fprintf(fp,"\n");
   }
wrapup:
       if(fp)
          fclose(fp);
       return(0);
}
