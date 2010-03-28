/* #######################    APOGEE COMPILED   ######################## */
/*\
Abstract
   The Locate Object class is a subclass of GRcmpowner.  This class serves
   as an intermediate object between the command object and the located
   graphics object.  This intermediate object is necessary since the 
   graphics object has a restricted channel and can not have connections 
   to another space.

History
   Gray Winn   08/27/87    Design and Coding Date.
\*/

class specification LCcmd_iso (1:0) of GRcmpowner;

instance LCcmd_iso
{
   /* 
    *  to_command    -  Channel to the command object.
    */

   channel {(many_to_many)} to_command;
};

end specification LCcmd_iso;
