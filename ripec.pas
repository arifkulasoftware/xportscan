unit ripec;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Buttons;

type
  TFRipeC = class(TForm)
    Panel1: TPanel;
    Label1: TLabel;
    Edit1: TEdit;
    Label2: TLabel;
    Edit2: TEdit;
    Label3: TLabel;
    Edit3: TEdit;
    SpeedButton2: TSpeedButton;
    SpeedButton1: TSpeedButton;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    OpenDialog1: TOpenDialog;
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    RList : TStringList ;
    UList : TStringList ;
  end;

 Procedure RipeConvert;

 var
  FRipeC: TFRipeC;

 implementation

{$R *.DFM}

Procedure RipeConvert;

 Var
  St : String  ;
  Rm : String  ;
  I  : Integer ;
  
 Begin
  With FRipeC Do
   Begin
    If ShowModal<>mrOk Then Exit;
    RList.LoadFromFile(Edit1.Text);
    UList.Clear;
    If RList.Count=0 Then
     Begin ShowMessage(Edit1.Text+' file empty!');Exit;End;
    Rm:='';
    For I:=0 To RList.Count-1 Do
     Begin
      St:=Trim(RList[I]);
      If Pos('ALLOCATED',St)>0 Then
       Begin
        Delete(St,1,Pos(' ',St));
        St:=Copy(St,1,Pos(' ',St)-1);
        UList.Add(St+':'+Edit2.Text+' ; '+Rm);
       End Else If Pos(')',St)>Pos('(',St) Then Rm:=Copy(St,Pos('(',St)+1,Pos(')',St)-Pos('(',St)-1);
     End;
    UList.SaveToFile(Edit3.Text); 
    ShowMessage('RIPE file Converted');
   End;
 End;

procedure TFRipeC.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
 If ModalResult<>mrOk Then Exit;
 If Trim(Edit1.Text)='' Then Exit;
 If Trim(Edit2.Text)='' Then Exit;
 If Trim(Edit3.Text)='' Then Exit;
 If Not FileExists(Edit1.Text) Then
  Begin ShowMessage(Edit1.Text+' File Not Found');Exit;End;
end;

procedure TFRipeC.FormCreate(Sender: TObject);
begin
 RList:=TStringList.Create;
 UList:=TStringList.Create;
end;

procedure TFRipeC.SpeedButton2Click(Sender: TObject);
begin
 If Not OpenDialog1.Execute Then Exit;
 Edit1.Text:=OpenDialog1.FileName;
end;

procedure TFRipeC.SpeedButton1Click(Sender: TObject);
begin
 If Not OpenDialog1.Execute Then Exit;
 Edit3.Text:=OpenDialog1.FileName;
end;

end.
