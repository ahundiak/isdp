/*----
%GP% CODE CLASSIFICATION
-----
%HD%

	CLASS NAME:	GRmodule  	GRmodule class
	METHOD NAME:	GRadd_fnt	Add font to font table

	Abstract: This method will add a font to the non-object font table


-----
%SC%


	value = GRadd_fnt (msg,virt_font_no,font_id,body_size,decent,flags)

-----
%EN%

	ON ENTRY:

	NAME		DATA TYPE		DESCRIPTION
       ------  		-----------    		----------------------------
       virt_font_no	IGRshort		the virtual font number of 
						the font to be added to the
						font table

       font_id		IGRint			the font id used by font server

       body_size	IGRdouble		the size used to create the font

       decent		IGRdouble		how many units of the bodysize
						are below the baseline

       flags		IGRint			flags that tell information
						about the font like if it is
						an eight of sixteen bit font

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


	  Modules:

	     DPadd_fnt		- add to the font table


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
	AET  12/11/87	: Changed to correspond to using the font server

-----
%PD%
--------------------------------------------------------------------
	      M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
	
	This method calls a function that will add the new font
	information to the non-object side font table

----*/
/*EH*/

class implementation GRmodule;

#include "dpaddfnt.h"   

	    method GRadd_fnt (IGRlong *msg; 
			      IGRshort virt_font_no; 
			      IGRint font_id;
			      IGRdouble  body_size;
			      IGRdouble  decent;
			      IGRint	 flags)


        {

	  IGRint sts= OM_S_SUCCESS;

	
	  *msg = MSSUCC;


	  DPadd_fnt(msg,ME.GRmodule->fnt_os_tbl_ptr,OM_Gw_current_OS,
			virt_font_no,font_id,body_size,decent,flags);



	  return(sts);


	}
	end implementation GRmodule;
