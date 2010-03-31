/* ###################   APOGEE COMPILED   ################## */
/*
  DESCRIPTION

    This command is the interface to create and manipulate law-curves
    that may be used by other commands in the system.

  HISTORY

    SS  :  08/23/89  :  Creation
    SY  :  06/30/93  :  Add associateve instance variable and override
                        wakeup and sleep. The command becomes associative.
    scw :  08/14/94  :  clarified sleep method
*/
   
class specification EClawcv (1:3) of ECelements;

instance EClawcv
  {
  IGRpoint orig;
  IGRpoint xpts[2];
  IGRvector plnnor;
  IGRshort substate, subtype;
  IGRboolean associative, reversed;
  };

override execute, get_locate_criteria, wakeup, super_cmd.sleep;

end specification EClawcv;
