class implementation Root;

#include "OMminimum.h"
#include "OMprimitives.h"
#include "OMerrordef.h"
#include "bserr.h"
#include "ex.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "gr.h"
#include "igrdp.h"
#include "godef.h"
#include "go.h"
#include "dp.h"

#include "grdpbdef.h"
#include "grdpbmacros.h"

#include "vderrmacros.h"
/*
#include "griodef.h"
#include "grio.h"
#include "griomacros.h"
*/
#include "emsdattyp.h"

from  GRvg	  import  GRgenabsg;
from  GRvg	  import  GRgetsymb;
from  GRgraphics  import  GRdisplay;
from  EMSsurface  import  EMintsurf_saveside;
from  EMSdpr	  import  EMmake_primitive1;
from  EMSsurface  import  EMgetactiveid;
from  EMSsurface  import  EMputLsIfNotThere;
from  EMSsurface  import  EMcompress_top;
from  EMSsubbs	  import  EMreduce_range;


long   SFtrimSfToSf (
  long			*msg,
  struct GRid		*sf1,
  struct GRmd_env	*env1,
  struct GRid		*sf2,
  struct GRmd_env	*env2
)
{

long			sts;
struct  IGRbsp_surface  *surf_geom = NULL,
			*geom2 = NULL;
struct  GRvg_construct  cst;
struct  GRsymbology	symb;
int			sizbuf,
			NoBytesRet;
struct  EMSdataselect   other_surf;
double			uvpars[2],
			saveside_point[3];
BSrc			rc;
GRobjid			intobj;
enum   GRdpmode		dpmode;




    sts = OM_S_SUCCESS;
    *msg = MSSUCC;


    sts = om$send ( msg = message GRvg.GRgenabsg (
					msg,
					&(env1->md_env.matrix_type),
					env1->md_env.matrix,
					(char **)&surf_geom ),
		    targetid = sf1->objid,
		    targetos = sf1->osnum,
		    senderid = NULL_OBJID );
    VDS_ERR_HNDLR("GRvg.GRgenabsg", sts, *msg, VD_VERBOSE, wrapup );

    uvpars[0] = 0.5;
    uvpars[1] = 0.5;
    BSsfptseval ( surf_geom, 1, uvpars, saveside_point, &rc );
    if ( rc != BSSUCC )
    {
	printf("BSsfptseval failure\n");
	goto wrapup;
    }

    /*
     * get the symbology of first surface
     */
    sts = om$send ( msg = message GRvg.GRgetsymb ( msg, &symb),
		    targetid = sf1->objid,
		    targetos = sf1->osnum,
		    senderid = NULL_OBJID );
    VDS_ERR_HNDLR("GRvg.GRgetsymb", sts, *msg, VD_VERBOSE, wrapup );


    cst.msg	   = msg;
    cst.env_info   = env1;
    cst.newflag    = 0;
    cst.level      = symb.level;
    cst.properties = GRIS_LOCATABLE | GRIS_DISPLAYABLE;
    cst.geometry   = NULL;
    cst.display    = &symb.display_attr;
    cst.class_attr = NULL;
    cst.name       = NULL;

    sts = EMgetvggeom(  msg,
			&(env2->md_env.matrix_type),
			env2->md_env.matrix,
			sf2, &geom2, NULL);
    if(!(1&*msg&sts))
    {
	printf("EMgetvggeom failure\n");
	goto wrapup;
    }

    dpmode = GRbe;
    sts = om$send ( msg = message GRgraphics.GRdisplay (
			msg,
			&(env1->md_env.matrix_type),
			env1->md_env.matrix,
			&dpmode,
			&(env1->md_id) ),
		    targetid = sf1->objid,
		    targetos = sf1->osnum,
		    senderid = NULL_OBJID );



    other_surf.datatype	 = EMSdata_surface;
    other_surf.data.surface = geom2;

    sts = om$send ( msg = message EMSsurface.EMintsurf_saveside (
						msg,
						&cst,
						&other_surf,
						env1,
						saveside_point,
						-1,
						0,
						&intobj,
						NULL,
						TRUE,
						NULL ),
		   targetid = sf1->objid,
		   targetos = sf1->osnum,
		   senderid = NULL_OBJID );

    if ( !(sts & *msg & 1) )
    {
       printf("EMSsurface.EMintsurf_saveside failure\n");
       goto wrapup;
    }

/*
message EMmake_primitive1(IGRlong *EMmsg; struct GRmd_env *my_env;
                          struct GRid *new_id);
*/
    {
	struct GRid  new_obj, active_id, top_lm_id;
	GRobjid		 return_id;

	sts = om$send(msg = message EMSsurface.EMgetactiveid( msg,
					&active_id, &top_lm_id),
                        targetid = sf1->objid,
                        targetos = sf1->osnum,
			senderid = NULL_OBJID);

	sts = om$send ( msg = message EMSdpr.EMmake_primitive1(
						msg,
						env1,
						&new_obj ),
			targetid = active_id.objid,
			targetos = active_id.osnum,
			senderid = NULL_OBJID );

	sts = om$send ( msg = message EMSsubbs.EMreduce_range (
						msg,
						env1,
						&return_id,
						0 ),
			targetid = new_obj.objid,
			targetos = new_obj.osnum,
			senderid = NULL_OBJID );
/*
         sts = om$send(msg = message EMSsubbs.EMreduce_range(&msg,
                             &me->solid_info.module_info, &return_id, 0),
                       senderid = new_id.objid,
                       targetos = new_id.osnum,  /*Im sending across OS.* /
                       p_chanselect = &to_comps);
         ERROR(sts, msg, "ECcomptree red range", wrapup);

	sts = om$send(msg = message EMSsurface.EMgetactiveid( msg,
					&active_id, &top_lm_id),
                        targetid = sf1->objid,
                        targetos = sf1->osnum,
			senderid = NULL_OBJID);

	sts = om$send( msg = message EMSsurface.EMcompress_top(
					msg, env1 ),
			senderid = NULL_OBJID,
			targetid = sf1->objid,
			targetos = sf1->osnum);
	VDS_ERR_HNDLR("EMSsurface.EMputLsIfNotThere",sts,*msg,VD_VERBOSE,wrapup );
*/

	dpmode = GRbd;
	sts = om$send ( msg = message GRgraphics.GRdisplay (
						msg,
						&(env1->md_env.matrix_type),
						env1->md_env.matrix,
						&dpmode,
						&(env1->md_id) ),
			targetid = return_id,
			targetos = sf1->osnum,
			senderid = NULL_OBJID );
    }

wrapup:

  if ( geom2 ) free( geom2 );
  return sts;


}

end implementation Root;
