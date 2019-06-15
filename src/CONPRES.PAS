Program ConFont;

Uses
  DemoGrx2, Crt;

Const
  InputFile = 'presents.PCX';
  OutputFile = 'presents.ASM';
  XSize = 90;
  YSize = 37;

Var
  TempFile : File Of Byte;
  OutFile : Text;
  Color : Byte;
  I, X, Y, XPos, YPos : Integer;

Procedure SaveChar;

Begin
  For Y := 0 To YSize Do
  For X := 0 To XSize Do
  Begin
    Color := Mem(.$A000:(Y * 320) + X.);
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
  WriteLn(OutFile, 'PUBLIC          Presents');
  WriteLn(OutFile, 'MyData          SEGMENT');
  Write(OutFile, 'Presents');

  For Y := 1 To 37 Do
  Begin
    Write(OutFile, '                DB ');
    For X := 1 To 90 Do
    Begin
      Read(TempFile, Color);
      Write(OutFile, Color:3, ', ');
    End;
    Read(TempFile, Color);
    WriteLn(OutFile, Color:3);
  End;

  WriteLn(OutFile, 'MyData      ENDS');
  Write(OutFile, 'END');

  Close(OutFile);
End;

Begin
  Assign(TempFile, 'Temp.bin');
  Rewrite(TempFile);
  InitScreen($13);
  XPos := 0;
  YPos := 0;
  ViewPCX(InPutFile);

  SaveChar;

  Bin2Db;
  InitScreen(3);
  Close(TempFile);
  Erase(TempFile);
End.