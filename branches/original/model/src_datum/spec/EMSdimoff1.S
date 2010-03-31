/* ###################   APOGEE COMPILED   ################## */
class specification EMSdimoff1 (2:0) of ASnode, EMSdimoff;

/*
 * The function of this class is to provide the ability for objects to
 * connect to this object using the notification channel. The parent class
 * EMSdimdtm does not have this ability.
 *
 * History
 *  Creation : dfl : 11/27/93
    modified : dfl : 09/20/94 - overide NDparent_deleted added to 
                                inform object of deletion of its parent
                                to delete itself and to delete (inform)
                                ist dependent DMsglpara object.
 */

override GRvg, 
         NDparent_deleted;
end specification EMSdimoff1;
