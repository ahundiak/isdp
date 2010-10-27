class implementation nci_macro;
/*--------------------------------------------------------------------------*/
/*
/*  nci_macroi.I
/*  robert patience
/*  5 sept 1989
/*
/* E BEEKER Feb '90
/* management of indexing converted in C
/*---------------------------------------------------------------------------
/* */

#define AS_DEBUG	/* debug pre-processor */

#include "ci_macro.h"

#include "memory.h"
#include "igrdef.h"    
#include "codef.h"    
#include "grdpbdef.h"    
#include "grdpbmacros.h"    
#include "OMerrordef.h"
#include "OMmacros.h"
#include "OMprimitives.h"
#include "macro.h"
#include "DIdef.h"
#include "DIprims.h"
#include "AS_status.h"
#include "nddef.h"
#include "asbox.h"
#include "asdef.h"
#include "asmacros.h"
#include <stdio.h>
#include "cierrordef.h" 
#include "ciexecmacros.h" 
#include "grownmacros.h"
#include "nddef.h"
#include "ndmacros.h"
from ACcpx_defn		import ACgive_feet_desc, ACintpt_foot,ACintpt_foot_dir,
			       ACgive_temp_desc, ACgive_name ;
from ACmacro_defn 	import ACgive_upscan;


extern GRclassid 	OPP_ASsource_class_id;
extern GRclassid    OPP_GRundo_class_id;

extern test_ci1();
extern run_ci();


/* ========================================================================= */

method ACgive_structure( int *suc,*direct_index; char *feet_name;
			 struct ret_struct  *ptr_rst; struct GRmd_env *md_env )
{

  IGRint		status;
  struct GRid		nci_macro_id;
  int			pos, chan, type;
  struct GRid		mac_def;

  status = om$send(msg = message ACcpx.find_macro(&mac_def),
		      targetid = my_id );
  as$status( action = RET_STATUS );
  status = om$send(msg= message ACcpx_defn.ACintpt_foot(suc,feet_name,
					&chan,&pos, &type),
		      targetid = mac_def.objid ,targetos = mac_def.osnum);
  as$status( action = RET_STATUS );

  if( ( chan == feet_virtual) )
       {
       status=om$send(msg = message nci_macro.ci_kl_ACgive_structure
		(suc,direct_index,feet_name,ptr_rst,md_env),
		      targetid = my_id  );
	if(status) return(status);
       } 
  
  if (chan == -1) {
    
    /* -------------------------------------------
     * This channel thing is a bit confusing
     * the code looks for a foot whose name matches
     * the desired attribute name then returns this chan
     * Feet don't have to actually exist, they can be virtual
     *
     * In any event, the VDbufMacro does not have any of this
     * So treat them all as virtual feet
     */

    struct GRid myID;
    IGRint sts;
    extern GRclassid OPP_VDbufMacro_class_id;

    myID.objid = my_id;
    myID.osnum = OM_Gw_current_OS;
    sts = VDobjIsAncestryValid(NULL,&myID,OPP_VDbufMacro_class_id,NULL);
    if (sts == 1) chan = feet_virtual;   
  }
  
  if(( chan == feet_virtual) && 
		test_ci1("ACgive_structure", my_id, OM_Gw_current_OS, 
		&nci_macro_id, me->internal_buffer))
    {
    CIpushlist	arglist[5];
      		arglist[0].addr	= &suc		;
      		arglist[0].size = sizeof(suc)	;
      		arglist[1].addr	= &direct_index		;
      		arglist[1].size = sizeof(direct_index)	;
      		arglist[2].addr	= &feet_name		;
      		arglist[2].size = sizeof(feet_name)	;
      		arglist[3].addr	= &ptr_rst		;
      		arglist[3].size = sizeof(ptr_rst)	;
      		arglist[4].addr	= &md_env		;
      		arglist[4].size = sizeof(md_env)	;
     ci$push( argc = 5, argv = arglist ) ;
     status=run_ci("ACgive_structure" ,nci_macro_id );
    }
  else
   {
    /*| I am doing ov_ci_mac.NDmove_to_root */
    status = om$send( mode = OM_e_wrt_message,
		    msg = message ov_ci_mac.ACgive_structure
		    (suc,direct_index,feet_name,ptr_rst,md_env),
            	    targetid = my_id );
   }
   return(status);
}


end implementation nci_macro;
