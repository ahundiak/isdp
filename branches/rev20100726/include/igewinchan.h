




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

#ifndef igewinchan_include

#define igewinchan_include

channel window_to_exec
{
   (many_to_many, 
    initial=1, increment=1)
    exec;
};

channel window_to_gadgets
{
   (one_to_many, 
    initial=1, increment=1)
    IGEgadget;
};

channel parent_to_children
{
   (one_to_many, 
    initial=1, increment=1)
    IGEgadget;
};

channel children_to_parent
{
   (many_to_one, 
    initial=1, increment=1)
    IGEgadget;
};

channel window_to_module
{
   (many_to_one, 
    initial=1, increment=1)
    module;
};

#endif
