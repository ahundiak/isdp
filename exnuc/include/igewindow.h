




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

#ifndef igewindow_include

#define igewindow_include


	/*
	 *
	 *    This include file is dependent on the following 
	 *    include files:
	 *
	 *	igetypedef.h
	 *
	 */

struct DPws_flags     /* work station flags      */
{
     unsigned int display_origin :1;  /*  the origin from 
                                           which points are 
                                           taken: screen or 
                                           window origin */
           
     unsigned int x_origin       :1;  /*  x_origin from the
                                           left or right    */
           
     unsigned int y_origin       :1;  /*  y_origin from top or
                                                      bottom */
           
     unsigned int RFU            :29; /*  reserved for future
                                                           use */
};

           

struct win_var_list
{
    IGRint var;
    IGRchar *var_ptr;
    IGRlong num_bytes;
    IGRlong *bytes_returned;
};

struct IGEdit_range
{
  IGRint xlo;
  IGRint ylo;
  IGRint xhi;
  IGRint yhi;
};


struct dyn_flags
{
   IGRboolean dyn_on;
   IGRboolean mod_flag;
};

struct IGEsrstate
{
   IGRint	count;
   IGRint	win_no;
   IGRint	objid[5];
   unsigned short osnum[5];
};

#endif
