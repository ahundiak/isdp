/* $Id: VLunwrapFk2.I,v 1.2 2001/02/20 01:06:56 build Exp $  */

/* --------------------------------------------------------------------
 * I/LOFT
 *
 * File:        loftdp/src/unfold/VLunwrapFk2.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VLunwrapFk2.I,v $
 *      Revision 1.2  2001/02/20 01:06:56  build
 *      Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *      Revision 1.1.1.1  2001/01/04 21:11:42  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:32:50  pinnacle
# LOFT 2.5.1
#
# Revision 1.1  1997/05/08  14:05:56  pinnacle
# Loft 250
#
# Revision 1.5  1997/01/29  20:33:12  pinnacle
# Replaced: src/unfold/VLunwrapFk2.I for:  by rchennup for loft
#
# Revision 1.4  1996/11/01  06:08:12  pinnacle
# Replaced: src/unfold/VLunwrapFk2.I for:  by rchennup for loft
#
# Revision 1.3  1996/05/01  06:57:06  pinnacle
# Replaced: src/unfold/VLunwrapFk2.I for:  by rchennup for loft
#
# Revision 1.2  1996/01/31  09:07:44  pinnacle
# Replaced: src/unfold/VLunwrapFk2.I for:  by svkadamb for loft
#

 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *
 * -------------------------------------------------------------------*/


class implementation VLabstract;


#include <stdio.h>
#include <math.h>
#include "vlprototype.h"

#include "OMprimindex.h"
#include "OMprimitives.h"
#include "OMminimum.h"
#include "OMerrordef.h"

#include "igetypedef.h"
#include "igrtypedef.h"
#include "igrdef.h"
#include "igrdp.h"
#include "godef.h"
#include "madef.h"
#include "gr.h"
#include "growner.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "dp.h"
#include "bserr.h"
#include "bstypes.h"
#include "maerr.h"
#include "bs.h"
#include "bsparameters.h"
#include "EMSmsgdef.h"
#include "msdef.h"
#include "OMindex.h"
#include "OMmacros.h"
#include "EMSssprops.h"
#include "EMSdpb.h"
#include "EMSopt.h"
#include "grmacros.h"
#include "dpezmac.h"
#include "igr.h"
#include "griodef.h"
#include "go.h"
#include "ex.h"
#include "grio.h"
#include "nddef.h"
#include "asmacros.h"
#include "parametric.h"
#include "csdef.h"
#include "values.h"
#include "asmacros.h"
#include "bsicmpcvoff.h"
#include "vsmiscmacros.h"
#include "vlcntrline.h"
#include "vlmark.h"
#include "vlrolline.h"
#include "bsvalues.h"
#include "vsedgedef.h"
#include "vsedgemacros.h"
#include "vlglinedef.h"
#include "vlstructure.h"
#include "expmacros.h"
#include "expression.h"
#include "vsplatedef.h"
#include "griomacros.h"
#include "vlgrmacros.h"
#include "vlgrdef.h"
#include "vsgeommacros.h"
#include "vsstfnrdef.h"
#include "grdpbmacros.h"
#include "vlquerydef.h"
#include "vsbmaxisdef.h"
#include "vltemplate.h"
#include "vlunfold.h"
#include "exmacros.h"
#include "exproto.h"
#include "DIprims.h"
#include "vlforkmacros.h"
#include "ACrg_collect.h"
#include "ACattrib.h"
#include "vlstifftpl.h"
#include "vldbgmacros.h"

  
extern GRclassid        OPP_VLctrLine_class_id;
extern GRclassid        OPP_VLmrkLine_class_id;
extern GRclassid        OPP_VLrolLine_class_id;
extern GRclassid        OPP_VLbutLine_class_id;
extern GRclassid        OPP_VLwatLine_class_id;
extern GRclassid        OPP_VLseaLine_class_id;
extern GRclassid        OPP_VLtrace_class_id;
extern GRclassid        OPP_VLgenLine_class_id;
extern GRclassid        OPP_VLtplMgr_class_id;
extern GRclassid        OPP_VSmrkPlate_class_id;

extern 			BSchtptstsf();
extern 			BSchtptstso();
extern 			BSsfarrevn();
extern 			BSkts_f_fit();
extern 			BSkts_f_app();
extern 			BSrev_cv();
extern			GRdpb_get();
extern			GRdpb_put();
extern	IGRdouble	BSdistptpt();
extern	IGRboolean	BScrossp();
extern	IGRdouble	BSdotp();
extern	IGRdouble	BSlenvec();
extern  IGRboolean	BSnorvec();
extern  void		BSchtptstcv();
extern	void		BSalloccv(), BSallocsf();
extern	IGRboolean	BSfreecv(), BSfreesf();
extern  IGRchar		*memcpy();
extern  void		BSsfeval();
extern			GRdisplay_object();
extern  IGRdouble	sqrt();
extern	IGRdouble	cos(),fabs();
extern			ASmake_source_from_env();
extern IGRint 		MAinvmx();
extern IGRint 		MAmulmx();
extern IGRboolean	MAtypemx();
extern IGRint 		BSsfevaln();
extern 			VLbrowseFctInTree();
extern 			VLfilterClass();
extern  int             VLgetMacrosAtStep();
extern  void            FAevPtSfFaDr();
extern struct GRid      NULL_GRID;


/* ************************************************************************ */
/*   Given a plate, this function find all lines attached to it.            */
/* ************************************************************************ */
IGRint VLget_lines (dev,plate,opt,md_env,count,list)
struct 	mise_a_plat	*dev;         /*I: unwrapping structure */
struct GRobj_env	*plate;       /* I : plate */
int			opt;          /* I: option :
					 0-->the returned number (count) 
                                             will contain, in addition of
					     the number of lines, the number
                                             of feet-lines in rolLine and 
                                             mark objects. 
				         1-->we dont take into account
                                             the feet-line number of rolLine 
                                             and mark objects */

struct GRmd_env		*md_env;
int	        	*count;       /* O : number of found lines */
struct GRobj_env       	**list;       /* O : list of found lines */
{
int			count1,Mgr_count,i,dim = 4;
int			count2,len,j;
int     		save_count,ln_to_add,k;
long    		sts,msg,loc_msg;
int     		nbline,UnwLnsOptions[UNFOLD_NB_OPTLINE];
struct GRobj_env 	*tp_manager=NULL,*cntrl=NULL;
int     		mark_roll=0;
int         		nb_child;
VLquLine                Query[IDX_SC_SIZE];
IGRdouble               RangTol,ChtTol;
struct GRobj_env        *buf=NULL,*Qline = NULL;

  msg = 0;
  Mgr_count = 0;
  *count = 0;

     /* Return associative elements attached to this node */
  VLbrowseFctInTree( plate, VL_Q_TOP_SOURCE, NULL,
                     VL_Q_DOWN_DIRECT,
                     VLgetMacrosAtStep,
                     count, list );
  save_count = *count;


  VLdecode(dev->WantedLinesCode,UNFOLD_NB_OPTLINE, UnwLnsOptions);
   
  BSxtractpar ( &loc_msg, BSTOLCHRDHT, &ChtTol);
  RangTol = 5 * ChtTol;

  if (UnwLnsOptions[UNFOLD_ATT_IDX_BUTT] ) {
       VLqLineStfTpl (Query);
       /* We need just Butt Lines */
       for ( i=0; i<IDX_SC_SIZE; i++)
         Query[i].query = 0;
       Query[IDX_SC_BUTT].query = 1;
   
       /* Query for lines in the range of plate surface */
       sts = VLqueryStfTpl ( &dev->surf_id, NULL, Query, RangTol,
                             md_env, &nbline, &Qline, &i,
                             &buf, &loc_msg);
       if (!(sts&loc_msg&1)) goto quit;
       if (nbline) {
         (* list) = ( struct GRobj_env * )
          om$realloc(ptr= (char *) (* list),
                     size = ((*count)+nbline)*sizeof( struct GRobj_env ) );
           if ((* list) == NULL) goto quit;
           for (i=0;i<nbline;i++) (* list)[i+(*count)] = Qline[i];
           (*count) += nbline;
       }
  }

  if (UnwLnsOptions[UNFOLD_ATT_IDX_SEAM] ) {
       VLqLineStfTpl (Query);
       /* We need just Seam Lines */
       for ( i=0; i<IDX_SC_SIZE; i++)
         Query[i].query = 0;
       Query[IDX_SC_SEAM].query = 1;
   
       /* Query for lines in the range of plate surface */
       sts = VLqueryStfTpl ( &dev->surf_id, NULL, Query, RangTol,
                             md_env, &nbline, &Qline, &i,
                             &buf, &loc_msg);
       if (!(sts&loc_msg&1)) goto quit;
       if (nbline) {
         (* list) = ( struct GRobj_env * )
          om$realloc(ptr= (char *) (* list),
                     size = ((*count)+nbline)*sizeof( struct GRobj_env ) );
           if ((* list) == NULL) goto quit;
           for (i=0;i<nbline;i++) (* list)[i+(*count)] = Qline[i];
           (*count) += nbline;
       }
  }

  if (UnwLnsOptions[UNFOLD_ATT_IDX_TRACE] ) {
       VLqLineStfTpl (Query);
       /* We need just Trace Lines */
       for ( i=0; i<IDX_SC_SIZE; i++)
         Query[i].query = 0;
       Query[IDX_SC_TRAC].query = 1;
   
       /* Query for lines in the range of plate surface */
       sts = VLqueryStfTpl ( &dev->surf_id, NULL, Query, RangTol,
                             md_env, &nbline, &Qline, &i,
                             &buf, &loc_msg);
       if (!(sts&loc_msg&1)) goto quit;
       if (nbline) {
         (* list) = ( struct GRobj_env * )
          om$realloc(ptr= (char *) (* list),
                     size = ((*count)+nbline)*sizeof( struct GRobj_env ) );
           if ((* list) == NULL) goto quit;
           for (i=0;i<nbline;i++) (* list)[i+(*count)] = Qline[i];
           (*count) += nbline;
       }
  }

      /* find template manager objects because they can
                                             contain control lines objects */ 
  VLfilterClass(*count,(*list),&Mgr_count,OPP_VLtplMgr_class_id);
  if (Mgr_count) {
    cntrl = (struct GRobj_env *) malloc(Mgr_count*sizeof(struct GRobj_env));
    if (cntrl == NULL) goto quit;
    tp_manager = (struct GRobj_env *)
                              malloc(Mgr_count*sizeof(struct GRobj_env));
    if (tp_manager == NULL) goto quit;
  }
  for (i=0;i<Mgr_count;i++)
  {
    tp_manager[i] = (*list)[i];
            /* find control lines attached to each template Manager */
    sts = om$send( msg      = message NDmacro.ACreturn_foot(
                                          &loc_msg,
                                          NAM_TM_CTRL,
                                          &cntrl[i].obj_id,
                                          &cntrl[i].mod_env.md_env.matrix_type,
                                          cntrl[i].mod_env.md_env.matrix),
                         targetid = (*list)[i].obj_id.objid,
                         targetos = (*list)[i].obj_id.osnum,
                         senderid = NULL_OBJID ) ;
    if (!(sts & loc_msg &1)) {
      goto quit;
    }
    if ((*list)[i].mod_env.md_env.matrix_type != MAIDMX) {
      MAmulmx(&loc_msg,&dim,&dim,&dim,(*list)[i].mod_env.md_env.matrix,
              cntrl[i].mod_env.md_env.matrix,cntrl[i].mod_env.md_env.matrix);
      MAtypemx( &loc_msg, cntrl[i].mod_env.md_env.matrix,
                                     &cntrl[i].mod_env.md_env.matrix_type);
    }
  }

        /* find genline objects */
  VLfilterClass(*count,(*list),count,OPP_VLgenLine_class_id);
  len = *count;
  count1 = 0;

       /* find control lines directly attached to the plate */
  VLfilterClass(len,&(*list)[count1],&count2,OPP_VLctrLine_class_id);

      /* No more then six control lines on the plate (three on each side
         with respect to x, y or z axis), so we eleminate supplement
         control lines */
  sts = VLfilterCntLn(Mgr_count,cntrl,tp_manager,count2,(*list),&ln_to_add);
  if (!(sts&1)) goto quit;

  if (ln_to_add > 0) { // add control lines of the template manager objects
    (*list) = (struct GRobj_env *) om$realloc(
                        ptr = (char *) (*list),
                        size = (save_count + ln_to_add)*sizeof(struct GRobj_env)
                                              );
    for (i= (*count)-1; i>=count2;i--)
    (*list)[i+ ln_to_add] = (*list)[i];
  }
  k = count2;
  for (i=0;i<Mgr_count;i++)
  {                
    if (cntrl[i].obj_id.objid != NULL_OBJID) {
      for (j=0;j<count2;j++)
      {                   // try to add control lines in the empty places.
        if ((*list)[j].obj_id.objid == NULL_OBJID){
          (*list)[j] = cntrl[i];
          break;
        }
      }
      if (j==count2) {
        (*list)[k] = cntrl[i];
        k++;
      }
    }
  }
  (*count) += k - count2;
  len += k - count2;
  count2 += k - count2;

  k = 0;    // eleminate the remained empty places.
  for (i=0; i< count2;)
  {
    if (i == count2 -k) break;
    if ((*list)[i].obj_id.objid == NULL_OBJID) {
      k++;
      for (j=i;j<(*count)-1;j++)
        (*list)[j] = (*list)[j+1];
    }
    else i++;
  }
  count2 -= k;
  (*count) -= k;
  len -= k;

  len = len - count2;
  count1 = count1 + count2;

  VLfilterClass(len,&(*list)[count1],&count2,OPP_VLrolLine_class_id);
  if (count2 && !opt) {
    for (i=count1;i< count1+count2; i++) {
      sts = om$send( msg      = message GRowner.GRget_number_components(
                                                              &loc_msg,
                                                              &nb_child ),
                        senderid = NULL_OBJID,
                        targetos = (*list)[i].obj_id.osnum,
                        targetid = (*list)[i].obj_id.objid);
    if (!(sts&loc_msg&1)) goto quit;
      mark_roll += nb_child/2 + 1;
    }
  }
  len = len - count2;
  count1 = count1 + count2;
  VLfilterClass(len,&(*list)[count1],&count2,OPP_VLmrkLine_class_id);
  if (count2 && !opt) {
    for (i=count1;i< count1+count2; i++) {
      sts = om$send( msg      = message GRowner.GRget_number_components(
                                                              &loc_msg,
                                                              &nb_child ),
                        senderid = NULL_OBJID,
                        targetos = (*list)[i].obj_id.osnum,
                        targetid = (*list)[i].obj_id.objid);
    if (!(sts&loc_msg&1)) goto quit;
      mark_roll += nb_child;
    }
  }
  len = len - count2;
  count1 = count1 + count2;
  VLfilterClass(len,&(*list)[count1],&count2,OPP_VLtrace_class_id);
  len = len - count2;
  count1 = count1 + count2;
  VLfilterClass(len,&(*list)[count1],&count2,OPP_VLwatLine_class_id);
  len = len - count2;
  count1 = count1 + count2;

                       /* The following two VLfilterClass call must remain the
                  two last calls (this the Cut index */

  VLfilterClass(len,&(*list)[count1],&count2,OPP_VLseaLine_class_id);
  len = len - count2;
  count1 = count1 + count2;
  VLfilterClass(len,&(*list)[count1],&count2,OPP_VLbutLine_class_id);

  *count = count1 + count2;
  if(!opt) *count += mark_roll;

  if( vs$is_ancestry_valid(  object  = &plate->obj_id,
                             classid = OPP_VSmrkPlate_class_id ) )
  {
     IGRint          numObjects;
     struct GRid     *GridBuffer=NULL;

     sts= om$send ( msg =  message NDnode.NDget_objects(
                                                ND_IN_BUF |ND_ROOT,
                                                (struct GRid *)NULL,
                                                0,
                                                &GridBuffer,
                                                1,
                                                OM_K_MAXINT,
                                                &numObjects),
			senderid        = NULL_OBJID,
                        targetid        = plate->_objid,
                        targetos        = plate->_osnum        );
     --numObjects;
     __DBGpr_objlist( "Marked Lines", numObjects, GridBuffer );
     if ( numObjects ) {
         (* list) = ( struct GRobj_env * )
          om$realloc(ptr= (char *) (* list),
                     size = ((*count)+numObjects)*sizeof( struct GRobj_env ) );
           if ((* list) == NULL) goto quit;
           for (i=0;i<numObjects;i++) 
           {
	      (* list)[i+(*count)].obj_id  = GridBuffer[i];
	      (* list)[i+(*count)].mod_env = plate->mod_env; 
           }
           (*count) += numObjects;
       }

  }

  msg = 1;
quit :
  if (cntrl) {free(cntrl); cntrl = NULL;}
  if (tp_manager) {free(tp_manager); tp_manager = NULL;}
  return msg;
}

end implementation VLabstract;
