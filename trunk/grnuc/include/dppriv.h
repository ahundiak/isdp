




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

#ifndef dppriv_include

#define dppriv_include

struct clip_struct
{
    IGRboolean need_clip; /* 1 - clip. 0 - do not clip */
    IGRboolean rect_clip;
    IGRboolean front_clip;
    IGRboolean back_clip;
    IGRdouble  dit_clip_range[6];
};

struct mat_struct
{
    IGRmatrix  matrix;       /* view matrix		  */
};


struct DPgad_extent
{
   IGRint	index;
   GRobjid	id;
   IGRint	x_min;
   IGRint	y_min;
   IGRint	x_max;
   IGRint	y_max;
};

struct DPgad_in_win
{
   IGRint	num_of_gra_gad;
   struct DPgad_extent	gads[4];
};


#endif
