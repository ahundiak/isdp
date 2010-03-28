/* #######################    APOGEE COMPILED   ######################## */
class implementation GRrtree;
/*
Abstract
	This method will connect the rtree to the module so that
	it may be found easily.  It also names the Rtree GRrtree and places
	it in the NOD in the current object space.

History
	7/20/87
 scw   07/10/92  ansi conversion

Bugs
	Multiple Rtrees are not yet supported.
*/


#include "grimport.h"
#ifndef NULL
#define NULL 0
#endif
#include "msdef.h"
#include "exmacros.h"

method GRrtconn ( IGRlong        *rc;
                  struct GRid    *md_id;
                  IGRushort      *mdchan)

{
    OM_S_CHANSELECT   to_channel, fr_channel;
    IGRlong   status;
    IGRchar   to_name[13], fr_name[13];

    *rc = MSSUCC;

    strcpy (to_name, "primary");
    strcpy (fr_name, "rtree_owner");

    fr_channel.type = OM_e_name;
    to_channel.type = OM_e_name;
    fr_channel.u_sel.name = fr_name;
    to_channel.u_sel.name = to_name;

    status = om$send (	msg = message Root.connect ( to_channel,NULL,
					my_id, OM_Gw_current_OS,
					fr_channel, NULL),
			targetid = md_id->objid,
			targetos = md_id->osnum);
    if (! (1&status))
    {
	om$report_error (sts = status);
	goto FINISH;
    }

/*    status = ex$get_cur_mod( id    = &mod.objid);
/*    mod.osnum = OM_Gw_current_OS;
/*
/*    if (!( 1 & status))
/*    {
/*        return (OM_S_SUCCESS);
/*    }
/*
/*    status = ex$get_NOD(NODname   = "IGENOD",
/*			pobjid    = &NOD_id,
/*			modid     = mod.objid,
/*			mod_osnum = mod.osnum);
/*    if (!( 1 & status))
/*    {
/*        return (OM_S_SUCCESS);
/*    }
/*
/*    status = ex$get_objid_from_NOD(NODobjid  = NOD_id,
/*				   objname   = "GRrtree",
/*				   pobjid    = &rtree_id,
/*				   modid     = mod.objid,
/*				   mod_osnum = mod.osnum);
/*    if (status == OM_W_NAMENOTFOUND)
/*    {
/*  	status = om$send(msg      = message OMNamObjDir.add_name
/*				    ("GRrtree", my_id),
/*                         senderid = my_id,
/*	                 targetid = NOD_id);
/*
/*	if (!( 1 & status))
/* 	{
/*	   om$report_error(sts = status);
/*           return (status);
/*	}
/*    } 
      */
FINISH:
    return ( status );
}

end implementation GRrtree;
