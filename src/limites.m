% Função que retorna os limites superior e inferior de geração de potência 
% ativa e tensão nas barras para cada máquina
function [limite] = limites(flag,param,rede)

i = 1:param.nBarras;
j = 1:param.nPV;
[J,I] = meshgrid(j,i);
k = find(rede.Barras(I,1) == rede.PV(J,1));
l = find(k > param.nBarras);
k(l) = k(l) - param.nBarras*((ceil(k(l)/param.nBarras)) - 1);

if strcmp(flag,'PVmin')
    ativo = 0.1*(rede.PV(:,3)');
    tensao = rede.Barras(k,5)';
elseif strcmp(flag,'PVmax')
    ativo = 1.5*(rede.PV(:,3)');
    tensao = rede.Barras(k,6)';
end

limite = cat(2,ativo,tensao);