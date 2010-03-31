/*
 * This macro performs a getsize, malloc, and a getgeom.
 *
 * Input arguments are as follows:
 *
 *      sts             OM error return status (int)
 *      msg             pointer to the error return code which will be one
 *                      of (MSSUCC, MANOMEMORY, MSFAIL) (int *)
 *      located_object  the located object (struct GRlc_info *)
 *      is_a_curve      if TRUE then use IGRbsp_curve, else use
 *                      IGRbsp_surface
 *      resultant_geom  (struct IGRbsp_curve *) or (struct IGRbsp_surface *)
 *
 * Include files required:
 *
 *      msdef.h
 *      maerr.h
 *
 *      RLW     12/05/86
 * 	rlw	12/20/87 : made the macro call a funtion in order to
 *                         reduce code space
 */
#define EMS_GET_GEOMETRY(sts,msg,located_object,is_a_curve,resultant_geom) \
{ \
 sts = EMget_the_geometry( \
  located_object, \
  is_a_curve, \
  FALSE, \
  FALSE, \
  my_id, \
  &resultant_geom, \
  msg); \
}

/* The following options are required for deciding the type of the geometry
 * that should be extracted for an edge.
 */

#define EMSedgeom_logical      0x1   /* Extract the logical geometry as opposed
                                      * to the natural (i.e. stored) geometry
                                      * which is the default.
                                      */
#define EMSedgeom_full         0x2   /* Extract the geometry of the "full-edge".
                                      * By default, you get the geometry of the
                                      * actual extents of the edge. This option
                                      * does not affect non-partedges.
                                      * By default, the EMedgetgeom
                                      * function will return the geometry of a
                                      * part-edge within its bounds only. This
                                      * option will return the geometry of the 
                                      * underlying full-edge.
                                      * Again, if you want the function to 
                                      * return the geometry of the actual extent
                                      * of the edge, DO NOT use this option.
                                      */
