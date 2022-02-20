% Fun��o que retorna os dados da rede rec�m convertida e calcula os
% par�metros da rede
function [param] = parametro(rede)

% Carregando os dados da rede rec�m convertida
param.nBarras = length(rede.Barras(:,1)); % N�mero total de barras
param.nLinhas = length(rede.Linhas(:,1)); % N�mero total de ramos
param.nPV = length(rede.PV(:,1)); % N�mero total de barras PV
param.nPQ = length(rede.PQ(:,1)); % N�mero total de barras PQ
param.Sbase = rede.SW(1,2); % Pot�ncia base da rede (MVA)
param.nLT = numel(find(rede.Linhas(:,12) == 0)); % N�mero de linhas de transmiss�o
param.nTrf = numel(find(rede.Linhas(:,12) ~= 0)); % N�mero de transformadores
param.nGer = numel(find(rede.PV(:,3) ~= 0)) + 1; % N�mero de geradores
param.nComp = numel(find(rede.PV(:,3) == 0)); % N�mero de compensadores (est. e s�nc.)
param.nLoad = numel(find(rede.PQ(:,5) == 1)); % N�mero de cargas efetivas
param.nBpass = numel(find(rede.PQ(:,5) == 0)); % N�mero de barras passivas

% �ndice das barras DE e PARA
[param.DE, param.PARA] = indice_barras(rede,param);