/*

  ABSTRACT :
  --------

    The purpose of the objects of this class is to be the root directory of
  a files object space.  This class is a private class.

  HISTORY :
  -------

  03/18/1988 : HGB - Creation Date
*/

class specification DIroot ( 1:2 ) of DIrectory;

 instance DIroot
 {
   /* the channel to the object space */
   channel { (one_to_one, initial = 1, increment = 1) } to_OS;
 };


 message identify ( DIobjid *objid );
   /*
      This message is used to identify the root directory of an object space.

      Argument description :
      --------------------

        DIobjid *objid   : my objid to be added         (OUT)
   */

 override init;

end specification DIroot;

