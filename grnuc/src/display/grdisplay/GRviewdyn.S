




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
%GP% CODE CLASSIFICATION
-----
%HD%

        CLASS NAME:     GRviewdyn       view dynamics
        SUBCLASS OF:    IGEgragad       gadget system

        Abstract:  defines the view dynamics class

-----
%CD%

        CHANNELS DECLARED:

        module
                      
                 
                                         
-----
%MD%

        MESSAGES DECLARED:



-----
%NB%

        NOTES:

-----
%CH%

        CHANGE HISTORY

        AET    09/13/88  : Design date.

-----
%PD%
--------------------------------------------------------------------
                C L A S S    D E S C R I P T I O N
--------------------------------------------------------------------

----*/
/*EH*/

class specification GRviewdyn (1:0) of IGEgragad;


/*      construct is GRviewdyn_construct;	*/

	override DPdisbyoid,DPdisbybuf,DPgen_update;

	message GRviewdyn_set_up(IGRlong *msg; IGRdouble stroke_scale_factor);

	message GRviewdyn_reset(IGRlong *msg);

        /* internal message used by display list code */
        message DPsetup_for_dlist_feedback( IGRlong *msg; IGRboolean setup_dl );

        /* internal message used by display list */
        message DPdisplay_for_dlist( IGRlong *msg; OM_S_OBJID objid; OMuword osnum );

end specification GRviewdyn;

