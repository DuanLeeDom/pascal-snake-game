program snakegame;

uses
  Crt, Windows, MMSystem;

const
  Width = 20;  // Largura do campo de jogo
  Height = 10; // Altura do campo de jogo
  MaxLength = 100;

type
  TPoint = record
    X, Y: Integer;
  end;

var
  Snake: array[1..MaxLength] of TPoint;
  Length: Integer;
  Food: TPoint;
  Direction: Char;
  NextDirection: Char;
  GameOver: Boolean;
  Score: Integer;

procedure Setup;
begin
  Randomize;
  Length := 1;
  Snake[1].X := Width div 2;
  Snake[1].Y := Height div 2;
  Food.X := Random(Width - 1) + 1;
  Food.Y := Random(Height - 1) + 1;
  Direction := 'D';
  NextDirection := Direction;
  GameOver := False;
  Score := 0; // Reseta a pontuação
end;

procedure Draw;
var
  X, Y, i: Integer;
  IsSnakeSegment: Boolean;
begin
  // Atualize a borda superior uma vez, sem limpar a tela
  GotoXY(1, 1);
  WriteLn('+' + StringOfChar('-', Width) + '+  +----------+');

  for Y := 1 to Height do
  begin
    GotoXY(1, Y + 1); // Use GotoXY para ir diretamente à linha correta
    Write('|'); // Borda esquerda
    for X := 1 to Width do
    begin
      if (X = Snake[1].X) and (Y = Snake[1].Y) then
        Write('O') // Cabeça da cobra
      else if (X = Food.X) and (Y = Food.Y) then
        Write('*') // Comida
      else
      begin
        IsSnakeSegment := False;
        for i := 2 to Length do
          if (X = Snake[i].X) and (Y = Snake[i].Y) then
          begin
            Write('o'); // Corpo da cobra
            IsSnakeSegment := True;
            Break;
          end;
        if not IsSnakeSegment then
          Write(' '); // Espaço vazio
      end;
    end;
    Write('|'); // Borda direita

    // Atualiza a pontuação na direita
    GotoXY(Width + 3, Y + 1); // Ajusta para nova linha após o espaçamento
    if Y = 2 then
      WriteLn('  Score: ', Score) // Exibe a pontuação na linha 2
    else
      WriteLn(' '); // Espaço vazio para outras linhas
  end;

  // Desenha a borda inferior uma vez
  GotoXY(1, Height + 2);
  WriteLn('+' + StringOfChar('-', Width) + '+  +----------+');
end;

procedure Input;
begin
  if KeyPressed then
  begin
    NextDirection := ReadKey;
    // Impede mudanças de direção oposta
    if (NextDirection = 'w') and (Direction <> 's') then
      Direction := 'w'
    else if (NextDirection = 's') and (Direction <> 'w') then
      Direction := 's'
    else if (NextDirection = 'a') and (Direction <> 'd') then
      Direction := 'a'
    else if (NextDirection = 'd') and (Direction <> 'a') then
      Direction := 'd';
  end;
end;

procedure PlaySoundEffect;
begin
  mciSendString('open "C:\Users\duanl\Music\beep.wav" type waveaudio alias soundfile', nil, 0, 0);
  mciSendString('play soundfile', nil, 0, 0);
  Sleep(200);
  mciSendString('close soundfile', nil, 0, 0);
end;

procedure PlayBackgroundSound;
begin
  mciSendString('open "C:\Users\duanl\Music\background.wav" type waveaudio alias soundfile', nil, 0, 0);
  mciSendString('play bgmusic repeat', nil, 0, 0);
end;
procedure StopBackgroundMusic;
begin
  mciSendString('stop bgmusic', nil, 0, 0);
  mciSendString('close bgmusic', nil, 0, 0);
end;

procedure Logic;
var
  i: Integer;
begin
  // Atualiza o corpo da cobra
  for i := Length downto 2 do
    Snake[i] := Snake[i - 1];

  // Mover a cobra na direção atual
  case Direction of
    'w': Dec(Snake[1].Y); // Cima
    's': Inc(Snake[1].Y); // Baixo
    'a': Dec(Snake[1].X); // Esquerda
    'd': Inc(Snake[1].X); // Direita
  end;

  // Verifica se comeu a comida
  if (Snake[1].X = Food.X) and (Snake[1].Y = Food.Y) then
  begin
    if Length < MaxLength then
      Inc(Length);
    Food.X := Random(Width - 1) + 1;
    Food.Y := Random(Height - 1) + 1;
    Inc(Score); // Aumenta a pontuação
    //PlaySound('beep.mp3', 0, SND_ASYNC);
    PlaySoundEffect;

  end;

  // Verifica se colidiu consigo mesma ou com as bordas
  if (Snake[1].X < 1) or (Snake[1].X > Width) or (Snake[1].Y < 1) or (Snake[1].Y > Height) then
    GameOver := True;

  for i := 2 to Length do
    if (Snake[1].X = Snake[i].X) and (Snake[1].Y = Snake[i].Y) then
      GameOver := True;
end;

procedure HideCursor;
var
  Info: CONSOLE_CURSOR_INFO;
begin
  GetConsoleCursorInfo(GetStdHandle(STD_OUTPUT_HANDLE), Info);
  Info.bVisible := False; // Oculta o cursor
  SetConsoleCursorInfo(GetStdHandle(STD_OUTPUT_HANDLE), Info);
end;

procedure ShowCursor;
var
  Info: CONSOLE_CURSOR_INFO;
begin
  GetConsoleCursorInfo(GetStdHandle(STD_OUTPUT_HANDLE), Info);
  Info.bVisible := True; // Mostra o cursor
  SetConsoleCursorInfo(GetStdHandle(STD_OUTPUT_HANDLE), Info);
end;

function PlayAgain: Boolean;
var
  Choice: Char;
begin
  GotoXY(1, Height + 3);
  Write('Deseja jogar novamente? (S/N): ');
  Choice := ReadKey;
  Result := (Choice = 'S') or (Choice = 's');
end;

begin
  repeat
    Setup;

    // Oculta o cursor
    HideCursor;

    // Centraliza a saída no console (sem limpar a tela constantemente)
    GotoXY(1, 1);
    ClrScr;
    WriteLn('            /^\/^\' );
    WriteLn('          _|__|  O|' );
    WriteLn('   \/    /~     \_/ \' );
    WriteLn('    \____|__________|' );
    WriteLn('           \_______\' );
    WriteLn('  +--------------------+');
    WriteLn('  |      Snake Game    |');
    WriteLn('  +--------------------+');
    WriteLn('  |   Controles:       |');
    WriteLn('  |   W - Cima         |');
    WriteLn('  |   S - Baixo        |');
    WriteLn('  |   A - Esquerda     |');
    WriteLn('  |   D - Direita      |');
    WriteLn('  +--------------------+');
    WriteLn('  |                    |');
    WriteLn('  |   o                |   -> Corpo da cobra');
    WriteLn('  |   o                |   -> Corpo da cobra');
    WriteLn('  |   0                |   -> Cabeca da cobra ');
    WriteLn('  |   *                |   -> Comida');
    WriteLn('  |                    |');
    WriteLn('  +--------------------+');
    WriteLn('  |   Score: 0         |   -> A quantidade de comida');
    WriteLn('  +--------------------+');
    WriteLn('Pressione qualquer tecla para iniciar o jogo...');
    ReadKey; // Espera o jogador pressionar uma tecla
    Clrscr;

    while not GameOver do
    begin
      Draw;
      Input;
      Logic;
      Delay(100); // Controla a velocidade do jogo
    end;

    GotoXY(1, Height + 3);
    ClrScr;
    WriteLn('            /^\/^\          _____                         ____                 _ ' );
    WriteLn('          _|__|  O|        / ____|                       / __ \               | |' );
    WriteLn('   \/    /~     \_/ \     | |  __  __ _ _ __ ___   ___  | |  | |_   _____ _ __| |' );
    WriteLn('    \____|__________|     | | |_ |/ _` | _ `  _ \ / _ \ | |  | \ \ / / _ \  __| |' );
    WriteLn('           \_______\      | |__| | (_| | | | | | |  __/ | |__| |\ V /  __/ |  |_|' );
    WriteLn('                           \_____|\__,_|_| |_| |_|\___|  \____/  \_/ \___|_|  (_)' );
    WriteLn();
    Writeln('Sua pontuacao final: ', Score);

    // Mostra o cursor novamente
    ShowCursor;
  until not PlayAgain;
end.

