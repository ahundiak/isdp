/* $Id: VDunwTools.I,v 1.1.1.1 2001/01/04 21:09:31 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdunwrap/VDunwTools.I
 *
 * Description: Generic unwrap routines
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDunwTools.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:09:31  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1999/10/26  19:31:06  pinnacle
# ah
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 07/19/99  ah      creation
 *
 ***************************************************************************/

class implementation VDSroot;

#ifndef DEBUG
#define DEBUG 1
#endif

#include "VDtypedef.h"
#include "VDobj.h"

#include "VDunwrap.h"

#include "bscrossp.h"
#include "bsnorvec.h"
#include "bsdotp.h"
#include "bsallocsf.h"
#include "bssf_copy.h"
#include "bslenvec.h"

/* --------------------------------------------------
 * Keep these for now
 */
extern  IGRint		abs();
extern  IGRchar	       *memcpy();
extern  IGRdouble	sqrt();
extern	IGRdouble	fabs();

extern GRclassid OPP_GR3dlinestr_class_id;
extern GRclassid OPP_EMSgenbs_class_id;

/* ------------------------------------------------------------------
 * Utility to make creating debug objects easier
 */
static IGRlong	   VDunwCnst_msg;
static TGRdisplay  VDunwAct_disp;
static IGRshort	   VDunwAct_level;
static TGRmd_env   VDunwModuleInfo;

void VDunwInitCnst(TGRvg_construct *usr_cnst) // IO Construction List
{

  // Just a fill up
  gr$get_module_env(buffer = &VDunwModuleInfo);

  ASget_active_symb( &VDunwAct_level, &VDunwAct_disp);
  usr_cnst->msg        = &VDunwCnst_msg;        
  usr_cnst->env_info   = &VDunwModuleInfo;
  usr_cnst->display    = &VDunwAct_disp;
  usr_cnst->geometry   = NULL; 
  usr_cnst->newflag    = FALSE;
  usr_cnst->level      = VDunwAct_level;
  usr_cnst->properties = GRIS_LOCATABLE | GRIS_DISPLAYABLE;
  usr_cnst->class_attr = NULL;
  usr_cnst->name       = NULL;
  
}
/* ----------------------------------------------------
 * Init the main structure
 */
IGRstat VDunwInitDevSrfInfo(TVDunwDevSrfInfo *dev)

{
  if (dev == NULL) return MSFAIL;
  memset(dev,0,sizeof(TVDunwDevSrfInfo));

  dev->uvSrfId.objid      = NULL_OBJID;
  dev->tesselation_option = 0;
  dev->AllWaterLines      = 0;
  dev->WantedLinesCode    = 31;
  dev->side_of_plate      = 2;

  return MSSUCC;
}

/* ----------------------------------------------------
 * Free the main structure
 */
IGRstat VDunwFreeDevSrfInfo(TVDunwDevSrfInfo *dev)
{
  IGRint i;
  BSrc   rc;
  
  if (dev == NULL) return MSFAIL;

  if( dev->surface ){
    if( dev->surface->bdrys ){
      om$dealloc( ptr = dev->surface->bdrys );
      dev->surface->bdrys = NULL;
    }
    om$dealloc( ptr = dev->surface ); 
    dev->surface = NULL;
  }

  if (dev->Param_u)    {free(dev->Param_u);        dev->Param_u    = NULL;}
  if (dev->Param_v)    {free(dev->Param_v);        dev->Param_v    = NULL;}
  if (dev->P)	       {free(dev->P); 	           dev->P	   = NULL;}
  if (dev->M)	       {free(dev->M);	           dev->M          = NULL;}
  if (dev->norm)       {free(dev->norm);	   dev->norm       = NULL;}
  if (dev->def)	       {free(dev->def);	           dev->def        = NULL;}
  if (dev->devsrf)     {BSfreesf(&rc,dev->devsrf); dev->devsrf     = NULL;}
  if (dev->fg)	       {free(dev->fg);	           dev->fg         = NULL;}
  if (dev->edgeUVGeom) {free(dev->edgeUVGeom);     dev->edgeUVGeom = NULL;}		 
  if (dev->edgeAt )    {free(dev->edgeAt);         dev->edgeAt     = NULL;}
			 

  if((dev->bdrys_a_plat)&&(dev->bdrys_a_plat->num_boundaries!=0)) {
    for (i=0;i<dev->bdrys_a_plat->num_boundaries;i=i+1) {
      free((dev->bdrys_a_plat->bndries[i]).points);
    }
    free(dev->bdrys_a_plat);
    dev->bdrys_a_plat	= NULL;
  }

  if( dev->ind )      {free(dev->ind);	         dev->ind      = NULL;}

  return MSSUCC;

}	

/* -------------------------------------------------------------------
 * This function prints out the devSrfInfo structure for debugging
 */
IGRstat VDunwPrintDevSrfInfo(TVDunwDevSrfInfo *dev, IGRint debugFlag)
{
  IGRstat retFlag = 0;
  
  // Arg check
  if (dev == NULL) goto wrapup;
  retFlag = 1;
  
  // Allow skipping everything
  if (debugFlag == 0) goto wrapup;

  printf("----------------- Developable Surface Information -----------------\n");
  vdobj$Print(objOE = &dev->surf_id);

  if (dev->surface == NULL) printf("No original 3d surface geometry\n");
  else {
    printf("Original 3d surface has poles u=%d,v=%d\n",
	   dev->surface->u_num_poles,
	   dev->surface->v_num_poles);
  }
  printf("Unwrapped Nb_u=%d,Nb_u=%d\n",dev->Nb_u,dev->Nb_v);

  if (dev->devsrf == NULL) printf("No devsrf geometry\n");
  else {
    printf("devsrf has poles u=%d,v=%d\n",
	   dev->devsrf->u_num_poles,
	   dev->devsrf->v_num_poles);
  }
  if ((dev->uvSrfId.objid == 0) || (dev->uvSrfId.objid == NULL_OBJID)) {
    printf("No uvSrfId object\n");
  }
  else {
    printf("The uvSrfId object is\n");
    vdobj$Print(objID = &dev->uvSrfId);
  }
  
  // Done
  printf("-----------------\n");
  
wrapup:
  return retFlag;
}

/* -------------------------------------------------------------------
 * This function create an order 2 bspline surface giving the poles,
 *  the number of poles in u and v and the 2 knot vectors.
 *
 * Cloned from VLcreOrd2Srf
 */
IGRstat VDunwCreateOrder2Srf(
  IGRdouble	*poles,	  /*I the given poles */
  IGRint	 Nu,	  /*I the number of poles in u */
  IGRint	 Nv,	  /*I the number of poles in v */
  IGRdouble	*KtsU,    /*I the internal knots in u */
  IGRdouble	*KtsV,	  /*I the internal knots in v */
  IGRshort  	constOpt, /*I constOpt = 0 just the bs 
			      constOpt = 1 the structure + the object
			      constOpt = 2 just just object */

  TGRvg_construct *cst,	    /*I the construction list */
  IGRboolean	   display, /*I display option to send a display or not */
  TGRobj_env	  *ObjSrf,  /*O the resulting surface */
  TGRbsp_surface  **sf,     /*O depending to constOpt the BS structure */
  IGRlong	  *msg      /*O return code MSSUCC or MSFAIL */
)
{
  IGRstat       sts;
  BSrc		rc;
  TGRbsp_surface  *tmpSf;

  tmpSf = NULL;

  BSallocsf ((IGRshort)(2), (IGRshort)(2),
	     (IGRlong)Nu,   (IGRlong)Nv,
	     (IGRboolean ) FALSE, (IGRshort)0, &tmpSf, &rc);
  if (rc != BSSUCC) {
    printf("Error in VLcreOrd2Srf\n");
    printf("BSallocsf on <struct IGRbsp_surface *> returns %d\n", rc);
    goto wrapup; 
  }

  /*c set up the sf structure */
  tmpSf->u_order 		= (IGRshort)   2;
  tmpSf->v_order 		= (IGRshort)   2;
  tmpSf->u_periodic 	= (IGRboolean) FALSE;
  tmpSf->v_periodic 	= (IGRboolean) FALSE;
  tmpSf->u_non_uniform 	= (IGRboolean) TRUE;
  tmpSf->v_non_uniform 	= (IGRboolean) TRUE;
  tmpSf->u_num_poles   	= (IGRlong)    Nu;
  tmpSf->v_num_poles   	= (IGRlong)    Nv;
  tmpSf->u_num_knots   	= (IGRlong)    2 + Nu;
  tmpSf->v_num_knots   	= (IGRlong)    2 + Nv;
  tmpSf->rational		= (IGRboolean) FALSE;
  tmpSf->planar        	= (IGRboolean) FALSE;
  tmpSf->u_phy_closed  	= (IGRboolean) FALSE;
  tmpSf->v_phy_closed  	= (IGRboolean) FALSE;
  tmpSf->pos_orient    	= (IGRboolean) TRUE;
  tmpSf->on_off	  	= (IGRboolean) TRUE;
  tmpSf->num_boundaries 	= (IGRshort) 0;

  /*c store the poles of surface, just do a memcpy */
  memcpy ( (IGRchar *)tmpSf->poles,(IGRchar *)poles,
	   (IGRint) 3 * Nu * Nv * sizeof(IGRdouble) );

  /*c store the knots in u */
  tmpSf->u_knots[0] = 0.0;
  memcpy ( (IGRchar *)&tmpSf->u_knots[1],(IGRchar *)KtsU,
	   (IGRint) Nu * sizeof(IGRdouble) );
  tmpSf->u_knots[tmpSf->u_num_knots-1] = 1.0;


  /*c same story in v */
  tmpSf->v_knots[0] = 0.0;
  memcpy ( (IGRchar *)&tmpSf->v_knots[1],(IGRchar *)KtsV,
	   (IGRint) Nv * sizeof(IGRdouble) );
  tmpSf->v_knots[tmpSf->v_num_knots-1] = 1.0;

  if( constOpt == 0 ){
    *sf = tmpSf;
    *msg = MSSUCC;
    return MSSUCC;
  }

  cst->geometry = (IGRchar *) tmpSf;

  ObjSrf->obj_id.objid = NULL_OBJID; 
  ObjSrf->obj_id.osnum = cst->env_info->md_id.osnum; 

  sts =	om$construct( classid = OPP_EMSgenbs_class_id, 
	              p_objid = &ObjSrf->obj_id.objid, 
         	      osnum   =  ObjSrf->obj_id.osnum,
	              msg     = message GRgraphics.GRconstruct(cst) );

  if( !(sts&1) ){ 
    printf("error in om$construct for sf\n");
    goto wrapup;
  }

  ObjSrf->mod_env = (*cst->env_info);

  if( display == TRUE ){

    gr$display_object ( object_id = (TGRid *)&ObjSrf->obj_id,
			md_env    = cst->env_info,
			mode      = GRbd );
  }

  cst->geometry = NULL;
  if( ( constOpt == 2 ) && (tmpSf != NULL) ) BSfreesf(&rc,tmpSf );
  else *sf = tmpSf;

  *msg = MSSUCC;
  return MSSUCC;

wrapup:
  if( tmpSf != NULL ) BSfreesf(&rc,tmpSf);
  *msg = MSFAIL;
  return MSFAIL;

}

end implementation VDSroot;
