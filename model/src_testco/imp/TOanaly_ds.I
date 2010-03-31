/*
    This file contains the initial implementation of the Data Structures
    Layer for the Topology Analysis project.

    more to come...
*/

class implementation Root;

# include <alloca.h>
# include "igrtypedef.h"
# include "igetypedef.h"
# include "igr.h"
# include "igrdp.h"
# include "gr.h"
# include "go.h"
# include "ex.h"
# include "grdpbdef.h"
# include "grdpbmacros.h"
# include "dp.h"
# include "griodef.h"
# include "grio.h"
# include "lcdef.h"
# include "lc.h"
# include "EMSasnuc.h"
# include "EMSasmacros.h"
# include "EMSasnucdef.h"
# include "madef.h"
# include "godef.h"
# include "EMSmsgdef.h"
# include "OMerrordef.h"
# include "emserr.h"
# include "emsdef.h"
# include "emsmacros.h"
# include "msmacros.h"
# include "EMSopt.h"
# include "EMSprop.h"
# include "EMS.h"
# include "EMSbnddef.h"
# include "EMSbnd.h"
# include "EMSlmdef.h"
#include "EMSasopts.h"
#include "EC_P.h"
#include "EC_S.h"
#include "EC_I.h"
#include "EC_E.h"
#include "EC_M.h"
#include "GRtypedef.h"
#include "EMSascmacros.h"
# include <stdio.h>
# include "ECmsg.h"
# include "TOdsl.h"
# include "TOstruct1.h"
# include "TOtopology.h"
# include "TOproto_ta.h"
#include "TOproto_ds.h"
#include "TOnumbers.h"
# include <time.h>
#undef clock


from EMSsubbs		import EMgetedges;
from EMSedge 		import EMdisplay;
from EMSedge  		import EMxyz_endpt;
from EMSsubbs 		import EMmk_nat_bdry;
from EMSedge            import EMget_props;
from EMSedge            import EMget_bcxyz_geom;
from EMSedge            import EMset_props;

extern OMuword OPP_EMSsubbs_class_id;
   
time_t zeit;


/*
Name

    TOadd_surfaces

Abstract

    This is the function that adds surfaces to the data structures of
    the basic topology . If no basic topology exist it is created.

Synopsis

    TOadd_surfaces( topo, num_sf, sfids)

    struct topology *topo;          generell topology structure
    IGRint          num_sf;         Number of surfaces
    struct GRid     *sfids;         Surface ids

Description
    Add one surface or a group of surfaces to the basic
    topology
Return Value
    sts = 0	if successful;
         -1	if processing failed;
         10	if no surface selected;
Notes

History

    22 Feb 94   B.Burkhardt    	Creation
*/

int TOadd_surfaces(
    struct topology *topo,          /* generell topology structure */
    IGRint          num_sf,         /* Number of surfaces   */
    struct GRid     *sfids)         /* Surface ids          */
{
   IGRint          sts = NULL;
   struct topology *topo1;
   int tmp_option;
#ifdef DBG
/*
   prepeare time measuring and test print file
*/

   FILE            *fp=NULL;
   FILE            *fp1=NULL;
   extern time_t zeit;
   time_t zeits;
   printf("TOadd_surfaces\n");

   if((fp = fopen("tmp","w"))== NULL)
   {
      printf("can't open tmp in TOadd_surfaces \n");
      return(-1);
   }

   if((fp1 = fopen("top_data","w"))== NULL)
   {
      printf("can't open top_data in TOadd_surfaces \n");
      return(-1);
   }
   clock();
   fprintf(fp,"cpu= %10.5f s nach start\n",clock()/1000000);
   sts = time(&zeit);
   sts = time(&zeits);
   fprintf(fp,"time = %d sec. start\n",(zeits-zeit));
#endif
   topo1 = topo1; /*make the compiler happy; topo1 used later in TOadd_s.. */
/*
   If no surfaces exist generate input data from the given
   EMS object list and generate a basic topologyi (engine).
   Else, if an engine exist generate an input add it to the data input
   structures and include in the topological data structures at the
   right place.
*/
   ex$message(msgnumb = EMS_I_ClearStatusField);
   ex$message(msgnumb = EMS_P_ClearPromptField,);
   if(!num_sf)
   {
      ex$message(field = ERROR_FIELD,
                 msgnumb = EMS_E_NoSurfSel);/*No Surfaces Selected*/
      sts =10;
      goto wrapup;
   }
 
   ex$message(field = ERROR_FIELD,
              msgnumb = EMS_E_Process /* Processing */);

   if(!(topo->sf.num_sf))
   {
      sts = TOgen_input(topo,num_sf,sfids);
      if(sts)
      {
#ifdef DBG
      printf("TOgen_input failed\n");
#endif
         goto wrapup;
      }
      sts = TOgen_engine(topo);
      if(sts)
      {
#ifdef DBG
      printf("TOgen_engine failed\n");
#endif
      ex$message(field = ERROR_FIELD,
              msgnumb = EMS_E_BasicFail /*Generation of Basic Topology failed*/
                );

         goto wrapup;
      }
      ex$message(field = ERROR_FIELD,
                 msgnumb = EMS_E_BasicNrSf,
                          /*Basic Topology generated with # Surfaces*/
                 type = "%6d", var = num_sf);
   }
   else /* case:  engine already exist */
   {
      tmp_option = topo->pa.option;
      topo->pa.option &= ~TOPO_DO_GRAPHIC_PERMAN;
      sts = TOdelete_top(topo);
      topo->pa.option = tmp_option;
      sts = TOinit(topo);
      if(sts)
      {
#ifdef DBG
      printf("TOinit failed\n");
#endif
         goto wrapup;
      }
      sts = TOgen_input(topo,num_sf,sfids);
      if(sts)
      {
#ifdef DBG
      printf("TOgen_input failed\n");
#endif
         goto wrapup;
      }
      sts = TOgen_engine(topo);
      if(sts)
      {
#ifdef DBG
      printf("TOadd_engine failed\n");
#endif
      ex$message(field = ERROR_FIELD,
              msgnumb = EMS_E_BasicFail /*Generation of Basic Topology failed*/
                );

         goto wrapup;
      }
      ex$message(field = ERROR_FIELD,
                 msgnumb = EMS_E_BasicNrSf,
                          /*Basic Topology generated with # Surfaces*/
                 type = "%6d", var = num_sf);
   }
   sts = NULL;
wrapup:
#ifdef DBG
   if(fp)
      fclose(fp);
   if(fp1)
      fclose(fp1);
#endif
   return(sts);
}
/*
Name

    TOadd_engine

Abstract

    This is the function that includes surfaces, their edges and points
    in an existing engine;

Synopsis

    TOadd_engine( topo,topo1)

    struct topology *topo;          generell topology structure
    struct topology *topo1;         generell topology structure, including
				    the elements to add 

Description
    Add one surface or a group of surfaces to the basic
    topology
Return Value
    sts = 0	if successful;
         -1	if processing failed;
Notes

History

    22 Feb 94   B.Burkhardt    	Creation
*/
int TOadd_engine( 
    struct topology *topo,          /* generell topology structure */
    struct topology *topo1)         /* generell topology structure, including
				       the elements to add */
{
   printf("TOadd_engine\n");
   *topo  = *topo;
   *topo1 = *topo1;
   return(NULL);
}

/*
Name

   TOdelete_surfaces

Abstract

    text

Synopsis

    int TOdelete_surfaces(struct topology *topo,  int num_sf, struct GRid *objid)

Description

    delete surfaces from the internal list in topo

Return Value

    0

Notes

Index

Keywords

History

    xx Feb 94   GWW     Creation
*/
int TOdelete_surfaces(struct topology *topo, int num_sf, struct GRid *objid)
{
   printf("TOdelete_surfaces\n");
   topo   = topo;
   num_sf = num_sf;
   objid  = objid;
   return 0;
}
/*
Name

    name

Abstract

    text

Synopsis

sts = TOdelete_topology(struct topology *topo)

topo	- pointer to the main structure of topological data

Description
	Deletes the topological structure and free all 
        the allocated memory

Return Value

    NULL

Notes

Index

Keywords

History

    15 Feb 94   GWW     Creation
    01 Aug 94   B.Burkhardt    	Add deletion of temporary point objects
*/
int TOdelete_topology(struct topology *topo)
{
   TOdelete_temp(topo,TRUE); /* delete temporary objects */

   TOdelete_points(topo,TRUE); /* delete temporary points */

   TOdelete_top(topo);  /* delete topology structures */

   return 0;
}
/*
Name

    TOstitch_ed

Abstract

    this is the EMS independent interface the EMS methods for
    the analyzing of edge continuities

Synopsis

    TOstitch_ed(topo,sti_option,ed1,ed2,
                n_poi_p_con,p_con_head,p_con_tail,
                n_poi_n_con,n_con_head,n_con_tail,
                n_poi_r_con,r_con_head,r_con_tail);

    struct topology *topo; 	   main structure for topology data	
    short           sti_option;    sti_option = 0 --> edge match
                                   sti_option = 1 --> overlap and split
    struct edge     *ed1          -pointer to the first edge in the list 
    struct edge     *ed2          -pointer to the second edge in the list 
    IGRint          *n_poi_p_con  -number of sample points where continuity
                                   is violated in Invest Edge Match 
    struct point    **p_con_head  -list header for points where continuity 
                                   is violated
    struct point    **p_con_tail  -list tail for points where continuity is
                                   violated   
    IGRint          *n_poi_n_con  -) 
    struct point    **n_con_head  -) the same as above for normal continuity 
    struct point    **n_con_tail  -) 

    IGRint          *n_poi_r_con  -) 
    struct point    **r_con_head  -) the same as above for radius continuity 
    struct point    **r_con_tail  -) 


Description

    Interface routine between EMS and Basic Topology.
    Prepeares data for TOedstitch function and calls the function.	


Return Value

Notes

History

    14 Dec 93   B.Burkhardt     Creation
    13 Sep 94   B.Burkhardt     Add list headers and tails for point list
                                for worst case display
*/

# define TOoption0x1000         0x1000

int TOstitch_ed( struct topology *topo, 	
                short           sti_option, 
                struct edge     *ed1,
                struct edge     *ed2,
                IGRint          *n_poi_p_con,
                struct point    **p_con_head,
                struct point    **p_con_tail,
                IGRint          *n_poi_n_con,
                struct point    **n_con_head,
                struct point    **n_con_tail,
                IGRint          *n_poi_r_con,
                struct point    **r_con_head,
                struct point    **r_con_tail)


{
   IGRlong               EMmsg;     
   IGRint                sample_size ;
   IGRdouble             match_tol ; 
   IGRdouble             same_an_tol;
   IGRdouble             same_rd_tol;
   struct EMSstitch_info pair;
   IGRint 		 nret;
   int                   sts=NULL;
   struct edge           *ed[2];

   pair.option  = TOstitch_top_tol | TOstitch_no_range_check;
   sample_size  = topo->pa.number_of_diagnosis_points;
   match_tol    = topo->pa.diagnosis_distance_tolerance;
   same_an_tol  = topo->pa.diagnosis_angle_tolerance;
   same_rd_tol  = topo->pa.diagnosis_radius_tolerance;

   if(!sti_option)/* check the edges in TOsort_ed */
   {
      pair.option |= TOcheck_interval;
      match_tol    = topo->pa.topology_tolerance;
   }
   else if (sti_option == 1 || sti_option == 11)/* split edges in TOsplit_ed */
   {
      match_tol    = topo->pa.topology_tolerance;
      pair.option &= ~TOstitch_no_range_check;
      pair.option &= ~TOcheck_interval;
      pair.option |=  TOsplit_edges;
   }
   else if(sti_option == 2)/* analyze distance between curves in TOana_dist */
   {
      pair.option |= TOanalyz_p_cont;
      pair.option |= TOstitch_no_range_check | TOsplit_edges |TOget_interval;
      pair.option &= ~TOcheck_interval;
      sample_size  = topo->pa.number_of_diagnosis_points;
      match_tol    = topo->pa.diagnosis_distance_tolerance;
   }
   else if(sti_option == 3)/* analyze normal continuity in TOana_nor */
   {
      pair.option |= TOanalyz_n_cont | TOanalyz_p_cont;
      pair.option |= TOstitch_no_range_check;
      pair.option &= ~TOcheck_interval & ~TOsplit_edges &  ~TOget_interval;
      sample_size  = topo->pa.number_of_diagnosis_points;
      match_tol    = topo->pa.diagnosis_distance_tolerance;
      same_an_tol  = topo->pa.diagnosis_angle_tolerance;
   }
   else if(sti_option == 4)/* analyze radius continuity in TOana_nor */
   {
      pair.option |= TOanalyz_r_cont | TOanalyz_n_cont | TOanalyz_p_cont;
      pair.option |= TOstitch_no_range_check;
      pair.option &= ~TOcheck_interval & ~TOsplit_edges &  ~TOget_interval;
      sample_size  = topo->pa.number_of_diagnosis_points;
      match_tol    = topo->pa.diagnosis_distance_tolerance;
      same_an_tol  = topo->pa.diagnosis_angle_tolerance;
      same_rd_tol  = topo->pa.diagnosis_radius_tolerance;
   }
   else if(sti_option == 5)/* Investigate Edge Match (Distance)*/
   {
      pair.option |= TOinvest_p_cont;
      pair.option |= TOstitch_no_range_check;
      pair.option &= ~TOcheck_interval & ~TOsplit_edges &  ~TOget_interval;
      sample_size  = topo->pa.number_of_edge_match_points;
      match_tol    = topo->pa.distance;
   }
   pair.edge0        = ed1->ext->referenced_object.objid;
   pair.edge1        = ed2->ext->referenced_object.objid;
   pair.surf0        = ed1->sf->ext->referenced_object.objid;
   pair.surf1        = ed2->sf->ext->referenced_object.objid;
   pair.edge_geom0   = ed1->edid0->ext->edge;
   pair.edge_geom1   = ed2->edid0->ext->edge;
   pair.surf_geom0   = ed1->sf->ext->surf;
   pair.surf_geom1   = ed2->sf->ext->surf;

   ed[0]             = ed1;
   ed[1]             = ed2;

/*
   this is the modified stitch function used in EMedstitch.I
   /usr2/ip32/modelsrc/src_bound/imped
*/


   sts = TOedstitch(topo,&pair,ed,sample_size,
                    match_tol,same_an_tol,same_rd_tol,
                    n_poi_p_con, p_con_head, p_con_tail,
                    n_poi_n_con, n_con_head, n_con_tail,
                    n_poi_r_con, r_con_head, r_con_tail);

   if(sts<NULL)
   {
#ifdef DBG
      printf("TOedstitch failed\n");
#endif
      goto wrapup;
   }
wrapup:
   return(sts);
}

int TOdelete_ext_surf(struct Ext_data_surface *surface)
{
   surface = surface;
   return 0;
}

int TOdelete_ext_edge(struct Ext_data_edge *edge)
{
   edge = edge;
   if(edge != NULL && edge->edge != NULL)
   {
     if(edge->edge->poles) om$dealloc(ptr = edge->edge->poles);
     if(edge->edge->knots) om$dealloc(ptr = edge->edge->knots);
     if(edge->edge->weights) om$dealloc(ptr = edge->edge->weights);
   }
   return 0;
}


end implementation Root;
