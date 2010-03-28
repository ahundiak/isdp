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

/*
Name
        GRcsbase

Description
        This class defines the base coordinate system class, which must always
        be present in every object space.  For this reason the base may not
        be deleted.  The base is created by the coordinate system manager
        upon first reference to the csmgr.

History
        Kumar Talluri   11/08/86    design and implementation
        mrm             03/14/88    remove override for copy - copies are now
                                    considered valid as long as they are not of
                                    the GRcsbase class
                        03/31/88    override GRxform to disallow manipulation
                        04/27/88    override GRcopy to produce a "copy" of the
                                    GRgencs class
*/

class specification GRcsbase (1:0) of GRgencs;

override GRdelete,      /* deletion illegal */
         GRcopy,        /* produce GRgencs copy */
         GRxform;       /* manipulation illegal */

end specification GRcsbase;
