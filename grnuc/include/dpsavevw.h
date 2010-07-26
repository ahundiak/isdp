




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

#ifndef dpsavevw_include
#define dpsavevw_include

          /*\
           *    The following structure defines private data used in
           *    saved view object.
	   *
	   *  	This include file is dependent on the following include files:
	   *  	igrtypedef.h
          \*/
            
            struct DPsavevw                       /* saved view structure */
            {
                IGRchar   name[32];         	   /* saved view name  */
                IGRint 	  flags;		   /* view flags       */
                IGRlong   grid_per_ref_x;          /* # of grid dots
                                                      between x-axis 
						      cross  	       */
		IGRlong	  grid_per_ref_y;	   /* # of grid dots 
						      between y-axis
						      cross	       */
		IGRint	  levels[32];		   /* levels	       */
		IGRshort  display_mode;		   /* display mode     */
		IGRdouble min_x_indep;		   /* the portion of   */
						   /* the window that  */
		IGRdouble min_y_indep;		   /* the gadget       */
		IGRdouble max_x_indep;		   /* occupies defined */
		IGRdouble max_y_indep;		   /* as percentages   
						      of the window    */
                IGRdouble uor_per_ref_x;           /* uor value between
                                                      grid reference
						      x-axis crosses   */
                IGRdouble uor_per_ref_y;           /* uor value between
                                                      grid reference
						      y-axis crosses   */
                IGRpoint origin;                   /* view origin      */
                IGRdouble rotation[4][4];          /* view rotation
                                                      matrix           */
                IGRdouble vw_volume[6];            /* view volume      */
                IGRdouble act_z;                   /* active z in viewing
                                                      coordinate system*/
		IGRdouble construct_plane[4][4];   /* construction
						      plane matrix     */
		IGRpoint  eye_pt;		   /* eye point        */
		IGRpoint  coi;	   		   /* center of 
						      interest	       */
		IGRdouble vw_angle;		   /* view angle       	*/
		IGRpoint  vrp;			   /* view reference pt */
		IGRvector vpn;			   /* view plane normal */
		IGRvector vup;			   /* view up vector    */
               };


#endif
           

