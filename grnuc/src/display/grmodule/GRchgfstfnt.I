/*----
%GP% CODE CLASSIFICATION
-----
%HD%

	CLASS NAME:	GRmodule  	GRmodule class
	METHOD NAME:	GRchg_fst_fnt	change fast font numbers

	Abstract: This method will call the non-object side to change
		  the fast fonts numbers in the font table.

-----
%SC%

	value = GRchg_fst_fnt (msg,fst_char_fnt,fst_frac_fnt,fst_16bit_fnt)


-----
%EN%

	ON ENTRY:

	NAME		DATA TYPE		DESCRIPTION
       ------  		-----------    		----------------------------
       fst_char_fnt	IGRshort		the virtual font number of
						the fast character font

       fst_frac_fnt	IGRshort		the virtual font number of
						the fast fraction font

       fst_16bit_fnt	IGRshort		the virtual font number of
						the fast 16-bit font

       
-----
%EX%

	ON EXIT:

	NAME	DATA TYPE	DESCRIPTION
       ------  -----------    ----------------------------
       *msg	IGRlong		return status
				  MSSUCC - successfully completed
				  MSFAIL - unsuccessfully completed


-----
%MD%

	MODULES AND METHODS INVOKED:

	  Methods:

	     none

	  Modules:

	     DPchg_fst_fnt	- Change fast font numbers


-----
%RL%

	RELATIONS REFERENCED:

	   none

-----
%NB%

	NOTES:

-----
%CH%

	CHANGE HISTORY

	AET  01/30/86	: Design date.
	AET  12/11/87	: Changed to correspond to new font structure 
			  using the font server
	AET  06/20/88	: Changed to include fast 16-bit font

-----
%PD%
--------------------------------------------------------------------
	      M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
	
	This method calls a non-object routine to change the
	fast font numbers for a particular object space. 
	
----*/
/*EH*/

class implementation GRmodule;

#include "dpchgfstfnt.h"   

	    method GRchg_fst_fnt (IGRlong *msg;	IGRshort fst_char_fnt;
				  IGRshort fst_frac_fnt; 
				  IGRshort fst_16bit_fnt)


        {

	
	  *msg = MSSUCC;



	  DPchg_fst_fnt(msg,ME.GRmodule->fnt_os_tbl_ptr,OM_Gw_current_OS,
			fst_char_fnt,fst_frac_fnt,fst_16bit_fnt);


 	  return(OM_S_SUCCESS);


	}
	end implementation GRmodule;
