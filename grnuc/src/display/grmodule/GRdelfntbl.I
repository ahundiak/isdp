/*----
%GP% CODE CLASSIFICATION
-----
%HD%

	CLASS NAME:	GRmodule  	GRmodule class
	METHOD NAME:	GRdel_fnt_tbl	delete font table

	Abstract: This method will call a non-object routinte to delete
		  a particular font table when an object space is deleted.

-----
%SC%

	value = GRdel_fnt_tbl (msg)

-----
%EN%

	ON ENTRY:

	NAME		DATA TYPE		DESCRIPTION
       ------  		-----------    		----------------------------

       
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

	     DPdel_fnt_tbl	- delete font table


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
	AET  12/11/87	: changed call to DP_del_fnt_tbl to send 
			  os num by value instead of by address

-----
%PD%
--------------------------------------------------------------------
	      M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
	
	This method will delete a particular font table when a particular 
	object space is deleted. 

----*/
/*EH*/

   

	class implementation GRmodule;

#include "dpdelfntbl.h"

	    method GRdel_fnt_tbl (IGRlong *msg )


        {

	  *msg = MSSUCC;

	  DPdel_fnt_tbl(msg,ME.GRmodule->fnt_os_tbl_ptr,OM_Gw_current_OS);


	  return(OM_S_SUCCESS);


	}
	end implementation GRmodule;
