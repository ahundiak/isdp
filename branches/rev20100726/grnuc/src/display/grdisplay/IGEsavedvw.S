/*----
%GP% CODE CLASSIFICATION
-----
%HD%

	CLASS NAME:	IGEsavedvw	Saved View
	SUBCLASS OF:	IGEgragad

	Abstract:  defines saved views 

-----
%CD%

	CHANNELS DECLARED:

	inherited from IGEgragad winsup and to_all
		      
 	   	 
				         
-----
%MD%

	MESSAGES DECLARED:



-----
%NB%

	NOTES:

-----
%CH%

	CHANGE HISTORY

	MAS    08/13/86	: Design date.
	MP	08/04/88 : changed to be subclassed from IGEgragad 
				in release 1.2
-----
%PD%
--------------------------------------------------------------------
		C L A S S    D E S C R I P T I O N
--------------------------------------------------------------------

----*/
/*EH*/

class specification IGEsavedvw (2:0) of IGEgragad;

#include "dpsavevw.h"


               instance IGEsavedvw
               {
		    variable IGRchar descript[];
               };

	reject  activate , clear, convert_pnt, movicon, delicon, 
		covicon, clpicon,
		DPdisbyoid, DPdisbybuf,
		DPerase_hilite, DPcal, DPgriddraw,
		DPuor2dit, DPgridonoff, DPgridlock, DPrngbox, 
		DPcollect_win, gragad_cons, DPfit, DPlevels,
		DPupdate, DPgen_update, DPupd_app_init, 
		DPview_vol, 
		DPcenter, DPzoom, DPscroll, DProtate, 
		DPdelayonoff, DPwnarea;

	reject 	change_process_to, DPinrgbox, DPcal_persp, DPset_persp,
		DPun_persp, dynamics, DPcvt_persp;

	override DPinquire, DPset, delete;


  /* MESSAGES */

	message  savedvw_cons ( IGRlong *msg; IGRshort inflag; 
				IGRchar *vw_name; IGRchar *inst; 
				IGRchar *descript; IGRdouble *origin);
 
	message DPsv_recall (IGRlong *msg; IGRshort in_flags; 
				IGRlong array_size; struct GRid *wn_ids);

end specification IGEsavedvw;
