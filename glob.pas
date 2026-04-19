unit glob;

interface

 Uses Classes,WinSock;

 Type
  PortsC = Class
   Sp,Ep : Word ;
   Ps    : Word ;
   Constructor Create(S,E:Word);
  End;

  IPsC = Class
   SIp,EIp : Cardinal ;
   Ports   : TList   ;
   P       : Integer ; // Port list Pos
   Ps      : Cardinal ; // IP Pos
   Rem     : String  ;
   Constructor Create(S,E:Integer;R:String);
   Destructor Destroy ; Override ;
  End;

 Const
  INIFile = '.\xportscan.ini';  

 Function CharCount(Ch:Char;St:String):Integer ;

implementation

Constructor PortsC.Create(S,E:Word);

 Begin
  inherited Create;
  Sp:=S; Ep:=E;
  If S>E Then Begin Sp:=E;Ep:=S;End; 
  Ps:=Sp;
 End;

Constructor IPsC.Create(S,E:Integer;R:String);

 Begin
  inherited Create;
  S:=ntohl(S);E:=ntohl(E);
  SIp:=S;EIp:=E;
  If S>E Then Begin SIp:=E;EIp:=S;End;
  Ps:=SIp;
  Rem:=R;
  P:=0;
  Ports:=TList.Create;
 End;

Destructor IPsC.Destroy ;

 Begin
  inherited ;
  While Ports.Count>0 Do
   Begin
    PortsC(Ports[0]).Free;
    Ports.Delete(0);
   End;
  Ports.Free; 
 End;

Function CharCount(Ch:Char;St:String):Integer ;
 Var I:Integer;
 Begin
  Result:=0;
  If LenGth(ST)=0 Then Exit;
  For I:=1 To LenGth(ST) Do
   If St[I]=Ch Then Inc(Result);
 End;


end.
 