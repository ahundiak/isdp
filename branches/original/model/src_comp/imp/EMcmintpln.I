class implementation EMScomposite;

#include "EMScc.h"
#include "OMmacros.h"   /* OM_BLOCK_MOVE    */
#include "EMSmsgdef.h"  /* EMS error codes  */
#include "EMSlogic.h"   /* EMSmsgReport     */
#include "EMStypedef.h" /* EMSmsgReport     */
#include "EMScmacros.h" /* EMSmsgReport     */
#include "emserr.h"

#define LOCAL_BUF       10

method EMintplane(struct GRvg_construct *construct_list;
                  struct IGRplane *plane;
                  struct GRlc_info *located_object;
                  int *number_of_intersections;
                  struct GRid **pointer_to_resulting_intersections;
                  int *EMmsg)
/*
History

        DLB     10/29/87        Modified channel for version 1.1.0
        SM      05/26/87        Fixed memory problems
        AIC     05/14/87        Modify to collect results
        AIC     03/30/87        Creation Date

Algorithm

        Send in a loop to the components, collecting the results.
*/
{
  IGRlong               sts;
  OMuint                num_components;
  IGRint                i,  buf_size;
  OM_S_CHANSELECT       to_comps;

  /*
   * Initialize
   */
  sts = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;

  *number_of_intersections = 0;
  *pointer_to_resulting_intersections = NULL;

  *pointer_to_resulting_intersections = (struct GRid *)
        om$malloc (size = LOCAL_BUF * sizeof(struct GRid));

  buf_size = LOCAL_BUF;

  to_comps.type = OM_e_addr;
  to_comps.u_sel.addr = &ME.GRcmpowner->to_components;

  sts = om$get_channel_count(object = me, p_chanselect = &to_comps,
                             count = &num_components);
  for(i = 0; i < num_components; i ++)
  {
    IGRint             num_ints;
    struct GRid        *ints;

    num_ints = 0;
    ints = NULL;

    sts = om$send(msg = message GRvg.EMintplane(construct_list, plane,
                 located_object, &num_ints, &ints, EMmsg),
                 p_chanselect = &to_comps, from = i, to = i);
    if(! (1 & *EMmsg & sts)) goto wrapup;
    if(num_ints)
    {
      IGRint        num_bytes;
      struct GRid   *from_addr, *to_addr;

      if( (*number_of_intersections + num_ints) > buf_size)
       {
         *pointer_to_resulting_intersections = (struct GRid *)
           om$realloc (ptr = ( IGRchar* )
				*pointer_to_resulting_intersections, 
                       size = (*number_of_intersections+num_ints+LOCAL_BUF)
                                 * sizeof(struct GRid));
        buf_size = num_ints + LOCAL_BUF;
       }

      from_addr = ints;
      to_addr=&(*pointer_to_resulting_intersections)[*number_of_intersections];
      num_bytes = num_ints * sizeof(struct GRid);
      OM_BLOCK_MOVE(from_addr, to_addr, num_bytes);
      (*number_of_intersections) += num_ints;
      buf_size -= num_ints;
      if(ints) om$dealloc(ptr = ints);
    }
  }

wrapup:
  EMWRAPUP(*EMmsg, sts, "In EMScomposite.EMintplane");
  return(sts);
}

end implementation EMScomposite;
