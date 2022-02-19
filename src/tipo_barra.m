% Função que classifica as barras do sistema em 3 tipos:
% 1 - barra de carga
% 2 - barra de geração
% 3 - barra de referência angular

function [tipo] = tipo_barra(rede,param)

tipo = zeros(param.nBarras,1);
for k = 1:param.nBarras
    for j = 1:param.nPQ
        if rede.Barras(k,1) == rede.PQ(j,1)
            tipo(k) = 1;
        end
    end
    for m = 1:param.nPV
        if rede.Barras(k,1) == rede.PV(m,1)
            tipo(k) = 2;
        end
    end
    if rede.Barras(k,1) == rede.SW(1,1)
        tipo(k) = 3;
    end
end

for k = 1:param.nBarras
    if tipo(k) == 0
        tipo(k) = 1;
    end
end