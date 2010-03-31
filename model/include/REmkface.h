#ifndef REmkface_include
#define REmkface_include 1

/*
  This include file contains the type  definition for the classes EMS*mkface.
  Please make sure when adding types to see that the same have not been defined
  at a parent level.  

 EMS_ASno_type                  0   - 2.0 version of assoc make face
 EMS_ASmkface_w_track_pt        1   - 2.0 vers of assoc make face w/ track pt
 EMS_ASmkface_ver2_1            2   - 2.1 version of assoc make face
 EMS_ASmkface_ver2_1_w_track_pt 3   - 2.1 vers of assoc make face w/ track pt

History:
 DLB: 08/12/92 : Use new assoc version for assoc make face.  Pre 2.1.0 version
                 will recompute without using point side orientation algorithm.
 DLB: 07/24/92 : Create this include for track pt support.
*/

/* EMS*mkface class recomputation info is the cht double only*/

/* For EMS_ASno_type 0 & w_track_pt*/

#define EMS_ASmkface_w_track_pt        1
#define EMS_ASmkface_ver2_1            2  
#define EMS_ASmkface_ver2_1_w_track_pt 3

#endif
