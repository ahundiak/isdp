




 /*
 COPYRIGHT
                     COPYRIGHT INTERGRAPH CORPORATION
                              < 1986, 1987 >
  
              Including software  and  its  file formats, and
              audio-visual displays; all rights reserved; may
              only  be  used   pursuant   to  the  applicable
              software     license     agreement;    contains
              confidential  and  proprietary  information  of
              intergraph and/or other  third parties which is
              protected  by  copyright,   trade  secret,  and
              trademark  law,  and  may  not  be  provided or
              otherwise made available  without prior written
              authorization.
  
  
                         RESTRICTED RIGHTS LEGEND
              Use, duplication,  or  disclosure  by  the U.S.
              Government is  subject  to  restrictions as set
              forth in subdivision  (b)(3)(ii)  of the Rights
              in Technical Data  and Computer Software clause
              at 52.227-7013.
  
  
              Intergraph Corporation
              One Madison Industrial Park
              Huntsville, Al 35807-4201
  
 */ 



	struct IGEscreen_info
	{
	   IGRint	bckgnd_planes;
	   IGRint	hilite_plane;
	   IGRint	vs_no;
	   IGRint	num_planes;
	   IGRint	plane_mask;
	   IGRint	vlt_size;
	   IGRint	dac_size;
	   IGRint	x_extent;
	   IGRint	y_extent;
	   IGRint	fixed_vlt_start;
	   IGRint	fixed_vlt_size;
	   IGRint	db_enabled;
	   IGRint	zb_enabled;
	   IGRint	sr_vlt_enabled;
	};

	struct IGEterm_info
	{
	   IGRint			num_phy_screens;
	   IGRint			num_of_screens;
	   struct IGEscreen_info	r_scn;
	   struct IGEscreen_info	l_scn;	   
	};

