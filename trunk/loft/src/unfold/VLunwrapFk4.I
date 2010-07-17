/* $Id: VLunwrapFk4.I,v 1.2 2001/02/20 01:06:58 build Exp $  */

/* --------------------------------------------------------------------
 * I/LOFT
 *
 * File:        loftdp/src/unfold/VLunwrapFk4.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VLunwrapFk4.I,v $
 *      Revision 1.2  2001/02/20 01:06:58  build
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
# Revision 1.3  1997/02/23  22:49:14  pinnacle
# Replaced: src/unfold/VLunwrapFk4.I for:  by rchennup for loft
#
# Revision 1.2  1996/01/31  09:10:28  pinnacle
# Replaced: src/unfold/VLunwrapFk4.I for:  by svkadamb for loft
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

extern  IGRchar		*memcpy();

/*==========================================================================*/
/*  Given a surface, this function find all curves to Mark or to Cut on it. */
/*==========================================================================*/
IGRlong VLgetCutMarkLns (
           struct mise_a_plat	 *dev,  /*I : structure containing information*/
           struct GRobj_env	 *plate, /*I : Given Surface*/
           struct GRvg_construct *cst,   /*I : construction list*/
           int			 *NumEdges,   /*O : total number of edges */
           struct EdgeMatch	 **EdgeList,  /*O : the edge list  containing 
                                                    the unwraped edge ID and 
                                                    the edge_attribut macro 
                                                    matching with */
           struct GRid		 *min_rec,   /*O :surface's minimum rectangle */
           int			 *num_out_ids,/*O :number of found lines */
           struct GRid		 *out_ids,    /*O :found lines, the list begin
                                                   with curves to mark.*/
           int			 *Cut_index,/*O:index when begin curves to cut*/
           int			 *contour_index,/*O : index when begin curves
                                                    of the surface's contour.*/
           struct GRid		 *line,     /*O : used to compute orientation.*/
           int			 *surf_type,/*O : type of the surface (Port,
                                                   Starboard or Middle.*/
           double                *Length,/*O : length of the minimum rectangle*/
           double                *Width  /*O : width of the minimum rectangle*/
                       )
{
       IGRlong		msg,loc_msg,sts;
       IGRint		NumBound,*LoopIndex,NumOldCrvs=0;
       IGRint		i,numMarkChild,numMarkCrvs;
struct GRobj_env	*Bound,*MarkCrvs;
struct EdgeMatch	*locEdgeList;
       int		locNumEdges;
int                     nbline,UnwLnsOptions[UNFOLD_NB_OPTLINE];
VLquLine                Query[IDX_SC_SIZE];
IGRdouble               RangTol,ChtTol;
struct GRid		*OldCrvs=NULL;
struct GRobj_env        *buf=NULL,*Qline = NULL;
  
  msg = MSFAIL;

  Bound = NULL;
  LoopIndex = NULL;
  NumBound = 0;
  nbline = 0;
  *Cut_index = 0;
  *num_out_ids = 0;
  MarkCrvs = NULL;
  locEdgeList = NULL;
  locNumEdges = 0;

  /*c evaluate the mapping in 2D of the boundaries including the offset  */
  sts  = VLcreBoundWithOff( dev, cst, (IGRboolean)FALSE, &NumBound, 
                            &Bound, &LoopIndex, &locNumEdges, &locEdgeList,
                            surf_type, line, &NumOldCrvs, &OldCrvs, &loc_msg );
  if (!(sts&1&loc_msg)) {
	printf("Error in VLgetCutMarkLns\n");
	printf("VLcreBoundWithOff: Failed\n");
    	goto quit;
  }

  if (EdgeList != NULL) {
    *EdgeList = locEdgeList;
    *NumEdges  = locNumEdges;
  }
  else {
    if( locEdgeList ){om$dealloc(ptr=locEdgeList);locEdgeList=NULL;}
  }
  /*c evaluate the minimum rectangle */

        cst->geometry = NULL;
        sts  = vl$minrect ( curve   = &(Bound[0].obj_id),
                            environ = cst->env_info,
                            cst     = cst,
                            length  = Length,
                            width   = Width,
                            frame   = min_rec,
                            msg     = &loc_msg );
        if (!(sts&loc_msg&1)) {
		printf("Error in VLgetCutMarkLns\n");
		printf("vl$minrect : Failed\n");
          	goto quit;
        }

    if (plate != NULL) {
    VLdecode(dev->WantedLinesCode,UNFOLD_NB_OPTLINE, UnwLnsOptions);
         /* find water lines which are not attached to the plate
            but just cross it */
      if (UnwLnsOptions[UNFOLD_ATT_IDX_WATER] && dev->AllWaterLines) {
       VLqLineStfTpl (Query);
                            // we need just Water Lines
       for ( i=0; i<IDX_SC_SIZE; i++)
         Query[i].query = 0;
       Query[IDX_SC_WATL].query = 1;
   
       BSxtractpar ( &loc_msg, BSTOLCHRDHT, &ChtTol);
       RangTol = 5 * ChtTol;
   
       /* Query for lines in the range of stiffener wide side */
       sts = VLqueryStfTpl ( &dev->surf_id, NULL, Query, RangTol,
                             cst->env_info, &nbline, &Qline, &i,
                             &buf, &loc_msg);
       if (!(sts&loc_msg&1)) goto quit;
       if (nbline) {
           MarkCrvs = (struct GRobj_env *) om$malloc(
                                      size = nbline*sizeof(struct GRobj_env));
           if (MarkCrvs == NULL) goto quit;
           for (i=0;i<nbline;i++) MarkCrvs[i] = Qline[i];
           numMarkCrvs = nbline;
       }
     }
   
     numMarkChild = 0;
             /* find curves attached to the plate */
      sts = VLgetCrvsConToSrf(dev,plate,cst,0,contour_index,&numMarkChild,
                              &numMarkCrvs,MarkCrvs,NumOldCrvs,OldCrvs,&loc_msg);
      if (!(sts&loc_msg&1)) {
	printf("Error in VLgetCutMarkLns\n");
	printf("VLgetCrvsConToSrf 1: Failed\n");
        goto quit;
      }

      if( numMarkChild > 0 ){
        if (!nbline) {
          MarkCrvs = ( struct GRobj_env * )
          om$malloc( size = numMarkChild * sizeof( struct GRobj_env ) );
          if( MarkCrvs == NULL ){
		  printf("Error in VLgetCutMarkLns\n");
                  __DBGpr_com("error malloc MarkCrvs");
                  goto quit;
          }
          __DBGpr_com( "before 2nd call to GetCrvs" );
        }
        else {
         MarkCrvs = ( struct GRobj_env * )
          om$realloc(ptr= (char *) MarkCrvs,
                     size = (numMarkChild+nbline)*sizeof( struct GRobj_env ) );
         if( MarkCrvs == NULL ){
           printf("Error in VLgetCutMarkLns\n");
           __DBGpr_com("error malloc MarkCrvs");
           goto quit;
         }
        }
             /* find curves attached to the plate */
        numMarkCrvs = nbline;
        sts = VLgetCrvsConToSrf( dev,plate, cst, 1, contour_index,Cut_index,
                                 &numMarkCrvs, MarkCrvs,NumOldCrvs,OldCrvs,&loc_msg);
        if (!(sts&loc_msg&1)) {
		printf("Error in VLgetCutMarkLns\n");
		printf("VLgetCrvsConToSrf 1: Failed\n");
          	goto quit;
        }
      }
      else {
        if (nbline) {
          numMarkCrvs = nbline;
          sts = VLgetCrvsConToSrf( dev,plate, cst, 2, contour_index,Cut_index,
                                   &numMarkCrvs, MarkCrvs, NumOldCrvs,OldCrvs,&loc_msg);
          if (!(sts&loc_msg&1)) {
                  printf("Error in VLgetCutMarkLns\n");
                  printf("VLgetCrvsConToSrf 1: Failed\n");
                  goto quit;
          }
        }
      }

      if (MarkCrvs != NULL) {
          for(i=0;i< *contour_index;i++){
            out_ids[*num_out_ids] = MarkCrvs[i].obj_id;
            (*num_out_ids)++;
          }
      }
    }
            /* find curves to cut */
  for(i=0;i<NumBound;i=i+1) {
    sts = VLdropCompCrv( &Bound[i],LoopIndex[i],out_ids,num_out_ids,&loc_msg );
    __CheckRC( sts , loc_msg, "VLdropCompCrv", quit );
  }

  msg = MSSUCC;

quit :
  if( LoopIndex ){om$dealloc(ptr=LoopIndex);LoopIndex=NULL;}
  if( MarkCrvs != NULL){ om$dealloc( ptr = MarkCrvs ); MarkCrvs = NULL;}
  if( Bound != NULL){ om$dealloc( ptr = Bound ); Bound = NULL;}
  if( Qline ){ om$dealloc( ptr = Qline ); Qline = NULL;}
  if( buf ){ om$dealloc( ptr = buf ); buf = NULL;}
  return msg;
}

end implementation VLabstract;
