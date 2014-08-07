  { A set of examples to demonstrate features of Extended Pascal }

  { Prospero Software, January 1993 }

  {  ------------------------------------------  }

PROGRAM strings1 (output);

  { Extended Pascal examples }
  { Variable length strings & substrings }

VAR a,b: string(20);  { a,b have "capacity" 20 }
    n: 1..10;

BEGIN
  a := '1234567890';
  FOR n := 1 TO 10 DO
      writeln(a[1..n],'.',substr(a,n+1));
    { The substring yields characters 1 to n of "a"; }
    { function substr takes the remaining characters }
  a := 'The quick brown fox';
  b := 'the lazy dog.';
  writeln(a+' jumps over '+b);
    { + operator concatenates strings }
  a[5..6] := 'sl';
  b[5..6] := 'do';
  writeln(a,' laughs at ',b);
END.

  { Generated output is:
    1.234567890
    12.34567890
    123.4567890
    1234.567890
    12345.67890
    123456.7890
    1234567.890
    12345678.90
    123456789.0
    1234567890.
    The quick brown fox jumps over the lazy dog.
    The slick brown fox laughs at the dozy dog.
  }

  {  ------------------------------------------  }

PROGRAM strings2 (output);

  { Extended Pascal examples }
  { Variable strings & fixed strings }

TYPE  pac10 = PACKED ARRAY [1..10] OF char;

VAR   a,b: string(20);
      x,y: pac10;

BEGIN
  x := 'One,two,';    { two trailing spaces supplied }
  y := 'three,four';  { fits exactly }
  a := trim(x);       { "trim" removes trailing spaces }
  b := a + y;
  IF x = a THEN writeln(b);
  writeln(index(b,'ee'));  { "index" locates 'ee' in b }
END.

  { Generated output is:
    One,two,three,four
	12
  }

  {  ------------------------------------------  }

PROGRAM strings3 (output);

  { Extended Pascal examples }
  { Schematic string parameters & domains }

TYPE  stringp = ^string;

VAR   p1,p2: stringp;

FUNCTION ps (s: string) = p: stringp;
    { Function ps takes a general string parameter,
      obtains space in the heap to fit a string of the
      length of the parameter, copies the parameter
      into the heap and returns the pointer }
    { The named function result avoids the need for
      a work variable }
  BEGIN
    new(p,length(s));
    p^ := s;
  END {ps};

BEGIN {program}
  p1 := ps('A rubber duck');
  p2 := ps('the ideal bath companion');
  writeln(p1^,' is (some say) ',p2^);
  dispose(p1);  { removes duck from heap }
END.

  { Generated output is:
    A rubber duck is (some say) the ideal bath companion
  }

  {  ------------------------------------------  }

PROGRAM instate1 (output);

  { Extended Pascal examples }
  { Initial states of simple types }

TYPE  col = (red,yellow,blue) VALUE yellow;

VAR   j: integer VALUE 999;
      cy: col;            { initialized to yellow }
      cr: col VALUE red;  { initialized to red }

PROCEDURE p;
    { As the type of the selector in the record below
      has an initial state, it determines the choice
      of variant (yellow) when the procedure is entered
      and the record variable is created }
  VAR rec: RECORD
	     a: integer VALUE 100;
	     CASE c: col OF
	       red:    (x: integer);
	       yellow: (y: real VALUE 2.5);
	       blue:   (z: complex);
	   END {rec};
  BEGIN
    writeln(rec.a,rec.y);
  END {p};

BEGIN {program}
  writeln(j+1);
  IF (succ(cr) = cy) AND (succ(cy) = blue) THEN
    writeln('cr and cy initialized');
  p;
END.

  { Generated output is:
      1000
    cr and cy initialized
       100 2.50000000000000E+000
  }

  {  ------------------------------------------  }

PROGRAM instate2 (output);

  { Extended Pascal examples }
  { Record constructor as initial state }

TYPE  col = (red,yellow,blue);
      rec = RECORD
	      a: integer;
	      CASE c: col OF
		red:    (x: integer);
		yellow: (y: real);
		blue:   (z: complex);
	    END
	    VALUE [ a: 100;
		    CASE c: yellow OF [y: 2.5] ];

VAR   gc: col;
      pr: ^rec;

PROCEDURE p (fc: col);
    { As the type of the record r below has a specified
      initial state, the record is initialized each time
      the procedure is entered and the variable created }
  VAR r: rec;
  BEGIN
    writeln(r.a*ord(fc));
    IF (fc = yellow) AND (r.c = fc) THEN writeln(r.y);
  END {p};

BEGIN {program}
  FOR gc := red TO blue DO p(gc);
  new(pr);    { pr^ gets initial state too }
  writeln(pr^.a,pr^.y);
END.

  { Generated output is:
	 0
       100
     2.50000000000000E+000
       200
       100 2.50000000000000E+000
  }

  {  ------------------------------------------  }

PROGRAM arrayc (output);

  { Extended Pascal examples }
  { Array constant & constant access }

TYPE  days = (sun,mon,tues,weds,thurs,fri,sat);
      dname = string(8);

VAR   d: days;

FUNCTION DayName (fd: days): dname;
    { Elements of the array constant DayNames can be
      selected with a variable index }
  TYPE  abbrevs = ARRAY [days] OF
		  PACKED ARRAY [1..5] OF char;
  CONST DayNames = abbrevs
	[ sun: 'Sun'; mon: 'Mon'; tues: 'Tues';
	  weds: 'Weds'; thurs: 'Thurs'; fri: 'Fri';
	  sat: 'Satur' ];
  BEGIN
    DayName := trim(DayNames[fd]) + 'day';
  END {DayName};

BEGIN {program}
  FOR d := fri DOWNTO mon DO writeln(DayName(d));
END.

  { Generated output is:
    Friday
    Thursday
    Wedsday
    Tuesday
    Monday
  }

  {  ------------------------------------------  }

  {  The next example consists of three modules and a main
     program.  Module "one" exports an interface named i1,
     containing two constants named "lower" and "upper".  }

MODULE one;

EXPORT i1 = (lower,upper);

CONST  lower = 0;
       upper = 11;

END {of heading};
END {of module one}.


  {  Module "two" imports the constants "lower" and "upper",
     uses them to define a type, and also re-exports them.
     Export interface i2 contains the type "subr", j2 contains
     the constants "lower" and "upper".   (Interface j2 is not
     used in this sequence of modules, but illustrates that
     re-export is allowed.)  }

MODULE two;

EXPORT i2 = (subr);             { just the type "subr" }
       j2 = (lower,upper);      { the two constants }

IMPORT i1;

TYPE   subr = lower..upper;

END { of heading };
END { of module two }.


  {  Module "three" employs qualified import and renaming.  It
     exports an interface named i3 containing a function, a type
     and two constants.  It imports i1 from module one and i2
     from module two, both qualified (that is, any references to
     the constituents must be qualified by the interface names).
     Also, the type "subr" is renamed on import to "lim_range".
     The constants are renamed on export as "lim_lower" and
     "lim_upper".  The heading of function "limited" is given
     in the module heading, and the function definition in the
     module block.  }

MODULE three;

EXPORT i3 = (limited,i2.lim_range,
	     i1.lower => lim_lower, i1.upper => lim_upper);

IMPORT i1 QUALIFIED;
       i2 QUALIFIED ONLY (subr => lim_range);

FUNCTION  limited (x: integer): i2.lim_range;

END { of heading};

FUNCTION  limited;
  BEGIN
    IF x < i1.lower THEN limited := i1.lower
    ELSE
    IF x > i1.upper THEN limited := i1.upper
    ELSE
      limited := x;
  END { limited };

END { of module three }.


  {  The main program imports interface i3 and calls the
     function "limited" to restrict the range of values. }

PROGRAM limit (output);

IMPORT i3;    { gets everything exported via i3 }

VAR    i: integer;
       limited_i: lim_range;

BEGIN
  FOR i := lim_lower - 3 TO lim_upper + 3 DO
    BEGIN
      limited_i := limited (i);
      IF limited_i <> i THEN
	writeln (' i =',i:3,', limited_i =',limited_i:3);
    END;
END.

  { Generated output is:
     i = -3, limited_i =  0
     i = -2, limited_i =  0
     i = -1, limited_i =  0
     i = 12, limited_i = 11
     i = 13, limited_i = 11
     i = 14, limited_i = 11
  }

  {  ------------------------------------------  }

  { This example consists of a module and a main program.
    The module exports a protected variable, and also has
    initialization and finalization parts. }

MODULE  pvm (output);

EXPORT  pvi = (PROTECTED v, stepv);
    { The protected export allows an importing module or
      program to reference v but not to modify it; v can
      only be changed by code within this module, such as
      the procedure stepv. }

CONST lo = 0; hi = 3;

VAR   v: lo..hi;

PROCEDURE stepv;

END { of module heading };

PROCEDURE stepv;
  BEGIN
    IF v = hi THEN v := lo
    ELSE v := succ(v);
  END {stepv};

TO BEGIN DO v := 1;
    { module initialization is performed
      before the main program block is entered .. }

TO END DO writeln ('Final value of v is ',v:1);
    { .. finalization is performed after it has completed }

END { of module };


PROGRAM pvp (output);

IMPORT  pvi;

VAR   j,k: integer;

BEGIN
  writeln('Initial value of v is ',v:1);
  REPEAT
    j := v;  stepv;  k := v;
  UNTIL k < j;
  writeln('Range of v is ',k:1,' to ',j:1);
  stepv;
END.

  { Generated output is:
    Initial value of v is 1
    Range of v is 0 to 3
    Final value of v is 1
  }

  {  ------------------------------------------  }

  {  ------------------------------------------  }

