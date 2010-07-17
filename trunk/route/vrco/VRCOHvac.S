
/* ******************************************************************

Autor	: O.N (isdc)

Date 	: Apr-17-1991

Subject	:	
	

History	:
---------

	Date	+ Autor	+	Description
	========+=======+==============================================
		+	+
		+	+

***********************************************************************	*/

class specification VRCOHvac (1:0) of VRCOProduct;

instance VRCOHvac
{
};



/* override messages */
/* ***************** */
/* We need to override this method in 	*/
/* order to set the product flag 	*/
override status_disp;

override VRFillForm;
override form_notification;
override VRDisplayMessage;

end specification VRCOHvac;

