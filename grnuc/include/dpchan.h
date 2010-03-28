




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


#ifndef dpchan_include

#define dpchan_include
 
channel gra_gad_to_winsup
{
   (many_to_many, 
    initial=1, increment=1)
    IGEwinsup;
};

channel gra_gad_to_all
{
   (many_to_many, 
    initial=1, increment=1)
};

channel gra_gad_to_instance_support
{
   (many_to_many, abs_ordered,
    initial=2, increment=1 )
};

channel winsup_to_gra_gad
{
   (many_to_many, 
    initial=1, increment=1)
    IGEgragad;
};

#endif
