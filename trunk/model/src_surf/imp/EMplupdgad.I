/******************************************************************************
*
* Description:
*
*    This method updates the gadgets on the subform for the review element 
*    command if two or more commands are combined in one form. In this case 
*    only one form exists for this command therefore this method returns 
*    success.
*
* Overrides:
*    GRupdate_gadgets at GRgraphics.
*
*
* Abstract
*     
*     This method returns success because gadgets need not be updated.
*
*
* Method: GRupdate_gadgets (IGRlong *msg; IGRchar *form_ptr)
*
*  (O) IGRlong		 *msg		 Error Message
* (IO) IGRchar		 *form_ptr   form pointer
*
* Description:
*
*  This method returns success.
*
* History:
*
*    msm 	05/31/91    creation date.
*
******************************************************************************/


class implementation EMSplane;

method GRupdate_gadgets ( IGRlong *msg; IGRchar *form_ptr)
{
 return (1);
}
end implementation EMSplane;
