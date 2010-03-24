




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

class specification cmdserver (1:0) of Root;


instance cmdserver
 {
   int stkptr,stklen,form_cmd_detached;
   struct EX_cmd_cntrl *cmdlist;

   channel {(many_to_one, initial=1, increment=1)} modcmds;
   channel {(rel_ordered, one_to_many, initial=1, increment=5)} cmdstack;
 };

message init_cs();

message wakeup_cs();

message exec_cs(int *response;char *response_data;int mode);

message sleep_cs(int type_sleep);

message disconnect_from_stack ( int *msg );

message clear_stack();

end specification cmdserver;
