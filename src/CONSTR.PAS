Program ConString;

Uses
  Crt;

Const
  OutPutFile = 'Str.asm';
  CharArray =  'ABCDEFGHIJKLMNOPQRSTUVWXYZ:.,!? 1';
  NumStrings = 1;

Var
  StF : Text;
  TextA : Array(.1..NumStrings.) Of String(.80.);
  I, I2, SLength : Integer;

Begin
  SLength := 0;
  TextA(.1.) := 'A PRODUCTION OF';

  Assign(StF, OutPutFile);
  Rewrite(StF);
  Write(StF, '                DB ');
  For I2 := 1 To NumStrings Do
  Begin
    For I := 1 To Length(TextA(.I2.)) Do Write(StF, Pos(TextA(.I2, I.), CharArray), ', ');
    Inc(SLength, Length(TextA(.I2.)));
  End;
  Close(StF);
  WriteLn('TextLength : ', Slength);
  Repeat Until KeyPressed;
End.