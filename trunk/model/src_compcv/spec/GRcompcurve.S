/* ###################   APOGEE COMPILED   ################## */
class specification GRcompcurve (1:0) of GRcurve, EMScomposite;

/*
Abstract
        This class maintains relationship between a group of curves
        connected end to end in sequence. Any object sub-classed off
        GRbspline is a valid entry. Currently compsite of composites
        are not supported. There is no limit on the number of curves
        that can be maintained in the relationship. All the curves
        that are components of a composite behave like a single curve
        as long as the curves are in this relationship.

History

        TGM     7/30/91     Un-Rejected GRkeypoint.
        RC      1/3/90      Inherit GRplotprep from GRgraphics.
        dhm     1/10/89     Override GRstretch.
        dhm     11/17/88    Override GRcpparallel.
        AIC     16 Jul 1988 Override GRcentcurv and GRcenter.
        AIC     08 Jul 1988 Override GRarea.
        dhm     05/16/88    Overrode GRgetsfsize and GRloadform.
        AIC     01-March-88 Override GRget_locate_properties to
                            return KLUGE bit GR_LC_CHECK_PLANAR so
                            that non-planar composite curve are not
                            located when the locate is searching
                            for planar objects. This is a very short
                            term solution and will be redone in the
                            1.1.1 release.
        AIC     23-Feb-88   Reject GRkeypoint for efficiency of tentative
                            keypoint snap.
        gk      01/22/87    creation date
        rlw     05/06/87    redid instance data, made this a subclass
                            of EMScomposite, removed overrides, took
                            out continuity stuff, moved EMinitcc to
                            GRconstruct, added overrides
        DLB     10/29/87    overrode GRvg instance data and removed 
                            EMdrpcc (GRdrop replaces it).
        RC      1/05/87     Removed override for EMbuild_stack.
*/


instance GRcompcurve
{
 IGRuchar       comp_props;     /* composite props indicator */
};
override
        GRdetplane,    /*
                         Motivation: Determine the plane of a composite
                         
                         Files
                                GRccdetplane.I
                       */
        GRgenabsg,     /*
                         Motivation: Generate abstract data of a composite
                         
                         Files
                                GRccgenabs.I
                       */
        GRgetgeom,     /*
                         Motivation: Get the geometry of a composite
                         
                         Files
                                GRccgetgeom.I
                       */
        GRgetsize,     /*
                         Motivation: Get the size of a composites geometry
                         
                         Files
                                GRccgetsize.I
                       */
        GRendpts,       /*
                          Motivation: Need to access two objects to
                          get end points

                          Files 
                                GRccendpts.I
                        */
        GRgeomprops;    /*
                          Motivation: Dummy method in declaring class

                          Files
                                GRccgeomprops.I
                        */
#ifndef BASE_EMS
/*

Further explanation of instance data. 
Note that keywords can be found in go/include/godef.h.

                Bit fields for comp_props
 
 bit     meaning                                keyword
 ---     -------                                -------
 0       not used
 1       not used
 2       not used
 3       not used
 4       is the curve phy closed?               GRIS_PHY_CLOSED

*/



        message EMmakecomp (IGRlong             *msg;
                            struct GRmd_env     *myModuleInfo;
                            IGRlong              num_ent;
                            struct GRlc_info    *entries;
                            IGRlong             *rotten_one);
/*
Abstract
        Given an array of curves in 'entries' this method makes a composite
        out of them. The message can be sent to either a composite curve
        object shell (in which case the objects being sent in form a composite)
        or to an existing composite curve (in which case the existing composite
        is extended further).

Notes
        When the curves are strung together the continuity condition should
        be set based on the geometric relationship between the curves
        (ie positional, tangential or curvature continuity). But, currently
        it is being arbitrarily set to 0.

Arguments
        msg             error return code       
                                MSSUCC if successful
                                GRILLDEFINITION if an object is closed
                                MSFAIL if an object end points are not
                                       close enough to the composite

        myModuleInfo    module information of composite curve

        num_ent         number of objects sent in

        entries         object info (id, osnum, moduleinfo)

        rotten_one      the entry that made compositing not possible

                        -1 implies that all objects being sent in are
                           okay. If *msg is GRILLDEFINITION, then the
                           composite curve object the message being
                           sent to is closed itself and can't take
                           any more objects

                         0 implies that first object itself is not a
                           valid object (happens if it is closed)

Files
        EMccmakecomp.I
*/

/******************************************************
 *REJECT GRvg INSTANCE DATA
 *****************************************************/
override GRvg;
        message EMaddtocomp(IGRlong             *msg;
                           struct GRid           add_obj;
                           struct GRmd_env      *objModuleInfo;
                           struct GRmd_env      *myModuleInfo;
                           IGRboolean            inter_allowed;
                           IGRdouble             search_tol;
                           IGRdouble             connect_tol;
                           IGRboolean            valid_end_pnt;
                           IGRpoint              comp_start;
                           IGRpoint              comp_stop;
                           IGRlong              *comp_so_far);
/*
Abstract
        This method adds an object to an existing composite curve.

Notes
        If the objects are not close enough the caller may request
        that they be extended to intersection. If there is an intersection
        then both, composite and the object, are trimmed to intersection.
        Otherwise error is returned.

Arguments
        msg             error return code GRILLDEFINITION if the composite
                                                        curve is closed.
                                          MSFAIL if object is closed
                                                 or points not close enough
                                                 or intersection doesn't exist

        add_obj         object to be added

        objModuleInfo   module information of the object to be added

        myModuleInfo    module information of the composite curve

        inter_allowed   TRUE if trimming to intersection is desired
                        currently set to FALSE

        search_tol      Only the objects with either end point within
                        this distance from an end point of composite
                        will be considered

        connect_tol     If either end point of the object is within this
                        distance from an end point of composite, then
                        it is added as is. Only if the distance greater
                        than this value, will intersection be considered,
                        if specified.

        valid_end_pnt   TRUE if the end points of composite curve are valid.
                        If the caller knows the end points of the composite
                        curve, setting this to TRUE will speed up the addition
                        process.

        comp_start      starting point of the composite curve; updated after
                        successful addition, if appropriate.

        comp_stop       stop point of the composite curve; updated after
                        successful addition, if appropriate.

        comp_so_far     number of components in the composite curve. If the
                        number of components are known apriori, this could
                        be set in the caller. If *comp_so_far <= 0, then
                        this method will determine the number of components
                        in the composite. The value will be update upon
                        successful addition
Files
        EMccaddtoc.I
*/

override
        GRstretch,
        /*
            Motivation
                Fill in message declaration.

            File
                EMccstretch.I
        */

        GRcpparallel,
        /*
            Motivation
                Fill in message declaration.

            File
                EMcccpparal.I
        */

        GRcentcurv,
        /*
            Motivation
                Fill in message declaration.

            File
                EMscarea.I
        */

        GRcenter,
        /*
            Motivation
                Fill in message declaration.

            File
                EMscarea.I
        */

        GRarea,
        /*
            Motivation
                Fill in message declaration.

            File
                EMscarea.I
        */

        GRreport, GRreport_defaults, GRupdate_gadgets,
        /*
          Motivation

            Fill in a message declaration.

          Files
            EMccreport.I EMccrptdef.I EMccupdgad.I
        */

/*
 * KLUGE
 */
                GRget_locate_properties,
                GRremove_components,
		GRgetexgeom,
		GRgetexsize,
		EMpratpt,
		GRsplit,
		GR2ptpartdel,
		GR3ptpartdel,
		GRarclength,
		GRdisextend,
		GRmidpoint,
		EMpartofcv,
		GRptalong,
		GRptextend,
		GRptseqspace,
		GRtotlength,
        GRclip,
                        /*
                          Motivation: Treat overlap as outside.

                          Files 
                                GRccclip.I
                        */

        GRgetobjinfo,   /*
                          Motivation: Dummy method in declaring class

                          Files
                                GRccgetobjin.I
                        */
        GRrevparm,      /*
                          Motivation: Dummy method in declaring class

                          Files
                                GRccrevparm.I
                        */
        EMcrvcrvint,    /*
                          Motivation: Dummy method in declaring class

                          Files
                                EMccccint.I
                        */
        EMcrvslfint,    /*
                          Motivation: Dummy method in declaring class

                          Files
                                EMccslfint.I
                        */

        GRcopy,        /*
                         Motivation: need to copy a composite curve
                         
                         Files
                                EMcccopy.I
                       */
        GRconstruct,   /*
                         Motivation: Initialize the composite header
                         
                         Files
                                GRccconst.I
                       */
	    EMcvoffset,   /* Motivation : Offset composite curve 
		
			 Files
				EMccoffset.I
                       */

/* #ifndef IDRAW  commented out - Ashok - Sep 5, 1990 */
	EMgetpoles,	/*
			  Motivation: Dummy message at declaring class
			
			  Files
				EMccgetpoles.I
			*/
	GRrcopy,
/* #endif commented out - Ashok - Sep 5, 1990 */

        GRformatele,

        GRpostabsg;    /*
                         Motivation: Set composite properties after a change
                         
                         Files
                                GRccpostab.I
                       */


override	GRanalyze_element;

/* ***********************
   reject
        GRkeypoint; 
   ***********************  */
#endif

from GRgraphics inherit GRplotprep;

end specification GRcompcurve;
