
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:41 $
$Locker:  $
*/

class specification HSgragad (2:0) of IGEgragad, HSinstance;

/*

DESCRIPTION
	Class definition for a Hidden Line Window.  These are a subclass of
	the Graphics Windows.

HISTORY
	Sept. 5, 1986  --- Initial insertions (Mike Lanier)
	Feb. 12, 1987  --- Added overrides for clpicon and covicon (Steve Rapa)
        March 13, 1987 --- Added HScollect_win method (A.M.Thomas)
	April 29, 1991 --- Re-designed for 2.0.1 (Steve Rogers)
*/

#include "OMminimum.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igrdef.h"
#include "igr.h"
#include "gr.h"
#include "dp.h"
#include "hsdef.h"
#include "hsurf.h"


message HSsave_instance( IGRlong *msg );

/*
DESCRIPTION
	This message saves the instance data of the HSgragad by
	constructing an HSinstance object, copying its instance data
	to the HSinstance object, and then connecting itself to the
	HSinstance object's to_gragad channel.
*/
 
message HSrestore_instance( IGRlong *msg );

/*
DESCRIPTION
	This message restores the instance data of an HSgragad.  If the HSgragad
	has an HSinstance object attached, its data is copied to the HSgragad
	and it is deleted.  If the HSgragad doesn't have a HSinstance object
	attached, default instance data is loaded into the HSgragad.
*/

message HSdraw_grid( IGRlong *msg );

override DPgen_update;
override DPcal;
override DPupd_app_init;
override DPdisbybuf;
override DPdisbyoid;
override DPcollect_win;
override DPgriddraw;
override delete;
override clear;
override clpicon;
override covicon;
override movicon;
override dynamics;
override start_frame;
override display_frame;
override display_frames;

/*

MOTIVATION --- DPupdate
	This is the same as the method that it is overriding, except
	that, in addition to all that the overridden method does, this
	one has function calls that initialize and clean up an Hidden
	Line Update.

MOTIVATION --- DPgenupdate
	This is the same as the method that it is overriding, except
	that, in addition to all that the overridden method does, this
	one has function calls that initialize and clean up an Hidden
	Line Update.

MOTIVATION --- GRdisbybuf, GRdisblyoid
	For Hidden Line processing, there are some attribute of the
	DP_information data structure that have to be changed.  These are

	is_update --- from true to false
	is_hidden_list --- from false to true
	hline_info --- from NILL to the address of the Hidden Line
		Window instance data
	hl_tiler --- from NILL to HStile_object, the tiler function

MOTIVATION --- delete
	The same as the method that it is overridding, execept, in
	addition to all the old method does, it calls Hidden Line
	routines to delete an Hidden Line Window.

MOTIVATION -- clpicon, covicon
	Same as method being overridden except that the window is
	repainted instead of tiled again.

MOTIVATION -- movicon
	Need to check that if the window is being stretched, that there is
	enough memory to allocate for the additional area.

*/

end specification HSgragad;

