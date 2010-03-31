#ifndef REcurve_h
#define REcurve_h 1

/*
  This include file contains the recomputation information and type 
  definition for all the instantiable classes under GAcurve.

  EMSmsc_id        1
  EMSmsc_key       2
  EMSmsc_id_key    3

History:
 PP: 11/4/91 : Trying to make some sense of the info spread out in 
               different include files.
 SY : 06/30/93 : Add data structure for law curve recomputation.
*/

#define EMSmsc_id           1  /* Contains object id of the edge or loop to
                                * which this model-space counterpart corresponds
                                */
/*
 * In this case the objid is stored in EMSassoc vla.
 *
 * OM_S_OBJID objid;
 */

#define EMSmsc_key          2  /* Contains the key of the edge or loop to
                                * which this model-space counterpart corresponds
                                */

/*
 * In this case only the key is stored in EMSassoc vla. This structure
 * is defined in EMSkey.h
 * struct EMSkey
 * {
 *   unsigned short chan_count;      
 *   unsigned short chan_index;     
 *   unsigned char  sub_item_type; 
 * };
 */

#define EMSmsc_id_key       3  /* Contains both the object id and the key of
                                * the edge or loop to which this model-space
                                * counterpart corresponds
                                */

/*
 * If both key and id are stored then the recomputation information of
 * the pointer object can be unpacked by typecasting to the following
 * structure . The same is defined in REpointer.h

 * struct EMSobjid_key
 * {
 *  OM_S_OBJID objid;
 *  unsigned char key_info[];
 * };
 */

#define EMSmsc_match_failed 4  /* Indicator that topology matching has failed
                                * for this object
                                */

/* Recompute info for law curve */

struct EMSlaw_curve
{
  IGRvector axis, normal;
  IGRboolean reversed;
  IGRchar name[1];
};

#define EMSmsc_noncount_key 5  /* Same as EMSmsc_id and stores some 
				* creator specific information.
				*/

/*
struct EMSnoncountkey {
  OM_S_OBJID objid;
  IGRshort item_type;
  IGRshort info_type;
  IGRshort size;
  char key[1];
};
*/
#define EMSmsc_long_key     6   /* Stores key, id and creator specific 
				 * information.
				 */
/*
struct EMSlong_key {
  OM_S_OBJID objid;
  struct EMStmp_key noncount_st;
  unsigned char key_info[1];
};
*/

#define EMSuniq_normal    20	/* Stores the point and normal corresponds
	                           to original curve and transformed */
#endif
 
