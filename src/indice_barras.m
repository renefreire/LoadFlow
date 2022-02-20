% Função para normalizar os índices das barras
function [DE, PARA] = indice_barras(rede,param)

% Separando os índices das barras
k = 1:param.nBarras;
index(k,1) = rede.Barras(k,1);
index(k,2) = k;

% Barras DE e PARA normalizadas
m = 1:param.nLinhas;
n = 1:param.nBarras;
[M,N] = meshgrid(m,n);

i = find(rede.Linhas(M,1) == rede.Barras(N,1));
j = find(i > param.nBarras);
i(j) = i(j) - param.nBarras*((ceil(i(j)/param.nBarras)) - 1);
DE(m) = index(i,2);

g = find(rede.Linhas(M,2) == rede.Barras(N,1));
h = find(g > param.nBarras);
g(h) = g(h) - param.nBarras*((ceil(g(h)/param.nBarras)) - 1);
PARA(m) = index(g,2);