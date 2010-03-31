/* ###################   APOGEE COMPILED   ################## */
class implementation EMShorizon;

# include <alloca.h>
# include "emsdef.h"
# include "EMSopt.h"
# include "EMSprop.h"
# include "EMSmsgdef.h"
# include "emserr.h"

from EMSedge import EMget_props;

method EMget_the_edges(IGRlong         *EMmsg;
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
    08 July 91 Jack Changed call to EMShorizon.EMcheck_orientation to 
                    EMShelper.EMcheck_orientation since it is now 
                    defined there and overridden at EMShorizon.
    13 Aug  91 Jack Added struct GRid *obj parm to EMcheck_orientation
                    message send.  Don't need the GRid returned here
                    so NULL is passed in.
    17 Sep  91 Jack Added *mdenv_info parm. Re: reference planes.
    24 Nov  91 Jack Don't return edges with edge prop EMED_NO_DISPLAY
                    set.
    03 Oct  92  msm ANSI-C conversion.
    17 Jun  93  WBC Added support for the option EMS_OPT_ALL_HORIZON which
                    allows all horizon edges to be returned regardless of
                    orientation.

*/
{
 IGRlong   sts;
 IGRint    match,
           num,
           num2 = 0;
 OMuint    count = 0;
 IGRdouble result;
 OM_S_CHANSELECT to_comps;
 OM_S_OBJECT_LINKAGE *loc_horiz_edges = NULL;
 IGRushort props = 0;

 *EMmsg = EMS_S_Success;
  sts = OM_S_SUCCESS;

 /* check options to see if the caller wants horizon edges */
 if((options & EMS_OPT_HORIZON) ||
    (options & EMS_OPT_ALL_HORIZON))
  {
   /* if all horizon edges are requested, don't need to check orientation */

   if (! (options & EMS_OPT_ALL_HORIZON))
    {
     sts = om$send( msg = message EMShelper.EMcheck_orientation(
                                           z_vector,
                                           mdenv_info,
                                          &match, 
                                          &result,
                                           NULL),
                    senderid = my_id,
                    targetid = my_id );
     EMerr_hndlr( !( 1 & *EMmsg & sts ), *EMmsg, EMS_E_Fail, wrapup );
 
     /* if the z_vector is not the same as the objects z vector(mdenv_info),
        then we don't want to return any edges, just return success.
      */  
     if(!match)
      {
       sts = OM_S_SUCCESS;
      *EMmsg = EMS_S_Success;   
       goto wrapup;
      }
    }
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
      to avoid fragmenting memory.  This way we don't need to
      keep track of how big the edge buffer is.  The following
      check will tell us if we need to realloc. 
    */  
   if((((*num_horiz_edges/32)+1)*32) <= *num_horiz_edges+count)
    {
       num = (((*num_horiz_edges+count)/32)+1);
            
      *horiz_edges = (struct GRid *) om$realloc(ptr = (IGRchar *)*horiz_edges,
                 size = (sizeof(struct GRid) * num * 32));
        
    }
   
   loc_horiz_edges = (OM_S_OBJECT_LINKAGE *) alloca(sizeof(
                                             OM_S_OBJECT_LINKAGE)*count);   

   sts = om$get_channel_objects(object = me,                     
                                p_chanselect = &to_comps,
                                list = loc_horiz_edges,
                                size = count,
                                count = &count);
   EMerr_hndlr(!(1&sts),*EMmsg,EMS_E_OMerror,wrapup);

   /* load up the array of edge GRid's to pass back */
   for(num=0;num < count;num++)
   {
     sts = om$send ( msg = message EMSedge.EMget_props(
                                           EMmsg,
                                          &props ),
                     targetid = loc_horiz_edges[num].S_objid,
                     targetos = loc_horiz_edges[num].osnum);
     if(!(sts & *EMmsg & 1))
       goto wrapup;

     if(!(props & EMED_NO_DISPLAY)) /* if this edge is displayed */
      {
       (*horiz_edges)[*num_horiz_edges+num2].osnum = 
                                            loc_horiz_edges[num].osnum;
       (*horiz_edges)[*num_horiz_edges+num2].objid = 
                                            loc_horiz_edges[num].S_objid;
        num2++;
      }

   }

   *num_horiz_edges += num2;

   } /* end if count */
 } /* end if options */



wrapup:

  return(sts);
}

end implementation EMShorizon; 
