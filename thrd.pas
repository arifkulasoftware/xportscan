{$I-}
unit thrd;

interface

uses
  sysutils,windows,Classes,scktcomp,Main;

type
  MyTh = class(TThread)
    procedure ClientSocket1Error(Sender: TObject; Socket: TCustomWinSocket;
      ErrorEvent: TErrorEvent; var ErrorCode: Integer);
  private
    { Private declarations }
  protected
    procedure Execute; override;
    Procedure AddTOLog;
  public
   IP   : String ;
   Port : Integer ;
   constructor Create(CreateSuspended: Boolean);
   destructor Destroy; override;
  end;

 Const
  Opened : Integer = 0;
  LogFn  : String = 'connects.log';

implementation

 Const
  Guard : Integer = 0;

Procedure AddLog(St:String);
 Var
  Tx : TextFile ;
 Begin
  AssignFile(Tx,LogFn);
  Append(Tx);
  If IoResult<>0 Then ReWrite(Tx);
  If IoResult<>0 Then Exit;
  WriteLn(Tx,St);
  CloseFile(Tx);
 End;

Procedure incSafe ;

 ASM
@1: MOV EDX,1
    XCHG Guard,EDX
    OR EDX,EDX
    JNZ @2
    INC opened
    MOV guard,EDX
    Ret
@2: PUSH 0
    CALL Sleep
    JMP @1
 END;

Procedure DecSafe ;

 ASM
@1: MOV EDX,1
    XCHG Guard,EDX
    OR EDX,EDX
    JNZ @2
    DEC opened
    MOV guard,EDX
    Ret
@2: PUSH 0
    CALL Sleep
    JMP @1
 END;


constructor MyTh.Create(CreateSuspended: Boolean);

 Begin
  incSafe;
  inherited ;
  FreeOnTerminate:=True;
  IP:='';
  Port:=0;
  Priority:=tpIdle;
 End;

destructor MyTh.Destroy;

 Begin
  DecSafe;
  inherited;
 End;

Procedure MyTh.AddTOLog;

 Begin
  FMain.Memo1.Lines.Add(IP+':'+IntToStr(Port));
  AddLog(IP+':'+IntToStr(Port));
 end;

Procedure MyTh.Execute;
Var CS:TClientSocket;
begin
 CS:=TClientSocket.Create(Nil);
 CS.OnError:=ClientSocket1Error;
 CS.ClientType:=ctBlocking;
 CS.Port:=Port;
 CS.Address:=IP;
// Synchronize(AddToLog);
 Try
  CS.Open;
  If CS.Active Then Synchronize(AddToLog);
  CS.Close;
 Except
//  on E: Exception do AddLog('(1) '+E.Message);
 End;
 Try
  CS.Free;
 Except
//  on E: Exception do AddLog('(2) '+E.Message);
 End;
end;

procedure MyTh.ClientSocket1Error(Sender: TObject;
  Socket: TCustomWinSocket; ErrorEvent: TErrorEvent;
  var ErrorCode: Integer);
begin
 ErrorCode:=0;
end;


end.
