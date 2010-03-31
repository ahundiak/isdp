/* ###################   APOGEE COMPILED   ################## */
class implementation EMSgradata;

# include "EMS.h"

# ifndef EMSmsgdef_include
# include "EMSmsgdef.h"     /* EMS error codes  */
# endif

# ifndef EMSfrtdef_include
# include "EMSfrtdef.h"     /* EMSGD_UPTODATE  */
# endif

# ifndef EMSlogic_include
# include "EMSlogic.h"      /* EMSmsgReport     */
# endif

# ifndef EMStypedef_include
# include "EMStypedef.h"    /* EMSmsgReport     */
# endif

# ifndef EMScmacros_include
# include "EMScmacros.h"    /* EMSmsgReport     */
# endif

from EMSsubbs import EMgetRuleLineTable;

method EMupdate(IGRlong *EMmsg;
                IGRshort *mx_type; IGRmatrix mx;
                struct IGResqbs **rlt;
                struct IGResbs *bs_attr;
                struct IGRbsp_surface *surface;
                IGRchar *buffer; IGRint buffer_size;
                struct EMSpartolbasis *partol)
/*
    History

        msm     03 Oct 92   ANSI-C conversion.
        AIC     17 Apr 89   Do NOT store natural edges.
        AIC     28 Apr 88   Change EMFRT_UPTODATE to EMGD_UPTODATE.
        AIC            87   Genesis
*/
{
  IGRlong   sts;
  struct IGResqbs *locrlt = NULL;

  /*
   * Initialize
   */
  sts = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;
  if(!rlt) rlt = &locrlt;

  if(! (me^^EMShelper.props & EMGD_UPTODATE))
  {
    /*
     * Update myself
     */
   if(! *rlt)
    {
      IGRint            *u_stripes, *v_stripes;

      if(bs_attr)
      {
        u_stripes = (IGRint *)&bs_attr->u_rules;
        v_stripes = (IGRint *)&bs_attr->v_rules;
      }
      else
      {
        u_stripes = NULL;
        v_stripes = NULL;
      }

      /*
       * Get the surface's rule line table
       */
      {
        OM_S_CHANSELECT to_requesters;

        to_requesters.type = OM_e_addr;
        to_requesters.u_sel.addr = &me^^EMShelper.to_requesters;
        sts = om$send(msg = message EMSsubbs.EMgetRuleLineTable
                      (EMmsg, FALSE, u_stripes, v_stripes, surface,
                       (IGRint *)mx_type, mx, buffer, buffer_size, rlt),
                      p_chanselect = &to_requesters, from = 0, to = 0);
        if(! (1 & *EMmsg & sts)) goto wrapup;
      }
    }

    /*
     * Clip me according to the rule line table
     */
    sts = om$send(msg = message EMSgradata.EMclip(EMmsg, *rlt, partol,
                  mx_type, mx, surface), targetid = my_id);
    if(! (1 & *EMmsg & sts)) goto wrapup;
  }

wrapup:
  if(locrlt) om$dealloc(ptr = locrlt);

  EMSmsgReport(sts, "EMSgradata.EMupdate", FALSE);
  if EMSmsgReport(*EMmsg, "EMSgradata.EMupdate", FALSE) sts = OM_E_ABORT;
  return(sts);
}

end implementation EMSgradata;
