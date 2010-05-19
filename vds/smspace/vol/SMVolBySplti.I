/* $Id: SMVolBySplti.I,v 1.1.1.1 2001/01/04 21:07:38 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/smspace/vol / SMVolBySplti.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMVolBySplti.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:38  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.2  1996/01/24  20:06:34  pinnacle
# Replaced: ./smspace/vol/SMVolBySplti.I for:  by azuurhou for vds.240
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

/*
/*  History :
/*	CH  : 16 Oct 92	  creation date.
/*
/* */

class implementation SMVolBySplt;

#include "OMmacros.h"
#include "OMprimitives.h"

#include "igetypedef.h"
#include "igrtypedef.h"
#include "igrdef.h"
#include "igr.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"

#include "nddef.h"
#include "ndmacros.h"
#include "acrepdef.h"
#include "acrepmacros.h"
#include "asbox.h"
#include "emsmass.h"

#include "EC_I.h"
#include "EMSmsgdef.h"
#include "emssfintdef.h"
#include "emsdef.h"


#include "VDSpathdef.h"
#include "VDSudp_mac.h"
#include "VDSutil_def.h" 
#include "vdsmacros.h"

#include "grerr.h"
#include "vds.h"
#include "VDmsg.h"
#include "SMmsg.h"

#include "bserr.h"

#include "AS_status.h"

#define AS_DEBUG

from	EMSdpr		import	EMmake_primitive1;
from    EMSsurface      import  EMgetactiveid;
from    EMSsubbs        import  EMreduce_range, EMmk_nat_bdry;
from 	EMSsfspltwsf	import	EMsplit_with_surface;

extern	GRclassid	OPP_EMSproject_class_id;
extern	GRclassid	OPP_EMSsfsolid_class_id;
extern	GRclassid	OPP_EMSslboolean_class_id;
extern	GRclassid	OPP_GR3dpoint_class_id;

/* ****************** MSG ACmplace_from_def () ************************	*/

method ACmplace_from_def(int *rc, prop; 	char rep;char *macro_name;
	       	int num_temp;	struct GRid *temp_list;
		struct GRid *def_occ;
		struct GRmd_env *md_env )

{
 IGRlong status;

 /* Put the properties to no proptect:
 /*	- Does not create source,
 /*	- Does not verify the number (variable number of templates) 
 /*	- Does not verify the template types
 /* */
 prop = prop | AChdr_noprotect | ACcant_place_sym;
 status = om$send(msg = message ACncpx.ACmplace_from_def(rc, prop, rep, 
		         macro_name, num_temp, temp_list, def_occ, md_env),
                  mode     = OM_e_wrt_message,
                  targetid = my_id );

 return	status ;
}


/* *********************** MSG GRgetobjinfo () ************************	*/

method GRgetobjinfo( IGRlong *rc; struct GRobj_info *info )

{
 strcpy(info->type, "Split Solid");
  
 *rc = MSSUCC;
 return	OM_S_SUCCESS;
}

#define MAX_ROOT_SRF 13

struct SfSplt
 {
  struct GRobj_env 	surf;
  struct GRid		split;
  IGRint		type;
 };

#define MAX_SPLIT_SRF 14

/* ******************* MSG ACconstruct_feet () ************************	*/

method	ACconstruct_feet( IGRlong *rc; IGRint cn_type; 
				IGRint count; struct GRid list[];
				struct GRmd_env *md_env;
				IGRint *fcount; struct GRid *feet_list )
{
 IGRlong 		status, loc_msg;
 IGRlong                sizebuf, nret;
 struct IGRdisplay      display;
 IGRshort               level;
 struct GRmd_env	my_env;
 struct	GRvg_construct  cst;
 IGRint			i, k;
 IGRint                 MyProps, Rev[MAX_SPLIT_SRF];
 IGRboolean		FlCl;
 IGRboolean		PlanInf, SurfExt, SurfRev[MAX_SPLIT_SRF];
 struct ret_struct      str;
 struct GRobj_env	Surf[MAX_SPLIT_SRF];

 if(count > MAX_SPLIT_SRF) count = MAX_SPLIT_SRF;
 feet_list[0].objid = NULL_OBJID;

 my_env = *md_env;
 my_env.md_id.objid = NULL_OBJID; /* Computation out of RTREE */

 cst.msg        = &loc_msg;
 cst.newflag    = FALSE;
 cst.geometry   = NULL;
 cst.env_info   = &my_env;
 cst.class_attr = NULL;
 cst.name       = NULL;
 cst.properties	= GRIS_LOCATABLE | GRIS_DISPLAYABLE;


 sizebuf = sizeof(struct IGRdisplay);
 gr$get_active_display(msg     = &loc_msg,
                       sizbuf  = &sizebuf,
                       buffer  = &display,
                       nret    = &nret);

 /*| get the active level */
 sizebuf = sizeof(IGRshort);
 gr$get_active_level(msg     = &loc_msg,
                     sizbuf  = &sizebuf,
                     buffer  = &level,
                     nret    = &nret);
 cst.display    = &display;
 cst.level      = level;

 /* Get the expression mask */
 status = om$send(msg = message NDnode.NDgive_structure(&loc_msg, &str, NULL),
			targetid= list[0].objid,
			targetos= list[0].osnum);
 if(!(status & loc_msg & 1)) goto wrapup ;

 MyProps = (IGRint) str.var.root_pm_st.value;
 if(MyProps & 0x8000) PlanInf = TRUE;
 else		      PlanInf = FALSE;

 if(MyProps & 0x4000) FlCl = TRUE;
 else                 FlCl = FALSE;

 if(MyProps & 0x10000) SurfExt = TRUE;  /* Splitting surfaces extended */
 else		       SurfExt = FALSE;

 k = 0;

 if(count > 15) count = 15;
 for(i=1;i<count;i++)
  {
   status = om$send(msg = message NDnode.ASreturn_go(&Surf[k].obj_id,
				&Surf[k].mod_env.md_env.matrix_type, 
				 Surf[k].mod_env.md_env.matrix),
			targetid= list[i].objid,
			targetos= list[i].osnum);
   if(!(status & 1)) goto wrapup ;
  
   Surf[k].mod_env.md_id.objid = NULL_OBJID;
   Surf[k].mod_env.md_id.osnum = Surf[k].obj_id.osnum;

   if((1<<k) & MyProps) Rev[k] = 1;
   else	                Rev[k] = 0;

   SurfRev[k] = FALSE;
   k++;
  }
 
 if(!(SMMkSlSpSf(&cst, FlCl, k, Surf, PlanInf, SurfExt, Rev, SurfRev, NULL, &feet_list[0]) & 1)) 
  {
   goto wrapup;
  }

 *rc = MSSUCC;
 return	OM_S_SUCCESS;

 wrapup:

 *fcount = 0;
 *rc = MSFAIL;
 return	OM_W_ABORT;
}

/*
	----------------------------------------------------------
 */

/*   Modif PL 06-29-93  
	Kluddge waiting that the feet management is correctly done !!!!. */


method ACgive_path(int *suc;struct GRid *go_obj;char *foot_name)
{
        int i,sts;
        struct GRid pied;
        OM_S_CHANSELECT chansel;

        chansel.type = OM_e_name;
        chansel.u_sel.name = "GRcmpowner.to_components";

        /**** must find pied see give_foot ****/
        pied.objid = NULL_OBJID;
        sts = om$get_objid_at_index
                             ( object =         me,
                               p_chanselect =   &chansel,
                               index =          0,
                               objidaddr =      &pied.objid,
                               osnumaddr =      &pied.osnum);

        if( (1&sts) && pied.objid != NULL_OBJID ){
            /*| get the index of the object go_obj*/
            get_index_of_surf(pied, &i, *go_obj );
            if( i != -1 ){
                sprintf(foot_name,"$%d", i );
                /*"ACgivepath, foot_name created: %s\n ",foot_name */
                return ( *suc =OM_S_SUCCESS );
            }
        }

        /*"ACgivepath failed, call normal message \n"*/
        return om$send(msg= message ACncpx.ACgive_path
                                                (suc,go_obj,foot_name),
                        targetid=my_id,
                        mode = OM_e_wrt_message);
}

method ACreturn_foot(long *suc;char *foot_name; struct GRid *foot_GRid;
                     IGRshort *mat_type; IGRdouble *matrix)
{
        int ix;         /* index */
        int sts,loc_msg;
        OM_S_CHANSELECT chansel;
        struct GRid pied;

        *suc = 0;

        if( foot_name[0] != '$' ){
                return om$send( msg = message ACncpx.ACreturn_foot
                                        ( suc, foot_name, foot_GRid,
                                          mat_type, matrix),
                         targetid = my_id,
                         mode = OM_e_wrt_message);
        }
        chansel.type = OM_e_name;
        chansel.u_sel.name = "GRcmpowner.to_components";

        /**** must find real feet
        /**** we assume this is the 1st one on the channel to_component
        /* */
        pied.objid = NULL_OBJID;
        sts = om$get_objid_at_index
                             ( object =         me,
                               p_chanselect =   &chansel,
                               index =          0,
                               objidaddr =      &pied.objid,
                               osnumaddr =      &pied.osnum);
        if(!(1&sts) )
                return sts;
        if( pied.objid == NULL_OBJID )
                return *suc = 0;

        ix = -1;
        sscanf(&foot_name[1],"%d", &ix );
        if( !get_surf_at_index(pied, ix, foot_GRid ) )
                return *suc = 0;
        /*"ci_mac_bib.ACgive_foot, foot:%d %d\n",foot_GRid->objid,
                                foot_GRid->osnum */

        if(mat_type) *mat_type = MAIDMX;
        if(matrix) MAidmx(&loc_msg,matrix);

        *suc = 1; /*return real graphic object */

        return(sts);
}

/*----------------------------------------------------------------------------*/
method VDgetObjDef( long *msg ; VDobjDef *myDef ) {

	long		sts ;	/* OM return code	*/

	/*
	 * name.
	 */
	myDef->info		= SM_I_ObjVolBySplt ;
	myDef->type		= 0 ;

	sts	= OM_S_SUCCESS ;
	*msg	= MSSUCC ;

	return sts ;

} /* method VDgetObjdDef */
/*----------------------------------------------------------------------------*/

end implementation SMVolBySplt;

