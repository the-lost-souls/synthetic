Unit DemoGrx2;

InterFace
  Const
    res : Word=320;

  Type
    RgbsType = Array(.0..767.) Of Byte;
    BlackWhiteType = (CBlack, CWhite);
    XYType = Record
             X, Y : Integer;
           End;
    ByteArray = Array(.1..1.) Of Byte;

  Procedure FadeOutPicture(Rgbs : RgbsType);      {Fades out a picture to black}
  Procedure FadeInPicture(Rgbs : RgbsType; FromColor : BlackWhiteType); {Fades in a picture}

  Procedure InitScreen(Mode : Byte);       {Inits graphicscreen}

  Procedure XYZ(InX, InY, CenterX, CenterY : Integer; InZ : Real; Var OutX, OutY : Integer);
  {Converts XYZ-Coordinates to ScreenXY-Coordinates}

  Procedure GetPicturePalette(FileName : String; Var Rgbs : RgbsType);
  {Gets 256-palette from picturefile}
  Procedure ViewPicture(FileName : String);
  Procedure Set256Palette(Rgbs : RgbsType);             {Sets a 256-Colour palette. Red, Green, Blue..}
  Procedure SetRgbColor(R, G, B, Color : Byte);         {Sets a color in the palette}
  Procedure FPutPixel(X, Y : Word; Color : Byte; Screen : Word);    {Puts a pixel}
  Function FGetPixel(X, Y : Word; Screen : Word) : Byte;            {Gets a pixelcolor}

  Function FileExists(FileName : String) : Boolean;
  {Tests a file's extension}
  Function IntToStr(I : LongInt) : String; {Converts integer to string}
  Function StrToInt(S : String) : Integer;
  {Converts String to Integer}

  Procedure LoadFont(FileName : String); {Loads a font}
  Procedure FontString(X, Y : Integer; S : String; FontScreen : Word);
  Procedure RemoveFont;
  Procedure ViewPcx(FileName : String);           {Views a PCXPicture in 320x200x256}
  Procedure GetPCXPalette(FileName : String; Var Rgbs : RgbsType);    {Loads the PCX-Palette from file}



Implementation

Uses
  Dos;


Var
  I : Integer;
  B : Boolean;
  Regs : Registers;
  FontList : Array(.1..40.) Of ^ByteArray;
  PixelX, PixelY : Byte;

Procedure FadeOutPicture(Rgbs : RgbsType);      {Fades out a picture to black}

Begin
  Repeat
    B := False;
    For I := 0 To 767 Do If Rgbs(.I.) > 0 Then
    Begin
      Dec(Rgbs(.I.));
      B := True;
    End;
    Set256Palette(Rgbs);
  Until B = False;

  FillChar(Mem(.$A000 : $0000.), 64000, 0);    {Fills screen with black}
End;            {Procedure FadeOutPicture}


Procedure FadeInPicture(Rgbs : RgbsType; FromColor : BlackWhiteType); {Fades in a picture}

Var
  TempRgbs : RgbsType;

Begin
  Case FromColor Of

  CBlack : Begin
             For I := 0 To 767 Do TempRgbs(.I.) := 0;
             Repeat
               B := False;
               For I := 0 To 767 Do If TempRgbs(.I.) < Rgbs(.I.) Then
               Begin
                 Inc(TempRgbs(.I.));
                 B := True;
               End;
               Set256Palette(TempRgbs);
             Until B = False;
           End;

  CWhite : Begin
             For I := 0 To 767 Do TempRgbs(.I.) := 63;

             Repeat
               B := False;
               For I := 0 To 767 Do If TempRgbs(.I.) > Rgbs(.I.) Then
               Begin
                 Dec(TempRgbs(.I.));
                 B := True;
               End;
               Set256Palette(TempRgbs);
             Until B = False;
           End;
  End;
End;  {Procedure FadeInPicture}


Procedure InitScreen(Mode : Byte);      {Inits graphicmode}

Begin
  Regs.Ah := 0;
  Regs.Al := Mode;

  Intr($10, Regs);
End;              {Procedure InitScreen}

Procedure XYZ(InX, InY, CenterX, CenterY : Integer; InZ : Real; Var OutX, OutY : Integer);
{Converts XYZ-Coordinates to ScreenXY-Coordinates}

Var
  WorkVar : Integer;

Begin
  If InX < CenterX Then
  Begin
    WorkVar := CenterX - InX;
    OutX := Round(CenterX - (WorkVar / InZ));
  End;
  If InY < CenterY Then
  Begin
    WorkVar := CenterY - InY;
    OutY := Round(CenterY - (WorkVar / InZ));
  End;
  If InX > CenterX Then
  Begin
    WorkVar := InX - CenterX;
    OutX := Round(CenterX + (WorkVar / InZ));
  End;
  If InY > CenterY Then
  Begin
    WorkVar := InY - CenterY;
    OutY := Round(CenterY + (WorkVar / InZ));
  End;
  If InY = CenterY Then OutY := CenterY;
  If InX = CenterX Then OutX := CenterX;
End;               {Procedure XYZ}


Procedure GetPicturePalette(FileName : String; Var Rgbs : RgbsType);
{Gets 256-Palette from picturefile}

Var
  F : File;

Begin
  If Not FileExists(FileName) Then
  Begin
    InitScreen($2);
    Write('Couldn''t find PictureFile');
    Halt;
  End;

  Assign(F, FileName);
  Reset(F, 1);

  BlockRead(F, Rgbs, SizeOf(Rgbs), I);

  Close(F);
End;       {Procedure GetPicturePalette}

Procedure ViewPicture(FileName : String);
{Views picture}

Var
  Rgbs : RgbsType;
  F : File;
  X, Y : Integer;
  Color : Byte;

Begin
  GetPicturePalette(FileName, Rgbs);
  Set256Palette(Rgbs);

  If Not FileExists(FileName) Then
  Begin
    InitScreen($2);
    Write('Couldn''t find PictureFile');
    Halt;
  End;

  Assign(F, FileName);
  Reset(F, 1);

  Seek(F, 767);

  BlockRead(F, Mem(.$A000:$0000.), 64000, X);
  Close(F);
End;       {Procedure ViewPicture}


Procedure Set256Palette(Rgbs : RgbsType);  {Sets the 256-Colour Palette. Colours are Red, Green, Blue...Red, Green, Blue}

Begin
  Regs.Ah:=$10;
  Regs.Al:=$12;
  Regs.Bx:=0;          {StartColour}
  Regs.Cx:=255;        {EndColour}
  Regs.Es:=Seg(Rgbs);
  Regs.Dx:=Ofs(Rgbs);
  Intr($10,Regs);
End;                   {Procedure Set256Palette}


Procedure SetRgbColor(R, G, B, Color : Byte);  {Sets one color in the palette}

Begin
  Regs.Ah := $10;
  Regs.Al := $10;
  Regs.Bx := Color;

  Regs.Dh := R;
  Regs.Ch := G;
  Regs.Cl := B;

  Intr($10, Regs);
End;                    {Procedure SetRgbColor}


Function FGetpixel(x,y:word; Screen : Word) : Byte;

Var
  C : Byte;

Begin
  Asm
    mov ax, Screen                {ScreenMemory}
    mov es, ax                    {Put it in es}
    mov dx, y
    mov ax, y
    {$G+}
    rol dx, 6
    rol ax, 8
    {$G-}
    add dx, ax
    add dx, x
    mov di, dx
    mov al, es:[di]
    mov c, al
  End;

  FGetPixel := C;
end;

procedure FPutpixel(X, Y : Word; Color : Byte; Screen : Word); Assembler;
asm
  cmp x,320
  jge @out
  cmp x,0
  jl  @out
  cmp y,200
  jge @out
  cmp y,0
  jl  @out

  mov ax, Screen                {ScreenMemory}
  mov es, ax                    {Put it in es}
  mov dx, y
  mov ax, y
  {$G+}
  rol dx, 6
  rol ax, 8
  {$G-}
  add dx, ax
  add dx, x
  mov di, dx
  mov al, color
  mov es:[di], al

  @out:
end;

Function FileExists(FileName : String) : Boolean;
{Tests a file's extension}

Var
  F : File;

Begin
  {$I-}
  Assign(F, FileName);
  Reset(F);
  Close(F);
  {$I+}
  FileExists := (IOResult = 0) And (FileName <> '');
End;         {Procedure FileExists}

function IntToStr(i: Longint): string;
{ Convert any Integer type to a string }

var
  s: string[11];
begin
  Str(i, s);
  IntToStr := s;
end;       {Function IntToStr}

Function StrToInt(S : String) : Integer;
{Converts String to Integer}

Var
  TempI, Code : Integer;

Begin
  Val(S, TempI, Code);
  If Code = 0 Then StrToInt := TempI
  Else
  Begin
    WriteLn('Error !');
    Halt;
  End;
End;      {Function StrToInt}


Procedure LoadFont(FileName : String);
{Loads FontFile}

Var
  F : File Of Byte;
  Dummy : Integer;

Begin
  Assign(F, FileName);
  Reset(F);
  Read(F, PixelX, PixelY);

  For I := 1 To 40 Do GetMem(FontList(.I.), SizeOf(FontList(.I.)^) * (PixelX * PixelY));

  For I := 1 To 40 Do
  For Dummy := 1 To PixelX * PixelY Do
  Read(F, FontList(.I.)^(.Dummy.));
  Close(F);
End;            {Procedure LoadFont}


Procedure FontString(X, Y : Integer; S : String; FontScreen : Word);
{Displays string in loaded font}

Procedure FontChar(CharNumber : Integer);

Var
  CountX, CountY : Integer;

Begin
  For CountY := 1 To PixelY - 1 Do
  For CountX := 1 To PixelX Do
  FPutPixel(CountX + X, CountY + Y, FontList(.CharNumber.)^(.((CountY) * (PixelX)) + CountX.), FontScreen);
  Inc(X, PixelX + 2);
End;               {Procedure FontChar}

Begin
  For I := 1 To Length(S) Do
  Case UpCase(S(.I.)) Of
    'A' : FontChar(1);
    'B' : FontChar(2);
    'C' : FontChar(3);
    'D' : FontChar(4);
    'E' : FontChar(5);
    'F' : FontChar(6);
    'G' : FontChar(7);
    'H' : FontChar(8);
    'I' : FontChar(9);
    'J' : FontChar(10);
    'K' : FontChar(11);
    'L' : FontChar(12);
    'M' : FontChar(13);
    'N' : FontChar(14);
    'O' : FontChar(15);
    'P' : FontChar(16);
    'Q' : FontChar(17);
    'R' : FontChar(18);
    'S' : FontChar(19);
    'T' : FontChar(20);
    'U' : FontChar(21);
    'V' : FontChar(22);
    'W' : FontChar(23);
    'X' : FontChar(24);
    'Y' : FontChar(25);
    'Z' : FontChar(26);
    ' ' : Inc(X, PixelX + 2);
  End;
End;               {Procedure FontString}


Procedure RemoveFont;
{Removes Font from memory}

Begin
  For I := 1 To 40 Do FreeMem(FontList(.I.), SizeOf(FontList(.I.)^) * (PixelX * PixelY));
End; {Procedure RemoveFont}


Procedure GetPCXPalette(FileName : String; Var Rgbs : RgbsType);    {Loads the PCX-Palette from file}

Var
  F : File;

Begin
  If Not FileExists(FileName) Then
  Begin
    InitScreen($2);
    Write('Couldn''t find PCX-File');
    Halt;
  End;

  Assign(F, FileName);
  Reset(F, 1);

  Seek(F, FileSize(F) - 768);
  BlockRead(F, Rgbs, SizeOf(Rgbs), I);

  For I := 0 To 767 Do Rgbs(.I.) := Rgbs(.I.) SHR 2;

  Close(F);
End;            {Procedure GetPCXPalette}


Procedure ViewPcx(FileName : String);           {Views a PCX-picture in 320x200x256}

Const
  DataBuffer = $1400;                   {How many bytes to read from file at every loop}

Var
  ScreenOffset, BufferCounter, HowMany : LongInt;
  PCXBuffer : Array(.1..DataBuffer.) Of Byte;
  Rgbs : RgbsType;
  DataByte : Byte;
  NumRead : Word;
  F : File;

Procedure FillBuffer;                           {Fills the databuffer}

Begin
  If (BufferCounter > DataBuffer) Then
  Begin
    BufferCounter := 1;
    BlockRead(F, PCXBuffer, SizeOf(PCXBuffer), NumRead);
  End;
  DataByte := PCXBuffer(.BufferCounter.);
  Inc(BufferCounter);
End;                                    {Procedure FillBuffer}


Begin
  If Not FileExists(FileName) Then
  Begin
    InitScreen($2);
    Write('Error : Couldn''t find PcxFile');
    Halt;
  End;

  Assign(F, FileName);
  Reset(F, 1);

  GetPCXPalette(FileName, Rgbs);
  Set256Palette(Rgbs);

  Seek(F, 128);

  HowMany := 0;
  ScreenOffset := 0;
  BufferCounter := Databuffer+1;

  While (ScreenOffset < 64000) Do
  Begin
    FillBuffer;
    HowMany := 1;
    If (DataByte And $C0) = $C0 Then
    Begin
      HowMany := DataByte And $3F;
      FillBuffer;
    End;
    FillChar(Mem(.$A000 : ScreenOffset.), HowMany, DataByte);   {Puts PCXBytes in Videomemory ($AAA:0000)}
    Inc(ScreenOffset, Howmany);
  End;

  Close(F);
End;            {Procedure ViewPCX}

End. {Unit DemoGrx}