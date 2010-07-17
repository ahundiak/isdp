
/* ******************************************************************

Autor	: O.N (isdc)

Date 	: May-17-1991

Subject	:	
	

History	:
---------

	Date	+ Autor	+	Description
	========+=======+==============================================
		+	+
		+	+

***********************************************************************	*/

class specification VRCORway (1:0) of VRCOProduct;

instance VRCORway
{
};

/* We need to override this method in order to set the product flag */

/* override messages */
/* ***************** */
override status_disp;

override VRFillForm;
override form_notification;
override VRDisplayMessage;

end specification VRCORway;

