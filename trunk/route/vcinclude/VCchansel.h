
/* $Id: VCchansel.h,v 1.1.1.1 2001/01/04 21:12:34 cvs Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:        vcinclude/VCchansel.h
 *
 * Description:
 *
 *      Predefined channel selectors for cabling
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VCchansel.h,v $
 *      Revision 1.1.1.1  2001/01/04 21:12:34  cvs
 *      Initial import to CVS
 *
 * Revision 1.1  1998/04/30  10:52:34  pinnacle
 * ROUTE 2.5.1
 *
 * Revision 1.1  1997/10/30  05:21:40  pinnacle
 * Integ into Route 02040304
 *
 * Revision 1.3  1997/07/14  21:18:08  pinnacle
 * Replaced: vcinclude/*.h for:  by hverstee for cabling
 *
 * Revision 1.2  1997/01/24  14:48:04  pinnacle
 * Replaced: vcinclude/VCchansel.h for:  by hverstee for cabling
 *
 * Revision 1.1  1997/01/23  13:34:20  pinnacle
 * Created: vcinclude/VCchansel.h by hverstee for cabling
 *
 *
 * History:
 *      MM/DD/YY   AUTHOR       DESCRIPTION
 *
 *      05/27/96    hv          Initial
 *
 *************************************************************************/

#ifndef	vc_chansel_include
#define vc_chansel_include

#define VC_CHAN_FATHER       "NDfather.father"
#define VC_CHAN_CHILDREN     "NDchildren.children"
#define VC_CHAN_OWNER        "GRconnector.to_owners"
#define VC_CHAN_COMPS        "GRcmpowner.to_components"
#define VC_CHAN_LISTEN       "ASsource.listeners"
#define VC_CHAN_NOTIF        "GRnotify.notification"

#ifndef VC_DEFINE_AN_GLOBALS
extern 
#endif
  OM_S_CHANSELECT 
	VC_GLB_children,
	VC_GLB_father,
	VC_GLB_to_comp,
	VC_GLB_to_owner,
        VC_GLB_listeners,
	VC_GLB_notification;

#ifndef VC_DEFINE_AN_GLOBALS
extern
#endif
  GRspacenum    VC_GLB_writable_os;

#endif

