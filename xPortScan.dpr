program xPortScan;

uses
  Forms,
  main in 'main.pas' {FMain},
  glob in 'glob.pas',
  thrd in 'thrd.pas',
  ripec in 'ripec.pas' {FRipeC};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TFMain, FMain);
  Application.CreateForm(TFRipeC, FRipeC);
  Application.Run;
end.
