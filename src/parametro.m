% Função que retorna os dados da rede recém convertida e calcula os
% parâmetros da rede
function [param] = parametro(rede)

% Carregando os dados da rede recém convertida
param.nBarras = length(rede.Barras(:,1)); % Número total de barras
param.nLinhas = length(rede.Linhas(:,1)); % Número total de ramos
param.nPV = length(rede.PV(:,1)); % Número total de barras PV
param.nPQ = length(rede.PQ(:,1)); % Número total de barras PQ
param.Sbase = rede.SW(1,2); % Potência base da rede (MVA)
param.nLT = numel(find(rede.Linhas(:,12) == 0)); % Número de linhas de transmissão
param.nTrf = numel(find(rede.Linhas(:,12) ~= 0)); % Número de transformadores
param.nGer = numel(find(rede.PV(:,3) ~= 0)) + 1; % Número de geradores
param.nComp = numel(find(rede.PV(:,3) == 0)); % Número de compensadores (est. e sínc.)
param.nLoad = numel(find(rede.PQ(:,5) == 1)); % Número de cargas efetivas
param.nBpass = numel(find(rede.PQ(:,5) == 0)); % Número de barras passivas

% Índice das barras DE e PARA
[param.DE, param.PARA] = indice_barras(rede,param);