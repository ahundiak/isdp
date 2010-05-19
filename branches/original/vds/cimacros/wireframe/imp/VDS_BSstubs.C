/* $Id: VDS_BSstubs.C,v 1.1.1.1 2001/01/04 21:07:22 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/cimacros/wireframe/imp / VDS_BSstubs.C
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDS_BSstubs.C,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:22  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.1  1997/05/08  13:20:44  pinnacle
 * New project VDS 250
 *
 * Revision 1.1  1996/07/19  20:33:52  pinnacle
 * Create VDS 241 project
 *
 * Revision 1.1  1994/11/14  22:42:32  pinnacle
 * Create vds.240 from vds.232
 *
 * Revision 1.1  1994/11/08  16:07:00  pinnacle
 * create vds.232
 *
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

/*
	I/VDS
	Stub to have all BS's available to PPL.

        History :
        92/08/26  alc  Give a size NB_MAX to the list of external functions
                       (acc compiled !)
*/


#define NB_MAX 100


extern	int
	BSac2eptscr(),
	BSadd_ktr(),
	BSalloccv(),
	BSallocsf(),
	BSarc3pts(),
	BSblend_cv(),
	BScrossp(),
	BSctrarplcv(),
	BScv_sf_int(),
	BScvarrevc(),
	BScvcv_int(),
	BScveval(),
	BSdirfitcv(),
	BSdistptpt(),
	BSdotp(),
	BSfreecv(),
	BSfreesf(),
	BShelix1(),
	BSiarcln(),
	BSlenvec(),
	BSlsqfitcv(),
	BSmdstptcv(),
	BSmergarrcv(),
	BSmkvec(),
	BSnorvec(),
	BSpartofcv(),
	BSpartofsf(),
	BSpj_pt_sf(),
	BSpl_cv_int(),
	BSpl_pl(),
	BSpl_pl_pl(),
/*	BSplpl_int(),   */
	BSprepcircp(),
	BSprj_cv_pl(),
	BSpt_in_cv(),
	BSptperpsf(),
	BSrev_cv(),
	BSsf_pl_int(),
	BSsfarrevn(),
	BSsfeval(),
	BSsfxttpt(),
	BSsur_sur(),
	BStst_plan(),
	BSxlnpl(),
	MAunitvc(),
 	BSarclength(),
 	BSellctaxrm(),
 	BSxln(),
      	BSxlnpl(),
       	BScvcvint(),
       	BSfillet(),
        BSalloccv(),
        BSdotp(),
        BSpartofcv(),
        BSpjcvtsf(),
        BSprj_cv_pl(),
        BSsf_pl_int(),
        BSsfnormal(),
        BSsur_sur() ;

VDS_BSstubs() {
	/*
	 * Force references to some BS routines.
	 */
	int (*BS[NB_MAX])() ;
        int i ;

        i = 0 ;

	BS[i] = BSac2eptscr ; i++ ;
	BS[i] = BSadd_ktr ; i++ ;
	BS[i] = BSalloccv ; i++ ;
	BS[i] = BSallocsf ; i++ ;
	BS[i] = BSarc3pts ; i++ ;
	BS[i] = BSblend_cv ; i++ ;
	BS[i] = BScrossp ; i++ ;
	BS[i] = BSctrarplcv ; i++ ;
	BS[i] = BScv_sf_int ; i++ ;
	BS[i] = BScvarrevc ; i++ ;
	BS[i] = BScvcv_int ; i++ ;
	BS[i] = BScveval ; i++ ;
	BS[i] = BSdirfitcv ; i++ ;
	BS[i] = BSdistptpt ; i++ ;
	BS[i] = BSdotp ; i++ ;
	BS[i] = BSfreecv ; i++ ;
	BS[i] = BSfreesf ; i++ ;
	BS[i] = BShelix1 ; i++ ;
	BS[i] = BSiarcln ; i++ ;
	BS[i] = BSlenvec ; i++ ;
	BS[i] = BSlsqfitcv ; i++ ;
	BS[i] = BSmdstptcv ; i++ ;
	BS[i] = BSmergarrcv ; i++ ;
	BS[i] = BSmkvec ; i++ ;
	BS[i] = BSnorvec ; i++ ;
	BS[i] = BSpartofcv ; i++ ;
	BS[i] = BSpartofsf ; i++ ;
	BS[i] = BSpj_pt_sf ; i++ ;
	BS[i] = BSpl_cv_int ; i++ ;
	BS[i] = BSpl_pl ; i++ ;
	BS[i] = BSpl_pl_pl ; i++ ;
	BS[i] = BSprepcircp ; i++ ;
	BS[i] = BSprj_cv_pl ; i++ ;
	BS[i] = BSpt_in_cv ; i++ ;
	BS[i] = BSptperpsf ; i++ ;
	BS[i] = BSrev_cv ; i++ ;
	BS[i] = BSsf_pl_int ; i++ ;
	BS[i] = BSsfarrevn ; i++ ;
	BS[i] = BSsfeval ; i++ ;
	BS[i] = BSsfxttpt ; i++ ;
	BS[i] = BSsur_sur ; i++ ;
	BS[i] = BStst_plan ; i++ ;
	BS[i] = BSxlnpl ; i++ ;
	BS[i] = MAunitvc ; i++ ;
 	BS[i] = BSarclength ; i++ ;
 	BS[i] = BSellctaxrm ; i++ ;
 	BS[i] = BSxln ; i++ ;
      	BS[i] = BSxlnpl ; i++ ;
       	BS[i] = BScvcvint ; i++ ;
       	BS[i] = BSfillet ; i++ ;
	BS[i] = BSalloccv ; i++ ;
	BS[i] = BSdotp ; i++ ;
	BS[i] = BSpartofcv ; i++ ;
	BS[i] = BSpjcvtsf ; i++ ;
	BS[i] = BSprj_cv_pl ; i++ ;
	BS[i] = BSsf_pl_int ; i++ ;
	BS[i] = BSsfnormal ; i++ ;
	BS[i] = BSsur_sur ; i++ ;

	return ;
}
