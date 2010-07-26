




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

  /*
   *   include files for the display package  
   *
   *   This include file has the following dependencies:
   *	
   *		igrtypedef.h
   *
   */

#ifndef dp_include

#define     dp_include
        
enum  GRdpmode  {GRbd, GRbe, GRhd, GRhe, GRbdhd, GRbehe,
                 GRbdhe, GRbehd, GRhhd, GRhdo, GRhhdo, GRheo, GRbdheo, GRbeheo};


struct var_list
{
    IGRint var;
    IGRchar *var_ptr;
    IGRlong num_bytes;
    IGRlong *bytes_returned;
};

struct DPdit_range
{
  IGRint xlo;
  IGRint ylo;
  IGRint xhi;
  IGRint yhi;
};

#endif
