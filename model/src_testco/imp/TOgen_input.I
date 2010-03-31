/*
    This file contains the initial implementation of the Data Structures
    Layer for the Topology Analysis project.
    "Analyze Adjacnecy between Surface"

*/

class implementation ECtpanaly;

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
# include "TOdsl.h"
# include "TOstruct1.h"
# include "TOtopology.h"
# include "TOproto_ta.h"
#include "TOproto_ds.h"
#include "bserr.h"
#include "bstypes.h"
#include "bsparameters.h"
#include "bsarclen.h"
# include <time.h>
#undef clock


from EMSsubbs		import EMgetedges;
from EMSedge  		import EMxyz_endpt;
from EMSedge  		import EMget_props;
from EMSsubbs 		import EMmk_nat_bdry;
from GRvg		import GRgetsize ;
from GRvg		import GRgetgeom ;
from EMSedge		import EMget_bcxyz_geom;

time_t zeit;

/*
** return start (flag=0) or end (flag=1) point of curve
*/
static void get_end_point(int flag, struct IGRbsp_curve *curve,
	IGRdouble coord[3])
{
    IGRdouble weight;
    int j;

    if (flag == 0)
    {
        /* Find the start point of the curve */
        /* If the curve is rational, unweight the poles */
        if (curve->rational)
            weight = curve->weights[0];
        else
            weight = 1.0;
        j = 0;

    }
    else
    {
        /* Find the end point of the curve */
        j = (curve->num_poles - 1) * 3;
        if (curve->rational)
            weight = curve->weights[curve->num_poles-1];
        else
            weight = 1.0;
    }

    coord[0] = curve->poles[j]/weight;
    coord[1] = curve->poles[j+1]/weight;
    coord[2] = curve->poles[j+2]/weight;
}

/*
Name

    TOgen_input

Abstract

    This is the function that converts EMS data structures to the data
    structures of the topology engine.

Synopsis

    TOgen_input( topo, num_sf, sfids)

    struct topology *topo;          generell topology structure
    IGRint          num_sf;         Number of surfaces
    struct GRid     *sfids;         Surface ids

Description
    Add one surface or a group of surfaces to the basic
    topology
Return Value
    sts = 0	if successful;
         -1	if processing failed;
Notes

History

    22 Feb 94   B.Burkhardt    	Creation
    20 May 94   B.Burkhardt    	Toggle for edge option; use interior of
                                composite Surfaces or not
*/

int TOgen_input( struct topology *topo, 
                 IGRint          num_sf,    
                 struct GRid     *sfids)
{
   struct    GRid *edges = NULL;
   IGRint    num_ed=NULL;
   IGRint    buf_size=NULL;
   IGRlong   EMmsg;
   IGRlong   edge_option = EMS_OPT_CONNECTABLE;
   IGRdouble begin_pt_xyz[3];
   IGRdouble end_pt_xyz[3];
   IGRdouble start,ende,dir,arc;
   IGRboolean status;
   BSrc      rc;
#ifdef NOT_USED
   struct    IGRbsp_surface **surf_geom=NULL;
#endif
   int      i=NULL;
   int      ii=NULL;
   int      sts=NULL;
   struct Ext_data_surface *sfid = NULL;
   struct Ext_data_edge *edid = NULL;
   struct elist    *elhead;
   struct elist    *eltail;
   struct telist   *tlhead;
   struct telist   *tltail;
   struct GRmd_env *sfenvs = NULL;
   int errnum = 0;
   IGRlong num_bytes;

   OMuint		count = NULL;    
   IGRboolean        is_primitive_surface;
   OM_S_CHANSELECT   to_loopset;
   IGRlong           msg;
   IGRlong           size_buf = sizeof(*sfenvs);
   struct GRmdenv_info mdenv_info;

#ifdef DBG
   extern time_t zeit;
   time_t zeits;
   FILE *fp = NULL;

   if((fp=fopen("tmp","a"))==NULL)
   {
      printf("can't open tmp in TOgen_input\n");
      return(-1);
   }
   printf("TOgen_input\n");
#endif
   sfenvs = (struct GRmd_env *)alloca(num_sf * sizeof(*sfenvs));
   if(!sfenvs)
   {
#ifdef DBG
      printf("alloca failed in TOgen_input\n");
#endif
      sts = -1;
      goto wrapup;
   }
   sts = NULL;
/* start and end parameter and direction indicator for BSarclen */
   start = 0.0;
   ende  = 1.0;
   dir   = 0.5;

   sts = EMmake_chanselect (EMSsubbs_to_loopset, &to_loopset);

   mdenv_info.matrix_type = MAIDMX;
   MAidmx (&msg, mdenv_info.matrix);

   if(topo->pa.option & TOPO_DO_INTERIOR_OF_CO)
      edge_option = EMS_OPT_ALL;
   else
      edge_option = EMS_OPT_CONNECTABLE;

/*
   loop over all surfaces
 *  determine if it has topology.  If not then construct some. 
       -- copied from make Composite Surface Command
 *  fill input data structures
*/
   for(i=0; i<num_sf; i++)
   {
/* printf("add surface %d, objid=%d\n",i,sfids[i].objid); */

      sts = gr$get_module_env (msg = &msg,
                                  sizbuf = &size_buf,
                                  buffer = &(sfenvs[i]));

      sts = om$get_channel_count(
               osnum = sfids[i].osnum,
               objid = sfids[i].objid,
               p_chanselect = &to_loopset,
               count = &count);
      is_primitive_surface = (1 & sts); /* Will fail if not primitive */
      if (is_primitive_surface && (count == 0))
      {
            sts = om$send(
                  msg = message EMSsubbs.EMmk_nat_bdry(
                  &EMmsg,
                  &(sfenvs[i].md_env),
                  NULL),
                  senderid=NULL_OBJID,
                  targetid = sfids[i].objid,
                  targetos = sfids[i].osnum);
      } /* if (!count) */




      /* sfid = (struct Ext_data_surface *)malloc(sizeof(struct Ext_data_surface)); */
      sfid = (struct Ext_data_surface *)TOnew_memory(topo, sizeof(struct Ext_data_surface));

      if(sfid == NULL){ sts=-1; goto wrapup;}

      sfid->referenced_object.osnum = sfids[i].osnum;
      sfid->referenced_object.objid = sfids[i].objid;
      sfid->displayed_object.osnum  = NULL;
      sfid->displayed_object.objid  = NULL;

      /* get the surface information */
      sts = om$send(mode = OM_e_wrt_object,
		msg = message GRvg.GRgetsize ( &EMmsg,
				&sfenvs[i].md_env.matrix_type,
				sfenvs[i].md_env.matrix,
				&num_bytes),
		senderid = NULL,
		targetid = sfids[i].objid,
		targetos = sfids[i].osnum);
      if(!(1&sts&EMmsg))
      {
        continue;
      }

      sfid->surf = (struct IGRbsp_surface *) TOnew_memory(topo,num_bytes);
      if(sfid->surf == NULL){ sts=-1; goto wrapup;}

      sts = om$send(mode = OM_e_wrt_object,
		msg = message GRvg.GRgetgeom(
				&EMmsg,
				&sfenvs[i].md_env.matrix_type,
				sfenvs[i].md_env.matrix,
				(IGRchar *) sfid->surf),
		senderid = NULL,
		targetid = sfid->referenced_object.objid,
		targetos = sfid->referenced_object.osnum);
		
				
     
/*
      get edges;
*/
      num_ed = NULL;
      buf_size = NULL;
      sts = om$send(msg = message EMSsubbs.EMgetedges(&EMmsg,
            edge_option, &edges, &buf_size, &num_ed,
            NULL,NULL,NULL,NULL),
            senderid = NULL_OBJID, 
	    targetos = sfids[i].osnum,
	    targetid = sfids[i].objid);
      if(!(1&sts))
      {
#ifdef DBG
         printf("getedges failed for %d(%d), %d edges\n",sfids[i].objid,
		 sfids[i].osnum,num_ed);
#endif
         sts = NULL;
         continue;
      }
	
/*
      Generate input data structures for topology
*/
#ifdef DBG
            printf("TOadd_sf %x %x %d %x %x \n",topo,sfid,num_ed,elhead,eltail);
#endif
      sts = TOadd_sf(topo,sfid,num_ed, &elhead, &eltail);
         if(sts)
         {
#ifdef DBG
            printf("TOadd_sf failed\n");
#endif
            goto wrapup;
         }      
/*
      Loop over all edges of the current surface
      check the default settings for param !!!!!!!
*/
      for(ii=0;ii<num_ed;ii++)
      {
         edid = (struct Ext_data_edge *)TOnew_memory(topo,
                                              sizeof(struct Ext_data_edge));
         if(edid == NULL){ sts=-1; goto wrapup;}
         edid->referenced_object.osnum = edges[ii].osnum;
         edid->referenced_object.objid = edges[ii].objid;
         edid->displayed_object.osnum  = NULL;
         edid->displayed_object.objid  = NULL;
         edid->bound[0].param             = 0.0;
         edid->bound[0].span_inx          = NULL;
         edid->bound[1].param             = 1.0;
         edid->bound[1].span_inx          = NULL;


         edid->edge = (struct IGRbsp_curve *)TOnew_memory(topo, 
				sizeof(struct IGRbsp_curve));
         if(edid->edge == NULL) goto wrapup;

         /* get the edge information */
	 edid->edge->poles = NULL;
	 edid->edge->knots = NULL;
	 edid->edge->weights = NULL;
	 sts = om$send ( msg = message EMSedge.EMget_bcxyz_geom
            ( &EMmsg, &mdenv_info, 0, NULL, 0, OM_K_MAXINT, FALSE, 0, 
			edid->edge),
                targetid = edges[ii].objid,
                targetos = edges[ii].osnum,
                senderid = NULL );
/* Caution: this call will allocate the space for poles/knots/weights
**          somehow, we have to free this space later
*/
	 if(!(1&sts))
	 {
#ifdef DBG
            printf("EMget_bcxyz_geom failed\n");
#endif
            goto wrapup;
	 }

         sts = TOadd_ed(topo,edid,1,NULL,NULL,NULL,topo->sf.sftail->next,
                      NULL,NULL,NULL,&tlhead,&tltail);
         if(sts)
         {
#ifdef DBG
            printf("TOadd_ed failed\n");
#endif
            goto wrapup;
         }      
         sts = TOadd_el(topo,eltail,topo->ed.etail->next);
         if(sts)
         {
#ifdef DBG
            printf("TOadd_el failed\n");
#endif
            goto wrapup;
         }      

         /* get edge property */
         sts = om$send(msg = message EMSedge.EMget_props( &EMmsg,
			&edid->props),
                       targetos = edges[ii].osnum,
                       targetid = edges[ii].objid,
			senderid= edges[ii].objid);
         if(!(1&sts))
	 {
#ifdef DBG
		printf("cannot get prop (%d,%d)\n",i,ii);
#endif
		errnum ++;
	 }
         
/*
	printf("surf=%d,edg=%d, prop=0x%x\n",i,ii,edid->props);
*/
         if( edid->props & EMED_DEGENERATE)
            topo->ed.etail->next->status = 9; 
         else
         {
/*
            don't reley on edge properties!
            make a test with the arclength
*/
        
            BSarclen(&rc,&status,edid->edge,&start,&ende,&dir,&arc);
            if(rc != BSSUCC)
            {
               sts = 1;
               goto wrapup;
            }
            if(arc < 0.5*topo->pa.diagnosis_distance_tolerance)
               topo->ed.etail->next->status = 9; 
         }
/*
         get end points of the current edge
*/
#ifdef NOT_USED

         sts = om$send(msg = message EMSedge.EMxyz_endpt(&EMmsg,
                       &(sfids[i]), &(sfenvs[i].md_env),
                       NULL,NULL,begin_pt_xyz,end_pt_xyz,
                       surf_geom),   
                       senderid = NULL_OBJID,
                       targetos = edges[ii].osnum,
                       targetid = edges[ii].objid);
         if(!(1&sts))
         {
#ifdef DBG
            printf("message EMSedge.EMxyz_endpt failed (surf=%d,edge=%d)\n",
			i,ii);
#endif
	    ++errnum;
            /* goto wrapup; */
         }      
#endif

         get_end_point(0, edid->edge, begin_pt_xyz);
         
         sts =TOadd_pt(topo,1,(double *)begin_pt_xyz,topo->ed.etail->next,NULL);
         if(sts)
         {
#ifdef DBG
            printf("TOadd_pt failed\n");
#endif
            goto wrapup;
         }      
         topo->ed.etail->next->p1     = topo->pt.ptail->next;

         get_end_point(1, edid->edge, end_pt_xyz);

         sts =TOadd_pt(topo,1,(double *)end_pt_xyz,topo->ed.etail->next,NULL);
         if(sts)
         {
#ifdef DBG
            printf("TOadd_pt failed\n");
#endif
            goto wrapup;
         }      
         topo->ed.etail->next->p2     = topo->pt.ptail->next;
      } /* loop over all edges */      
   } /* loop over all surfaces */
   if(errnum > 0)
   {
#ifdef DBG
            printf("abort because of failure\n");
#endif
	sts = 1;
	goto wrapup;
   }

#ifdef DBG      
       fprintf(fp,"cpu nach TOgen_input %10.5f s \n",clock()/1000000);
       sts = time(&zeits);
       fprintf(fp,"time = %d sec.\n",(zeits-zeit));
       fprintf(fp,"\nanzahl der flaechen : %10d\n",num_sf);
       fprintf(fp,"\nanzahl der edges    : %10d\n",topo->ed.num_ed);
       fprintf(fp,"\nanzahl der punkte   : %10d\n\n",topo->pt.num_pt);
#endif

#ifdef TEST_INPUT
       sts = TOprint_sf(topo);
       if(sts)
          goto wrapup;
       sts = TOprint_ed(topo);
       if(sts)
          goto wrapup;
       sts = TOprint_pt(topo);
       if(sts)
          goto wrapup;
#endif
   sts = NULL;
wrapup:
#ifdef DBG      
   if(fp)
      fclose(fp);
#endif
   return(sts);
}
end implementation ECtpanaly;
