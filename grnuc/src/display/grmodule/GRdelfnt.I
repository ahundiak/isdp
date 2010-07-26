/*----
%GP% CODE CLASSIFICATION
-----
%HD%

	CLASS NAME:	GRmodule		GRmodule class
	METHOD NAME:	GRdel_fnt	delete font

	Abstract: This method will call a non-object routinte to delete
		  a particular font from a particular object space.

-----
%SC%

	value = GRdel_fnt (msg,virt_font_no)

-----
%EN%

	ON ENTRY:

	NAME		DATA TYPE		DESCRIPTION
       ------  		-----------    		----------------------------
       virt_font_no	IGRshort		the virtual font number of 
						the font to be deleted 

       
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

	     DPdel_fnt		- delete font from the font table


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
	AET  12/11/87	: Change virt_font_no to be by value instead of 
			  by address

-----
%PD%
--------------------------------------------------------------------
	      M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
	
	This method will delete a particular font for a particular 
	object space. 

----*/
/*EH*/

   

	class implementation GRmodule;

#include "dpdelfnt.h"

	    method GRdel_fnt (IGRlong *msg; IGRshort virt_font_no)  


        {

	  *msg = MSSUCC;

	  DPdel_fnt(msg,ME.GRmodule->fnt_os_tbl_ptr,OM_Gw_current_OS,
		    virt_font_no);


	  return(OM_S_SUCCESS);


	}
	end implementation GRmodule;
