/*\
ABSTRACT : AStextpm is the class of associative text with a position relative
           to other elements of the design (as AStext) but also with a text 
	   string relative to other elements of the design.

           This object has one more root than an AStext which is a parameter :
           -  text string of class text_exp printed with %s
           -  value of another subclass of expression, printed for the moment
	      in the fix format %10.3lf.


CHANGE HISTORY :
        jla       24-sep-87 : design
\*/

class specification AStextpm (0:1) of ASsrctext;

override GRvg;
override GRtext;
override GRnotify;

override ASevaluate;

/* MOTIVATION
evaluate the text string (in array for example) and store it by the function
call :  status = AStext_store(text,stren(text));
*/

end specification AStextpm;
