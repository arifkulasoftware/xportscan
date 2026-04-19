unit main;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, Menus, ActnList, ExtCtrls, ToolWin, StdCtrls, Buttons, ImgList,
  Winsock,Math,iniFiles;

type
  TFMain = class(TForm)
    StatusBar1: TStatusBar;
    MainMenu1: TMainMenu;
    ActionList1: TActionList;
    File1: TMenuItem;
    Config1: TMenuItem;
    N1: TMenuItem;
    Exit1: TMenuItem;
    acExit: TAction;
    Panel1: TPanel;
    Panel2: TPanel;
    ToolBar1: TToolBar;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    Label1: TLabel;
    Edit1: TEdit;
    SpeedButton1: TSpeedButton;
    Label2: TLabel;
    Edit2: TEdit;
    Edit3: TEdit;
    Label3: TLabel;
    Label4: TLabel;
    Edit4: TEdit;
    SpeedButton2: TSpeedButton;
    Memo1: TMemo;
    PopupMenu1: TPopupMenu;
    Clear1: TMenuItem;
    ImageList1: TImageList;
    ImageList2: TImageList;
    acStart: TAction;
    StartStop1: TMenuItem;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    Timer1: TTimer;
    ProgressBar1: TProgressBar;
    acRipeConvert: TAction;
    TabSheet3: TTabSheet;
    Label5: TLabel;
    Edit5: TEdit;
    OpenDialog1: TOpenDialog;
    Label6: TLabel;
    Edit6: TEdit;
    procedure acExitExecute(Sender: TObject);
    procedure Clear1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure acStartExecute(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure acRipeConvertExecute(Sender: TObject);
    procedure Edit5Change(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
    IPLists : TStringList ;
    JobList : TList       ;
    LJob    : Integer     ;
    LJobPos : Integer     ;
    LIpPos  : Cardinal    ;
    MaxJob  : Integer     ;
    MaxOpen : Integer     ;
    Procedure LoadIpList  ;
    Procedure FreeJobList ;
    Procedure ClearPanel  ;
  end;

var
  FMain: TFMain;

implementation

uses glob, thrd, ripec;

{$R *.DFM}
Procedure TFMain.ClearPanel;

 Begin
  StatusBar1.Panels[0].Text:='';
  StatusBar1.Panels[1].Text:='';
  StatusBar1.Panels[2].Text:='';
  StatusBar1.Panels[3].Text:='';
 End;

Procedure TFMain.FreeJobList ;

 Begin
  While JobList.Count>0 Do
   begin
    IPsC(JobList[0]).Free;
    JobList.Delete(0);
   End;
  MaxJob:=0;   
 end;

procedure TFMain.LoadIpList ;

 Var
  St,Rem : String ;
  I      : Integer ;
  IsC    : IPsC    ; 

 Function ParseLine(L,Rm:String):IPsC;

  Var
   Ip,Port,SIp,EIp,Sub : String  ;
   IPl,Sbl             : LongInt ;
   Sp,Ep               : String  ;
   IC                  : IPsC    ;
   PC                  : PortsC  ; 

  Begin
   Result:=Nil;
   PC:=Nil;
   If Pos(':',L)=0 Then Exit; // Port Not Defined
   IP:=Trim(Copy(L,1,Pos(':',L)-1));
   Delete(L,1,Pos(':',L));
   Port:=Trim(L);
// IP Parse
   If (IP='') Or (Port='') Then Exit;
   SIp:=Ip;EIp:=Ip;
   If Pos('/',IP)>0 Then
    Begin
     SIp:=Trim(Copy(IP,1,Pos('/',IP)-1));Delete(IP,1,Pos('/',IP));
     Sub:=Trim(Ip);
     While CharCount('.',SIp)<3 Do SIp:=SIp+'.0';
     Try
      IPl:=inet_addr(@SIP[1]);
      Sbl:=StrToInt(Sub);
      Sbl:=Round(Power(2,32-Sbl));
      IPl:=htonl(ntohl(IPl)+Sbl);
      EIp:=inet_ntoa(in_addr(IPL));
      Except Exit;
     End;
     IP:=SIp+'-'+EIp;
    End;

   If Pos('-',IP)>0 Then
    Begin
     SIp:=Trim(Copy(IP,1,Pos('-',IP)-1));Delete(IP,1,Pos('-',IP));
     EIp:=Trim(Ip);
    End;

   If (SIp='') Or (EIp='') Then Exit;  // - var SIp yok

   Try
    IC:=IPsC.Create(inet_addr(@SIp[1]),inet_addr(@EIp[1]),Rm);
    Except Exit;
   End; // IP Start - End ok

// Port Parse

   Repeat
    Sub:=Port;
    If Pos(',',Port)>0 Then
     Begin
      Sub:=Copy(Port,1,Pos(',',Port)-1);
      Delete(Port,1,Pos(',',Port));
     End Else Port:='';
    Sub:=Trim(Sub);
    Sp:=Sub;Ep:=Sub;
    If Pos('-',Sub)>0 Then
     Begin
      Sp:=Trim(Copy(Sub,1,Pos('-',Sub)-1));Delete(Sub,1,Pos('-',Sub));
      Ep:=Trim(Sub);
     End;
    Try
     PC:=PortsC.Create(StrToInt(Sp),StrToInt(Ep));
     Inc(MaxJob,Round((Ic.EIp-IC.SIp+1.0)*(Pc.Ep-Pc.Sp+1.0)));
    Except
     IC.Free;
     Exit ;
    End;
    IC.Ports.Add(PC);
   Until Port='';
   Result:=IC;
  End;

 Begin
  IPLists.Clear;
  FreeJobList;
  If PageControl1.ActivePageIndex=0 Then
   Begin
    Try
     IPLists.LoadFromFile(Edit1.Text);
    Except
     ShowMessage(Edit1.Text+' Not Found');
     Exit;
    End;
   End Else Begin
    If (Trim(Edit2.Text)='') Or (Trim(Edit3.Text)='') Then
     Begin
      ShowMessage('IP LIST and PORTS must exists');
      Exit;
     End;
    IPLists.Add(Edit2.Text+':'+Edit3.Text);
   End;
  If IPLists.Count=0 Then
   Begin ShowMessage('IP file empty');Exit;End;
  For I:=0 To IPLists.Count-1 Do
   Begin
    St:=IPLists[I];
    Rem:='';
    If Pos(';',St)>0 Then
     Begin
      Rem:=Copy(St,Pos(';',St)+1,LenGth(St));
      Delete(St,Pos(';',St),LenGth(St)); // Remark kaldir
     End;
    St:=Trim(St);                                     
    If St<>'' Then
     Begin
      IsC:=ParseLine(St,Rem);
      If Not Assigned(IsC) Then
       Begin
        IPLists.Clear;
        FreeJobList;
        ShowMessage('Error on line '+St);
        Exit;
       End;
      JobList.Add(IsC);
     End;
   End;
  If JobList.Count=0 Then ShowMessage('IP List empty');
 End;

procedure TFMain.acExitExecute(Sender: TObject);
begin
 Close;
end;

procedure TFMain.Clear1Click(Sender: TObject);
begin
 Memo1.Lines.Clear;
end;

procedure TFMain.FormCreate(Sender: TObject);

 Var
  FIni : TIniFile ;
  St   : String   ;
  
begin
 PageControl1.ActivePageIndex:=0;
 IPLists:=TStringList.Create ;
 JobList:=TList.Create;
 MaxOpen:=128;
 LJobPos:=0;
 LIpPos:=0;

 FIni:=TIniFile.Create(INIFile);
 Edit2.Text:=FIni.ReadString('CONFIG','IP_LIST','');
 Edit3.Text:=FIni.ReadString('CONFIG','PORTS','');
 Edit1.Text:=FIni.ReadString('CONFIG','IP_FILE','iplists.txt');
 Edit6.Text:=FIni.ReadString('CONFIG','THREADS','4');
 Edit5.Text:=FIni.ReadString('CONFIG','MAX_OPEN','255');
 Edit4.Text:=FIni.ReadString('CONFIG','LOG_FILE','connects.log');
 St:=FIni.ReadString('CONFIG','LASTJOBPOS','0');
 Try LJobPos:=StrToInt(St); Except LJobPos:=0; End ;
 St:=FIni.ReadString('CONFIG','LASTIPPOS','0');
 Try LIpPos:=StrToInt64(St); Except LIpPos:=0; End ;
 St:=FIni.ReadString('CONFIG','PAGE','0');
 Try PageControl1.ActivePageIndex:=StrToInt(St); Except PageControl1.ActivePageIndex:=0;End;
 FIni.Free;
end;

procedure TFMain.acStartExecute(Sender: TObject);
begin
 If Timer1.Tag=1 Then
  Begin
   Timer1.Tag:=2;
   acStart.Enabled:=False;
   Exit;
  End;
 LJob:=0;
 LoadIpList;
 If JObList.Count=0 Then Exit;
 If (LJobPos+LIpPos>0) And (LJobPos<JObList.Count) Then
  Case MessageDlg('Continue from last position ?',mtConfirmation,mbYesNoCancel,0) Of
   mrYes : Begin
    LJob:=LJobPos;
    IPsC(JobList[LJob]).Ps:=LIpPos;
   End;
   mrNo : ;
   mrCancel : Exit;
  End; 
 acStart.ImageIndex:=2;
 acStart.Caption:='Stop';
 LogFn:=Edit4.Text;
 LJobPos:=0;
 LIpPos:=0;
 ClearPanel;
 ProgressBar1.Position:=0;
 ProgressBar1.Max:=MaxJob;
 Timer1.Tag:=1;
 Timer1.Enabled:=True;
end;

procedure TFMain.Timer1Timer(Sender: TObject);
Var
 IC   : IpsC    ;
 PC   : PortsC  ;
 Th   : MyTh    ;

begin
 Timer1.Enabled:=False;
 StatusBar1.Panels[3].Text:=IntToStr(Opened);
 If Timer1.Tag=2 Then
  Begin
   If Opened=0 Then
    Begin
     acStart.ImageIndex:=0;
     acStart.Caption:='Start';
     acStart.Enabled:=True;
     Timer1.Tag:=0;
     LJobPos:=0;
     LIpPos:=0;
     If LJob<JobList.Count Then
      Begin
       LJobPos:=LJob;
       LIpPos:=IPsC(JobList[LJob]).Ps;
      End; 
     Exit;
    End;
   Timer1.Enabled:=True;
   Exit;
  End;
 If LJob>=JobList.Count Then
  Begin
   acStartExecute(Nil);
   Timer1.Enabled:=True;
   Exit;
  End;
 If Opened>MaxOpen Then Begin Timer1.Enabled:=True;Exit;End;
 IC:=IPsC(JobList[LJob]);
 If Ic.Ps<=Ic.EIp Then
  Begin
   If IC.P<IC.Ports.Count Then
    Begin
     PC:=IC.Ports[IC.P];
     If PC.Ps<=Pc.Ep Then
      Begin
       Th:=MyTh.Create(True);
       Th.IP:=inet_ntoa(in_addr(htonl(IC.Ps)));
       Th.Port:=Pc.Ps;

       StatusBar1.Panels[0].Text:=IC.Rem;
       StatusBar1.Panels[1].Text:=Th.IP;
       StatusBar1.Panels[2].Text:=IntToStr(Th.Port);
       ProgressBar1.Position:=ProgressBar1.Position+1;
       Th.Resume;
       Inc(Pc.Ps);
      End Else Begin
       PC.Ps:=Pc.Sp;
       Inc(IC.P);
      End;
    End Else Begin
     Ic.P:=0;
     Inc(IC.Ps);
    End;
  End Else Begin
   Ic.Ps:=IC.SIp;
   Inc(LJob);
  End; 
 Timer1.Enabled:=True;
end;

procedure TFMain.acRipeConvertExecute(Sender: TObject);
begin
 RipeConvert;
end;

procedure TFMain.Edit5Change(Sender: TObject);
begin
 Try
  MaxOpen:=StrToInt(Edit5.Text);
 Except
  MaxOpen:=128;
 End;
end;

procedure TFMain.SpeedButton2Click(Sender: TObject);
begin
 OpenDialog1.DefaultExt:='log';
 OpenDialog1.FilterIndex:=2; 
 If Not OpenDialog1.Execute Then Exit;
 Edit4.Text:=OpenDialog1.FileName;
end;

procedure TFMain.SpeedButton1Click(Sender: TObject);
begin
 OpenDialog1.DefaultExt:='txt';
 OpenDialog1.FilterIndex:=1;
 If Not OpenDialog1.Execute Then Exit;
 Edit4.Text:=OpenDialog1.FileName;
end;

procedure TFMain.FormClose(Sender: TObject; var Action: TCloseAction);
Var
  FIni : TIniFile ;
begin
 If (Opened>0) And (LJob<JobList.Count) Then
  Begin
   LJobPos:=LJob;
   LIpPos:=IPsC(JobList[LJob]).Ps;
  End;
 DeleteFile(INIFile);
 FIni:=TIniFile.Create(INIFile);
 FIni.WriteString('CONFIG','IP_LIST',Edit2.Text);
 FIni.WriteString('CONFIG','PORTS',Edit3.Text);
 FIni.WriteString('CONFIG','IP_FILE',Edit1.Text);
 FIni.WriteString('CONFIG','THREADS',Edit6.Text);
 FIni.WriteString('CONFIG','MAX_OPEN',Edit5.Text);
 FIni.WriteString('CONFIG','LOG_FILE',Edit4.Text);
 FIni.WriteString('CONFIG','LASTJOBPOS',IntToStr(LJobPos));
 FIni.WriteString('CONFIG','LASTIPPOS',IntToStr(LIpPos));
 FIni.WriteString('CONFIG','PAGE',IntToStr(PageControl1.ActivePageIndex)); 
 FIni.Free;
end;

end.
