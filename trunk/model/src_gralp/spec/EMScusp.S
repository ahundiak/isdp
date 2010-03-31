/* ###################   APOGEE COMPILED   ################## */
class specification EMScusp (2:0) of EMSgraloop;

/*

   History
     
       Jack  05-06-91   Created from Allen's 2.0.0 version.
       Jack  13-June-91 Added override of EMget_the_edges 
                        message. 
       DLB   07/10/91   Disable tagging.
       Jack  15-Oct-91  Added struct EMSpartolbasis parm to 
                        EMput_rule_lines.  This is the tol 
                        for the surface.
       Jack  25-Sep-92  Added override EMchangeSurface.(just return success)
*/

not_taggable;

override
        debug,
        EMget_the_edges,
        EMchangeSurface;

/*
    Initialize the cusp.
*/
message EMinit_cusp( struct IGRbsp_surface   *surface;
                     OM_S_OBJID               surface_id;
                     IGRshort                *matrix_type;
                     IGRdouble               *matrix);


message EMput_rule_lines(struct IGResqbs       *rule_lines;
                         int                    is_cusp;
                         OM_S_OBJID             surface_id;
                         struct EMSpartolbasis *partolbasis);



end specification EMScusp;
