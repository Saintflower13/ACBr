{******************************************************************************}
{ Projeto: Componente ACBreSocial                                              }
{  Biblioteca multiplataforma de componentes Delphi para envio dos eventos do  }
{ eSocial - http://www.esocial.gov.br/                                         }
{                                                                              }
{ Direitos Autorais Reservados (c) 2008 Wemerson Souto                         }
{                                       Daniel Simoes de Almeida               }
{                                       Andr� Ferreira de Moraes               }
{                                                                              }
{ Colaboradores nesse arquivo:                                                 }
{                                                                              }
{  Voc� pode obter a �ltima vers�o desse arquivo na pagina do Projeto ACBr     }
{ Componentes localizado em http://www.sourceforge.net/projects/acbr           }
{                                                                              }
{                                                                              }
{  Esta biblioteca � software livre; voc� pode redistribu�-la e/ou modific�-la }
{ sob os termos da Licen�a P�blica Geral Menor do GNU conforme publicada pela  }
{ Free Software Foundation; tanto a vers�o 2.1 da Licen�a, ou (a seu crit�rio) }
{ qualquer vers�o posterior.                                                   }
{                                                                              }
{  Esta biblioteca � distribu�da na expectativa de que seja �til, por�m, SEM   }
{ NENHUMA GARANTIA; nem mesmo a garantia impl�cita de COMERCIABILIDADE OU      }
{ ADEQUA��O A UMA FINALIDADE ESPEC�FICA. Consulte a Licen�a P�blica Geral Menor}
{ do GNU para mais detalhes. (Arquivo LICEN�A.TXT ou LICENSE.TXT)              }
{                                                                              }
{  Voc� deve ter recebido uma c�pia da Licen�a P�blica Geral Menor do GNU junto}
{ com esta biblioteca; se n�o, escreva para a Free Software Foundation, Inc.,  }
{ no endere�o 59 Temple Street, Suite 330, Boston, MA 02111-1307 USA.          }
{ Voc� tamb�m pode obter uma copia da licen�a em:                              }
{ http://www.opensource.org/licenses/lgpl-license.php                          }
{                                                                              }
{ Daniel Sim�es de Almeida  -  daniel@djsystem.com.br  -  www.djsystem.com.br  }
{              Pra�a Anita Costa, 34 - Tatu� - SP - 18270-410                  }
{                                                                              }
{******************************************************************************}

{******************************************************************************
|* Historico
|*
|* 27/10/2015: Jean Carlo Cantu, Tiago Ravache
|*  - Doa��o do componente para o Projeto ACBr
|* 13/02/2019: Arce
|*  - Criada classes do evento S-2221
******************************************************************************}
{$I ACBr.inc}

unit pcesS2221;

interface

uses
  SysUtils, Classes,
  pcnConversao, pcnGerador, ACBrUtil,
  pcesCommon, pcesConversaoeSocial, pcesGerador;

type
  TS2221Collection = class;
  TS2221CollectionItem = class;
  TEvtToxic = class;
  TToxicologico = class;

  TS2221Collection = class(TOwnedCollection)
  private
    function GetItem(Index: Integer): TS2221CollectionItem;
    procedure SetItem(Index: Integer; Value: TS2221CollectionItem);
  public
    function Add: TS2221CollectionItem;
    property Items[Index: Integer]: TS2221CollectionItem read GetItem write SetItem; default;
  end;

  TS2221CollectionItem = class(TCollectionItem)
  private
    FTipoEvento: TTipoEvento;
    FEvtToxic: TEvtToxic;
    procedure setEvtToxic(const Value: TEvtToxic);
  public
    constructor Create(AOwner: TComponent); reintroduce;
    destructor  Destroy; override;
  published
    property TipoEvento: TTipoEvento read FTipoEvento;
    property EvtToxic: TEvtToxic read FEvtToxic write setEvtToxic;
  end;

  TToxicologico = class(TPersistent)
  private
    FdtExame: TDateTime;
    FnmMed: String;
    FufCRM: String;
    FcodSeqExame: String;
    FcnpjLab: String;
    FindRecusa: tpSimNao;
    FnrCRM: String;
  public
     property dtExame: TDateTime read FdtExame write FdtExame;
     property cnpjLab: String read FcnpjLab write FcnpjLab;
     property codSeqExame: String read FcodSeqExame write FcodSeqExame;
     property nmMed: String read FnmMed write FnmMed;
     property nrCRM: String read FnrCRM write FnrCRM;
     property ufCRM: String read FufCRM write FufCRM;
     property indRecusa: tpSimNao read FindRecusa write FindRecusa;
  end;

  TEvtToxic = class(TeSocialEvento)
  private
    FIdeEvento: TIdeEvento2;
    FIdeEmpregador: TIdeEmpregador;
    FIdeVinculo: TIdeVinculo;
    FToxicologico: TToxicologico;
    FACBreSocial: TObject;

    { Geradores da classe }
    procedure GerarToxicologico(objToxicologico: TToxicologico);
  public
    constructor Create(AACBreSocial: TObject);overload;
    destructor  Destroy; override;

    function GerarXML: boolean; override;
    function LerArqIni(const AIniString: String): Boolean;

    property IdeEvento: TIdeEvento2 read FIdeEvento write FIdeEvento;
    property IdeEmpregador: TIdeEmpregador read FIdeEmpregador write FIdeEmpregador;
    property IdeVinculo: TIdeVinculo read FIdeVinculo write FIdeVinculo;
    property toxicologico: TToxicologico read FToxicologico write FToxicologico;
  end;

implementation

uses
  IniFiles,
  ACBreSocial;

{ TS2221CollectionItem }

constructor TS2221CollectionItem.Create(AOwner: TComponent);
begin
  FTipoEvento := teS2221;
  FEvtToxic   := TEvtToxic.Create(AOwner);
end;

destructor TS2221CollectionItem.Destroy;
begin
  FEvtToxic.Free;

  inherited;
end;

procedure TS2221CollectionItem.setEvtToxic(const Value: TEvtToxic);
begin
  FEvtToxic.Assign(Value);
end;

{ TS2221Collection }

function TS2221Collection.Add: TS2221CollectionItem;
begin
  Result := TS2221CollectionItem(inherited Add);
  Result.Create(TComponent(Self.Owner));
end;

function TS2221Collection.GetItem(Index: Integer): TS2221CollectionItem;
begin
  Result := TS2221CollectionItem(inherited GetItem(Index));
end;

procedure TS2221Collection.SetItem(Index: Integer; Value: TS2221CollectionItem);
begin
  inherited SetItem(Index, Value);
end;

constructor TEvtToxic.Create(AACBreSocial: TObject);
begin
  inherited;

  FACBreSocial   := AACBreSocial;
  FIdeEvento     := TIdeEvento2.Create;
  FIdeEmpregador := TIdeEmpregador.Create;
  FIdeVinculo    := TIdeVinculo.Create;
  FToxicologico  := TToxicologico.Create;
end;

destructor TEvtToxic.destroy;
begin
  FIdeEvento.Free;
  FIdeEmpregador.Free;
  FIdeVinculo.Free;
  FToxicologico.Free;

  inherited;
end;

procedure TEvtToxic.GerarToxicologico(objToxicologico: TToxicologico);
begin
  Gerador.wGrupo('toxicologico');

  Gerador.wCampo(tcDat, '', 'dtExame',    10, 10, 1, objToxicologico.dtExame);
  Gerador.wCampo(tcStr, '', 'cnpjLab',     1, 14, 0, objToxicologico.cnpjLab);
  Gerador.wCampo(tcStr, '', 'codSeqExame', 1, 11, 0, objToxicologico.codSeqExame);
  Gerador.wCampo(tcStr, '', 'nmMed',       1, 70, 0, objToxicologico.nmMed);
  Gerador.wCampo(tcStr, '', 'nrCRM',       1,  8, 0, objToxicologico.nrCRM);
  Gerador.wCampo(tcStr, '', 'ufCRM',       1,  2, 0, objToxicologico.ufCRM);
  Gerador.wCampo(tcStr, '', 'indRecusa',   1,  1, 1, eSSimNaoToStr(objToxicologico.indRecusa));

  Gerador.wGrupo('/toxicologico');
end;

function TEvtToxic.GerarXML: boolean;
begin
  try
    Self.VersaoDF := TACBreSocial(FACBreSocial).Configuracoes.Geral.VersaoDF;

    Self.Id := GerarChaveEsocial(now, Self.ideEmpregador.NrInsc, Self.Sequencial);

    GerarCabecalho('evtToxic');
    Gerador.wGrupo('evtToxic Id="' + Self.Id + '"');

    GerarIdeEvento2(Self.IdeEvento);
    GerarToxicologico(Self.Toxicologico);

    Gerador.wGrupo('/evtToxic');

    GerarRodape;

    XML := Assinar(Gerador.ArquivoFormatoXML, 'evtToxic');

    Validar(schevtInsApo);

  except on e:exception do
    raise Exception.Create('ID: ' + Self.Id + sLineBreak + ' ' + e.Message);
  end;

  Result := (Gerador.ArquivoFormatoXML <> '')
end;

function TEvtToxic.LerArqIni(const AIniString: String): Boolean;
begin
  Result := False;

  { Implementar }

end;

end.
