Program ConFont;

Uses
  DemoGrx2, Crt;

Const
  InputFile = 'FONT.PCX';
  OutputFile = 'FONT.ASM';
  CharArray = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ:.,!? 1';
  XSize = 16;
  YSize = 16;
  CharsOnLine = 18;

Var
  TempFile : File Of Byte;
  OutFile : Text;
  Color : Byte;
  I, X, Y, XPos, YPos : Integer;
  CA : String;



Procedure SaveChar;

Begin
  For Y := YPos To (YPos+ YSize - 1) Do
  For X := XPos To XPos + XSize -1 Do
  Begin
    Color := Mem(.$A000:(Y * 320) + X.);
    If Color = 223 Then Color := 1 Else Color := 0;
    Write(TempFile, Color);
  End;
End;

Procedure Bin2Db;

Begin
  I := 1;

  Assign(OutFile, OutPutFile);
  Rewrite(OutFile);
  Seek(TempFile, 0);

  WriteLn(OutFile, '.Model  Small');
  WriteLn(OutFile, 'PUBLIC          Font');
  WriteLn(OutFile, 'MyData          SEGMENT');
  Write(OutFile, 'Font');

  For I := 1 To Length(CA) Do
  Begin
{    Write(OutFile, CA(.I.));}
    For Y := 1 To YSize Do
    Begin
      Write(OutFile, '                DB ');
      For X := 1 To (XSize - 1) Do
      Begin
        Read(TempFile, Color);
        Write(OutFile, Color:3, ', ');
      End;
      Read(TempFile, Color);
      WriteLn(OutFile, Color:3);
    End;
    WriteLn(OutFile);
  End;

  WriteLn(OutFile, 'MyData      ENDS');
  Write(OutFile, 'END');

  Close(OutFile);
End;

Begin
  Assign(TempFile, 'Temp.bin');
  Rewrite(TempFile);
  CA := CharArray;
  InitScreen($13);
  XPos := 0;
  YPos := 0;
  ViewPCX(InPutFile);

  For I := 1 To CharsOnLine Do
  Begin
    SaveChar;
    Inc(XPos, (XSize + 1));
  End;
  Inc(YPos, (YSize + 1));
  XPos := 0;
  For I := 1 To Length(CharArray) - CharsOnLine Do
  Begin
    SaveChar;
    Inc(XPos, (XSize + 1));
  End;

  Bin2Db;
  InitScreen(3);
  Close(TempFile);
  Erase(TempFile);
End.