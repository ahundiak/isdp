/*****************************************************************************

  Description :

              Macro for Measuring distance between any 2 elements. 

  Creation :

  Srividya P. - 31st Mar 95 

*****************************************************************************/


#ifndef EMSmeas_dis_macro
#define EMSmeas_dis_macro


/**********************************************************************

    Description :

    This macro measures the distance between two elements.
    Returns the distance and the points on the corresponding
    elements from which the actual distance is measured. 

    IGRlong *msg        -  Output:
                           Message return code.
                           -MSSUCC,
                            if successful.
                           -MSFAIL,
                            in case  of failure.

    struct GRid first_grid -  Input:
                           The objectid and the osnum of the
			   first element to be measure from.

    struct GRid second_grid -  Input:
                           The objectid and the osnum of the
                           second element to be measured to.

    struct GRmd_env  *mod_env1 - Input:
			   The module environment of the first element.

    struct GRmd_env  *mod_env2 - Input:
			   The module environment of the second element.

    struct GRevent   *event1 - Input:
			  The accept point and the window_id and osnum
			  needs to be provided(if not the entire
			  structure) of the first element.

    struct GRevent   *event2 - Input:
			  The accept point and the window_id and osnum
			  needs to be provided(if not the entire
			  structure) of the second element.

    IGRboolean  app_flag  - Input:
			  Whether the 'apparent_flag' needs to be
			  obtained and correspondingly measure or not.
			  By default, it is FALSE (i.e 'gr$get_apparent_flag'
			  is not called for measurement).

    IGRdouble   *point1   - Output:
			  The point on the first element from which 
		    	  the measurement is done.

    IGRdouble   *point2   - Output:
			  The point on the second element to which 
		    	  the measurement is done.

    IGRdouble   *distance -  Output:
			  The minimum distance between the two elements
			  is returned .

**********************************************************************/
#omdef ems$meas_mindis_bet_2_eli (
		msg ,
                first_grid ,
                second_grid ,
                mod_env1,
                mod_env2,
                event1,
                event2,
                app_flag = FALSE,
                point1,
                point2,
                mindist
                )
	COmeasget_mindist(
                (msg) ,
                (first_grid) ,
                (second_grid) ,
                (mod_env1),
                (mod_env2),
                (event1),
                (event2),
                (app_flag),
                (point1),
                (point2),
                (mindist)
                )


#endomdef

#endif 
