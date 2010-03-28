/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME: 	GRvg
     METHOD NAME:	GRcpxconn

     Abstract: 	This method will connect "me" to a given object 
		through a specified channel.

-----
%SC%    

     GRsetconn(msg,setid,cpx_chan,index)

-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   ------------------------------------
     *cpxid	   GRid		  structure indicating objid of 
				  object to connect me to
     cpx_chan  OM_p_CHANSELECT	  channel  associated with
				  input object
     *index	   IGRlong	  index into ordered relation 
				  (default value if no ordered 
				   relation exists:  NULL)

-----
%EX%

     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     *msg	   IGRlong	  completion code
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
	This method connects "me" to the input object.  It also sets 
	the component bit in the properties word if not already set.

----*/
/*EH*/

class implementation GRvg;

#include "grimport.h"
#include "msdef.h"

method GRcpxconn(IGRlong *msg; struct GRid *cpxid; OM_p_CHANSELECT
		 cpx_chan; IGRlong *index)
{
	IGRlong  OMmsg;		/* OM return value	*/
	IGRlong relindex2;	/* relative index of 	*/
				/* input object		*/
	OM_S_CHANSELECT my_chandef;
	
	/* initialize variables */
        *msg = MSSUCC;
	relindex2 = 0;
	
	my_chandef.type = OM_e_addr;
	my_chandef.u_sel.addr = &me->to_cpx;

	OMmsg = om$send(mode = OM_e_wrt_object,
			msg = message Root.connect(*cpx_chan,relindex2,
					 my_id,OM_Gw_current_OS,my_chandef,
					 *index),
			senderid = my_id,
			targetid = cpxid->objid,
			targetos = cpxid->osnum);

	if (! (1 & OMmsg))
	{
	   *msg = MSFAIL;
	}
	else
	{
	   /* set the component bit in the properties word */

	   me->properties = me->properties | GRIS_COMPONENT;
	}

        return(OMmsg);
}

end implementation GRvg;
