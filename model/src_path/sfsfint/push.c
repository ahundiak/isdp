#include <math.h>

#include "OMminimum.h"
#include "OMerrordef.h"
#include "igetypedef.h"

#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "gr.h"
#include "go.h"

#include "EMSmsgdef.h"
#include "EMSbnddef.h"
#include "EMSbnd.h"
#include "EMSprop.h"
#include "EMSopt.h"
#include "emsdef.h"
#include "emssfintdef.h"
#include "emsinterdef.h"
#include "emsdattyp.h"
#include "emsinter.h"
#include "emssfint.h"

#include "PWminimum.h"
#include "PWerror.h"
#include "PWgmdata.h"

/* Prototypes */
#include "bs.h"
#include "bserr.h"
#include "bsparameters.h"
#include "bsmdistptsf.h"
#include "bssfeval.h"

#include "msdef.h"
#include "ma.h"
#include "maidmx.h"


#include "PWapi/sfgeom.h"
#include "PWapi/edprops.h"
#include "PWapi/sflp.h"
#include "PWapi/lped.h"
#include "PWapi/edcons.h"

#include "PWapi/edptproj.h"
#include "PWapi/partol.h"
#include "PWapi/detrev.h"
#include "PWapi/changedata.h"
#include "PWapi/intcvpts.h"
#include "PWapi/edgeom.h"
#include "PWapi/mdstptgm.h"
#include "PWapi/objcons.h"

#define   START   0
#define   STOP    1 
#define   MID1    2
#define   MID2    3

static PWresult pwPushtoCommonEdge
(
  struct EMSintobj       *p_intobj,
  struct GRid            *p_csfid,
  struct EMSdataselect   *p_cdata,
  int                    *p_cctype,
  double                 xyztol,
  struct EMSsfintedpar   **pp_cincparms
);

static PWresult Getendinfo
(
  int                   numpts,
  double                *p_uvpts,
  PWobjid               edgeid,
  PWosnum               os,
  double                uvtol,
  struct EMSsfintedpar  **pp_cincparms
);

extern OMuword OPP_EMSdumedge_class_id;

PWresult   pwPushCoincEdges
(
  struct EMSinters **pp_inters,
  struct EMSintobj *p_intcv,
  double           xyztol
)
{
  PWresult                  retval;
  PWboolean                 reversed1=FALSE, reversed2=FALSE, edge_closed=FALSE,
                            intobj_reverse=FALSE, degenerate=FALSE, aflag=0;
  int                       cctype;
  IGRushort                 cintprops=0;
  long                      msg_loc, stat_OM, rc;
  struct IGRbsp_surface     *p_surface=NULL, *p_thissurf=NULL;
  struct EMSinters          *p_inters_loc=NULL;
  struct EMSintobj          *p_other_intobj=NULL, *p_new_intobj=NULL;
  struct EMSdataselect      cdata, cintdata;
  struct EMSsfintedpar      *cincparms=NULL, *tmpparm=NULL;
  struct GRid               csfid, *p_intedid=NULL;
  PWosnum                   os;
  PWobjid                   coincident_edgeid, common_edgeid;
  unsigned short            mattyp;
  double                    mat[16], uvtol;
  struct GRmd_env           rfenv;

  extern void               EMdelintobj(), EMcmpinters(), 
                            EMdataselect_data_free(), EMsfintedpar_free();
  extern IGRlong            EMmkintdata();
  extern struct EMSintobj   *EMmakeintlist();

  /*
   * Initialize local variables
   */
  msg_loc = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;
  cdata.datatype = EMSdata_null;
  cdata.data.object = NULL;
  cintdata.datatype = EMSdata_null;
  cintdata.data.object = NULL;
  common_edgeid = PW_K_NullObjid;
  
  /*
   * Get the identity matrix
   */
  if(aflag = pwIsActivationOn())
  {
    pwGetActiveModuleEnv(&rfenv);
    memcpy(mat, rfenv.md_env.matrix, sizeof(PWmatrix));
    mattyp = rfenv.md_env.matrix_type;
  }
  else
  {
    mattyp = 2;
    MAidmx (&rc, mat);
    OnErrorState (rc != MSSUCC, retval,
                  SetError (PW_K_BspMath, PW_K_Internal), wrapup);
  }

  p_inters_loc = p_intcv->this_obj_node;
  /*
   *  Get the uvtol for this surface from the xyz tol
   */
  retval = PW_GetSfBspsfStack (p_inters_loc->this_obj.objid, 
                      p_inters_loc->this_obj.osnum, mattyp, mat,
                      p_thissurf);
  OnErrorCode (retval, wrapup);
  uvtol = pwGetParTolSf (p_thissurf, xyztol);

  /*
   * Check if the uvintobj is an object.
   * If it is an object then check whether it is a dummy edge. 
   * A dummy edge has to be pushed across. (NOT IMPLEMENTED)
   */

  /*
   * If intobj is degenerate then continue
   */

  if ((p_intcv->props & EMSintobj_uvdegenerate) ||
      (p_intcv->props & EMSintobj_xyzdegenerate) ||
      (p_intcv->other_intobj_node->props & EMSintobj_uvdegenerate) ||
      (p_intcv->other_intobj_node->props & EMSintobj_xyzdegenerate))
  {
    p_intcv->props |= EMSintobj_marked;
    retval = SetSuccess (PW_K_Orientation, PW_K_Degenerate);
    goto wrapup;
  }
  if (!(p_intcv->props & EMSintobj_marked))
  {
    if (p_intcv->this_uvintobj.datatype == EMSdata_object)
    {
      /*
       * Intialize the loop variables
       */
      cincparms = NULL;
      cdata.datatype = EMSdata_null;
      cdata.data.object = NULL;
      cintdata.datatype = EMSdata_null;
      cintdata.data.object = NULL;

      p_intedid = p_intcv->this_uvintobj.data.object;
      os = p_intedid->osnum;
      coincident_edgeid = p_intcv->coinced;

      /*
       * Check if the coinced field in the EMSintobj structure points 
       * to some edge. 
       */
      if (coincident_edgeid != PW_K_NullObjid)
      {
        /*
         * Check if the coincident edge is closed and its end-points 
         * lie on the intobj, the intobj needs to be split into two at 
         * that point. Trimming should take care of this.  
         */
        /*
         * Here we assume that if the coincident edge is closed and the
         * edge start/stop point interacts with the intersection then
         * trimming splits the intersection into two pieces.
         */
        edge_closed = pwIsEdClosedXYZ (coincident_edgeid, os);
        /*
         * Check if the coincident edge and the intersection is flowing
         * in the same or opposite direction. If dirction of flow is 
         * opposite then this  intobj is a candidate for pushing.
         */
        intobj_reverse = pwDetIntReversal (coincident_edgeid, p_intcv,
                                           uvtol); 

        if (intobj_reverse)
        {
          retval = pwPushtoCommonEdge (p_intcv, &csfid, &cdata, 
                                       &cctype, xyztol, &cincparms);
          OnErrorCode (retval, wrapup); 
        }
        else
        {
          p_intcv->props |= EMSintobj_marked;
          goto wrapup;
        }

        /*
         * Make the intobj uv-dataselect
         */
        cintdata.datatype = EMSdata_null;
        stat_OM = EMmkintdata (&msg_loc, &cdata, cctype, NULL, FALSE,
                               NULL, NULL, TRUE, NULL, NULL, &cintdata);
        OnErrorState (!(1&stat_OM&msg_loc), retval,
                      SetError (PW_K_Pathway, PW_K_Internal), wrapup); 
        if (msg_loc == EMS_I_Degenerate)
          degenerate = TRUE;
        else
          degenerate = FALSE;

        cdata.data.object->objid = NULL_OBJID;
        EMdataselect_data_free (&msg_loc, &cdata, 1);
        cdata.datatype = EMSdata_null;
        cdata.data.object = NULL;

        /*
         * If the direction of the uv-data generated by the "pushtocommon"
         * call is the reverse of the xyz-data currently residing in 
         * intobj_loc, make it consistent and record the fact that the
         * true direction is the reverse of the current.
         */
        if (p_intcv->reversed)
        {
          pwEdRev (cintdata.data.object->objid, 
                   cintdata.data.object->osnum);

          /*
           * Reverse 'cintdata.data.object' uvgeometry
           */
          tmpparm   = cincparms;
          cincparms = cincparms->next;
          cincparms->next = tmpparm;
          cincparms->next->next = NULL;
         
          reversed1 = TRUE;
        }
        else
        {
          reversed1 = FALSE;
        }
        /* check this one */
        /*******
        bit_mask = EMSintobj_coincident | EMSintobj_dupothersurf |
                   EMSintobj_dupthissurf | EMSintobj_nonoriented |
                   EMSintobj_deletable | EMSintobj_xyzdegenerate;
        cintprops = (p_intcv->props & bit_mask) |
                    (degenerate ? EMSintobj_uvdegenerate : NULL);
        *******/
        p_other_intobj = p_intcv->other_intobj_node;

        /*
         * Delete the present intobj keeping only the this_xyzintobj
         * dataselect.
         */
        p_intcv->this_xyzintobj.datatype = EMSdata_null;
        p_intcv->other_intobj_node = NULL;
        EMdelintobj (&msg_loc, p_intcv);
        OnErrorState (!(1&msg_loc), retval,
                      SetError (PW_K_Pathway, PW_K_Internal), wrapup);

        /*
         * The "bad" coincidence is based on the relative direction between
         * the "dummy-edge" and it's "full-edge". If the "full-edge" is
         * reverse connected to it's common-edge then the new, pushed
         * intersection edge being generated on this common-edge is 
         * already in * the correct direction, viz, opposite in quality. 
         * Otherwise, * it has to be reversed.
         */
        reversed2 = !(pwIsEdRevConn (coincident_edgeid, os));

        /*
         * The pushed intersection is now put back into the intersection
         * list, taking care to see that the reverse-flag is set as the
         * exclusive OR of the two calls for reversal.
         */
        p_surface = NULL;
        /*
         * Get the surface geometry
         */
        retval = PW_GetSfBspsfHeap (csfid.objid, csfid.osnum, mattyp, mat,
                           p_surface);
        OnErrorCode (retval, wrapup);
        /*
         * Make the new intobj node
         */
        p_new_intobj = EMmakeintlist (&msg_loc, pp_inters, NULL, 
                       &csfid, NULL,
                       p_surface, NULL, NULL, NULL,
                       p_other_intobj ?&p_other_intobj->this_xyzintobj:NULL,
                       &cintdata, NULL,
                       reversed1 ^ reversed2, NULL,
                       cincparms, NULL,
                       cintprops, NULL,
                       &cctype, NULL,
                       TRUE, FALSE);
        OnErrorState (!(1&msg_loc), retval,
                      SetError (PW_K_Pathway, PW_K_Internal), wrapup);
        if (p_other_intobj)
        {
          p_new_intobj->other_intobj_node = p_other_intobj;
          p_other_intobj->other_intobj_node = p_new_intobj;
        }
        p_new_intobj->props |= EMSintobj_marked;
        /*
         * Obtain the common edge corresponding to the coincident edge.
         */
        common_edgeid = pwGetCommonEd (coincident_edgeid, os);
        p_new_intobj->coinced = common_edgeid;
        cincparms = NULL;
      }

    }/* if datatype is dataobject */
  }/* if intobj is not marked */
  wrapup:
  EMdataselect_data_free (&msg_loc, &cdata, 1);
  cdata.datatype = EMSdata_null;
  if (cincparms)
  {
    EMsfintedpar_free (cincparms, MAXINT);
    cincparms = NULL;
  }
  return (retval);
}/* end of function pwPushCoincEdges */


static PWresult pwPushtoCommonEdge 
(
  struct EMSintobj       *p_intobj, 
  struct GRid            *p_csfid, 
  struct EMSdataselect   *p_cdata, 
  int                    *p_cctype,
  double                 xyztol,
  struct EMSsfintedpar   **pp_cincparms
)
{
  PWresult               retval;
  int                    i, numpts ;
  long                   rc, msg_loc, stat_OM;
  PWosnum                os;
  PWpoint                temp_pt;
  PWobjid                common_edgeid, common_lpid, common_sfid;
  PWboolean              revgeom=FALSE, free_xyzcvdata=FALSE, aflag=0;
  PWpoint                xyzendpts[4], startptxyz, stopptxyz;
  PWpoint2d              startpt, stoppt;
  double                 uvtol, uvpts[8], temp_dist=0;
  unsigned short         mattyp;
  PWmatrix               mat;
  struct GRid            *object=NULL;
  struct IGRbsp_surface  *p_surface=NULL;
  struct EMSsfintedpar   *epptr=NULL;
  struct EMSedgebound    startpar, stoppar;
  struct EMSpartedinfo   partinfo;
  struct PWcvpt          loc_xyzcvpt[2];
  enum  EMScvinttype     startloc, stoploc;
  struct PWcvdata        loc_xyzcvdata;
  /** OM_S_CHANSELECT        chan_to_edge, chan_to_owner; ***/
  extern  IGRint         EMgetendpts_xyz();
  extern  IGRlong        EFget_clipped_edge_type();
  extern  void           EFtoggle();

  struct PWcvparam       edbounds[2];
  struct GRmd_env        rfenv;


  os = p_intobj->this_uvintobj.data.object->osnum;
  p_csfid->osnum = os;
  retval = PW_K_Success;
  mattyp = 2;
  numpts = 2;
  loc_xyzcvdata.datatype = PWcvdata_null;
  loc_xyzcvpt[0].p_attrib = NULL;
  loc_xyzcvpt[1].p_attrib = NULL;
  /*
   * Get the identity matrix
   */
  if(aflag = pwIsActivationOn())
  {
    pwGetActiveModuleEnv(&rfenv);
    memcpy(mat, rfenv.md_env.matrix, sizeof(PWmatrix));
    mattyp = rfenv.md_env.matrix_type;
  }
  else
  {
    MAidmx (&rc, mat);
    OnErrorState (rc != MSSUCC, retval,
                  SetError (PW_K_BspMath, PW_K_Internal), wrapup);
  }
  /*
   * Obtain the common edge corresponding to the coincident edge.
   */
  common_edgeid = pwGetCommonEd (p_intobj->coinced, os);
  
  /*
   * Get the common edge surface id.
   */
  common_lpid = pwGetLpOfEd (common_edgeid, os);
  common_sfid = pwSfOfLp (common_lpid, os);
  p_csfid->objid = common_sfid;
  /*
   * Get the common edge surface geometry and the uvtol
   */
  retval = PW_GetSfBspsfStack (common_sfid, os, mattyp, mat, p_surface);
  OnErrorCode (retval, wrapup);
  uvtol = pwGetParTolSf (p_surface, xyztol);
  
  /*
   *  Obtain the common edge props and type
   */
  *p_cctype = pwGetEdCvType (common_edgeid, os);
  /*
   * Get the edge type from 'p_cctype' by calling EFget_clipped_edge_type
   */
  EFget_clipped_edge_type (&msg_loc, (IGRuchar)(*p_cctype), 
                           (IGRuchar *)p_cctype);
  /**
  OnErrorState (!(!&msg_loc), retval,
                SetError (PW_K_Pathway, PW_K_Internal), wrapup);
  **/
  /*
   * The edge parameters on the common edge that match the endpoints
   * of the model space edge/geometry are determined.
   */
  
  /*
   * The endpoints have to be obtained by projection as there is no
   * direct topology to these values. Special care needs to be taken
   * if the projected uvpts lie on some seam edge. An ambiguous situation
   * exists.
   */

  /*
   * Get xyz endpts of the input 'p_intobj->this_xyzintobj' considering the
   * reversed bit. Store it in xyzendpts[0:1]
   */
  stat_OM = EMgetendpts_xyz (&msg_loc, &mattyp, mat, 
                             &(p_intobj->this_xyzintobj), 
                             p_intobj->reversed, 1,
                             xyzendpts[START],  xyzendpts[STOP]);
  OnErrorState (!(1&stat_OM&msg_loc), retval,
                SetError (PW_K_Pathway, PW_K_Internal), wrapup);
  if ( pwIsEdClosedXYZ (common_edgeid, os))
  {
    /*
     * The common edge runs from one seam-line of the common-surface
     * to the other (eg, cylinder) or the common-edge is closed in uv itself.
     * In these cases, internal point(s) are required to differentiate the
     * true section of the edge. See update in next para.
     */
    /*
     * Obtain 2 internal points from the input 'p_intobj->this_xyzintobj'
     * store it in 'xyzendpts[2:3]' honouring the reversed field make
     * numpts=4;
     */
    /*
     * Convert the input dataselect structure for this_xyzintobj into a PWcvdata
     */
    retval = pwChangeEMSCvdata (&(p_intobj->this_xyzintobj), &loc_xyzcvdata,
                                mattyp, mat, &free_xyzcvdata);
    OnErrorCode (retval, wrapup);
    /*
     * Get two internal xyz-point on the input xyzintobj and store it in
     * xyzedpts[2]
     */
    retval = pwGetInternalCvPts (&loc_xyzcvdata, 2, PWtopopos_middle, 
                                 loc_xyzcvpt);
    OnErrorCode (retval, wrapup);
    /*
     * Check for the intobj reversed flag. We need to store the internal
     * points along the logical flow of the edge.
     */
    if (!(p_intobj->reversed))
    {
      memcpy (xyzendpts[2], loc_xyzcvpt[0].pt, 3*sizeof(double));
      memcpy (xyzendpts[3], loc_xyzcvpt[1].pt, 3*sizeof(double));
    }
    else
    {
      memcpy (xyzendpts[2], loc_xyzcvpt[1].pt, 3*sizeof(double));
      memcpy (xyzendpts[3], loc_xyzcvpt[0].pt, 3*sizeof(double));
    }
  }
  /*
   *  Obtain the uvparameters corresponding to the xyzpts on the common
   *  edge surface
   */
  for (i=START; i<=STOP; i++)
  {
    BSmdistptsf (&rc, p_surface, xyzendpts[i], &uvpts[i*2], &uvpts[i*2+1],
                 temp_pt, &temp_dist);
    OnErrorState (rc != BSSUCC, retval,
                  SetError (PW_K_BspMath, PW_K_Internal), wrapup);
  }
  /*
   * Now we have to do some further processing to avoid problems caused
   * by seam. If the next or the previous edge of the common edge is a
   * seam edge then due to mapping the uvpoints obtained above may go to
   * the other side. This can be avoided by making a direct xyz check 
   * with the intersection endpoints and the common-edge endpoints.
   */
  pwGetEdEndPts (common_edgeid, os, startpt, stoppt);
  BSsfeval (p_surface, startpt[0], startpt[1], 0, &startptxyz, &rc);
  OnErrorState (rc != BSSUCC, retval,
                SetError( PW_K_BspMath, PW_K_Internal), wrapup);
  BSsfeval (p_surface, stoppt[0], stoppt[1], 0, &stopptxyz, &rc);
  OnErrorState (rc != BSSUCC, retval,
                SetError( PW_K_BspMath, PW_K_Internal), wrapup);
    
  if (pwDistPtPt (xyzendpts[0], startptxyz) < xyztol)
  {
    memcpy (uvpts, startpt, 2*sizeof(double));
  }
  else if (pwDistPtPt (xyzendpts[0], stopptxyz) <xyztol)
  {
    memcpy (uvpts, stoppt, 2*sizeof(double));
  }
  if (pwDistPtPt (xyzendpts[1], startptxyz) <xyztol)
  {
     memcpy (&uvpts[2], startpt, 2*sizeof(double));
  }
  else if (pwDistPtPt (xyzendpts[1], stopptxyz) < xyztol)
  {
    memcpy (&uvpts[2], stoppt, 2*sizeof(double));
  }

  if ( pwIsEdClosedXYZ (common_edgeid, os))
  {
    /*
     * If the common edge is a closed one then take the start/stop points
     * along with middle point and decide which side to be kept.
     */
    for (i=MID1; i<=MID2; i++)
    {
      BSmdistptsf (&rc, p_surface, xyzendpts[i], &uvpts[2*i], &uvpts[2*i +1],
                   temp_pt, &temp_dist);
      OnErrorState (rc != BSSUCC, retval,
                    SetError (PW_K_BspMath, PW_K_Internal), wrapup);
    }
    numpts=4;
  }
   
  /*
   * The end-point information on the to-be-extracted part is formatted
   * into the EMSsfintedpar linked list for output.
   */
  Getendinfo (numpts, uvpts, common_edgeid, os, uvtol, pp_cincparms);
  epptr = *pp_cincparms;
  startloc = epptr->intloc;
  stoploc = epptr->next->intloc;
  if (startloc == EMScvint_middle || stoploc == EMScvint_middle)
  {
    partinfo.edprops = (pwIsEdDegen (common_edgeid, os) ? EMED_DEGENERATE :0)
                       |(pwIsEdIso (common_edgeid, os) ? EMED_ISO : 0)
                       |(pwIsEdNatural (common_edgeid, os) ? EMED_NATURAL :0);
    partinfo.edprops |= EMED_OPEN;
    partinfo.edprops &= ~EMED_XYZ_CLOSED;

    revgeom = FALSE;
    startpar = epptr->edgepar;
    stoppar = epptr->next->edgepar;
    if (startpar.span_inx + startpar.param >
        stoppar.span_inx + stoppar.param)
    {
      partinfo.edprops |= EMED_REVERSED;
    }
    partinfo.edbdry[START] = startpar;
    partinfo.edbdry[STOP] = stoppar;
    partinfo.edid = NULL_OBJID;
  }
  else
  {
    partinfo.edprops = (pwIsEdNatural (common_edgeid, os) ? EMED_NATURAL :0)
                      |(pwIsEdOpen (common_edgeid, os) ? EMED_OPEN :0)
                      |(pwIsEdClosedXYZ (common_edgeid, os) ? 
                                         EMED_XYZ_CLOSED :0)
                      |(pwIsEdRev (common_edgeid, os) ? EMED_REVERSED :0)
                      |(pwIsEdDegen (common_edgeid, os) ? EMED_DEGENERATE :0)
                      |(pwIsEdIso (common_edgeid, os) ? EMED_ISO : 0) ;
    if (startloc == EMScvint_rtend)
    {
      revgeom = TRUE;
    }
    else
    {
      revgeom = FALSE;
    }
    startpar = epptr->edgepar;
    stoppar = epptr->next->edgepar;
    partinfo.edbdry[START] = startpar;
    partinfo.edbdry[STOP] = stoppar;
    /*
     * Obtain the 'partinfo.edbdry' from the common_edgeid 
     * (call to EMgetbounds) Assume that the points returned are exact.
     */
    if (revgeom)
    {
      EFtoggle (EMED_REVERSED, &partinfo.edprops);
    }
    partinfo.edid = PW_K_NullObjid;
  }
  /*
   * Extract the parameteric space geometry within the bounds just computed.
   * Then a part-edge is created 
   */
  /*
   * Create the part edge and connect it to the common edge. This object
   * is returned as the functions output
   */

  /*
   * connect this object to the common edge
   */

  object = (struct GRid *)malloc (sizeof (struct GRid));
  p_cdata->datatype = EMSdata_object;
  p_cdata->data.object = object;

  edbounds[FIRST].spaninx  = partinfo.edbdry [FIRST].span_inx; 
  edbounds[FIRST].spanpar  = partinfo.edbdry [FIRST].param ;
  edbounds[SECOND].spaninx = partinfo.edbdry [SECOND].span_inx; 
  edbounds[SECOND].spanpar = partinfo.edbdry [SECOND].param ;

  object->objid = pwCreateDummyEdge (common_edgeid, os, edbounds, 
                    (int) partinfo.edprops, (int) *p_cctype);
  OnErrorState ((object->objid == PW_K_NullObjid), retval, 
                SetError (PW_K_Pathway, PW_K_Internal), wrapup);
  object->osnum = os;

wrapup:
  if (free_xyzcvdata)
  {
    pwFreeCvdata (&loc_xyzcvdata);
  }
  return (retval);
}/* end of function pwPushtoCommonEdge */


static PWresult Getendinfo
(
  int                   numpts,
  double                *p_uvpts,
  PWobjid               edgeid,
  PWosnum               os,
  double                uvtol,
  struct EMSsfintedpar  **pp_cincparms
)
{
  PWresult              retval;
  int                   i, endinx;
  long                  msg_loc;
  struct  PWid          edobj;
  struct  PWcvpt        cvpt[4], cvpttmp;
  PWpoint2d             loc_uvpt, startpt, stoppt;
  struct  EMSedgebound  param;
  enum PWtopopostype    topo, topo0, topo1;
  struct PWcvparam      startpar, stoppar;
  enum EMScvinttype     location=EMScvint_unknown;
  double                val0=0.0, val1=0.0, val2=0.0, val3=0.0;

  /*
   * Initialize
   */
  retval = PW_K_Success;
  cvpt[0].p_attrib = NULL;
  cvpt[1].p_attrib = NULL;
  cvpt[2].p_attrib = NULL;
  cvpt[3].p_attrib = NULL;
  edobj.objid = edgeid;
  edobj.osnum = os;
  
  /*
   * Obtain the paramteric points on the edge that correspond to the
   * input points. The first two points are the primary points. In cases
   * where the surface is physically closed, some ambiguity might arise
   * when the parametric point lies on a seam edge. This is resolved here
   * as far as possible.
   */
  /* 
   * Do a point project on to the common edge with the uv points.
   * In case of a closed there will be four uvpoints. (startpt, stoppt
   * and two internal points of the intersection) 
   */
  retval = pwEdPtProject (&edobj, numpts, (PWpoint2d *)p_uvpts, uvtol,
                          cvpt);
  OnErrorCode (retval, wrapup);
  if (pwIsEdClosedXYZ (edgeid, os))
  {
    /*
     * Store the topological position of the start/stop point of the 
     * intersection on the common edge
     */
    topo0 = pwGetTopoposCvpt (&cvpt[START]);
    topo1 = pwGetTopoposCvpt (&cvpt[STOP]);

    /*
     * Get the parameter values corresponding to the four uvpoints
     */
    val0 =  cvpt[START].cvparam.spaninx + cvpt[START].cvparam.spanpar;
    val1 =  cvpt[STOP].cvparam.spaninx + cvpt[STOP].cvparam.spanpar;
    val2 =  cvpt[MID1].cvparam.spaninx + cvpt[MID1].cvparam.spanpar;
    val3 =  cvpt[MID2].cvparam.spaninx + cvpt[MID2].cvparam.spanpar;

    /*
     * Get the end points and end parameters for the common edge.
     */
    pwGetEdEndPts (edobj.objid, edobj.osnum, startpt, stoppt);
    pwGetEdEndPars (edobj.objid, edobj.osnum, &startpar, &stoppar);

    /*
     * When at least one start/stop point is at the start/stop and both
     * both the topological positions are not same (unlike  start/start, 
     * stop/stop, middle/middle)
     */
    if (topo0 != topo1)
    {
      if ((topo0 == PWtopopos_start) || (topo0 == PWtopopos_stop) ||
          (topo1 == PWtopopos_start) || (topo1 == PWtopopos_stop))
      {
        /*
         * If the internal point parameter value is not within the end
         * point parameter values. Then get the other end point 
         * parameter.
         */
        if (!(((val0<val2) && (val2<val1)) || 
            ((val1<val2) && (val2<val0))) )
        {
          if (topo0 == PWtopopos_start) 
          {
            cvpt[START].cvparam = stoppar;
            cvpt[START].pt[0] = stoppt[0];
            cvpt[START].pt[1] = stoppt[1];
            pwSetTopoposCvpt (&cvpt[START], PWtopopos_stop);
          }
          else if (topo0 == PWtopopos_stop)
          {
            cvpt[START].cvparam = startpar;
            cvpt[START].pt[0] = startpt[0];
            cvpt[START].pt[1] = startpt[1];
            pwSetTopoposCvpt (&cvpt[START], PWtopopos_start);
          }
          else if (topo1 == PWtopopos_start)
          {
            cvpt[STOP].cvparam = stoppar;
            cvpt[STOP].pt[0] = stoppt[0];
            cvpt[STOP].pt[1] = stoppt[1];
            pwSetTopoposCvpt (&cvpt[STOP], PWtopopos_stop);
          }
          else if (topo1 == PWtopopos_stop)
          {
            cvpt[STOP].cvparam = startpar;
            cvpt[STOP].pt[0] = startpt[0];
            cvpt[STOP].pt[1] = startpt[1];
            pwSetTopoposCvpt (&cvpt[STOP], PWtopopos_start);
          }
        }
      }
    }
    else /* both topopos are same. */
    {
      if (topo0 == PWtopopos_start)
      {
        cvpt[START].cvparam = stoppar;
        cvpt[START].pt[0] = stoppt[0];
        cvpt[START].pt[1] = stoppt[1];
        pwSetTopoposCvpt (&cvpt[START], PWtopopos_stop);
      } 
      else if (topo0 == PWtopopos_stop)
      {
        cvpt[START].cvparam = startpar;
        cvpt[START].pt[0] = startpt[0];
        cvpt[START].pt[1] = startpt[1];
        pwSetTopoposCvpt (&cvpt[START], PWtopopos_start);
      }
    }
    /*
     * Update the parameter values for further checking.
     */
    val0 =  cvpt[START].cvparam.spaninx + cvpt[START].cvparam.spanpar;
    val1 =  cvpt[STOP].cvparam.spaninx + cvpt[STOP].cvparam.spanpar;
    val2 =  cvpt[MID1].cvparam.spaninx + cvpt[MID1].cvparam.spanpar;
    val3 =  cvpt[MID2].cvparam.spaninx + cvpt[MID2].cvparam.spanpar;

    /*
     * Swap the parameter values depending upon the flow direction of the
     * intersection. This can be determined by checking the parameter
     * values 'val2' and 'val3'
     */
    if ((val3 >val2 && val1 < val0) || (val3 <val2 && val1 >val0))
    {
      cvpttmp.cvparam = cvpt[START].cvparam;
      cvpttmp.pt[0] = cvpt[START].pt[0];
      cvpttmp.pt[1] = cvpt[START].pt[1];
      pwSetTopoposCvpt (&cvpttmp, pwGetTopoposCvpt (&cvpt[START]));

      cvpt[START].cvparam = cvpt[STOP].cvparam;
      cvpt[START].pt[0] = cvpt[STOP].pt[0];
      cvpt[START].pt[1] = cvpt[STOP].pt[1];
      cvpt[START].pt[2] = 0.0;
      pwSetTopoposCvpt (&cvpt[START], pwGetTopoposCvpt (&cvpt[STOP]));

      cvpt[STOP].cvparam = cvpttmp.cvparam;
      cvpt[STOP].pt[0] = cvpttmp.pt[0];
      cvpt[STOP].pt[1] = cvpttmp.pt[1];
      cvpt[STOP].pt[2] = 0.0;
      pwSetTopoposCvpt (&cvpt[STOP], pwGetTopoposCvpt (&cvpttmp));
    }
  }
  for (endinx = START; endinx<=STOP; endinx++)
  {
    loc_uvpt[0] = cvpt[endinx].pt[0];
    loc_uvpt[1] = cvpt[endinx].pt[1];
    param.param = cvpt[endinx].cvparam.spanpar;
    param.span_inx = cvpt[endinx].cvparam.spaninx;
    topo = pwGetTopoposCvpt (&cvpt[endinx]);
    switch (topo)
    {
      case PWtopopos_start :
           location = EMScvint_lfend;
           break;
      case PWtopopos_stop :
           location = EMScvint_rtend;
           break;
      case PWtopopos_middle :
           location = EMScvint_middle;
           break;
    }
    
    EMmkeparlist (&msg_loc, pp_cincparms, location, edgeid, 
                  param.span_inx, param.param, loc_uvpt, NULL, FALSE);
    OnErrorState (!(1&msg_loc), retval,
                  SetError (PW_K_Pathway, PW_K_Internal), wrapup);
  } 
  wrapup:
  for (i=START; i<=STOP; i++)
  {
    if (cvpt[i].p_attrib)
    {
      pwFreeAttribList (cvpt[i].p_attrib);
      cvpt[i].p_attrib = NULL;
    }
  }
  return retval;
}
