/* $Id: VLunwrapFk1.I,v 1.2 2001/02/20 01:06:53 build Exp $  */

/* --------------------------------------------------------------------
 * I/LOFT
 *
 * File:        loftdp/src/unfold/VLunwrapFk1.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VLunwrapFk1.I,v $
 *      Revision 1.2  2001/02/20 01:06:53  build
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
# Revision 1.3  1997/04/03  11:14:14  pinnacle
# Replaced: src/unfold/VLunwrapFk1.I for:  by rchennup for loft
#
# Revision 1.2  1996/01/31  09:07:02  pinnacle
# Replaced: src/unfold/VLunwrapFk1.I for:  by svkadamb for loft
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

from	ASindexcv	import  ASget_uvwdef;

extern	GRclassid	OPP_ASindexcv_class_id;
extern	GRclassid	OPP_GR3dlinestr_class_id;

extern	IGRchar		*memcpy();
extern	void		BSsfeval();
extern	IGRint 		BSsfevaln();
extern	void            FAevPtSfFaDr();


/* ************************************************************************ *
 Given a list of lines (obj), this function  maps it on the surface
 (dev->surface). If the surface is a plane, it just copy the lines.
 Finally, it creates VLjunction object.
 * ************************************************************************ */
long VLprojectParLine(dev,nb_obj,obj,ACrg,nb_att,cst,numCrvs,Crvs)
struct mise_a_plat	*dev; /*I: unwrap structure */
int			nb_obj;/*I: number of lines */
struct GRobj_env	*obj;  /*I: lines */
struct  GRvg_construct  *cst;  /*I: contruction list */
struct ACrg_coll        *ACrg; /*I: rg_collection to put in the create 
				    VLjunction objects */
int                     nb_att;/*I: number of attribute in the collection */
int			*numCrvs;/*O: number of output VLjunction objetc */
struct GRobj_env        *Crvs;   /*O: VLjunction objetc */
{
int			ii,j,k,jj;
long			loc_msg,status,msg;
struct GRobj_env        cp_obj,tmp_obj,tmp;
struct  GRsymbology     symbology;
struct  GRas            asso_list;
double			dbl[3];
struct  IGRpolyline     str;
IGRint          	count   =       0;
IGRdouble      		*uvw    =       NULL;
IGRlong        		nptSize;
BSrc			rc;
double                  ptDr[3], vecDr[6];
struct GRid		res_id;
short			act_level;

     msg = MSFAIL;
     str.points = NULL;
     as$make_source(go_grid = dev->surf_id.obj_id,
                    mod_env = &dev->surf_id.mod_env,
                    as_os = cst->env_info.md_id.osnum,
                    as_grid = &res_id);
     j = sizeof(short);
     gr$get_active_level( msg    = &loc_msg,
                          sizbuf = &j,
                          buffer = &act_level ) ;

     for (ii=0;ii<nb_obj;ii++)
     {
         /* to do a good NDplace later, we need copy */
       status = om$send(msg = message GRgraphics.GRcopy(
                                                &loc_msg,
                                                &obj[ii].mod_env,
                                                cst->env_info,
                                                &(cp_obj.obj_id.objid) ),
                                senderid = NULL_OBJID,
                                targetid = obj[ii].obj_id.objid,
                                targetos = obj[ii].obj_id.osnum );
        if (!(status&loc_msg&1)) {
          goto wrapup;
        }
	cp_obj.obj_id.osnum=cst->env_info->md_id.osnum;
        cp_obj.mod_env = *(cst->env_info);

	status = om$send( msg = message GRvg.GRchglevel( 
						&loc_msg,
						(IGRshort *) &(cst->level)),
                                senderid = NULL_OBJID,
                                targetid = cp_obj.obj_id.objid,
	                        targetos = cp_obj.obj_id.osnum ) ;
        if (!(status&loc_msg&1)) {
          printf("GRchglevel Failed\n");
        }

     if (!dev->developpable) {
        asso_list.num_parents = 1;
        asso_list.parents = &res_id;
        dbl[0] = 0.; dbl[1] = 0.; dbl[2] = 0.;
        asso_list.as_attr         = (char *) dbl;
        asso_list.context = NULL;
        asso_list.go_attr = NULL;
        asso_list.go_objid.objid = cp_obj.obj_id.objid;
        asso_list.go_objid.osnum = cst->env_info->md_id.osnum;
        tmp.obj_id.osnum = cst->env_info->md_id.osnum;

        status = om$construct( classid = OPP_ASindexcv_class_id,
                            p_objid = &tmp.obj_id.objid,
                            osnum = tmp.obj_id.osnum);
        if( !(status&1) ){
          goto wrapup;
        }
        cst->geometry = NULL;
        status = om$send(msg = message ASindexcv.NDplace(
                                &asso_list,
                                cst->env_info,
                                (char *) cst),
                        senderid = NULL_OBJID,
                        targetid = tmp.obj_id.objid,
                        targetos = tmp.obj_id.osnum );
    
        if( !( status & 1 ) ){
          goto wrapup;
        }
        status = om$send ( msg =  message ASindexcv.ASget_uvwdef(
                                                   NULL,
                                                   0,
                                                   &count ),
                                   targetid       = tmp.obj_id.objid,
                                   targetos       = tmp.obj_id.osnum,
                                   senderid       = NULL_OBJID );
        if( !( status & 1 ) ){
          goto wrapup;
        }
        str.num_points = count;
        count = 0;

        nptSize = 3 * str.num_points * sizeof(IGRdouble);

        uvw = (IGRdouble * ) om$malloc( size = nptSize );
        if( uvw == NULL ){
          __DBGpr_com("Error malloc uvw");
          goto wrapup;
        }
  
        status = om$send ( msg =  message ASindexcv.ASget_uvwdef(
                                    uvw, str.num_points, &count),
                            targetid        = tmp.obj_id.objid,
                            targetos        = tmp.obj_id.osnum,
                            senderid       = NULL_OBJID );
        __DBGpr_dbl( "uvW", uvw[0] );
  
        if( !( status & 1 ) ){
          goto wrapup;
        }
        str.points = (IGRdouble * ) om$malloc( size = nptSize );
        if( str.points == NULL ){
          __DBGpr_com("Error malloc str.points");
          goto wrapup;
        }
        j = 3 * str.num_points;

        if (dev->tesselation_option == PARAMETRIC) {
  

           for(k=0;k<j;k+=3){
           	BSsfeval( dev->devsrf, uvw[k], uvw[k+1], 0,
                          &(str.points[k]), &rc );
            	if (rc != BSSUCC) goto wrapup;
           }
	}
        else{
           for(k=0;k<j;k+=3){
                BSsfevaln(dev->surface,uvw[k],uvw[k+1],1, &jj,ptDr,vecDr,&rc);
                FAevPtSfFaDr((IGRshort) 3,dev->P,dev->devsrf,dev->def,
                            ptDr, vecDr, uvw[k],uvw[k+1], &(str.points[k]),&rc);
                if (rc != BSSUCC) goto wrapup;
	   }
        }

        status = om$send( msg   = message GRvg.GRgetsymb( &loc_msg,&symbology),
                         senderid = NULL_OBJID,
                         targetid = obj[ii].obj_id.objid,
                         targetos = obj[ii].obj_id.osnum);

 
        tmp_obj.obj_id.objid = NULL_OBJID;
        tmp_obj.obj_id.osnum = cst->env_info->md_id.osnum;

        cst->geometry = (IGRchar *) &str;
        status = om$construct( classid = OPP_GR3dlinestr_class_id,
                             p_objid = &tmp_obj.obj_id.objid,
                             osnum   = tmp_obj.obj_id.osnum,
                             msg     = message GRgraphics.GRaltconstruct(cst));

        if (!(status&(*(cst->msg))&1)) {
              goto wrapup;
            }
        
        symbology.level = act_level;
        status = om$send( msg   = message GRvg.GRputsymb( &loc_msg,&symbology ),
                         senderid = NULL_OBJID,
                         targetid = tmp_obj.obj_id.objid,
                         targetos = tmp_obj.obj_id.osnum );
  
        status = vl$createLoftFork (msg=&loc_msg,
                           graphic = &tmp_obj,
                           attr    = ACrg,
                           number  = nb_att,
                           Env     = cst->env_info,
                           forkId = &(Crvs[*numCrvs].obj_id));
        if (!(status&loc_msg&1)) {
          goto wrapup;
        }
  
        Crvs[*numCrvs].mod_env = *cst->env_info;
        *numCrvs += 1;

        if( uvw ){ om$dealloc( ptr = uvw ); uvw = NULL;}
        if( str.points ){ om$dealloc( ptr = str.points );
                                    str.points = NULL;}
        om$send(msg = message GRgraphics.GRdelete
                                                (&loc_msg,cst->env_info),
                             targetid = tmp.obj_id.objid,
                             targetos = tmp.obj_id.osnum,
		             senderid = NULL_OBJID );
      }
      else {
        status = vl$createLoftFork (msg=&loc_msg,
                           graphic = &cp_obj,
                           attr    = ACrg,
                           number  = nb_att,
                           Env     = cst->env_info,
                           forkId = &(Crvs[*numCrvs].obj_id));
        if (!(status&loc_msg&1)) {
          goto wrapup;
        }
        Crvs[*numCrvs].mod_env = *cst->env_info;
        *numCrvs += 1;
      }
    }

    msg = MSSUCC;
wrapup :
    if( !(msg&1) )
    {
      if( cp_obj.obj_id.objid != NULL_OBJID )
      {
	status = om$send(msg = message GRgraphics.GRdelete( 
						&loc_msg, cst->env_info ),
                              senderid = NULL_OBJID,
			      targetid = cp_obj.obj_id.objid,
                              targetos = cp_obj.obj_id.osnum  );
      }
    }

    if( uvw ){ om$dealloc( ptr = uvw ); uvw = NULL;}
    if( str.points ){ om$dealloc( ptr = str.points ); str.points = NULL;}
    return msg;
}

end implementation VLabstract;
