/*
  ABSTRACT

  This is a constructed class which represents the splitting operation of
  a solid by another surface. The resultant of the split are two
  independent state trees. Internally this type of operation is treated similar
  to 'intersect surface save side'.

  The class name stands for 'split solid with a surface', not to be confused
  with EMSslsplit.


  HISTORY

  SM	08-Jan-89	Design date.
*/

class specification EMSslspltwsf (1:0) of EMSslboolean, EMSsfspltwsf;

/*------------------ INSTANCE DATA SECTION -------------------*/

override GRvg;

end specification EMSslspltwsf;
