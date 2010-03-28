/* #######################    APOGEE COMPILED   ######################## */





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

/*----
%GP%  CODE CLASSIFICATION                           
----
%HD%

      CLASS NAME:     GRadp
      SUBCLASS OF:    IGEcolsup, global_class

-----
%CD%

      CHANNELS DECLARED:
-----
%MD%

      MESSAGES DECLARED:
      METHODS OVERRIDDEN: global_class.wake_up
                          global_class.super_construct
                          IGEcolsup.color_table_changed
-----
%NB%

      NOTES:
-----
%CH%

      CHANGE HISTORY:

        WBC  11/30/87:   Creation date.
-----
%PD%
--------------------------------------------------------------------
                 C L A S S    D E S C R I P T I O N
--------------------------------------------------------------------
    The class GRadp (Active Drawing Parameters) is a subclass
of global_class.  It initializes and displays the Active
Drawing Parameters form (which displays the active weight, color,
style and layer).  If the color table is changed, this class will
be notified via the color_table_changed message.  Any Drawing
Parameters Form being displayed at that time will be updated to
reflect the changes to the color table.
----*/
/*EH*/

class specification GRadp (1:1) of IGEcolsup, global_class;

override super_construct, wake_up, color_table_changed, sleep;

end specification GRadp;
