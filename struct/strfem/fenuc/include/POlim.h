#ifndef	PO_limits
#define PO_limits

/*****************************************************************************

   Doc: POlim.h

   Abstract: Defines various limits used by the postprocessing system.

   History:

	Date		Who	Why
	---------	---	------------------------------------------
	????		???	Creation
	23 Feb 89	msl	Update for 1.2
	10 May 89	msl	Increased PO_PMAN_NAME_LEN from 10 to 16
	25 Oct 89	msl	Added nodes_per_elem

 ****************************************************************************/

#define	PO_PMAN_NAME_LEN	16	/* maximum length of POman name	*/
#define	PO_PMAN_DESC_LEN	50	/* maximum length of POman description*/
#define	PO_PMAN_DATE_LEN	14	/* POman date format "DyMonYr Hr:Mn"*/

#define	PO_CVTNM_LEN		17	/* maximum length of cvt name	*/
#define PO_CVT_SPACE		15	/* initial alloc of values & colors */

#define	PO_PDNAME_LEN		64	/* length of pdentry name	*/
#define	PO_UNIT_KWD_LEN		30	/* length of pdentry unit type	*/
#define PO_UNIT_NAM_LEN		26	/* max. length of EMS unit name	*/
#endif
