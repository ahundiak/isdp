/* ###################   APOGEE COMPILED   ################## */
class implementation EMSgraloop;

# include <alloca.h>
# include "emsdef.h"
# include "EMSopt.h"
# include "EMSprop.h"
# include "EMSmsgdef.h"
# include "emserr.h"

from EMSedge import EMget_props;

method EMget_the_edges(IGRlong *EMmsg;
                       IGRshort         options;
                       IGRdouble       *z_vector;
                       struct GRmdenv_info *mdenv_info;
                       IGRint          *num_gralp_edges;
                       IGRint          *num_horiz_edges;
                       IGRint          *num_cusp_edges;                
                       struct GRid     **gralp_edges;
                       struct GRid     **horiz_edges;
                       struct GRid     **cusp_edges)

/*
History

    13 June 91 Jack Creation
    24 Nov  91 Jack    Don't return edges with edge prop EMED_NO_DISPLAY
                       set.
    03 Oct  92 msm  ANSI-Cconversion.


Notes:  This routine will return the graloop edges if the options 
        parameter so specifies.  Since the the graloop edge may
        have partedge on it(and partedges may have partedges on them...)
        the top level of edges/partedges will be returned in gralp_edges.
*/
{
 IGRlong   sts;
 IGRint    num,
           num2 = 0;
 OMuint    count = 0;
 OM_S_CHANSELECT to_comps;
 OM_S_OBJECT_LINKAGE *loc_gralp_edges = NULL;
 IGRushort props = 0;

 *EMmsg = EMS_S_Success;
  sts = OM_S_SUCCESS;

 /* check options to see if the caller wants gralp edges */
 if(options & EMS_OPT_GRALOOP)
  {

   to_comps.type = OM_e_addr;
   to_comps.u_sel.addr = &ME.EMSbd_owner->to_comps;  

   sts = om$get_channel_count(object = me,
                              p_chanselect=&to_comps,
                              count=&count);
   EMerr_hndlr(!(1&sts),*EMmsg,EMS_E_OMerror,wrapup);

  if(count) 
   {
   /* check if we need to realloc more space.  the allocs for
      the memory passed back are in multiples of 32 in order 
      to avoid fragmenting memory.  Also, we don't need to
      keep track of how big the edge buffer is.  The following
      check will tell us if we need to realloc. 
    */  
   if((((*num_gralp_edges/32)+1)*32) <= *num_gralp_edges+count)
    {
       num = (((*num_gralp_edges+count)/32)+1);
            
      *gralp_edges = (struct GRid *) om$realloc(ptr = (IGRchar *)*gralp_edges,
                 size = (sizeof(struct GRid) * num * 32));
        
    }
   
   loc_gralp_edges = (OM_S_OBJECT_LINKAGE *) alloca(sizeof(
                                             OM_S_OBJECT_LINKAGE)*count);   

   sts = om$get_channel_objects(object = me,                     
                                p_chanselect = &to_comps,
                                list = loc_gralp_edges,
                                size = count,
                                count = &count);
   EMerr_hndlr(!(1&sts),*EMmsg,EMS_E_OMerror,wrapup);

   /* load up the array of edge GRid's to pass back */
   for(num=0;num < count;num++)
   {

     sts = om$send ( msg = message EMSedge.EMget_props(
                                           EMmsg,
                                          &props ),
                     targetid = loc_gralp_edges[num].S_objid,
                     targetos = loc_gralp_edges[num].osnum);
     if(!(sts & *EMmsg & 1))
       goto wrapup;

     if(!(props & EMED_NO_DISPLAY)) /* if this edge is displayed */
      {
       (*gralp_edges)[*num_gralp_edges+num2].osnum = 
                                            loc_gralp_edges[num].osnum;
       (*gralp_edges)[*num_gralp_edges+num2].objid = 
                                            loc_gralp_edges[num].S_objid;
        num2++;
      }

   }

   *num_gralp_edges += num2;

   } /* end if count */
 } /* end if options */


wrapup:

  return(sts);


}

end implementation EMSgraloop; 
