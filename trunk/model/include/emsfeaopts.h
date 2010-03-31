/*
 * This file has been created to define the features options in terms
 * bits. The termonology has been choosen so as to be in concert
 * with the features are being looked at.
 *
 * History
 * Rustagi    ????  Creation
 */

/* These properties will be stored as instance data of the feature object,
 * since it will be needed during re-compute.
 */

/* Option for attributes of the feature. Used to store as recomp info. Therefore
 * these definitions may NEVER be changed. See structure EMSfeature_attributes
 * where these properties will be stored. If the number of properties exceeds
 * 31, then define the last bit 0x80000000 as EMSfeature_more_options_available,
 * so that the next item in the struct "more_attributes" can be searched for
 * remaining attributes.
 */

/* DO NOT CHANGE, REPEAT OR REASSIGN BELOW VALUES, SINCE THEY WILL BE STORED IN 
 * INSTANCE DATA.
 */

/* what is the "extent" of the feature */
#define EMSfeature_thru_all   0x1
#define EMSfeature_thru_next  0x2  /* for "remove material" */
#define EMSfeature_to_next    0x4  /* for "add material"    */
#define EMSfeature_thru_until 0x8
#define EMSfeature_from_to    0x10
#define EMSfeature_finite     0x20

/* whether feature is projected/revolved/skinned */
#define EMSfeature_projected  0x40
#define EMSfeature_revolved   0x80
#define EMSfeature_skinned    0x100

/*whether feature is proj/rev/skinned normal/non-normal to profile plane */
#define EMSfeature_normal_to_profile_plane      0x200

/* whether it is symmetric/one-sided */
#define EMSfeature_symmetric  0x400

/* whether,profile is to be extended/not-extended for profile creation */
#define EMSfeature_profile_extend   0x800

/* whether material addition/removal in to "right" side of profile or left. For
 * ribs where thickness is to be specified in plane of profile, this indicates
 * whether thickness vector is to "right" side of profile or not.
#define EMSfeature_profile_orient_right  REMOVED...IS NOW A PARENT
 */

/* to differentiate between the two types of ribs possible */
#define EMSfeature_thickness_in_profile_plane  0x1000

/* For an add/remove material type of feature that is non-symmetric, if this 
 * bit is NOT set, it means that there might be a "start surface" or a 
 * "start ref. plane" that are distinct from the ref. plane of the profile.
 * This bit makes sense however, ONLY if the "EMSfeature_from_to" bit is set.
 */
#define EMSfeature_from_profile         0x2000
