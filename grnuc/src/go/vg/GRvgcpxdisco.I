/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME: 	GRvg
     METHOD NAME:	GRcpxdisconn

     Abstract: 	This method will disconnect "me" from the input 
		object along the specified channel.

-----
%SC%    

     GRcpxdisconn(msg,cpxid,cpx_chan)

-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   ------------------------------------
     *cpxid	   GRid		  structure indicating objid of 
				  object to disconnect me from
     cpx_chan  OM_p_CHANSELECT	  channel number associated with 
				  input object 

-----
%EX%
     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     *msg	   long	  completion code
				     - MSSUCC if successful
				     - MSFAIL (severe) if failure
     
-----
%MD%

     MODULES AND METHODS INVOKED:

     Modules:
		none.
     Methods:
		none.
-----
%RL%

     RELATIONS REFERENCED:
			   none.
-----
%NB%

     NOTES:
	    none.
-----
%CH%

     CHANGE HISTORY:
	
	SDG     04/18/86 : Design date.
-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
	This method disconnects "me" from the input object.  If the 
	object is owned by anyone and this disconnect leaves him 
	with no other owners, then the component bit in the 
	properties word is cleared.

----*/
/*EH*/

class implementation GRvg;

#include "grimport.h"
#include "msdef.h"
#include "godef.h"

method GRcpxdisconn(long *msg; struct GRid *cpxid; 
		    OM_p_CHANSELECT cpx_chan)
	
{
	long  OMmsg;		/* OM return value	*/
	OM_S_CHANSELECT my_chandef;
	unsigned int count;	/* number of owners	*/
	int owners;		/* number of owners	*/

        *msg = MSSUCC;

	my_chandef.type = OM_e_addr;
	my_chandef.u_sel.addr = &me->to_cpx;

	OMmsg = om$send(mode = OM_e_wrt_object,
			msg = message Root.disconnect(*cpx_chan,my_id,
				 	 OM_Gw_current_OS,my_chandef),
			senderid = my_id,
			targetid = cpxid->objid,
			targetos = cpxid->osnum);

	if (! (1 & OMmsg))
	{
	   *msg = MSFAIL;
	}
	else
	{

	   OMmsg = om$get_channel_count(osnum = OM_Gw_current_OS,
                                        objid = my_id,
                                        p_chanselect = &my_chandef,
                                        count = &count);

	   owners = (int )count;
	
	   if (owners == 0)
	   {
	      /* clear the component bit in the properties word */

	      me->properties = me->properties & ~GRIS_COMPONENT;
	   }  
	}


        return(OMmsg);
}
end  implementation GRvg;

